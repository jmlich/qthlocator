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
                subtitle.text: qshDateTime
                summary.text: comment
            }
            onClicked: pageStack.push(Qt.resolvedUrl('AddToLogPage.qml'), logModel.get(index))
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
