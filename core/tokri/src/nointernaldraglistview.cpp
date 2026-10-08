#include "nointernaldraglistview.h"

#include "loghelpers.h"
#include "themeprovider.h"

#include <QDragEnterEvent>
#include <QGuiApplication>
#include <QMouseEvent>

namespace {

void preferCopy(QDropEvent *e)
{
    if (e->isAccepted()) {
        e->setDropAction(Qt::CopyAction);
        e->accept();
    }
}

}

NoInternalDragListView::NoInternalDragListView() {}

void NoInternalDragListView::startDrag(Qt::DropActions supportedActions)
{
    const Qt::KeyboardModifiers mods = QGuiApplication::keyboardModifiers();
#ifdef Q_OS_MACOS
    const bool copy = mods.testFlag(Qt::AltModifier);
    if (copy) {
        supportedActions = Qt::CopyAction;
    }
#else
    const bool copy = mods.testFlag(Qt::ControlModifier);
#endif
    setDefaultDropAction(copy ? Qt::CopyAction : Qt::MoveAction);
    QListView::startDrag(supportedActions);
}

QItemSelectionModel::SelectionFlags
NoInternalDragListView::selectionCommand(const QModelIndex &index,
                                         const QEvent *event) const
{
    if (event && event->type() == QEvent::MouseButtonPress) {
        const auto *mouseEvent = static_cast<const QMouseEvent *>(event);
        if (mouseEvent->button() == Qt::RightButton
            && selectionModel()
            && selectionModel()->hasSelection())
            return QItemSelectionModel::NoUpdate;
    }

    return QListView::selectionCommand(index, event);
}

void NoInternalDragListView::dragEnterEvent(QDragEnterEvent *e)
{
    const bool isSelf = e->source() == this;
    if (isSelf)
        e->ignore();
    else {
        emit dropping(true);
        QListView::dragEnterEvent(e);
        preferCopy(e);
    }
}

void NoInternalDragListView::dragMoveEvent(QDragMoveEvent *e)
{
    const bool isSelf = e->source() == this;
    if (isSelf)
        e->ignore();
    else {
        QListView::dragMoveEvent(e);
        preferCopy(e);
    }
}

void NoInternalDragListView::dragLeaveEvent(QDragLeaveEvent *e)
{
    Logger &log = Logger::instance();
    log.push("dragLeave");
    log.log() << "leave";

    emit dropping(false);

    QListView::dragLeaveEvent(e);

    log.pop();
}

void NoInternalDragListView::dropEvent(QDropEvent *e)
{
    Logger &log = Logger::instance();
    log.push("dropEvent");

    log.log() << "source==this=" << (e->source() == this)
              << "dropAction=" << e->dropAction()
              << "possibleActions=" << e->possibleActions()
              << "formats=" << e->mimeData()->formats();
    emit dropping(false);

    e->setDropAction(Qt::CopyAction);

    QListView::dropEvent(e);

    log.log() << "accepted=" << e->isAccepted()
              << "finalDropAction=" << e->dropAction();

    log.pop();
}

void NoInternalDragListView::emitVisibleCount()
{
    const QSize grid = gridSize();
    if (grid.isEmpty())
        return;

    const QSize vp = viewport()->size();
    const int cols = vp.width() / grid.width() + 1;
    const int rows = vp.height() / grid.height() + 1;
    const int count = cols * rows;

    if (count == mLastVisibleCount)
        return;

    mLastVisibleCount = count;
    emit visibleCountChanged(count);
}

