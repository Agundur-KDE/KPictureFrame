/*
 * SPDX-FileCopyrightText: 2025 Agundur <info@agundur.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 */

import QtQuick
import QtQuick.Controls 6.7
import QtQuick.Layouts
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

DropArea {
    id: full

    property string imagePath: plasmoid.configuration.imagePath

    anchors.fill: parent

    Image {
        id: picture

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: imagePath
        onStatusChanged: {
            if (status === Image.Error)
                console.warn("❌ Fehler beim Laden des Bildes:", imagePath);

        }
    }

    // Optionaler Overlay-Text, falls kein Bild gesetzt wurde
    Label {
        anchors.centerIn: parent
        visible: !imagePath
        text: i18n("No image selected")
        color: "white"
        font.pixelSize: 18
    }

}