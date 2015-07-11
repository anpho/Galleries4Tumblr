import bb.cascades 1.2

QtObject {
    function ajax(method, endpoint, paramsArray, callback, customheader, form) {
        console.log(method + "//" + endpoint + JSON.stringify(paramsArray))
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status == 200) {
                    console.log("[AJAX]Response = " + request.responseText);
                    callback({
                            "success": true,
                            "data": request.responseText
                        });
                } else {
                    console.log("[AJAX]Status: " + request.status + ", Status Text: " + request.statusText);
                    callback({
                            "success": false,
                            "data": request.statusText
                        });
                }
            }
        };
        var params = paramsArray.join("&");
        var url = endpoint;
        if (method == "GET" && params.length > 0) {
            url = url + "?" + params;
        }
        request.open(method, url, true);
        if (form) {
            request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        }

        if (customheader) {
            for (var i = 0; i < customheader.length; i ++) {
                request.setRequestHeader(customheader[i].k, customheader[i].v);
            }
        }
        if (method == "GET") {
            request.send();
        } else {
            request.send(params);
        }
    }

    onCreationCompleted: {
        console.log("[QML]Common.qml loaded.")
    }

    function getResult(endpoint, callback) {
        endpoint = "http://api.tumblr.com/v2/blog/%1/posts/photo?api_key=m7DH0EbGhFogCs5zrOiBObJjpawzcEoVyi53X0RyH00SXDVTSd&limit=1".arg(endpoint);
        ajax("GET", endpoint, [], function(r) {
                if (r['success']) {
                    var msgbody = JSON.parse(r['data']);
                    if (msgbody.meta.status == 200) {
                        callback(true, msgbody.response)
                    } else {
                        callback(false, msgbody.meta.msg)
                    }
                } else {
                    callback(false, qsTr("Network Error."));
                }
            }, [], false);
    }
    function getLastUpdate(sitename, callback) {
        if (sitename == "") {
            callback(indexpath, false, qsTr("site name not given."))
        }
        var endpoint = "http://api.tumblr.com/v2/blog/%1/posts/photo?limit=1&api_key=m7DH0EbGhFogCs5zrOiBObJjpawzcEoVyi53X0RyH00SXDVTSd".arg(sitename);
        ajax("GET", endpoint, [], function(r) {
                if (r['success']) {
                    var msgbody = JSON.parse(r['data']);
                    if (msgbody.meta.status == 200) {
                        var lastupdate = msgbody.response.blog.updated;
                        var imagearray = msgbody.response.posts[0].photos[0].alt_sizes;
                        var firstimage = imagearray[imagearray.length - 1].url;
                        callback(firstimage, true, calcDateInteval(lastupdate), msgbody.response.blog.posts)
                    } else {
                        callback("", false, qsTr("Invalid API result"), -1);
                    }
                } else {
                    callback("", false, qsTr("Network error."), -1)
                }
            }, [], false)
    }
    property variant div: [ 1, 60, 60, 24, 7, 4, 12 ]
    property variant units: [ 'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', 'years' ]
    function calcDateInteval(from) {
        var intv = (new Date().getTime() - from * 1000 ) / 1000;
        var result = intv;
        var i = 0;
        while (result > div[i + 1] && i < div.length) {
            i ++;
            result = result / div[i];
        }
        result = Math.floor(result);

        var string_result = ("%1 %2 ago").arg(result).arg(units[i])
        if (result <= 0) {
            string_result = qsTr("Just now");
        }
        console.log(string_result);
        return string_result;
    }

}
