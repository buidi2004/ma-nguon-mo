import 'package:flutter_test/flutter_test.dart';
import 'package:transit_kit/transit_kit.dart';

void main() {
  test('verify transit types', () {
    expect(TransitType.heroScale, isNotNull);
    expect(TransitType.cinematicReveal, isNotNull);
    expect(TransitType.flashBlack, isNotNull);
    expect(TransitType.fadeThrough, isNotNull);
    expect(TransitType.cupertino, isNotNull);
    expect(TransitType.modalBottom, isNotNull);
    expect(TransitType.parallaxSlideRight, isNotNull);
    expect(TransitType.smoothPopIn, isNotNull);
    expect(TransitType.values.length, 384);
  });
}
