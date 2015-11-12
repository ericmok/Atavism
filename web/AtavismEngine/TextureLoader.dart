part of AtavismEngine;


class TextureLoader {
  static const String ZUG = 'Zug/red.png';
  static html.ImageElement ZUG_IMAGE;

  static void load() {
    ZUG_IMAGE = html.querySelector("#zug");
  }
}