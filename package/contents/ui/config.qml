/*
 *  Copyright 2020 Bojidar Marinov
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *  Copyright 2014 Kai Uwe Broulik <kde@privat.broulik.de>
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
    id: root
    property alias cfg_Color: colorDialog.color
    property string cfg_Image
    property var cfg_SlidePaths: ""
    property alias cfg_Zoom: zoomSpinBox.value
    property alias cfg_Crop: cropSpinBox.value
    property alias cfg_DesktopRows: rowsSpinBox.value
    property alias cfg_SlideDuration: durationSpinBox.value

    function saveConfig() {
        mainLoader.item && mainLoader.item.saveConfig();
    }

    QtDialogs.ColorDialog {
        id: colorDialog
        modality: Qt.WindowModal
        showAlphaChannel: false
        title: i18nd("plasma_applet_org.kde.image", "Select Background Color")
    }
    
    SystemPalette {
        id: syspal
    }

    RowLayout {
        Item {
            Layout.fillWidth: true
        }
        
        Row {
            spacing: units.smallSpacing
            QtControls.Label {
                anchors.verticalCenter: colorButton.verticalCenter
                text: i18nd("plasma_applet_org.kde.image", "Background Color:")
            }
            QtControls.Button {
                id: colorButton
                width: units.gridUnit * 3
                text: " " // needed so it gets a proper height...
                onClicked: colorDialog.open()

                Rectangle {
                    id: colorRect
                    anchors.centerIn: parent
                    width: parent.width - 2 * units.smallSpacing
                    height: theme.mSize(theme.defaultFont).height
                    color: colorDialog.color
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
        
        Row {
            spacing: units.smallSpacing
            QtControls.Label {
                anchors.verticalCenter: rowsSpinBox.verticalCenter
                text: i18nd("com.github.bojidar-bg.parallax", "Desktop Rows:")
            }
            QtControls.SpinBox {
                id: rowsSpinBox
                minimumValue: 0
                maximumValue: 40
                stepSize: 1
                suffix: " " + i18n("Rows")
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
    }
    
    RowLayout {
        Item {
            Layout.fillWidth: true
        }
        
        Row {
            spacing: units.smallSpacing
            QtControls.Label {
                anchors.verticalCenter: zoomSpinBox.verticalCenter
                text: i18nd("com.github.bojidar-bg.parallax", "Parallax Zoom Factor:")
            }
            QtControls.SpinBox {
                id: zoomSpinBox
                minimumValue: 100
                maximumValue: 400
                stepSize: 1
                suffix: i18n("%")
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
        
        Row {
            spacing: units.smallSpacing
            QtControls.Label {
                anchors.verticalCenter: cropSpinBox.verticalCenter
                text: i18nd("com.github.bojidar-bg.parallax", "Parallax Crop Factor:")
            }
            QtControls.SpinBox {
                id: cropSpinBox
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                suffix: i18n("%")
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
        
        Row {
            spacing: units.smallSpacing
            QtControls.Label {
                anchors.verticalCenter: durationSpinBox.verticalCenter
                text: i18nd("com.github.bojidar-bg.parallax", "Slide Duration:")
            }
            QtControls.SpinBox {
                id: durationSpinBox
                minimumValue: 0
                maximumValue: 2000
                stepSize: 10
                suffix: " " + i18n("ms")
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
    }

    Loader {
        id: mainLoader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Component.onCompleted: setSource('ConfigImagePicker.qml')
    }
}
