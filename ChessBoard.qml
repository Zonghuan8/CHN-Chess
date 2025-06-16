import QtQuick

Item {
    id: _board
    width: parent.width*0.8
    height: parent.height*0.9
    anchors.centerIn: parent

    //棋盘背景
    Rectangle {
        id: boardBackground
        anchors.fill: parent
        color: "#e6c99c"
        border.width: 4
        border.color: "#8b4513"
        radius: 4
    }

    //绘制网格线
    //水平线,10线9行
    Repeater {
        model: 10
        Canvas {
            id: horizontalLine
            y: index*parent.height/9//平均分成9份
            width: parent.width
            height: 8
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 2.5;
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.stroke();//绘制图形轮廓
            }
        }
    }

    //垂直线，9线8列
    Repeater {
        model: 9
        Canvas {
            id: verticalLine
            x: index * _board.width/8//平均分成8份
            width: 8
            height: parent.height
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#000000";
                ctx.lineWidth = 2.5;
                ctx.beginPath();

                //分两段绘制垂直线（绕过河界）
                if (index > 0 && index < 8) {
                    //中间竖线在楚河汉界处断开（棋盘高度的4/9到5/9之间为河界）
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, _board.height * 4/9);//上半部分（河界以上）
                    ctx.moveTo(0, _board.height * 5/9);
                    ctx.lineTo(0, _board.height);//下半部分（河界以下）
                } else {
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, _board.height);
                }
                ctx.stroke();//绘制图形轮廓
            }
        }
    }

    //绘制楚河汉界文字
    Rectangle {
        id: _riverArea
        anchors.centerIn: parent
        width: parent.width - 2 * parent.width/8
        height: parent.width/8
        color: "transparent"

        Text {
            anchors.fill: parent
            text:qsTr(" 楚 河        汉 界 ")
            font.family: "楷体"
            font.pixelSize: height * 0.8
            color: "#8b4513"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
            ctx.moveTo(_board.width/8 * 3, 0);
            ctx.lineTo(_board.width/8 * 5, _board.height/9 * 2);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(_board.width/8 * 5, 0);
            ctx.lineTo(_board.width/8 * 3, _board.height/9 * 2);
            ctx.stroke();

            //红方九宫（下）
            ctx.beginPath();
            ctx.moveTo(_board.width/8 * 3, _board.height);
            ctx.lineTo(_board.width/8 * 5, _board.height - _board.height/9 * 2);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(_board.width/8 * 5, _board.height);
            ctx.lineTo(_board.width/8 * 3, _board.height - _board.height/9 * 2);
            ctx.stroke();
        }
    }
}
