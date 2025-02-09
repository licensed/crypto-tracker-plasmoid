/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.15
import QtQuick.Controls 6.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.SettingsCategory {
    id: configRoot
    categoryList.model: ListModel {
        ListElement {
            name: i18n("Exchanges")
            icon: "taxes-finances"
            source: "config/Exchanges.qml"
        }
        ListElement {
            name: i18n("Layout")
            icon: "window"
            source: "config/Layout.qml"
        }
        ListElement {
            name: i18n("About")
            icon: "view-visible"
            source: "config/About.qml"
        }
    }
}

