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

    property var colorPalette: [
        { name: "Amarillo", hex: "#fff9a6" },
        { name: "Rosa", hex: "#ffb6c1" },
        { name: "Verde", hex: "#b5e8b5" },
        { name: "Azul", hex: "#b5d8e8" },
        { name: "Naranja", hex: "#ffdab9" },
        { name: "Morado", hex: "#d8b5e8" },
        { name: "Cyan", hex: "#b5e8e8" },
        { name: "Gris", hex: "#d9d9d9" },
        { name: "Blanco", hex: "#ffffff" }
    ]

    property var systemFonts: ["Sans Serif", "Serif", "Monospace", "Arial", "Courier New",
        "DejaVu Sans", "DejaVu Serif", "DejaVu Sans Mono", "Liberation Sans",
        "Liberation Serif", "Liberation Mono", "Noto Sans", "Noto Serif",
        "Ubuntu", "Cantarell", "Droid Sans"]

    Layout.minimumWidth: minimumWidth
    Layout.minimumHeight: minimumHeight
    Layout.preferredWidth: Plasmoid.configuration.widgetWidth
    Layout.preferredHeight: isCollapsed ? 40 : Plasmoid.configuration.widgetHeight

    Component.onCompleted: {
        initialized = true
    }

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
                color: Qt.darker(root.noteColor, 1.1)
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
                        color: "#444444"
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
                color: Qt.darker(root.noteColor, 1.05)
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
                    color: "#333333"
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
            width: 22
            height: 22
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            cursorShape: Qt.SizeFDiagCursor
            z: 10
            preventStealing: true

            property real startX
            property real startY
            property real startW
            property real startH

            onPressed: (mouse) => {
                startX = mouse.x
                startY = mouse.y
                startW = root.width
                startH = root.height
                mouse.accepted = true
            }

            onPositionChanged: (mouse) => {
                if (pressed) {
                    var dw = mouse.x - startX
                    var dh = mouse.y - startY
                    var newW = Math.max(root.minimumWidth, startW + dw)
                    var newH = Math.max(root.minimumHeight, startH + dh)
                    Plasmoid.configuration.widgetWidth = newW
                    Plasmoid.configuration.widgetHeight = newH
                }
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#888"
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
            width: parent.width - 22
            height: 8
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 22
            cursorShape: Qt.SizeVerCursor
            z: 10
            preventStealing: true

            property real startY
            property real startH

            onPressed: (mouse) => {
                startY = mouse.y
                startH = root.height
                mouse.accepted = true
            }

            onPositionChanged: (mouse) => {
                if (pressed) {
                    var dh = mouse.y - startY
                    Plasmoid.configuration.widgetHeight = Math.max(root.minimumHeight, startH + dh)
                }
            }
        }

        // --- RESIZE: BORDE DERECHO ---
        MouseArea {
            width: 8
            height: parent.height - 22
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 32
            cursorShape: Qt.SizeHorCursor
            z: 10
            preventStealing: true

            property real startX
            property real startW

            onPressed: (mouse) => {
                startX = mouse.x
                startW = root.width
                mouse.accepted = true
            }

            onPositionChanged: (mouse) => {
                if (pressed) {
                    var dw = mouse.x - startX
                    Plasmoid.configuration.widgetWidth = Math.max(root.minimumWidth, startW + dw)
                }
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
