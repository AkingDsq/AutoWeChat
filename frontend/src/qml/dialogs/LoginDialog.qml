import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: loginDialog

    // ==================== 信号 ====================
    // 登录成功信号 — Main.qml 监听此信号切换至主界面
    signal loginSuccess

    // ==================== 微信主题色定义 ====================
    QtObject {
        id: w
        // 主色
        readonly property color green: "#07C160"
        readonly property color greenDark: "#06AD56"
        readonly property color greenHover: "#06AD56"
        // 背景
        readonly property color white: "#FFFFFF"
        readonly property color bg: "#F5F5F5"
        readonly property color avatarBg: "#E8E8E8"
        // 边框
        readonly property color border: "#D9D9D9"
        readonly property color borderFocus: "#07C160"
        // 文字
        readonly property color textPrimary: "#333333"
        readonly property color textSecondary: "#999999"
        readonly property color placeholder: "#C0C0C0"
        readonly property color link: "#576B95"
        // 状态
        readonly property color error: "#FA5151"
        // 尺寸
        readonly property int fontSize: 14
        readonly property int fontSizeSmall: 12
        readonly property int fontSizeLarge: 16
        readonly property int radius: 4
        readonly property int cardRadius: 8
        readonly property int cardWidth: 300
        readonly property int fieldWidth: 260
        readonly property int fieldHeight: 40
    }

    // ==================== 全屏背景 ====================
    Rectangle {
        anchors.fill: parent
        color: w.bg
    }

    // ==================== 卡片容器（含阴影） ====================
    Item {
        width: w.cardWidth
        height: loginCard.height
        anchors.centerIn: parent

        // 手动阴影（偏移半透明矩形，无需额外 Qt 模块）
        Rectangle {
            anchors.fill: loginCard
            anchors.leftMargin: 3
            anchors.topMargin: 3
            radius: w.cardRadius
            color: "#18000000"
        }

        // 登录卡片主体
        Rectangle {
            id: loginCard
            width: w.cardWidth
            height: cardLayout.implicitHeight + 40  // 上下各20px内边距
            color: w.white
            radius: w.cardRadius

            ColumnLayout {
                id: cardLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 0

                // ---- 头像区域 ----
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.bottomMargin: 24
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 6
                    color: w.avatarBg
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "qrc:/ui/head_1.jpg"
                        fillMode: Image.PreserveAspectCrop
                        // 头像加载失败时的占位
                        asynchronous: true
                    }
                }

                // ---- 用户名输入区域 ----
                Rectangle {
                    id: usernameWrapper
                    Layout.preferredWidth: w.fieldWidth
                    Layout.preferredHeight: w.fieldHeight
                    Layout.alignment: Qt.AlignHCenter
                    color: w.white
                    border.color: usernameField.activeFocus ? w.borderFocus : w.border
                    border.width: 1
                    radius: w.radius

                    // 用户图标前缀
                    Image {
                        id: userIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/ui/contact_list.png"
                        width: 16
                        height: 16
                    }

                    // 用户名输入框
                    TextField {
                        id: usernameField
                        anchors.left: userIcon.right
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        background: null
                        font.pixelSize: w.fontSize
                        placeholderText: qsTr("Username")
                        placeholderTextColor: w.placeholder
                        color: w.textPrimary
                        leftPadding: 0
                        rightPadding: 0
                        selectByMouse: true
                    }
                }

                // 字段间距
                Item {
                    Layout.preferredHeight: 16
                }

                // ---- 密码输入区域 ----
                Rectangle {
                    id: passwordWrapper
                    Layout.preferredWidth: w.fieldWidth
                    Layout.preferredHeight: w.fieldHeight
                    Layout.alignment: Qt.AlignHCenter
                    color: w.white
                    border.color: passwordField.activeFocus ? w.borderFocus : w.border
                    border.width: 1
                    radius: w.radius

                    // 密码输入框
                    TextField {
                        id: passwordField
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.right: eyeIcon.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        background: null
                        font.pixelSize: w.fontSize
                        echoMode: TextInput.Password
                        placeholderText: qsTr("Password")
                        placeholderTextColor: w.placeholder
                        color: w.textPrimary
                        leftPadding: 0
                        rightPadding: 0
                        selectByMouse: true
                    }

                    // 密码可见性切换按钮
                    Image {
                        id: eyeIcon
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        source: passwordField.echoMode === TextInput.Password ? "qrc:/ui/unvisible.png" : "qrc:/ui/visible.png"
                        width: 18
                        height: 18

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                passwordField.echoMode = passwordField.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password;
                            }
                        }
                    }
                }

                // 按钮间距
                Item {
                    Layout.preferredHeight: 24
                }

                // ---- 登录按钮 ----
                Button {
                    id: loginButton
                    Layout.preferredWidth: w.fieldWidth
                    Layout.preferredHeight: 44
                    Layout.alignment: Qt.AlignHCenter

                    text: qsTr("Log In")
                    font.pixelSize: w.fontSizeLarge
                    font.bold: true

                    // 微信绿背景
                    background: Rectangle {
                        radius: w.radius
                        color: loginButton.pressed ? w.greenDark : (loginButton.hovered ? w.greenHover : w.green)
                    }

                    // 白色文字
                    contentItem: Text {
                        text: loginButton.text
                        font: loginButton.font
                        color: w.white
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 输入校验：空值检查 + 红色边框提示
                        var hasError = false;

                        if (usernameField.text.trim() === "") {
                            usernameWrapper.border.color = w.error;
                            hasError = true;
                            resetUsernameBorder.start();
                        }

                        if (passwordField.text === "") {
                            passwordWrapper.border.color = w.error;
                            hasError = true;
                            resetPasswordBorder.start();
                        }

                        if (!hasError) {
                            loginDialog.loginSuccess();
                        }
                    }
                }

                // 选项间距
                Item {
                    Layout.preferredHeight: 16
                }

                // ---- 选项行：自动登录 / 记住密码 ----
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: w.fieldWidth
                    spacing: 20

                    CheckBox {
                        id: autoLoginBox
                        text: qsTr("Auto Login")
                        font.pixelSize: w.fontSizeSmall

                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            x: autoLoginBox.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 2
                            border.color: autoLoginBox.checked ? w.green : w.border
                            border.width: autoLoginBox.checked ? 0 : 1
                            color: autoLoginBox.checked ? w.green : w.white

                            Text {
                                anchors.centerIn: parent
                                text: "✓"            // ✓ 勾选符号
                                color: w.white
                                font.pixelSize: 11
                                visible: autoLoginBox.checked
                            }
                        }
                    }

                    CheckBox {
                        id: rememberBox
                        text: qsTr("Remember")
                        font.pixelSize: w.fontSizeSmall

                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            x: rememberBox.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 2
                            border.color: rememberBox.checked ? w.green : w.border
                            border.width: rememberBox.checked ? 0 : 1
                            color: rememberBox.checked ? w.green : w.white

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: w.white
                                font.pixelSize: 11
                                visible: rememberBox.checked
                            }
                        }
                    }
                }

                // ---- 弹性填充 + 注册链接 ----
                Item {
                    Layout.fillHeight: true
                    Layout.preferredHeight: 20
                }

                Text {
                    text: qsTr("Register Account")
                    color: w.link
                    font.pixelSize: w.fontSizeSmall
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 8

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked:
                        // TODO: 切换到注册页面 (Phase 1)
                        {}
                    }
                }
            }
        }
    }

    // ==================== 输入错误恢复定时器 ====================
    // 输入为空时边框变红，2 秒后恢复为正常颜色
    Timer {
        id: resetUsernameBorder
        interval: 2000
        onTriggered: {
            usernameWrapper.border.color = usernameField.activeFocus ? w.borderFocus : w.border;
        }
    }

    Timer {
        id: resetPasswordBorder
        interval: 2000
        onTriggered: {
            passwordWrapper.border.color = passwordField.activeFocus ? w.borderFocus : w.border;
        }
    }
}
