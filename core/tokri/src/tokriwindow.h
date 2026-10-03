#ifndef TOKRIWINDOW_H
#define TOKRIWINDOW_H

#include <QListView>
#include <QMainWindow>
#include <QDragEnterEvent>
#include <QDragMoveEvent>
#include <QMimeData>
#include <QCloseEvent>
#include <QList>
#include <QUrl>
#include <QLabel>
#include <QPushButton>
#include <QMouseEvent>
#include <QPaintEvent>

QT_BEGIN_NAMESPACE
namespace Ui {
class TokriWindow;
}
QT_END_NAMESPACE

class ThumbnailDelegate;

class TokriWindow : public QMainWindow
{
    Q_OBJECT

public:
    TokriWindow(QWidget *parent = nullptr);
    ~TokriWindow();
    Ui::TokriWindow* uiHandle();
    void sleep();
    void wakeUp();

public slots:
    void onShakeDetect();
    void deleteSelection();
    void renameSelection();
    void copySelection();
    void openSelection();
    void selectAll();
    void clearAll();
    void updateSummary();
    void setViewListMode(bool listMode);

signals:
    void pasteRequested();

protected:
    void mousePressEvent(QMouseEvent *e) override;
    void mouseMoveEvent(QMouseEvent *e) override;
    void mouseReleaseEvent(QMouseEvent *e) override;
    void paintEvent(QPaintEvent *e) override;
    void closeEvent(QCloseEvent *e) override;

private:
    Ui::TokriWindow *ui;

    void init();
    void setupDropoverUI();
    void applyColumnSizing();
    void moveNearCursor();
    void openItem(QString filePath);
    QList<QUrl> selectedUrls() const;

    ThumbnailDelegate *mDelegate = nullptr;
    QLabel *mStatusLabel = nullptr;
    QPushButton *mGridBtn = nullptr;
    QPushButton *mListBtn = nullptr;

    bool mIsDragging = false;
    QPoint mDragPos;
};
#endif // TOKRIWINDOW_H
