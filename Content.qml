import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id:content
    anchors.fill: parent

    property alias dialogs: _dialogs
    property bool musicEnabled: true
    property bool soundEnabled: true

    Dialogs{
        id:_dialogs

    }

}
