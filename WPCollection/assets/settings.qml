import bb.cascades 1.4
import bb.device 1.4
import org.labsquare 1.0
import bb.system 1.2
Page {
    attachedObjects: [
        DisplayInfo {
            id: di
        }
    ]
    property bool unlocked: false
    property variant navroot
    property variant display: di.pixelSize
    property int columns: Math.round(column_slider.immediateValue)
    property int batchsize: (Math.round(di.pixelSize.height / (di.pixelSize.width / columns) * columns / 10) + 1 ) * 10
    onBatchsizeChanged: {
        _app.setv("limit", batchsize);
    }
    ScrollView {
        Container {
            Header {
                title: qsTr("THEME SETTINGS")
            }
            Container {
                topPadding: 10.0
                bottomPadding: 10.0
                leftPadding: 20.0
                rightPadding: 20.0

                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                Label {
                    text: qsTr("Use Dark Theme")
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0

                    }
                    textStyle.fontWeight: FontWeight.W100
                    verticalAlignment: VerticalAlignment.Center
                }
                ToggleButton {
                    checked: Application.themeSupport.theme.colorTheme.style === VisualStyle.Dark
                    onCheckedChanged: {
                        _app.setv("use_dark_theme", checked ? "dark" : "bright");
                        try {
                            Application.themeSupport.setVisualStyle(checked ? VisualStyle.Dark : VisualStyle.Bright);
                        } catch (e) {

                        }
                    }
                }
            }
            Container {
                topPadding: 10.0
                leftPadding: 20.0
                bottomPadding: 10.0
                rightPadding: 20.0
                Label {
                    multiline: true
                    text: qsTr("This will be applied immediately.")
                    textStyle.fontWeight: FontWeight.W100
                }
            }
            Header {
                title: qsTr("UI SETTINGS")
            }
            Container {
                topPadding: 10.0
                leftPadding: 20.0
                bottomPadding: 10.0
                rightPadding: 20.0
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: qsTr("Columns in a gallery view.Default number is 4, which looks like below:")
                    textStyle.fontWeight: FontWeight.W100
                    multiline: true
                }
                ImageView {
                    imageSource: "asset:///images/columns.png"
                    scalingMethod: ScalingMethod.AspectFit
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight

                    }
                    Slider {
                        value: parseInt(_app.getv('columns', "4"))
                        fromValue: 3
                        toValue: 6
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }
                        id: column_slider
                        onValueChanged: {
                            _app.setv('columns', Math.round(value));
                        }
                        verticalAlignment: VerticalAlignment.Center
                    }
                    Label {
                        text: qsTr("%1 columns").arg(Math.round(column_slider.immediateValue))
                        textStyle.fontWeight: FontWeight.W100
                        verticalAlignment: VerticalAlignment.Center
                    }
                }
                Label {
                    text: qsTr("Each web request will fetch %1 images from gallery.").arg(batchsize)
                    textStyle.fontWeight: FontWeight.W100
                    multiline: true
                }
                Label {
                    text: qsTr("Please note that in FREE version, this app will send ONE request for each gallery only, UNLOCKED version has no limitation and can browse all images in gallery.")
                    textStyle.fontWeight: FontWeight.W100
                    multiline: true
                }
            }
            Header {
                title: qsTr("CACHE MANAGEMENT")
            }
            Container {
                topPadding: 10.0
                bottomPadding: 10.0
                leftPadding: 20.0
                rightPadding: 20.0
                horizontalAlignment: HorizontalAlignment.Fill
                WebImageView {
                    id: wi
                    visible: false
                }
                Label {
                    text: qsTr("This app will automatically cache images, if you want to clear all the caches now, press this button below.")
                    multiline: true
                    textStyle.fontWeight: FontWeight.W100

                }
                Button {
                    horizontalAlignment: HorizontalAlignment.Center
                    color: Color.DarkGreen
                    text: qsTr("CLEAR CACHE")
                    onClicked: {
                        wi.clearCache();
                        sst.body = qsTr("Cache cleared.")
                        sst.show();
                    }
                    attachedObjects: [
                        SystemToast {
                            id: sst
                        }
                    ]
                }
            }
            Header {
                title: qsTr("UNLOCK FREATURES")
            }
            Container {
                visible: button_unlock.visible
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 10.0
                bottomPadding: 10.0
                leftPadding: 20.0
                rightPadding: 20.0
                Label {
                    text: qsTr("Features in UNLOCKED version:\r\n- My Sites ( add your customized tumblr sites, import / export them, and share with your friends.\r\n- View all images in gallery instead of only latest 50.")
                    multiline: true
                    textStyle.fontWeight: FontWeight.W100

                }
            }
            Button {
                visible: ! unlocked
                horizontalAlignment: HorizontalAlignment.Center
                text: qsTr("UNLOCK")
                onClicked: {
                    sstoast.body = qsTr("Processing...")
                    sstoast.show();
                    var unlockpage = Qt.createComponent("unlock.qml").createObject(navroot);
                    navroot.push(unlockpage);
                }
                attachedObjects: [
                    SystemToast {
                        id: sstoast
                    }
                ]
                id: button_unlock
                color: Color.DarkCyan
            }
            Container {
                visible: ! button_unlock.visible
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: qsTr("You've unlocked all the features, thank you!")
                    textStyle.textAlign: TextAlign.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    multiline: true
                    textStyle.fontWeight: FontWeight.W100
                }
            }
            Divider {

            }
        }
    }
}
