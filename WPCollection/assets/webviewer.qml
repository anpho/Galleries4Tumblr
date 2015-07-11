import bb.cascades 1.2

Page {
    property alias uri: webv.url
    property variant nav
    titleBar: TitleBar {
        title: webv.title
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    Container {
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill

        background: Color.Black
        ScrollView {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollRole: ScrollRole.Main
            WebView {
                id: webv
                horizontalAlignment: HorizontalAlignment.Fill
                preferredHeight: Infinity
                onNavigationRequested: {
//                    if (url.toString().trim().length == 0) {
//                        return;
//                    }
//                    if (request.navigationType == WebNavigationType.LinkClicked || request.navigationType == WebNavigationType.OpenWindow) {
//                        request.action = WebNavigationRequestAction.Ignore
//                        var page = Qt.createComponent("webviewer.qml").createObject(nav);
//                        page.uri = request.url;
//                        page.nav = nav;
//                        nav.push(page)
//                    }
                }
                settings.userAgent: "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
                settings.defaultFontSizeFollowsSystemFontSize: true
                settings.zoomToFitEnabled: true
                settings.activeTextEnabled: false

            }
        }
    }
}