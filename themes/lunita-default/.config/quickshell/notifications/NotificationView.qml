import QtQuick
import QtQuick.Layouts

Item {
    id: viewRoot

    required property var notifState

    implicitWidth: 390
    width: 390
    implicitHeight: cardsColumn.implicitHeight

    ColumnLayout {
        id: cardsColumn
        width: parent.width
        spacing: 10

        Repeater {
            model: notifState.activeList

            delegate: NotificationCard {
                id: card
                required property var modelData
                required property int index

                notifData: card.modelData
                notifState: viewRoot.notifState

                onRequestDismiss: id => {
                    notifState.dismiss(id);
                }

                onRequestAction: (id, actionIndex) => {
                    notifState.invokeAction(id, actionIndex);
                }
            }
        }
    }
}
