/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.2
import bb.system 1.2
import bb.cascades.pickers 1.0
import org.labsquare 1.0
NavigationPane {
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            attachedObjects: [
                ComponentDefinition {
                    id: aboutpage
                    source: "about.qml"
                }
            ]
            onTriggered: {
                var abtpage = aboutpage.createObject()
                abtpage.navroot = navigationPane;
                navigationPane.push(abtpage);
            }
        }
        settingsAction: SettingsActionItem {
            attachedObjects: [
                ComponentDefinition {
                    id: setpage
                    source: "settings.qml"
                }
            ]
            onTriggered: {
                var settings = setpage.createObject();
                settings.unlocked = unlocked;
                settings.navroot = navigationPane;
                navigationPane.push(settings);
            }
        }
    }
    onPushTransitionEnded: {
        if (navigationPane.top != basepage) {
            Application.menuEnabled = false;
        }
        // disable application menu.
    }
    onPopTransitionEnded: {
        // Destroy the popped Page once the back transition has ended.
        page.destroy();
        if (navigationPane.top == basepage) {
            Application.menuEnabled = true;
        }
        unlocked = _app.getv('unlock', 'false') == "true"
    }
    id: navigationPane
    property bool unlocked: _app.getv('unlock', 'false') == "true"

    attachedObjects: [
        Common {
            id: co
        },
        SystemToast {
            id: sst
        }
    ]
    Page {
        id: basepage
        titleBar: TitleBar {
            kind: TitleBarKind.Segmented
            options: [
                Option {
                    id: opdef
                    text: qsTr("Default")
                },
                Option {
                    id: opfav
                    text: qsTr("Favourite")
                },
                Option {
                    id: opmine
                    text: qsTr("My Galleries")
                    enabled: unlocked
                    onSelectedChanged: {
                        if (selected) {
                            basepage.actionBarVisibility = ChromeVisibility.Default
                        } else {
                            basepage.actionBarVisibility = ChromeVisibility.Hidden
                        }
                    }
                }
            ]
        }
        function addnewSite(hname, hurl, gif) {
            console.log("Adding to galleries>>title: %1, url:%2, gif:%3".arg(hname).arg(hurl).arg(gif))
            var item = {
                "title": hname,
                "host": hurl,
                "gif": gif
            }
            mysites.add(item)
        }
        actions: [
            ActionItem {
                title: qsTr("Add Gallery")
                imageSource: "asset:///icon/ic_add.png"
                ActionBar.placement: ActionBarPlacement.Signature
                onTriggered: {
                    var addsitepage = Qt.createComponent("AddSite.qml").createObject(navigationPane);
                    addsitepage.nav = navigationPane;
                    addsitepage.siteToBeAdded.connect(basepage.addnewSite);
                    navigationPane.push(addsitepage);
                }
            },
            ActionItem {
                title: qsTr("Import")
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///icon/ic_add_folder.png"
                onTriggered: {
                    fp.open()
                }
                attachedObjects: [
                    FilePicker {
                        id: fp
                        mode: FilePickerMode.Picker
                        type: FileType.Other
                        defaultType: FileType.Other
                        viewMode: FilePickerViewMode.ListView
                        sortOrder: FilePickerSortOrder.Descending
                        sortBy: FilePickerSortFlag.Date
                        title: qsTr("Pick a file to import")
                        onError: {
                            sst.body = qsTr("Unknown error : %1").arg(error)
                            sst.show();
                        }
                        onFileSelected: {
                            console.log("FileSelected signal received : " + selectedFiles);
                            var filepath = selectedFiles[0];
                            var filecontent = _app.readTextFile(filepath);
                            if (filecontent == "") {
                                sst.body = qsTr("No gallery imported, file not valid.")
                                sst.show();
                            } else {
                                try {
                                    var jsondata = JSON.parse(filecontent);
                                    for (var i = 0; i < jsondata.length; i ++) {
                                        mysites.add(jsondata[i])
                                    }
                                    sst.body = qsTr("Data imported successfully.");
                                    sst.show();
                                } catch (e) {
                                    sst.body = qsTr("No gallery imported, file not valid.")
                                    sst.show();
                                }
                            }
                        }
                    }
                ]
            },
            ActionItem {
                title: qsTr("Export")
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///icon/ic_save.png"
                onTriggered: {
                    filesavepicker.open()
                }
                attachedObjects: [
                    FilePicker {
                        id: filesavepicker
                        mode: FilePickerMode.Saver
                        type: FileType.Other
                        defaultType: FileType.Other
                        viewMode: FilePickerViewMode.ListView
                        title: qsTr("Export")
                        onError: {
                            sst.body = qsTr("Unknown error : %1").arg(error)
                            sst.show();
                        }
                        onFileSelected: {
                            console.log("save -- FileSelected signal received : " + selectedFiles);
                            var filepath = selectedFiles[0] + ".galleries";

                            var jsondata = [];
                            for (var i = 0; i < adm.size(); i ++) {
                                jsondata.push(adm.value(i))
                            }
                            var successWrote = _app.writeTextFile(filepath, JSON.stringify(jsondata));
                            if (successWrote) {
                                sst.body = qsTr("Data exported successfully.")
                                sst.show()
                            } else {
                                sst.body = qsTr("Data export error, please ensure \"Shared Files\" permission is granted.")
                                sst.show();
                            }
                        }
                        allowOverwrite: true
                    }
                ]
            }
        ]
        actionBarVisibility: ChromeVisibility.Hidden
        Container {
            Container {
                visible: opdef.selected
                ListView {
                    dataModel: XmlDataModel {
                        source: "asset:///tumblr.xml"
                        id: xdm
                    }
                    onTriggered: {
                        var dataitem = xdm.data(indexPath);
                        console.log(JSON.stringify(dataitem));
                        var sitepage = Qt.createComponent("Site.qml").createObject(navigationPane);
                        sitepage.nav = navigationPane;
                        sitepage.endpoint = dataitem.host;
                        navigationPane.push(sitepage)
                    }
                    function addToFav(obj) {
                        myfavs.add(obj)
                    }
                    function getlastupdate(host, callback) {
                        co.getLastUpdate(host, callback)
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "header"
                            content: Header {
                                title: ListItemData.title
                            }
                        },
                        ListItemComponent {
                            type: "item"
                            Container {
                                id: itemroot
                                WebImageView {
                                    imageSource: "asset:///images/loading.gif"
                                    onCreationCompleted: {
                                        itemroot.ListItem.view.getlastupdate(ListItemData.host, function(j, b, d, posts) {
                                                if (b) {
                                                    url = j
                                                } else {
                                                }
                                            })
                                    }
                                    verticalAlignment: VerticalAlignment.Fill
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    scalingMethod: ScalingMethod.AspectFill
                                }
                                Container {
                                    background: Color.Black
                                    verticalAlignment: VerticalAlignment.Bottom
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    topPadding: 5.0
                                    leftPadding: 5.0
                                    rightPadding: 5.0
                                    bottomPadding: 5.0
                                    opacity: 0.6
                                    Label {
                                        multiline: true
                                        textStyle.fontSize: FontSize.XSmall
                                        textStyle.fontWeight: FontWeight.W100
                                        textStyle.color: Color.White
                                        textFit.mode: LabelTextFitMode.Standard
                                        textStyle.textAlign: TextAlign.Center
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        verticalAlignment: VerticalAlignment.Center
                                        id: itemlabel
                                        text: ListItemData.title
                                        autoSize.maxLineCount: 2
                                    }
                                }

                                contextActions: [
                                    ActionSet {
                                        actions: [
                                            ActionItem {
                                                title: qsTr("View")
                                                imageSource: "asset:///icon/ic_all.png"
                                                onTriggered: {
                                                    itemroot.ListItem.view.triggered(itemroot.ListItem.indexPath)
                                                }
                                            },
                                            ActionItem {
                                                title: qsTr("Add to Favourite")
                                                imageSource: "asset:///icon/ic_add_bookmarks.png"
                                                onTriggered: {
                                                    itemroot.ListItem.view.addToFav(ListItemData)
                                                }
                                            }
                                        ]
                                    }
                                ]
                                layout: DockLayout {

                                }

                            }
                        }
                    ]
                    layout: GridListLayout {
                        columnCount: 4
                        headerMode: ListHeaderMode.Sticky
                        orientation: LayoutOrientation.TopToBottom

                    }
                    bufferedScrollingEnabled: true
                    snapMode: SnapMode.LeadingEdge
                    scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                }
            }

            Container {
                visible: opfav.selected
                onVisibleChanged: {
                    if (visible) {
                        myfavs.load();
                    }
                }
                Header {
                    title: qsTr("My Favourites")
                }
                // FAV START
                ListView {
                    id: myfavs
                    // multi selection
                    multiSelectAction: MultiSelectActionItem {

                    }
                    function getlastupdate(host, callback) {
                        co.getLastUpdate(host, callback)
                    }
                    multiSelectHandler {
                        actions: DeleteActionItem {
                            onTriggered: {
                                var selecteditems = myfavs.selectionList().sort()
                                for (var i = selecteditems.length - 1; i > -1; i --) {
                                    var indexpath = selecteditems[i];
                                    var item = fdm.data(indexpath);
                                    fdm.removeAt(fdm.indexOf(item));
                                }
                            }
                        }
                        status: qsTr("None Selected.")
                        onActiveChanged: {
                            if (active == true) {
                                console.log("Multiple selection mode is enabled.")
                            } else {
                                console.log("Multiple selection mode is disabled.")
                            }
                        }
                    }
                    onSelectionChanged: {
                        if (selectionList().length > 1) {
                            multiSelectHandler.status = selectionList().length + qsTr(" galleries selected")
                        } else if (selectionList().length == 1) {
                            multiSelectHandler.status = qsTr("1 gallery selected");
                        } else {
                            multiSelectHandler.status = qsTr("None selected");
                        }
                    }
                    // end of multiselection
                    dataModel: ArrayDataModel {
                        id: fdm
                        onItemAdded: {
                            sst.body = qsTr("%1 added to Favourites.").arg(fdm.data(indexPath).title)
                            sst.show();
                            myfavs.save();
                        }
                        onItemRemoved: {
                            myfavs.save();
                        }
                    }
                    function save() {
                        var jsondata = [];
                        for (var i = 0; i < fdm.size(); i ++) {
                            jsondata.push(fdm.value(i))
                        }
                        _app.setv('favs', JSON.stringify(jsondata));
                    }
                    function add(obj) {
                        if (fdm.indexOf(obj) > -1) {
                            return;
                        } else {
                            fdm.insert(0, obj);
                        }
                    }
                    onCreationCompleted: {
                        load();
                    }
                    function load() {
                        fdm.clear();
                        var jsondata = _app.getv('favs', '');
                        if (jsondata.length > 0) {
                            jsondata = JSON.parse(jsondata);
                            fdm.append(jsondata)
                        }
                    }
                    function requestDelete(indexPath) {
                        fdm.removeAt(fdm.indexOf(fdm.data(indexPath)));
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ""
                            Container {
                                id: favitem
                                WebImageView {
                                    imageSource: "asset:///images/loading.gif"
                                    onCreationCompleted: {
                                        favitem.ListItem.view.getlastupdate(ListItemData.host, function(j, b, d, posts) {
                                                if (b) {
                                                    url = j
                                                } else {
                                                }
                                            })
                                    }
                                    verticalAlignment: VerticalAlignment.Fill
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    scalingMethod: ScalingMethod.AspectFill
                                }
                                Container {
                                    background: Color.Black
                                    verticalAlignment: VerticalAlignment.Bottom
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    topPadding: 5.0
                                    leftPadding: 5.0
                                    rightPadding: 5.0
                                    bottomPadding: 5.0
                                    opacity: 0.6
                                    Label {
                                        multiline: true
                                        textStyle.fontSize: FontSize.XSmall
                                        textStyle.fontWeight: FontWeight.W100
                                        textStyle.color: Color.White
                                        textFit.mode: LabelTextFitMode.Standard
                                        textStyle.textAlign: TextAlign.Center
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        verticalAlignment: VerticalAlignment.Center
                                        text: ListItemData.title
                                        autoSize.maxLineCount: 2
                                    }
                                }
                                contextActions: [
                                    ActionSet {
                                        title: qsTr("My Favourite")
                                        subtitle: ListItemData.title
                                        actions: [
                                            ActionItem {
                                                title: qsTr("View")
                                                onTriggered: {
                                                    favitem.ListItem.view.triggered(favitem.ListItem.indexPath);
                                                }
                                                imageSource: "asset:///icon/ic_all.png"
                                            },
                                            DeleteActionItem {
                                                onTriggered: {
                                                    favitem.ListItem.view.requestDelete(favitem.ListItem.indexPath)
                                                }
                                            }
                                        ]
                                    }
                                ]
                                layout: DockLayout {

                                }
                            }
                        }
                    ]
                    onTriggered: {
                        var dataitem = fdm.data(indexPath);
                        var sitepage = Qt.createComponent("Site.qml").createObject(navigationPane);
                        sitepage.nav = navigationPane;
                        sitepage.endpoint = dataitem.host;
                        sitepage.enableGif = dataitem.gif;
                        navigationPane.push(sitepage)
                    }
                    layout: GridListLayout {
                        columnCount: 4
                        headerMode: ListHeaderMode.None
                        orientation: LayoutOrientation.TopToBottom
                        cellAspectRatio: 1.0

                    }
                    bufferedScrollingEnabled: true
                    snapMode: SnapMode.LeadingEdge
                    scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                }
                // FAV END
            }
            Container {
                visible: opmine.selected
                onVisibleChanged: {
                    if (visible) {
                        mysites.load();
                    }
                }
                Header {
                    title: qsTr("My Galleries")
                }
                ListView {
                    id: mysites
                    // multi selection
                    multiSelectAction: MultiSelectActionItem {

                    }
                    function getlastupdate(host, callback) {
                        co.getLastUpdate(host, callback)
                    }
                    multiSelectHandler {
                        actions: DeleteActionItem {
                            onTriggered: {
                                var selecteditems = mysites.selectionList().sort()
                                for (var i = selecteditems.length - 1; i > -1; i --) {
                                    var indexpath = selecteditems[i];
                                    var item = adm.data(indexpath);
                                    adm.removeAt(adm.indexOf(item));
                                }
                            }
                        }
                        status: qsTr("None Selected.")
                        onActiveChanged: {
                            if (active == true) {
                                console.log("Multiple selection mode is enabled.")
                            } else {
                                console.log("Multiple selection mode is disabled.")
                            }
                        }
                    }
                    onSelectionChanged: {
                        if (selectionList().length > 1) {
                            multiSelectHandler.status = selectionList().length + qsTr(" galleries selected")
                        } else if (selectionList().length == 1) {
                            multiSelectHandler.status = qsTr("1 gallery selected");
                        } else {
                            multiSelectHandler.status = qsTr("None selected");
                        }
                    }
                    // end of multiselection

                    dataModel: ArrayDataModel {
                        id: adm
                        onItemAdded: {
                            mysites.save();
                        }
                        onItemRemoved: {
                            mysites.save();
                        }
                    }
                    function save() {
                        var jsondata = [];
                        for (var i = 0; i < adm.size(); i ++) {
                            jsondata.push(adm.value(i))
                        }
                        _app.setv('sites', JSON.stringify(jsondata));
                    }
                    function add(obj) {
                        if (adm.indexOf(obj) > -1) {
                            return;
                        } else {
                            adm.insert(0, obj);
                        }
                    }
                    onCreationCompleted: {
                        load();
                    }
                    function load() {
                        adm.clear();
                        var jsondata = _app.getv('sites', '');
                        if (jsondata.length > 0) {
                            jsondata = JSON.parse(jsondata);
                            adm.append(jsondata)
                        }
                    }
                    function requestDelete(indexPath) {
                        adm.removeAt(adm.indexOf(adm.data(indexPath)));
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ""
                            Container {
                                id: siteitem
                                WebImageView {
                                    imageSource: "asset:///images/loading.gif"
                                    onCreationCompleted: {
                                        siteitem.ListItem.view.getlastupdate(ListItemData.host, function(j, b, d, posts) {
                                                if (b) {
                                                    url = j
                                                } else {
                                                }
                                            })
                                    }
                                    verticalAlignment: VerticalAlignment.Fill
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    scalingMethod: ScalingMethod.AspectFill
                                }
                                Container {
                                    background: Color.Black
                                    verticalAlignment: VerticalAlignment.Bottom
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    topPadding: 5.0
                                    leftPadding: 5.0
                                    rightPadding: 5.0
                                    bottomPadding: 5.0
                                    opacity: 0.6
                                    Label {
                                        multiline: true
                                        textStyle.fontSize: FontSize.XSmall
                                        textStyle.fontWeight: FontWeight.W100
                                        textStyle.color: Color.White
                                        textFit.mode: LabelTextFitMode.Standard
                                        textStyle.textAlign: TextAlign.Center
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        verticalAlignment: VerticalAlignment.Center
                                        text: ListItemData.title
                                        autoSize.maxLineCount: 2
                                    }
                                }
                                contextActions: [
                                    ActionSet {
                                        title: qsTr("My Galleries")
                                        subtitle: ListItemData.title
                                        actions: [
                                            ActionItem {
                                                title: qsTr("View")
                                                onTriggered: {
                                                    siteitem.ListItem.view.triggered(siteitem.ListItem.indexPath);
                                                }
                                                imageSource: "asset:///icon/ic_all.png"
                                            },
                                            DeleteActionItem {
                                                onTriggered: {
                                                    siteitem.ListItem.view.requestDelete(siteitem.ListItem.indexPath)
                                                }
                                            }
                                        ]
                                    }
                                ]
                                layout: DockLayout {

                                }
                            }
                        }
                    ]
                    onTriggered: {
                        var dataitem = adm.data(indexPath);
                        var sitepage = Qt.createComponent("Site.qml").createObject(navigationPane);
                        sitepage.nav = navigationPane;
                        sitepage.endpoint = dataitem.host;
                        sitepage.enableGif = dataitem.gif;
                        navigationPane.push(sitepage)
                    }
                    layout: GridListLayout {
                        columnCount: 4
                        headerMode: ListHeaderMode.None
                        orientation: LayoutOrientation.TopToBottom
                        cellAspectRatio: 1.0

                    }
                    bufferedScrollingEnabled: true
                    snapMode: SnapMode.LeadingEdge
                    scrollIndicatorMode: ScrollIndicatorMode.ProportionalBar
                }
            }
        }
    }

}
