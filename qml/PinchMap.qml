// SPDX-License-Identifier: GPL-3.0-only

import QtQuick 2.9
//import "functions.js" as F
import "geom.js" as G

Rectangle {
    id: pinchmap
    property bool mapTileVisible: true
    property bool mapAirspaceVisible: false

    property real zoomLevel: 7
    property int zoomLevelInt: Math.floor(zoomLevel)
    property real zoomLevelReminder: zoomLevel - zoomLevelInt
    property int oldZoomLevel: 99
    property int maxZoomLevel: 19
    property int minZoomLevel: 2
    property int minZoomLevelShowGeocaches: 9
    property real tileScaleFactor: 2
    property int tileSize: (128 + (128 * zoomLevelReminder)) * tileScaleFactor
    property int cornerTileX: 32
    property int cornerTileY: 32
    property int numTilesX: Math.ceil(width / tileSize) + 2
    property int numTilesY: Math.ceil(height / tileSize) + 2
    property int maxTileNo: Math.pow(2, zoomLevelInt) - 1
    property variant targetRect: []

    property alias currentPositionShow: positionIndicator.visible
    property int currentPositionIndex: 0
    property double currentPositionLat: 0
    property double currentPositionLon: 0
    property double currentPositionAzimuth: 0
    property double currentPositionAltitude: 0
    property string currentPositionTime

    property bool rotationEnabled: false

    property bool pageActive: true

    property double latitude: 49.803575
    property double longitude: 15.475555
    property variant scaleBarLength: getScaleBarLength(latitude)
    property variant gpsModel
    property variant trackModel
    property double pointsSelectedLat
    property double pointsSelectedLon

    property alias angle: rot.angle

    property bool autocenter: true

    property string url
    // : "~/Maps/OSM/%(zoom)d/%(x)d/%(y)d.png"
    // url: "https://a.tile.openstreetmap.org/%(zoom)d/%(x)d/%(y)d.png";
    property variant url_subdomains: []
    property string airspaceUrl

    property string attribution: ""
    property string airspaceAttribution: ""

    //    property alias wfImageSource: worldFileImage.source
    //    property alias wfParam: worldFileImage.param
    //    property alias wfZone: worldFileImage.zone
    //    property alias wfNorthHemi: worldFileImage.northHemi
    property bool wfVisible: false

    property variant wfcoords
    property variant polygonCache
    property variant worldfiles

    //    property alias model: geocacheDisplay.model
    //    property alias waypointModel: waypointDisplay.model

    //property int status: PageStatus.active
    //property bool pageActive: (status == PageStatus.active);

    property bool needsUpdate: false

    property int filterCupData: 0
    property int filterCupCategory: 0

    property bool showTrackAnyway: true

    signal pannedManually
    signal trackRendered
    signal trackInBounds

    transform: Rotation {
        id: rot
        angle: 0
        origin.x: pinchmap.width / 2
        origin.y: pinchmap.height / 2
    }

    onMaxZoomLevelChanged: {
        if (pinchmap.maxZoomLevel < pinchmap.zoomLevel) {
            setZoomLevel(maxZoomLevel);
        }
    }

    onPageActiveChanged: {
        if (pageActive && needsUpdate) {
            needsUpdate = false;
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
            canvas.requestPaint();
        }
    }

    onWidthChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
            canvas.requestPaint();
        }
    }

    onHeightChanged: {
        if (!pageActive) {
            needsUpdate = true;
        } else {
            pinchmap.setCenterLatLon(pinchmap.latitude, pinchmap.longitude);
            canvas.requestPaint();
        }
    }

    onZoomLevelIntChanged: {
        cleanCache(true);
    }

    function setZoomLevel(z) {
        setZoomLevelPoint(z, pinchmap.width / 2, pinchmap.height / 2);
    }

    function zoomIn() {
        setZoomLevel(pinchmap.zoomLevel + 1);
    }

    function zoomOut() {
        setZoomLevel(pinchmap.zoomLevel - 1);
    }

    function setZoomLevelPoint(z, x, y) {
        if (z === zoomLevel) {
            return;
        }
        if (z < pinchmap.minZoomLevel || z > pinchmap.maxZoomLevel) {
            return;
        }
        var p = getCoordFromScreenpoint(x, y);
        zoomLevel = z;
        setCoord(p, x, y);
    }

    function pan(dx, dy) {
        map.offsetX -= dx;
        map.offsetY -= dy;
    }

    function panEnd() {
        var changed = false;
        var threshold = pinchmap.tileSize;
        while (map.offsetX < -threshold) {
            map.offsetX += threshold;
            cornerTileX += 1;
            changed = true;
        }
        while (map.offsetX > threshold) {
            map.offsetX -= threshold;
            cornerTileX -= 1;
            changed = true;
        }
        while (map.offsetY < -threshold) {
            map.offsetY += threshold;
            cornerTileY += 1;
            changed = true;
        }
        while (map.offsetY > threshold) {
            map.offsetY -= threshold;
            cornerTileY -= 1;
            changed = true;
        }
        updateCenter();
    }

    function zoomToBounds(lat1, lon1, lat2, lon2) {
        if ((pinchmap.width <= 0) || (pinchmap.height <= 0)) {
            return;
        }
        console.log("zoomToBoundsB: " + pinchmap.width + " " + pinchmap.height + " " + tileSize);
        setCenterLatLon(0.5 * (lat1 + lat2), 0.5 * (lon1 + lon2));
        var latFrac = Math.abs(deg2rad(lat1) - deg2rad(lat2)) / Math.PI;
        var lonFrac = Math.abs(lon1 - lon2) / 360;
        var latZoom = Math.floor(Math.log(pinchmap.height / tileSize / latFrac) / Math.log(2));
        var lonZoom = Math.floor(Math.log(pinchmap.width / tileSize / lonFrac) / Math.log(2));
        console.log("zoomToBoundsC:" + latFrac + " " + lonFrac + " " + latZoom + " " + lonZoom);
        setZoomLevel(Math.min(latZoom, lonZoom, maxZoomLevel));
        trackInBounds();
    }

    function updateCenter() {
        var l = getCenter();
        longitude = l[1];
        latitude = l[0];
        cleanCache();
        canvas.requestPaint();
    }

    function requestUpdate() {
        var start = getCoordFromScreenpoint(0, 0);
        var end = getCoordFromScreenpoint(pinchmap.width, pinchmap.height);
        canvas.requestPaint();
        console.debug("Update requested.");
    }

    function requestUpdateDetails() {
        var start = getCoordFromScreenpoint(0, 0);
        var end = getCoordFromScreenpoint(pinchmap.width, pinchmap.height);
        console.debug("Download requested.");
    }

    function getScaleBarLength(lat) {
        var destlength = width / 5;
        var mpp = getMetersPerPixel(lat);
        var guess = mpp * destlength;
        var base = 10 * -Math.floor(Math.log(guess) / Math.log(10) + 0.00001);
        var length_meters = Math.round(guess / base) * base;
        var length_pixels = length_meters / mpp;
        return [length_pixels, length_meters];
    }

    function getMetersPerPixel(lat) {
        return Math.cos(lat * Math.PI / 180.0) * 2.0 * Math.PI * G.earth_radius / (256 * (maxTileNo + 1));
    }

    function deg2rad(deg) {
        return deg * (Math.PI / 180.0);
    }

    function deg2num(lat, lon) {
        var rad = deg2rad(lat % 90);
        var n = maxTileNo + 1;
        var xtile = ((lon % 180.0) + 180.0) / 360.0 * n;
        var ytile = (1.0 - Math.log(Math.tan(rad) + (1.0 / Math.cos(rad))) / Math.PI) / 2.0 * n;
        return [xtile, ytile];
    }

    function setLatLon(lat, lon, x, y) {
        var oldCornerTileX = cornerTileX;
        var oldCornerTileY = cornerTileY;
        var tile = deg2num(lat, lon);
        var cornerTileFloatX = tile[0] + (map.rootX - x) / tileSize; // - numTilesX/2.0;
        var cornerTileFloatY = tile[1] + (map.rootY - y) / tileSize; // - numTilesY/2.0;
        cornerTileX = Math.floor(cornerTileFloatX);
        cornerTileY = Math.floor(cornerTileFloatY);
        map.offsetX = -(cornerTileFloatX - Math.floor(cornerTileFloatX)) * tileSize;
        map.offsetY = -(cornerTileFloatY - Math.floor(cornerTileFloatY)) * tileSize;
        updateCenter();
    }

    function setCoord(c, x, y) {
        setLatLon(c[0], c[1], x, y);
    }

    function setCenterLatLon(lat, lon) {
        setLatLon(lat, lon, pinchmap.width / 2, pinchmap.height / 2);
    }

    function setCenterCoord(c) {
        setCenterLatLon(c[0], c[1]);
    }

    function getCoordFromScreenpoint(x, y) {
        var realX = -map.rootX - map.offsetX + x;
        var realY = -map.rootY - map.offsetY + y;
        var realTileX = cornerTileX + realX / tileSize;
        var realTileY = cornerTileY + realY / tileSize;
        return num2deg(realTileX, realTileY);
    }

    function getScreenpointFromCoord(lat, lon) {
        var tile = deg2num(lat, lon);
        var realX = (tile[0] - cornerTileX) * tileSize;
        var realY = (tile[1] - cornerTileY) * tileSize;
        var x = realX + map.rootX + map.offsetX;
        var y = realY + map.rootY + map.offsetY;
        return [x, y];
    }

    function getMappointFromCoord(lat, lon) {
        //        console.count()
        var tile = deg2num(lat, lon);
        var realX = (tile[0] - cornerTileX) * tileSize;
        var realY = (tile[1] - cornerTileY) * tileSize;
        return [realX, realY];
    }

    function getCenter() {
        return getCoordFromScreenpoint(pinchmap.width / 2, pinchmap.height / 2);
    }

    function sinh(aValue) {
        return (Math.pow(Math.E, aValue) - Math.pow(Math.E, -aValue)) / 2;
    }

    function num2deg(xtile, ytile) {
        var n = Math.pow(2, zoomLevelInt);
        var lon_deg = xtile / n * 360.0 - 180;
        var lat_rad = Math.atan(sinh(Math.PI * (1 - 2 * ytile / n)));
        var lat_deg = lat_rad * 180.0 / Math.PI;
        return [lat_deg % 90.0, lon_deg % 180.0];
    }

    function tileUrl(tx, ty) {
        var imageUrl = tileUrlMultiple(tx, ty, url, true)
        for (var i = 0; i < imageCache.length; i++) {
            if (imageCache[i].cacheUrl === imageUrl) {
                // console.log("Cache hit:", imageUrl)
                imageCache[i].lastHit = new Date();
                return imageCache[i].source
            }
        }

        console.log("cache miss ("+imageCache.length+"): " + imageUrl )
        var newImage = Qt.createQmlObject(
            'import QtQuick 2.7;
                Image {
                    property var lastHit: new Date();
                    property string cacheUrl: "'+imageUrl+'";
                    visible: false;
                    source: "' + imageUrl + '"
                }', parent, "dynamicImage")
        imageCache.push(newImage)
        return newImage.source;
    }

    function cleanCache(force = false) {
        if (force) {
            for (var i = 0; i < imageCache.length; i++) {
                    imageCache[i].destroy();

            }
            imageCache = [];
            return;
        }
        if (imageCache.length < 50) {
            return;
        }
        var someTimeAgo = new Date().getTime() - 60000;

        for (var i = 0; i < imageCache.length; i++) {
            if (imageCache[i].lastHit.getTime() < someTimeAgo) {
                // console.log("Removing stale cache item: " + imageCache[i].cacheUrl);
                imageCache[i].destroy();
                imageCache.splice(i, 1);
            }
        }
        console.log("after cleanup imageCache.length: " + imageCache.length)
    }

    property var imageCache: []

    function tileUrlMultiple(tx, ty, baseUrl, first) {
        if ((baseUrl === undefined) || (baseUrl === "")) {
            return "qrc:///images/noimage-disabled.png";
        }
        if (tx < 0 || tx > maxTileNo) {
            if (!first) {
                return "";
            }
            return "qrc:///images/noimage.png";
        }
        if (ty < 0 || ty > maxTileNo) {
            if (!first) {
                return "";
            }
            return "qrc:///images/noimage.png";
        }
        var res = Qt.resolvedUrl(G.getMapTile(baseUrl, tx, ty, zoomLevelInt, url_subdomains));
        return res;
    }
    function imageStatusToString(status) {
        switch (status) {
        //% "Ready"
        case Image.Ready:
            return i18n.tr("Ready");
        //% "Not Set"
        case Image.Null:
            return i18n.tr("Not set");
        //% "Error"
        case Image.Error:
            return i18n.tr("Error");
        //% "Loading ..."
        case Image.Loading:
            return i18n.tr("Loading ...");
        //% "Unknown error"
        default:
            return i18n.tr("Unknown error");
        }
    }

    function setTargetLocator(locatorName) {
        var lonLat = G.locatorToLatLon(locatorName);
        targetRect = lonLat;
        if ((lonLat[0] == 0) && (lonLat[1] == 0)) {
            // don't zoom when empty
            return;
        }
        if (currentPositionShow) {
            var zoomBounds = [Math.min(lonLat[1], lonLat[3], currentPositionLat), Math.min(lonLat[0], lonLat[0], currentPositionLon), Math.max(lonLat[1], lonLat[3], currentPositionLat), Math.max(lonLat[0], lonLat[0], currentPositionLon)];
            zoomToBounds(zoomBounds[0], zoomBounds[1], zoomBounds[2], zoomBounds[3]);
        } else {
            zoomToBounds(lonLat[1], lonLat[0], lonLat[3], lonLat[2]);
        }
    }

    Grid {
        id: map
        columns: numTilesX
        width: numTilesX * tileSize
        height: numTilesY * tileSize
        property int rootX: -(width - parent.width) / 2
        property int rootY: -(height - parent.height) / 2
        property int offsetX: 0
        property int offsetY: 0
        x: rootX + offsetX
        y: rootY + offsetY

        Repeater {
            id: tiles

            model: (pinchmap.numTilesX * pinchmap.numTilesY)
            Rectangle {
                id: tile
                property alias source: img.source
                property int tileX: cornerTileX + (index % numTilesX)
                property int tileY: cornerTileY + Math.floor(index / numTilesX)
                Rectangle {
                    id: progressBar
                    property real p: 0
                    height: 16
                    width: parent.width - 32
                    anchors.centerIn: img
                    color: "#c0c0c0"
                    border.width: 1
                    border.color: "#000000"
                    Rectangle {
                        anchors.left: parent.left
                        anchors.margins: 2
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: (parent.width - 4) * progressBar.p
                        color: "#000000"
                    }
                    visible: mapTileVisible && (img.status !== Image.Ready)
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    y: parent.height / 2 - 32
                    text: imageStatusToString(img.status)
                    visible: mapTileVisible && (img.status !== Image.Ready)
                }
                Image {
                    anchors.fill: parent
                    visible: mapTileVisible && (img.status === Image.Null)
                    source: "qrc:///images/noimage.png"
                }

                Image {
                    id: img
                    anchors.fill: parent
                    onProgressChanged: {
                        progressBar.p = progress;
                    }
                    source: mapTileVisible ? tileUrl(tileX, tileY) : ""
                    visible: mapTileVisible
                }

                Image {
                    anchors.fill: parent
                    source: mapAirspaceVisible ? tileUrlMultiple(tileX, tileY, airspaceUrl, false) : ""
                    visible: mapAirspaceVisible
                }

                width: tileSize
                height: tileSize
                color: mapTileVisible ? "#c0c0c0" : "transparent"
            }
        }
    }

    Waypoint {
        id: positionIndicator
        waypointType: "target-indicator-cross"
        targetPoint: getMappointFromCoord(currentPositionLat, currentPositionLon)
        azimuth: currentPositionAzimuth
        mapx: map.x
        mapy: map.y
        visible: false
    }

    Canvas {
        id: canvas
        x: map.x
        y: map.y
        width: map.width
        height: map.height
        renderStrategy: Canvas.Cooperative

        onPaint: {
            console.time("canvas-onPaint");
            var ctx = canvas.getContext("2d");
            ctx.save();
            ctx.lineCap = "butt";
            ctx.lineJoin = "bevel";
            ctx.lineWidth = 2;
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            if (targetRect.length == 4 && targetRect[0] != 0 && targetRect[1] != 0 && targetRect[2] != 0 && targetRect[3] != 0) {
                var screenPoint1 = getMappointFromCoord(targetRect[1], targetRect[0]);
                var screenPoint2 = getMappointFromCoord(targetRect[3], targetRect[2]);
                var first = [screenPoint1[0] < screenPoint2[0] ? screenPoint1[0] : screenPoint2[0], screenPoint1[1] < screenPoint2[1] ? screenPoint1[1] : screenPoint2[1]];
                var second = [screenPoint1[0] > screenPoint2[0] ? screenPoint1[0] : screenPoint2[0], screenPoint1[1] > screenPoint2[1] ? screenPoint1[1] : screenPoint2[1]];
                ctx.strokeStyle = "#ff0000";
                ctx.beginPath();
                ctx.strokeRect(first[0], first[1], second[0] - first[0], second[1] - first[1]);
            }
            console.timeEnd("canvas-onPaint");
        }
    }

    PinchArea {
        id: pincharea

        property double __oldZoom
        property double __oldAngle

        anchors.fill: parent

        function calcZoomDelta(p) {
            var newZoomLevel = (Math.log(p.scale) / Math.log(2)) + __oldZoom;
            pinchmap.setZoomLevelPoint(newZoomLevel, p.center.x, p.center.y);
            if (rotationEnabled) {
                rot.angle = __oldAngle + p.rotation;
            }
            pan(p.previousCenter.x - p.center.x, p.previousCenter.y - p.center.y);
        }

        onPinchStarted: {
            __oldZoom = pinchmap.zoomLevel;
            __oldAngle = rot.angle;
        }

        onPinchUpdated: {
            calcZoomDelta(pinch);
        }

        onPinchFinished: {
            calcZoomDelta(pinch);
        }

        MouseArea {
            id: mousearea
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool __isPanning: false
            property bool __isDragingPoint: false
            property int __lastX: -1
            property int __lastY: -1
            property int __firstX: -1
            property int __firstY: -1
            property int maxClickDistance: 100

            anchors.fill: parent

            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    setZoomLevelPoint(pinchmap.zoomLevel + 1, wheel.x, wheel.y);
                } else {
                    setZoomLevelPoint(pinchmap.zoomLevel - 1, wheel.x, wheel.y);
                }
            }

            onDoubleClicked: {
                var click_coord = getCoordFromScreenpoint(mouse.x, mouse.y);
                currentPositionLat = click_coord[0];
                currentPositionLon = click_coord[1];
                currentPositionShow = true;
                console.log(click_coord[0], click_coord[1], G.calcLocator(click_coord[1], click_coord[0]));
            }

            onPressed: {
                pannedManually();
                __isPanning = true;
                __lastX = mouse.x;
                __lastY = mouse.y;
                __firstX = mouse.x;
                __firstY = mouse.y;
            }

            onReleased: {
                if (mouse.button == Qt.RightButton) {
                    return;
                }
                if (__isPanning) {
                    panEnd();
                }

                // pri kliknuti do mapy

                __isPanning = false;
                __isDragingPoint = false;
            }

            onPositionChanged: {
                if (mouse.button == Qt.RightButton) {
                    return;
                }
                if (__isPanning) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;
                    pan(-dx, -dy);
                    __lastX = mouse.x;
                    __lastY = mouse.y;
                    /*
                    once the pan threshold is reached, additional checking is unnecessary
                    for the press duration as nothing sets __wasClick back to true
                    */
                    //                    if (__wasClick && Math.pow(mouse.x - __firstX, 2) + Math.pow(mouse.y - __firstY, 2) > maxClickDistance) {
                    //                        __wasClick = false;
                    //                    }
                }
                if (__isDragingPoint) {
                    var dx = mouse.x - __lastX;
                    var dy = mouse.y - __lastY;
                    if (pointsSelectedIndex >= 0) {
                        var c = getCoordFromScreenpoint(mouse.x, mouse.y);
                        var item = pointsListModel.get(pointsSelectedIndex);
                        pointsListModel.setProperty(pointsSelectedIndex, "lat", c[0]);
                        pointsListModel.setProperty(pointsSelectedIndex, "lon", c[1]);
                    }
                    __lastX = mouse.x;
                    __lastY = mouse.y;
                }
            }

            onCanceled: {
                __isPanning = false;
                __isDragingPoint = false;
            }
        }
    }

    ListModel {
        id: pointsListModel
    }

    Text {
        id: attributionText
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignLeft
        anchors.leftMargin: 5
        anchors.bottomMargin: 2
        font.pixelSize: 12
        textFormat: Text.RichText

        text: parent.attribution + " " + parent.airspaceAttribution
    }

    Component.onCompleted: {
        G.testAll();
    }
}
