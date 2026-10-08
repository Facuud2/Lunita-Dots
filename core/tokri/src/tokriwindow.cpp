#include "tokriwindow.h"
#include "./ui_tokriwindow.h"
#include "dropawarefilesystemmodel.h"
#include "filereveal.h"
#include "loghelpers.h"
#include "standardpaths.h"
#include "thumbnaildelegate.h"
#include "thumbnaillayout.h"
#include "themeprovider.h"

#include <QDir>
#include <QMenu>
#include <QCloseEvent>
#include <QDesktopServices>
#include <QFile>
#include <QFileInfo>
#include <QFileSystemModel>
#include <QFrame>
#include <QApplication>
#include <QClipboard>
#include <QScrollBar>
#include <QUrl>
#include <QProcess>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QPainter>
#include <QPainterPath>
#include <QCursor>
#include <QScreen>
#include <QToolButton>

TokriWindow::TokriWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::TokriWindow)
{
    ui->setupUi(this);

    init();
    setupDropoverUI();

    mDelegate = new ThumbnailDelegate(ui->listView);
    ui->listView->setItemDelegate(mDelegate);

    ui->listView->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->listView->setAcceptDrops(true);
    ui->listView->setFrameShape(QFrame::NoFrame);
    ui->listView->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    ui->listView->setDragDropMode(QAbstractItemView::DragDrop);
    ui->listView->setDragEnabled(true);
    ui->listView->setSelectionMode(QAbstractItemView::ExtendedSelection);
    ui->listView->setTextElideMode(Qt::ElideMiddle);
    ui->listView->setResizeMode(QListView::Adjust);
    ui->listView->setLayoutMode(QListView::Batched);
    ui->listView->setMouseTracking(true);
    ui->listView->setFocusPolicy(Qt::StrongFocus);
    ui->listView->setDropIndicatorShown(false);
    ui->listView->setContextMenuPolicy(Qt::CustomContextMenu);
    ui->listView->setStyleSheet("QListView { background: transparent; border: none; }");

    connect(ui->listView, &QListView::doubleClicked,
            this, [this](const QModelIndex &idx){
                if (!idx.isValid())
                    return;

                const QString filePath =
                    idx.data(QFileSystemModel::FileInfoRole)
                        .value<QFileInfo>()
                        .filePath();
                openItem(filePath);
    });

    // Default to Dropover List Mode
    setViewListMode(true);

    connect(ui->listView, &QWidget::customContextMenuRequested, this,
            [this](const QPoint &pos) {
                Logger &log = Logger::instance();
                log.push("contextMenu");

                auto *view = ui->listView;
                auto *sel  = view->selectionModel();
                const auto selected = sel ? sel->selectedIndexes() : QModelIndexList();
                const int count = selected.size();

                QMenu menu;
                menu.setPalette(this->palette());

                QAction *open = nullptr, *reveal = nullptr, *rename = nullptr;
                QAction *copy = nullptr, *del = nullptr, *selectAll = nullptr;
                QAction *paste = nullptr;

                if (count > 0) {
                    open = menu.addAction("&Open");
                    copy = menu.addAction("&Copy");
                    del  = menu.addAction("Move to &Trash");
                }
                if (count == 1) {
                    reveal= menu.addAction("Open Containing &Folder");
                    rename= menu.addAction("&Rename");
                }

                paste = menu.addAction("&Paste");
                paste->setEnabled(DropAwareFileSystemModel::isPasteable(
                    QGuiApplication::clipboard()->mimeData()));
                selectAll = menu.addAction("Select &All");

                menu.addSeparator();
                QAction *clearAct = menu.addAction("Clear All");

                QAction *chosen = menu.exec(view->viewport()->mapToGlobal(pos));
                if (!chosen) {
                    log.pop();
                    return;
                }

                auto fileInfoAt = [](const QModelIndex &idx) {
                    return idx.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();
                };

                if (chosen == paste) {
                    emit pasteRequested();
                    log.pop();
                    return;
                }
                if (chosen == selectAll) {
                    this->selectAll();
                    log.pop();
                    return;
                }
                if (chosen == clearAct) {
                    clearAll();
                    log.pop();
                    return;
                }
                if (chosen == open) {
                    openSelection();
                    log.pop();
                    return;
                }
                if (count == 1 && chosen == reveal) {
                    FileReveal::revealInFileManager(
                        fileInfoAt(selected[0]).absoluteFilePath());
                    log.pop();
                    return;
                }
                if (count == 1 && chosen == rename) {
                    renameSelection();
                    log.pop();
                    return;
                }
                if (chosen == copy) {
                    copySelection();
                    log.pop();
                    return;
                }
                if (chosen == del) {
                    deleteSelection();
                }

                log.pop();
            });
}

