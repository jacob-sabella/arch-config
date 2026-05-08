//@ pragma UseQApplication
//@ pragma IgnoreSystemSettings
//
// Side-gutter visual backdrop. Renders two layer-shell columns matching the
// monitor's reserved area (left + right). Polls `hyprctl monitors -j` every
// 1s so widths track the sidepanels.lua aspect-ratio presets.
//
// exclusiveZone = 0 — Hyprland already reserves via hl.monitor, we don't
// want to double-reserve.
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
      color: "#2a2020cc"          // brighter + more opaque so empty gutters are obvious          // subtle red-tinted dark
      visible: root.leftWidth > 0
      anchors { left: true; top: true; bottom: true }
      implicitWidth: root.leftWidth
      exclusiveZone: -1           // ignore Hyprland's reserved-area offset
      WlrLayershell.layer: WlrLayer.Bottom   // sit BELOW windows
    }
  }

  Variants {
    model: Quickshell.screens.filter(s => s.name === "HDMI-A-2")

    PanelWindow {
      required property ShellScreen modelData
      screen: modelData
      color: "#2a2020cc"          // brighter + more opaque so empty gutters are obvious
      visible: root.rightWidth > 0
      anchors { right: true; top: true; bottom: true }
      implicitWidth: root.rightWidth
      exclusiveZone: -1
      WlrLayershell.layer: WlrLayer.Bottom
    }
  }
}
