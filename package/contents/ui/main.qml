/*
    SPDX-FileCopyrightText: 2020 Bojidar Marinov <bojidar.marinov.bg@gmail.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1

import org.kde.plasma.core 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kwindowsystem 1.0 as KWindowSystem


Item {
    id: root

    //public API, the C++ part will look for those
    function setUrl(url) {
        wallpaper.configuration.Image = url
    }

    Rectangle {
        id: backgroundColor
        anchors.fill: parent
        visible: image.status === Image.Ready
        color: wallpaper.configuration.Color
        Behavior on color {
            ColorAnimation { duration: units.longDuration }
        }
    }
    
    KWindowSystem.KWindowSystem {
        id: kwindowsystem
    }
    
    Image {
        id: image
        property var zoom: wallpaper.configuration.Zoom / 100
        property var crop: wallpaper.configuration.Crop / 100
        property var desktopRows: wallpaper.configuration.DesktopRows
        property var desktopCols: Math.round(kwindowsystem.numberOfDesktops / wallpaper.configuration.DesktopRows)
        property var aspect: implicitHeight / implicitWidth
        property var coverWidth: Math.max(parent.width, parent.height / aspect)
        
        width: coverWidth * zoom
        height: coverWidth * aspect * zoom
        
        property var ox: ((kwindowsystem.currentDesktop - 1) % desktopCols) / (desktopCols - 1)
        property var oy: Math.floor((kwindowsystem.currentDesktop - 1) / desktopCols) / (desktopRows - 1)
        property var dx: parent.width - width
        property var dy: parent.height - height
        
        x: lerp(dx * ox, dy * ox + (dx - dy) / 2, dx < dy ? crop : 0)
        y: lerp(dy * oy, dx * oy + (dy - dx) / 2, dy < dx ? crop : 0)
        
        function lerp(x, y, t) {return (y - x) * t + x}
        
        source: wallpaper.configuration.Image
                
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
    }
}
