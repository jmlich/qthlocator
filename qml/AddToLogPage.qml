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
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import "geom.js" as G
import QtPositioning 5.12

Page {
    id: addToLogPage

    property alias gpsLocator: sourceLocator.text
    property alias targetLocator: destinationLocator.text

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
            text: i18n.tr('Your position')
        }
        TextField {
            id: sourceLocator
        }

        Label {
            text: i18n.tr('Your call sign')
        }

        TextField {
            id: callSign
            text: "Pepa Kurim"
        }

        Label {
            text: i18n.tr('Time')
        }

        TextField {
            id: dateTime
            property date connDate: new Date()
            text: connDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " " + connDate.toLocaleTimeString(Qt.locale, Locale.ShortFormat)
        }

        Label {
            text: i18n.tr('Type')
        }

        TextField {
            id: devType
            text: "portable"
        }

        Label {
            text: i18n.tr('Radio band')
        }

        TextField {
            id: devBand
            text: "PMR"
        }

        Label {
            text: i18n.tr('Locator')
        }

        TextField {
            id: destinationLocator
        }

        Label {
            text: i18n.tr('Note')
        }

        TextArea {
            id: note
        }

        Button {
            text: i18n.tr('Save')
            onClicked: {

                logModel.insert(0, {
                    sourceLocator: sourceLocator.text,
                    callSign: callSign.text,
                    dateTime: dateTime.connDate,
                    commType: devType.text,
                    radioBand: devBand.text,
                    locator: destinationLocator.text,
                    note: note.text,
                })

                logModel.save();

                pageStack.pop();
            }
        }
    }
}