void NoInternalDragListView::paintEvent(QPaintEvent *e) {
    emitVisibleCount();

    QListView::paintEvent(e);

    auto *m = model();
    if (!m || m->rowCount(rootIndex()) > 0)
        return;

    QPainter p(viewport());
    p.setRenderHint(QPainter::Antialiasing);

    bool dark = (palette().window().color().lightness() < 128);
    int cx = width() / 2;
    int cy = qMax(height() / 2 - 30, 90);

    bool isWin11 = ThemeProvider::isWin11();

    if (isWin11) {
        // Windows 11 Fluent Empty State Card
        p.save();
        p.translate(cx, cy);

        // Subtle shadow/background card
        p.setBrush(dark ? QColor(255, 255, 255, 8) : QColor(0, 0, 0, 6));
        p.setPen(QPen(dark ? QColor(255, 255, 255, 18) : QColor(0, 0, 0, 12), 1));
        p.drawRoundedRect(QRect(-48, -36, 96, 72), 8, 8);

        // Front Fluent card
        p.setBrush(dark ? QColor(36, 42, 54, 230) : QColor(255, 255, 255, 240));
        p.setPen(QPen(dark ? QColor(255, 255, 255, 35) : QColor(0, 0, 0, 25), 1.2));
        p.drawRoundedRect(QRect(-44, -32, 88, 64), 8, 8);

        // Accent drop arrow in Windows 11 Fluent Blue (#4CC2FF)
        p.setPen(QPen(ThemeProvider::accentColor(), 2.2, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
        p.drawLine(QPoint(0, -9), QPoint(0, 9));
        p.drawLine(QPoint(-6, 3), QPoint(0, 9));
        p.drawLine(QPoint(6, 3), QPoint(0, 9));
        p.restore();

        // Title and subtitle in Segoe UI Variable / Inter
        QFont titleFont = font();
        titleFont.setFamily("Segoe UI Variable Display, Segoe UI, Inter, sans-serif");
        titleFont.setItalic(false);
        titleFont.setPointSizeF(10.0);
        titleFont.setWeight(QFont::DemiBold);
        p.setFont(titleFont);
        p.setPen(dark ? QColor("#FFFFFF") : QColor("#1A1A1A"));
        p.drawText(QRect(0, cy + 48, width(), 22), Qt::AlignHCenter, "Arrastra elementos aquí");

        QFont subFont = font();
        subFont.setFamily("Segoe UI Variable Text, Segoe UI, Inter, sans-serif");
        subFont.setItalic(false);
        subFont.setPointSizeF(8.5);
        p.setFont(subFont);
        p.setPen(dark ? QColor(255, 255, 255, 130) : QColor(0, 0, 0, 130));
        p.drawText(QRect(0, cy + 72, width(), 20), Qt::AlignHCenter, "Sacude el cursor o presiona Super+T");
    } else {
        // Draw stacked cards like Dropover
        // Back card (tilted left)
        p.save();
        p.translate(cx, cy);
        p.rotate(-8);
        p.setBrush(dark ? QColor(255, 255, 255, 12) : QColor(0, 0, 0, 10));
        p.setPen(QPen(dark ? QColor(255, 255, 255, 30) : QColor(0, 0, 0, 25), 1.2));
        p.drawRoundedRect(QRect(-42, -32, 84, 64), 10, 10);
        p.restore();

        // Middle card (tilted right)
        p.save();
        p.translate(cx, cy);
        p.rotate(6);
        p.setBrush(dark ? QColor(255, 255, 255, 18) : QColor(0, 0, 0, 15));
        p.setPen(QPen(dark ? QColor(255, 255, 255, 45) : QColor(0, 0, 0, 35), 1.2));
        p.drawRoundedRect(QRect(-42, -32, 84, 64), 10, 10);
        p.restore();

        // Front card (straight)
        p.save();
        p.translate(cx, cy);
        p.setBrush(dark ? QColor(48, 44, 54, 230) : QColor(255, 255, 255, 240));
        p.setPen(QPen(dark ? QColor(255, 255, 255, 70) : QColor(0, 0, 0, 45), 1.5));
        p.drawRoundedRect(QRect(-45, -34, 90, 68), 10, 10);

        // Accent drop arrow on the front card
        p.setPen(QPen(QColor("#0A84FF"), 2.2, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
        p.drawLine(QPoint(0, -8), QPoint(0, 8));
        p.drawLine(QPoint(-6, 2), QPoint(0, 8));
        p.drawLine(QPoint(6, 2), QPoint(0, 8));
        p.restore();

        // Title and subtitle
        QFont titleFont = font();
        titleFont.setPointSizeF(10.5);
        titleFont.setWeight(QFont::DemiBold);
        p.setFont(titleFont);
        p.setPen(dark ? QColor("#FFFFFF") : QColor("#1D1D1F"));
        p.drawText(QRect(0, cy + 50, width(), 22), Qt::AlignHCenter, "Drop items here to hold");

        QFont subFont = font();
        subFont.setPointSizeF(8.5);
        p.setFont(subFont);
        p.setPen(dark ? QColor(255, 255, 255, 120) : QColor(0, 0, 0, 120));
        p.drawText(QRect(0, cy + 74, width(), 20), Qt::AlignHCenter, "Shake cursor or press Super+T");
    }
}
