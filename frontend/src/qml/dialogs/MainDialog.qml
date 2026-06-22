import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: mainDialog
    title: qsTr("Main Dialog")
    modal: true
    standardButtons: DialogButtonBox.Cancel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            text: qsTr("Welcome to AutoWeChat!")
            font.pointSize: 16
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: qsTr("Start WeChat")
            Layout.alignment: Qt.AlignHCenter
            onClicked: {}
        }
    }
}
