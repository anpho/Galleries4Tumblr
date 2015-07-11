import bb.cascades 1.4
import bb.system 1.2
Page {
    property variant nav
    signal siteToBeAdded(string hostname, string hosturl, bool gifEnabled)
    attachedObjects: [
        Common {
            id: co
        },
        SystemPrompt {
            id: ssp
            title: qsTr("Name this gallery")
            body: qsTr("Please name this gallery: %1").arg(hosturl)
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection) {
                    nav.pop();
                    siteToBeAdded(inputFieldTextEntry(), hosturl, gif_Enabled)
                } else {
                }
            }
            inputField.defaultText: hosttitle
            inputField.maximumLength: 50
            inputOptions: SystemUiInputOption.None
            inputField.emptyText: qsTr("Unknown")
            dismissAutomatically: true

        },
        SystemToast {
            id: sst
        }
    ]
    titleBar: TitleBar {
        title: qsTr("Add a gallery")

    }
    id: pageAddSite
    property string hostname
    property string hosturl
    property string hostimages
    property string hosttitle
    property alias gif_Enabled: giftoggle.checked
    property bool hostvalid: false

    function testSite() {
        hostvalid = false;
        // test if the tumblr site is valid
        hosturl = "%1.tumblr.com".arg(hostname);
        co.getResult(hosturl, function(b, d) {
                if (b) {
                    pageAddSite.hostvalid = true
                    pageAddSite.hostimages = d.total_posts
                    pageAddSite.hosttitle = d.blog.title
                } else {
                    pageAddSite.hostvalid = false;
                    pageAddSite.hostimages = "";
                    pageAddSite.hosttitle = ""
                    sst.body = qsTr("Not a valid gallery.")
                    sst.show();
                }
            })
    }
    Container {
        Header {
            title: qsTr("Gallery Address")
        }
        Container {
            leftPadding: 20.0
            topPadding: 10.0
            bottomPadding: 10.0
            rightPadding: 20.0
            Label {
                text: qsTr("You can add a <a href='http://tumblr.com'>Tumblr</a> site here.")
                multiline: true
                textStyle.fontWeight: FontWeight.W100
                textFormat: TextFormat.Html
            }
        }

        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            leftPadding: 20.0
            rightPadding: 20.0
            topPadding: 10.0
            bottomPadding: 10.0
            Label {
                text: "http://"
                verticalAlignment: VerticalAlignment.Center
                textStyle.fontWeight: FontWeight.W100
            }
            TextField {
                id: domainname
                verticalAlignment: VerticalAlignment.Center
                hintText: qsTr("type domain name here")
                textFormat: TextFormat.Plain
                input.submitKey: SubmitKey.Done
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                validator: Validator {
                    property variant regex_anh: /^[a-z0-9\-]+$/i
                    errorMessage: qsTr("Only Alphabet, Numeric and Hyphen allowed.")
                    onValidate: {
                        state = ValidationState.InProgress
                        valid = regex_anh.test(domainname.text)
                        if (valid) {
                            state = ValidationState.Valid
                        } else {
                            state = ValidationState.Invalid
                        }
                    }
                    mode: ValidationMode.Immediate
                }
                textStyle.fontWeight: FontWeight.W100
                textStyle.textAlign: TextAlign.Center
                backgroundVisible: true
                clearButtonVisible: true

            }
            Label {
                text: ".tumblr.com"
                verticalAlignment: VerticalAlignment.Center
                textStyle.fontWeight: FontWeight.W100
            }

        }
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight

            }
            leftPadding: 20.0
            topPadding: 10.0
            bottomPadding: 10.0
            rightPadding: 20.0
            Label {
                text: qsTr("Enable GIF for this gallery")
                textStyle.fontWeight: FontWeight.W100
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1.0

                }
                verticalAlignment: VerticalAlignment.Center

            }
            ToggleButton {
                id: giftoggle
            }
        }
        Button {
            enabled: domainname.validator.valid
            verticalAlignment: VerticalAlignment.Center
            text: qsTr("Check")
            onClicked: {
                // add to lib.
                //                var item = {
                //                    "title": countlabel.title,
                //                    "host": countlabel.host
                //                }
                //                mysites.add(item);
                hostname = domainname.text;
                testSite();
            }
            horizontalAlignment: HorizontalAlignment.Center
        }

        Container {
            visible: hostvalid
            horizontalAlignment: HorizontalAlignment.Fill
            Label {
                text: qsTr("%1 has %2 posts").arg(hosturl).arg(hostimages)
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Fill
            }

        }

        ControlDelegate {
            delegateActive: hostvalid && hosturl.trim().length>0
            sourceComponent: ComponentDefinition {
                AlbumViewer {
                    id: av
                    navroot: nav
                    endpoint: hosturl
                    gifEnabled: gif_Enabled
                    limit: 8
                    columns: 4
                    autoloadnextpage: false
                }
            }
        }
    }
    actions: [
        ActionItem {
            title: qsTr("Add")
            imageSource: "asset:///icon/ic_done.png"
            ActionBar.placement: ActionBarPlacement.Signature
            enabled: hostvalid
            onTriggered: {
                ssp.show();
            }
        }
    ]
}