TokriWindow::~TokriWindow()
{
    delete ui;
}

Ui::TokriWindow *TokriWindow::uiHandle()
{
    return ui;
}

void TokriWindow::setupDropoverUI()
{
    // Frameless translucent window with drop shadow & rounded corners
    setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Tool);
    setAttribute(Qt::WA_TranslucentBackground);

    // Hide classic menu bar
    if (ui->menuBar) {
        ui->menuBar->hide();
    }

    // Set fixed initial dimensions matching Dropover drawer
    resize(410, 480);
    setMinimumSize(360, 320);

    // Adjust central widget layout margins
    auto *mainLayout = qobject_cast<QVBoxLayout*>(ui->centralwidget->layout());
    if (!mainLayout) {
        mainLayout = new QVBoxLayout(ui->centralwidget);
        ui->centralwidget->setLayout(mainLayout);
    }
    ui->centralwidget->setAttribute(Qt::WA_TranslucentBackground);
    ui->centralwidget->setStyleSheet("QWidget#centralwidget { background: transparent; }");
    mainLayout->setContentsMargins(16, 14, 16, 14);
    mainLayout->setSpacing(10);

    // ── Header Bar (Windows 11 Fluent or macOS Dropover) ──
    QHBoxLayout *headerLayout = new QHBoxLayout;
    headerLayout->setContentsMargins(0, 0, 0, 0);

    bool isWin11 = ThemeProvider::isWin11();

    if (isWin11) {
        // Windows 11 Header: Icon + Title on left, More + Close on right
        QLabel *iconLabel = new QLabel(this);
        QPixmap iconPix(":/com.ysuraj.Tokri.png");
        if (!iconPix.isNull()) {
            iconLabel->setPixmap(iconPix.scaled(18, 18, Qt::KeepAspectRatio, Qt::SmoothTransformation));
        }
        iconLabel->setFixedSize(18, 18);
        headerLayout->addWidget(iconLabel);

        QLabel *titleLabel = new QLabel("Tokri", this);
        titleLabel->setStyleSheet("QLabel { font-family: 'Segoe UI Variable Display', 'Segoe UI', 'Adwaita Sans', sans-serif; font-style: normal; font-size: 12px; font-weight: 600; color: #FFFFFF; background: transparent; padding-left: 4px; }");
        headerLayout->addWidget(titleLabel);

        headerLayout->addStretch();

        QPushButton *moreBtn = new QPushButton("···", this);
        moreBtn->setObjectName("headerMoreBtn");
        moreBtn->setFixedSize(28, 22);
        moreBtn->setCursor(Qt::PointingHandCursor);
        moreBtn->setToolTip("Opciones");
        moreBtn->setStyleSheet(
            "QPushButton#headerMoreBtn { "
            "  background: rgba(255, 255, 255, 0.06); "
            "  border: 1px solid rgba(255, 255, 255, 0.09); "
            "  border-radius: 4px; "
            "  color: #E2E8F0; "
            "  font-size: 12px; font-weight: bold; text-align: center; "
            "  padding: 0px; margin: 0px; "
            "} "
            "QPushButton#headerMoreBtn:hover { "
            "  background: rgba(255, 255, 255, 0.14); "
            "  border: 1px solid rgba(255, 255, 255, 0.18); "
            "  color: #FFFFFF; "
            "}"
        );
        connect(moreBtn, &QPushButton::clicked, this, [this, moreBtn]{
            QMenu menu(this);
            menu.setPalette(palette());
            menu.addAction("📂 Abrir carpeta de canasta", this, [this]{
                QDesktopServices::openUrl(QUrl::fromLocalFile(StandardPaths::getPath(StandardPaths::TokriDir)));
            });
            menu.addAction("📋 Pegar", this, &TokriWindow::pasteRequested);
            menu.addAction("✓ Seleccionar todo", this, &TokriWindow::selectAll);
            menu.addSeparator();
            menu.addAction("🗑 Vaciar canasta (Mover a la papelera)", this, &TokriWindow::clearAll);
            menu.addSeparator();
            if (ui->actionHelp) menu.addAction(ui->actionHelp);
            if (ui->actionAbout) menu.addAction(ui->actionAbout);
            menu.addSeparator();
            menu.addAction("🚪 Salir de Tokri", qApp, &QCoreApplication::quit);

            menu.exec(moreBtn->mapToGlobal(QPoint(0, moreBtn->height() + 4)));
        });
        headerLayout->addWidget(moreBtn);

        QPushButton *closeBtn = new QPushButton("✕", this);
        closeBtn->setObjectName("headerCloseBtn");
        closeBtn->setFixedSize(30, 22);
        closeBtn->setCursor(Qt::PointingHandCursor);
        closeBtn->setToolTip("Ocultar en bandeja (Esc)");
        closeBtn->setStyleSheet(
            "QPushButton#headerCloseBtn { "
            "  background: rgba(255, 255, 255, 0.06); "
            "  border: 1px solid rgba(255, 255, 255, 0.09); "
            "  border-radius: 4px; "
            "  color: #E2E8F0; "
            "  font-size: 11px; font-weight: bold; text-align: center; "
            "  padding: 0px; margin: 0px; "
            "} "
            "QPushButton#headerCloseBtn:hover { "
            "  background: #C42B1C; "
            "  border: 1px solid #C42B1C; "
            "  color: #FFFFFF; "
            "}"
        );
        connect(closeBtn, &QPushButton::clicked, this, &TokriWindow::sleep);
        headerLayout->addWidget(closeBtn);
    } else {
        // Circular Close Button (X)
        QPushButton *closeBtn = new QPushButton("✕", this);
        closeBtn->setObjectName("headerCloseBtn");
        closeBtn->setFixedSize(24, 24);
        closeBtn->setCursor(Qt::PointingHandCursor);
        closeBtn->setToolTip("Ocultar en bandeja (Esc)");
        closeBtn->setStyleSheet(
            "QPushButton#headerCloseBtn { "
            "  background: rgba(255, 255, 255, 0.16); "
            "  border: 1px solid rgba(255, 255, 255, 0.22); "
            "  border-radius: 12px; "
            "  color: #FFFFFF; "
            "  padding: 0px; margin: 0px; "
            "  font-size: 11px; font-weight: bold; text-align: center; "
            "} "
            "QPushButton#headerCloseBtn:hover { "
            "  background: #FF3B30; "
            "  border: 1px solid #FF3B30; "
            "  color: #FFFFFF; "
            "}"
        );
        connect(closeBtn, &QPushButton::clicked, this, &TokriWindow::sleep);
        headerLayout->addWidget(closeBtn);

        headerLayout->addStretch();

        // Center Accent Pill (Dropover signature handle)
        QWidget *pillHandle = new QWidget(this);
        pillHandle->setFixedSize(38, 5);
        pillHandle->setStyleSheet(
            "background-color: #FFD60A; border-radius: 2.5px;"
        );
        headerLayout->addWidget(pillHandle);

        headerLayout->addStretch();

        // Circular More Options Button (•••)
        QPushButton *moreBtn = new QPushButton("•••", this);
        moreBtn->setObjectName("headerMoreBtn");
        moreBtn->setFixedSize(24, 24);
        moreBtn->setCursor(Qt::PointingHandCursor);
        moreBtn->setToolTip("Opciones");
        moreBtn->setStyleSheet(
            "QPushButton#headerMoreBtn { "
            "  background: rgba(255, 255, 255, 0.16); "
            "  border: 1px solid rgba(255, 255, 255, 0.22); "
            "  border-radius: 12px; "
            "  color: #FFFFFF; "
            "  padding: 0px; margin: 0px; "
            "  font-size: 10px; font-weight: bold; text-align: center; "
            "} "
            "QPushButton#headerMoreBtn:hover { "
            "  background: rgba(255, 255, 255, 0.32); "
            "  color: #FFFFFF; "
            "}"
        );
        connect(moreBtn, &QPushButton::clicked, this, [this, moreBtn]{
            QMenu menu(this);
            menu.setPalette(palette());
            menu.addAction("📂 Open Basket Folder", this, [this]{
                QDesktopServices::openUrl(QUrl::fromLocalFile(StandardPaths::getPath(StandardPaths::TokriDir)));
            });
            menu.addAction("📋 Paste", this, &TokriWindow::pasteRequested);
            menu.addAction("✓ Select All", this, &TokriWindow::selectAll);
            menu.addSeparator();
            menu.addAction("🗑 Clear All (Move to Trash)", this, &TokriWindow::clearAll);
            menu.addSeparator();
            if (ui->actionHelp) menu.addAction(ui->actionHelp);
            if (ui->actionAbout) menu.addAction(ui->actionAbout);
            menu.addSeparator();
            menu.addAction("🚪 Quit Tokri", qApp, &QCoreApplication::quit);

            menu.exec(moreBtn->mapToGlobal(QPoint(0, moreBtn->height() + 4)));
        });
        headerLayout->addWidget(moreBtn);
    }

    // ── Toolbar Row (Items Count + Grid/List Switcher) ──
    QHBoxLayout *toolbarLayout = new QHBoxLayout;
    toolbarLayout->setContentsMargins(4, 2, 4, 0);

    mStatusLabel = new QLabel("Canasta vacía", this);
    mStatusLabel->setFixedHeight(26);
    if (isWin11) {
        mStatusLabel->setStyleSheet(
            "QLabel { font-family: 'Segoe UI Variable Text', 'Segoe UI', 'Adwaita Sans', sans-serif; font-style: normal; font-size: 12px; font-weight: 600; color: #FFFFFF; background: transparent; }"
        );
    } else {
        mStatusLabel->setStyleSheet(
            "QLabel { font-size: 13px; font-weight: 600; color: #F5F5F7; background: transparent; }"
        );
    }
    toolbarLayout->addWidget(mStatusLabel);

    toolbarLayout->addStretch();

    // Mode Switcher Container
    QWidget *switchContainer = new QWidget(this);
    switchContainer->setFixedSize(62, 26);
    switchContainer->setObjectName("switchContainer");
    if (!isWin11) {
        switchContainer->setStyleSheet(
            "QWidget#switchContainer { "
            "  background: rgba(255, 255, 255, 0.12); "
            "  border: 1px solid rgba(255, 255, 255, 0.16); "
            "  border-radius: 7px; "
            "}"
        );
    }
    QHBoxLayout *switchLayout = new QHBoxLayout(switchContainer);
    switchLayout->setContentsMargins(2, 2, 2, 2);
    switchLayout->setSpacing(2);

    mGridBtn = new QPushButton("⊞", switchContainer);
    mGridBtn->setObjectName("modeGridBtn");
    mGridBtn->setFixedSize(28, 22);
    mGridBtn->setCursor(Qt::PointingHandCursor);
    mGridBtn->setToolTip("Vista en cuadrícula");

    mListBtn = new QPushButton("☰", switchContainer);
    mListBtn->setObjectName("modeListBtn");
    mListBtn->setFixedSize(28, 22);
    mListBtn->setCursor(Qt::PointingHandCursor);
    mListBtn->setToolTip("Vista en lista");

    connect(mGridBtn, &QPushButton::clicked, this, [this]{ setViewListMode(false); });
    connect(mListBtn, &QPushButton::clicked, this, [this]{ setViewListMode(true); });

    switchLayout->addWidget(mGridBtn);
    switchLayout->addWidget(mListBtn);
    toolbarLayout->addWidget(switchContainer);

    // Insert headers into layout at the top
    mainLayout->insertLayout(0, headerLayout);
    mainLayout->insertLayout(1, toolbarLayout);

    mainLayout->setStretch(0, 0);
    mainLayout->setStretch(1, 0);
    mainLayout->setStretch(2, 1);

    ui->listView->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
    ui->listView->setMinimumHeight(150);
}

