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

    // 连接状态面板
    Rectangle {
        id: connectionPanel
        width: parent.width * 0.8
        height: 120
        anchors.bottom: chatPanel.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#f0f0f0"
        radius: 10
        border.color: "#888"
        border.width: 1
        visible: true
        z:100
        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: networkChess.connectionStatus
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                visible: networkChess.connectionStatus === "未连接"

                Button {
                    text: "创建游戏"
                    onClicked: networkChess.createGame()
                }

                Button {
                    text: "加入游戏"
                    onClicked: joinDialog.open()
                }
            }

            Button {
                text: "断开连接"
                visible: networkChess.connectionStatus !== "未连接"
                onClicked: networkChess.disconnectGame()
            }
        }
    }

    // 加入游戏对话框
    // Dialog {
    //     id: joinDialog
    //     title: "加入游戏"
    //     anchors.centerIn: parent
    //     width: parent.width * 0.7
    //     modal: true

    //     Column {
    //         spacing: 20
    //         width: parent.width

    //         TextField {
    //             id: ipInput
    //             width: parent.width
    //             placeholderText: "输入主机IP地址"
    //             inputMethodHints: Qt.ImhFormattedNumbersOnly
    //         }

    //         Button {
    //             text: "连接"
    //             width: parent.width
    //             onClicked: {
    //                 networkChess.joinGame(ipInput.text)
    //                 joinDialog.close()
    //             }
    //         }
    //     }
    // }

    // 加入游戏对话框
    Dialog {
        id: joinDialog
        title: "加入游戏"
        width: parent.width * 0.7
        modal: true

        // 使用固定位置而不是锚点
        x: (parent.width - width) / 2
        y: chatPanel.y - height - 20  // 显示在聊天面板上方20像素处

        Column {
            spacing: 20
            width: parent.width

            TextField {
                id: ipInput
                width: parent.width
                placeholderText: "输入主机IP地址"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            Button {
                text: "连接"
                width: parent.width
                onClicked: {
                    networkChess.joinGame(ipInput.text)
                    joinDialog.close()
                }
            }
        }
    }

    // 棋盘背景 (与本地对战相同)
    Rectangle {
        id: boardBackground
        height: parent.height*0.91
        width:parent.width
        anchors.top:parent.top
        anchors.topMargin: 0
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

        // 胜利动画组件 (与本地对战相同)
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

        // 吃子动画组件 (与本地对战相同)
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
                }
            }
        }

        NetworkBoard {
            id: networkChess
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

                // 执行移动 - 使用正确的参数顺序
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

        // 棋盘绘制 (修复棋盘线问题)
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

        // 九宫斜线 (与本地对战相同)
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

        // 楚河汉界文字 (与本地对战相同)
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

        // 棋子 (与本地对战相同)
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
                console.log("连接状态:", networkChess.connectionStatus);

                // ================= 操作权限校验 =================
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
        color: "#f0f0f0"
        radius: 10
        border.color: "#888"
        border.width: 1
        visible: networkChess.connectionStatus !== "未连接"

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
}
