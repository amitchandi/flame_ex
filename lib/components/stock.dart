import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import '../klondike_game.dart';
import '../pile.dart';
import 'card.dart';
import 'waste.dart';

class StockPile extends PositionComponent
    with TapCallbacks, HasGameRef<KlondikeGame>
    implements Pile {
  StockPile({super.position}) : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<Card> _cards = [];
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  @override
  void acquireCard(Card card) {
    assert(!card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
    card.pile = this;
  }

  void acquireCardsFromWaste(List<Card> cards) {
    for (int i = 0; i < cards.length; i++) {
      Card card = cards[i];
      if (card.isFaceUp) {
        card.flip();
      }
      card.priority = 100 + i;
      card.moveCard(position, () async {
        card.priority = _cards.length;
        _cards.add(card);
        card.pile = this;
      }, i <= 2);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final wastePile = parent!.firstChild<WastePile>()!;
    if (_cards.isEmpty) {
      List<Card> movedCards = wastePile.removeAllCards().reversed.toList();
      acquireCardsFromWaste(movedCards);
      gameRef.addMove(wastePile, this, movedCards, null, null);
    } else {
      int numMovedCards = 3;
      if (gameRef.isEasy) {
        numMovedCards = 1;
      }
      List<Card> movedCards = [];
      for (var i = 0; i < numMovedCards; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          movedCards.add(card);
        }
      }
      wastePile.acquireCardsFromStock(movedCards);
      gameRef.addMove(this, wastePile, movedCards, null, null);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      KlondikeGame.cardWidth * 0.3,
      _circlePaint,
    );
  }

  @override
  bool canMoveCard(Card card) => false;

  @override
  bool canAcceptCard(Card card) {
    return false;
  }

  @override
  void removeCard(Card card) {
    _cards.remove(card);
  }

  @override
  void returnCard(Card card) =>
      throw StateError('cannot remove cards from here');

  @override
  Card? getLastCard() {
    return _cards.isEmpty ? null : _cards.last;
  }

  @override
  void removeAllCards() {
    _cards.clear();
  }

  bool isEmpty() {
    return _cards.isEmpty;
  }
}
