import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    property var notifModel
    property var liveNotifs
    property real layoutWidth: 980
    property real layoutHeight: 680

    property color base: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.base : "#1e1e2e"
    property color surface: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.surface0 : "#313244"
    property color surface2: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.surface1 : "#45475a"
    property color text: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.text : "#cdd6f4"
    property color subtext: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.subtext0 : "#a6adc8"
    property color accent: typeof mochaColors !== "undefined" && mochaColors ? mochaColors.mauve : "#cba6f7"

    property string diskText: "ölçülüyor..."
    property string gpuText: "ölçülüyor..."
    property string uptimeText: "ölçülüyor..."

    Component.onCompleted: SysData.subscribe()
    Component.onDestruction: SysData.unsubscribe()

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { statsProc.running = false; statsProc.running = true }
    }

    Process {
        id: statsProc
        command: ["bash", "-c", "df -h / | awk 'NR==2{print $3 \" / \" $2 \" (\" $5 \")\"}'; uptime -p; if command -v sensors >/dev/null 2>&1; then sensors 2>/dev/null | awk '/edge|Tctl|Package id 0/{print $2; exit}'; else echo 'sensör yok'; fi; if [ -r /sys/class/drm/card1/device/gpu_busy_percent ]; then cat /sys/class/drm/card1/device/gpu_busy_percent; elif [ -r /sys/class/drm/card0/device/gpu_busy_percent ]; then cat /sys/class/drm/card0/device/gpu_busy_percent; else echo 'n/a'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = (this.text || "").trim().split("\n")
                if (lines.length > 0) root.diskText = lines[0] || "bilinmiyor"
                if (lines.length > 1) root.uptimeText = lines[1] || "bilinmiyor"
                if (lines.length > 2) root.gpuText = (lines[2] || "bilinmiyor") + (lines[2] && lines[2].indexOf("°") < 0 && lines[2] !== "n/a" ? " GPU" : "")
                if (lines.length > 3 && lines[3] !== "n/a") root.gpuText += "  •  " + lines[3] + "% kullanım"
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.base
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 34
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            Text { text: "SİSTEM DURUMU"; color: root.text; font.pixelSize: 28; font.bold: true; Layout.fillWidth: true }
            Text { text: "Super + Shift + I"; color: root.subtext; font.pixelSize: 14 }
        }

        Text { text: "Canlı değerler • iki saniyede bir güncellenir"; color: root.subtext; font.pixelSize: 15 }

        GridLayout {
            columns: 2
            rowSpacing: 14
            columnSpacing: 14
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: [
                    { icon: "", title: "İşlemci", value: SysData.cpu + "%", detail: "CPU kullanımı", color: root.accent },
                    { icon: "", title: "Bellek", value: SysData.ramPercent + "%", detail: SysData.ramGb.toFixed(1) + " GB kullanılıyor", color: "#89b4fa" },
                    { icon: "", title: "Ekran kartı", value: root.gpuText, detail: "RX 9060 XT / GPU durumu", color: "#f5c2e7" },
                    { icon: "", title: "Sıcaklık", value: SysData.temp + "°C", detail: "sistem sensörü", color: "#fab387" },
                    { icon: "", title: "Disk", value: root.diskText, detail: "kök dosya sistemi", color: "#a6e3a1" },
                    { icon: "", title: "Çalışma süresi", value: root.uptimeText, detail: "son açılıştan beri", color: "#74c7ec" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: root.surface
                    border.color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.25)
                    border.width: 1
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8
                        Text { text: modelData.icon; color: modelData.color; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 28 }
                        Text { text: modelData.title; color: root.subtext; font.pixelSize: 14 }
                        Text { text: modelData.value; color: root.text; font.pixelSize: 21; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Text { text: modelData.detail; color: root.subtext; font.pixelSize: 12; Layout.fillWidth: true }
                    }
                }
            }
        }

        Text { text: "Esc ile kapat"; color: root.subtext; font.pixelSize: 13; Layout.alignment: Qt.AlignRight }
    }
}

// SYSTEMINFO_PANEL_END
