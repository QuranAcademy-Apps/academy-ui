import 'package:adhan_dart/adhan_dart.dart' as adhan;

import 'prayer_settings.dart';
import 'prayer_method_resolver.dart';

/// Local times of the five prayers of one day.
typedef PrayerDay = Map<Prayer, DateTime>;

/// Local times of every [DayMoment] of one day (the prayers plus sunrise).
typedef DayTimes = Map<DayMoment, DateTime>;

/// The night between a day's Maghrib and the next Fajr.
typedef NightTimes = ({DateTime middle, DateTime lastThird});

/// What Home shows at a moment: a day and the prayer coming next.
class PrayerSnapshot {
  const PrayerSnapshot({
    required this.day,
    required this.next,
    required this.remaining,
  });

  final PrayerDay day;
  final Prayer next;
  final Duration remaining;
}

/// Fajr / Isha angles (or the fixed Isha interval) of [method].
typedef MethodAngles = ({double fajr, double isha, int ishaInterval});

/// The method really used at [location]: the user's pick, or the one that
/// is customary there for «Auto».
PrayerMethod effectiveMethod(
  PrayerSettings settings,
  PrayerLocation location,
) => settings.method == PrayerMethod.auto
    ? resolvePrayerMethod(location)
    : settings.method;

MethodAngles methodAngles(PrayerMethod method) {
  final parameters = _methodParameters(method);
  return (
    fajr: parameters.fajrAngle,
    isha: parameters.ishaAngle,
    ishaInterval: parameters.ishaInterval ?? 0,
  );
}

adhan.CalculationParameters _methodParameters(PrayerMethod method) =>
    switch (method) {
      PrayerMethod.auto || PrayerMethod.muslimWorldLeague =>
        adhan.CalculationMethodParameters.muslimWorldLeague(),
      PrayerMethod.russia => adhan.CalculationMethodParameters.russia(),
      PrayerMethod.ummAlQura => adhan.CalculationMethodParameters.ummAlQura(),
      PrayerMethod.egyptian => adhan.CalculationMethodParameters.egyptian(),
      PrayerMethod.karachi => adhan.CalculationMethodParameters.karachi(),
      PrayerMethod.northAmerica =>
        adhan.CalculationMethodParameters.northAmerica(),
      PrayerMethod.moonsighting =>
        adhan.CalculationMethodParameters.moonsightingCommittee(),
      PrayerMethod.turkiye => adhan.CalculationMethodParameters.turkiye(),
      PrayerMethod.dubai => adhan.CalculationMethodParameters.dubai(),
      PrayerMethod.kuwait => adhan.CalculationMethodParameters.kuwait(),
      PrayerMethod.qatar => adhan.CalculationMethodParameters.qatar(),
      PrayerMethod.singapore => adhan.CalculationMethodParameters.singapore(),
      PrayerMethod.indonesian => adhan.CalculationMethodParameters.indonesian(),
      PrayerMethod.tehran => adhan.CalculationMethodParameters.tehran(),
      PrayerMethod.jafari => adhan.CalculationMethodParameters.jafari(),
      PrayerMethod.france => adhan.CalculationMethodParameters.france(),
      PrayerMethod.morocco => adhan.CalculationMethodParameters.morocco(),
      PrayerMethod.algerian => adhan.CalculationMethodParameters.algerian(),
      PrayerMethod.tunisia => adhan.CalculationMethodParameters.tunisia(),
      PrayerMethod.jordan => adhan.CalculationMethodParameters.jordan(),
      PrayerMethod.portugal => adhan.CalculationMethodParameters.portugal(),
    };

adhan.Prayer _moment(DayMoment moment) => switch (moment) {
  DayMoment.fajr => adhan.Prayer.fajr,
  DayMoment.sunrise => adhan.Prayer.sunrise,
  DayMoment.dhuhr => adhan.Prayer.dhuhr,
  DayMoment.asr => adhan.Prayer.asr,
  DayMoment.maghrib => adhan.Prayer.maghrib,
  DayMoment.isha => adhan.Prayer.isha,
};

adhan.CalculationParameters _parameters(
  PrayerSettings settings,
  PrayerLocation location,
) {
  final parameters = _methodParameters(effectiveMethod(settings, location));
  parameters
    ..madhab = switch (settings.asr) {
      AsrSchool.standard => adhan.Madhab.shafi,
      AsrSchool.hanafi => adhan.Madhab.hanafi,
    }
    // Adhan recommends 1/7 of the night above 48°; `recommended` ignores the
    // southern hemisphere, so the latitude is taken by magnitude.
    ..highLatitudeRule = switch (settings.highLatitude) {
      PrayerHighLatitude.auto =>
        location.latitude.abs() > 48
            ? adhan.HighLatitudeRule.seventhOfTheNight
            : adhan.HighLatitudeRule.middleOfTheNight,
      PrayerHighLatitude.middleOfTheNight =>
        adhan.HighLatitudeRule.middleOfTheNight,
      PrayerHighLatitude.seventhOfTheNight =>
        adhan.HighLatitudeRule.seventhOfTheNight,
      PrayerHighLatitude.angle => adhan.HighLatitudeRule.twilightAngle,
    }
    // Inside the polar circle the nearest day with a sunrise is used.
    ..polarCircleResolution = adhan.PolarCircleResolution.aqrabYaum
    ..adjustments = {
      for (final moment in DayMoment.values)
        _moment(moment): settings.adjustmentOf(moment),
    };
  return parameters;
}

