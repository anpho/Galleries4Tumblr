import bb.cascades 1.4
import bb.platform 1.3
Page {
    attachedObjects: [
        PaymentManager {
            id: pm
            windowGroupId: Application.mainWindow.groupId
            onPurchaseFinished: {
                if (reply.errorCode == 0) {
                    _app.setv("unlock", "true");
                    purchased = 2;
                } else {
                    purchased = 1;
                }
            }
            function purchaseNow() {
                requestPurchase("", goodid);
            }
            onExistingPurchasesFinished: {
                if (reply.purchases.length > 0) {
                    _app.setv("unlock", "true");
                    purchased = 2;
                } else {
                    purchased = 1;
                    errortext.text = reply.errorText;
                }
            }
        }
    ]
    property variant nav
    property string goodid: 'SKU59965901'
    property int purchased: 0
    /*
     * 0 : unknown
     * 1 : not
     * 2 : purchased
     */
    onCreationCompleted: {
        pm.requestExistingPurchases(true);
    }
    ScrollView {
        Container {
            Header {
                title: qsTr("Unlock with BlackBerry World Payment")
            }
            Container {
                leftPadding: 20.0
                rightPadding: 20.0
                topPadding: 10.0
                bottomPadding: 10.0
                Label {
                    multiline: true
                    text: qsTr("Free version has these limits:\r\n- Can only view about 40 images of each gallery.\r\n- My Galleries is disabled.\r\nUnlocked version benifits:\r\n- View all images in gallery\r\n- Add customized tumblr sites to My Galleries with / without GIF enabled.\r\n- Import / Export My Galleries, share with your friends.")
                    textStyle.fontWeight: FontWeight.W100
                }
            }
            Divider {

            }
            Container {
                leftPadding: 20.0
                rightPadding: 20.0
                topPadding: 10.0
                bottomPadding: 10.0
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    text: qsTr("Payment status:")
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0
                    }
                }
                Label {
                    text: qsTr("Purchased")
                    visible: purchased == 2
                    textStyle.color: Color.Green
                }
                Label {
                    visible: purchased == 1
                    text: qsTr("Not Purchased")
                    textStyle.color: Color.Red
                }
                Label {
                    visible: purchased == 0
                    text: qsTr("Contacting BlackBerry World")
                    textStyle.color: Color.Blue
                }
            }
            Container {
                visible: purchased == 1
                leftPadding: 20.0
                rightPadding: 20.0
                topPadding: 10.0
                bottomPadding: 10.0
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontWeight: FontWeight.W100
                    multiline: true
                    id: errortext
                }
            }
            Divider {

            }
            Button {
                text: qsTr("Purchase")
                horizontalAlignment: HorizontalAlignment.Center
                appearance: ControlAppearance.Primary
                color: Color.Red
                visible: purchased == 1
                onClicked: {
                    pm.purchaseNow()
                }
            }
        }
    }
}
