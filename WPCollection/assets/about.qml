import bb.cascades 1.4
import bb 1.3
import bb.device 1.4
Page {
    property variant navroot
    attachedObjects: [
        PackageInfo {
            id: pi
        }
    ]
    actions: [
        ActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///icon/ic_feedback.png"
            title: qsTr("Feedback")
            onTriggered: {
                var feedback = Qt.createComponent("webviewer.qml").createObject(navroot);
                feedback.uri = "https://github.com/BBDev-CN/wallpapers/issues";
                feedback.nav = navroot;
                navroot.push(feedback)
            }
        }
    ]
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    ScrollView {
        scrollRole: ScrollRole.Main
        Container {
            Header {
                title: qsTr("VERSION")
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 50.0
                ImageView {
                    imageSource: "asset:///icon/icon.png"
                    preferredHeight: ui.du(15)
                    scalingMethod: ScalingMethod.AspectFit
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Label {
                    text: qsTr("Wallpapers Ver. %1").arg(pi.version)
                    textStyle.textAlign: TextAlign.Center
                    horizontalAlignment: HorizontalAlignment.Fill
                }
                Label {
                    text: _app.getv('unlock', 'false') == "true" ? qsTr("Unlocked") : qsTr("LOCKED")
                    textStyle.textAlign: TextAlign.Center
                    horizontalAlignment: HorizontalAlignment.Fill
                }
            }
            Header {
                title: qsTr("FREE / UNLOCKED DIFFERENCES")
            }
            Container {
                leftPadding: 20.0
                topPadding: 20.0
                rightPadding: 20.0
                horizontalAlignment: HorizontalAlignment.Fill
                bottomPadding: 20.0
                Label {
                    multiline: true
                    text: qsTr("Free version has these limits:\r\n- Can only view about 40 images of each gallery.\r\n- My Galleries is disabled.\r\nUnlocked version benifits:\r\n- View all images in gallery\r\n- Add customized tumblr sites to My Galleries with / without GIF enabled.\r\n- Import / Export My Galleries, share with your friends.")
                    textStyle.fontWeight: FontWeight.W100
                    textFit.mode: LabelTextFitMode.FitToBounds
                    textStyle.textAlign: TextAlign.Left
                }
            }

            Header {
                title: qsTr("ABOUT AUTHOR")
            }
            Container {
                leftPadding: 20.0
                topPadding: 20.0
                rightPadding: 20.0
                horizontalAlignment: HorizontalAlignment.Fill
                bottomPadding: 20.0
                Label {
                    multiline: true
                    text: qsTr("This app is developed by Merrick Zhang, founder of <a href=\"http://anpho.github.io\">anpho</a> and <a href=\"http://bbdev.cn\">BBDev.CN</a> , focused on bring best apps to BlackBerry 10 platform.")
                    textStyle.fontWeight: FontWeight.W100
                    textFit.mode: LabelTextFitMode.FitToBounds
                    textStyle.textAlign: TextAlign.Left
                    textFormat: TextFormat.Html
                }
            }
            Header {
                title: qsTr("COPYRIGHT")
            }
            Container {
                leftPadding: 20.0
                topPadding: 20.0
                rightPadding: 20.0
                horizontalAlignment: HorizontalAlignment.Fill
                bottomPadding: 20.0
                Label {
                    multiline: true
                    text: qsTr("All images / animated gifs are copyrighted by the original author, this app is a customized tumblr client designed to browse the largest picture community and provide native experiences to BlackBerry 10 users.")
                    textStyle.fontWeight: FontWeight.W100
                    textFit.mode: LabelTextFitMode.FitToBounds
                    textStyle.textAlign: TextAlign.Justify
                }
            }
        }
    }
}
