import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_noteColor: colorCombo.currentValue
    property alias cfg_noteTransparency: transparencySlider.value
    property alias cfg_noteFontFamily: fontCombo.currentText
    property alias cfg_noteFontSize: fontSizeSpin.value
    property alias cfg_enableMarkdown: markdownCheck.checked

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

    ComboBox {
        id: colorCombo
        Kirigami.FormData.label: i18nc("@label", "Color de fondo:")
        model: page.colorPalette
        textRole: "name"
        valueRole: "hex"
    }

    Slider {
        id: transparencySlider
        Kirigami.FormData.label: i18nc("@label", "Transparencia:")
        from: 0.2
        to: 1.0
        stepSize: 0.05
        value: 1.0

        Label {
            anchors.left: parent.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(transparencySlider.value * 100) + "%"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
    }

    ComboBox {
        id: fontCombo
        Kirigami.FormData.label: i18nc("@label", "Fuente:")
        model: ["Sans Serif", "Serif", "Monospace", "Arial", "Courier New",
            "DejaVu Sans", "DejaVu Serif", "DejaVu Sans Mono", "Liberation Sans",
            "Liberation Serif", "Liberation Mono", "Noto Sans", "Noto Serif",
            "Ubuntu", "Cantarell", "Droid Sans"]
    }

    SpinBox {
        id: fontSizeSpin
        Kirigami.FormData.label: i18nc("@label", "Tamano de fuente:")
        from: 8
        to: 72
        value: 14
    }

    CheckBox {
        id: markdownCheck
        Kirigami.FormData.label: i18nc("@label", "Markdown:")
        text: i18nc("@option", "Habilitar soporte Markdown")
        checked: false
    }
}
