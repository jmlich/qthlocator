/*
 * SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2024  Jozef Mlich
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * qthlocator is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QQmlEngine>
#include "networkaccessmanagerfactory.h"
#include "qthlocatorconfig.h"

int main(int argc, char *argv[])
{
    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);
    app->setApplicationName("com.github.jmlich.qthlocator");

    qDebug() << "Starting app from main.cpp";

    NetworkAccessManagerFactory namFactory;

    qmlRegisterSingletonType<QthLocatorConfig>("com.github.jmlich.qthlocator", 1, 0, "QthLocatorConfig", QthLocatorConfig::qmlInstance);

    QQuickView *view = new QQuickView();
    QQmlEngine* engine = view->engine();
    engine->setNetworkAccessManagerFactory(&namFactory);

    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    return app->exec();
}
