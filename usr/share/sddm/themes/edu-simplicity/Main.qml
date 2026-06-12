import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0
import "SimpleControls" as Simple

Item {
    id: root

    readonly property color backgroundColor: Qt.rgba(0, 0, 0, 0.4)
    readonly property color hoverBackgroundColor: Qt.rgba(0, 0, 0, 0.6)

    // Base font size for all controls — bumped for low-vision readability.
    // Backgrounds use implicitHeight: 30 as a floor, so controls grow to fit.
    readonly property int fontSize: 16

    width: 1920
    height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Repeater {
        model: screenModel
        SceneBackground {
            x: geometry.x; y: geometry.y
            width: geometry.width; height: geometry.height
            sceneBackgroundType: "image"
            sceneBackgroundImage: Qt.resolvedUrl("images/background.jpg")
        }
    }

    TextConstants { id: textConstants }
    
    Connections {
        target: sddm
        
        function onLoginSucceeded() {}
        
        function onLoginFailed() {
            pw_entry.clear()
            pw_entry.focus = true
            
            errorMsgContainer.visible = true
        }
    }
    
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Simple.ComboBox {
            id: user_entry
            model: userModel
            currentIndex: userModel.lastIndex
            textRole: "realName"
            font.pointSize: root.fontSize
            width: 250
            KeyNavigation.backtab: session
            KeyNavigation.tab: pw_entry
        }

        TextField {
            id: pw_entry
            color: "white"
            echoMode: TextInput.Password
            focus: true
            font.pointSize: root.fontSize
            placeholderText: textConstants.promptPassword
            width: 250
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 30
                color: pw_entry.activeFocus ? hoverBackgroundColor : backgroundColor
                border.color: Qt.rgba(1, 1, 1, 0.4)
                radius: 3
            }
            onAccepted: sddm.login(user_entry.getValue(), pw_entry.text, session.currentIndex)
            KeyNavigation.backtab: user_entry
            KeyNavigation.tab: loginButton
        }

        Simple.Button {
            id: loginButton
            text: textConstants.login
            font.pointSize: root.fontSize
            width: 250
            onClicked: sddm.login(user_entry.getValue(), pw_entry.text, session.currentIndex)
            KeyNavigation.backtab: pw_entry
            KeyNavigation.tab: suspend
        }
        
        Rectangle {
            id: errorMsgContainer
            width: 250
            height: loginButton.height
            color: "#F44336"
            clip: true
            visible: false
            radius: 3
            
            Label {
                anchors.centerIn: parent
                text: textConstants.loginFailed
                width: 240
                color: "white"
                font.pointSize: root.fontSize
                font.bold: true
                elide: Qt.locale().textDirection == Qt.RightToLeft ? Text.ElideLeft : Text.ElideRight
                horizontalAlignment: Qt.AlignHCenter
            }
        }

    }

    Row {
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 5
        
        Simple.Button {
            id: suspend
            text: textConstants.suspend
            font.pointSize: root.fontSize
            onClicked: sddm.suspend()
            visible: sddm.canSuspend
            KeyNavigation.backtab: loginButton
            KeyNavigation.tab: hibernate
        }

        Simple.Button {
            id: hibernate
            text: textConstants.hibernate
            font.pointSize: root.fontSize
            onClicked: sddm.hibernate()
            visible: sddm.canHibernate
            KeyNavigation.backtab: suspend
            KeyNavigation.tab: restart
        }
        
        Simple.Button {
            id: restart
            text: textConstants.reboot
            font.pointSize: root.fontSize
            onClicked: sddm.reboot()
            visible: sddm.canReboot
            KeyNavigation.backtab: suspend; KeyNavigation.tab: shutdown
        }
        
        Simple.Button {
            id: shutdown
            text: textConstants.shutdown
            font.pointSize: root.fontSize
            onClicked: sddm.powerOff()
            visible: sddm.canPowerOff
            KeyNavigation.backtab: restart; KeyNavigation.tab: session
        }
    }

    Simple.ComboBox {
        id: session
        anchors {
            left: parent.left
            leftMargin: 10
            top: parent.top
            topMargin: 10
        }
        currentIndex: sessionModel.lastIndex
        model: sessionModel
        textRole: "name"
        font.pointSize: root.fontSize
        width: 200
        visible: sessionModel.rowCount() > 1
        KeyNavigation.backtab: shutdown
        KeyNavigation.tab: user_entry
    }

    Rectangle {
        id: timeContainer
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 10
            rightMargin: 10
        }
        border.color: Qt.rgba(1, 1, 1, 0.4)
        radius: 3
        color: backgroundColor
        width: timelb.width + 10
        height: session.height

        Label {
            id: timelb
            anchors.centerIn: parent
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: "white"
            font.pointSize: root.fontSize
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }
}
