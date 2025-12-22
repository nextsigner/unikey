#ifndef SWISSEPHMANAGER_H   // <--- ESTO ES LO QUE FALTA
#define SWISSEPHMANAGER_H   // <--- ESTO ES LO QUE FALTA

// 1. PRIMERO: Librerías de C++ y Qt
#include <QObject>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <cmath>
#include <memory>

// 2. POR ÚLTIMO: Swiss Ephemeris
#ifdef __cplusplus
extern "C" {
#endif

#ifdef Q_OS_WIN
#include "libs/swisseph/swephexp.h"
#include "libs/swisseph/sweph.h"
#else
#include "swephexp.h"
#endif


#ifdef __cplusplus
}
#endif

// Estructura para los resultados
struct PlanetPosition {
    double longitude;
    double latitude;
    double distance;
    double speedLong;
    QString planetName;
};

class SwissEphManager : public QObject
{
    Q_OBJECT
public:
    explicit SwissEphManager(QObject *parent = nullptr);
    ~SwissEphManager();
    Q_INVOKABLE void setSwePath(const QString swePath);
    Q_INVOKABLE QString getBodiePosJson(int bi, int a, int m, int d, int h, int min, int gmt,
                                        double lon, double lat, double alt);
    Q_INVOKABLE QString getHousesPos(int a, int m, int d, int h, int min, int gmt,
                         double lon, double lat, QString hsys);
    Q_INVOKABLE QVector<int> getSolarReturn(double targetSunLong, int targetYear, int birthMonth, int birthDay, double gmt);
    Q_INVOKABLE QString getLunarEvents(int year, double gmt);
    Q_INVOKABLE double findMoonPhase(double startJd, double targetPhase);
    Q_INVOKABLE QJsonObject jdToDateTimeJson(double jdUT, double gmt);

    PlanetPosition getPlanetPosition(double julianDay, int planetIndex);
    double dateToJulian(int year, int month, int day, double hour);

private:
    QString m_ephePath;
};

#endif // SWISSEPHMANAGER_H
