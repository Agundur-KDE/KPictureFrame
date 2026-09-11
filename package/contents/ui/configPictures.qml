/*
 * SPDX-FileCopyrightText: 2025 Agundur <info@agundur.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 */
import QtCore
import QtQuick 2.0
import QtQuick.Controls 6.2 as QQC2
import QtQuick.Dialogs as QQD
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_imagePath: variableName.text
    property alias cfg_folderPath: folderField.text
    property alias cfg_slideshowInterval: intervalSpin.value
    property alias cfg_ambientGlow: glowCheck.checked
    property alias cfg_randomizeOrder: randomizeCheck.checked
    property alias cfg_pauseOnHover: pauseHoverCheck.checked
    property int cfg_pictureFillMode

    onCfg_pictureFillModeChanged: fillModeCombo.syncIndex()

    QQC2.ComboBox {
        id: modeCombo

        Kirigami.FormData.label: i18n("Source:")
        model: [i18n("Single picture"), i18n("Slideshow folder")]
        Component.onCompleted: currentIndex = folderField.text !== "" ? 1 : 0
        onActivated: index => {
            if (index === 0)
                folderField.text = "";
        }
    }

    RowLayout {
        visible: modeCombo.currentIndex === 0

        QQD.FileDialog {
            id: fileDialog

            fileMode: QQD.FileDialog.OpenFile
            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            nameFilters: ["*.png *.jpg *.jpeg *.webp *.svg", "*"]
            onAccepted: {
                variableName.text = fileDialog.selectedFile.toString().replace("file://", "");
            }
        }

        QQC2.TextField {
            id: variableName

            Kirigami.FormData.label: i18n("Picture:")
            placeholderText: i18n("No file selected.")
        }

        QQC2.Button {
            text: i18n("Browse")
            icon.name: "folder-symbolic"
            onClicked: fileDialog.open()
        }

    }

    RowLayout {
        visible: modeCombo.currentIndex === 1

        QQD.FolderDialog {
            id: folderDialog

            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            onAccepted: {
                folderField.text = folderDialog.selectedFolder.toString().replace("file://", "");
            }
        }

        QQC2.TextField {
            id: folderField

            Kirigami.FormData.label: i18n("Slideshow folder:")
            placeholderText: i18n("No folder selected.")
        }

        QQC2.Button {
            text: i18n("Browse")
            icon.name: "folder-symbolic"
            onClicked: folderDialog.open()
        }

    }

    QQC2.SpinBox {
        id: intervalSpin

        Kirigami.FormData.label: i18n("Change picture every (seconds):")
        from: 1
        to: 86400
        visible: modeCombo.currentIndex === 1
    }

    QQC2.CheckBox {
        id: randomizeCheck

        Kirigami.FormData.label: i18n("Slideshow order:")
        text: i18n("Randomize order")
        visible: modeCombo.currentIndex === 1
    }

    QQC2.CheckBox {
        id: pauseHoverCheck

        text: i18n("Pause when cursor is over the picture")
        visible: modeCombo.currentIndex === 1
    }

    QQC2.ComboBox {
        id: fillModeCombo

        // Speichert direkt den rohen Image.FillMode-Enum-Wert in cfg_pictureFillMode
        // (wie im offiziellen org.kde.image-Wallpaper) statt eines eigenen Enum-kcfg-Typs:
        // dessen Werte kommen über die plasmoid.configuration-Bridge nicht zuverlässig durch.
        Kirigami.FormData.label: i18n("Scaling:")
        model: [
            {
                "label": i18n("Scaled and cropped"),
                "fillMode": Image.PreserveAspectCrop
            },
            {
                "label": i18n("Scaled"),
                "fillMode": Image.Stretch
            },
            {
                "label": i18n("Scaled, keep proportions"),
                "fillMode": Image.PreserveAspectFit
            },
            {
                "label": i18n("Centered"),
                "fillMode": Image.Pad
            }
        ]
        textRole: "label"
        onActivated: index => cfg_pictureFillMode = model[index]["fillMode"]
        Component.onCompleted: syncIndex()
        function syncIndex() {
            for (let i = 0; i < model.length; i++) {
                if (model[i]["fillMode"] === cfg_pictureFillMode) {
                    currentIndex = i;
                    break;
                }
            }
        }
    }

    QQC2.CheckBox {
        id: glowCheck

        Kirigami.FormData.label: i18n("Ambient glow:")
        text: i18n("Blurred halo around the picture")
        checked: true
    }

}
