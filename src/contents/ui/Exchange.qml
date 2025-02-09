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
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import "../js/crypto.js" as Crypto

GridLayout {
    id: tickerRoot

    columns: 4
    rows: 1

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true

    property var json: undefined
    property string exchange: ''
    property string crypto: ''
    property bool hideCryptoLogo: false
    property string pair: ''
    property bool useCustomLocale: false
    property string customLocaleName: ''
    property int refreshRate: 5
    property bool hidePriceDecimals: false
    property bool showPriceChangeMarker: true
    property bool showTrendingMarker: true
    property int trendingTimeSpan: 60
    property bool flashOnPriceRaise: true
    property string flashOnPriceRaiseColor: '#78c625'
    property bool flashOnPriceDrop: true
    property string flashOnPriceDropColor: '#ff006e'
    property string markerColorPriceRaise: '#78c625'
    property string markerColorPriceDrop: '#ff006e'

    // Initialize properties from JSON
    Component.onCompleted: {
        if (json !== undefined) {
            exchange = json.exchange
            crypto = json.crypto
            hideCryptoLogo = json.hideCryptoLogo
            pair = json.pair
            refreshRate = json.refreshRate
            hidePriceDecimals = json.hidePriceDecimals
            useCustomLocale = json.useCustomLocale
            customLocaleName = json.customLocaleName
            showPriceChangeMarker = json.showPriceChangeMarker
            showTrendingMarker = json.showTrendingMarker
            trendingTimeSpan = json.trendingTimeSpan
            flashOnPriceRaise = json.flashOnPriceRaise
            flashOnPriceRaiseColor = json.flashOnPriceRaiseColor
            flashOnPriceDrop = json.flashOnPriceDrop
            flashOnPriceDropColor = json.flashOnPriceDropColor
            markerColorPriceRaise = json.markerColorPriceRaise
            markerColorPriceDrop = json.markerColorPriceDrop
        }
    }

    // React to property changes
    onExchangeChanged: fetchRate(exchange, crypto, pair)
    onCryptoChanged: fetchRate(exchange, crypto, pair)
    onPairChanged: fetchRate(exchange, crypto, pair)

    function getDirectionColor(direction, colorUp, colorDown) {
        return (direction === +1) ? colorUp : (direction === -1) ? colorDown : '#ffffff'
    }

    property var lastTrendingUpdateStamp: 0
    property var lastTrendingRate: 0
    property int trendingDirection: 0
    property bool trendingCalculated: false

    function invalidateExchangeData() {
        lastTrendingUpdateStamp = 0
        lastTrendingRate = 0
        trendingDirection = 0
        trendingCalculated = false
        currentRate = 0
        currentRateValid = false
        lastRate = 0
        lastRateValid = false
        rateChangeDirection = 0
        rateChangeDirectionCalculated = false
    }

    function updateTrending(rate) {
        var now = new Date()
        var updateTrending = false
        if (lastTrendingUpdateStamp !== 0 && (now.getTime() - lastTrendingUpdateStamp) >= (trendingTimeSpan * 60 * 1000)) {
            trendingDirection = (rate > lastTrendingRate) ? 1 : (rate < lastTrendingRate) ? -1 : 0
            updateTrending = true
            trendingCalculated = true
        }

        if (lastTrendingUpdateStamp === 0 || updateTrending) {
            lastTrendingUpdateStamp = now.getTime()
            lastTrendingRate = rate
        }
    }

    function getTrendingMarkerText() {
        var color = getDirectionColor(trendingDirection, markerColorPriceRaise, markerColorPriceDrop)
        var rateText = ''
        if (trendingCalculated && (trendingDirection !== 0)) {
            rateText += '<span style="color: ' + color + ';">'
            rateText += (trendingDirection === +1) ? '↑' : (trendingDirection === -1) ? '↓' : ''
            rateText += '</span> '
        }
        return rateText
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (!dataDownloadInProgress) {
                tickerRoot.opacity = 0.5
                fetchRate(exchange, crypto, pair)
            }
        }
    }

    function getRateChangeMarkerText() {
        var color = getDirectionColor(rateChangeDirection, markerColorPriceRaise, markerColorPriceDrop)
        var rateText = ''
        if (rateChangeDirection !== 0) {
            rateText += ' <span style="color: ' + color + ';">'
            rateText += (rateChangeDirection === +1) ? '▲' : (rateChangeDirection === -1) ? '▼' : ''
            rateText += '</span>'
        }
        return rateText
    }

    function getCurrentRateText() {
        if (!currentRateValid) return '---'
        var rate = hidePriceDecimals ? Math.round(currentRate) : currentRate
        var localeName = useCustomLocale ? customLocaleName : ''
        var rateText = Number(rate).toLocaleCurrencyString(Qt.locale(localeName), Crypto.getCurrencySymbol(pair))
        return hidePriceDecimals ? rateText.replace(Qt.locale(localeName).decimalPoint + '00', '') : rateText
    }

    Rectangle {
        id: bgWall
        anchors.fill: parent
        opacity: 0
    }

    Timer {
        id: bgWallFadeTimer
        interval: 100
        running: false
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            bgWall.opacity = (bgWall.opacity > 0) ? (bgWall.opacity -= 0.1) : 0
            running = (bgWall.opacity !== 0)
        }
    }

    Image {
        id: cryptoIcon
        visible: !hideCryptoLogo
        width: 20
        height: 20
        source: plasmoid.file('', 'images/' + Crypto.getCryptoIcon(crypto))
    }

    PlasmaComponents.Label {
        visible: showTrendingMarker
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignHCenter
        height: 20
        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        text: getTrendingMarkerText()
    }

    PlasmaComponents.Label {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignHCenter
        height: 20
        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        text: getCurrentRateText()
    }

    PlasmaComponents.Label {
        visible: showPriceChangeMarker
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignHCenter
        height: 16
        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        minimumPixelSize: 8
        text: getRateChangeMarkerText()
    }

    property bool dataDownloadInProgress: false
    function fetchRate(exchange, crypto, pair) {
        if (dataDownloadInProgress) return
        if (!Crypto.exchangeExists(exchange)) return
        if (!Crypto.isCryptoSupported(exchange, crypto)) return
        if (!Crypto.isPairSupported(exchange, crypto, pair)) return
        dataDownloadInProgress = true

        downloadExchangeRate(exchange, crypto, pair, function(rate) {
            var now = new Date()
            lastUpdateMillis = now.getTime()
            if (currentRateValid) {
                lastRate = currentRate
                lastRateValid = true
            }
            currentRate = rate
            currentRateValid = true

            if (lastRateValid) {
                var lastRateChangeDirection = rateChangeDirection
                rateChangeDirection = (currentRate > lastRate) ? 1 : (currentRate < lastRate) ? -1 : 0
                rateDirectionChanged = (lastRateChangeDirection !== rateChangeDirection)
                rateChangeDirectionCalculated = true
            }

            updateTrending(currentRate)
        })
    }

    function downloadExchangeRate(exchangeId, crypto, pair, callback) {
        var exchange = Crypto.exchanges[exchangeId]
        var url = exchange.api_url.replace('{crypto}', crypto).replace('{pair}', pair)
        request(url, function(data) {
            if (data.length !== 0) {
                try {
                    var json = JSON.parse(data)
                    callback(exchange.getRateFromExchangeData(json, crypto, pair))
                } catch (error) {
                    console.error("Download failed for URL: " + url)
                }
            }
            tickerRoot.opacity = 1
            dataDownloadInProgress = false
        })
    }

    function request(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                callback(xhr.responseText)
            }
        }
        xhr.open('GET', url, true)
        xhr.send('')
    }
}
