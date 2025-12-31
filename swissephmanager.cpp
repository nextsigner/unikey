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

#include <QJsonObject>
#include <QJsonDocument>
#include <cmath>

QString SwissEphManager::getBodiePosJson(int bi, int a, int m, int d, int h, int min, int gmt,
                                         double lon, double lat, double alt)
{
    // 1. Cálculo de Tiempo y Día Juliano (UT)
    double horaUT = (h + (min / 60.0)) - gmt;
    double jd = swe_julday(a, m, d, horaUT, SE_GREG_CAL);

    // 2. Configuración de precisión (Topocéntrica)
    swe_set_topo(lon, lat, alt);

    // Flags: Posición, Velocidad (para retrogradación) y Topocéntrico
    long iflag = SEFLG_SPEED | SEFLG_TOPOCTR;
    double results[6];
    char errorMsg[256];

    int returnFlag = swe_calc_ut(jd, bi, iflag, results, errorMsg);
    if (returnFlag < 0) {
        qWarning() << "Error SwissEph:" << errorMsg;
        return "{}";
    }

    double gdec = results[0];       // Longitud eclíptica total (0-360)
    double speedLong = results[3];  // Velocidad para determinar retrogradación

    // 3. Desglose Zodiacal (Signos, Grados, Minutos, Segundos)
    // Cada signo tiene exactamente 30 grados
    int is = static_cast<int>(gdec / 30.0);
    double rsdeg_total = fmod(gdec, 30.0);
    int rsdeg = static_cast<int>(rsdeg_total);

    double resto_min = (rsdeg_total - rsdeg) * 60.0;
    int rsmin = static_cast<int>(resto_min);

    double resto_seg = (resto_min - rsmin) * 60.0;
    int rsseg = static_cast<int>(std::round(resto_seg));

    // Correcciones por redondeo matemático
    if (rsseg >= 60) { rsseg = 0; rsmin++; }
    if (rsmin >= 60) { rsmin = 0; rsdeg++; }
    if (rsdeg >= 30) { rsdeg = 0; is = (is + 1) % 12; }

    // 4. Construcción del JSON (Sin información de casas)
    QJsonObject obj;
    obj["gdec"] = gdec;
    obj["is"] = is;
    //obj["rsdeg"] = rsdeg;
    obj["gdeg"] = gdec;
    obj["rsgdeg"] = rsdeg;
    //obj["rsmin"] = rsmin;
    obj["mdeg"] = rsmin;
    //obj["rsseg"] = rsseg;
    obj["sdeg"] = rsseg;
    //obj["retro"] = (speedLong < 0)?1:0;
    obj["retro"] = (speedLong > 0)?1:0;

    QJsonDocument doc(obj);
    return doc.toJson(QJsonDocument::Compact);
}

QString SwissEphManager::getHousesPos(int a, int m, int d, int h, int min, int gmt,
                                      double lon, double lat, QString hsys)
{
    // 1. Cálculo de Tiempo Universal (UT)
    double horaUT = (h + (min / 60.0)) - gmt;
    double jd = swe_julday(a, m, d, horaUT, SE_GREG_CAL);

    // 2. Preparar variables para la librería
    double cusps[13]; // La librería usa índices 1 a 12 para las casas
    double ascmc[10]; // Puntos adicionales (Asc, MC, Armmc, etc.)

    // Definir sistema de casas (por defecto Placidus 'P')
    char sys = hsys.isEmpty() ? 'P' : hsys.toUpper().at(0).toLatin1();

    // 3. Calcular las cúspides
    // El segundo parámetro (0) indica que usamos el zodiaco tropical
    int result = swe_houses_ex(jd, 0, lat, lon, sys, cusps, ascmc);

    if (result < 0) return "{}";

    // 4. Construir el JSON con las 12 casas
    QJsonObject root;
    QJsonObject housesObj;

    for (int i = 1; i <= 12; ++i) {
        double gdec = cusps[i];

        // Desglose de grados, minutos y segundos
        int is = static_cast<int>(gdec / 30.0);
        double rsdeg_total = fmod(gdec, 30.0);
        int rsdeg = static_cast<int>(rsdeg_total);
        double resto_min = (rsdeg_total - rsdeg) * 60.0;
        int rsmin = static_cast<int>(resto_min);
        double resto_seg = (resto_min - rsmin) * 60.0;
        int rsseg = static_cast<int>(qRound(resto_seg));

        // Ajustes de redondeo
        if (rsseg == 60) { rsseg = 0; rsmin++; }
        if (rsmin == 60) { rsmin = 0; rsdeg++; }

        // Crear objeto para cada casa
        QJsonObject houseData;
        houseData["gdec"] = gdec;
        houseData["is"] = is;
        //houseData["rsdeg"] = rsdeg;
        houseData["rsgdeg"] = rsdeg;
        houseData["gdeg"] = static_cast<int>(gdec);;
        //houseData["rsmin"] = rsmin;
        houseData["mdeg"] = rsmin;
        //houseData["rsseg"] = rsseg;
        houseData["sdeg"] = rsseg;

        QString nomItem="h";
        nomItem.append(QString::number(i));
        housesObj[nomItem] = houseData;
    }

    // 5. Agregar puntos principales (Ascendente y MC) por conveniencia
    root["ph"] = housesObj;
    root["asc"] = ascmc[0];
    root["mc"] = ascmc[1];
    root["vertex"] = ascmc[3];

    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact);
}

