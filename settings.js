// 游戏设置控制器
var musicEnabled = true;
var soundEnabled = true;

function initial(music, sound) {
    musicEnabled = music;
    soundEnabled = sound;
    console.log("游戏初始化完成，音乐: " +
                (musicEnabled ? "开启" : "关闭") +
                "，音效: " + (soundEnabled ? "开启" : "关闭"));
}

//音乐控制函数
function toggleMusic(enabled) {
    musicEnabled = enabled;
    console.log("音乐已" + (musicEnabled ? "开启" : "关闭"));
}

//音效控制函数
function toggleSound(enabled) {
    soundEnabled = enabled;
    console.log("音效已" + (soundEnabled ? "开启" : "关闭"));
}

// 播放音乐函数
function playBgMusic() {
    if (musicEnabled)
       bgMusic.play()   //棋子移动音效
}

function playMoveSound() {
    if (soundEnabled)
        moveSound.play()   //棋子移动音效
}

function playCaptureSound() {
    if (soundEnabled)
       captureSound.play()    //吃子音效
}
