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
import "geom.js" as G


//import QtQuick.Controls 2.2

Page {
    id: logPage

    header: PageHeader {
        id: pageHeader
        title: i18n.tr('Log')
/*
        trailingActionBar.actions: [
            Action {
                iconName: "document-save"
                name: i18n.tr('Export')
                onTriggered: {
                    console.log("Export");
                }
            }
        ]
*/
    }

    ListView {
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        model: logModel
        delegate: ListItem {
            height: layout.height + (divider.visible ? divider.height : 0)
            ListItemLayout {
                id: layout
                title.text: 
                    myGridSquare + (( myGridSquare != "" && stationGridSquare != "") ? " → " : "" ) + stationGridSquare
                    + ((stationCallSign != "") ? " (" + stationCallSign + ")" : "")
                subtitle.text: qsoDateTime.toLocaleString(Qt.locale()) +
                    (( myGridSquare != "" && stationGridSquare != "")
                        ? " | "+ G.formatDistance(G.locatorDistance(myGridSquare, stationGridSquare), {distanceUnit: 'km'}) + " | "
                            + G.formatBearing(G.locatorBearingTo(myGridSquare, stationGridSquare))
                        : "" )
                summary.text: comment
            }
            onClicked: {
                var record = logModel.get(index)
                record = JSON.parse(JSON.stringify(record)) // without this ugly hack the rowIndex cannot be added and values are not visible in AddToLogPage
                record.rowIndex = index
//                console.log("AddToLogPage -> " + JSON.stringify(record, 0, 2))
                pageStack.push(Qt.resolvedUrl('AddToLogPage.qml'), record)
            }
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            console.log("delete " + index);
                            logModel.remove(index, 1);
                            logModel.save()
                        }
                    }
                ]
            }
        }
    }
}
