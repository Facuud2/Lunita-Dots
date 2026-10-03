#ifndef THUMBNAILDELGATE_H
#define THUMBNAILDELGATE_H

#include <QStyledItemDelegate>

class ThumbnailDelegate : public QStyledItemDelegate
{
    Q_OBJECT

public:
    explicit ThumbnailDelegate(QObject *parent = nullptr);

    void setListMode(bool listMode);
    bool isListMode() const { return mIsListMode; }

    void paint(QPainter *painter, const QStyleOptionViewItem &option,
               const QModelIndex &index) const override;
    QSize sizeHint(const QStyleOptionViewItem &option,
                   const QModelIndex &index) const override;

private:
    void paintListRow(QPainter *p, const QStyleOptionViewItem &opt, const QModelIndex &index) const;
    void paintGridItem(QPainter *p, const QStyleOptionViewItem &opt, const QModelIndex &index) const;

    bool mIsListMode = true; // Default to Dropover list mode as requested
};

#endif // THUMBNAILDELGATE_H
