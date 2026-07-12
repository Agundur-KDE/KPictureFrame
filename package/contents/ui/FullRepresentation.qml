/*
 * SPDX-FileCopyrightText: 2025 Agundur <info@agundur.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 */

import QtQuick
import QtQuick.Controls 6.7
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

DropArea {
    id: full

    property string imagePath: plasmoid.configuration.imagePath
    property string folderPath: plasmoid.configuration.folderPath
    property bool slideshowMode: folderPath !== ""
    property int currentIndex: 0
    property int contentWidth: 0
    property int contentHeight: 0
    // ponytail: Ordner vs. Bild wird nur an der Datei-Endung erkannt (kein KIO StatJob).
    // Reicht für Drag&Drop aus dem Dateimanager; bei falscher Erkennung bleibt die Slideshow leer.
    readonly property var imageExtensions: /\.(png|jpe?g|webp|svg)$/i

    implicitWidth: contentWidth
    implicitHeight: contentHeight
    anchors.fill: parent
    onFolderPathChanged: currentIndex = 0
    onDropped: (drop) => {
        if (drop.hasUrls) {
            let url = drop.urls[0].toString();
            if (url.startsWith("file:")) {
                let path = url.replace("file://", "");
                if (imageExtensions.test(url)) {
                    plasmoid.configuration.imagePath = path;
                    plasmoid.configuration.folderPath = "";
                } else {
                    plasmoid.configuration.folderPath = path;
                }
            }
        }
    }

    FolderListModel {
        id: folderModel

        folder: full.slideshowMode ? "file://" + full.folderPath : ""
        showDirs: false
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg"]
    }

    Timer {
        interval: plasmoid.configuration.slideshowInterval * 1000
        running: full.slideshowMode && folderModel.count > 0
        repeat: true
        onTriggered: full.currentIndex = (full.currentIndex + 1) % folderModel.count
    }

    Image {
        id: picture

        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        source: full.slideshowMode ? (folderModel.count > 0 ? folderModel.get(full.currentIndex, "fileURL") : "") : full.imagePath
        autoTransform: true
        asynchronous: true
        visible: status === Image.Ready
        onStatusChanged: {
            if (status === Image.Error)
                console.warn("❌ Fehler beim Laden des Bildes:", source);

            if (status === Image.Ready)
                Qt.callLater(() => {
                // wird abgewartet bis das Bild wirklich gerendert ist
                full.contentWidth = picture.paintedWidth;
                full.contentHeight = picture.paintedHeight;
            });

        }
    }

    // Optionaler Overlay-Text, falls kein Bild/Ordner gesetzt wurde oder der Ordner leer ist
    Label {
        anchors.centerIn: parent
        visible: full.slideshowMode ? folderModel.count === 0 : !imagePath
        text: full.slideshowMode ? i18n("No images found in this folder") : i18n("Drag an image or a folder here")
        color: "white"
        font.pixelSize: 18
    }

}