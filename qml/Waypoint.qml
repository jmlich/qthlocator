import QtQuick 2.9
// import "uiconstants.js" as UI

Image {
    id: item
    property variant targetPoint
    property string waypointType: "Diamond_Blue";
    property real azimuth: 0
    property real mapx;
    property real mapy;
//    width: 46
//    height: 46
    x: mapx + targetPoint[0] - width/2
    y: mapy + targetPoint[1] - height/2
    source: "qrc:///images/"+waypointType+".png"

    transform: Rotation {
        origin.x: item.width/2
        origin.y: item.height - item.width/2
        angle: azimuth
    }
}

//Rectangle {
//    width: drawSimple ? 10: 36
//    height: drawSimple ? 10: 36
//    property variant cache
//    property bool drawSimple
//    color: (currentGeocache && cache.name == currentGeocache.name) ? "#44ff0000" : (cache.marked ? "#88ffff80" : "#88ffffff")
//    border.width: 4
//    border.color: UI.getCacheColor(cache)
//    //smooth: true
//    radius: 7
//    visible: ! (settings.optionsHideFound && cache.found)
//    Image {
//        source: (cache.status == 0) ? "qrc:///images/mark.png" : "qrc:///images/cross.png";
//        anchors.centerIn: parent
//        visible: ! drawSimple
//    }
//}
