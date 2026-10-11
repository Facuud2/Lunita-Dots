import QtQuick

Item {
    id: viewRoot

    required property var notifState

    width: 360
    implicitWidth: 360
    height: cardsColumn.height
    implicitHeight: cardsColumn.height

    Column {
        id: cardsColumn
        width: parent.width
        spacing: 8
        anchors.bottom: parent.bottom

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: viewRoot.notifState.activePopups

            delegate: NotificationCard {
                id: card
                required property var modelData
                required property int index

                notifData: card.modelData
                notifState: viewRoot.notifState
                width: cardsColumn.width

                onRequestDismiss: id => {
                    viewRoot.notifState.dismissPopup(id);
                }

                onRequestAction: (id, actionIndex) => {
                    viewRoot.notifState.invokeAction(id, actionIndex);
                }
            }
        }
    }
}
