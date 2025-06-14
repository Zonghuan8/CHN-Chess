function createPiece(board, cellWidth, cellHeight) {
    var component = Qt.createComponent("ChessPiece.qml");

    if (component.status === Component.Ready) {
        // 创建棋子对象
        var piece = component.createObject(board, {
            "size": cellWidth,  // 使用传入的cellWidth
            "centerX": 0 * cellWidth,
            "centerY": 0 * cellHeight,
            "text": "车",
            "isRed": true
        });

        if (piece === null) {
            console.error("创建棋子失败");
        } else {
            console.log("动态棋子创建成功",
                       "尺寸:", piece.size,
                       "位置:", piece.centerX, piece.centerY);
        }
    } else {
        console.error("加载组件失败:", component.errorString());
    }
}

function createPiece1(board, cellWidth, cellHeight) {
    var component = Qt.createComponent("ChessPiece.qml");

    if (component.status === Component.Ready) {
        // 创建棋子对象
        var piece = component.createObject(board, {
            "size": cellWidth,  // 使用传入的cellWidth
            "centerX": 1 * cellWidth,
            "centerY": 0 * cellHeight,
            "text": "马",
            "isRed": true
        });

        if (piece === null) {
            console.error("创建棋子失败");
        } else {
            console.log("动态棋子创建成功",
                       "尺寸:", piece.size,
                       "位置:", piece.centerX, piece.centerY);
        }
    } else {
        console.error("加载组件失败:", component.errorString());
    }
}

