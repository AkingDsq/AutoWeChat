import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import WeChatClient 1.0

ApplicationWindow {
    id: window
    width: 400
    height: 540
    visible: true
    title: qsTr("AutoWeChat")

    Loader {
        id: mainLoader
        anchors.fill: parent
        source: "dialogs/LoginDialog.qml"
    }

    Connections {
        target: mainLoader.item        // 指向当前加载的页面
        enabled: mainLoader.status === Loader.Ready   // 确保已加载

        function onLoginSuccess() {
            // 登录成功后切换至主界面
            mainLoader.source = "dialogs/MainDialog.qml";
        }
    }
}
