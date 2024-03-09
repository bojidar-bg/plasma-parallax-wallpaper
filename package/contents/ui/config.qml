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

    property string cfg_Image
    property string cfg_ImageDefault
    property var cfg_SlidePaths: []
    property var cfg_SlidePathsDefault: []
    property alias cfg_Zoom: zoomSpinBox.value
    property int cfg_ZoomDefault
    property alias cfg_Crop: cropSpinBox.value
    property int cfg_CropDefault
    property alias cfg_SlideDuration: durationSpinBox.value
    property int cfg_SlideDurationDefault

    signal configurationChanged()
    /**
     * Emitted when the user finishes adding images using the file dialog.
     */
    signal wallpaperBrowseCompleted();

    onScreenChanged: function() {
        if (thumbnailsLoader.item) {
            thumbnailsLoader.item.screenSize = !!root.screen.geometry ? Qt.size(root.screen.geometry.width, root.screen.geometry.height):  Qt.size(root.screen.width, root.screen.height);
        }
    }

    function saveConfig() {
        imageWallpaper.wallpaperModel.commitAddition();
        imageWallpaper.wallpaperModel.commitDeletion();
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
            id: zoomSpinBox
            from: 100
            to: 400
            stepSize: 1
            textFromValue: function(value) { return value + "  %"; } // https://bugreports.qt.io/browse/QTBUG-51022
            valueFromText: function(text) { return Number(text.split(" ")[0]); }

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Parallax Zoom Factor:")
            KCM.SettingHighlighter {
                highlight: cfg_Zoom != cfg_ZoomDefault
            }
        }

        QtControls2.SpinBox {
            id: cropSpinBox
            from: 0
            to: 100
            stepSize: 1
            textFromValue: function(value) { return value + " %"; } // https://bugreports.qt.io/browse/QTBUG-51022
            valueFromText: function(text) { return Number(text.split(" ")[0]); }

            Kirigami.FormData.label: i18nd("com.github.bojidar-bg.parallax", "Parallax Crop Factor:")
            KCM.SettingHighlighter {
                highlight: cfg_Crop != cfg_CropDefault
            }
        }
    }

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

    Component.onDestruction: {
        if (wallpaperConfiguration)
            wallpaperConfiguration.PreviewImage = "null";
    }
}
