import QtQuick 2.0
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_noteFontSize: fontSizeSpinBox.value
    property alias cfg_enableMarkdown: markdownCheck.checked
    property alias cfg_noteTransparency: transparencySlider.value
    property string cfg_noteColor: "#fff176"
    property string cfg_noteFontFamily: "Sans Serif"

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "Color:")

            Repeater {
                model: [
                    { n: "A", hex: "#fff176" },
                    { n: "R", hex: "#f48fb1" },
                    { n: "V", hex: "#a5d6a7" },
                    { n: "Az", hex: "#90caf9" },
                    { n: "N", hex: "#ffcc80" },
                    { n: "M", hex: "#ce93d8" },
                    { n: "C", hex: "#80deea" },
                    { n: "G", hex: "#bdbdbd" },
                    { n: "B", hex: "#ffffff" }
                ]
                Rectangle {
                    width: 28
                    height: 28
                    radius: 4
                    color: modelData.hex
                    border.color: root.cfg_noteColor === modelData.hex ? "#333" : "#ccc"
                    border.width: root.cfg_noteColor === modelData.hex ? 3 : 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.n
                        font.pixelSize: 10
                        font.bold: true
                        color: "#333"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cfg_noteColor = modelData.hex
                    }
                }
            }
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
                textFormat: Text.PlainText
            }
        }

        QQC2.ComboBox {
            id: fontCombo
            Kirigami.FormData.label: i18nc("@label", "Fuente:")
            model: ["Sans Serif", "Serif", "Monospace", "Arial", "Courier New",
                "DejaVu Sans", "DejaVu Serif", "DejaVu Sans Mono", "Liberation Sans",
                "Liberation Serif", "Liberation Mono", "Noto Sans", "Noto Serif",
                "Ubuntu", "Cantarell", "Droid Sans"]
            currentIndex: {
                var idx = fontCombo.model.indexOf(root.cfg_noteFontFamily)
                return idx >= 0 ? idx : 0
            }
            onActivated: (index) => root.cfg_noteFontFamily = fontCombo.model[index]
        }

        QQC2.SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: i18nc("@label", "Tamano:")
            from: 8
            to: 72
        }

        QQC2.CheckBox {
            id: markdownCheck
            Kirigami.FormData.label: i18nc("@label", "Markdown:")
            text: i18nc("@option", "Habilitar")
        }
    }
}
