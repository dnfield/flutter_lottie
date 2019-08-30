import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import 'model/animation.dart';
import 'model/layers.dart';

class LottiePlayer {
  LottiePlayer(this.animation) : assert(animation != null);

  final LottieAnimation animation;

  /// Draws an animation frame to the [Canvas] with a given [size],
  /// and [progress].
  ///
  /// The [progress] argument will be clamped betwee 0..1.
  ///
  /// All arguments are required.
  void drawFrame({
    @required Canvas canvas,
    @required double progress,
    @required Size size,
  }) {
    assert(canvas != null);
    assert(progress != null);

    progress = progress.clamp(0.0, 1.0);
    final double frameTime = animation.frameTimeForProgress(progress);
    print(frameTime);

    for (Layer layer in animation.layers.where(
      (Layer layer) => layer.containsFrame(frameTime),
    )) {
      final double opacity = (layer.transform?.opacity?.valueAt(frameTime) ?? 100) / 100;
      if (opacity <= 0) {
        continue;
      }

      final Matrix4 matrix = layer.transform?.toMatrix4(frameTime);
      if (matrix != null && !matrix.isIdentity()) {
        canvas.save();
        canvas.transform(matrix.storage);
      }

      drawLayer(
        layer,
        canvas: canvas,
        frameTime: frameTime,
        size: size,
        opacity: opacity,
      );
      if (matrix != null && !matrix.isIdentity()) {
        canvas.restore();
      }
    }
  }

  void drawLayer(
    Layer layer, {
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
    @required double opacity,
  }) {
    assert(layer != null);

    // for (var shape in layer.shapes) {
    //   shape.drawShape(
    //     canvas: canvas,
    //     frameTime: frameTime,
    //     size: size,
    //   );
    // }
  }
}
