


//List<CatProfile> catProfiles = []; // Example list of cat profiles

class CatProfile {
  final String id;
  final String name;
  final String age;
  final String breed;
  final String sex;
  final double weight;
  final String? imagePath;

  CatProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.breed,
    required this.sex,
    required this.weight,
    this.imagePath,
  });

//JSON CONVERSION
  factory CatProfile.fromJson(Map<String, dynamic> json) {
    return CatProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      breed: json['breed'],
      sex: json['sex'],
      weight: json['weight'].toDouble(),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'breed': breed,
      'sex': sex,
      'weight': weight,
      'imagePath': imagePath,
    };
  }
}