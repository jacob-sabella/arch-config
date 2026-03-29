#!/usr/bin/env python3
"""Convert Neural DSP preset files to Carla .carxs state files.

Usage:
    python3 ndsp_to_carla.py <plugin> [preset_file_or_dir] [output_dir]

    <plugin>: gojira, henson, or thall
    If preset_file_or_dir is a directory, converts all .xml files recursively.
    If omitted, converts all factory presets for the given plugin.
    Output dir defaults to ~/ndsp-presets/<plugin>/
"""

import sys
import os
import re
import struct
import base64
import xml.etree.ElementTree as ET
from pathlib import Path

# Plugin configs
PLUGINS = {
    "gojira": {
        "template_carxs": Path.home() / "gojira.carxs",
        "preset_dir": Path.home() / ".wine/drive_c/ProgramData/Neural DSP/Archetype Gojira X",
        "name": "Archetype Gojira X",
    },
    "henson": {
        "template_carxs": Path.home() / "timhenson.carxs",
        "preset_dir": Path.home() / ".wine/drive_c/ProgramData/Neural DSP/Archetype Tim Henson X",
        "name": "Archetype Tim Henson X",
    },
    "thall": {
        "template_carxs": Path.home() / "thall.carxs",
        "preset_dir": Path.home() / ".wine/drive_c/ProgramData/Odeholm Audio/thall amp/Presets",
        "preset_ext": ".afx",
        "name": "thall amp",
        "direct_chunk": True,  # .afx files ARE the chunk data directly
    },
}


def parse_ndsp_preset(filepath):
    """Parse Neural DSP's binary preset format into a dict.

    Binary format: null-terminated strings with markers between key-value pairs.
    Pattern: key\\x00\\x01<len>\\x05value\\x00
    """
    with open(filepath, "rb") as f:
        data = f.read()

    params = {}

    # Extract preset name: find "name" key
    name_idx = data.find(b'\x05name\x00')
    if name_idx >= 0:
        # Value starts after the marker bytes following "name\x00"
        val_start = name_idx + 6  # skip "\x05name\x00"
        # Skip marker bytes to get to value
        while val_start < len(data) and data[val_start] != 0x05:
            val_start += 1
        if val_start < len(data):
            val_start += 1  # skip the 0x05
            val_end = data.index(b'\x00', val_start)
            params['_preset_name'] = data[val_start:val_end].decode('ascii', errors='replace')

    # Find all key=value pairs using the pattern: key\x00\x01<byte>\x05value\x00
    # The \x05 before the value is the string type marker
    i = 0
    while i < len(data) - 4:
        # Look for the pattern: \x00\x01<len>\x05 which precedes a value
        if data[i] == 0x00 and i + 1 < len(data) and data[i+1] == 0x01:
            # Find the key that precedes this marker
            # Walk backwards from i to find the start of the key (after previous \x00 or \x05)
            key_end = i
            key_start = key_end - 1
            while key_start >= 0 and data[key_start] >= 0x20 and data[key_start] < 0x7f:
                key_start -= 1
            key_start += 1  # skip the delimiter

            if key_start < key_end:
                try:
                    key = data[key_start:key_end].decode('ascii')
                except:
                    i += 1
                    continue

                # After \x00\x01 there are 1-2 marker bytes, then \x05, then the value.
                # The \x05 is a string type marker. We need to find the LAST \x05 in the
                # marker region before the value starts.
                marker_pos = i + 2  # skip \x00\x01
                found_value = False
                # Scan up to 4 bytes for the \x05 type marker
                for scan in range(marker_pos, min(marker_pos + 4, len(data))):
                    if data[scan] == 0x05:
                        # Check if the byte after \x05 starts a printable ASCII value
                        val_start = scan + 1
                        if val_start >= len(data):
                            break
                        if data[val_start] < 0x20 or data[val_start] >= 0x7f:
                            continue  # not a printable value, keep scanning
                        val_end = data.find(b'\x00', val_start)
                        if val_end < 0:
                            val_end = len(data)
                        try:
                            val = data[val_start:val_end].decode('ascii')
                        except:
                            break
                        # Only store if key looks like a parameter name and value looks valid
                        if (re.match(r'^[a-zA-Z][a-zA-Z0-9]*$', key) and
                            key not in ('subModels', 'listElements') and
                            (re.match(r'^-?\d+\.?\d*$', val) or val in ('true', 'false'))):
                            params[key] = val
                        found_value = True
                        i = val_end
                        break

                if not found_value:
                    i += 1
                    continue
            else:
                i += 1
        else:
            i += 1

    return params


def extract_chunk_xml(carxs_path):
    """Extract the internal XML from a Carla .carxs file."""
    tree = ET.parse(carxs_path)
    root = tree.getroot()
    chunk_el = root.find('.//Chunk')
    if chunk_el is None:
        raise ValueError(f"No <Chunk> found in {carxs_path}")

    chunk_b64 = chunk_el.text.strip()
    chunk_bytes = base64.b64decode(chunk_b64)

    # Header: "VC2!" + 4 bytes length
    header = chunk_bytes[:8]
    xml_bytes = chunk_bytes[8:]
    # Strip trailing null
    xml_bytes = xml_bytes.rstrip(b'\x00')
    return header[:4], xml_bytes


