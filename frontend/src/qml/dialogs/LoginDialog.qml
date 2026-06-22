import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginDialog
    width: 400
    height: 200

    signal loginSuccess

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        TextField {
            id: usernameField
            placeholderText: qsTr("Username")
            Layout.fillWidth: true
        }

        TextField {
            id: passwordField
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Login")
            Layout.alignment: Qt.AlignRight
            onClicked: {
                loginDialog.loginSuccess();
            }
        }
    }
}
