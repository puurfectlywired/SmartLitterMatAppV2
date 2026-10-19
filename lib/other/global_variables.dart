


//WEIGHT CONTROL
//default weight unit
String weightUnit = 'lb';

//store weight value
double storeWeight(double enteredWeight) {
  if (weightUnit == 'kg') {
    return enteredWeight * 2.20462;
    }
    else if (weightUnit == 'g') {
      return enteredWeight * 453.59237;
    }
    else {
      return enteredWeight;
    }
}

//convert weight unit, assuming internally stored as Kg
String displayWeight(double weightKg) {
  if (weightUnit == 'kg') {
    return '${(weightKg / 2.20462).toStringAsFixed(1)} lb';
  } 
  else if (weightUnit == 'g') {
    return '${(weightKg * 453.59237).toStringAsFixed(0)} g';
  } 
  else {
    return '${weightKg.toStringAsFixed(1)} lb';
  }
}