void TokriWindow::setViewListMode(bool listMode)
{
    if (mDelegate) {
        mDelegate->setListMode(listMode);
    }

    bool isWin11 = ThemeProvider::isWin11();
    QString activeStyle;
    QString inactiveStyle;

    if (isWin11) {
        activeStyle =
            "QPushButton { background: rgba(255, 255, 255, 0.16); color: #4CC2FF; border: 1px solid rgba(255, 255, 255, 0.14); border-radius: 4px; font-size: 12px; font-weight: bold; padding: 0px; margin: 0px; }";
        inactiveStyle =
            "QPushButton { background: transparent; color: rgba(255, 255, 255, 0.55); border: 1px solid transparent; border-radius: 4px; font-size: 12px; padding: 0px; margin: 0px; } "
            "QPushButton:hover { color: #FFFFFF; background: rgba(255, 255, 255, 0.08); }";
    } else {
        activeStyle =
            "QPushButton { background: rgba(255, 255, 255, 0.35); color: #FFFFFF; border: none; border-radius: 5px; font-size: 13px; font-weight: bold; padding: 0px; margin: 0px; }";
        inactiveStyle =
            "QPushButton { background: transparent; color: rgba(255, 255, 255, 0.55); border: none; border-radius: 5px; font-size: 13px; padding: 0px; margin: 0px; } "
            "QPushButton:hover { color: #FFFFFF; background: rgba(255, 255, 255, 0.14); }";
    }

    if (listMode) {
        ui->listView->setViewMode(QListView::ListMode);
        ui->listView->setFlow(QListView::TopToBottom);
        ui->listView->setWrapping(false);
        ui->listView->setGridSize(QSize());
        ui->listView->setSpacing(2);

        if (mListBtn) mListBtn->setStyleSheet(activeStyle);
        if (mGridBtn) mGridBtn->setStyleSheet(inactiveStyle);
    } else {
        ui->listView->setViewMode(QListView::IconMode);
        ui->listView->setFlow(QListView::LeftToRight);
        ui->listView->setWrapping(true);
        ui->listView->setGridSize(QSize(120, 130));
        ui->listView->setSpacing(6);

        if (mGridBtn) mGridBtn->setStyleSheet(activeStyle);
        if (mListBtn) mListBtn->setStyleSheet(inactiveStyle);
    }

    ui->listView->viewport()->update();
}

