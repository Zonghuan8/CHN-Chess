// 游戏设置控制器
var musicEnabled = true;
var soundEnabled = true;

function initial() {
   console.log("游戏初始化完成，音乐:开启,音效: 开启" );
}

//音乐控制函数
function toggleMusic(enabled) {
    musicEnabled = enabled;
    console.log("音乐已" + (musicEnabled ? "开启" : "关闭"));
    if (musicEnabled)
    {
       player.musicEnabled=true
    }else {
      player.musicEnabled=false
           }
}

//音效控制函数
function toggleSound(enabled) {
    soundEnabled = enabled;
    console.log("音效已" + (soundEnabled ? "开启" : "关闭"));
    if(soundEnabled)
    {
       player.soundEnabled=true
    }else{
       player.soundEnabled=false
    }
}



