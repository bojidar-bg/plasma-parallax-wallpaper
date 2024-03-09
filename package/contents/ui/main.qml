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

    property var desktopRows: virtualdesktopinfo.desktopLayoutRows
    property var desktopCols: Math.round(virtualdesktopinfo.numberOfDesktops / desktopRows)
    property var currentDesktop: virtualdesktopinfo.desktopIds.indexOf(virtualdesktopinfo.currentDesktop)

    function lerp(x, y, t) {return (y - x) * t + x}

    MouseArea {
        id: mouseArea
        width: parent.width
        height: parent.height
        hoverEnabled: true
    }
    property var ox: (currentDesktop % desktopCols + mouseArea.mouseX / mouseArea.width) / (desktopCols)
    property var oy: (Math.floor(currentDesktop / desktopCols)  + mouseArea.mouseY / mouseArea.height) / (desktopRows)

    Repeater {
        model: wallpaper.configuration.Images.length
        delegate: Item {
            Image {
                id: img

                source: mediaProxy.modelImage
                width: parent.width
                height: parent.height

                Wallpaper.MediaProxy {
                    id: mediaProxy
                    source: wallpaper.configuration.Images[index]
                    targetSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
                }
                visible: index == 0
            }
            Image {
                id: maskimg

                source: mediaProxyMask.modelImage

                Wallpaper.MediaProxy {
                    id: mediaProxyMask
                    source: wallpaper.configuration.Masks[index]
                    targetSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
                }
                visible: false
            }

            property var zoom: wallpaper.configuration.Zooms[index] / 100
            property var crop: wallpaper.configuration.Crops[index] / 100
            property var aspect: img.implicitHeight / img.implicitWidth
            property var coverWidth: Math.max(root.width, root.height / aspect)

            width: coverWidth * zoom
            height: coverWidth * aspect * zoom

            property var dx: root.width - width
            property var dy: root.height - height

            x: lerp(dx * ox, dy * ox + (dx - dy) / 2, dx < dy ? crop : 0)
            y: lerp(dy * oy, dx * oy + (dy - dx) / 2, dy < dx ? crop : 0)

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

            ShaderEffect {
                width: parent.width
                height: parent.height

                property variant source: img
                property variant mask: maskimg
                fragmentShader: "mask.frag.qsb"
                visible: index != 0
            }
        }
    }
}
