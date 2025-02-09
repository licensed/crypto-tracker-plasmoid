/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.15
import "../js/meta.js" as Meta
import org.kde.plasma.components 3.0 as PlasmaComponents

PlasmaComponents.Label {
    url: Meta.authorUrl

    text: {
        var currentYear = new Date().getFullYear()
        var year = '' + Meta.firstReleaseYear
        if (Meta.firstReleaseYear < currentYear) {
            year += '-' + currentYear
        }

        return '&copy;' + year + ' by <strong><u>' + Meta.authorName + '</u></strong>'
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (url !== "") {
                Qt.openUrlExternally(url)
            } else {
                console.debug('No URL provided.')
            }
        }
    }
}
