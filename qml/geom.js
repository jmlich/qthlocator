// SPDX-License-Identifier: GPL-3.0-only

.pragma library

var earth_radius = 6371000;
var global_center_lat = 0;
var global_center_lon = 0;
var originShift = 2 * Math.PI * 6378137 / 2.0

/* Ellipsoid model constants (actual values here are for WGS84) */
var sm_a = 6378137.0;
var sm_b = 6356752.314;
var sm_EccSquared = 6.69437999013e-03;

var UTMScaleFactor = 0.9996;

function rad2deg (rad) {
    return (180*rad)/Math.PI;
}

function rad2degPair (rad) {
    return [rad2deg(rad[0]), rad2deg(rad[1])]
}


function deg2rad (deg) {
    return (deg/180)*Math.PI;
}

function deg2radPair (deg) {
    return [deg2rad(deg[0]), deg2rad(deg[1])]
}


function formatDistance(d, settings) {
    if (! d) {
        return "0"
    }

    if (settings.distanceUnit === 'm') {
        if (d >= 15000) {
            return Math.round(d / 1000.0) + " km"
        } else if (d >= 3000) {
            return (d / 1000.0).toFixed(1) + " km"
        } else if (d >= 100) {
            return Math.round(d) + " m"
        } else {
            return d.toFixed(1) + " m"
        }
    } else if (settings.distanceUnit === 'km') {
        return Math.round(d / 1000.0) + " km"
    }
}

function formatBearing(b) {
    return Math.round(b) + "°"
}

function formatCoordinate(lat, lon, c) {
    return getLat(lat, c) + " " + getLon(lon, c)
}

function getDM(l) {
    var out = Array(3);
    out[0] = (l > 0) ? 1 : -1
    l = out[0] * l
    out[1] = ("00" + Math.floor(l)).substr(-3, 3)
    out[2] = ("00" + ((l - Math.floor(l)) * 60).toFixed(3)).substr(-6, 6)
    return out
}

function getValueFromDM(sign, deg, min) {
    return sign*(deg + (min/60))
}

function getLat(lat, settings) {
    var l = Math.abs(lat)
    var c = "N";
    if (lat < 0) {
        c = "S"
    }
    if (settings.coordinateFormat === "D") {
        return c + " " + l.toFixed(5) + "°"
    } else if (settings.coordinateFormat === "DM") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt))
        return ("00" + Math.floor(l)).slice(-2) + ("00"+Math.floor(mxt)).slice(-2)+ "." + ("000" + s.toFixed(3)*1000).slice(-3) + c
    } else if (settings.coordinateFormat === "DMS") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt)) * 60
        return c + " " + Math.floor(l) + "° " + Math.floor(mxt) + "' " + s.toFixed(3) + "''"
    } else {
        return c + " " + Math.floor(l) + "° " + ((l - Math.floor(l)) * 60).toFixed(3) + "'"
    }
}

function getLon(lon, settings) {
    var l = Math.abs(lon)
    var c = "E";
    if (lon < 0) {
        c = "W"
    }
    if (settings.coordinateFormat === "D") {
        return c + " " + l.toFixed(5) + "°"
    } else if (settings.coordinateFormat === "DM") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt))
        return ("000" + Math.floor(l)).slice(-3) + ("00"+Math.floor(mxt)).slice(-2)+ "." + ("000" + s.toFixed(3)*1000).slice(-3) + c
    } else if (settings.coordinateFormat === "DMS") {
        var mxt = (l - Math.floor(l)) * 60
        var s = (mxt - Math.floor(mxt)) * 60
        return c + " "+ Math.floor(l) + "° " + Math.floor(mxt) + "' " + s.toFixed(5) + "''"
    } else {
        return c + " " + Math.floor(l) + "° " + ((l - Math.floor(l)) * 60).toFixed(3) + "'"
    }
}



function distToAngle (meters) {
    var angle_radians = Math.asin(meters/earth_radius);
    return rad2deg(angle_radians);
}


