import 'dart:html';

import 'camera.dart';
import 'game.dart';

abstract class Drawable {
  void draw(CanvasRenderingContext2D context, Camera camera);
}

abstract class Updateable {
  void update(num deltaTime, Game game);
}