void TokriWindow::updateSummary()
{
    if (!ui || !ui->listView || !ui->listView->model() || !mStatusLabel)
        return;

    auto *model = ui->listView->model();
    QModelIndex root = ui->listView->rootIndex();
    int count = model->rowCount(root);

    if (count == 0) {
        mStatusLabel->setText("Canasta vacía");
        return;
    }

    qint64 totalBytes = 0;
    int imgCount = 0;
    static const QSet<QString> imgExts = {"png", "jpg", "jpeg", "webp", "gif", "bmp", "svg", "ico"};

    for (int i = 0; i < count; ++i) {
        QModelIndex idx = model->index(i, 0, root);
        QFileInfo fi = idx.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();
        totalBytes += fi.size();
        if (imgExts.contains(fi.suffix().toLower())) {
            imgCount++;
        }
    }

    QString sizeStr;
    if (totalBytes < 1024) sizeStr = QString::number(totalBytes) + " B";
    else if (totalBytes < 1024 * 1024) sizeStr = QString::number(totalBytes / 1024.0, 'f', 1) + " KB";
    else if (totalBytes < 1024 * 1024 * 1024) sizeStr = QString::number(totalBytes / (1024.0 * 1024.0), 'f', 1) + " MB";
    else sizeStr = QString::number(totalBytes / (1024.0 * 1024.0 * 1024.0), 'f', 1) + " GB";

    QString itemWord;
    if (imgCount == count && count > 0) {
        itemWord = (count == 1) ? "1 Imagen" : QString("%1 Imágenes").arg(count);
    } else {
        itemWord = (count == 1) ? "1 Archivo" : QString("%1 Archivos").arg(count);
    }

    mStatusLabel->setText(QString("%1 • %2").arg(itemWord, sizeStr));
}

