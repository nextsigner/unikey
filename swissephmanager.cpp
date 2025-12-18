#include "swissephmanager.h"
#include <QDebug>

SwissEphManager::SwissEphManager(QObject *parent)
    : QObject(parent)
{
    // Configurar la ruta de los archivos de datos (.se1)
    // Swiss Ephemeris espera una cadena de C (char*)
    //swe_set_ephe_path(m_ephePath.toUtf8().data());
}

SwissEphManager::~SwissEphManager()
{
    // Cerrar archivos y liberar memoria de la librería
    swe_close();
}

void SwissEphManager::setSwePath(const QString swePath)
{
    swe_set_ephe_path(swePath.toUtf8().data());
}

double SwissEphManager::getBodiePos(int bi, int a, int m, int d, int h, int min, int gmt)
{
    // 1. Convertir hora y minuto a decimal
    double horaLocalDecimal = h + (min / 60.0);

    // 2. Ajustar según el GMT para obtener el Tiempo Universal (UT)
    // Si estamos en GMT-3 (Argentina), restamos -3, lo que equivale a sumar 3 horas para llegar a UT.
    double horaUT = horaLocalDecimal - gmt;

    // 3. Obtener el Día Juliano (swe_julday maneja el desborde de horas automáticamente)
    double jd = swe_julday(a, m, d, horaUT, SE_GREG_CAL);

    // 4. Calcular posición
    double results[6];
    char errorMsg[256];
    // SEFLG_SPEED para obtener velocidad, o 0 para solo posición
    int returnFlag = swe_calc_ut(jd, bi, SEFLG_SPEED, results, errorMsg);

    if (returnFlag >= 0) {
        return results[0]; // results[0] es la longitud de arco (0° a 360°)
    } else {
        qWarning() << "Error en cálculo de cuerpo" << bi << ":" << errorMsg;
        return -1.0;
    }
}

double SwissEphManager::dateToJulian(int year, int month, int day, double hour)
{
    // SE_GREG_CAL indica que usamos el calendario gregoriano (1)
    // o SE_JUL_CAL para el juliano (0)
    double julianDay = swe_julday(year, month, day, hour, SE_GREG_CAL);
    return julianDay;
}

PlanetPosition SwissEphManager::getPlanetPosition(double julianDay, int planetIndex)
{
    double results[6];
    char errorMsg[256];
    long iflag = SEFLG_SPEED; // Bandera para calcular también la velocidad

    // Realizar el cálculo
    // SE_ECL_NUT calcula posiciones geocéntricas
    int returnFlag = swe_calc_ut(julianDay, planetIndex, iflag, results, errorMsg);

    PlanetPosition pos;
    if (returnFlag >= 0) {
        pos.longitude = results[0];
        pos.latitude = results[1];
        pos.distance = results[2];
        pos.speedLong = results[3];

        char name[40];
        swe_get_planet_name(planetIndex, name);
        pos.planetName = QString::fromLatin1(name);
    } else {
        qWarning() << "Error en cálculo de SwiEph:" << errorMsg;
    }

    return pos;
}
