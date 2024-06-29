#ifndef QTHLOCATORCONFIG_H
#define QTHLOCATORCONFIG_H

#include <QObject>
#include <QVariant>
#include <QDate>

#include <QSettings>
class QQmlEngine;
class QJSEngine;

#define OPTION(key, name, setter, def, type, gettertype, settertype)  \
    Q_PROPERTY(type name READ name WRITE setter NOTIFY name##Changed) \
    type name() const                                                 \
    { return value(key, def).gettertype(); }                          \
    void setter(settertype value)                                     \
    { setValue(key, value, &QthLocatorConfig::name##Changed); }         \
    Q_SIGNAL void name##Changed();

#define BOOL_OPTION(key, name, setter, def)   \
    OPTION(key, name, setter, def, bool, toBool, bool)

#define INT_OPTION(key, name, setter, def)    \
    OPTION(key, name, setter, def, int, toInt, int)

#define UINT_OPTION(key, name, setter, def)   \
    OPTION(key, name, setter, def, uint, toInt, uint)

#define INT64_OPTION(key, name, setter, def)  \
    OPTION(key, name, setter, def, qint64, toLongLong, qint64)

#define STRING_OPTION(key, name, setter, def) \
    OPTION(key, name, setter, def, QString, toString, const QString &)

#define ENUM_OPTION(key, name, setter, type, def)                               \
    Q_PROPERTY(type name READ name WRITE setter NOTIFY name##Changed)           \
    type name() const                                                           \
    { return static_cast<type>(value(key, def).toInt()); }                      \
    void setter(type value)                                                     \
    { setValue(key, static_cast<int>(value), &QthLocatorConfig::name##Changed); } \
    Q_SIGNAL void name##Changed();

#define ALARM_OPTION(key, name, setter, type, def, gettertype) \
    Q_INVOKABLE type name(quint8 n) const                      \
    { return value(key.arg(n), def).gettertype(); }            \
    Q_INVOKABLE void setter(quint8 n, type value)              \
    { setValue(key.arg(n), value); }


class QthLocatorConfig : public QObject
{
    Q_OBJECT

    QthLocatorConfig(QObject *parent = nullptr);

public:

    static QthLocatorConfig *instance();
    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return instance();
    }

    QVariant value(const QString &key, const QVariant &def = QVariant()) const;
    void setValue(const QString &key, const QVariant &value);

    STRING_OPTION(QStringLiteral("logModel"), logModel, setLogModel, QString("[]"))
    STRING_OPTION(QStringLiteral("lastBand"), lastBand, setLastBand, QString("PMR"))
    STRING_OPTION(QStringLiteral("lastMyCallSign"), lastMyCallSign, setLastMyCallSign, QString(""))
    STRING_OPTION(QStringLiteral("lastMyLocation"), lastMyLocation, setLastMyLocation, QString("portable"))
    STRING_OPTION(QStringLiteral("lastMyPlace"), lastMyPlace, setLastMyPlace, QString(""))
    STRING_OPTION(QStringLiteral("lastStationLocation"), lastStationLocation, setLastStationLocation, QString("portable"))

private:
    using signal_ptr = void(QthLocatorConfig::*)();

    void setValue(const QString &key, const QVariant &value, signal_ptr signal);

};

#undef ALARM_OPTION
#undef ENUM_OPTION
#undef STRING_OPTION
#undef INT64_OPTION
#undef UINT_OPTION
#undef INT_OPTION
#undef BOOL_OPTION
#undef OPTION

#endif // QTHLOCATORCONFIG_H
