#include "qthlocatorconfig.h"

#include <QCoreApplication>

#include <functional>


QthLocatorConfig::QthLocatorConfig(QObject *parent)
    : QObject(parent)
{

}

QthLocatorConfig *QthLocatorConfig::instance()
{
    static QthLocatorConfig *inst = nullptr;
    if (!inst) {
        inst = new QthLocatorConfig(qApp);
    }
    return inst;
}

QVariant QthLocatorConfig::value(const QString &key, const QVariant &def) const
{
    QSettings settings;
    return settings.value(key, def);
}

void QthLocatorConfig::setValue(const QString &key, const QVariant &value)
{
    QSettings settings;
    settings.setValue(key, value);
}

void QthLocatorConfig::setValue(const QString &key, const QVariant &value, signal_ptr signal)
{
    QSettings settings;
    auto prev = settings.value(key);

    if (value != prev) {
        settings.setValue(key, value);
        emit std::bind(signal, this)();
    }
}
