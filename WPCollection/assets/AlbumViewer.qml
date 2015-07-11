import bb.cascades 1.2
import bb.data 1.0
import bb.system 1.2
import org.labsquare 1.0

ListView {
    property bool gifEnabled: false
    property string endpoint
    property bool loading: false
    property int columns: 4
    property int bestFit: 0
    property int total: 0
    property int limit: columns * 10
    property bool autoloadnextpage: navroot ? navroot.unlocked : false
    property variant navroot
    property variant gifregexp: /\.gif$/ig
    function genURL(offset_) {
        var url = "http://api.tumblr.com/v2/blog/%1/posts/photo?api_key=m7DH0EbGhFogCs5zrOiBObJjpawzcEoVyi53X0RyH00SXDVTSd&limit=%2&offset=%3".arg(endpoint).arg(limit).arg(offset_);
        return url;
    }
    dataModel: ArrayDataModel {
        id: adm
    }
    function requestFullView(fullurl, lowurl, itemdata) {
        var iview = Qt.createComponent("ImageViewer.qml").createObject(navroot);
        iview.hi_res_url = fullurl;
        iview.low_res_url = lowurl;
        iview.fulldata = itemdata;
        navroot.push(iview);
    }
    listItemComponents: [
        ListItemComponent {
            type: ""
            WebImageView {
                id: itemroot
                scalingMethod: ScalingMethod.AspectFill
                loadEffect: ImageViewLoadEffect.FadeZoom
                url: ListItemData.alt_sizes[ListItemData.alt_sizes.length - 1].url
                property string bestSize: ListItemData.alt_sizes[itemroot.ListItem.view.bestFit].url
                property string originalSize: ListItemData.original_size.url
                gestureHandlers: TapHandler {
                    onTapped: {
                        itemroot.ListItem.view.requestFullView(bestSize, itemroot.url, ListItemData);
                    }
                }
            }
        }
    ]
    attachedObjects: [
        ListScrollStateHandler {
            onAtEndChanged: {
                if (atEnd) {
                    if (! autoloadnextpage && (total > 0)) {
                        if (navroot && !navroot.unlocked){
                            sst.body=qsTr("Unlock to see more.")
                            sst.show();
                        }
                        return;
                    }
                    if (! loading && endpoint.trim().length !=0) {
                        loading = true;
                        pageDataSource.load();
                    }
                }
            }
        },
        DataSource {
            id: pageDataSource
            property int offset: 0
            source: genURL(offset)
            remote: true
            type: DataSourceType.Json
            onDataLoaded: {
                loading = false; //FIX #1
                if (data.meta.status == 200) {
                    var posts = data.response.posts;
                    total = data.response.total_posts
                    if (posts.length == 0) {
                        // if is empty.
                        return;
                    }
                    offset += posts.length;
                    //adm.append(posts);
                    //edit 2015/7/4 , preprocess posts incase there's multiple wallpapers in one post.
                    var wallpapers_array = [];
                    for (var i = 0; i < posts.length; i ++) {
                        var currentpost = posts[i];
                        for (var j = 0; j < currentpost.photos.length; j ++) {
                            var wallpaper_item = currentpost.photos[j];
                            if (gifEnabled) {

                            } else if (gifregexp.test(wallpaper_item.original_size.url)) {
                                continue;
                            }

                            wallpapers_array.push(wallpaper_item)
                        }
                    }
                    adm.append(wallpapers_array);
                } else {
                    ssd.body = data.meta.msg;
                    ssd.show();
                }
            }
            onError: {
                loading = false;
                console.log(errorMessage)
                ssd.body = qsTr("Host unreachable, please check your Internet connection and try again. ");
                ssd.show()
            }
        },
        SystemToast {
            id: sst
        },
        SystemDialog {
            id: ssd
            title: qsTr("Error")
            includeRememberMe: false
            rememberMeChecked: false
            customButton.enabled: false
            cancelButton.enabled: false
            onFinished: {
                navroot.pop()
            }
        }
    ]
    layout: GridListLayout {
        columnCount: columns

    }
    scrollRole: ScrollRole.Main

}