void TokriWindow::clearAll()
{
    QString tokriDir = StandardPaths::getPath(StandardPaths::TokriDir);
    QDir dir(tokriDir);
    for (const QFileInfo &fi : dir.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot)) {
        QFile::moveToTrash(fi.absoluteFilePath());
    }
}

void TokriWindow::mousePressEvent(QMouseEvent *e)
{
    if (e->button() == Qt::LeftButton) {
        mDragPos = e->globalPosition().toPoint() - frameGeometry().topLeft();
        mIsDragging = true;
        e->accept();
    }
    QMainWindow::mousePressEvent(e);
}

void TokriWindow::mouseMoveEvent(QMouseEvent *e)
{
    if (mIsDragging && (e->buttons() & Qt::LeftButton)) {
        move(e->globalPosition().toPoint() - mDragPos);
        e->accept();
        return;
    }
    QMainWindow::mouseMoveEvent(e);
}

void TokriWindow::mouseReleaseEvent(QMouseEvent *e)
{
    mIsDragging = false;
    QMainWindow::mouseReleaseEvent(e);
}

void TokriWindow::paintEvent(QPaintEvent *)
{
    QPainter p(this);
    p.setRenderHint(QPainter::Antialiasing);

    QRect r = rect().adjusted(1, 1, -1, -1);
    int radius = ThemeProvider::windowCornerRadius();
    QColor bgColor = ThemeProvider::windowBgColor();
    QColor borderColor = ThemeProvider::windowBorderColor();

    QPainterPath path;
    path.addRoundedRect(r, radius, radius);

    p.fillPath(path, bgColor);
    p.setPen(QPen(borderColor, 1.0));
    p.drawPath(path);
}

