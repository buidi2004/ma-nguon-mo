import 'package:flutter_test/flutter_test.dart';
import 'package:transit_kit/transit_kit.dart';

void main() {
  test('verify transit types', () {
    expect(TransitType.heroScale, isNotNull);
    expect(TransitType.cinematicReveal, isNotNull);
    expect(TransitType.cinematicBars, isNotNull);
    expect(TransitType.dollyZoomIn, isNotNull);
    expect(TransitType.neonGlow, isNotNull);
    expect(TransitType.flashBlack, isNotNull);
    expect(TransitType.fadeThrough, isNotNull);
    expect(TransitType.cupertino, isNotNull);
    expect(TransitType.cupertinoFade, isNotNull);
    expect(TransitType.modalBottom, isNotNull);
    expect(TransitType.parallaxSlideRight, isNotNull);
    expect(TransitType.smoothPopIn, isNotNull);
    expect(TransitType.fadeSlideUp, isNotNull);
    expect(TransitType.sharedAxisX, isNotNull);
    expect(TransitType.slideRightFade, isNotNull);
    expect(TransitType.spotlightReveal, isNotNull);
    expect(TransitType.frostedGlass, isNotNull);
    expect(TransitType.circularRevealCenter, isNotNull);
    expect(TransitType.curtainHorizontal, isNotNull);
    expect(TransitType.curtainVertical, isNotNull);
    expect(TransitType.waveMotionRight, isNotNull);
    expect(TransitType.depthFadeIn, isNotNull);
    expect(TransitType.deckShuffle, isNotNull);
    expect(TransitType.stairStepRight, isNotNull);
    expect(TransitType.elasticOvershoot, isNotNull);
    expect(TransitType.shutterVertical, isNotNull);
    expect(TransitType.depthPull, isNotNull);
    expect(TransitType.depthPush, isNotNull);
    expect(TransitType.accordionVertical, isNotNull);
    expect(TransitType.bookOpenRight, isNotNull);
    expect(TransitType.glitchFade, isNotNull);
    expect(TransitType.glitchHorizontal, isNotNull);
    expect(TransitType.pixelDissolve, isNotNull);
    expect(TransitType.values.length, 384);
  });
}
