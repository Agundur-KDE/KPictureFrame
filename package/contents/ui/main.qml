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

PlasmoidItem {
    // Layout.preferredWidth: full.implicitWidth > 0 ? full.implicitWidth : 300
    // Layout.preferredHeight: full.implicitHeight > 0 ? full.implicitHeight : 200

    id: root

    preferredRepresentation: {
        return fullRepresentation;
    }
    Plasmoid.title: i18n("KPictureFrame")
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    toolTipMainText: Plasmoid.title

    // Darstellungen binden das zentrale Modell
    fullRepresentation: FullRepresentation {
        id: full
    }

    compactRepresentation: MouseArea {
        id: compact

        implicitWidth: Kirigami.Units.iconSizes.medium
        implicitHeight: Kirigami.Units.iconSizes.medium
    }

}