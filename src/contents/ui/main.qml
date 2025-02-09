/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import "../js/meta.js" as Meta

Item {
    id: root

    Component.onCompleted: {
        plasmoid.setAction("showAboutDialog", i18n('About %1…', Meta.title))
        plasmoid.setAction("checkUpdateAvailability", i18n("Check update…"))
    }

    function action_checkUpdateAvailability() {
        updateChecker.checkUpdateAvailability(true)
    }

    function action_showAboutDialog() {
        aboutDialog.visible = true
    }

    AboutDialog {
        id: aboutDialog
    }

    // ------------------------------------------------------------------------------------------------------------------------

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: ExchangeContainer {}

    // ------------------------------------------------------------------------------------------------------------------------

    Plasmoid.backgroundHints: (typeof PlasmaCore.Types.ConfigurableBackground !== "undefined"
        ? PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
        : plasmoid.configuration.containerLayoutTransparentBackgroundEnabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground
    )

    // ------------------------------------------------------------------------------------------------------------------------

    UpdateChecker {
        id: updateChecker

        // Check once every 7 days
        checkInterval: (((1000 * 60) * 60) * 24 * 7)
    }
}
