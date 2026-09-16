import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami 2.20 as Kirigami

KCM.SimpleKCM {
    id: page

    property string cfg_noteColor
    property double cfg_noteTransparency
    property string cfg_noteFontFamily
    property int cfg_noteFontSize
    property bool cfg_enableMarkdown

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

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            ComboBox {
                id: colorCombo
                Kirigami.FormData.label: i18nc("@label", "Color de fondo:")
                model: page.colorPalette
                textRole: "name"
                currentIndex: {
                    for (var i = 0; i < page.colorPalette.length; i++) {
                        if (page.colorPalette[i].hex === page.cfg_noteColor) {
                            return i
                        }
                    }
                    return 0
                }
                onActivated: (index) => {
                    page.cfg_noteColor = page.colorPalette[index].hex
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18nc("@label", "Transparencia:")
                spacing: Kirigami.Units.smallSpacing

                QQC2.Slider {
                    id: transparencySlider
                    from: 0.2
                    to: 1.0
                    stepSize: 0.05
                    value: page.cfg_noteTransparency
                    onMoved: page.cfg_noteTransparency = value
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
                currentIndex: {
                    var idx = fontCombo.model.indexOf(page.cfg_noteFontFamily)
                    return idx >= 0 ? idx : 0
                }
                onActivated: (index) => {
                    page.cfg_noteFontFamily = fontCombo.model[index]
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18nc("@label", "Tamano de fuente:")
                spacing: Kirigami.Units.smallSpacing

                QQC2.SpinBox {
                    id: fontSizeSpinBox
                    from: 8
                    to: 72
                    value: page.cfg_noteFontSize
                    onValueModified: page.cfg_noteFontSize = value
                }

                QQC2.Label {
                    text: "px"
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            QQC2.CheckBox {
                id: markdownCheck
                Kirigami.FormData.label: i18nc("@label", "Markdown:")
                text: i18nc("@option", "Habilitar soporte Markdown")
                checked: page.cfg_enableMarkdown
                onToggled: page.cfg_enableMarkdown = checked
            }
        }
    }
}