function angleRad(center_lat, center_lon, poi_lat, poi_lon) {
    var lat = poi_lat - center_lat;
    var lon = (poi_lon - center_lon) * Math.cos(deg2rad(poi_lat))
    return Math.atan2(lon, lat);
}


function computeArcPoint(clat, clon, r, partAngle) {

    var lon = Math.sin(partAngle) * r;
    var lat = Math.cos(partAngle) * r;
    var rlat = clat + lat;
    var rlon = clon + lon / Math.cos ( deg2rad (rlat) )

    return [rlat, rlon];
}


function DMStoFloat(str) {
    var reg_exp = /([nsewNSEW])\s*(\d*)°\s*(\d*)'?\s*(\d*\.?\d*)'?'?/;
    var match = reg_exp.exec(str);

    if (match === null) {
        console.log("error: \"" + str + "\" is not valid Latitude/Longitude data")
        return parseFloat(str, 0);
    }

    var dir, d, m, s;
    dir = String(match[1]).toUpperCase()
    dir = ((dir === "N" || dir === "E" ) ? 1.0 : -1.0);

    d = parseFloat(match[2]);
    m = parseFloat(match[3]);
    s = parseFloat(match[4]);
    d = isNaN(d) ? 0 : d;
    m = isNaN(m) ? 0 : m
    s = isNaN(s) ? 0 : s;

    var value = dir * ( d + m/60.0 + s/3600.0 )

    return value;
}


function getMapTile(url, x, y, zoom, subdomains) {
    var result = url.replace("%(x)d", x).replace("%(y)d", y).replace("%(zoom)d", zoom);
    if ((subdomains !== undefined) && (subdomains.length > 0)) {
        var rand = Math.floor((Math.random() * subdomains.length));
        result = result.replace("%(s)d", subdomains[rand]);
    }

    return result;
}

function getBearingTo(lat, lon, tlat, tlon) {
    var lat1 = lat * (Math.PI/180.0);
    var lat2 = tlat * (Math.PI/180.0);

    var dlon = (tlon - lon) * (Math.PI/180.0);
    var y = Math.sin(dlon) * Math.cos(lat2);
    var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlon);
    return (360 + (Math.atan2(y, x)) * (180.0/Math.PI)) % 360;
}

function getDistanceTo(lat, lon, tlat, tlon) {
    var dlat = Math.pow(Math.sin((tlat-lat) * (Math.PI/180.0) / 2), 2)
    var dlon = Math.pow(Math.sin((tlon-lon) * (Math.PI/180.0) / 2), 2)
    var a = dlat + Math.cos(lat * (Math.PI/180.0)) * Math.cos(tlat * (Math.PI/180.0)) * dlon;
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return 6371000.0 * c;
}

function euclidDistance(a_x, a_y, b_x, b_y) {
    var d_x = a_x-b_x;
    var d_y = a_y-b_y;
    return Math.sqrt(d_x*d_x + d_y*d_y);
}

function lineIntersection(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy) {

    //  Fail if either line is undefined.
    if (Ax===Bx && Ay===By || Cx===Dx && Cy===Dy) return false;

    //  Fail if the segments share an end-point.
    if (Ax===Cx && Ay===Cy || Bx===Cx && By===Cy
            ||  Ax===Dx && Ay===Dy || Bx===Dx && By===Dy) {
        return false; }

    //  (1) Translate the system so that point A is on the origin.
    Bx-=Ax; By-=Ay;
    Cx-=Ax; Cy-=Ay;
    Dx-=Ax; Dy-=Ay;

    //  Discover the length of segment A-B.
    var distAB = Math.sqrt(Bx*Bx+By*By);

    //  (2) Rotate the system so that point B is on the positive X axis.
    var theCos=Bx/distAB;
    var theSin=By/distAB;
    var newX=Cx*theCos+Cy*theSin;
    Cy  =Cy*theCos-Cx*theSin; Cx=newX;
    newX=Dx*theCos+Dy*theSin;
    Dy  =Dy*theCos-Dx*theSin; Dx=newX;

    //  Fail if segment C-D doesn't cross line A-B.
    if (Cy<0. && Dy<0. || Cy>=0. && Dy>=0.) return false;

    //  (3) Discover the position of the intersection point along line A-B.
    var ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);

    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos<0. || ABpos>distAB) return false;

    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    var X = (Number(Ax) + ABpos*theCos);
    var Y = Ay + ABpos*theSin;

    //  Success.
    return {x: X, y: Y};

}

