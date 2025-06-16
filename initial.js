function addPiece(size, centerX, centerY,text,isRed) {
    let component = Qt.createComponent("ChessPiece.qml");

    if (component.status === Component.Ready) {
        //创建棋子对象
        let piece = component.createObject(board, {
            "size": size,  //使用传入的cellWidth
            "centerX": centerX,
            "centerY": centerY,
            "text": text,
            "isRed": isRed
        });
        if (piece === null) {
            console.error("创建棋子失败");
        } else {
            console.log("动态棋子"+ text+ "创建成功",
                       "尺寸:", piece.size,
                       "位置:", piece.centerX, piece.centerY);
        }
    } else {
        console.error("加载组件失败:", component.errorString());
    }
}

function initializeBoard(board,cw,ch) {
    //黑方棋子
    addPiece(cw, 0*cw, 0*ch, "車",false);
    addPiece(cw, 1*cw, 0*ch, "马",false);
    addPiece(cw, 2*cw, 0*ch, "象",false);
    addPiece(cw, 3*cw, 0*ch, "士",false);
    addPiece(cw, 4*cw, 0*ch, "將",false);
    addPiece(cw, 5*cw, 0*ch, "士",false);
    addPiece(cw, 6*cw, 0*ch, "象",false);
    addPiece(cw, 7*cw, 0*ch, "马",false);
    addPiece(cw, 8*cw, 0*ch, "車",false);
    addPiece(cw, 1*cw, 2*ch, "炮",false);
    addPiece(cw, 7*cw, 2*ch, "炮",false);
    for (let i = 0; i <= 8; i += 2) addPiece(cw, i*cw, 3*ch, "卒",false);;

    //红方棋子
    addPiece(cw, 0*cw, 9*ch, "車",true);
    addPiece(cw, 1*cw, 9*ch, "马",true);
    addPiece(cw, 2*cw, 9*ch, "相",true);
    addPiece(cw, 3*cw, 9*ch, "仕",true);
    addPiece(cw, 4*cw, 9*ch, "帥",true);
    addPiece(cw, 5*cw, 9*ch, "仕",true);
    addPiece(cw, 6*cw, 9*ch, "相",true);
    addPiece(cw, 7*cw, 9*ch, "马",true);
    addPiece(cw, 8*cw, 9*ch, "車",true);
    addPiece(cw, 1*cw, 7*ch, "炮",true);
    addPiece(cw, 7*cw, 7*ch, "炮",true);
    for (let j = 0; j <= 8; j += 2) addPiece(cw, j*cw, 6*ch, "兵",true);;
}

