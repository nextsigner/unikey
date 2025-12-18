#ifndef SWISSEPHMANAGER_H   // <--- ESTO ES LO QUE FALTA
#define SWISSEPHMANAGER_H   // <--- ESTO ES LO QUE FALTA

// 1. PRIMERO: Librerías de C++ y Qt
#include <QObject>
#include <QString>
#include <QDebug>
#include <memory>

// 2. POR ÚLTIMO: Swiss Ephemeris
#ifdef __cplusplus
extern "C" {
#endif

#include "swephexp.h"

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
    Q_INVOKABLE double getBodiePos(int bi, int a, int m, int d, int h, int min, int gmt);

    PlanetPosition getPlanetPosition(double julianDay, int planetIndex);
    double dateToJulian(int year, int month, int day, double hour);

private:
    QString m_ephePath;
};

#endif // SWISSEPHMANAGER_H