function latLonToMeters(lat, lon) {
    var mx = lon * originShift / 180.0
    var my = Math.log( Math.tan ( (90 + lat) * Math.PI / 360.0  ) ) / (Math.PI / 180);
    my = my * originShift / 180.0
    return [mx, my]
}

//    "Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"

function metersToLatLon(mx, my) {

    var lon = (mx / originShift) * 180.0;
    var lat = (my / originShift) * 180.0;

    lat = 180 / Math.PI * (2 * Math.atan( Math.exp( lat * Math.PI / 180.0)) - Math.PI / 2.0);
    return [lat, lon];
}

/**
  * Makes perpendicular projection of point to line
  * point C projected to line AB
  */

function projectionPointToLineLatLon(Ax, Ay, Bx, By, Cx,Cy) {

    var A = latLonToMeters(Ax, Ay)
    var B = latLonToMeters(Bx, By)
    var C = latLonToMeters(Cx, Cy)

    var D = projectionPointToLine(A[0], A[1], B[0], B[1], C[0], C[1])

    return metersToLatLon(D[0], D[1]);
}


/**
  * point C projected to line AB
  */

function projectionPointToLine(Ax, Ay, Bx, By, Cx, Cy) {


    var px = Bx - Ax;
    var py = By - Ay;

    var u =  ((Cx - Ax) * px + (Cy - Ay) * py) / (px * px + py * py)


    if (u > 1) {
        u = 1;
    } else if (u < 0) {
        u = 0;
    }

    var x = Ax + u * px;
    var y = Ay + u * py;

    return [x, y];


/*
    var ACdistance = getDistanceTo(Ax, Ay, Cx, Cy)
    var BCdistance = getDistanceTo(Bx, By, Cx, Cy)

    var ACratio = ACdistance/(ACdistance + BCdistance)

    var Dx = Ax * (1 - ACratio) + Bx * ACratio;
    var Dy = Ay * (1 - ACratio) + By * ACratio;

    return [Dx, Dy]
    */
}


function getCoordByDistanceBearing(lat, lon, bear, dist) {

    var lat1 = deg2rad(lat);
    var lon1 = deg2rad(lon);
    var brng = deg2rad(bear);
    var d = dist/earth_radius;  // uhlova vzdalenost

    var dlat = d * Math.cos ( brng );
    if (Math.abs(dlat) < 1E-10) {
        dlat = 0;
    }

    var lat2 = lat1 + dlat;
    var dphi = Math.log(Math.tan(lat2/2+Math.PI/4)/Math.tan(lat1/2+Math.PI/4));


    var q = (isFinite(dlat/dphi)) ? dlat/dphi : Math.cos(lat1);  // E-W line gives dPhi=0

    var dLon = d*Math.sin(brng)/q;

    if (Math.abs(lat2) > Math.PI/2) {
        lat2 = (lat2 > 0) ? Math.PI-lat2 : -Math.PI-lat2;
    }


    var lon2 = (lon1+dLon+Math.PI)%(2*Math.PI) - Math.PI;

    return {lat: rad2deg(lat2),lon: rad2deg(lon2)};

}



