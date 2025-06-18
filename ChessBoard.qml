//棋盘
import QtQuick
import Chess 1.0

Item {
    id: _board
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    property int square: width/10

    //棋盘背景
    Rectangle {
        id: boardBackground
        height: parent.height
        width:parent.width
        anchors.fill: parent
        color: "#f0e0d0"
        border.width:4
        border.color: "#DCB35C"
        radius: 4

        Canvas {
            id: boardCanvas
            width: parent.width
            height:parent.height
            onPaint: {
                var ctx = getContext("2d")
                var cellSize = width / 9

                //清空画布
                ctx.clearRect(0, 0, width, height)

                //绘制网格线
                ctx.strokeStyle = "#000000"
                ctx.lineWidth = 1

                //横线
                for (var row = 1; row <= 10; row++) {
                ctx.beginPath()
                ctx.moveTo(_board.square, _board.square*(row))
                ctx.lineTo(width-_board.square,_board.square*(row))
                ctx.stroke()
                }

                // 竖线
                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _board.square, _board.square)
                    ctx.lineTo(col * _board.square, _board.square * 5) // 上半部分
                    ctx.stroke()
                }

                for (var col = 1; col <= 9; col++) {
                    ctx.beginPath()
                    ctx.moveTo(col * _board.square, 6*_board.square)
                    ctx.lineTo(col * _board.square, 10*_board.square)
                    ctx.stroke()
                }

                ctx.beginPath()
                ctx.moveTo( _board.square, _board.square * 5)
                ctx.lineTo( _board.square, 6*_board.square)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo( 9*_board.square, _board.square * 5)
                ctx.lineTo( 9*_board.square, 6*_board.square)
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
                ctx.moveTo(_board.square*4, _board.square);
                ctx.lineTo(_board.square* 6, _board.square * 3);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_board.square* 6, _board.square);
                ctx.lineTo(_board.square* 4, _board.square*3);
                ctx.stroke();

                //红方九宫（下）
                ctx.beginPath();
                ctx.moveTo(_board.square*4, _board.square*10);
                ctx.lineTo(_board.square*6, _board.square*8);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(_board.square* 6, _board.square*10);
                ctx.lineTo(_board.square* 4, _board.square*8);
                ctx.stroke();
            }
        }

        Text {
            id: riverText
            x:4*_board.square
            y:5*_board.square

            anchors.horizontalCenter: parent.horizontalCenter

            font.family: "SimHei"
            font.bold: true
            font.pixelSize: Math.max(_board.square * 0.8, 20)
            text: "楚 河        汉 界"
            color: "#8B4513"

            style: Text.Outline
            styleColor: "#00000011"
        }

        Board{
            id:chess
        }

        Repeater {
            model: chess.stones
            delegate: ChessPiece {
                centerX: (modelData.col +1)* _board.square
                centerY: (modelData.row +1)*  _board.square
                size: _board.square
                text: {
                    switch(modelData.type) {
                        case Stone.CHE: return "车"
                        case Stone.MA: return "马"
                        case Stone.XIANG: return modelData.red ? "相" : "象"
                        case Stone.SHI: return modelData.red ? "仕" : "士"
                        case Stone.JIANG: return modelData.red ? "帅" : "将"
                        case Stone.PAO: return "炮"
                        case Stone.BING: return modelData.red ? "兵" : "卒"
                        default: return "?"
                    }
                }
                isRed: modelData.red
            }
        }
    }

    TapHandler {
        onTapped: (event) => {
            var pos=chess.clickPosition(square, event.position.x, event.position.y);
            console.log(pos.x);
        }
    }
}
