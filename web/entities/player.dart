import 'dart:html';

import '../collision.dart';
import '../game.dart';
import '../vector.dart';

import '../traits/traits.dart';
import 'entity.dart';

class PlayerAnimation extends Animation {
  PlayerAnimation(Player entity) : super(entity);

  Player get player => entity as Player;
  Move get move => player.move;

  @override
  final animations = {
    'go': [
      Rectangle(104, 41, 17, 23),
      Rectangle(9, 41, 17, 23),
      Rectangle(41, 41, 17, 23),
      Rectangle(72, 41, 17, 23),
    ],
    'stop': [Rectangle(9, 41, 17, 23)],
    'jump': [Rectangle(168, 41, 17, 23)],
    'fall': [Rectangle(200, 41, 17, 23)],
    'stop-on-ladder': [Rectangle(583, 41, 17, 23)],
    'climbing': [
      Rectangle(583, 41, 17, 23),
      Rectangle(616, 41, 17, 23),
      Rectangle(647, 41, 17, 23),
      Rectangle(680, 41, 17, 23),
    ]
  };

  num lastPositionY = 0;

  @override
  void changeFrame() {
    if (move.collisionDirections.contains(Directions.Bottom)) {
      currentAnimation = move.by.x == 0 ? 'stop' : 'go';
    } else if (player.ladderCollider.onLadder ||
        player.ladderCollider.standingOnLadder) {
      currentAnimation = 'stop-on-ladder';

      if (move.by.y != 0) currentAnimation = 'climbing';
    } else {
      currentAnimation = player.position.y < lastPositionY ? 'jump' : 'fall';
    }

    if (move.by.x > 0) flipFrame = false;
    if (move.by.x < 0) flipFrame = true;

    lastPositionY = player.position.y;
  }
}

class Player extends BoxEntity {
  Move move;
  PlayerAnimation animation;
  Jump jump;
  Gravity gravity;
  LadderCollider ladderCollider;

  Player() : super(Vector(10, 10), Vector(15, 23)) {
    illustrators.add(animation = PlayerAnimation(this));

    addTrait(animation);
    addTrait(gravity = Gravity(this));
    addTrait(jump = Jump(this));
    addTrait(move = Move.withTileCollider(this));

    move.addCollider(ladderCollider = LadderCollider(move, this));

    jump.time = 21;
  }

  final speed = 100;

  @override
  void update(num deltaTime, Game game) {
    super.update(deltaTime, game);

    var go = 0;

    if (move.collisionDirections.contains(Directions.Platform)) {
      if (game.keyboard.isClickedKey('s')) {
        final platformCollider =
            move.colliders[PlatformCollider] as PlatformCollider;

        platformCollider.goDown = true;
      }
    }

    if (ladderCollider.standingOnLadder) {
      var ladderSpeed = 0;

      if (game.keyboard.isClickedKey('s')) {
        ladderCollider.goLadderDown = true;
        ladderSpeed = speed;
      } else {
        ladderCollider.goLadderDown = false;
      }

      move.by.y += ladderSpeed;
    } else if (ladderCollider.onLadder) {
      var ladderSpeed = 0;

      jump.stop();

      gravity.disabled = true;

      if (game.keyboard.isClickedKey('w')) ladderSpeed = -speed;
      if (game.keyboard.isClickedKey('s')) {
        ladderCollider.goLadderDown = true;
        ladderSpeed = speed;
      } else {
        ladderCollider.goLadderDown = false;
      }

      move.by.y += ladderSpeed;
    } else if (!jump.isJumping) {
      gravity.disabled = false;
    }

    if (game.keyboard.isClickedKey('a')) go = -speed;
    if (game.keyboard.isClickedKey('d')) go = speed;
    if (game.keyboard.isClickedKey(' ')) {
      jump.start();
    } else if (!ladderCollider.onLadder) {
      jump.stop();
    }

    move.by.x += go;

    // restart game

    var restart = top > game.map.size.y;

    for (var snake in game.snakes) {
      if (aabb(this, snake)) restart = true;
    }

    if (restart) {
      position = Vector.blank();
      jump.stop();
    }
  }
}