void TokriWindow::init()
{
    QString tokriDir = StandardPaths::getPath(StandardPaths::TokriDir);
    QDir dir(tokriDir);
    if (!dir.exists()){
        dir.mkpath(tokriDir);
    }
}

void TokriWindow::applyColumnSizing()
{
    setMinimumWidth(360);
}

void TokriWindow::moveNearCursor()
{
#ifdef Q_OS_LINUX
    QProcess proc;
    proc.start("hyprctl", QStringList() << "cursorpos");
    if (proc.waitForFinished(100)) {
        QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        QStringList parts = out.split(',');
        if (parts.size() == 2) {
            bool ok1 = false, ok2 = false;
            int cx = parts[0].trimmed().toInt(&ok1);
            int cy = parts[1].trimmed().toInt(&ok2);
            if (ok1 && ok2) {
                QPoint p(cx + 20, cy + 20);
                QScreen *scr = QGuiApplication::screenAt(p);
                if (!scr) scr = QGuiApplication::screenAt(QCursor::pos());
                if (!scr) scr = QGuiApplication::primaryScreen();
                if (scr) {
                    const QRect screen = scr->availableGeometry();
                    if (p.x() + width() > screen.right() - 12)
                        p.setX(screen.right() - width() - 12);
                    if (p.y() + height() > screen.bottom() - 12)
                        p.setY(screen.bottom() - height() - 12);
                    if (p.x() < screen.left() + 12)
                        p.setX(screen.left() + 12);
                    if (p.y() < screen.top() + 38)
                        p.setY(screen.top() + 38);
                }
                move(p);
                return;
            }
        }
    }
#endif

    const QPoint cursor = QCursor::pos();
    const QSize winSize = size();
    QPoint p(cursor.x() + 20, cursor.y() + 20);

    QScreen *scr = QGuiApplication::screenAt(cursor);
    if (!scr) scr = QGuiApplication::primaryScreen();
    if (scr) {
        const QRect screen = scr->availableGeometry();
        if (p.x() + winSize.width() > screen.right() - 12)
            p.setX(screen.right() - winSize.width() - 12);
        if (p.y() + winSize.height() > screen.bottom() - 12)
            p.setY(screen.bottom() - winSize.height() - 12);
        if (p.x() < screen.left() + 12)
            p.setX(screen.left() + 12);
        if (p.y() < screen.top() + 38)
            p.setY(screen.top() + 38);
    }

    move(p);
}

