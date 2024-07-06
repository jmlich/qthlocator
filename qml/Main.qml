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
import com.github.jmlich.qthlocator 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'com.github.jmlich.qthlocator'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    ListModel {
        id: logModel

        onDataChanged: {
            console.log("logModel changed " + count)
        }

        function save() {
            var arr = []
            for (var i = 0; i < count; i++) {
                var item = get(i);
                arr.push(item);
            }
//            console.log(JSON.stringify(arr, 0, 2))
            QthLocatorConfig.logModel = JSON.stringify(arr)
        }

        function load() {
            var data = JSON.parse(QthLocatorConfig.logModel)

            logModel.clear()
            for (var i = 0; i < data.length; i++) {
                logModel.append(data[i]);
            }
        }
    }


    Component.onCompleted: {
        test_parse_variable_log_entry();
        logModel.load()
    }


    PageStack {
        id: pageStack
        Component.onCompleted: push(mainPage)
        Page {
            id: mainPage
            anchors.fill: parent

            header: PageHeader {
                id: header
                title: i18n.tr('QTH Locator')
                trailingActionBar.actions: [
                    Action {
                        iconName: "view-list-symbolic"
                        name: i18n.tr('Log')
                        onTriggered: {
                            pageStack.push(Qt.resolvedUrl('LogPage.qml'));
                        }
                    }
                ]
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
                    text: i18n.tr('Your position')
                    font.bold: true
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                }
                Label {
                    text: i18n.tr('Latitude: %1').arg(map.currentPositionShow ? map.currentPositionLat : '??')
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                }
                Label {
                    text: i18n.tr('Longitude: %1').arg(map.currentPositionShow ? map.currentPositionLon : '??')
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
                    text: i18n.tr('QTH: %1').arg(gpsLocatorValue)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                }

                Label {
                    text: i18n.tr('Contacted Station (callsign, grid square)')
                    font.bold: true
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                }
                TextField {
                    id: targetEntry
                    width: parent.width / 2
                    placeholderText: "Pepa Kuřim p Vartovna JN89XG"

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }

                    onTextChanged: {
                        var regex = /([a-zA-Z]{2}\d{2}[a-zA-Z]{2}(\d{2})?)/;
                        var match = regex.exec(targetEntry.text);
                        if (match) {
                            map.setTargetLocator(match[1]);
                        }
                    }
                }

                Label {
                    text: i18n.tr('Distance: %1 km').arg((map.currentPositionShow && map.targetRect.length > 0 && map.targetRect[0] != 0 && map.targetRect[1] != 0) ? Math.round(G.getDistanceTo(map.currentPositionLat, map.currentPositionLon, (map.targetRect[1] + map.targetRect[3]) / 2, (map.targetRect[0] + map.targetRect[2]) / 2) / 1000.0) : '??')
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                }



                Button {
                    text: i18n.tr('Add to log')
                    enabled: (targetEntry.text !== '') && (map.currentPositionShow)
                    onClicked: {
                        var parsed = parse_variable_log_entry(targetEntry.text)
                        var record = {
                            qsoDateTime: new Date(),
                            myGridSquare: gpsLocator.gpsLocatorValue,
                            myAltitude: isNaN(positionSource.position.coordinate.altitude) ? '' : positionSource.position.coordinate.altitude
                        }
                        record = Object.assign(record, parsed)
                        console.log("Open AddToLogPage: " + JSON.stringify(record, 0, 2));
                        pageStack.push(Qt.resolvedUrl('AddToLogPage.qml'), record);
                    }
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
                url: "https://%(s)d.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png"
                url_subdomains: ['a', 'b', 'c']
                maxZoomLevel: 19
                attribution: "data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, " + "<a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, " + "Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: true

        onPositionChanged: {

            var coord = positionSource.position.coordinate;
            console.log("Valid: " + valid + " Coordinate:", coord.longitude, coord.latitude);
            map.currentPositionShow = valid && !isNaN(coord.latitude);
            if (map.currentPositionShow) {
                map.currentPositionLat = coord.latitude;
                map.currentPositionLon = coord.longitude;
            }
        }
    }


    function parse_variable_log_entry(input) {
        var mod = input.replace(/\s([pPhHmM])\s/g, ' /$1 ');
        // Regular expression to match the modified message with optional parts
        var regex = /^([a-zA-Z0-9\s]+?)\s(\/[pPhHmM])?\s?([a-zA-Z\s]+)?([a-zA-Z]{2}\d{2}[a-zA-Z]{2})$/;
        var result = regex.exec(mod);

        if (result) {

            var callSign = (result[1] || '').replace(/^\b\w+\b/g, function(word) {
                    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
            }).trim();
            var location = (result[3] || '').replace(/\b\w+\b/g, function(word) { // mont blanc is tranformed to Mont Blanc
                    return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
            }).trim();

            var place = '';
            if (result[2] == '/p' || result[2] == '/P') {
                place = 'portable';
            } else if (result[2] == '/h' || result[2] == '/h') {
                place = 'home';
            } else if (result[2] == '/m' || result[2] == '/M') {
                place = 'mobile';
            }

            var dict = {
                stationCallSign: callSign,
                stationPlace: place, // portable | mobile | home
                stationLocation: location,
                stationGridSquare: (result[4] || '').toUpperCase(), // e.g. JN89GE
            }
        } else {
            var dict = {
                stationGridSquare: input,
            }
        }


        return dict;
    }

function test_parse_variable_log_entry() {

    var inputs = [
        "pepa klobouky m holy vrch jn99bb",
        "pepa kurim p rozhledna vartovna jn89xg",
        "pepa kurim p vartovna jn89xg",
        "pepa p vartovna jn89xg",
        "pepa kurim p jn89xg",
        "pepa kurim jn89xg",
        "pepa jn89xg",
        "jn89xg",
    ]

    for (var i = 0; i < inputs.length; i++) {
        console.log ("inputs[" + i + "] = '" + inputs[i] + "' " + JSON.stringify(parse_variable_log_entry(inputs[i]), 0, 2))
    }
}

}
