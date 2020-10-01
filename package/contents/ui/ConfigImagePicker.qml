/*
 *  Copyright 2020 Bojidar Marinov
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Dialogs 1.1 as QtDialogs
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0 // for Screen
//We need units from it
import org.kde.plasma.core 2.0 as Plasmacore
import org.kde.plasma.wallpapers.image 2.0 as Wallpaper
import org.kde.kquickcontrolsaddons 2.0


ColumnLayout {
    id: imagePicker
    
    property string slidePaths: cfg_SlidePaths
    anchors.fill: parent

    function saveConfig() {
        imageWallpaper.commitDeletion()
    }

    Wallpaper.Image {
        id: imageWallpaper
        targetSize: {
            return Qt.size(Screen.width, Screen.height)
        }
        onSlidePathsChanged: imagePicker.slidePaths = slidePaths
    }

    onSlidePathsChanged: {
        imageWallpaper.slidePaths = slidePaths
    }
    
    QtControls.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        frameVisible: true
        highlightOnFocus: true

        Component.onCompleted: {
            //replace the current binding on the scrollbar that makes it visible when content doesn't fit

            //otherwise we adjust gridSize when we hide the vertical scrollbar and
            //due to layouting that can make everything adjust which changes the contentWidth/height which
            //changes our scrollbars and we continue being stuck in a loop

            //looks better to not have everything resize anyway.
            //BUG: 336301
            __verticalScrollBar.visible = true
        }

        GridView {
            id: wallpapersGrid
            model: imageWallpaper.wallpaperModel
            currentIndex: -1
            focus: true

            cellWidth: Math.floor(wallpapersGrid.width / Math.max(Math.floor(wallpapersGrid.width / (units.gridUnit*12)), 1))
            cellHeight: Math.round(cellWidth / (imageWallpaper.targetSize.width / imageWallpaper.targetSize.height))

            anchors.margins: 4
            boundsBehavior: Flickable.StopAtBounds

            delegate: ConfigWallpaperDelegate {
                color: cfg_Color
            }

            onContentHeightChanged: {
                wallpapersGrid.currentIndex = imageWallpaper.wallpaperModel.indexOf(cfg_Image);
                wallpapersGrid.positionViewAtIndex(wallpapersGrid.currentIndex, GridView.Visible)
            }

            Keys.onPressed: {
                if (count < 1) {
                    return;
                }

                if (event.key == Qt.Key_Home) {
                    currentIndex = 0;
                } else if (event.key == Qt.Key_End) {
                    currentIndex = count - 1;
                }
            }

            Keys.onLeftPressed: moveCurrentIndexLeft()
            Keys.onRightPressed: moveCurrentIndexRight()
            Keys.onUpPressed: moveCurrentIndexUp()
            Keys.onDownPressed: moveCurrentIndexDown()

            Connections {
                target: imageWallpaper
                onCustomWallpaperPicked: {
                    wallpapersGrid.currentIndex = 0
                }
            }

        }
    }

    RowLayout {
        Layout.fillWidth: true
        QtControls.Button {
            iconName: "document-open-folder"
            text: i18nd("plasma_applet_org.kde.image","Open...")
            onClicked: imageWallpaper.showFileDialog();
        }
        QtControls.Button {
            iconName: "get-hot-new-stuff"
            text: i18nd("plasma_applet_org.kde.image","Get New Wallpapers...")
            onClicked: imageWallpaper.getNewWallpaper();
        }
    }
}
