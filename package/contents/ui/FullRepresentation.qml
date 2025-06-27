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
    onDropped: (drop) => {
        if (drop.hasUrls) {
            let url = drop.urls[0];
            if (url.toString().startsWith("file:")) {
                // Nur Bilder erlauben (optional)
                if (url.toString().match(/\.(png|jpe?g|webp|svg)$/i))
                    plasmoid.configuration.imagePath = url.toString().replace("file://", "");

            }
        }
    }

    Image {
        id: picture

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: imagePath
        onStatusChanged: {
            if (status === Image.Error)
                console.warn("❌ Fehler beim Laden des Bildes:", imagePath);

            if (status === Image.Ready) {
                root.implicitWidth = sourceSize.width;
                root.implicitHeight = sourceSize.height;
            }
        }
    }

    // Optionaler Overlay-Text, falls kein Bild gesetzt wurde
    Label {
        anchors.centerIn: parent
        visible: !imagePath
        text: i18n("Drag an image here")
        color: "white"
        font.pixelSize: 18
    }

}