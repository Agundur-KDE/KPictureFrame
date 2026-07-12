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

    RowLayout {
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
            placeholderText: i18n("No folder selected — single picture mode")
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
        enabled: folderField.text !== ""
    }

    QQC2.CheckBox {
        id: glowCheck

        Kirigami.FormData.label: i18n("Ambient glow:")
        text: i18n("Blurred halo around the picture")
        checked: true
    }

}
