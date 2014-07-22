/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ApplicationInfo.h"
#include "MirSurfaceItem.h"
#include "SurfaceManager.h"

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>

ApplicationInfo::ApplicationInfo(const QString &appId, QObject *parent)
    : ApplicationInfoInterface(appId, parent)
    , m_appId(appId)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_windowItem(0)
    , m_windowComponent(0)
    , m_parentItem(0)
    , m_surface(0)
{
    connect(this, &ApplicationInfo::stateChanged, this, &ApplicationInfo::onStateChanged);
}

ApplicationInfo::ApplicationInfo(QObject *parent)
    : ApplicationInfoInterface(QString(), parent)
    , m_stage(MainStage)
    , m_state(Starting)
    , m_focused(false)
    , m_fullscreen(false)
    , m_windowItem(0)
    , m_windowComponent(0)
    , m_parentItem(0)
    , m_surface(0)
{
    connect(this, &ApplicationInfo::stateChanged, this, &ApplicationInfo::onStateChanged);
}

ApplicationInfo::~ApplicationInfo()
{
    if (m_surface) {
        Q_EMIT SurfaceManager::singleton()->surfaceDestroyed(m_surface);
        m_surface->deleteLater();
    }
}

void ApplicationInfo::onWindowComponentStatusChanged(QQmlComponent::Status status)
{
    if (status == QQmlComponent::Ready && !m_windowItem)
        doCreateWindowItem();
}

void ApplicationInfo::onStateChanged(State state)
{
    if (state == ApplicationInfo::Running) {
        QTimer::singleShot(1000, this, SLOT(createSurface()));
    } else if (state == ApplicationInfo::Stopped) {
        destroySurface();
    }
}

void ApplicationInfo::createSurface()
{
    if (m_surface || state() == ApplicationInfo::Stopped) return;

    m_surface = new MirSurfaceItem(name(),
                                   MirSurfaceItem::Normal,
                                   fullscreen() ? MirSurfaceItem::Fullscreen : MirSurfaceItem::Maximized,
                                   screenshot());
    Q_EMIT surfaceChanged(m_surface);
    SurfaceManager::singleton()->registerSurface(m_surface);
}

void ApplicationInfo::destroySurface()
{
    if (!m_surface) return;
    MirSurfaceItem* oldSurface = m_surface;
    m_surface = nullptr;

    Q_EMIT surfaceChanged(nullptr);
    SurfaceManager::singleton()->unregisterSurface(m_surface);
    oldSurface->deleteLater();
}

void ApplicationInfo::createWindowComponent()
{
    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQmlEngine *engine = quickView->engine();

    m_windowComponent = new QQmlComponent(engine, this);
    m_windowComponent->setData(m_windowQml.toLatin1(), QUrl());
}

void ApplicationInfo::doCreateWindowItem()
{
    m_windowItem = qobject_cast<QQuickItem *>(m_windowComponent->create());
    m_windowItem->setParentItem(m_parentItem);
}

void ApplicationInfo::createWindowItem()
{
    if (!m_windowComponent)
        createWindowComponent();

    // only create the windowItem once the component is ready
    if (!m_windowComponent->isReady()) {
        connect(m_windowComponent, &QQmlComponent::statusChanged,
                this, &ApplicationInfo::onWindowComponentStatusChanged);
    } else {
        doCreateWindowItem();
    }
}

void ApplicationInfo::showWindow(QQuickItem *parent)
{
    m_parentItem = parent;

    if (!m_windowItem)
        createWindowItem();

    if (m_windowItem) {
        m_windowItem->setVisible(true);
    }
}

void ApplicationInfo::hideWindow()
{
    if (!m_windowItem)
        return;

    m_windowItem->setVisible(false);
}
