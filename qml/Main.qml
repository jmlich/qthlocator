/*
 * SPDX-License-Identifier: GPL-3.0-only
 *
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
import QtPositioning 5.12

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'com.github.jmlich.qthlocator'
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
                text: i18n.tr('Latitude: %1').arg( map.currentPositionShow ? map.currentPositionLat : '??')
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label {
                text: i18n.tr('Longitude: %1').arg( map.currentPositionShow ? map.currentPositionLon : '??')
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
            }
            Label {
                id: gpsLocator
                property string gpsLocatorValue: map.currentPositionShow ? G.calcLocator(map.currentPositionLon, map.currentPositionLat) : ''
                text: i18n.tr('QTH: %1').arg( gpsLocatorValue )
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
                    inputMethodHints: Qt.ImhUppercaseOnly | Qt.ImhNoPredictiveText
                    font.capitalization: Font.AllUppercase
                    onAccepted: {
                        map.setTargetLocator(targetLocator.text)
                    }
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
                text: i18n.tr('Distance: %1 km').arg( ( map.currentPositionShow && map.targetRect.length > 0 && map.targetRect[0] != 0 && map.targetRect[1] != 0  )
                    ? Math.round( G.getDistanceTo(map.currentPositionLat, map.currentPositionLon, (map.targetRect[1]+map.targetRect[3])/2, (map.targetRect[0]+map.targetRect[2])/2 ) / 1000.0)
                    :  '??')
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
            url_subdomains: ['a', 'b', 'c'];
            maxZoomLevel: 19
            attribution: "data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, " +
                    "<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, " +
                    "Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"

        }


    }


    PositionSource {
        id: src
        updateInterval: 1000
        active: true

        onPositionChanged: {

//                map.currentPositionShow = true
//                map.currentPositionLat = 49.1
//                map.currentPositionLon = 16.1
//                return

            var coord = src.position.coordinate;
            console.log("Valid: " + valid + " Coordinate:", coord.longitude, coord.latitude);

            map.currentPositionShow = valid && !isNaN(coord.latitude);
            if (map.currentPositionShow) {
                map.currentPositionLat = coord.latitude
                map.currentPositionLon = coord.longitude
            }
        }
    }

}
