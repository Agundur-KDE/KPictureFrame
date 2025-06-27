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

    RowLayout {
        Kirigami.FormData.label: i18n("Picture:")

        QQD.FileDialog {
            id: fileDialog

            fileMode: OpenFile
            currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
            nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.svg)", i18n("All files (%1)", "*")]
            onAccepted: {
                variableName.text = fileDialog.selectedFile.toString().replace("file://", "");
            }
        }

        QQC2.TextField {
            id: variableName

            placeholderText: i18n("No file selected.")
        }

        QQC2.Button {
            text: i18n("Browse")
            icon.name: "folder-symbolic"
            onClicked: fileDialog.open()
        }

    }

}
