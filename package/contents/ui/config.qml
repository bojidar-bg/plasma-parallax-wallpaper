/*
    SPDX-FileCopyrightText: 2020 Bojidar Marinov <bojidar.marinov.bg@gmail.com>
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2019 David Redondo <kde@david-redondo.de>

    SPDX-License-Identifier: GPL-2.0-or-later

    (based on https://invent.kde.org/plasma/plasma-workspace/-/blob/master/wallpapers/image/imagepackage/contents/ui/config.qml, 2024-03-09)
*/


import QtQuick
import QtQuick.Controls as QtControls2
import QtQuick.Layouts
import org.kde.plasma.wallpapers.image as PlasmaWallpaper
import org.kde.kquickcontrols as KQuickControls
import org.kde.kquickcontrolsaddons
import org.kde.newstuff as NewStuff
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

/**
 * For proper alignment, an ancestor **MUST** have id "appearanceRoot" and property "parentLayout"
 */
ColumnLayout {
    id: root

    property var configDialog
    property var wallpaperConfiguration: wallpaper.configuration
    property var parentLayout
    property var screen: Screen
    property var screenSize: !!screen.geometry ? Qt.size(screen.geometry.width, screen.geometry.height):  Qt.size(screen.width, screen.height)

    property var cfg_SlidePaths: []
    property alias cfg_SlideDuration: durationSpinBox.value
    property int cfg_SlideDurationDefault
    property var cfg_Images: []
    property string cfg_ImagesDefault
    property var cfg_Masks: []
    property string cfg_MasksDefault
    property var cfg_Zooms: []
    property int cfg_ZoomsDefault
    property var cfg_Crops: []
    property int cfg_CropsDefault

    property alias currentLayer: layerSpinBox.value

    onCurrentLayerChanged: {
        updateLayer();
    }
    Component.onCompleted: {
        updateLayer();
        console.log(wallpaperConfig);
    }

    function updateLayer() {
        cfg_Zooms[currentLayer] = cfg_Zooms[currentLayer] || cfg_ZoomsDefault;
        if (cfg_Crops[currentLayer] === undefined) cfg_Crops[currentLayer] = cfg_CropsDefault;
        if (cfg_Images[currentLayer] === undefined) cfg_Images[currentLayer] = cfg_ImagesDefault;
        if (cfg_Masks[currentLayer] === undefined) cfg_Masks[currentLayer] = cfg_MasksDefault;
        zoomSpinBox.value = cfg_Zooms[currentLayer];
        cropSpinBox.value = cfg_Crops[currentLayer];
    }

    signal configurationChanged()
    /**
     * Emitted when the user finishes adding images using the file dialog.
     */
    signal wallpaperBrowseCompleted();

    onScreenChanged: function() {
        screenSize = !!root.screen.geometry ? Qt.size(root.screen.geometry.width, root.screen.geometry.height):  Qt.size(root.screen.width, root.screen.height);
        if (thumbnailsLoader.item) {
            thumbnailsLoader.item.screenSize = screenSize
        }
        if (maskThumbnailsLoader.item) {
            maskThumbnailsLoader.item.screenSize = screenSize;
        }

    }

    function saveConfig() {
        imageWallpaper.wallpaperModel.commitAddition();
        imageWallpaper.wallpaperModel.commitDeletion();
        console.log("xx", JSON.stringify(configDialog.wallpaperConfiguration));
    }

    function openChooserDialog() {
        const dialogComponent = Qt.createComponent("AddFileDialog.qml");
        dialogComponent.createObject(root);
        dialogComponent.destroy();
    }

    PlasmaWallpaper.ImageBackend {
        id: imageWallpaper
        renderingMode: PlasmaWallpaper.ImageBackend.SingleImage
        targetSize: {
            // Lock screen configuration case
            return Qt.size(root.screenSize.width * root.screen.devicePixelRatio, root.screenSize.height * root.screen.devicePixelRatio)
        }
        onSlidePathsChanged: cfg_SlidePaths = slidePaths
        onSlideshowModeChanged: cfg_SlideshowMode = slideshowMode
        onSlideshowFoldersFirstChanged: cfg_SlideshowFoldersFirst = slideshowFoldersFirst

        onSettingsChanged: root.configurationChanged()
    }

    onCfg_SlidePathsChanged: {
        if (cfg_SlidePaths)
            imageWallpaper.slidePaths = cfg_SlidePaths
    }

    Kirigami.FormLayout {
        id: formLayout

        Component.onCompleted: function() {
            if (typeof appearanceRoot !== "undefined") {
                twinFormLayouts.push(appearanceRoot.parentLayout);
            }
        }

        QtControls2.SpinBox {
            id: durationSpinBox
            from: 0
            to: 2000
            stepSize: 10
            textFromValue: function(value) { return value + " ms"; } // https://bugreports.qt.io/browse/QTBUG-51022
            valueFromText: function(text) { return Number(text.split(" ")[0]); }

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Slide Duration:")
            KCM.SettingHighlighter {
                highlight: cfg_SlideDuration != cfg_SlideDurationDefault
            }
        }

        QtControls2.SpinBox {
            id: layerSpinBox
            from: 0
            to: cfg_Images.length + 1
            stepSize: 1
            value: currentLayer

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Edit layer:")
        }

        QtControls2.SpinBox {
            id: zoomSpinBox
            from: 100
            to: 400
            stepSize: 1
            textFromValue: function(value) { return value + "  %"; } // https://bugreports.qt.io/browse/QTBUG-51022
            valueFromText: function(text) { return Number(text.split(" ")[0]); }
            onValueChanged: {
                cfg_Zooms[currentLayer] = value;
                root.configurationChanged();
            }

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Parallax Zoom Factor:")
            KCM.SettingHighlighter {
                highlight: cfg_Zooms[currentLayer] != cfg_ZoomsDefault;
            }
        }

        QtControls2.SpinBox {
            id: cropSpinBox
            from: 0
            to: 100
            stepSize: 1
            textFromValue: function(value) { return value + " %"; } // https://bugreports.qt.io/browse/QTBUG-51022
            valueFromText: function(text) { return Number(text.split(" ")[0]); }
            onValueChanged: {
                cfg_Crops[currentLayer] = value;
                root.configurationChanged();
            }

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Parallax Crop Factor:")
            KCM.SettingHighlighter {
                highlight: cfg_Crops[currentLayer] != cfg_CropsDefault;
            }
        }
    }

    RowLayout {
        DropArea {
            Layout.fillWidth: true
            Layout.fillHeight: true

            onEntered: drag => {
                if (drag.hasUrls) {
                    drag.accept();
                }
            }
            onDropped: drop => {
                drop.urls.forEach(function (url) {
                    imageWallpaper.addUsersWallpaper(url);
                });
                // Scroll to top to view added images
                thumbnailsLoader.item.view.positionViewAtIndex(0, GridView.Beginning);
            }

            Loader {
                id: thumbnailsLoader
                anchors.fill: parent

                function loadWallpaper() {
                    let source = "ThumbnailsComponent.qml";

                    let props = {screenSize: screenSize};

                    thumbnailsLoader.setSource(source, props);
                }
            }

            Connections {
                target: configDialog
                function onCurrentWallpaperChanged() {
                    thumbnailsLoader.loadWallpaper();
                }
            }

            Component.onCompleted: () => {
                thumbnailsLoader.loadWallpaper();
            }
        }
        DropArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: currentLayer > 0

            onEntered: drag => {
                if (drag.hasUrls) {
                    drag.accept();
                }
            }
            onDropped: drop => {
                drop.urls.forEach(function (url) {
                    imageWallpaper.addUsersWallpaper(url);
                });
                // Scroll to top to view added images
                maskThumbnailsLoader.item.view.positionViewAtIndex(0, GridView.Beginning);
            }

            Loader {
                id: maskThumbnailsLoader
                anchors.fill: parent

                function loadWallpaper() {
                    let source = "ThumbnailsComponent.qml";

                    let props = {screenSize: screenSize, isMask: true};

                    maskThumbnailsLoader.setSource(source, props);
                }
            }

            Connections {
                target: configDialog
                function onCurrentWallpaperChanged() {
                    maskThumbnailsLoader.loadWallpaper();
                }
            }

            Component.onCompleted: () => {
                maskThumbnailsLoader.loadWallpaper();
            }
        }
    }

    Component.onDestruction: {
        if (wallpaperConfiguration)
            wallpaperConfiguration.PreviewImage = "null";
    }
}
