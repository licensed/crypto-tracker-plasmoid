/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Label {
    // URL to open once the label is clicked.
    property string url: ""

    // Optional label to be shown. If not provided, URL will be used as label.
    text: url

    textFormat: Text.RichText

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (url !== "") {
                PlasmaCore.Api.openUrlExternally(url)
            } else {
                console.debug('No URL provided.')
            }
        }
    }
}


