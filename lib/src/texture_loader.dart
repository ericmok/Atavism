part of atavism_engine;


class TextureLoader {
  static const String ZUG = 'assets/zug/red.png';
  static const String MARINE = 'assets/marine/marine.png';
  static const String TEST = 'assets/common/test.png';

  static load() async {
    AssetLoader aL = new AssetLoader([ZUG, MARINE]);
    await aL.load();
  }
}
