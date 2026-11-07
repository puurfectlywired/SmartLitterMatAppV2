//////////////////////////////////////////FORMAT CAT AGE//////////////////////////////////////////
String formatCatAge(DateTime birthday) {

  final now = DateTime.now();

  int years = now.year - birthday.year;
  int months = now.month - birthday.month;

  // ACCOUNT FOR BIRTHDAY NOT YET REACHED THIS MONTH
  if (now.day < birthday.day) {
    months--;
  }

  // ADJUST NEGATIVE MONTHS
  if (months < 0) {
    years--;
    months += 12;
  }

  // CAT IS LESS THAN ONE YEAR OLD
  if (years < 1) {

    final totalMonths = years * 12 + months;

    if (totalMonths < 1) {
      return 'Less than 1 month';
    }

    return '$totalMonths ${totalMonths == 1 ? 'month' : 'months'}';
  }

  // CAT IS ONE YEAR OR OLDER
  return '$years ${years == 1 ? 'year' : 'years'}';
}