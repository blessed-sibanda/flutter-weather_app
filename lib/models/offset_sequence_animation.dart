import 'dart:ui';

class OffsetSequence {
  final Offset positionA;
  final Offset positionB;
  final Offset positionC;

  OffsetSequence({
    required this.positionA,
    required this.positionB,
    required this.positionC,
  });

  factory OffsetSequence.fromBeginAndEndPositions(
    Offset offsetBegin,
    Offset offsetEnd,
  ) {
    return OffsetSequence(
      positionA: offsetBegin,
      positionB: Offset(offsetBegin.dx, offsetEnd.dy),
      positionC: offsetEnd,
    );
  }
}