QVector<int> SwissEphManager::getSolarReturn(double targetSunLong, int targetYear, int birthMonth, int birthDay, double gmt)
{
    // 1. Empezamos la búsqueda 2 días antes del cumpleaños estimado en UT
    // (Usamos 0.0 UT como punto de partida)
    double jdUT = swe_julday(targetYear, birthMonth, birthDay, 0.0, SE_GREG_CAL) - 2.0;

    double currentSun = 0;
    double precision = 0.0000001; // Alta precisión para capturar el segundo
    double results[6];
    char errorMsg[256];

    // 2. Bucle de aproximación (Método de Newton-Raphson)
    for (int i = 0; i < 30; i++) {
        swe_calc_ut(jdUT, SE_SUN, SEFLG_SPEED, results, errorMsg);
        currentSun = results[0];
        double speed = results[3]; // Velocidad diaria del sol (~0.98°/día)

        double diff = targetSunLong - currentSun;

        // Ajuste de normalización 0-360
        if (diff < -180.0) diff += 360.0;
        if (diff > 180.0)  diff -= 360.0;

        double step = diff / speed;
        jdUT += step;

        if (std::abs(step) < precision) break;
    }

    // 3. AJUSTE DE GMT
    // Convertimos el Día Juliano UT a Día Juliano Local
    // (1 hora = 1/24 de día)
    double jdLocal = jdUT + (gmt / 24.0);

    // 4. Desglosar el Día Juliano Local a fecha y hora
    int year, month, day;
    double hourDec;
    swe_revjul(jdLocal, SE_GREG_CAL, &year, &month, &day, &hourDec);

    // 5. Convertir hora decimal a H:M
    // Añadimos un pequeño epsilon (0.0001) para evitar errores de redondeo como 13:59:59 -> 13:59
    int h = static_cast<int>(hourDec + 0.00001);
    double m_total = (hourDec - h) * 60.0;
    int min = static_cast<int>(m_total + 0.5); // Redondeo al minuto más cercano

    // Manejo de desborde de minutos (si el redondeo da 60)
    if (min >= 60) {
        min = 0;
        h++;
    }
    // Si la hora desborda 24 debido al GMT o redondeo, swe_revjul ya lo manejó al darnos el día

    return QVector<int>({year, month, day, h, min});
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

#include <QJsonArray>

QString SwissEphManager::getLunarEvents(int year, double gmt)
{
    QJsonObject root;
    QJsonArray newMoons;
    QJsonArray fullMoons;
    QJsonArray eclipsesLunares;
    QJsonArray eclipsesSolares;

    double jdStart = swe_julday(year, 1, 1, 0.0, SE_GREG_CAL);
    double jdEnd = swe_julday(year + 1, 1, 1, 0.0, SE_GREG_CAL);
    char errorMsg[256];
    double xx[6];

    // --- 1. CÁLCULO DE FASES ---
    for (double jd = jdStart; jd < jdEnd; jd += 15.0) {

        // LUNA NUEVA (Sol y Luna en el mismo grado)
        double jdNew = findMoonPhase(jd, 0.0);
        if (jdNew >= jdStart && jdNew < jdEnd) {
            QJsonObject mObj = jdToDateTimeJson(jdNew, gmt);
            if (newMoons.isEmpty() || newMoons.last().toObject()["m"].toInt() != mObj["m"].toInt()) {
                swe_calc_ut(jdNew, SE_SUN, SEFLG_SPEED, xx, errorMsg);
                mObj["gdec"] = xx[0];
                mObj["is"] = static_cast<int>(xx[0] / 30.0);
                newMoons.append(mObj);
            }
        }

        // LUNA LLENA (Sol y Luna opuestos)
        double jdFull = findMoonPhase(jd, 180.0);
        if (jdFull >= jdStart && jdFull < jdEnd) {
            QJsonObject fObj = jdToDateTimeJson(jdFull, gmt);
            if (fullMoons.isEmpty() || fullMoons.last().toObject()["m"].toInt() != fObj["m"].toInt()) {
                // Datos del Sol
                swe_calc_ut(jdFull, SE_SUN, SEFLG_SPEED, xx, errorMsg);
                fObj["sun_gdec"] = xx[0];
                fObj["sun_is"] = static_cast<int>(xx[0] / 30.0);
                // Datos de la Luna
                swe_calc_ut(jdFull, SE_MOON, SEFLG_SPEED, xx, errorMsg);
                fObj["moon_gdec"] = xx[0];
                fObj["moon_is"] = static_cast<int>(xx[0] / 30.0);
                fullMoons.append(fObj);
            }
        }
    }

    // --- 2. CÁLCULO DE ECLIPSES LUNARES ---
    double tret[10];
    double currentJdLun = jdStart;
    while (true) {
        int res = swe_lun_eclipse_when(currentJdLun, SEFLG_JPLEPH, 0, tret, 0, errorMsg);
        if (res < 0 || tret[0] >= jdEnd) break;

        QJsonObject ecl;
        ecl["date"] = jdToDateTimeJson(tret[0], gmt);

        // Posiciones durante el máximo del eclipse
        swe_calc_ut(tret[0], SE_SUN, SEFLG_SPEED, xx, errorMsg);
        ecl["sun_gdec"] = xx[0];
        ecl["sun_is"] = static_cast<int>(xx[0] / 30.0);
        swe_calc_ut(tret[0], SE_MOON, SEFLG_SPEED, xx, errorMsg);
        ecl["moon_gdec"] = xx[0];
        ecl["moon_is"] = static_cast<int>(xx[0] / 30.0);

        if (res & SE_ECL_TOTAL) ecl["type"] = "Total";
        else if (res & SE_ECL_PARTIAL) ecl["type"] = "Parcial";
        else if (res & SE_ECL_PENUMBRAL) ecl["type"] = "Penumbral";

        eclipsesLunares.append(ecl);
        currentJdLun = tret[0] + 1.0;
    }

    // --- 3. CÁLCULO DE ECLIPSES SOLARES ---
    double currentJdSol = jdStart;
    while (true) {
        int res = swe_sol_eclipse_when_glob(currentJdSol, SEFLG_JPLEPH, 0, tret, 0, errorMsg);
        if (res < 0 || tret[0] >= jdEnd) break;

        QJsonObject eclSol;
        eclSol["date"] = jdToDateTimeJson(tret[0], gmt);

        // Posición del Sol/Luna (en eclipse solar están juntos)
        swe_calc_ut(tret[0], SE_SUN, SEFLG_SPEED, xx, errorMsg);
        eclSol["gdec"] = xx[0];
        eclSol["is"] = static_cast<int>(xx[0] / 30.0);

        if ((res & SE_ECL_TOTAL) && (res & SE_ECL_ANNULAR)) eclSol["type"] = "Híbrido";
        else if (res & SE_ECL_TOTAL) eclSol["type"] = "Total";
        else if (res & SE_ECL_ANNULAR) eclSol["type"] = "Anular";
        else if (res & SE_ECL_PARTIAL) eclSol["type"] = "Parcial";
        else eclSol["type"] = "Otro";

        eclipsesSolares.append(eclSol);
        currentJdSol = tret[0] + 1.0;
    }

    root["lunas_nuevas"] = newMoons;
    root["lunas_llenas"] = fullMoons;
    root["eclipses_lunares"] = eclipsesLunares;
    root["eclipses_solares"] = eclipsesSolares;

    return QJsonDocument(root).toJson(QJsonDocument::Compact);
}
double SwissEphManager::findMoonPhase(double startJd, double targetPhase)
{
    double jd = startJd;
    double results[6];
    char errorMsg[256];
    double diff = 1.0;

    // Máximo 10 iteraciones para encontrar el segundo exacto
    for (int i = 0; i < 10; i++) {
        // Posición Sol
        swe_calc_ut(jd, SE_SUN, 0, results, errorMsg);
        double sunPos = results[0];

        // Posición Luna
        swe_calc_ut(jd, SE_MOON, 0, results, errorMsg);
        double moonPos = results[0];

        // Calcular elongación actual
        double elongation = moonPos - sunPos;
        double currentDiff = elongation - targetPhase;

        // Normalizar a [-180, 180]
        while (currentDiff <= -180.0) currentDiff += 360.0;
        while (currentDiff > 180.0) currentDiff -= 360.0;

        // La Luna se mueve ~12.2° más rápido que el Sol por día
        double step = currentDiff / 12.19075;
        jd -= step;

        if (std::abs(step) < 0.00001) break; // Precisión de 1 segundo
    }
    return jd;
}

QJsonObject SwissEphManager::searchAspsBodieFromLong(int di, int mi, int ai,
                                                               int planeta_num_ignorado, double longitud_objetivo,
                                                               int df, int mf, int af,
                                                               double tol,
                                                               QStringList aaBodiesIndexs)
{
    QJsonObject result;
    char errorMsg[256];
    double xx[6];

    double jd_inicio = swe_julday(ai, mi, di, 0.0, SE_GREG_CAL);
    double jd_fin = swe_julday(af, mf, df, 0.0, SE_GREG_CAL);
    double tjd = jd_inicio;

    // Aspectos (0=Op, 1=Cuad, 2=Trig, 3=Conj, 4=Sext, 5=Semicuad, 6=Quinc)
    struct Aspect { double angle; int index; };
    QVector<Aspect> aspects = {
        {0.0, 3}, {180.0, 0}, {90.0, 1}, {-90.0, 1}, {120.0, 2}, {-120.0, 2},
        {60.0, 4}, {-60.0, 4}, {45.0, 5}, {-45.0, 5}, {150.0, 6}, {-150.0, 6}
    };

    bool found = false;

    while (tjd <= jd_fin) {
        for (const QString& idStr : aaBodiesIndexs) {
            int idOriginal = idStr.toInt();
            int idSwissEph = idOriginal;//qAbs(idOriginal);
            if (idOriginal == -10) {
                idSwissEph=10;
            }
            double longitud_actual = 0;

            if (swe_calc_ut(tjd, idSwissEph, SEFLG_SPEED, xx, errorMsg) >= 0) {
                if (idOriginal == -10) {
                    longitud_actual = fmod(xx[0] + 180.0, 360.0);
                } else {
                    longitud_actual = xx[0];
                }

                for (const auto& asp : aspects) {
                    double lon_deseada = fmod(longitud_objetivo + asp.angle + 360.0, 360.0);
                    double diff = qAbs(longitud_actual - lon_deseada);
                    if (diff > 180.0) diff = 360.0 - diff;

                    if (diff <= tol) {
                        int y, m, d, hh, mm;
                        double hDec;
                        swe_revjul(tjd, SE_GREG_CAL, &y, &m, &d, &hDec);
                        hh = static_cast<int>(hDec);
                        mm = static_cast<int>((hDec - hh) * 60 + 0.5);

                        result["isData"] = true;
                        result["a"] = y; result["m"] = m; result["d"] = d;
                        result["h"] = hh; result["min"] = mm;
                        result["gb"] = longitud_objetivo;
                        result["gr"] = longitud_actual;
                        result["aspIndex"] = asp.index;
                        result["numAstro"] = idOriginal;
                        result["tol"] = tol;
                        result["ai"] = ai; result["mi"] = mi; result["di"] = di;
                        result["af"] = af; result["mf"] = mf; result["df"] = df;

                        found = true;
                        break;
                    }
                }
            }
            if (found) break;
        }
        if (found) break;
        tjd += tol;
    }

    if (!found) {
        result["isData"] = false;
        result["gb"] = longitud_objetivo;
        result["tol"] = tol;
        result["ai"] = ai; result["mi"] = mi; result["di"] = di;
        result["af"] = af; result["mf"] = mf; result["df"] = df;
    }

    return result;
}

// Función auxiliar para convertir JD a Objeto JSON legible
QJsonObject SwissEphManager::jdToDateTimeJson(double jdUT, double gmt)
{
    // Convertimos el Día Juliano UT a la hora local usando el GMT
    double jdLocal = jdUT + (gmt / 24.0);

    int y, m, d;
    double hDec;
    // Desglosamos el Día Juliano local
    swe_revjul(jdLocal, SE_GREG_CAL, &y, &m, &d, &hDec);

    // Calculamos horas y minutos con redondeo de seguridad
    int hh = static_cast<int>(hDec + 0.00001);
    int mm = static_cast<int>((hDec - hh) * 60 + 0.5);

    // Ajuste por desborde de minutos
    if (mm >= 60) {
        mm = 0;
        hh++;
    }

    QJsonObject obj;
    obj["a"] = y;
    obj["m"] = m;
    obj["d"] = d;
    obj["h"] = hh;
    obj["min"] = mm;
    obj["gmt"] = gmt;
    // Opcionalmente puedes mantener el jd original por si lo necesitas para cálculos
    // obj["jd"] = jdUT;

    return obj;
}
