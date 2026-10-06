import '../models/cat_profile.dart';

class CatService {
  static final List<CatProfile> _cats = [];

  static Future<List<CatProfile>> getCats() async {
    return _cats;
  }

  static Future<void> addCat(CatProfile cat) async {
    _cats.add(cat);
  }

  static Future<void> updateCat(CatProfile cat) async {
    final index = _cats.indexWhere(
      (existingCat) => existingCat.id == cat.id,
    );

    if (index != -1) {
      _cats[index] = cat;
    }
  }

  static Future<void> deleteCat(String id) async {
    _cats.removeWhere((cat) => cat.id == id);
  }
}