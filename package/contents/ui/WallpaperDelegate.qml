/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later

    (based on https://invent.kde.org/plasma/plasma-workspace/-/blob/master/wallpapers/image/imagepackage/contents/ui/WallpaperDelegate.qml, 2024-03-09)
*/

import QtQuick
import QtQuick.Controls as QtControls2
import Qt5Compat.GraphicalEffects

import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import org.kde.kcmutils as KCM

KCM.GridDelegate {
    id: wallpaperDelegate

    opacity: model.pendingDeletion ? 0.5 : 1
    scale: index, 1 // Workaround for https://bugreports.qt.io/browse/QTBUG-107458

    text: model.display
    subtitle: model.author

    hoverEnabled: true

    actions: [
        Kirigami.Action {
            icon.name: "document-open-folder"
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Open Containing Folder")
            onTriggered: imageModel.openContainingFolder(index)
        },
        Kirigami.Action {
            icon.name: "edit-undo"
            visible: model.pendingDeletion
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Restore wallpaper")
            onTriggered: model.pendingDeletion = false
        },
        Kirigami.Action {
            icon.name: "edit-delete"
            tooltip: i18nd("plasma_wallpaper_org.kde.image", "Remove Wallpaper")
            visible: model.removable && !model.pendingDeletion
            onTriggered: {
                model.pendingDeletion = true;

                if (wallpapersGrid.view.currentIndex === index) {
                    const newIndex = (index + 1) % (imageModel.count - 1);
                    wallpapersGrid.view.itemAtIndex(newIndex).clicked();
                }
                root.configurationChanged(); // BUG 438585
            }
        }
    ]

    thumbnail: Rectangle {
        id: backgroundRect
        anchors.fill: parent

        Kirigami.Icon {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.large
            height: width
            source: "view-preview"
            visible: !walliePreview.visible
        }

        QPixmapItem {
            id: walliePreview
            anchors.fill: parent
            visible: model.screenshot !== null
            smooth: true
            pixmap: model.screenshot
            fillMode: {
                return QPixmapItem.PreserveAspectCrop;
            }
        }
    }

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    onClicked: {
        if (isMask) {
            cfg_Masks[currentLayer] = model.packageName || model.path;
            cfg_Masks = cfg_Masks;
        } else {
            cfg_Images[currentLayer] = model.packageName || model.path;
            cfg_Images = cfg_Images;
        }
        console.log(cfg_Masks, cfg_Images)
        root.configurationChanged();
        GridView.view.currentIndex = index;
    }
}
