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
import Lomiri.Components.Pickers 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.2
import "geom.js" as G
import com.github.jmlich.qthlocator 1.0


Page {
    id: addToLogPage

    property int rowIndex: -1
    property alias qsoDateTime: qsoDateTime.value;
    property alias band: band.text;
    property alias myCallSign: myCallSign.text;
    property alias myLocation: myLocation.text;
    property alias myPlace: myPlace.text;
    property alias myAltitude: myAltitude.text;
    property alias myGridSquare: myGridSquare.text;
    property alias stationCallSign: stationCallSign.text;
    property alias stationPlace: stationPlace.text;
    property alias stationGridSquare: stationGridSquare.text;
    property alias stationLocation: stationLocation.text;
    property alias comment: comment.text;

    header: PageHeader {
        id: pageHeader
        title: i18n.tr('Transmission detail')
    }

    Grid {
        columns: 2
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.margins: units.gu(1)

        Label {
            text: i18n.tr('Date and Time')
        }

        Component {
            id: dateTimeDialogComponent
            Dialog {
                id: dateTimeDialog
                title: i18n.tr("Select date and time")
                DatePicker {
                    id: datePicker
                    mode: "Years|Months|Days"
                    date: qsoDateTime.value
                    minimum: {
                        var d = new Date();
                        d.setFullYear(d.getFullYear() - 20);
                        return d;
                    }
                    maximum: {
                        var d = new Date();
                        d.setFullYear(d.getFullYear() + 20);
                        return d;
                    }
                }

                DatePicker {
                    id: timePicker
                    mode: "Hours|Minutes|Seconds"
                    date: qsoDateTime.value
                }

                Button {
                    text: i18n.tr("Set date and time")
                    onClicked: {
                        PopupUtils.close(dateTimeDialog)

                        const year = datePicker.date.getFullYear();
                        const month = datePicker.date.getMonth();
                        const day = datePicker.date.getDate();

                        const hours = timePicker.date.getHours();
                        const minutes = timePicker.date.getMinutes();
                        const seconds = timePicker.date.getSeconds();

                        qsoDateTime.value = new Date(year, month, day, hours, minutes, seconds);

                    }
                }
            }
        }

        Button {
            id: qsoDateTime
            property date value: new Date()
            text: value.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " " + value.toLocaleTimeString(Qt.locale, Locale.ShortFormat)
            onClicked: {
                onClicked: PopupUtils.open(dateTimeDialogComponent)
            }
        }

        Label {
            text: i18n.tr('Band')
        }

        TextField {
            id: band
            text: QthLocatorConfig.lastBand
            placeholderText: i18n.tr("e.g. PMR/UHF")
        }

        Label {
            text: i18n.tr('Your call sign')
        }

        TextField {
            id: myCallSign
            text: QthLocatorConfig.lastMyCallSign
        }

        Label {
            text: i18n.tr('Your type')
        }

        TextField {
            id: myLocation
            text: QthLocatorConfig.lastMyLocation
            placeholderText: i18n.tr("e.g. home/mobile/portable")
        }

        Label {
            text: i18n.tr('Your place')
        }

        TextField {
            id: myPlace
            text: QthLocatorConfig.lastMyPlace
            placeholderText: i18n.tr("e.g. Mount Everest")
        }

        Label {
            text: i18n.tr('Your altitude')
        }
        TextField {
            id: myAltitude
            placeholderText: i18n.tr("in meters")
        }


        Label {
            text: i18n.tr('Your locator')
        }
        TextField {
            id: myGridSquare
            inputMethodHints: Qt.ImhUppercaseOnly | Qt.ImhNoPredictiveText
            font.capitalization: Font.AllUppercase
            placeholderText: i18n.tr("e.g. JN89GE")
        }


        Label {
            text: i18n.tr('Station call sign')
        }

        TextField {
            id: stationCallSign
            text: ""
        }

        Label {
            text: i18n.tr('Station type')
        }


        TextField {
            id: stationLocation
            text: QthLocatorConfig.lastStationLocation
            placeholderText: i18n.tr("e.g. home/mobile/portable")
        }

        Label {
            text: i18n.tr('Station place')
        }

        TextField {
            id: stationPlace
            placeholderText: i18n.tr("e.g. Mont Blanc")
        }


        Label {
            text: i18n.tr('Station Locator')
        }

        TextField {
            id: stationGridSquare
            inputMethodHints: Qt.ImhUppercaseOnly | Qt.ImhNoPredictiveText
            font.capitalization: Font.AllUppercase
            placeholderText: i18n.tr("e.g. JN89GE")
        }


        Label {
            text: i18n.tr('Comment')
        }

        TextArea {
            id: comment
        }

        Button {
            text: i18n.tr('Save')
            onClicked: {

                QthLocatorConfig.lastBand = band.text
                QthLocatorConfig.lastMyCallSign = myCallSign.text
                QthLocatorConfig.lastMyLocation = myLocation.text
                QthLocatorConfig.lastMyPlace = myPlace.text
                QthLocatorConfig.lastStationLocation = stationLocation.text

                var modelRow = {
                    qsoDateTime: qsoDateTime.value.toISOString(),
                    band: band.text,
                    myCallSign: myCallSign.text,
                    myLocation: myLocation.text,
                    myPlace: myPlace.text,
                    myAltitude: myAltitude.text,
                    myGridSquare: myGridSquare.text.toUpperCase(),
                    stationCallSign: stationCallSign.text,
                    stationPlace: stationPlace.text,
                    stationGridSquare: stationGridSquare.text.toUpperCase(),
                    stationLocation: stationLocation.text,
                    comment: comment.text,
                }

                if (rowIndex < 0) {
                    logModel.insert(0, modelRow)
                } else {
                    logModel.set(rowIndex, modelRow)
                }



                logModel.save();

                pageStack.pop();
            }
        }
    }
}
