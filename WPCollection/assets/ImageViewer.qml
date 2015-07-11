import bb.cascades 1.4
import org.labsquare 1.0
import bb.platform 1.3
import bb.system 1.2
import bb.device 1.4
Page {
    property string hi_res_url
    property string low_res_url
    property variant fulldata
    property bool option_panel_visible: false
    onFulldataChanged: {
        console.log(JSON.stringify(fulldata))
        for (var i = 0; i < fulldata.alt_sizes.length; i ++) {
            var alt = fulldata.alt_sizes[i];
            var op = option.createObject();
            op.text = "%1 x %2".arg(alt.width).arg(alt.height);
            op.value = alt.url;
            rg.add(op);
        }
        rg.setSelectedIndex(1);
    }
    attachedObjects: [
        HomeScreen {
            id: hs
        },
        ComponentDefinition {
            id: option
            Option {

            }
        },
        SystemDialog {
            id: ssd
            title: qsTr("Error")
            body: qsTr("Image not found in cache, this shouldn't happen. Please clear the image cache through Settings and try again.")
            returnKeyAction: SystemUiReturnKeyAction.Default
            includeRememberMe: false
            rememberMeChecked: false
            customButton.enabled: false
            cancelButton.enabled: false
            confirmButton.label: "OK"
            onFinished: {
                navroot.pop();
            }
        },
        DisplayInfo {
            id: di
        }
    ]
    Container {
        attachedObjects: LayoutUpdateHandler {
            onLayoutFrameChanged: {
                webivlowres.preferredWidth = webiv.preferredWidth = layoutFrame.width
            }
        }
        layout: DockLayout {

        }
        WebImageView {
            id: webivlowres
            url: low_res_url
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            scalingMethod: ScalingMethod.AspectFill
            loadEffect: ImageViewLoadEffect.FadeZoom
            visible: webiv.loading < 1
        }
        WebImageView {
            id: webiv
            //            url: hi_res_url
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            scalingMethod: fill_or_fit ? ScalingMethod.AspectFill : ScalingMethod.AspectFit
            loadEffect: ImageViewLoadEffect.FadeZoom
            property bool fill_or_fit: true
            gestureHandlers: TapHandler {
                onTapped: {
                    webiv.fill_or_fit = ! webiv.fill_or_fit
                }
            }
        }
        Container {
            visible: webiv.loading < 1
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            Label {
                text: qsTr("Downloading image")
                horizontalAlignment: HorizontalAlignment.Center
                textFit.mode: LabelTextFitMode.FitToBounds
                textStyle.fontWeight: FontWeight.W100
                textStyle.color: Color.White
            }
            ProgressIndicator {
                fromValue: 0
                toValue: 1
                value: webiv.loading
                horizontalAlignment: HorizontalAlignment.Center
            }
        }
        ScrollView {
            visible: option_panel_visible
            horizontalAlignment: HorizontalAlignment.Fill
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                background: ui.palette.background
                RadioGroup {
                    id: rg
                    onSelectedValueChanged: {
                        webiv.resetControl();
                        webiv.url = selectedValue;
                        option_panel_visible = false
                    }
                    dividersVisible: true
                    verticalAlignment: VerticalAlignment.Bottom
                    horizontalAlignment: HorizontalAlignment.Center
                }
            }
            onFocusedChanged: {
                if (! focused) {
                    option_panel_visible = false;
                }
            }
            verticalAlignment: VerticalAlignment.Bottom
            scrollViewProperties.pinchToZoomEnabled: false
            scrollViewProperties.scrollMode: ScrollMode.Vertical
            scrollViewProperties.scrollRailsPolicy: ScrollRailsPolicy.LockNearAxes
            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.None
        }
    }

    actions: [
        ActionItem {
            enabled: webiv.loading == 1 && ! /\.gif$/i.test(low_res_url)
            ActionBar.placement: ActionBarPlacement.Signature
            title: qsTr("Set Wallpaper")
            imageSource: "asset:///icon/ic_done.png"
            onTriggered: {
                var cachedurl = webiv.getCachedPath();
                if (cachedurl.length > 0) {
                    hs.setWallpaper(cachedurl);
                } else {
                    ssd.show()
                }
            }

        },
        ActionItem {
            enabled: webiv.loading == 1
            imageSource: "asset:///icon/ic_view_image.png"
            title: qsTr("View Image")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                var cachedurl = webiv.getCachedPath();
                if (cachedurl.length > 0) {
                    _app.viewimage(cachedurl);
                } else {
                    ssd.show()
                }
            }
        },
        ActionItem {
            imageSource: "asset:///icon/ic_set_as_default.png"
            title: qsTr("Sizes")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                option_panel_visible = ! option_panel_visible
            }

        },
        ActionItem {
            enabled: webiv.loading == 1
            ActionBar.placement: ActionBarPlacement.Default
            imageSource: "asset:///icon/ic_share.png"
            title: qsTr("Share Image")
            onTriggered: {
                var cachedurl = webiv.getCachedPath();
                if (cachedurl.length > 0) {
                    _app.shareImage(cachedurl);
                } else {
                    ssd.show()
                }
            }
        },
        ActionItem {
            imageSource: "asset:///icon/ic_doctype_picture.png"
            title: qsTr("View Full-Res Image")
            onTriggered: {
                Qt.openUrlExternally(fulldata.original_size.url)
            }
        }
    ]
}
