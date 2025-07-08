// NetworkChessBoard.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Chess
import Qt5Compat.GraphicalEffects

Item {
    id: _networkBoard
    width: stackView.width
    height: stackView.height
    property int square: width/10
    property alias boardLogic: networkChess

    Image {
        source: "qrc:/images/bg.png"
        anchors.fill: parent
    }

    Rectangle {
        id: connectionStatusIndicator
        width: Math.min(parent.width * 0.3, 130)
        height: 30
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        radius: height / 2
        color: "#f0f0f0"
        border.color: "#888"
        border.width: 1

        // 状态指示灯
        Rectangle {
            id: statusLight
            width: 12
            height: 12
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: {
                switch(networkChess.connectionStatus) {
                    case "已连接": return "#4CAF50"; // 绿色
                    case "连接中": return "#FFC107";  // 黄色
                    default: return "#F44336";       // 红色
                }
            }

            // 呼吸动画效果
            SequentialAnimation on opacity {
                running: networkChess.connectionStatus === "连接中"
                loops: Animation.Infinite
                NumberAnimation { from: 0.5; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.0; to: 0.5; duration: 800; easing.type: Easing.InOutQuad }
            }
        }

        // 状态文本
        Text {
            id: statusText
            anchors.left: statusLight.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: networkChess.connectionStatus
            font.pixelSize: 14
            color: "#333"
        }

        // 棋子颜色指示
        Rectangle {
            id: colorIndicator
            width: 16
            height: 16
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            visible: networkChess.connectionStatus === "已连接"
            color: networkChess.myColorIsRed ? "#e53935" : "#212121" // 红方红色，黑方黑色

            // 动画效果
            SequentialAnimation on scale {
                running: networkChess.myTurn && networkChess.connectionStatus === "已连接"
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.2; duration: 500; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.2; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
            }
        }

        // 鼠标悬停提示
        ToolTip {
            id: statusToolTip
            delay: 500
            timeout: 3000
            text: {
                if(networkChess.connectionStatus === "已连接") {
                    return networkChess.myTurn ?
                        (networkChess.myColorIsRed ? "您的回合 (红方)" : "您的回合 (黑方)") :
                        "等待对手走棋...";
                }
                return networkChess.connectionStatus;
            }
        }

        // 鼠标悬停事件
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: statusToolTip.visible = true
            onExited: statusToolTip.visible = false
        }
    }

    //返回按钮
    Button {
        id:_backButton
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 20
        text:"返回首页"
        onClicked: {
            clickAnim.start()//点击动画
            player.click.play()
            stackView.pop()
            stackView.push("HomePage.qml")
        }
        background: Rectangle {
            id:btnBg
            color: _backButton.down ? "#696969":"#808080"
            radius: 5
            border.color: "#696969"
            border.width: 2
        }

        SequentialAnimation {
            id: clickAnim
            PropertyAnimation {
                target: _backButton
                property: "scale"
                to: 1.0
                duration: 500
                easing.type: Easing.OutBack
            }
        }
    }

    // 主菜单对话框
    Dialog {
        id: mainMenuDialog
        title: "联机对战"
        width: parent.width * 0.8
        height: 260
        anchors.centerIn: parent
        modal: true
        visible: networkChess.connectionStatus === "未连接"

        background: Rectangle {
            color: "#f8f8f8"
            radius: 12
            border.color: "#d0d0d0"
            border.width: 1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8
                samples: 16
                color: "#40000000"
            }
        }

        header: Label {
            text: mainMenuDialog.title
            font.pixelSize: 18
            font.bold: true
            color: "#4a6ea9"
            horizontalAlignment: Text.AlignHCenter
            padding: 12
        }

        Column {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 10

            Button {
                width: parent.width
                height: 50
                text: "创建游戏(红方)"
                font.pixelSize: 16
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#d9534f" : "#f56c6c"
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    networkChess.createGame()
                    mainMenuDialog.close()
                    connectionStatusDialog.open()
                }
            }

            Button {
                width: parent.width
                height: 50
                text: "加入游戏(黑方)"
                font.pixelSize: 16
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#5bc0de" : "#67c23a"
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    mainMenuDialog.close()
                    joinDialog.open()
                }
            }

            Button {
                width: parent.width
                height: 50
                text: "取消"
                font.pixelSize: 16
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#6c757d" : "#909399"
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainMenuDialog.close()
            }
        }
    }

    // 连接状态对话框
    Dialog {
        id: connectionStatusDialog
        title: "连接状态"
        width: parent.width * 0.8
        height: 220
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#f8f8f8"
            radius: 12
            border.color: "#d0d0d0"
            border.width: 1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8
                samples: 16
                color: "#40000000"
            }
        }

        header: Label {
            text: connectionStatusDialog.title
            font.pixelSize: 18
            font.bold: true
            color: "#4a6ea9"
            horizontalAlignment: Text.AlignHCenter
            padding: 12
        }

        Column {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 10

            Text {
                width: parent.width
                text: networkChess.connectionStatus
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: "#333"
            }

            Button {
                width: parent.width
                height: 50
                text: "断开连接"
                visible: networkChess.connectionStatus !== "未连接"
                font.pixelSize: 16
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#d9534f" : "#f56c6c"
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    networkChess.disconnectGame()
                    connectionStatusDialog.close()
                    mainMenuDialog.open()
                }
            }

            Button {
                width: parent.width
                height: 50
                text: "关闭"
                font.pixelSize: 16
                background: Rectangle {
                    radius: 6
                    color: parent.down ? "#6c757d" : "#909399"
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: connectionStatusDialog.close()
            }
        }
    }

    // 加入游戏对话框
    Dialog {
        id: joinDialog
        title: "加入游戏"
        width: parent.width * 0.8
        height: 220
        anchors.centerIn: parent
        modal: true

        background: Rectangle {
            color: "#f8f8f8"
            radius: 12
            border.color: "#d0d0d0"
            border.width: 1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8
                samples: 16
                color: "#40000000"
            }
        }

        header: Label {
            text: joinDialog.title
            font.pixelSize: 18
            font.bold: true
            color: "#4a6ea9"
            horizontalAlignment: Text.AlignHCenter
            padding: 12
        }

        Column {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 10

            TextField {
                id: ipInput
                width: parent.width
                height: 50
                placeholderText: "输入主机IP地址 (如: 192.168.1.100)"
                font.pixelSize: 16
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                background: Rectangle {
                    radius: 6
                    color: "#909399"
                    border.color: "#d0d0d0"
                    border.width: 1
                }
            }

            Row {
                width: parent.width
                spacing: 10

                Button {
                    width: parent.width * 0.5 - 5
                    height: 50
                    text: "连接"
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 6
                        color: parent.down ? "#5bc0de" : "#67c23a"
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (ipInput.text.trim() !== "") {
                            networkChess.joinGame(ipInput.text)
                            joinDialog.close()
                            connectionStatusDialog.open()
                        }
                    }
                }

                Button {
                    width: parent.width * 0.5 - 5
                    height: 50
                    text: "取消"
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 6
                        color: parent.down ? "#6c757d" : "#909399"
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        joinDialog.close()
                        mainMenuDialog.open()
                    }
                }
            }
        }
    }

    Text {
        text: "联机对战模式"
        font {
            family: "FZKai\-Z03"
            pixelSize: _networkBoard.width/12
            bold: true
        }
            color: "#696969"
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
    }

    // 棋盘背景
    Rectangle {
        id: boardBackground
        height: parent.height*0.65
        width:parent.width
        anchors.top:parent.top
        anchors.topMargin: 100
        color: "#f0e0d0"
        radius: 50

        Image {
            anchors.fill: parent
            source: "qrc:/images/background.png"
            opacity: 0.3
        }
        clip:true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: boardBackground.width
                height: boardBackground.height
                radius: boardBackground.radius
            }
        }

        // 吃子动画组件
        Component {
            id: captureAnimation
            Rectangle {
                id: captureEffect
                property point startPos
                property bool isGeneral: false
                width: _networkBoard.square
                height: _networkBoard.square
                radius: width / 2
                color: "transparent"
                border.color: isGeneral ? "#FFFF00" : "#FF0000"
                border.width: isGeneral ? 5 : 3
                opacity: 0.8
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -5
                    radius: parent.radius
                    color: "transparent"
                    visible: isGeneral
                    border.color: "#FFFFFF"
                    border.width: 2
                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: isGeneral
                    }
                }
                SequentialAnimation {
                    id: anim
                    running: true
                    ParallelAnimation {
                        NumberAnimation {
                            target: captureEffect
                            property: "scale"
                            from: 1.0
                            to: isGeneral ? 2.0 : 1.5
                            duration: isGeneral ? 500 : 300
                        }
                        NumberAnimation {
                            target: captureEffect
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: isGeneral ? 500 : 300
                        }
                    }
                    ScriptAction {
                        script: captureEffect.destroy()
                    }
                }
                Component.onCompleted: {
                    x = startPos.x - width / 2
                    y = startPos.y - height / 2
                }// 灰色按钮
            }
        }

        NetworkBoard {
            id: networkChess
            onConnectionStatusChanged: {
                //当连接状态变为"已连接"时自动关闭对话框
                if (connectionStatus === "已连接") {
                    connectionStatusDialog.close()
                }
            }
            onGameOver: (winner) => {
                victoryOverlay.winnerText = winner;
                victoryOverlay.visible = true;
                victoryAnimation.start();
                player.success.play();
            }
            onStonesChanged: {
                for (var i = 0; i < networkChess.stones.length; i++) {
                    var stone = networkChess.stones[i];
                    if (stone.dead && !stone._handledDead) {
                        stone._handledDead = true;
                        var startX = (stone.col + 1) * _networkBoard.square
                        var startY = (stone.row + 1) * _networkBoard.square
                        var anim = captureAnimation.createObject(boardBackground, {
                            startPos: Qt.point(startX, startY),
                            isGeneral: (stone.type === Stone.JIANG)
                        });
                        if (stone.type === Stone.JIANG) {
                            createGeneralCaptureEffect(startX, startY, stone.isRed);
                        }
                    }
                }
            }
            onOpponentMoveReceived: (fromCol, fromRow, toCol, toRow) => {
                // 处理对手的移动
                var targetPiece = networkChess.getPieceId(toCol, toRow);
                if (targetPiece !== -1) {
                    player.captureSound.play();
                } else {
                    player.moveSound.play();
                }

                // 执行移动
                if (networkChess.moveStone(fromCol, fromRow, toCol, toRow)) {
                    console.log("对手移动: ", fromCol, fromRow, "->", toCol, toRow);
                }
            }
            onMessageReceived: (message) => {
                chatDisplay.append("对手: " + message);
            }
            function createGeneralCaptureEffect(x, y, isRed) {
                for (var i = 0; i < 3; i++) {
                    (function(index) {
                        var delay = index * 200;
                        var effect = Qt.createComponent("AnimationEffect.qml");
                        if (effect.status === Component.Ready) {
                            var obj = effect.createObject(boardBackground, {
                                centerX: x,
                                centerY: y,
                                effectColor: isRed ? "#ff0000" : "#0000ff",
                                square: _networkBoard.square,
                                delay: delay
                            });
                            if (!obj) {
                                console.error("Failed to create AnimationEffect object");
                            }
                        } else {
                            console.error("Component not ready:", effect.errorString());
                        }
                    })(i);
                }
            }
        }

        // 棋盘绘制
        Canvas {
            id: boardCanvas
            width: parent.width
            height:parent.height
            onPaint: {
                var ctx = getContext("2d")
                var cellSize = width / 9
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#000000"
                ctx.lineWidth = 1

                //横线
                for (var row = 1; row <= 10; row++) {
                    ctx.beginPath()
                    ctx.moveTo(_networkBoard.square, row * _networkBoard.square)
                    ctx.lineTo(9 * _networkBoard.square, row * _networkBoard.square)
                    ctx.stroke()
                }

                //竖线
                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _networkBoard.square, _networkBoard.square)
                    ctx.lineTo(col * _networkBoard.square, 5 * _networkBoard.square)
                    ctx.stroke()
                }

                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _networkBoard.square, 6 * _networkBoard.square)
                    ctx.lineTo(col * _networkBoard.square, 10 * _networkBoard.square)
                    ctx.stroke()
                }

                // 连接上下两部分
                ctx.beginPath()
                ctx.moveTo(_networkBoard.square, 5 * _networkBoard.square)
                ctx.lineTo(_networkBoard.square, 6 * _networkBoard.square)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(9 * _networkBoard.square, 5 * _networkBoard.square)
                ctx.lineTo(9 * _networkBoard.square, 6 * _networkBoard.square)
                ctx.stroke()
            }
        }

        // 九宫斜线
        Canvas {
            id: _palaceCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 2.5;

                //黑方九宫（上）
                ctx.beginPath();
                ctx.moveTo(_networkBoard.square*4, _networkBoard.square);
                ctx.lineTo(_networkBoard.square* 6, _networkBoard.square * 3);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_networkBoard.square* 6, _networkBoard.square);
                ctx.lineTo(_networkBoard.square* 4, _networkBoard.square*3);
                ctx.stroke();

                //红方九宫（下）
                ctx.beginPath();
                ctx.moveTo(_networkBoard.square*4, _networkBoard.square*10);
                ctx.lineTo(_networkBoard.square*6, _networkBoard.square*8);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_networkBoard.square* 6, _networkBoard.square*10);
                ctx.lineTo(_networkBoard.square* 4, _networkBoard.square*8);
                ctx.stroke();
            }
        }

        // 楚河汉界文字
        Text {
            id: riverText
            x:4*_networkBoard.square
            y:5*_networkBoard.square
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "SimHei"
            font.bold: true
            font.pixelSize: Math.max(_networkBoard.square * 0.8, 20)
            text: "楚 河        汉 界"
            color: "#8B4513"
            style: Text.Outline
            styleColor: "#00000011"
        }

        // 棋子
        Repeater {
            model: networkChess.stones
            delegate: ChessPiece {
                centerX: (modelData.col +1)* _networkBoard.square
                centerY: (modelData.row +1)*  _networkBoard.square
                size: _networkBoard.square
                text: {
                    switch(modelData.type) {
                    case Stone.CHE: return "車"
                    case Stone.MA: return "马"
                    case Stone.XIANG: return modelData.isRed ? "相" : "象"
                    case Stone.SHI: return modelData.isRed? "仕" : "士"
                    case Stone.JIANG: return modelData.isRed ? "帅" : "将"
                    case Stone.PAO: return "炮"
                    case Stone.BING: return modelData.isRed ? "兵" : "卒"
                    default: return "?"
                    }
                }
                isRed: modelData.isRed
                selected: modelData.selected
                visible: !modelData.dead
            }
        }

        TapHandler {
            property int selectedPieceId: -1
            property int selectedRow: -1
            property int selectedCol: -1

            onTapped: (event) => {
                // ================= 调试信息输出 =================
                console.log("-----------------------");
                console.log("点击时回合状态:", networkChess.isRedTurn ? "红方回合" : "黑方回合");
                console.log("我的颜色:", networkChess.myColorIsRed ? "红方" : "黑方");
                console.log("当前是否可操作:", networkChess.myTurn ? "是" : "否");
                console.log("操作锁定状态:", networkChess.operationLocked ? "已锁定" : "未锁定");
                console.log("连接状态:", networkChess.connectionStatus);

                // ================= 操作权限校验 =================
                if (networkChess.operationLocked) {
                    console.log("操作被锁定：等待对手走棋...");
                    return;
                }

                if (!networkChess.myTurn) {
                    console.error("操作被拒绝：不是你的回合！");
                    return;
                }

                if (networkChess.connectionStatus === "未连接") {
                    console.error("操作被拒绝：未连接到对手");
                    return;
                }

                // ================= 获取点击位置 =================
                var pos = networkChess.clickPosition(square, event.position.x, event.position.y);
                var boardCol = pos.x - 1;
                var boardRow = pos.y - 1;

                console.log("点击坐标:", `(${boardCol},${boardRow})`);

                // ================= 清除所有选中状态 =================
                for (var i = 0; i < networkChess.stones.length; i++) {
                    networkChess.stones[i].selected = false;
                }

                // ================= 获取点击的棋子信息 =================
                var hasPiece = networkChess.isPiece(boardCol, boardRow);
                var pieceId = hasPiece ? networkChess.getPieceId(boardCol, boardRow) : -1;
                var piece = hasPiece ? networkChess.getStoneById(pieceId) : null;

                if (hasPiece) {
                    console.log("点击棋子 - ID:", pieceId,
                               "类型:", piece.type,
                               "颜色:", piece.isRed ? "红" : "黑",
                               "死亡状态:", piece.dead);
                }

                // ================= 点击逻辑处理 =================
                if (hasPiece) {
                    // 情况1：当前没有选中棋子
                    if (selectedPieceId === -1) {
                        // 检查是否是自己颜色的棋子
                        if ((piece.isRed && networkChess.myColorIsRed) ||
                            (!piece.isRed && !networkChess.myColorIsRed)) {

                            selectedPieceId = pieceId;
                            selectedCol = boardCol;
                            selectedRow = boardRow;
                            piece.selected = true;

                            console.log("成功选中棋子:", pieceId);
                        } else {
                            console.log("操作被拒绝：不能选中对方棋子");
                        }
                    }
                    // 情况2：当前已有选中棋子
                    else {
                        var selectedPiece = networkChess.getStoneById(selectedPieceId);

                        // 情况2.1：点击同一棋子（取消选中）
                        if (selectedPieceId === pieceId) {
                            selectedPieceId = -1;
                            console.log("取消选中当前棋子");
                        }
                        // 情况2.2：点击己方其他棋子（切换选中）
                        else if (piece.isRed === selectedPiece.isRed) {
                            selectedPiece.selected = false;
                            piece.selected = true;
                            selectedPieceId = pieceId;
                            selectedCol = boardCol;
                            selectedRow = boardRow;
                            console.log("切换选中到新棋子:", pieceId);
                        }
                        // 情况2.3：点击敌方棋子（尝试吃子）
                        else {
                            console.log("尝试吃子: 从(", selectedCol, selectedRow, ")到(", boardCol, boardRow, ")");

                            if (networkChess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                                networkChess.sendMove(selectedCol, selectedRow, boardCol, boardRow);
                                player.captureSound.play();
                                selectedPieceId = -1;
                                console.log("吃子成功");
                            } else {
                                console.log("吃子失败：不符合规则");
                            }
                        }
                    }
                }
                // 点击空白位置（尝试移动）
                else if (selectedPieceId !== -1) {
                    console.log("尝试移动: 从(", selectedCol, selectedRow, ")到(", boardCol, boardRow, ")");

                    if (networkChess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                        networkChess.sendMove(selectedCol, selectedRow, boardCol, boardRow);
                        player.moveSound.play();
                        selectedPieceId = -1;
                        console.log("移动成功");
                    } else {
                        console.log("移动失败：不符合规则");
                    }
                }
            }

            // ================= 选中状态可视化 =================
            onSelectedPieceIdChanged: {
                if (selectedPieceId !== -1) {
                    var piece = networkChess.getStoneById(selectedPieceId);
                    if (piece) {
                        piece.selected = true;
                    }
                }
            }
        }
    }

    // 聊天面板
    Rectangle {
        id: chatPanel
        width: parent.width * 0.8
        height: 200
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#f8f8f8"
        radius: 11
        border.color: "#d0d0d0"
        border.width: 1
        visible: networkChess.connectionStatus !== "未连接"

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8
            samples: 16
            color: "#40000000"
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            ScrollView {
                width: parent.width
                height: parent.height - 50
                clip: true

                TextArea {
                    id: chatDisplay
                    width: parent.width
                    readOnly: true
                    wrapMode: Text.Wrap
                    font.pixelSize: 14
                    color: "#333"
                    background: Rectangle {
                    color: "transparent"
                }

                // 自定义消息样式
                textFormat: TextEdit.RichText
                onTextChanged: {
                // 自动滚动到底部
                chatDisplay.cursorPosition = chatDisplay.length
                }
            }
       }

            Row {
                width: parent.width
                spacing: 10

                TextField {
                    id: chatInput
                    width: parent.width - 80
                    placeholderText: "输入消息..."
                }

                // 按Enter键发送消息
                Keys.onReturnPressed: {
                    if (chatInput.text.trim() !== "") {
                        networkChess.sendMessage(chatInput.text);
                        chatDisplay.append("我: " + chatInput.text);
                        chatInput.clear();
                    }
                }

                Button {
                    width: 70
                    text: "发送"
                    onClicked: {
                        if (chatInput.text.trim() !== "") {
                            networkChess.sendMessage(chatInput.text);
                            chatDisplay.append("我: " + chatInput.text);
                            chatInput.clear();
                        }
                    }
                }
            }
        }
    }

    // 胜利动画组件
    Rectangle {
        id: victoryOverlay
        anchors.fill: parent
        color: "#80000000"
        visible: false
        z: 100

        property string winnerText: ""
        property color winnerColor: winnerText === "红方" ? "#ff0000" : "#0000ff"

        Item {
            anchors.centerIn: parent
            Text {
                id: glowText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: _networkBoard.width*0.1
                font.bold: true
                color: victoryOverlay.winnerColor
                opacity: 0.7
            }
            Text {
                id: victoryText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: _networkBoard.width*0.1
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "#40000000"
            }
        }

        SequentialAnimation {
            id: victoryAnimation
            running: false
            NumberAnimation {
                target: victoryOverlay
                property: "opacity"
                from: 0
                to: 1
                duration: 1000
            }
            ParallelAnimation {
                loops: Animation.Infinite
                SequentialAnimation {
                    NumberAnimation {
                        target: victoryText
                        property: "scale"
                        from: 1.0
                        to: 1.1
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: victoryText
                        property: "scale"
                        from: 1.1
                        to: 1.0
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                SequentialAnimation {
                    ColorAnimation {
                        targets: [victoryText, glowText]
                        property: "color"
                        from: "white"
                        to: victoryOverlay.winnerColor
                        duration: 1000
                    }
                    ColorAnimation {
                        targets: [victoryText, glowText]
                        property: "color"
                        from: victoryOverlay.winnerColor
                        to: "white"
                        duration: 1000
                    }
                }
            }
        }
    }
}