function calcLocator(plon, plat) {
    let lon = plon + 180;
    let lat = plat + 90;
    let loc = new Array(8).fill('-');

    const loch = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lod = '0123456789';

    if (lat < 0 || lat > 180 || lon < 0 || lon > 360) {
        console.log("Invalid input " + plat +"," + plon);
        return "ERROR";
    }

    // JN
    loc[0] = loch[Math.floor(lon / 20)];
    loc[1] = loch[Math.floor(lat / 10)];

    lon = lon % 20;
    lat = lat % 10;

    // JN89
    loc[2] = lod[Math.floor(lon / 2)];
    loc[3] = lod[Math.floor(lat)];
    lon = lon % 2;
    lat = lat % 1;

    // JN89GE
    loc[4] = loch[Math.floor(lon * 60 / 5)];
    loc[5] = loch[Math.floor(lat * 60 / 2.5)];
    lon = lon % (5 / 60);
    lat = lat % (2.5 / 60);

    // JN89GE00
    loc[6] = lod[Math.floor(lon * 600 / 5)];
    loc[7] = lod[Math.floor(lat * 600 / 2.5)];

    return loc.join('');
}

function locatorToLatLon(locator) {
    if (locator.length < 4) {
        return [0, 0];
    }

    const loch = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lod = '0123456789';

    // JN
    let lon = loch.indexOf(locator[0].toUpperCase()) * 20;
    let lat = loch.indexOf(locator[1].toUpperCase()) * 10;

    // JN89
    lon += lod.indexOf(locator[2]) * 2;
    lat += lod.indexOf(locator[3]);

    let lon2 = lon + 2;
    let lat2 = lat + 1;

    if (locator.length >= 5) {

        // JN89GE
        lon += (loch.indexOf(locator[4].toUpperCase()) / 12);
        lat += (loch.indexOf(locator[5].toUpperCase()) / 24);

        lon2 = lon + (1 / 12);
        lat2 = lat + (1 / 24);

    }

    if (locator.length >= 7) {
        // JN89GE00
        lon += (lod.indexOf(locator[6]) / 120);
        lat += (lod.indexOf(locator[7]) / 240);

        lon2 = lon + (1 / 120);
        lat2 = lat + (1 / 240);
    }

    lon -= 180;
    lat -= 90;

    lon2 -= 180;
    lat2 -= 90;

    return [lon, lat, lon2, lat2];
}

function locatorDistance(loc1, loc2) {
    var ll1 = locatorToLatLon(loc1) // [lon1, lat1, lon2, lat2]
    var ll2 = locatorToLatLon(loc2)

    return getDistanceTo((ll1[1]+ll1[3])/2, (ll1[0]+ll1[2])/2,(ll2[1]+ll2[3])/2, (ll2[0]+ll2[2])/2)
}

function locatorBearingTo(loc1, loc2) {
    var ll1 = locatorToLatLon(loc1) // [lon1, lat1, lon2, lat2]
    var ll2 = locatorToLatLon(loc2)
    return getBearingTo((ll1[1]+ll1[3])/2, (ll1[0]+ll1[2])/2,(ll2[1]+ll2[3])/2, (ll2[0]+ll2[2])/2)
}

function testAll() {

    var locator1_ref = "JN89GE55";
    var locator2_ref = "JN89WG54";
    var locator1_lonLat = [16.54167, 49.18750];
    var locator2_lonLat = [17.87500, 49.27083];

    var locator1 = calcLocator(locator1_lonLat[0], locator1_lonLat[1]);
    var locator2 = calcLocator(locator2_lonLat[0], locator2_lonLat[1]);
    var locator1_lonLat = locatorToLatLon(locator1_ref)
    var locator2_lonLat = locatorToLatLon(locator2_ref)

    console.log ( "test calcLocator Kohoutovice: " +  ((locator1_ref == locator1) ? "OK" : "FAILED " + locator1 + " != " + locator1_ref ))
    console.log ( "test calcLocator Vsemina: " +  ((locator2_ref == locator2 ) ? "OK" : "FAILED "+ locator2 +" != " + locator2_ref ))


    console.log("test locatorToLatLon: " + locator1_ref + " " + locatorToLatLon(locator1_ref) )
    console.log("test locatorToLatLon: " + locator2_ref + " " + locatorToLatLon(locator2_ref) )

}