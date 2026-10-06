


//WEIGHT CONTROL
//default weight unit
String weightUnit = 'kg';

//store weight value
double storeWeight(double enteredWeight) {
  if (weightUnit == 'lb') {
    return enteredWeight / 2.20462;
    }
    else if (weightUnit == 'g') {
      return enteredWeight / 1000;
    }
    else {
      return enteredWeight;
    }
}

//convert weight unit, assuming internally stored as Kg
String displayWeight(double weightKg) {
  if (weightUnit == 'lb') {
    return '${(weightKg * 2.20462).toStringAsFixed(1)} lb';
  } 
  else if (weightUnit == 'g') {
    return '${(weightKg * 1000).toStringAsFixed(0)} g';
  } 
  else {
    return '${weightKg.toStringAsFixed(1)} kg';
  }
}