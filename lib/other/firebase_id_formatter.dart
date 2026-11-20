

class FirebaseIdFormatter {

  //////////////////////////////////////////MONTH NAMES//////////////////////////////////////////
  static const List<String> _months = [
    '',
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];


  //////////////////////////////////////////FORMAT DATE//////////////////////////////////////////
  // EXAMPLE: nov-17-2026
  static String formatDate(DateTime date) {

    final local = date.toLocal();

    return '${_months[local.month]}-${local.day}-${local.year}';
  }


  //////////////////////////////////////////FORMAT DATE AND TIME//////////////////////////////////////////
  // EXAMPLE: nov-17-2026_8:18pm
  static String formatDateTime(DateTime date) {

    final local = date.toLocal();

    final hour = local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'pm' : 'am';

    return '${formatDate(local)}_$hour:$minute$period';
  }


  //////////////////////////////////////////FORMAT DATE AND TIME WITH SECONDS//////////////////////////////////////////
  // EXAMPLE: nov-17-2026_8:18:32pm
  static String formatDateTimeSeconds(DateTime date) {

    final local = date.toLocal();

    final hour = local.hour % 12 == 0
        ? 12
        : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'pm' : 'am';

    return '${formatDate(local)}_$hour:$minute:$second$period';
  }


  //////////////////////////////////////////CAT PROFILE ID//////////////////////////////////////////
  // EXAMPLE: zeusu
  static String catProfile(String name) {

    return name.trim().toLowerCase().replaceAll(' ', '_');
  }









  //////////////////////////////////////////AMMONIA ALERT ID//////////////////////////////////////////
  // EXAMPLE: elevated_21.95%
  static String ammoniaAlert(double percentIncrease) {

    return 'elevated_${percentIncrease.toStringAsFixed(2)}%';
  }


  //////////////////////////////////////////AMMONIA ALERT HISTORY ID//////////////////////////////////////////
  // EXAMPLE: cleaned_nov-17-2026_8:18pm
  static String ammoniaHistory(DateTime cleanedAt) {

    return 'cleaned_${formatDateTime(cleanedAt)}';
  }










  //////////////////////////////////////////WEIGHT MEASUREMENT ID//////////////////////////////////////////
  // EXAMPLE: nov-17-2026_8:18:32pm
  static String weightMeasurement(DateTime timestamp) {

    return formatDateTimeSeconds(timestamp);
  }


  //////////////////////////////////////////WEIGHT ALERT ID//////////////////////////////////////////
  // EXAMPLE: gain_nov-17-2026
  static String weightAlert({
    required String type,
    required DateTime timestamp,
  }) {

    return '${type.trim().toLowerCase()}_${formatDate(timestamp)}';
  }


  //////////////////////////////////////////WEIGHT ALERT HISTORY ID//////////////////////////////////////////
  // EXAMPLE: gain_acknowledged_nov-17-2026_8:18pm
  static String weightAlertHistory({
    required String type,
    required DateTime acknowledgedAt,
  }) {

    return '${type.trim().toLowerCase()}_acknowledged_${formatDateTime(acknowledgedAt)}';
  }











  //////////////////////////////////////////LITTER VISIT ID//////////////////////////////////////////
  // EXAMPLE: nov-17-2026_8:18:32pm
  static String litterVisit(DateTime timestamp) {

    return formatDateTimeSeconds(timestamp);
  }


  //////////////////////////////////////////FREQUENCY ALERT ID//////////////////////////////////////////
  // EXAMPLE: increase_nov-14-2026
  static String frequencyAlert({
    required String type,
    required DateTime timestamp,
  }) {

    return '${type.trim().toLowerCase()}_${formatDate(timestamp)}';
  }


  //////////////////////////////////////////FREQUENCY ALERT HISTORY ID//////////////////////////////////////////
  // EXAMPLE: increase_acknowledged_nov-17-2026_8:18pm
  static String frequencyAlertHistory({
    required String type,
    required DateTime acknowledgedAt,
  }) {

    return '${type.trim().toLowerCase()}_acknowledged_${formatDateTime(acknowledgedAt)}';
  }













  //////////////////////////////////////////REPORT HISTORY ID//////////////////////////////////////////
  // EXAMPLE: nov-1-2026_to_nov-17-2026
  static String reportHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) {

    return '${formatDate(startDate)}_to_${formatDate(endDate)}';
  }

}
