import QtQuick
import QtMultimedia
import "settings.js" as Controller

Item {
  id: musicManager

  property alias bgMusic: _bgMusic
  property alias moveSound: _moveSound
  property alias captureSound: _captureSound
  // 暴露控制状态属性
  property bool musicEnabled: true
  property bool soundEnabled: true

  // 背景音乐播放器
  MediaPlayer {
    id: _bgMusic
    audioOutput: AudioOutput {
      id: bgAudioOutput
      volume: 0.5
    }
    source: "qrc:/sounds/bgm.ogg"
    loops: MediaPlayer.Infinite
  }

  // 音效播放器 - 走棋音效
   SoundEffect{
    id: _moveSound
    volume: 0.8
    source: "qrc:/sounds/move.wav"
  }

   // 音效播放器 - 吃子音效
   SoundEffect {
     id: _captureSound
     volume: soundEnabled ? 0.8 : 0
     //source: "qrc:/sounds/capture.wav"
   }

  // 初始化自动播放
  Component.onCompleted: {
     bgMusic.play()
  }
}
