#include "customnetworkaccessmanager.h"
#include <QtGui>

CustomNetworkAccessManager::CustomNetworkAccessManager(QObject* parent)
    : QNetworkAccessManager(parent)
{
    m_userAgent = QString("Mozilla/5.0 (%1; %2 %3) QtWebEngine/%4 QTHLocator")
                      .arg(QSysInfo::productType())
                      .arg(QSysInfo::currentCpuArchitecture())
                      .arg(QGuiApplication::platformName())
                      .arg(qVersion())
                      ;
    qDebug() << m_userAgent;
}
