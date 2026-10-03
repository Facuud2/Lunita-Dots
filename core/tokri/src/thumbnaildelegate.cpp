#include "thumbnaildelegate.h"
#include "thumbnaillayout.h"
#include "themeprovider.h"

#include <QApplication>
#include <QFontMetrics>
#include <QPainter>
#include <QPainterPath>
#include <QPalette>
#include <QStyle>
#include <QFileInfo>
#include <QFileSystemModel>
#include <QFileIconProvider>
#include <QImageReader>
#include <QSet>

ThumbnailDelegate::ThumbnailDelegate(QObject *parent)
    : QStyledItemDelegate(parent)
{
}

void ThumbnailDelegate::setListMode(bool listMode)
{
    mIsListMode = listMode;
}

void ThumbnailDelegate::paint(QPainter *painter,
                              const QStyleOptionViewItem &option,
                              const QModelIndex &index) const
{
    QStyleOptionViewItem opt = option;
    initStyleOption(&opt, index);

    if (mIsListMode) {
        paintListRow(painter, opt, index);
    } else {
        paintGridItem(painter, opt, index);
    }
}

void ThumbnailDelegate::paintListRow(QPainter *p,
                                    const QStyleOptionViewItem &opt,
                                    const QModelIndex &index) const
{
    QRect cell = opt.rect.adjusted(4, 2, -4, -2);
    bool selected = opt.state & QStyle::State_Selected;
    bool hover = opt.state & QStyle::State_MouseOver;
    bool dark = ThemeProvider::isDark();

    p->save();
    p->setRenderHint(QPainter::Antialiasing);

    // Row Background (macOS Dropover style)
    if (selected) {
        p->setBrush(QColor(10, 132, 255, 95));
        p->setPen(QPen(QColor(10, 132, 255, 180), 1));
        p->drawRoundedRect(cell, 8, 8);
    } else if (hover) {
        p->setBrush(dark ? QColor(255, 255, 255, 24) : QColor(0, 0, 0, 15));
        p->setPen(Qt::NoPen);
        p->drawRoundedRect(cell, 8, 8);
    }

    QFileInfo fi = index.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();

    // Left Thumbnail / Icon (30x30 with 5px rounded corners)
    int iconSize = 30;
    QRect iconRect(cell.x() + 8, cell.y() + (cell.height() - iconSize) / 2, iconSize, iconSize);
    QIcon icon = opt.icon;
    if (icon.isNull()) {
        static QFileIconProvider fallbackProvider;
        icon = fallbackProvider.icon(fi);
    }

    if (!icon.isNull()) {
        qreal dpr = opt.widget ? opt.widget->devicePixelRatioF() : 1.0;
        QPixmap pm = icon.pixmap(QSize(iconSize * 2, iconSize * 2), dpr);
        if (!pm.isNull()) {
            QPainterPath clip;
            clip.addRoundedRect(iconRect, 5, 5);
            p->save();
            p->setClipPath(clip);
            p->drawPixmap(iconRect, pm);
            p->restore();
        }
    }

    // File metadata
    QString name = opt.text;
    if (name.isEmpty()) name = fi.fileName();

    qint64 size = fi.size();
    QString sizeStr;
    if (size < 1024) sizeStr = QString::number(size) + " B";
    else if (size < 1024 * 1024) sizeStr = QString::number(size / 1024.0, 'f', 1) + " KB";
    else if (size < 1024 * 1024 * 1024) sizeStr = QString::number(size / (1024.0 * 1024.0), 'f', 1) + " MB";
    else sizeStr = QString::number(size / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";

    QString subStr;
    static const QSet<QString> imgExts = {"png", "jpg", "jpeg", "webp", "gif", "bmp", "svg", "ico"};
    if (imgExts.contains(fi.suffix().toLower())) {
        QImageReader reader(fi.filePath());
        QSize sz = reader.size();
        if (sz.isValid()) {
            subStr = QString("%1x%2").arg(sz.width()).arg(sz.height());
        }
    }
    if (subStr.isEmpty()) {
        subStr = fi.suffix().toUpper();
        if (subStr.isEmpty()) subStr = "FILE";
    }

    // Right Column: Size & Dimensions (Right-aligned, stacked)
    int metaWidth = 90;
    QRect metaRect(cell.right() - metaWidth - 8, cell.y() + 4, metaWidth, cell.height() - 8);

    QFont sizeFont = opt.font;
    sizeFont.setPointSizeF(9.0);
    sizeFont.setWeight(QFont::DemiBold);
    p->setFont(sizeFont);
    p->setPen(dark ? QColor("#F5F5F7") : QColor("#1D1D1F"));
    p->drawText(QRect(metaRect.x(), metaRect.y(), metaWidth, 16), Qt::AlignRight | Qt::AlignVCenter, sizeStr);

    QFont subFont = opt.font;
    subFont.setPointSizeF(7.6);
    p->setFont(subFont);
    p->setPen(dark ? QColor(255, 255, 255, 125) : QColor(0, 0, 0, 115));
    p->drawText(QRect(metaRect.x(), metaRect.y() + 16, metaWidth, 16), Qt::AlignRight | Qt::AlignVCenter, subStr);

    // Middle Column: Title (Middle-elided so extension is always visible)
    QRect titleRect(iconRect.right() + 12, cell.y(), metaRect.left() - (iconRect.right() + 18), cell.height());
    QFont nameFont = opt.font;
    nameFont.setPointSizeF(9.5);
    nameFont.setWeight(QFont::Medium);
    p->setFont(nameFont);
    p->setPen(dark ? QColor("#FFFFFF") : QColor("#1D1D1F"));

    QFontMetrics fm(nameFont);
    QString elidedName = fm.elidedText(name, Qt::ElideMiddle, titleRect.width());
    p->drawText(titleRect, Qt::AlignLeft | Qt::AlignVCenter, elidedName);

    // Subtle bottom separator line
    if (!selected) {
        p->setPen(QPen(dark ? QColor(255, 255, 255, 14) : QColor(0, 0, 0, 14), 1));
        p->drawLine(cell.x() + iconSize + 16, cell.bottom() + 1, cell.right() - 4, cell.bottom() + 1);
    }

    p->restore();
}

void ThumbnailDelegate::paintGridItem(QPainter *p,
                                     const QStyleOptionViewItem &opt,
                                     const QModelIndex &index) const
{
    QRect cell = opt.rect.adjusted(4, 4, -4, -4);
    bool selected = opt.state & QStyle::State_Selected;
    bool hover = opt.state & QStyle::State_MouseOver;
    bool dark = ThemeProvider::isDark();

    p->save();
    p->setRenderHint(QPainter::Antialiasing);

    // Card background
    if (selected) {
        p->setBrush(QColor(10, 132, 255, 95));
        p->setPen(QPen(QColor(10, 132, 255, 200), 1.5));
        p->drawRoundedRect(cell, 12, 12);
    } else if (hover) {
        p->setBrush(dark ? QColor(255, 255, 255, 25) : QColor(0, 0, 0, 18));
        p->setPen(QPen(dark ? QColor(255, 255, 255, 35) : QColor(0, 0, 0, 25), 1));
        p->drawRoundedRect(cell, 12, 12);
    } else {
        p->setBrush(dark ? QColor(255, 255, 255, 12) : QColor(0, 0, 0, 8));
        p->setPen(QPen(dark ? QColor(255, 255, 255, 18) : QColor(0, 0, 0, 12), 1));
        p->drawRoundedRect(cell, 12, 12);
    }

    // Thumbnail
    int thumbSize = qMin(cell.width() - 20, 80);
    QRect thumbRect(cell.center().x() - thumbSize / 2, cell.y() + 8, thumbSize, thumbSize);
    QIcon icon = opt.icon;
    if (icon.isNull()) {
        QFileInfo fi = index.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();
        static QFileIconProvider fallbackProvider;
        icon = fallbackProvider.icon(fi);
    }

    if (!icon.isNull()) {
        qreal dpr = opt.widget ? opt.widget->devicePixelRatioF() : 1.0;
        QPixmap pm = icon.pixmap(QSize(thumbSize * 2, thumbSize * 2), dpr);
        if (!pm.isNull()) {
            QPainterPath clip;
            clip.addRoundedRect(thumbRect, 8, 8);
            p->save();
            p->setClipPath(clip);
            p->drawPixmap(thumbRect, pm);
            p->restore();
        }
    }

    // Title text
    QRect textRect(cell.x() + 4, thumbRect.bottom() + 4, cell.width() - 8, cell.height() - thumbRect.bottom() - 6);
    QFont font = opt.font;
    font.setPointSizeF(8.5);
    p->setFont(font);
    p->setPen(dark ? QColor("#FFFFFF") : QColor("#1D1D1F"));
    QFontMetrics fm(font);
    QString elided = fm.elidedText(opt.text, Qt::ElideMiddle, textRect.width());
    p->drawText(textRect, Qt::AlignHCenter | Qt::AlignTop, elided);

    p->restore();
}

QSize ThumbnailDelegate::sizeHint(const QStyleOptionViewItem &option,
                                  const QModelIndex &index) const
{
    Q_UNUSED(index);
    if (mIsListMode) {
        int width = option.widget ? option.widget->width() - 16 : 380;
        return QSize(qMax(width, 280), 44);
    }

    using namespace ThumbnailLayout;
    const QFontMetrics fm(option.font);
    return QSize(TileWidth, TileHeight(fm.height()));
}
