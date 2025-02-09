/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../../js/crypto.js" as Crypto
import ".."

Kirigami.FormLayout {
    Layout.fillWidth: true
    id: controlRoot

    property alias cfg_customContainerLayoutEnabled: customContainerLayoutEnabled.checked
    property alias cfg_containerLayoutRows: layoutRows.value
    property alias cfg_containerLayoutColumns: layoutColumns.value
    property alias cfg_containerLayoutTransparentBackgroundEnabled: transparentBackground.checked

    // ------------------------------------------------------------------------------------------------------------------------

    CheckBox {
        id: customContainerLayoutEnabled
        text: i18n("Use custom grid layout")
        checked: cfg_customContainerLayoutEnabled
    }

    SpinBox {
        id: layoutRows
        editable: true
        from: 1
        to: 25
        stepSize: 1
        Kirigami.FormData.label: i18n("Rows")
        value: cfg_containerLayoutRows
        enabled: cfg_customContainerLayoutEnabled
    }

    SpinBox {
        id: layoutColumns
        editable: true
        from: 1
        to: 25
        stepSize: 1
        Kirigami.FormData.label: i18n("Columns")
        value: cfg_containerLayoutColumns
        enabled: cfg_customContainerLayoutEnabled
    }

    CheckBox {
        id: transparentBackground
        text: i18n("Transparent background")
        checked: cfg_containerLayoutTransparentBackgroundEnabled
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
