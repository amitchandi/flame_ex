import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_klondike/klondike_game.dart';

class UndoButton extends PositionComponent
    with TapCallbacks, HasGameRef<KlondikeGame> {
  late final Sprite image;
  @override
  Future<void>? onLoad() async {
    image = await gameRef.loadSprite('undo.png');
  }

  @override
  void onTapUp(TapUpEvent event) {
    gameRef.undoMove();
  }

  @override
  void render(Canvas canvas) {
    image.render(canvas);
  }
}
