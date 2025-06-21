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

  // 暴露控制状态属性
  property bool musicEnabled: true
  property bool soundEnabled: true

  // 背景音乐播放器
  MediaPlayer {
    id: _bgMusic
    audioOutput: AudioOutput {
      id: bgAudioOutput
      volume: 2.0
    }
    source: "qrc:/sounds/bgm.mp3"
    loops: MediaPlayer.Infinite
  }

  // 音效播放器 - 走棋音效
   SoundEffect{
    id: _moveSound
    volume: 1.0
    source: "qrc:/sounds/move.wav"
  }

   // 音效播放器 - 吃子音效
   SoundEffect {
     id: _captureSound
     volume:1.0
     source: "qrc:/sounds/capture.mp3"
   }

   SoundEffect{
    id: _click
    volume: 1.0
 //   source: "qrc:/sounds/click.ogg"
  }

   SoundEffect{
    id: _success
    volume: 1.0
//    source: "qrc:/sounds/success.ogg"
  }

  // 初始化自动播放
  Component.onCompleted: {
     bgMusic.play()
  //   click.play()
  //  success.play()
  }
}