/// Local noon of the calendar day of [date]: `+24 h` stays on the next
/// calendar day across DST changes, which adhan relies on.
DateTime _noon(DateTime date) => DateTime(date.year, date.month, date.day, 12);

adhan.PrayerTimes _times(
  PrayerLocation location,
  DateTime date,
  adhan.CalculationParameters parameters,
) => adhan.PrayerTimes(
  coordinates: adhan.Coordinates(location.latitude, location.longitude),
  date: _noon(date),
  calculationParameters: parameters,
);

/// Times of the local calendar day of [date] at [location].
DayTimes dayTimes(
  PrayerSettings settings,
  PrayerLocation location,
  DateTime date,
) => _dayTimes(settings, location, date, () => _parameters(settings, location));

/// Times of [count] calendar days from the day of [first], in order; the
/// calculation parameters are built once for the whole range.
List<DayTimes> daysTimes(
  PrayerSettings settings,
  PrayerLocation location,
  DateTime first,
  int count,
) {
  adhan.CalculationParameters? parameters;
  return [
    for (var day = 0; day < count; day++)
      _dayTimes(
        settings,
        location,
        // Calendar addition: a DST change must not move the day.
        DateTime(first.year, first.month, first.day + day),
        () => parameters ??= _parameters(settings, location),
      ),
  ];
}

DayTimes _dayTimes(
  PrayerSettings settings,
  PrayerLocation location,
  DateTime date,
  adhan.CalculationParameters Function() parameters,
) {
  // A published table wins where it covers the date; shifts apply on top.
  final tabled = settings.table?.day(date);
  if (tabled != null) {
    return {
      for (final entry in tabled.entries)
        entry.key: entry.value.add(
          Duration(minutes: settings.adjustmentOf(entry.key)),
        ),
    };
  }
  final times = _times(location, date, parameters());
  return {
    DayMoment.fajr: times.fajr.toLocal(),
    DayMoment.sunrise: times.sunrise.toLocal(),
    DayMoment.dhuhr: times.dhuhr.toLocal(),
    DayMoment.asr: times.asr.toLocal(),
    DayMoment.maghrib: times.maghrib.toLocal(),
    DayMoment.isha: times.isha.toLocal(),
  };
}

/// Every day of [month] (1–12) of [year], in order.
List<DayTimes> monthTimes(
  PrayerSettings settings,
  PrayerLocation location,
  int year,
  int month,
) => daysTimes(
  settings,
  location,
  DateTime(year, month),
  DateTime(year, month + 1, 0).day,
);

/// Middle and last third of the night that starts at Maghrib of [date].
NightTimes nightTimes(
  PrayerSettings settings,
  PrayerLocation location,
  DateTime date,
) {
  final table = settings.table;
  final tomorrow = DateTime(date.year, date.month, date.day + 1);
  if (table != null && table.day(date) != null && table.day(tomorrow) != null) {
    final evening = dayTimes(settings, location, date)[DayMoment.maghrib]!;
    final morning = dayTimes(settings, location, tomorrow)[DayMoment.fajr]!;
    final length = morning.difference(evening);
    return (
      middle: evening.add(length ~/ 2),
      lastThird: evening.add(length * 2 ~/ 3),
    );
  }
  final night = adhan.SunnahTimes(
    _times(location, date, _parameters(settings, location)),
    precision: false,
  );
  return (
    middle: night.middleOfTheNight.toLocal(),
    lastThird: night.lastThirdOfTheNight.toLocal(),
  );
}

/// Bearing to the Kaaba in degrees clockwise from true north.
double qiblaBearing(PrayerLocation location) =>
    adhan.Qibla.qibla(adhan.Coordinates(location.latitude, location.longitude));

/// The five prayers of the local calendar day of [date].
PrayerDay prayerDay(
  PrayerSettings settings,
  PrayerLocation location,
  DateTime date,
) {
  final times = dayTimes(settings, location, date);
  return {
    Prayer.fajr: times[DayMoment.fajr]!,
    Prayer.dhuhr: times[DayMoment.dhuhr]!,
    Prayer.asr: times[DayMoment.asr]!,
    Prayer.maghrib: times[DayMoment.maghrib]!,
    Prayer.isha: times[DayMoment.isha]!,
  };
}

/// Today's times until Isha has passed, then tomorrow's with Fajr next.
/// Null without a location.
PrayerSnapshot? prayerSnapshot(PrayerSettings settings, DateTime now) {
  final location = settings.location;
  if (location == null) return null;
  var day = prayerDay(settings, location, now);
  var upcoming = Prayer.values.where((p) => day[p]!.isAfter(now)).firstOrNull;
  if (upcoming == null) {
    day = prayerDay(settings, location, now.add(const Duration(days: 1)));
    upcoming = Prayer.fajr;
  }
  return PrayerSnapshot(
    day: day,
    next: upcoming,
    remaining: day[upcoming]!.difference(now),
  );
}
