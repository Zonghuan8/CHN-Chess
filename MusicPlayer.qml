import QtQuick
import QtMultimedia
import "settings.js" as Controller

Item {
  id: musicManager

  property alias bgMusic: _bgMusic    //背景音乐
  property alias moveSound: _moveSound   //移动音乐
  property alias captureSound: _captureSound   //吃子音乐
  property alias click: _click   //点击音乐
  property alias success:_success  //胜利音乐
  property alias fail:_fail  //失败音乐

  // 暴露可绑定属性
  property bool musicEnabled:true
  property bool soundEnabled:true

  // 背景音乐
  MediaPlayer {
    id: _bgMusic
    audioOutput: AudioOutput {
      id: bgAudioOutput
      volume:musicManager.musicEnabled ? 1.0 : 0.0  // 随musicEnabled变化
    }
    source: "qrc:/sounds/bgm.wav"
    loops: MediaPlayer.Infinite
   // autoPlay: true                // 自动播放
  }

  //走棋音效
   SoundEffect{
    id: _moveSound
    volume: musicManager.soundEnabled ? 1.0 : 0.0  // 随soundEnabled变化
    source: "qrc:/sounds/move.wav"
  }

   // 吃子音效
   SoundEffect {
     id: _captureSound
     volume: musicManager.soundEnabled ? 1.0 : 0.0
     source: "qrc:/sounds/capture.wav"
   }

   //点击音效
   SoundEffect{
    id: _click
    volume: musicManager.soundEnabled ? 1.0 : 0.0
    source: "qrc:/sounds/click.wav"
  }

   //胜利音效
   SoundEffect{
    id: _success
    volume: musicManager.soundEnabled ? 1.0 : 0.0
    source: "qrc:/sounds/success.wav"
  }

   SoundEffect{
    id: _fail
    volume: musicManager.soundEnabled ? 1.0 : 0.0
    source: "qrc:/sounds/fail.wav"
   }

   // 初始化自动播放
   Component.onCompleted: {
     bgMusic.play()
   }

}
