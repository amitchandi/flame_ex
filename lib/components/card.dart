import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_klondike/components/stock.dart';
import 'package:flame_klondike/components/waste.dart';

import '../klondike_game.dart';
import '../pile.dart';
import '../rank.dart';
import '../suit.dart';
import 'dart:ui';

import 'pile.dart';

class Card extends PositionComponent
    with DragCallbacks, HasGameRef<KlondikeGame> {
  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    KlondikeGame.cardSize.toRect(),
    const Radius.circular(KlondikeGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  // static final Sprite flameSprite = klondikeSprite(1367, 6, 357, 501);
  static final Sprite backSprite = cardsSprite(1752, 2, 60, 92);

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color(0xff7ab2e8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;

  static final blueFilter = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x880d8bff),
      BlendMode.srcATop,
    );
  static final Sprite blackJack = klondikeSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static final Sprite blackQueen = klondikeSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static final Sprite blackKing = klondikeSprite(1305, 532, 407, 549)
    ..paint = blueFilter;

  static final Sprite redJack = klondikeSprite(81, 565, 562, 488);
  static final Sprite redQueen = klondikeSprite(717, 541, 486, 515);
  static final Sprite redKing = klondikeSprite(1305, 532, 407, 549);

  Card(int intRank, int intSuit)
      : rank = Rank.of(intRank),
        suit = Suit.fromInt(intSuit),
        _faceUp = false,
        super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;
  bool _faceUp;

  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() => _faceUp = !_faceUp;

  Pile? pile;
  bool _isDragging = false;

  @override
  String toString() => rank.label + suit.label; // e.g. "Q♠" or "10♦"

  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      // _renderFront(canvas);
      _newRenderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  void _newRenderFront(Canvas canvas) {
    var data = gameRef.cardSpritesData.where(
      (element) {
        return element.name == '${rank.value}_${suit.name}';
      },
    ).first;
    cardsSprite(data.x.toDouble(), data.y.toDouble(), data.width.toDouble(),
            data.height.toDouble())
        .render(canvas,
            position: size / 2,
            anchor: Anchor.center,
            size: Vector2(KlondikeGame.cardWidth, KlondikeGame.cardHeight));
  }

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      suit.isRed ? redBorderPaint : blackBorderPaint,
    );
    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    _drawSprite(canvas, rankSprite, 0.1, 0.08);
    _drawSprite(canvas, rankSprite, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5, rotate: true);
    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, 0.5, 0.5, scale: 2.5);
        break;
      case 2:
        _drawSprite(canvas, suitSprite, 0.5, 0.25);
        _drawSprite(canvas, suitSprite, 0.5, 0.25, rotate: true);
        break;
      case 3:
        _drawSprite(canvas, suitSprite, 0.5, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        _drawSprite(canvas, suitSprite, 0.5, 0.2, rotate: true);
        break;
      case 4:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 5:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        break;
      case 6:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 7:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        break;
      case 8:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.35, rotate: true);
        break;
      case 9:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
        break;
      case 10:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.3, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
        break;
      case 11:
        _drawSprite(canvas, suit.isRed ? redJack : blackJack, 0.5, 0.5);
        break;
      case 12:
        _drawSprite(canvas, suit.isRed ? redQueen : blackQueen, 0.5, 0.5);
        break;
      case 13:
        _drawSprite(canvas, suit.isRed ? redKing : blackKing, 0.5, 0.5);
        break;
    }
  }

  void _renderBack(Canvas canvas) {
    // canvas.drawRRect(cardRRect, backBackgroundPaint);
    // canvas.drawRRect(cardRRect, backBorderPaint1);
    // canvas.drawRRect(backRRectInner, backBorderPaint2);
    // flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
    backSprite.render(canvas,
        position: size / 2,
        anchor: Anchor.center,
        size: Vector2(KlondikeGame.cardWidth, KlondikeGame.cardHeight));
  }

  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (pile?.canMoveCard(this) ?? false) {
      gameRef.flip.start(volume: 0.1);
      _isDragging = true;
      priority = 100;
      if (pile is TableauPile) {
        attachedCards.clear();
        final extraCards = (pile! as TableauPile).cardsOnTop(this);
        for (final card in extraCards) {
          card.priority = attachedCards.length + 101;
          attachedCards.add(card);
        }
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final cameraZoom = (findGame()! as FlameGame)
        .firstChild<CameraComponent>()!
        .viewfinder
        .zoom;
    final delta = event.delta / cameraZoom;
    position.add(delta);
    for (var card in attachedCards) {
      card.position.add(delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging) {
      return;
    }
    var fromPile = pile;
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        Card? formerParent;
        bool? formerWasFlipped;
        if (fromPile is WastePile) {
          int i = fromPile.indexOfCard(this);
          if (i > 0) {
            formerParent = fromPile.cardOfIndex(i - 1);
          }
        }
        if (fromPile is TableauPile) {
          formerParent = fromPile.getParentCard(this);
          formerWasFlipped = formerParent?.isFaceDown;
        }
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        gameRef.addMove(fromPile!, dropPiles.first, [this, ...attachedCards],
            formerParent, formerWasFlipped);
        if (attachedCards.isNotEmpty) {
          for (var card in attachedCards) {
            dropPiles.first.acquireCard(card);
          }
          attachedCards.clear();
        }
        StockPile spile = gameRef.stock;
        WastePile wpile = gameRef.waste;
        var cards = (findGame()! as FlameGame)
            .children
            .whereType<World>()
            .first
            .children
            .whereType<Card>()
            .where((card) => card.isFaceDown);
        if (wpile.isEmpty() && spile.isEmpty() && cards.isEmpty) {
          gameRef.finishGame();
        }
        return;
      }
    }
    if (attachedCards.isNotEmpty) {
      (pile as TableauPile).returnCards([this, ...attachedCards]);
      attachedCards.clear();
    } else {
      pile!.returnCard(this);
    }
  }

  final List<Card> attachedCards = [];

  void moveCard(Vector2 destination, Future<void> Function()? onComplete,
      bool playSound) async {
    add(MoveToEffect(
      destination,
      EffectController(duration: 0.2),
      onComplete: (() async {
        await onComplete?.call();
        if (playSound) {
          gameRef.place.start(volume: 0.1);
        }
        gameRef.isRunningUndo = false;
      }),
    ));
  }
}
