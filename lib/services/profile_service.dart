import '../models/cat_profile.dart';

class ProfileService {
  
  //replace with your actual API endpoint
  //static const String baseUrl = 'https://cloud_server.com/api/cats';
  //hardcoded example cat profile for testing purposes  
  static final List<CatProfile> _cats = [
    CatProfile(
      id: 'cat_001',
      name: 'Olive',
      age: 10,
      breed: 'Siamese',
      sex: 'Female',
      weight: 11,
      imagePath: null,
    ),

    CatProfile(
      id: 'cat_002',
      name: 'Winston',
      age: 5,
      breed: 'Maine Coon',
      sex: 'Male',
      weight: 12,
      imagePath: null,
    ),
  ];

  //GET cat profiles from cloud server
  static Future<List<CatProfile>> getProfiles() async {
    
    // when cloud server is implemented, uncomment the following code and remove the return _cats; line below
    // final response = await http.get(
    //   Uri.parse('$baseUrl/profiles'),
    // );

    // if (response.statusCode == 200) {
    //   final List<dynamic> data = jsonDecode(response.body);
    //   return data
    //       .map((json) => CatProfile.fromJson(json))
    //       .toList();
    // } else {
    //   throw Exception('Failed to load profiles');
    // }

    return _cats;
  }

  //POST cat profiles to cloud server
  static Future<void> addProfile(CatProfile cat) async {
    
    // when cloud server is implemented, uncomment the following code and remove the _cats.add(cat); line below
    // final response = await http.post(
    //   Uri.parse('$baseUrl/profiles'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode(cat.toJson()),
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Failed to create profile');
    // }

    _cats.add(cat);
  }

  //PUT/PATCH cat profiles to cloud server
  static Future<void> updateProfile(CatProfile cat) async {
    final index = _cats.indexWhere(
      (existingCat) => existingCat.id == cat.id,
    );

    if (index != -1) {
      _cats[index] = cat;
    }
  }

  //DELETE cat profiles from cloud server
  static Future<void> deleteProfile(String id) async {
   
   // when cloud server is implemented, uncomment the following code and remove the _cats.removeWhere line below
    // final response = await http.delete(
    //   Uri.parse('$baseUrl/profiles/$id'),
    // );

    // if (response.statusCode != 200 &&
    //     response.statusCode != 204) {
    //   throw Exception('Failed to delete profile');
    // }
   
    _cats.removeWhere((cat) => cat.id == id);
  }
}