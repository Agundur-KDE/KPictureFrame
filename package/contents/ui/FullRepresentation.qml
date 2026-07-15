/*
 * SPDX-FileCopyrightText: 2025 Agundur <info@agundur.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 *
 */

import QtQuick
import QtQuick.Controls 6.7
import QtQuick.Effects
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
    readonly property bool ambientGlow: plasmoid.configuration.ambientGlow
    readonly property bool randomizeOrder: plasmoid.configuration.randomizeOrder
    readonly property bool pauseOnHover: plasmoid.configuration.pauseOnHover
    readonly property int glowMargin: ambientGlow ? Kirigami.Units.gridUnit * 2 : 0
    readonly property url currentSource: full.slideshowMode ? (folderModel.count > 0 ? folderModel.get(full.currentIndex, "fileUrl") : "") : full.imagePath
    // ponytail: Ordner vs. Bild wird nur an der Datei-Endung erkannt (kein KIO StatJob).
    // Reicht für Drag&Drop aus dem Dateimanager; bei falscher Erkennung bleibt die Slideshow leer.
    readonly property var imageExtensions: /\.(png|jpe?g|webp|svg|gif)$/i

    implicitWidth: contentWidth + glowMargin * 2
    implicitHeight: contentHeight + glowMargin * 2
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
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg", "*.gif"]
    }

    HoverHandler {
        id: hoverHandler
    }

    // Shared by the auto-advance timer and the manual prev/next click zones below.
    function goTo(step) {
        if (folderModel.count === 0)
            return;
        full.currentIndex = (full.currentIndex + step + folderModel.count) % folderModel.count;
    }

    Timer {
        id: slideshowTimer

        interval: plasmoid.configuration.slideshowInterval * 1000
        running: full.slideshowMode && folderModel.count > 0 && !(full.pauseOnHover && hoverHandler.hovered)
        repeat: true
        onTriggered: {
            if (full.randomizeOrder && folderModel.count > 1) {
                // Nächsten Index zufällig wählen, aber nie denselben zweimal hintereinander.
                let next = full.currentIndex;
                while (next === full.currentIndex)
                    next = Math.floor(Math.random() * folderModel.count);
                full.currentIndex = next;
            } else {
                full.goTo(1);
            }
        }
    }

    // Unscharfe, übersättigte Kopie hinter dem Bild — der eigentliche "Ambilight"-Effekt.
    // opacity:0 statt visible:false: MultiEffect braucht die Quelle weiterhin gerendert,
    // um sie als Textur zu greifen (Qt-Quirk), aber sie soll selbst unsichtbar bleiben.
    AnimatedImage {
        id: glowSource

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: full.currentSource
        asynchronous: true
        opacity: 0
        visible: full.ambientGlow
    }

    MultiEffect {
        anchors.fill: parent
        source: glowSource
        visible: full.ambientGlow
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        saturation: 0.4
        brightness: 0.05
    }

    AnimatedImage {
        id: picture

        anchors.fill: parent
        anchors.margins: full.glowMargin
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        source: full.currentSource
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

    // Manuelle Weiterschaltung: linke/rechte Bildhälfte klickbar, nur im
    // Diashow-Modus mit mehr als einem Bild sinnvoll. Setzt den Auto-Timer
    // zurück, damit ein manueller Klick nicht sofort vom nächsten Tick
    // überholt wird.
    RowLayout {
        anchors.fill: parent
        anchors.margins: full.glowMargin
        spacing: 0
        visible: full.slideshowMode && folderModel.count > 1

        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                full.goTo(-1);
                slideshowTimer.restart();
            }
        }
        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                full.goTo(1);
                slideshowTimer.restart();
            }
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