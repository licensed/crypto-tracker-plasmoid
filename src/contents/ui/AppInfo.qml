/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../js/meta.js" as Meta

ColumnLayout {
    id: aboutMainContainer

    anchors.centerIn: parent
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.margins: 30

    Image {
        id: aboutLogo
        Layout.alignment: Qt.AlignHCenter
        fillMode: Image.PreserveAspectFit
        source: plasmoid.file("", "images/logo.png")
    }

    PlasmaExtras.Label {
        Layout.alignment: Qt.AlignHCenter
        textFormat: Text.PlainText
        font.bold: true
        font.pixelSize: Qt.application.font.pixelSize * 1.5
        text: Meta.title + " v" + Meta.version
    }

    CopyrightLabel {
        Layout.alignment: Qt.AlignHCenter
    }

    Item {
        height: 20
    }

    ClickableLabel {
        Layout.alignment: Qt.AlignHCenter
        text: i18n("Visit <u>project page</u> on Github")
        url: Meta.url
    }
}
