import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.utils
import Caelestia
import qs.components
import qs.components.controls
import qs.components.containers

PanelWindow {
    id: keybindWindow

    WlrLayershell.namespace: "caelestia-keybindpopup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
    width: 800
    height: 600
    
    color: "transparent"
    visible: false

    property var shortcutsArray: []

    HyprlandFocusGrab {
        active: keybindWindow.visible
        windows: [keybindWindow]
        onCleared: keybindWindow.visible = false
    }

    IpcHandler {
        target: "keybindpopup"
        function toggle(): void {
            if (!keybindWindow.visible) {
                Quickshell.execDetached([
                    "bash", 
                    "-c", 
                    "FILE=\"$HOME/.config/hypr/shortcut.json\"; touch \"$FILE\"; JSON=$(cat \"$FILE\"); if [ -z \"$JSON\" ]; then JSON=\"{}\"; fi; hyprctl -j binds | jq --argjson ex \"$JSON\" 'reduce .[] as $b ($ex; ((if ($b.modmask / 64 | floor) % 2 == 1 then \"SUPER+\" else \"\" end) + (if ($b.modmask / 4 | floor) % 2 == 1 then \"CTRL+\" else \"\" end) + (if ($b.modmask / 8 | floor) % 2 == 1 then \"ALT+\" else \"\" end) + (if ($b.modmask / 1 | floor) % 2 == 1 then \"SHIFT+\" else \"\" end) + $b.key) as $k | if .[$k] == null then .[$k] = \"\" else . end)' > \"$FILE.tmp\" && mv \"$FILE.tmp\" \"$FILE\""
                ]);
            }
            keybindWindow.visible = !keybindWindow.visible;
        }
    }

    FileView {
        path: `${Paths.home}/.config/hypr/shortcut.json`
        watchChanges: true
        onFileChanged: reload() 
        onLoaded: {
            try {
                let data = JSON.parse(text());
                let arr = [];
                for (const [key, val] of Object.entries(data)) {
                    arr.push({ bindStr: key, descStr: val });
                }
                keybindWindow.shortcutsArray = arr;
            } catch(e) {
                console.error("Failed to parse shortcuts JSON:", e);
            }
        }
    }

    StyledClippingRect {
        anchors.fill: parent
        color: Colours.tPalette.m3surfaceContainer
        
        radius: Config.border.rounding
        // Border properties completely removed

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.large

            // Window Title Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal
                
                MaterialIcon {
                    text: "keyboard"
                    color: Colours.palette.m3primary
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("System Keybinds")
                    font.pointSize: Appearance.font.size.larger
                    font.weight: 500
                    color: Colours.palette.m3primary
                }
            }

            // Pinned Column Headers (Stays fixed at the top)
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.padding.normal
                Layout.rightMargin: Appearance.padding.normal
                spacing: Appearance.spacing.large

                StyledText {
                    Layout.preferredWidth: 250
                    text: qsTr("Keybind")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Description")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }
            }

            StyledFlickable {
                id: scroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                contentWidth: width
                contentHeight: listLayout.implicitHeight
                clip: true

                ColumnLayout {
                    id: listLayout
                    width: scroll.width 
                    // Increased spacing between rows
                    spacing: Appearance.spacing.normal

                    Repeater {
                        model: keybindWindow.shortcutsArray
                        
                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            // Adjusted to account for the larger margins
                            Layout.preferredHeight: row.implicitHeight + (Appearance.padding.normal * 2)

                            RowLayout {
                                id: row
                                anchors.fill: parent
                                anchors.leftMargin: Appearance.padding.normal
                                anchors.rightMargin: Appearance.padding.normal
                                // Increased top and bottom padding for the text
                                anchors.topMargin: Appearance.padding.normal
                                anchors.bottomMargin: Appearance.padding.normal
                                spacing: Appearance.spacing.large

                                StyledText {
                                    Layout.preferredWidth: 250
                                    Layout.alignment: Qt.AlignTop
                                    text: modelData.bindStr
                                    color: Colours.palette.m3onSurface
                                    wrapMode: Text.Wrap
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    text: modelData.descStr
                                    color: Colours.palette.m3outline
                                    wrapMode: Text.Wrap
                                    visible: text !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