def apply_preset_to_xml(xml_bytes, params):
    """Apply preset parameters to the template XML."""
    root = ET.fromstring(xml_bytes)

    def update_attrs(el):
        for key in list(el.attrib.keys()):
            if key in params:
                el.attrib[key] = str(params[key])
        for child in el:
            update_attrs(child)

    update_attrs(root)

    # Mark as changed
    root.attrib['presetChanged'] = 'true'

    # Serialize back
    return ET.tostring(root, encoding='unicode')


def build_chunk(magic, xml_str):
    """Build the VST2 chunk with header."""
    xml_bytes = xml_str.encode('utf-8') + b'\x00'
    length = len(xml_bytes)
    header = magic + struct.pack('<I', length)
    return header + xml_bytes


def build_carxs(template_path, chunk_bytes):
    """Build a complete .carxs file using the template structure."""
    tree = ET.parse(template_path)
    root = tree.getroot()

    chunk_el = root.find('.//Chunk')
    # Base64 encode with line wrapping
    b64 = base64.b64encode(chunk_bytes).decode('ascii')
    # Wrap at 76 chars
    lines = [b64[i:i+76] for i in range(0, len(b64), 76)]
    chunk_el.text = '\n' + '\n'.join(lines) + '\n   '

    return ET.tostring(root, encoding='unicode', xml_declaration=True)


def extract_afx_name(data):
    """Extract preset name from an .afx binary file."""
    idx = data.find(b'preset_name\x00')
    if idx < 0:
        return None
    # Skip past "preset_name\x00" then marker bytes to find \x05 + name
    scan = idx + len(b'preset_name\x00')
    while scan < min(idx + 20, len(data)):
        if data[scan] == 0x05:
            val_start = scan + 1
            val_end = data.find(b'\x00', val_start)
            if val_end > val_start:
                return data[val_start:val_end].decode('ascii', errors='replace')
            break
        scan += 1
    return None


def convert_preset(plugin_key, preset_path, output_dir):
    """Convert a single preset file to a Carla .carxs file."""
    config = PLUGINS[plugin_key]
    template_path = config["template_carxs"]

    if config.get("direct_chunk"):
        # For plugins like thall amp where .afx IS the chunk data
        with open(preset_path, 'rb') as f:
            chunk = f.read()
        preset_name = extract_afx_name(chunk) or preset_path.stem
        carxs_content = build_carxs(template_path, chunk)
    else:
        # Neural DSP XML-based plugins
        params = parse_ndsp_preset(preset_path)
        preset_name = params.get('_preset_name', preset_path.stem)
        magic, template_xml = extract_chunk_xml(template_path)
        new_xml = apply_preset_to_xml(template_xml, params)
        chunk = build_chunk(magic, new_xml)
        carxs_content = build_carxs(template_path, chunk)

    # Determine output path preserving subfolder structure
    preset_dir = config["preset_dir"]
    try:
        rel = preset_path.relative_to(preset_dir)
        out_path = output_dir / rel.with_suffix('.carxs')
    except ValueError:
        out_path = output_dir / f"{preset_name}.carxs"

    out_path.parent.mkdir(parents=True, exist_ok=True)

    with open(out_path, 'w') as f:
        f.write('<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n')
        f.write('<!DOCTYPE CARLA-PRESET>\n')
        # Remove the xml declaration ET added since we write our own
        content = carxs_content
        if content.startswith('<?xml'):
            content = content[content.index('?>') + 2:].lstrip('\n')
        f.write(content + '\n')

    return out_path, preset_name


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    plugin_key = sys.argv[1].lower()
    if plugin_key not in PLUGINS:
        print(f"Unknown plugin: {plugin_key}")
        print(f"Available: {', '.join(PLUGINS.keys())}")
        sys.exit(1)

    config = PLUGINS[plugin_key]

    # Determine input
    if len(sys.argv) >= 3:
        input_path = Path(sys.argv[2])
    else:
        input_path = config["preset_dir"]

    # Determine output
    if len(sys.argv) >= 4:
        output_dir = Path(sys.argv[3])
    else:
        output_dir = Path.home() / "ndsp-presets" / plugin_key

    # Collect preset files
    preset_ext = config.get("preset_ext", ".xml")
    if input_path.is_file():
        presets = [input_path]
    elif input_path.is_dir():
        presets = sorted(input_path.rglob(f"*{preset_ext}"))
    else:
        print(f"Not found: {input_path}")
        sys.exit(1)

    if not presets:
        print(f"No {preset_ext} preset files found in {input_path}")
        sys.exit(1)

    print(f"Converting {len(presets)} presets for {config['name']}...")
    print(f"Output: {output_dir}/")
    print()

    converted = 0
    errors = 0
    for p in presets:
        try:
            out_path, name = convert_preset(plugin_key, p, output_dir)
            rel_out = out_path.relative_to(output_dir)
            print(f"  {name} -> {rel_out}")
            converted += 1
        except Exception as e:
            print(f"  ERROR: {p.name}: {e}")
            errors += 1

    print(f"\nDone: {converted} converted, {errors} errors")
    print(f"Load in Carla: right-click plugin -> Load State -> select .carxs file")


if __name__ == "__main__":
    main()
