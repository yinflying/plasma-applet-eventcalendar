import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

Item {
	// width: 888
	width: 60 + 430
	height: 620
	// anchors.fill: parent

	// width: 60
	// width: 430
	// height: 620

	SidebarMenu {
		id: sidebarMenu
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom

		Rectangle {
			anchors.fill: parent
			color: "#000"
			// color: sidebarMenu.open ? "#000" : "transparent"
			opacity: sidebarMenu.open ? 1 : 0.5
		}

		Column {
			width: parent.width
			height: childrenRect.height

			SidebarItem {
				iconName: 'open-menu-symbolic'
				text: "Menu"
				closeOnClick: false
				onClicked: sidebarMenu.open = !sidebarMenu.open
			}
			SidebarItem {
				iconName: 'view-sort-ascending-symbolic'
				text: "Apps"
				onClicked: appsView.show()
			}
			SidebarItem {
				iconName: 'search'
				text: "Search"
				onClicked: searchResultsView.showDefaultSearch()
			}
		}
		Column {
			width: parent.width
			height: childrenRect.height
			anchors.bottom: parent.bottom

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				onClicked: KCMShell.open("user_manager")
				visible: KCMShell.authorize("user_manager.desktop").length > 0
			}
			SidebarItem {
				iconName: 'folder-open-symbolic'
				text: "File Manager"
				onClicked: appsModel.launch('org.kde.dolphin')
			}
			SidebarItem {
				iconName: 'configure'
				text: "Settings"
				onClicked: appsModel.launch('systemsettings')
			}

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				text: "Power"
				onClicked: powerMenu.visible = !powerMenu.visible

				SidebarContextMenu {
					id: powerMenu
					model: appsModel.powerActionsModel
				}
			}
		}
	}


	Item {
		anchors.fill: parent
		anchors.bottomMargin: panelSearchBox.height

		SearchResultsView {
			id: searchResultsView
			visible: false
			// width: 430
			// anchors.top: parent.top
			// anchors.right: parent.right
			// anchors.bottom: parent.bottom

			Connections {
				target: search
				onQueryChanged: {
					if (search.query.length > 0 && stackView.currentItem != searchResultsView) {
						stackView.push(searchResultsView, true);
					}
				}
			}

			onVisibleChanged: {
				if (!visible) { // !stackView.currentItem
					search.query = ""
				}
			}

			function showDefaultSearch() {
				if (stackView.currentItem != searchResultsView) {
					stackView.push(searchResultsView, true)
				}
				search.applyDefaultFilters()
			}
		}

		// Item {
		// 	id: appListView
		// 	visible: false
		// 	// Rectangle {
		// 	// 	anchors.fill: parent
		// 	// 	anchors.margins: units.largeSpacing
		// 	// 	color: "transparent"
		// 	// 	border.color: "#111"

		// 	// 	PlasmaComponents.Label {
		// 	// 		anchors.centerIn: parent
		// 	// 		text: "App List View"
		// 	// 		// wrapMode: Text.Wrap
		// 	// 		// width: implicitWidth
		// 	// 	}
		// 	// }


		// }
		
		AppsView {
			id: appsView
			visible: false

			function show() {
				if (stackView.currentItem != appsView) {
					stackView.push(appsView, true)
				}
			}
		}

		StackView {
			id: stackView
			width: 430
			clip: true
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			initialItem: appsView

			delegate: StackViewDelegate {
				pushTransition: StackViewTransition {
					PropertyAnimation {
						target: enterItem
						property: "y"
						from: stackView.height
						to: 0
					}
					PropertyAnimation {
						target: exitItem
						property: "opacity"
						from: 1
						to: 0
					}
				}
				
				function transitionFinished(properties) {
					properties.exitItem.opacity = 1
				}
			}
		}
	}


	SearchField {
		id: panelSearchBox
		// width: 430
		height: 50
		anchors.leftMargin: 60
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
	}
}