void TokriWindow::onShakeDetect()
{
    Logger &log = Logger::instance();
    log.push("onShakeDetect");
    log.log() << "shake";

    wakeUp();
    log.pop();
}

void TokriWindow::sleep()
{
    Logger &log = Logger::instance();
    log.push("sleep");
    log.log() << "-> hide";

    hide();
    log.pop();
}

void TokriWindow::wakeUp()
{
    Logger &log = Logger::instance();
    log.push("wakeUp");
    log.log() << "-> show";

    moveNearCursor();
    updateSummary();
    show();
    raise();
    activateWindow();
    ui->listView->setFocus();

    log.pop();
}

void TokriWindow::deleteSelection()
{
    auto *sel = ui->listView->selectionModel();
    if (!sel) return;
    const auto selected = sel->selectedIndexes();
    for (const auto &idx : selected) {
        QFileInfo fi = idx.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();
        QFile::moveToTrash(fi.absoluteFilePath());
    }
    updateSummary();
}

void TokriWindow::renameSelection()
{
    auto *sel = ui->listView->selectionModel();
    if (!sel) return;
    const auto selected = sel->selectedIndexes();
    if (selected.size() == 1) {
        ui->listView->edit(selected.first());
    }
}

void TokriWindow::copySelection()
{
    QList<QUrl> urls = selectedUrls();
    if (urls.isEmpty()) return;

    QMimeData *mime = new QMimeData;
    mime->setUrls(urls);
    QApplication::clipboard()->setMimeData(mime);
}

void TokriWindow::openSelection()
{
    QList<QUrl> urls = selectedUrls();
    for (const auto &url : urls) {
        QDesktopServices::openUrl(url);
    }
}

void TokriWindow::selectAll()
{
    ui->listView->selectAll();
}

void TokriWindow::openItem(QString filePath)
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(filePath));
}

QList<QUrl> TokriWindow::selectedUrls() const
{
    QList<QUrl> urls;
    auto *sel = ui->listView->selectionModel();
    if (!sel) return urls;
    for (const auto &idx : sel->selectedIndexes()) {
        QFileInfo fi = idx.data(QFileSystemModel::FileInfoRole).value<QFileInfo>();
        urls.append(QUrl::fromLocalFile(fi.absoluteFilePath()));
    }
    return urls;
}

void TokriWindow::closeEvent(QCloseEvent *e)
{
    e->ignore();
    sleep();
}
