/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2019 David Redondo <kde@david-redondo.de>

    SPDX-License-Identifier: GPL-2.0-or-later

    (based on https://invent.kde.org/plasma/plasma-workspace/-/blob/master/wallpapers/image/imagepackage/contents/ui/thumbnailsComponent.qml, 2024-03-09)
*/

import QtQuick
import QtQuick.Controls as QQC2

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.newstuff as NewStuff

Item {
    id: thumbnailsComponent
    anchors.fill: parent

    property alias view: wallpapersGrid.view
    property var screenSize: Qt.size(Screen.width, Screen.height)

    readonly property QtObject imageModel: imageWallpaper.wallpaperModel

    Connections {
        target: imageWallpaper
        function onLoadingChanged(loading: bool) {
            if (loading) {
                return;
            }
            if (imageModel.indexOf(cfg_Image) < 0) {
                imageWallpaper.addUsersWallpaper(cfg_Image);
            }
            wallpapersGrid.resetCurrentIndex();
        }
    }

    Connections {
        target: root
        function onWallpaperBrowseCompleted() {
            // Scroll to top to view added images
            wallpapersGrid.view.positionViewAtIndex(0, GridView.Beginning);
            wallpapersGrid.resetCurrentIndex(); // BUG 455129
        }
    }

    KCM.GridView {
        id: wallpapersGrid
        anchors.fill: parent

        function resetCurrentIndex() {
            //that min is needed as the module will be populated in an async way
            //and only on demand so we can't ensure it already exists
            wallpapersGrid.view.currentIndex = Qt.binding(() => Math.min(imageModel.indexOf(cfg_Image), imageModel.count - 1));
        }

        // FIXME: this scrolls out of view due to the lack of a headerPositioning: property
        // in GridView, which is an omission; see https://bugreports.qt.io/browse/QTBUG-117035.
        // Once that's added, uncomment this line to fix it!
        // view.headerPositioning: GridView.OverlayHeader
        // Alternatively, make the page frameless, have the views touch the edges,
        // and just stick the header in a ColumnLayout with the view below it.
        view.header: Kirigami.InlineViewHeader {
            width: {
                const scrollBar = wallpapersGrid.QQC2.ScrollBar.vertical;
                return wallpapersGrid.width - scrollBar.width - scrollBar.leftPadding - scrollBar.rightPadding - Kirigami.Units.smallSpacing;
            }
            text: i18nd("plasma_wallpaper_org.kde.image", "Images")
            actions: [
                Kirigami.Action {
                    icon.name: "insert-image-symbolic"
                    text: i18ndc("plasma_wallpaper_org.kde.image", "@action:button the thing being added is an image file", "Add…")
                    onTriggered: root.openChooserDialog();
                },
                NewStuff.Action {
                    configFile: Kirigami.Settings.isMobile ? "wallpaper-mobile.knsrc" : "wallpaper.knsrc"
                    text: i18ndc("plasma_wallpaper_org.kde.image", "@action:button the new things being gotten are wallpapers", "Get New…")
                    viewMode: NewStuff.Page.ViewMode.Preview
                }
            ]
        }
        //kill the space for label under thumbnails
        view.model: thumbnailsComponent.imageModel

        //set the size of the cell, depending on Screen resolution to respect the aspect ratio
        view.implicitCellWidth: screenSize.width / 10 + Kirigami.Units.smallSpacing * 2
        view.implicitCellHeight: screenSize.height / 10 + Kirigami.Units.smallSpacing * 2 + Kirigami.Units.gridUnit * 3

        view.reuseItems: true

        view.delegate: WallpaperDelegate {
            color: cfg_Color
        }
    }

    KCM.SettingHighlighter {
        target: wallpapersGrid
        highlight: cfg_Image != cfg_ImageDefault
    }
}