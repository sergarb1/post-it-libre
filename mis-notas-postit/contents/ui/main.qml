import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property bool isCollapsed: Plasmoid.configuration.isCollapsed
    property int minimumWidth: 180
    property int minimumHeight: 60

    property color noteColor: Plasmoid.configuration.noteColor
    property real noteTransparency: Plasmoid.configuration.noteTransparency
    property string noteFontFamily: Plasmoid.configuration.noteFontFamily
    property int noteFontSize: Plasmoid.configuration.noteFontSize
    property bool enableMarkdown: Plasmoid.configuration.enableMarkdown

    property bool initialized: false

    width: Plasmoid.configuration.widgetWidth
    height: isCollapsed ? 40 : Plasmoid.configuration.widgetHeight

    Layout.minimumWidth: minimumWidth
    Layout.minimumHeight: minimumHeight

    Component.onCompleted: {
        initialized = true
    }

    property var colorPalette: [
        { name: "Amarillo", hex: "#fff176" },
        { name: "Rosa", hex: "#f48fb1" },
        { name: "Verde", hex: "#a5d6a7" },
        { name: "Azul", hex: "#90caf9" },
        { name: "Naranja", hex: "#ffcc80" },
        { name: "Morado", hex: "#ce93d8" },
        { name: "Cyan", hex: "#80deea" },
        { name: "Gris", hex: "#bdbdbd" },
        { name: "Blanco", hex: "#ffffff" }
    ]

    property var systemFonts: ["Sans Serif", "Serif", "Monospace", "Arial", "Courier New",
        "DejaVu Sans", "DejaVu Serif", "DejaVu Sans Mono", "Liberation Sans",
        "Liberation Serif", "Liberation Mono", "Noto Sans", "Noto Serif",
        "Ubuntu", "Cantarell", "Droid Sans"]

    Rectangle {
        id: postItBg
        anchors.fill: parent
        color: root.noteColor
        opacity: root.noteTransparency
        radius: 6
        border.color: Qt.darker(root.noteColor, 1.3)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // --- BARRA SUPERIOR ---
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Qt.darker(root.noteColor, 1.15)
                radius: 6

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    property real lastX
                    property real lastY

                    onPressed: (mouse) => {
                        lastX = mouse.x
                        lastY = mouse.y
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            root.x += mouse.x - lastX
                            root.y += mouse.y - lastY
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 4
                    spacing: 2
                    z: 1

                    Text {
                        text: "Post-it"
                        font.bold: true
                        font.pixelSize: 12
                        color: "#222222"
                        Layout.fillWidth: true
                    }

                    Button {
                        id: settingsBtn
                        text: "\u2699"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.pixelSize: 14
                        z: 2
                        onClicked: Plasmoid.internalAction("configure").trigger()
                        ToolTip.text: "Configuracion"
                        ToolTip.visible: hovered
                    }

                    Button {
                        text: root.isCollapsed ? "+" : "-"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.pixelSize: 16
                        font.bold: true
                        z: 2
                        onClicked: {
                            root.isCollapsed = !root.isCollapsed
                            Plasmoid.configuration.isCollapsed = root.isCollapsed
                        }
                        ToolTip.text: root.isCollapsed ? "Expandir" : "Colapsar"
                        ToolTip.visible: hovered
                    }
                }
            }

            // --- BARRA DE FORMATO ---
            Rectangle {
                id: formatBar
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Qt.darker(root.noteColor, 1.08)
                radius: 4
                visible: !root.isCollapsed && textArea.activeFocus
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    spacing: 2

                    Button {
                        text: "B"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.bold: true
                        font.pixelSize: 12
                        onClicked: insertFormat("**", "**")
                        ToolTip.text: "Negrita (Ctrl+B)"
                        ToolTip.visible: hovered
                    }

                    Button {
                        text: "I"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.italic: true
                        font.pixelSize: 12
                        onClicked: insertFormat("*", "*")
                        ToolTip.text: "Cursiva (Ctrl+I)"
                        ToolTip.visible: hovered
                    }

                    Button {
                        text: "U"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.underline: true
                        font.pixelSize: 12
                        onClicked: insertFormat("<u>", "</u>")
                        ToolTip.text: "Subrayado (Ctrl+U)"
                        ToolTip.visible: hovered
                    }

                    Rectangle { width: 1; height: 20; color: "#aaa" }

                    ComboBox {
                        id: fontCombo
                        model: root.systemFonts
                        currentIndex: {
                            var idx = root.systemFonts.indexOf(root.noteFontFamily)
                            return idx >= 0 ? idx : 0
                        }
                        implicitWidth: 120
                        implicitHeight: 26
                        font.pixelSize: 11
                        onActivated: (index) => {
                            if (root.initialized) {
                                var selectedFont = root.systemFonts[index]
                                root.noteFontFamily = selectedFont
                                Plasmoid.configuration.noteFontFamily = selectedFont
                            }
                        }
                    }

                    SpinBox {
                        id: fontSizeSpin
                        from: 8
                        to: 72
                        value: root.noteFontSize
                        implicitWidth: 60
                        implicitHeight: 26
                        font.pixelSize: 11
                        onValueModified: {
                            if (root.initialized) {
                                root.noteFontSize = value
                                Plasmoid.configuration.noteFontSize = value
                            }
                        }
                    }

                    Rectangle { width: 1; height: 20; color: "#aaa" }

                    Button {
                        text: "\uD83C\uDFA8"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.pixelSize: 14
                        onClicked: colorPopup.visible = !colorPopup.visible
                        ToolTip.text: "Color de fondo"
                        ToolTip.visible: hovered
                    }

                    Slider {
                        id: transparencySlider
                        from: 0.2
                        to: 1.0
                        value: root.noteTransparency
                        implicitWidth: 70
                        implicitHeight: 26
                        onMoved: {
                            root.noteTransparency = value
                            Plasmoid.configuration.noteTransparency = value
                        }
                        ToolTip.text: "Transparencia: " + Math.round(value * 100) + "%"
                        ToolTip.visible: hovered
                    }

                    Rectangle { width: 1; height: 20; color: "#aaa" }

                    Button {
                        text: "MD"
                        flat: true
                        implicitWidth: 26
                        implicitHeight: 26
                        font.pixelSize: 10
                        font.bold: root.enableMarkdown
                        checkable: true
                        checked: root.enableMarkdown
                        onClicked: {
                            root.enableMarkdown = !root.enableMarkdown
                            Plasmoid.configuration.enableMarkdown = root.enableMarkdown
                        }
                        ToolTip.text: root.enableMarkdown ? "Markdown ON" : "Markdown OFF"
                        ToolTip.visible: hovered
                    }
                }

                // --- POPUP DE COLORES ---
                Rectangle {
                    id: colorPopup
                    width: colorGrid.width + 16
                    height: colorGrid.height + 16
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 6
                    visible: false
                    anchors.top: formatBar.bottom
                    anchors.right: formatBar.right
                    anchors.rightMargin: 4
                    z: 100

                    Grid {
                        id: colorGrid
                        anchors.centerIn: parent
                        columns: 5
                        spacing: 4

                        Repeater {
                            model: root.colorPalette
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: modelData.hex
                                border.color: root.noteColor === modelData.hex ? "#333" : "#ccc"
                                border.width: root.noteColor === modelData.hex ? 2 : 1

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.noteColor = modelData.hex
                                        Plasmoid.configuration.noteColor = modelData.hex
                                        colorPopup.visible = false
                                    }
                                }

                                ToolTip.text: modelData.name
                                ToolTip.visible: hovered
                            }
                        }
                    }
                }
            }

            // --- AREA DE TEXTO ---
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 6
                visible: !root.isCollapsed
                clip: true

                TextArea {
                    id: textArea
                    text: Plasmoid.configuration.noteText
                    placeholderText: "Escribe tu nota aqui..."
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    background: null
                    color: "#222222"
                    placeholderTextColor: "#888888"
                    font.family: root.noteFontFamily
                    font.pixelSize: root.noteFontSize
                    textFormat: root.enableMarkdown ? TextEdit.MarkdownText : TextEdit.RichText

                    onTextChanged: {
                        if (root.initialized) {
                            Plasmoid.configuration.noteText = text
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.modifiers === Qt.ControlModifier) {
                            if (event.key === Qt.Key_B) {
                                insertFormat("**", "**")
                                event.accepted = true
                            } else if (event.key === Qt.Key_I) {
                                insertFormat("*", "*")
                                event.accepted = true
                            } else if (event.key === Qt.Key_U) {
                                insertFormat("<u>", "</u>")
                                event.accepted = true
                            }
                        }
                    }
                }
            }
        }

        // --- RESIZE: ESQUINA INFERIOR DERECHA ---
        MouseArea {
            id: resizeCorner
            width: 24
            height: 24
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            cursorShape: Qt.SizeFDiagCursor
            z: 10

            property real initMouseX
            property real initMouseY
            property real startW
            property real startH
            property bool active: false

            onPressed: (mouse) => {
                active = true
                initMouseX = mouse.x
                initMouseY = mouse.y
                startW = root.width
                startH = root.height
            }

            onPositionChanged: (mouse) => {
                if (active) {
                    var dx = mouse.x - initMouseX
                    var dy = mouse.y - initMouseY
                    root.width = Math.max(root.minimumWidth, startW + dx)
                    root.height = Math.max(root.minimumHeight, startH + dy)
                }
            }

            onReleased: {
                active = false
                Plasmoid.configuration.widgetWidth = root.width
                Plasmoid.configuration.widgetHeight = root.height
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#666"
                    ctx.lineWidth = 1
                    ctx.beginPath()
                    ctx.moveTo(width - 2, 2)
                    ctx.lineTo(2, height - 2)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(width - 7, 2)
                    ctx.lineTo(2, height - 7)
                    ctx.stroke()
                }
            }
        }

        // --- RESIZE: BORDE INFERIOR ---
        MouseArea {
            id: resizeBottom
            width: parent.width - 24
            height: 10
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 24
            cursorShape: Qt.SizeVerCursor
            z: 10

            property real initMouseY
            property real startH
            property bool active: false

            onPressed: (mouse) => {
                active = true
                initMouseY = mouse.y
                startH = root.height
            }

            onPositionChanged: (mouse) => {
                if (active) {
                    var dy = mouse.y - initMouseY
                    root.height = Math.max(root.minimumHeight, startH + dy)
                }
            }

            onReleased: {
                active = false
                Plasmoid.configuration.widgetHeight = root.height
            }
        }

        // --- RESIZE: BORDE DERECHO ---
        MouseArea {
            id: resizeRight
            width: 10
            height: parent.height - 24
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 32
            cursorShape: Qt.SizeHorCursor
            z: 10

            property real initMouseX
            property real startW
            property bool active: false

            onPressed: (mouse) => {
                active = true
                initMouseX = mouse.x
                startW = root.width
            }

            onPositionChanged: (mouse) => {
                if (active) {
                    var dx = mouse.x - initMouseX
                    root.width = Math.max(root.minimumWidth, startW + dx)
                }
            }

            onReleased: {
                active = false
                Plasmoid.configuration.widgetWidth = root.width
            }
        }
    }

    function insertFormat(prefix, suffix) {
        var start = textArea.selectionStart
        var end = textArea.selectionEnd
        var selected = textArea.getText(start, end)

        if (selected.length > 0) {
            textArea.remove(start, end)
            textArea.insert(start, prefix + selected + suffix)
        } else {
            textArea.insert(start, prefix + suffix)
            textArea.cursorPosition = start + prefix.length
        }
    }
}
