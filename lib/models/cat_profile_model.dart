//////////////////////////////////////////CAT PROFILE MODEL//////////////////////////////////////////
class CatProfile {

  final String id;
  final String name;
  final DateTime birthday;
  final String breed;
  final String sex;
  final double weight;
  final String? imagePath;

  CatProfile({
    required this.id,
    required this.name,
    required this.birthday,
    required this.breed,
    required this.sex,
    required this.weight,
    this.imagePath,
  });

  //////////////////////////////////////////JSON CONVERSION//////////////////////////////////////////
  factory CatProfile.fromJson(Map<String, dynamic> json) {

    return CatProfile(
      id: json['id'],
      name: json['name'],
      birthday: DateTime.parse(json['birthday'] as String),
      breed: json['breed'],
      sex: json['sex'],
      weight: (json['weight'] as num).toDouble(),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'name': name,
      'birthday': birthday.toIso8601String(),
      'breed': breed,
      'sex': sex,
      'weight': weight,
      'imagePath': imagePath,
    };
  }

  //////////////////////////////////////////CALCULATE AGE IN YEARS//////////////////////////////////////////
  // age is not stored in firebase, but calculated from the birthday when needed
  int get age {

    final now = DateTime.now();

    int years = now.year - birthday.year;

    if (
      now.month < birthday.month ||
      (now.month == birthday.month && now.day < birthday.day)
    ) {
      years--;
    }

    return years;
  }
}