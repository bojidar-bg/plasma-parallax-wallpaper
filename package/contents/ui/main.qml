/*
    SPDX-FileCopyrightText: 2020 Bojidar Marinov <bojidar.marinov.bg@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.wallpapers.image as Wallpaper
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager



WallpaperItem {
    id: root

    //public API, the C++ part will look for those
    function setUrl(url) {
        wallpaper.configuration.Image = url
    }
    
    TaskManager.VirtualDesktopInfo {
        id: virtualdesktopinfo
    }
    
    Image {
        id: image
        property var zoom: wallpaper.configuration.Zoom / 100
        property var crop: wallpaper.configuration.Crop / 100
        property var desktopRows: virtualdesktopinfo.desktopLayoutRows
        property var desktopCols: Math.round(virtualdesktopinfo.numberOfDesktops / desktopRows)
        property var currentDesktop: virtualdesktopinfo.desktopIds.indexOf(virtualdesktopinfo.currentDesktop)
        property var aspect: implicitHeight / implicitWidth
        property var coverWidth: Math.max(parent.width, parent.height / aspect)
        
        width: coverWidth * zoom
        height: coverWidth * aspect * zoom
        
        property var ox: (currentDesktop % desktopCols) / (desktopCols - 1)
        property var oy: Math.floor(currentDesktop / desktopCols) / (desktopRows - 1)
        property var dx: parent.width - width
        property var dy: parent.height - height
        
        x: lerp(dx * ox, dy * ox + (dx - dy) / 2, dx < dy ? crop : 0)
        y: lerp(dy * oy, dx * oy + (dy - dx) / 2, dy < dx ? crop : 0)
        
        function lerp(x, y, t) {return (y - x) * t + x}

        Behavior on x {
            NumberAnimation {
                duration: wallpaper.configuration.SlideDuration
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on y {
            NumberAnimation {
                duration: wallpaper.configuration.SlideDuration
                easing.type: Easing.OutCubic
            }
        }

        source: mediaProxy.modelImage

        Wallpaper.MediaProxy {
            id: mediaProxy
            source: wallpaper.configuration.Image

            targetSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
            onColorSchemeChanged: mediaProxy.modelImageChanged() // HACK!  Work around the fact that https://invent.kde.org/plasma/plasma-workspace/-/blob/29d966e653dd7bdf80eed2c767b1edf9714a2916/wallpapers/image/plugin/utils/mediaproxy.cpp#L199 does not raise the modelImageChanged signal despite updating modelImage
        }
    }
}
