import 'dart:math';

import 'package:tiled/tiled.dart';

import '../box/tile_box.dart';
import '../traits/move.dart';
import 'colliders.dart';

class LadderCollider extends Collider {
  bool onLadder = false, standingOnLadder = false, goLadderDown = false;

  LadderCollider(move, entity) : super(move, entity);

  @override
  Type get name => LadderCollider;

  bool calculatePenetration(num biggerThan, List<TileBox> tiles) {
    for (final tile in tiles) {
      if (tile.left - biggerThan < entity.left &&
          tile.right + biggerThan > entity.right) return true;
    }
    return false;
  }

  @override
  void both(Move move, ladderTiles) {
    onLadder = calculatePenetration(entity.width / 2, ladderTiles);

    if (onLadder &&
        move.by.y > 0 &&
        !goLadderDown &&
        (move.by.x == 0 || standingOnLadder)) {
      standingOnLadder = true;
      final minY = ladderTiles.map((tile) => tile.position.y).reduce(max);
      entity.position.y = minY - entity.size.y;
    } else {
      standingOnLadder = false;
    }
  }

  @override
  void nothing(Move move) {
    onLadder = false;
  }

  @override
  bool Function(TileBox) test(Layer layer) {
    return (TileBox box) =>
        box.tile.properties['ladder'] != null &&
        box.tile.properties['ladder'] == true;
  }
}
