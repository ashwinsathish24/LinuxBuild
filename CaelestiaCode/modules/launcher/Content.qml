pragma ComponentBehavior: Bound

import "services"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    required property var panels
    required property real maxHeight

    readonly property int padding: Appearance.padding.large
    readonly property int rounding: Appearance.rounding.large

    // Flag to track how the launcher was opened
    property bool isKeybindMode: false

    implicitWidth: listWrapper.width + padding * 2
    
    // Safely shrink the window height when the search container is hidden
    implicitHeight: (isKeybindMode ? 0 : searchContainer.height + Appearance.spacing.small) + listWrapper.height + padding * 2

    Item {
        id: listWrapper

        implicitWidth: list.width
        implicitHeight: list.height + root.padding

        anchors.horizontalCenter: parent.horizontalCenter
        
        // Conditionally anchor directly to the bottom so the invisible box doesn't push it up
        anchors.bottom: root.isKeybindMode ? parent.bottom : searchContainer.top
        anchors.bottomMargin: root.padding

        // Handle keys here so they work even when the search bar is hidden
        Keys.onUpPressed: list.currentList?.decrementCurrentIndex()
        Keys.onDownPressed: list.currentList?.incrementCurrentIndex()
        Keys.onLeftPressed: list.currentList?.decrementCurrentIndex()
        Keys.onRightPressed: list.currentList?.incrementCurrentIndex()

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                const currentItem = list.currentList?.currentItem;
                if (currentItem && list.showWallpapers) {
                    if (Colours.scheme === "dynamic" && currentItem.modelData.path !== Wallpapers.actualCurrent)
                        Wallpapers.previewColourLock = true;
                    Wallpapers.setWallpaper(currentItem.modelData.path);
                    root.visibilities.launcher = false;
                }
            }
        }

        ContentList {
            id: list

            content: root
            visibilities: root.visibilities
            panels: root.panels
            
            // Reclaim the missing space so the thumbnails fit perfectly
            maxHeight: root.maxHeight - (root.isKeybindMode ? 0 : searchContainer.implicitHeight + root.padding) - root.padding * 2
            
            search: search
            padding: root.padding
            rounding: root.rounding
        }
    }

    StyledRect {
        id: searchContainer

        // Conditionally hide the container
        visible: !root.isKeybindMode 

        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        radius: Appearance.rounding.full

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.padding

        implicitHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)

        MaterialIcon {
            id: searchIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.padding

            text: "search"
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledTextField {
            id: search

            anchors.left: searchIcon.right
            anchors.right: clearIcon.left
            anchors.leftMargin: Appearance.spacing.small
            anchors.rightMargin: Appearance.spacing.small

            topPadding: Appearance.padding.larger
            bottomPadding: Appearance.padding.larger

            placeholderText: qsTr("Type \"%1\" for commands").arg(Config.launcher.actionPrefix)

            // Spawn instantly in the correct state
            text: Wallpapers.openUiRequested ? `${Config.launcher.actionPrefix}wallpaper ` : ""

            onAccepted: {
                const currentItem = list.currentList?.currentItem;
                if (currentItem) {
                    if (list.showWallpapers) {
                        if (Colours.scheme === "dynamic" && currentItem.modelData.path !== Wallpapers.actualCurrent)
                            Wallpapers.previewColourLock = true;
                        Wallpapers.setWallpaper(currentItem.modelData.path);
                        root.visibilities.launcher = false;
                    } else if (text.startsWith(Config.launcher.actionPrefix)) {
                        if (text.startsWith(`${Config.launcher.actionPrefix}calc `))
                            currentItem.onClicked();
                        else
                            currentItem.modelData.onClicked(list.currentList);
                    } else {
                        Apps.launch(currentItem.modelData);
                        root.visibilities.launcher = false;
                    }
                }
            }

            Keys.onUpPressed: list.currentList?.decrementCurrentIndex()
            Keys.onDownPressed: list.currentList?.incrementCurrentIndex()
            Keys.onEscapePressed: root.visibilities.launcher = false

            Keys.onPressed: event => {
                if (!Config.launcher.vimKeybinds) return;
                if (event.modifiers & Qt.ControlModifier) {
                    if (event.key === Qt.Key_J) {
                        list.currentList?.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_K) {
                        list.currentList?.decrementCurrentIndex();
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Tab) {
                    list.currentList?.incrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                    list.currentList?.decrementCurrentIndex();
                    event.accepted = true;
                }
            }

            Component.onCompleted: {
                if (Wallpapers.openUiRequested) {
                    root.isKeybindMode = true; 
                    search.text = `${Config.launcher.actionPrefix}wallpaper `;
                    search.cursorPosition = search.text.length;
                    Wallpapers.openUiRequested = false;
                    listWrapper.forceActiveFocus(); // Shift focus to the list area
                } else {
                    forceActiveFocus();
                }
            }

            Connections {
                target: Wallpapers
                function onOpenUiRequestedChanged(): void {
                    if (Wallpapers.openUiRequested && root.visibilities.launcher) {
                        root.isKeybindMode = true;
                        search.text = `${Config.launcher.actionPrefix}wallpaper `;
                        search.cursorPosition = search.text.length;
                        Wallpapers.openUiRequested = false;
                        listWrapper.forceActiveFocus();
                    }
                }
            }

            Connections {
                target: root.visibilities
                function onLauncherChanged(): void {
                    if (!root.visibilities.launcher) {
                        search.text = "";
                        root.isKeybindMode = false;
                    }
                }

                function onSessionChanged(): void {
                    if (!root.visibilities.session && !root.isKeybindMode)
                        search.forceActiveFocus();
                }
            }
        }

        MaterialIcon {
            id: clearIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: root.padding

            width: search.text ? implicitWidth : implicitWidth / 2
            opacity: {
                if (!search.text)
                    return 0;
                if (mouse.pressed)
                    return 0.7;
                if (mouse.containsMouse)
                    return 0.8;
                return 1;
            }

            text: "close"
            color: Colours.palette.m3onSurfaceVariant

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: search.text ? Qt.PointingHandCursor : undefined

                onClicked: search.text = ""
            }

            Behavior on width {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }
        }
    }
}
