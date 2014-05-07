/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// local
#include "dbusunitysessionservice.h"

// Qt
#include <QDBusConnection>

DBusUnitySessionService::DBusUnitySessionService() : QObject()
{
    QDBusConnection connection = QDBusConnection::sessionBus();

    connection.registerService("com.canonical.Unity.Session");
    connection.registerObject("/com/canonical/Unity/Session", this,
                              QDBusConnection::ExportScriptableSignals
                              | QDBusConnection::ExportScriptableSlots
                              | QDBusConnection::ExportScriptableInvokables);
}

DBusUnitySessionService::~DBusUnitySessionService()
{
}

void DBusUnitySessionService::Logout()
{
  Q_EMIT logoutReady();
}

void DBusUnitySessionService::RequestLogout()
{
  Q_EMIT logoutRequested(false);
}
