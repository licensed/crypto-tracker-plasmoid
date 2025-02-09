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
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../../js/crypto.js" as Crypto
import ".."

Item {
    id: configExchanges

    Layout.fillWidth: true

    property alias cfg_exchanges: serializedExchanges.text

    Text {
        id: serializedExchanges
        visible: false
        onTextChanged: {
            exchangesModel.clear()
            JSON.parse(serializedExchanges.text).forEach(
                ex => exchangesModel.append(ex)
            )
        }
    }

    ListModel {
        id: exchangesModel
    }

    RowLayout {
        anchors.fill: parent

        Layout.alignment: Qt.AlignTop | Qt.AlignRight

        TableView {
            id: exchangesTable
            model: exchangesModel
            Layout.fillWidth: true
            selectionModel: ItemSelectionModel {}

            columnSpacing: 10
            rowSpacing: 5

            delegate: Item {
                Kirigami.Label {
                    text: {
                        if ((model.index >= 0) && (model.display !== '')) {
                            switch (model.column) {
                                case 0: {
                                    var ex = exchangesModel.get(model.index)
                                    var res = ex['enabled'] ? '' : '(L) '
                                    return res + Crypto.getExchangeName(ex['exchange'])
                                }
                                case 1: return Crypto.getCryptoName(model.display)
                                case 2: return Crypto.getCurrencyName(model.display)
                            }
                        }
                        return '??? row/col: ' + model.index + '/' + model.column + ' val: ' + model.display
                    }
                }
            }

            TableViewColumn {
                role: "exchange"
                title: "Exchange"
            }
            TableViewColumn {
                role: "crypto"
                title: "Crypto"
            }
            TableViewColumn {
                role: "pair"
                title: "Pair"
            }

            onDoubleClicked: editExchange(exchangesTable.selectionModel.currentIndex.row)
        }

        ColumnLayout {
            id: tableActionButtons
            anchors.top: parent.top

            Button {
                text: i18n("Add")
                icon.name: "list-add"
                onClicked: addExchange()
            }

            Button {
                text: i18n("Edit")
                icon.name: "edit-entry"
                onClicked: editExchange(exchangesTable.selectionModel.currentIndex.row)
                enabled: exchangesTable.selectionModel.hasSelection
            }

            Button {
                text: i18n("Remove")
                icon.name: "list-remove"
                onClicked: removeExchange(exchangesTable.selectionModel.currentIndex.row)
                enabled: exchangesTable.selectionModel.hasSelection
            }

            Button {
                text: i18n("Move Up")
                icon.name: "arrow-up"
                onClicked: moveExchange(-1)
                enabled: exchangesTable.selectionModel.currentIndex.row > 0
            }

            Button {
                text: i18n("Move Down")
                icon.name: "arrow-down"
                onClicked: moveExchange(1)
                enabled: exchangesTable.selectionModel.currentIndex.row < exchangesModel.count - 1
            }
        }
    }

    property int selectedRow: -1

    function saveExchanges() {
        var exchanges = []
        for (var i = 0; i < exchangesModel.count; i++) {
            exchanges.push(exchangesModel.get(i))
        }
        serializedExchanges.text = JSON.stringify(exchanges)
    }

    function addExchange() {
        exchange.init()
        selectedRow = -1
        exchangeEditDialog.open()
    }

    function editExchange(idx) {
        if (idx === -1 || idx >= exchangesModel.count) return

        exchange.fromJson(exchangesModel.get(idx))
        selectedRow = idx
        exchangeEditDialog.open()
    }

    function removeExchange(idx) {
        if (idx === -1 || idx >= exchangesModel.count) return

        exchangesModel.remove(idx)
        saveExchanges()
    }

    function moveExchange(direction) {
        var from = exchangesTable.selectionModel.currentIndex.row
        var to = from + direction
        if (to < 0 || to >= exchangesModel.count) return

        var item = exchangesModel.get(from)
        exchangesModel.remove(from)
        exchangesModel.insert(to, item)
        exchangesTable.selectionModel.setCurrentIndex(to)
        saveExchanges()
    }

    Dialog {
        id: exchangeEditDialog
        title: i18n("Exchange")
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            var ex = exchange.toJson()
            if (selectedRow === -1) {
                exchangesModel.append(ex)
            } else {
                exchangesModel.set(selectedRow, ex)
            }
            saveExchanges()
        }

        ExchangeConfig {
            id: exchange
        }
    }
}

