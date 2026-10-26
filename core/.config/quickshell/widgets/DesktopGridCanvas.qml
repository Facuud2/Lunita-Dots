import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState
    property string screenName: "default"
    property var framesMap: ({
    })
    readonly property bool isEditing: root.widgetsState ? root.widgetsState.isEditing : false
    readonly property bool isDarkTheme: root.widgetsState ? root.widgetsState.isDarkTheme : true
    readonly property color textColor: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"

    // ── Desktop Fullscreen Grid Metrics & Alignment ──
    readonly property real cellSize: 170
    readonly property real cellGap: 14
    readonly property int cols: Math.max(1, Math.floor((root.width - 40 + cellGap) / (cellSize + cellGap)))
    readonly property int rows: Math.max(1, Math.floor((root.height - 90 + cellGap) / (cellSize + cellGap)))
    readonly property real marginLeft: Math.max(20, (root.width - (cols * cellSize + (cols - 1) * cellGap)) / 2)
    readonly property real marginTop: Math.max(48, (root.height - (rows * cellSize + (rows - 1) * cellGap)) / 2)

    property var activeDragWidget: null
    property int activeDragCol: -1
    property int activeDragRow: -1
    property int activeDragColSpan: 1
    property int activeDragRowSpan: 1
    property int dragOrigCol: -1
    property int dragOrigRow: -1

    function colToX(c) {
        return Math.round(marginLeft + c * (cellSize + cellGap));
    }

    function rowToY(r) {
        return Math.round(marginTop + r * (cellSize + cellGap));
    }

    function xToCol(px, span) {
        var s = span || 1;
        var widthPx = s * cellSize + (s - 1) * cellGap;
        var centerX = px + widthPx / 2.0;
        var step = cellSize + cellGap;
        var c = Math.round(((centerX - marginLeft) / step) - (s / 2.0));
        return Math.max(0, Math.min(cols - s, c));
    }

    function yToRow(py, span) {
        var s = span || 1;
        var heightPx = s * cellSize + (s - 1) * cellGap;
        var centerY = py + heightPx / 2.0;
        var step = cellSize + cellGap;
        var r = Math.round(((centerY - marginTop) / step) - (s / 2.0));
        return Math.max(0, Math.min(rows - s, r));
    }

    // ── iOS Dwell Timer para Reordenamiento Suave (Dodge) ──
    Timer {
        id: dwellTimer
        interval: 340 // 340ms: umbral óptimo de iOS/macOS antes de apartar widgets
        repeat: false
        onTriggered: {
            if (activeDragWidget && activeDragCol >= 0 && activeDragRow >= 0) {
                executeReflow(activeDragWidget, activeDragCol, activeDragRow, activeDragColSpan, activeDragRowSpan);
            }
        }
    }

    function onWidgetDragStarted(frame) {
        dwellTimer.stop();
        activeDragWidget = frame;
        activeDragColSpan = (frame.width > 260) ? 2 : 1;
        activeDragRowSpan = (frame.height > 260) ? 2 : 1;
        dragOrigCol = xToCol(frame.x, activeDragColSpan);
        dragOrigRow = yToRow(frame.y, activeDragRowSpan);
        activeDragCol = dragOrigCol;
        activeDragRow = dragOrigRow;
    }

    function onWidgetDragMoved(frame, currentX, currentY) {
        if (!activeDragWidget || activeDragWidget !== frame)
            return;

        var targetCol = xToCol(currentX, activeDragColSpan);
        var targetRow = yToRow(currentY, activeDragRowSpan);

        if (targetCol !== activeDragCol || targetRow !== activeDragRow) {
            activeDragCol = targetCol;
            activeDragRow = targetRow;

            // Verificar si en la nueva posición hay colisión
            var collist = checkCollisions(frame, targetCol, targetRow, activeDragColSpan, activeDragRowSpan);
            if (collist.length > 0) {
                dwellTimer.restart();
            } else {
                dwellTimer.stop();
            }
        }
    }

    function checkCollisions(draggedFrame, tCol, tRow, tColSpan, tRowSpan) {
        var collided = [];
        for (var idKey in framesMap) {
            var f = framesMap[idKey];
            if (!f || f === draggedFrame || !f.widgetData)
                continue;

            var fColSpan = (f.width > 260) ? 2 : 1;
            var fRowSpan = (f.height > 260) ? 2 : 1;
            var fCol = xToCol(f.x, fColSpan);
            var fRow = yToRow(f.y, fRowSpan);

            var overlaps = (Math.max(tCol, fCol) < Math.min(tCol + tColSpan, fCol + fColSpan)) &&
                           (Math.max(tRow, fRow) < Math.min(tRow + tRowSpan, fRow + fRowSpan));

            if (overlaps) {
                collided.push({ frame: f, col: fCol, row: fRow, colSpan: fColSpan, rowSpan: fRowSpan });
            }
        }
        return collided;
    }

    function executeReflow(draggedFrame, tCol, tRow, tColSpan, tRowSpan) {
        var collided = checkCollisions(draggedFrame, tCol, tRow, tColSpan, tRowSpan);
        if (collided.length === 0)
            return;

        // Matriz de ocupación bidimensional: cols x rows
        var occ = [];
        for (var r = 0; r < rows; r++) {
            occ[r] = [];
            for (var c = 0; c < cols; c++) {
                occ[r][c] = false;
            }
        }

        // 1. Reservar las celdas del widget arrastrado en su destino
        for (var dr = tRow; dr < tRow + tRowSpan && dr < rows; dr++) {
            for (var dc = tCol; dc < tCol + tColSpan && dc < cols; dc++) {
                occ[dr][dc] = true;
            }
        }

        // 2. Marcar celdas de widgets estables (que no colisionan)
        for (var idKey in framesMap) {
            var other = framesMap[idKey];
            if (!other || other === draggedFrame || !other.widgetData)
                continue;

            var isCollided = false;
            for (var ci = 0; ci < collided.length; ci++) {
                if (collided[ci].frame === other) {
                    isCollided = true;
                    break;
                }
            }
            if (isCollided)
                continue;

            var oSpanX = (other.width > 260) ? 2 : 1;
            var oSpanY = (other.height > 260) ? 2 : 1;
            var oCol = xToCol(other.x, oSpanX);
            var oRow = yToRow(other.y, oSpanY);

            for (var or = oRow; or < oRow + oSpanY && or < rows; or++) {
                for (var oc = oCol; oc < oCol + oSpanX && oc < cols; oc++) {
                    occ[or][oc] = true;
                }
            }
        }

        // 3. Swap estilo iOS: 1 solo widget colisionado y cabe en el hueco original
        if (collided.length === 1 && dragOrigCol >= 0 && dragOrigRow >= 0) {
            var single = collided[0];
            var canSwap = true;
            if (dragOrigCol + single.colSpan > cols || dragOrigRow + single.rowSpan > rows) {
                canSwap = false;
            } else {
                for (var sr = dragOrigRow; sr < dragOrigRow + single.rowSpan; sr++) {
                    for (var sc = dragOrigCol; sc < dragOrigCol + single.colSpan; sc++) {
                        if (occ[sr][sc]) {
                            canSwap = false;
                            break;
                        }
                    }
                    if (!canSwap) break;
                }
            }

            if (canSwap) {
                var swapX = colToX(dragOrigCol);
                var swapY = rowToY(dragOrigRow);
                single.frame.x = swapX;
                single.frame.y = swapY;
                if (root.widgetsState)
                    root.widgetsState.updateWidgetPosition(root.screenName, single.frame.widgetData.id, swapX, swapY);
                return;
            }
        }

        // 4. Reubicación limpia para cada widget colisionado sin superposiciones
        for (var i = 0; i < collided.length; i++) {
            var item = collided[i];
            var bestSlot = findBestFreeSlotInOcc(occ, item.col, item.row, item.colSpan, item.rowSpan);
            if (bestSlot) {
                for (var br = bestSlot.row; br < bestSlot.row + item.rowSpan && br < rows; br++) {
                    for (var bc = bestSlot.col; bc < bestSlot.col + item.colSpan && bc < cols; bc++) {
                        occ[br][bc] = true;
                    }
                }
                var newX = colToX(bestSlot.col);
                var newY = rowToY(bestSlot.row);
                item.frame.x = newX;
                item.frame.y = newY;
                if (root.widgetsState)
                    root.widgetsState.updateWidgetPosition(root.screenName, item.frame.widgetData.id, newX, newY);
            }
        }
    }

    function findBestFreeSlotInOcc(occ, prefCol, prefRow, spanX, spanY) {
        var best = null;
        var bestDist = 999999;

        for (var r = 0; r <= rows - spanY; r++) {
            for (var c = 0; c <= cols - spanX; c++) {
                var free = true;
                for (var dr = 0; dr < spanY; dr++) {
                    for (var dc = 0; dc < spanX; dc++) {
                        if (occ[r + dr][c + dc]) {
                            free = false;
                            break;
                        }
                    }
                    if (!free) break;
                }

                if (free) {
                    var dist = Math.abs(c - prefCol) + Math.abs(r - prefRow);
                    if (dist < bestDist) {
                        bestDist = dist;
                        best = { col: c, row: r };
                    }
                }
            }
        }
        return best;
    }

    function onWidgetDragFinished(frame) {
        if (!frame || !frame.widgetData)
            return;

        dwellTimer.stop();

        var finalCol = activeDragCol;
        var finalRow = activeDragRow;
        if (finalCol < 0 || finalRow < 0) {
            finalCol = xToCol(frame.x, activeDragColSpan);
            finalRow = yToRow(frame.y, activeDragRowSpan);
        }

        // Ejecutar reflow inmediato si se suelta sobre una celda ocupada
        executeReflow(frame, finalCol, finalRow, activeDragColSpan, activeDragRowSpan);

        var snapX = colToX(finalCol);
        var snapY = rowToY(finalRow);

        frame.x = snapX;
        frame.y = snapY;

        if (root.widgetsState) {
            root.widgetsState.updateWidgetPosition(root.screenName, frame.widgetData.id, snapX, snapY);
            root.widgetsState.saveScreensLayout();
        }

        activeDragWidget = null;
        activeDragCol = -1;
        activeDragRow = -1;
        dragOrigCol = -1;
        dragOrigRow = -1;
    }

    function onWidgetResized(frame, finalW, finalH, sizeName) {
        if (!frame || !frame.widgetData)
            return;

        var colSpan = (finalW > 260) ? 2 : 1;
        var rowSpan = (finalH > 260) ? 2 : 1;
        var c = xToCol(frame.x, colSpan);
        var r = yToRow(frame.y, rowSpan);

        if (c + colSpan > cols)
            c = Math.max(0, cols - colSpan);
        if (r + rowSpan > rows)
            r = Math.max(0, rows - rowSpan);

        var snapX = colToX(c);
        var snapY = rowToY(r);

        frame.x = snapX;
        frame.y = snapY;

        executeReflow(frame, c, r, colSpan, rowSpan);

        if (root.widgetsState) {
            root.widgetsState.updateWidgetSize(root.screenName, frame.widgetData.id, finalW, finalH, sizeName);
            root.widgetsState.updateWidgetPosition(root.screenName, frame.widgetData.id, snapX, snapY);
            root.widgetsState.saveScreensLayout();
        }
    }

    // Helper forwarding methods for WidgetFrame and top bar
    function addWidget(type) {
        if (root.widgetsState)
            root.widgetsState.addWidget(root.screenName, type);

    }

    function resetLayout() {
        if (root.widgetsState)
            root.widgetsState.resetLayout(root.screenName);

    }

    function updateWidgetPosition(id, x, y) {
        if (root.widgetsState)
            root.widgetsState.updateWidgetPosition(root.screenName, id, x, y);

    }

    function updateWidgetSize(id, w, h, s) {
        if (root.widgetsState)
            root.widgetsState.updateWidgetSize(root.screenName, id, w, h, s);

    }

    function removeWidget(id) {
        if (root.widgetsState)
            root.widgetsState.removeWidget(root.screenName, id);

    }

    function toggleClockExpanded() {
        if (root.widgetsState)
            root.widgetsState.toggleClockExpanded(root.screenName);

    }

    function toggleMediaExpanded() {
        if (root.widgetsState)
            root.widgetsState.toggleMediaExpanded(root.screenName);

    }

    function toggleCalendarExpansion() {
        if (root.widgetsState)
            root.widgetsState.toggleCalendarExpansion(root.screenName);

    }

    function syncFrames() {
        if (!root.widgetsState)
            return ;

        var list = root.widgetsState.getScreenWidgets(root.screenName);
        if (!list || !Array.isArray(list))
            list = [];

        var newMap = Object.assign({
        }, framesMap);
        var seen = {
        };
        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            if (!item || !item.id)
                continue;

            seen[item.id] = true;
            var existing = newMap[item.id];
            if (!existing) {
                var obj = widgetFrameComp.createObject(widgetsContainer, {
                    "widgetData": item,
                    "canvas": root
                });
                newMap[item.id] = obj;
            } else {
                existing.applyData(item);
            }
        }
        for (var idKey in newMap) {
            if (!seen[idKey]) {
                if (newMap[idKey])
                    newMap[idKey].destroy();

                delete newMap[idKey];
            }
        }
        framesMap = newMap;
    }

    Component.onCompleted: {
        root.syncFrames();
    }

    // ── Background Canvas MouseArea: Dismiss keyboard focus when clicking desktop background ──
    MouseArea {
        anchors.fill: parent
        z: -1
        enabled: root.widgetsState ? root.widgetsState.wantsKeyboardFocus : false
        onClicked: {
            if (root.widgetsState)
                root.widgetsState.wantsKeyboardFocus = false;
        }
    }

    // ── Desktop Grid Guide (Red Visual Dinámica estilo Ryoku / iOS) ──
    DesktopGridGuide {
        id: gridGuide

        canvas: root
        cellSize: root.cellSize
        cellGap: root.cellGap
        cols: root.cols
        rows: root.rows
        marginLeft: root.marginLeft
        marginTop: root.marginTop
        activeDragCol: root.activeDragCol
        activeDragRow: root.activeDragRow
        activeDragColSpan: root.activeDragColSpan
        activeDragRowSpan: root.activeDragRowSpan
        isDragging: root.activeDragWidget !== null
    }

    // ── 1. Persistent Dynamic Widgets Container (No flickering/recreation) ──
    Item {
        id: widgetsContainer

        anchors.fill: parent
    }

    Component {
        id: widgetFrameComp

        WidgetFrame {
            widgetsState: root.widgetsState
            canvas: root
        }

    }

    Connections {
        function onScreensLayoutChanged() {
            root.syncFrames();
        }

        function onScreenLayoutChanged(targetScreen) {
            if (targetScreen === root.screenName || targetScreen === "all")
                root.syncFrames();

        }

        target: root.widgetsState
    }

    // ── 2. Top Edit Mode Header Bar (Visible only when editing) ──
    Rectangle {
        id: editTopBar

        z: 999
        visible: root.isEditing
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        height: 44
        implicitWidth: editBarRow.implicitWidth + 32
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.isDarkTheme ? Qt.rgba(0.14, 0.16, 0.2, 0.92) : Qt.rgba(0.96, 0.96, 0.98, 0.94)
        border.color: root.isDarkTheme ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.14)
        border.width: 1

        RowLayout {
            id: editBarRow

            anchors.centerIn: parent
            spacing: 8

            // Reset Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: resetText.implicitWidth + 16
                color: resetMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: resetText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "↺"
                        color: root.textColor
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Reset"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: resetMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.resetLayout()
                }

            }

            // Add Photos
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addPhoText.implicitWidth + 16
                color: addPhoMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addPhoText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Fotos"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addPhoMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("photos")
                }

            }

            // Add Calendar
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addCalText.implicitWidth + 16
                color: addCalMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addCalText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Calendario"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addCalMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("calendar")
                }

            }

            // Add Resources
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addSysText.implicitWidth + 16
                color: addSysMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addSysText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Actividad"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addSysMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("resources")
                }

            }

            // Add Clock
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addClkText.implicitWidth + 16
                color: addClkMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addClkText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Reloj"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addClkMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("clock")
                }

            }

            // Add Weather
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addWthText.implicitWidth + 16
                color: addWthMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addWthText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰖐"
                        font.family: "CaskaydiaCove Nerd Font"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Clima"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addWthMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("weather")
                }

            }

            // Add Files
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addFilesText.implicitWidth + 16
                color: addFilesMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addFilesText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Archivos"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addFilesMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("files")
                }

            }

            // Add Network
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addNetText.implicitWidth + 16
                color: addNetMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addNetText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Red"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addNetMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("network")
                }

            }

            // Add Battery
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addBatText.implicitWidth + 16
                color: addBatMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addBatText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Batería"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addBatMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("battery")
                }

            }

            // Add Git
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addGitText.implicitWidth + 16
                color: addGitMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addGitText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Git"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addGitMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("git")
                }

            }

            // Add Habits
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addHabText.implicitWidth + 16
                color: addHabMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addHabText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Salud"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addHabMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("habits")
                }

            }

            // Add Timetable
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addTtText.implicitWidth + 16
                color: addTtMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addTtText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Notas"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addTtMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("timetable")
                }

            }

            // Add Media
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addMedText.implicitWidth + 16
                color: addMedMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addMedText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "+"
                        color: root.textColor
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Música"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: addMedMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("media")
                }

            }

            // Settings "Ajustes" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: cfgText.implicitWidth + 20
                color: cfgMa.containsMouse ? (root.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: cfgText

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰒓"
                        font.family: "CaskaydiaCove Nerd Font"
                        color: root.widgetsState.accentBlue
                        font.pixelSize: 11
                    }

                    Text {
                        text: "Ajustes"
                        color: root.textColor
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                }

                MouseArea {
                    id: cfgMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
                }

            }

            // Done "Listo" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: doneText.implicitWidth + 24
                color: doneMa.containsMouse ? "#0088FF" : "#007AFF"

                Text {
                    id: doneText

                    anchors.centerIn: parent
                    text: "Listo"
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: doneMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.toggleEdit()
                }

            }

        }

    }

}
