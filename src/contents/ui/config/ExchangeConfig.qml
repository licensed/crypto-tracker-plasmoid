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

ColumnLayout {
    Layout.fillWidth: true

    property string exchange: undefined
    property string crypto: undefined
    property string pair: undefined

    function init() {
        fromJson({
            'enabled': true,
            'exchange': Crypto.getExchageIds()[0],
            'crypto': Crypto.BTC,
            'hideCryptoLogo': false,
            'pair': Crypto.USD,
            'refreshRate': 15,
            'hidePriceDecimals': false,
            'useCustomLocale': false,
            'customLocaleName': '',
            'showPriceChangeMarker': true,
            'showTrendingMarker': true,
            'trendingTimeSpan': 60,
            'flashOnPriceRaise': true,
            'flashOnPriceRaiseColor': '#78c625',
            'flashOnPriceDrop': true,
            'flashOnPriceDropColor': '#ff006e',
            'markerColorPriceRaise': '#78c625',
            'markerColorPriceDrop': '#ff006e',
        })
    }

    function fromJson(json) {
        console.debug(json)
        exchangeEnabled.checked = json.enabled
        exchange = json.exchange
        crypto = json.crypto
        hideCryptoLogo.checked = json.hideCryptoLogo
        pair = json.pair
        refreshRate.value = json.refreshRate
        hidePriceDecimals.checked = json.hidePriceDecimals
        useCustomLocale.checked = json.useCustomLocale
        customLocaleName.text = json.customLocaleName
        showPriceChangeMarker.checked = json.showPriceChangeMarker
        showTrendingMarker.checked = json.showTrendingMarker
        trendingTimeSpan.value = json.trendingTimeSpan
        flashOnPriceRaise.checked = json.flashOnPriceRaise
        flashOnPriceRaiseColor.color = json.flashOnPriceRaiseColor
        flashOnPriceDrop.checked = json.flashOnPriceDrop
        flashOnPriceDropColor.color = json.flashOnPriceDropColor
        markerColorPriceRaise.color = json.markerColorPriceRaise
        markerColorPriceDrop.color = json.markerColorPriceDrop
    }

    function updateModels() {
        if (!exchange || exchange === '') {
            return
        }
        if (!crypto || crypto === '' || !Crypto.isCryptoSupported(exchange, crypto)) {
            let cryptos = Crypto.getAllExchangeCryptos(exchange);
            crypto = cryptos[0].value
        }
        if (!pair || pair === '' || !Crypto.isPairSupported(exchange, crypto, pair)) {
            let pairs = Crypto.getPairsForCrypto(exchange, crypto)
            pair = pairs[0].value
        }
        exchangeComboBox.updateModel(exchange)
        cryptoComboBox.updateModel(exchange, crypto)
        pairComboBox.updateModel(exchange, crypto, pair)
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        CheckBox {
            id: exchangeEnabled
            Kirigami.FormData.label: i18n('Enabled')
            checked: true
        }

        ComboBox {
            id: exchangeComboBox
            enabled: exchangeEnabled.checked
            Kirigami.FormData.label: i18n('Exchange')
            textRole: "text"
            onCurrentIndexChanged: exchange = model[currentIndex]['value']

            function updateModel(exchange) {
                let tmp = []
                let currentIdx = 0
                Object.keys(Crypto.exchanges).forEach((key, idx) => {
                    tmp.push({'value': key, 'text': Crypto.getExchangeName(key)})
                    if (key === exchange) currentIdx = idx
                })
                model = tmp
                currentIndex = currentIdx
            }

            Component.onCompleted: updateModel(exchange)
        }

        PlasmaExtras.SpinBox {
            id: refreshRate
            enabled: exchangeEnabled.checked
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Update interval (minutes)")
        }

        RowLayout {
            Kirigami.FormData.label: i18n('Crypto')
            enabled: exchangeEnabled.checked

            ComboBox {
                id: cryptoComboBox
                textRole: "text"
                onCurrentIndexChanged: crypto = model[currentIndex]['value']

                function updateModel(exchange, crypto) {
                    let tmp = []
                    let currentIdx = 0
                    if (exchange in Crypto.exchanges) {
                        tmp = Crypto.getAllExchangeCryptos(exchange)
                        tmp.forEach((item, i) => {
                            if (item.value === crypto) currentIdx = i
                        })
                    }
                    model = tmp
                    currentIndex = currentIdx
                    crypto = model[currentIndex]?.value || ''
                }
            }

            CheckBox {
                id: hideCryptoLogo
                text: i18n("Hide currency icon")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n('Pair')
            enabled: exchangeEnabled.checked

            ComboBox {
                id: pairComboBox
                textRole: "text"
                onCurrentIndexChanged: pair = model[currentIndex]['value']

                function updateModel(exchange, crypto, pair) {
                    let tmp = []
                    let currentIdx = 0
                    if (Crypto.exchanges[exchange]?.pairs?.[crypto]) {
                        tmp = Crypto.getPairsForCrypto(exchange, crypto)
                        tmp.forEach((item, i) => {
                            if (item.value === pair) currentIdx = i
                        })
                    }
                    model = tmp
                    currentIndex = currentIdx
                    pair = model[currentIndex]?.value || ''
                }
            }
        }
    }
}
