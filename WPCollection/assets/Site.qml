import bb.cascades 1.4

Page {
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property variant nav
    property int batch: parseInt(_app.getv('limit', "40"))
    property int columnsint: parseInt(_app.getv('columns', '4'))
    property alias endpoint: av.endpoint
    property alias enableGif: av.gifEnabled
    onCreationCompleted: {
        batch = parseInt(_app.getv('limit', '40'))
        columnsint = parseInt(_app.getv('columns', '4'))
    }
    Container {
        layout: DockLayout {

        }
        AlbumViewer {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            id: av
            navroot: nav
            limit: batch
            columns: columnsint
            scrollRole: ScrollRole.Main
        }
        Container {
            visible: av.loading
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Bottom
            background: Color.Black
            opacity: 0.8

            layout: DockLayout {

            }
            Container {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                topPadding: 20.0
                bottomPadding: 20.0
                Label {
                    text: qsTr("Loading Contents...")
                    textStyle.color: Color.White
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontWeight: FontWeight.W100
                }
            }

        }
    }
}
