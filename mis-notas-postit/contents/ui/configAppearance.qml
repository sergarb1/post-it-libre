import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_noteColor: colorCombo.currentIndex
    property alias cfg_noteTransparency: transparencySlider.value
    property alias cfg_noteFontFamily: fontCombo.currentText
    property alias cfg_noteFontSize: fontSizeSpinBox.value
    property alias cfg_enableMarkdown: markdownCheckBox.checked

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

    Kirigami.FormLayout {
        anchors.fill: parent

        ComboBox {
            id: colorCombo
            Kirigami.FormData.label: i18nc("@label", "Color de fondo:")
            model: page.colorPalette.map(function(c) { return c.name })
        }

        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "Transparencia:")

            QQC2.Slider {
                id: transparencySlider
                from: 0.2
                to: 1.0
                stepSize: 0.05
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: Math.round(transparencySlider.value * 100) + "%"
                implicitWidth: 40
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

        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "Tamano de fuente:")

            QQC2.SpinBox {
                id: fontSizeSpinBox
                from: 8
                to: 72
                value: 14
            }

            QQC2.Label {
                text: "px"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }

        QQC2.CheckBox {
            id: markdownCheckBox
            Kirigami.FormData.label: i18nc("@label", "Markdown:")
            text: i18nc("@option", "Habilitar soporte Markdown")
        }
    }
}
