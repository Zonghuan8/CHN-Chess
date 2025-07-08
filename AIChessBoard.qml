import QtQuick
import QtQuick.Controls
import Chess
import Qt5Compat.GraphicalEffects

Item {
    id: _aiBoard
    width: stackView.width//parent是stackView
    height: stackView.height
    property int square: _aiBoard.width/10
    property alias boardLogic: chess

    AIGameBoard {
         id: chess
         aiIsRed: false
         aiLevel: 1
     }

    Timer {
        id: aiTimer
        interval: 100
        onTriggered: {
            if (!chess.isGameOver() &&
                ((chess.isRedTurn && chess.aiIsRed) ||
                 (!chess.isRedTurn && !chess.aiIsRed))) {
                chess.computerMove()
            }
        }
    }

    //移动动画组件
    Component {
        id: moveAnimation

        Item {
            property Stone piece
            property real fromX
            property real fromY
            property real toX
            property real toY
            property int toCol//添加目标列坐标
            property int toRow//添加目标行坐标
            property int killId

            NumberAnimation on fromX {
                id: xAnim
                from: fromX
                to: toX
                duration: 500
            }

            NumberAnimation on fromY {
                id: yAnim
                from: fromY
                to: toY
                duration: 500
            }

            function start() {
                xAnim.start();
                yAnim.start();
            }

            onToXChanged: {
                piece.col = toCol;
                piece.row = toRow;

                //处理吃子
                if (killId !== -1) {
                    var killedPiece = boardLogic.getStoneById(killId);
                    if (killedPiece) {
                        killedPiece.dead = true;
                        player.captureSound.play()
                    }
                }
            }
        }
    }

    //胜利动画组件
    Rectangle {
        id: victoryOverlay
        anchors.fill: parent
        color: "#80000000" //半透明黑色
        visible: false
        z: 100 //确保在最上层

        property string winnerText: ""
        property color winnerColor: winnerText === "红方" ? "#ff0000" : "#0000ff"

        // 胜利文本容器
        Item {
            anchors.centerIn: parent

            //发光效果：使用多个文本层
            Text {
                id: glowText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: _aiBoard.width*0.1
                font.bold: true
                color: victoryOverlay.winnerColor
                opacity: 0.7
            }

            //主文本
            Text {
                id: victoryText
                anchors.centerIn: parent
                text: victoryOverlay.winnerText + "胜利!"
                font.pixelSize: _aiBoard.width*0.1
                font.bold: true
                color: "white"
                style: Text.Outline
                styleColor: "#40000000"
            }
        }

        //进入动画
        SequentialAnimation {
            id: victoryAnimation
            running: false

            //淡入
            NumberAnimation {
                target: victoryOverlay
                property: "opacity"
                from: 0
                to: 1
                duration: 1000
            }

            //文字跳动
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

                //颜色变化
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

    //棋盘背景
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
        //设置图片为圆角
        clip:true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: boardBackground.width
                height: boardBackground.height
                radius: boardBackground.radius
            }
        }


        Component {
            id: captureAnimation

            Rectangle {
                id: captureEffect
                property point startPos
                property bool isGeneral: false //是否是将/帅

                width: _aiBoard.square
                height: _aiBoard.square
                radius: width / 2
                color: "transparent"
                border.color: isGeneral ? "#FFFF00" : "#FF0000" //将军特殊颜色
                border.width: isGeneral ? 5 : 3
                opacity: 0.8

                //将军特殊效果：使用旋转矩形
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
                            to: isGeneral ? 2.0 : 1.5 //将军放大更多
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

        Connections {
            target: boardLogic

            function onGameOver(winner) {
                victoryOverlay.winnerText = winner;
                victoryOverlay.visible = true;
                victoryAnimation.start();
                if(victoryOverlay.winnerText=="红方")
                {
                   player.success.play();
                }
                else{
                    player.fail.play();
                }

                aiTimer.stop();
            }

            function onStonesChanged() {
                for (var i = 0; i < boardLogic.stones.length; i++) {
                    var stone = boardLogic.stones[i];
                    if (stone.dead && !stone._handledDead) {
                        stone._handledDead = true;
                        var startX = (stone.col + 1) * _aiBoard.square;
                        var startY = (stone.row + 1) * _aiBoard.square;
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

            function onComputerMoved(moveId, fromCol, fromRow, toCol, toRow, killId) {
                boardBackground.createMoveAnimation(moveId, fromCol, fromRow, toCol, toRow, killId);
            }
            //将军被吃的特殊效果
            function createGeneralCaptureEffect(x, y, isRed) {
                //多个圆形扩散效果
                for (var i = 0; i < 3; i++) {
                    (function(index) {
                        var delay = index * 200;

                        //创建AnimationEffect实例
                        var effect = Qt.createComponent("AnimationEffect.qml");
                        if (effect.status === Component.Ready) {
                            var obj = effect.createObject(boardBackground, {
                                                              centerX: x,
                                                              centerY: y,
                                                              effectColor: isRed ? "#ff0000" : "#0000ff",
                                                              square: _aiBoard.square,
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

        //移动动画函数
        function createMoveAnimation(moveId, fromCol, fromRow, toCol, toRow, killId) {
            //查找移动的棋子
            var piece = null;
            for (var i = 0; i < boardLogic.stones.length; i++) {
                if (boardLogic.stones[i].id === moveId) {
                    piece = boardLogic.stones[i];
                    break;
                }
            }

            if (!piece) return;

            //创建动画
            var anim = moveAnimation.createObject(boardBackground, {
                piece: piece,
                fromX: (fromCol + 1) * _aiBoard.square,
                fromY: (fromRow + 1) * _aiBoard.square,
                toX: (toCol + 1) * _aiBoard.square,
                toY: (toRow + 1) * _aiBoard.square,
                toCol: toCol,   //传递目标列坐标
                toRow: toRow,   //传递目标行坐标
                killId: killId
            });
            anim.start();
            player.moveSound.play()
        }


        Canvas {
            id: boardCanvas
            width: parent.width
            height: parent.height
            onPaint: {
                var ctx = getContext("2d")
                var cellSize = width / 9

                ctx.clearRect(0, 0, width, height)

                //绘制网格线
                ctx.strokeStyle = "#000000"
                ctx.lineWidth = 1

                //横线
                for (var row = 1; row <= 10; row++) {
                    ctx.beginPath()
                    ctx.moveTo(_aiBoard.square, _aiBoard.square * row)
                    ctx.lineTo(9*_aiBoard.square, _aiBoard.square * row)
                    ctx.stroke()
                }

                //竖线
                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _aiBoard.square, _aiBoard.square)
                    ctx.lineTo(col * _aiBoard.square, _aiBoard.square * 5) //上半部分
                    ctx.stroke()
                }

                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _aiBoard.square, 6 * _aiBoard.square)
                    ctx.lineTo(col * _aiBoard.square, 10 * _aiBoard.square)
                    ctx.stroke()
                }

                ctx.beginPath()
                ctx.moveTo(_aiBoard.square, _aiBoard.square * 5)
                ctx.lineTo(_aiBoard.square, 6 * _aiBoard.square)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(9 * _aiBoard.square, _aiBoard.square * 5)
                ctx.lineTo(9 * _aiBoard.square, 6 * _aiBoard.square)
                ctx.stroke()
            }
        }

        //绘制九宫斜线
        Canvas {
            id: _palaceCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 2.5;

                //黑方九宫（上）
                ctx.beginPath();
                ctx.moveTo(_aiBoard.square * 4, _aiBoard.square);
                ctx.lineTo(_aiBoard.square * 6, _aiBoard.square * 3);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_aiBoard.square * 6, _aiBoard.square);
                ctx.lineTo(_aiBoard.square * 4, _aiBoard.square * 3);
                ctx.stroke();

                //红方九宫（下）
                ctx.beginPath();
                ctx.moveTo(_aiBoard.square * 4, _aiBoard.square * 10);
                ctx.lineTo(_aiBoard.square * 6, _aiBoard.square * 8);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_aiBoard.square * 6, _aiBoard.square * 10);
                ctx.lineTo(_aiBoard.square * 4, _aiBoard.square * 8);
                ctx.stroke();
            }
        }

        Text {
            id: riverText
            x: 4 * _aiBoard.square
            y: 5 * _aiBoard.square

            anchors.horizontalCenter: parent.horizontalCenter

            font.family: "SimHei"
            font.bold: true
            font.pixelSize: Math.max(_aiBoard.square * 0.8, 20)
            text: "楚 河        汉 界"
            color: "#8B4513"

            style: Text.Outline
            styleColor: "#00000011"
        }

        Repeater {
            model: boardLogic.stones
            delegate: ChessPiece {
                centerX: (modelData.col + 1) * _aiBoard.square
                centerY: (modelData.row + 1) * _aiBoard.square
                size: _aiBoard.square
                text: {
                    switch (modelData.type) {
                    case Stone.CHE: return "車"
                    case Stone.MA: return "马"
                    case Stone.XIANG: return modelData.isRed ? "象" : "相"
                    case Stone.SHI: return modelData.isRed ? "仕" : "仕"
                    case Stone.JIANG: return modelData.isRed ? "将" : "帅"
                    case Stone.PAO: return "炮"
                    case Stone.BING: return modelData.isRed ? "卒" : "兵"
                    default: return "?"
                    }
                }
                isRed: modelData.isRed
                selected: modelData.selected //绑定到Stone的selected属性
                visible: !modelData.dead //死亡棋子不可见
            }
        }

        TapHandler {
            property int selectedPieceId: -1
            property int selectedRow: -1
            property int selectedCol: -1

            onTapped: (event) => {
                console.log("点击事件触发");

                // 游戏结束检查
                if (victoryOverlay.visible) {
                    console.log("游戏已结束，忽略点击");
                    return;
                }

                // AI回合检查
                var isAITurn = (chess.isRedTurn && chess.aiIsRed) || (!chess.isRedTurn && !chess.aiIsRed);
                if (isAITurn) {
                    console.log("AI回合，忽略玩家点击");
                    return;
                }

                if (!chess) {
                    console.error("棋盘逻辑未初始化!");
                    return;
                }

                // 计算点击位置
                var pos = chess.clickPosition(square, event.position.x, event.position.y);
                var boardCol = pos.x - 1;
                var boardRow = pos.y - 1;

                console.log("点击位置:", `(${boardCol},${boardRow})`);

                // 清除所有棋子的选中状态
                for (var i = 0; i < chess.stones.length; i++) {
                    var stone = chess.stones[i];
                    if (stone && stone.id !== -1) {  // 添加空指针检查
                        stone.selected = false;
                    }
                }

                // 判断点击位置是否有棋子
                var hasPiece = chess.isPiece(boardCol, boardRow);
                var pieceId = hasPiece ? chess.getPieceId(boardCol, boardRow) : -1;
                var piece = hasPiece && pieceId !== -1 ? chess.getStoneById(pieceId) : null;  // 加强空指针检查

                console.log("点击位置有棋子:", hasPiece, piece ? "ID:" + piece.id : "无棋子");

                // 1. 点击位置有棋子
                if (hasPiece && piece) {  // 确保piece不为null
                    // 1.1 当前没有选中棋子
                    if (selectedPieceId === -1) {
                        // 检查是否轮到此方走棋
                        if ((piece.isRed && chess.isRedTurn) || (!piece.isRed && !chess.isRedTurn)) {
                            // 选中棋子
                            selectedPieceId = pieceId;
                            selectedCol = boardCol;
                            selectedRow = boardRow;
                            piece.selected = true;
                            console.log("选中棋子:", pieceId, "位置:", `(${selectedCol},${selectedRow})`);
                        } else {
                            console.log("不是当前回合的棋子");
                        }
                    }
                    // 1.2 当前已有选中棋子
                    else {
                        var selectedPiece = chess.getStoneById(selectedPieceId);

                        // 确保selectedPiece存在
                        if (!selectedPiece) {
                            console.log("选中的棋子不存在，重置选择");
                            selectedPieceId = -1;
                            return;
                        }

                        // 1.2.1 点击同一棋子：取消选中
                        if (selectedPieceId === pieceId) {
                            selectedPieceId = -1;
                            selectedRow = -1;
                            selectedCol = -1;
                            piece.selected = false;
                            console.log("取消选中");
                        }
                        // 1.2.2 点击己方其他棋子：切换选中
                        else if (piece.isRed === selectedPiece.isRed) {
                            // 检查轮次
                            if ((piece.isRed && chess.isRedTurn) || (!piece.isRed && !chess.isRedTurn)) {
                                selectedPiece.selected = false;
                                piece.selected = true;
                                selectedPieceId = pieceId;
                                selectedCol = boardCol;
                                selectedRow = boardRow;
                                console.log("切换选中:", pieceId, "位置:", `(${selectedCol},${selectedRow})`);
                            } else {
                                console.log("不是当前回合的棋子");
                            }
                        }
                        // 1.2.3 点击敌方棋子：尝试吃子
                        else {
                            console.log("尝试吃子: 从(", selectedCol, selectedRow, ")到(", boardCol, boardRow, ")");

                            // 尝试移动棋子(吃子)
                            if (chess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                                player.captureSound.play();
                                console.log("吃子成功");
                                selectedPieceId = -1;

                                // 检查是否需要AI移动
                                if (!chess.isGameOver() &&
                                    ((chess.isRedTurn && chess.aiIsRed) ||
                                     (!chess.isRedTurn && !chess.aiIsRed))) {
                                    aiTimer.start();
                                }
                            } else {
                                console.log("吃子失败，不符合规则");
                            }
                        }
                    }
                }
                // 2. 点击空白位置
                else {
                    // 有选中棋子时尝试移动
                    if (selectedPieceId !== -1) {
                        var selectedPiece = chess.getStoneById(selectedPieceId);
                        if (!selectedPiece) {
                            console.log("选中的棋子不存在，重置选择");
                            selectedPieceId = -1;
                            return;
                        }

                        // 尝试移动棋子
                        if (chess.moveStone(selectedCol, selectedRow, boardCol, boardRow)) {
                            console.log("移动成功");
                            player.moveSound.play();
                            selectedPieceId = -1;

                            // 检查是否需要AI移动
                            if (!chess.isGameOver() &&
                                ((chess.isRedTurn && chess.aiIsRed) ||
                                 (!chess.isRedTurn && !chess.aiIsRed))) {
                                aiTimer.start();
                            }
                        } else {
                            console.log("移动失败，不符合规则");
                        }
                    } else {
                        console.log("无选中棋子");
                    }
                }
            }
        }
    }
}
