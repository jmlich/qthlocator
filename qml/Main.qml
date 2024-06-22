/*
 * Copyright (C) 2024  Jozef Mlich
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * qthlocator is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import "geom.js" as G


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'qthlocator.com.github.jmlich'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('QTH Locator')
        }

        Column {
            id: infoColumn
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
                bottomMargin: units.gu(1)
            }
            spacing: units.gu(0.5)

            Label {
                text: i18n.tr('Current position')
                font.bold: true
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label {
                text: i18n.tr('Latitude: %1').arg(0)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label {
                text: i18n.tr('Longitude: %1').arg(0)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label {
                text: i18n.tr('QTH: %1').arg('')
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }

            Label {
                text: i18n.tr('Find')
                font.bold: true
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Row {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                TextField {
                    id: targetLocator
                    width: parent.width / 2

                }
                Button {
                    width: parent.width / 2
                    text: i18n.tr('Search')
                    onClicked: {
                        map.setTargetLocator(targetLocator.text)
                    }
                }
            }

            Label {
                text: i18n.tr('Distance: %1 km').arg('??')
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }

        }

        PinchMap {
            id: map
            anchors {
                top: infoColumn.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            clip: true
            url: "https://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
            url_subdomains: ['a','b', 'c'];
            maxZoomLevel: 19
            attribution: "data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, " +
                    "<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, " +
                    "Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"

        }


    }
}
