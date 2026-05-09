//@ pragma UseQApplication
//@ pragma IgnoreSystemSettings
//
// Side-gutter visual backdrop. Two layer-shell columns matching the monitor's
// reserved area (left + right). Color tracks matugen.json (live-watched), so
// `matugen` regen retints the gutters automatically.
//
// Run via: qs -p ~/.config/quickshell/gutters/shell.qml -d
//
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
  id: root
  property int leftWidth: 0
  property int rightWidth: 0
  property string gutterColor: "#322827"   // fallback until matugen.json loads

  // Watch matugen.json so theme regens propagate live.
  FileView {
    path: Qt.resolvedUrl(Quickshell.env("HOME") + "/.config/quickshell/matugen.json")
    watchChanges: true
    onFileChanged: this.reload()
    onLoaded: {
      try {
        const data = JSON.parse(this.text());
        if (data && data.surface_container_high) {
          root.gutterColor = data.surface_container_high;
        }
      } catch (e) {
        console.warn("gutter: failed to parse matugen.json:", e);
      }
    }
  }

  Process {
    id: poll
    command: ["bash","-c","hyprctl monitors -j | python3 -c \"import json,sys;[print(m.get('reserved',[0,0,0,0])[0],m.get('reserved',[0,0,0,0])[2]) for m in json.load(sys.stdin) if m.get('name')=='HDMI-A-2']\""]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = (this.text || "").trim().split(/\s+/);
        if (parts.length >= 2) {
          root.leftWidth  = parseInt(parts[0]) || 0;
          root.rightWidth = parseInt(parts[1]) || 0;
        }
      }
    }
  }
  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: poll.running = true
  }

  Variants {
    model: Quickshell.screens.filter(s => s.name === "HDMI-A-2")

    PanelWindow {
      required property ShellScreen modelData
      screen: modelData
      color: root.gutterColor
      visible: root.leftWidth > 0
      anchors { left: true; top: true; bottom: true }
      implicitWidth: root.leftWidth
      exclusiveZone: -1
      WlrLayershell.layer: WlrLayer.Bottom
    }
  }

  Variants {
    model: Quickshell.screens.filter(s => s.name === "HDMI-A-2")

    PanelWindow {
      required property ShellScreen modelData
      screen: modelData
      color: root.gutterColor
      visible: root.rightWidth > 0
      anchors { right: true; top: true; bottom: true }
      implicitWidth: root.rightWidth
      exclusiveZone: -1
      WlrLayershell.layer: WlrLayer.Bottom
    }
  }
}
