/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto

ColumnLayout {
    Layout.fillWidth: true

    property bool running: true

    property string exchange: undefined
    property string crypto: undefined
    property string fiat: undefined
    property int refreshRate: 5                 // minutes
    property bool hidePriceDecimals: false

    property bool useCustomLocale: false
    property string customLocaleName: ''

    property bool showPriceChangeMarker: true

    property bool showTrendingMarker: true
    property int trendingTimeSpan: 60          // minutes

    // ------------------------------------------------------------------------------------------------------------------------

    onExchangeChanged: updateModels()
    onCryptoChanged: updateModels()
    onFiatChanged: updateModels()

    function updateModels() {
        if (typeof exchange === 'undefined' || exchange === '') {
            // console.error(`Undefined exchange or empty: '${exchange}'`)
            return
        }
        if (typeof crypto === 'undefined' || crypto === '') {
            // console.error(`Undefined crypto or empty: '${crypto}'`)
        }
        if (typeof fiat !== 'undefined' || fiat !== '') {
            // console.error(`Undefined fiat or empty: '${fiat}'`)
        }

        exchangeComboBox.updateModel(exchange)
        cryptoComboBox.updateModel(exchange, crypto)
        // check if current value of crypto is supported by new exchange.
        // In such case fallback to first supported crypto.
        if (!Crypto.isCryptoSupported(exchange, crypto)) {
            var cryptos = Crypto.getAllExchangeCryptos(exchange)
            crypto = cryptos[0]
            cryptoComboBox.updateModel(exchange, cryptos)
        }

        fiatComboBox.updateModel(exchange, crypto, fiat)
    }

    // ------------------------------------------------------------------------------------------------------------------------

    CheckBox {
        text: i18n("Exchange enabled")
        checked: running
        onCheckedChanged: running = checked
    }

    // ------------------------------------------------------------------------------------------------------------------------

    Kirigami.FormLayout {
        enabled: running

        Layout.fillWidth: true

        PlasmaComponents.ComboBox {
            id: exchangeComboBox
            Kirigami.FormData.label: i18n('Exchange')
            textRole: "text"
            // Component.onCompleted: populateExchageModel()
            onCurrentIndexChanged: exchange = model[currentIndex]['value']

            function updateModel(exchange) {
                var tmp = []
                var idx = 0
                var currentIdx = 0
                for(const key in Crypto.exchanges) {
                    tmp.push({'value': key, 'text': Crypto.getExchangeName(key)})
                    if (key === exchange) currentIdx = idx
                    idx++
                }
                model = tmp
                currentIndex = currentIdx
            }

            Component.onCompleted: updateModel(exchange)
        }

        // ------------------------------------------------------------------------------------------------------------------------

        PlasmaComponents.ComboBox {
            id: cryptoComboBox
            Kirigami.FormData.label: i18n('Crypto')
            textRole: "text"
            onCurrentIndexChanged: {
                console.debug(`cryptoComboBox::onCurrentIndexChanged(): crypto: ${model[currentIndex]['value']}, currentIndex: ${currentIndex}`)
                crypto = model[currentIndex]['value']
            }

            function updateModel(exchange, crypto) {
                console.debug(`cryptoComboBox::updateModel() ex: ${exchange}, crypto: ${crypto}`)

                var tmp = []
                var currentIdx = 0
                if (exchange in Crypto.exchanges) {
                    var tmp = Crypto.getAllExchangeCryptos(exchange);
                    for (var i=0; i<tmp.length; i++) {
                        if (tmp[i].value == crypto) currentIdx = i
                    }
                }
                model = tmp
                currentIndex = currentIdx
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        PlasmaComponents.ComboBox {
            id: fiatComboBox
            Kirigami.FormData.label: i18n('Fiat')
            textRole: "text"
            onCurrentIndexChanged: fiat = model[currentIndex]['value']

            function updateModel(exchange, crypto, fiat) {
                console.debug(`fiatComboBox::updateModel() ex: ${exchange}, crypto: ${crypto}, fiat: ${fiat}`)

                var tmp = []
                var currentIdx = 0
                if ((exchange in Crypto.exchanges) && (crypto in Crypto.exchanges[exchange]['pairs'])) {
                    tmp = Crypto.getFiatsForCrypto(exchange, crypto)
                    for (var i=0; i<tmp.length; i++) {
                        if (tmp[i].value === fiat) currentIdx = i
                    }
                }
                model = tmp
                currentIndex = currentIdx
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        PlasmaComponents.SpinBox {
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Update interval (minutes)")
            value: refreshRate
            onValueChanged: refreshRate = value
        }

        // FIXME should be per Pair as we may have i.e. LTCBTC pair soon
        // and this would make no sense then.
        PlasmaComponents.CheckBox {
            text: i18n("Hide price decimals")
            checked: hidePriceDecimals
            onCheckedChanged: hidePriceDecimals = checked
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            CheckBox {
                text: i18n("Locale to use")
                checked: useCustomLocale
                onCheckedChanged: useCustomLocale = checked
            }

            TextField {
                enabled: useCustomLocale
                placeholderText: "en_US"
                text: customLocaleName
                onTextChanged: customLocaleName = text
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        CheckBox {
            text: i18n("Show price change marker")
            checked: showPriceChangeMarker
            onCheckedChanged: showPriceChangeMarker = checked
        }

        CheckBox {
            text: i18n("Show trending marker")
            checked: showTrendingMarker
            onCheckedChanged: showTrendingMarker = checked
        }

        PlasmaComponents.SpinBox {
            enabled: showTrendingMarker
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Time span (minutes)")
            value: trendingTimeSpan
            onValueChanged: trendingTimeSpan = value
        }

        // ------------------------------------------------------------------------------------------------------------------------
    }

    // ------------------------------------------------------------------------------------------------------------------------
}