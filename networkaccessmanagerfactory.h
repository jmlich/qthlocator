#ifndef NETWORKACCESSMANAGERFACTORY_H
#define NETWORKACCESSMANAGERFACTORY_H

#include "customnetworkaccessmanager.h"
#include <QQmlNetworkAccessManagerFactory>
#include <QtNetwork>

class NetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory {
public:
    explicit NetworkAccessManagerFactory();

    QNetworkAccessManager* create(QObject* parent)
    {
        CustomNetworkAccessManager* manager = new CustomNetworkAccessManager(parent);
        return manager;
    }
};

#endif // NETWORKACCESSMANAGERFACTORY_H
