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
    property int contentWidth: 0
    property int contentHeight: 0

    implicitWidth: contentWidth
    implicitHeight: contentHeight
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
        fillMode: Image.Image.PreserveAspectFit
        smooth: true
        mipmap: true
        source: imagePath
        autoTransform: true
        asynchronous: true
        visible: status === Image.Ready
        onStatusChanged: {
            // root.width = picture.paintedWidth;
            // root.height = picture.paintedHeight;
            // root.implicitWidth = picture.paintedWidth;
            // root.implicitHeight = picture.paintedHeight;

            if (status === Image.Error)
                console.warn("❌ Fehler beim Laden des Bildes:", imagePath);

            if (status === Image.Ready)
                Qt.callLater(() => {
                    // wird abgewartet bis das Bild wirklich gerendert ist
                    full.contentWidth = picture.paintedWidth;
                    full.contentHeight = picture.paintedHeight;
                });

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