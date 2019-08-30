import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../parsers.dart';
import 'effects.dart';
import 'properties.dart';
import 'shapes.dart';

abstract class MaskProperty {}

@immutable
class Transform {
  const Transform({
    this.anchorPoint,
    this.position,
    this.scale,
    this.rotation,
    this.opacity,
    this.positionX,
    this.positionY,
    this.positionZ,
    this.skew,
    this.skewAxis,
  });

  static Transform fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return Transform(
      anchorPoint: MultiDimensionalProperty.fromJson(json['a']),
      position: MultiDimensionalProperty.fromJson(json['p']),
      scale: MultiDimensionalProperty.fromJson(json['s']),
      rotation: ValueProperty.fromJson(json['r']),
      opacity: ValueProperty.fromJson(json['o']),
      positionX: ValueProperty.fromJson(json['px']),
      positionY: ValueProperty.fromJson(json['py']),
      positionZ: ValueProperty.fromJson(json['pz']),
      skew: ValueProperty.fromJson(json['sk']),
      skewAxis: ValueProperty.fromJson(json['sa']),
    );
  }

  final MultiDimensionalProperty anchorPoint;
  final MultiDimensionalProperty position;
  final MultiDimensionalProperty scale;
  final ValueProperty rotation;
  final ValueProperty opacity;
  final ValueProperty positionX;
  final ValueProperty positionY;
  final ValueProperty positionZ;
  final ValueProperty skew;
  final ValueProperty skewAxis;

  Matrix4 toMatrix4(double frameTime) {
    final Matrix4 matrix = Matrix4.identity();

    if (position != null) {
      final Offset positionValue = position.valueAt(frameTime);
      if (positionValue != null && positionValue != Offset.zero) {
        matrix.translate(positionValue.dx, positionValue.dy);
      }
    }
    if (rotation != null) {
      final double rotationValue = rotation.valueAt(frameTime);
      if (rotationValue != null && rotationValue != 0) {
        matrix.rotateZ(rotationValue * math.pi / 180.0);
      }
    }
    if (scale != null) {
      final Offset scaleValue = scale.valueAt(frameTime);
      if (scaleValue != null && scaleValue != Offset.zero) {
        matrix.scale(scaleValue.dx, scaleValue.dy);
      }
    }
    if (anchorPoint != null) {
      final Offset anchorPointValue = anchorPoint.valueAt(frameTime);
      if (anchorPointValue != null && anchorPointValue != Offset.zero) {
        matrix.translate(-anchorPointValue.dx, -anchorPointValue.dy);
      }
    }

    return matrix;
  }

  @override
  String toString() => <String>[
        '$runtimeType{\n',
        if (anchorPoint != null) '  anchorPoint: $anchorPoint,\n',
        if (position != null) '  position: $position,\n',
        if (scale != null) '  scale: $scale,\n',
        if (rotation != null) '  rotation: $rotation,\n',
        if (opacity != null) '  opacity: $opacity,\n',
        if (positionX != null) '  positionX: $positionX,\n',
        if (positionY != null) '  positionY: $positionY,\n',
        if (positionZ != null) '  positionZ: $positionZ,\n',
        if (skew != null) '  skew: $skew,\n',
        if (skewAxis != null) '  skewAxis: $skewAxis\n',
        '}'
      ].join();
}

@immutable
abstract class Layer {
  const Layer({
    this.transform,
    this.autoOrient = false,
    this.blendMode,
    this.is3D = false,
    this.index = -1,
    this.inPoint,
    this.outPoint,
    this.startTime,
    this.name,
    this.stretch,
    this.parent,
    this.effects,
    this.maskProperties,
  });

  Layer._fromJson(Map<String, dynamic> json)
      : assert(json != null),
        transform = Transform.fromJson(json['ks']),
        autoOrient = json['ao'] == 1,
        blendMode = parseBlendMode(json['bm'] ?? 0),
        is3D = json['ddd'] == 1,
        index = parseInt(json['ind']) ?? -1,
        inPoint = parseDouble(json['ip']),
        outPoint = parseDouble(json['op']),
        startTime = parseDouble(json['st']),
        name = json['nm'],
        stretch = parseDouble(json['sr']),
        parent = parseInt(json['parent']),
        effects = null, // TODO
        maskProperties = null; // TODO

  static Layer fromJson(Map<String, dynamic> json) {
    assert(json != null);

    switch (json['ty']) {
      case 0:
        return PrecompLayer.fromJson(json);
      case 3:
        return NullLayer.fromJson(json);
      case 4:
        return ShapeLayer.fromJson(json);
    }
    throw 'Unsupported layer ${json['ty']}';
  }

  static Comparator<Layer> startTimeComparator = (Layer a, Layer b) {
    final int startTimeCompare = a.startTime.compareTo(b.startTime);
    if (startTimeCompare == 0) {
      return a.index.compareTo(b.index);
    }
    return startTimeCompare;
  };

  final Transform transform;
  final bool autoOrient;
  final BlendMode blendMode;
  final bool is3D;
  final int index;
  final double inPoint;
  final double outPoint;
  final double startTime;
  final String name;
  final double stretch;
  final int parent;
  final UnmodifiableListView<Effect> effects;
  final UnmodifiableListView<MaskProperty> maskProperties;

  bool containsFrame(double frame) => inPoint <= frame && outPoint >= frame;

  Path toPath(double frameTime);

  String get _extraProperties;

  @override
  String toString() => <String>[
        '$runtimeType{\n',
        if (transform != null) '  transform: $transform,\n',
        if (autoOrient != null) '  autoOrient: $autoOrient,\n',
        if (blendMode != null) '  blendMode: $blendMode,\n',
        if (is3D != null) '  is3D: $is3D,\n',
        if (index != null) '  index: $index,\n',
        if (inPoint != null) '  inPoint: $inPoint,\n',
        if (outPoint != null) '  outPoint: $outPoint,\n',
        if (startTime != null) '  startTime: $startTime,\n',
        if (name != null) '  name: $name,\n',
        if (stretch != null) '  stretch: $stretch,\n',
        if (parent != null) '  parent: $parent,\n',
        if (_extraProperties != null) '$_extraProperties',
        '}'
      ].join();
}

@immutable
class ShapeLayer extends Layer {
  const ShapeLayer({
    Transform transform,
    bool autoOrient,
    BlendMode blendMode,
    bool is3D,
    int index,
    double inPoint,
    double outPoint,
    double startTime,
    String name,
    double stretch,
    int parent,
    UnmodifiableListView<Effect> effects,
    UnmodifiableListView<MaskProperty> maskProperties,
    this.shapes,
  }) : super(
          transform: transform,
          autoOrient: autoOrient,
          blendMode: blendMode,
          is3D: is3D,
          index: index,
          inPoint: inPoint,
          outPoint: outPoint,
          startTime: startTime,
          name: name,
          stretch: stretch,
          parent: parent,
          effects: effects,
          maskProperties: maskProperties,
        );

  ShapeLayer._fromJson({
    Map<String, dynamic> json,
    this.shapes,
  }) : super._fromJson(json);

  static ShapeLayer fromJson(Map<String, dynamic> json) {
    assert(json != null);
    assert(json['ty'] == 4);
    return ShapeLayer._fromJson(
      json: json,
      shapes: parseList(json['shapes'], Shape.fromJson),
    );
  }

  final UnmodifiableListView<Shape> shapes;

  Path toPath(double frameTime) {
    final Path path = Path();
    for (final shape in shapes) {
      path.addPath(shape.toPath(frameTime));
    }
  }

  String get _extraProperties => '  shapes: $shapes\n';
}

@immutable
class NullLayer extends Layer {
  const NullLayer({
    Transform transform,
    bool autoOrient,
    BlendMode blendMode,
    bool is3D,
    int index,
    double inPoint,
    double outPoint,
    double startTime,
    String name,
    double stretch,
    int parent,
    UnmodifiableListView<Effect> effects,
    UnmodifiableListView<MaskProperty> maskProperties,
  }) : super(
          transform: transform,
          autoOrient: autoOrient,
          blendMode: blendMode,
          is3D: is3D,
          index: index,
          inPoint: inPoint,
          outPoint: outPoint,
          startTime: startTime,
          name: name,
          stretch: stretch,
          parent: parent,
          effects: effects,
          maskProperties: maskProperties,
        );

  NullLayer._fromJson({Map<String, dynamic> json}) : super._fromJson(json);

  static NullLayer fromJson(Map<String, dynamic> json) {
    assert(json != null);
    assert(json['ty'] == 3);
    return NullLayer._fromJson(json: json);
  }

  @override
  Path toPath(double frameTime) => null;

  String get _extraProperties => '';
}

@immutable
class PrecompLayer extends Layer {
  const PrecompLayer({
    Transform transform,
    bool autoOrient,
    BlendMode blendMode,
    bool is3D,
    int index,
    double inPoint,
    double outPoint,
    double startTime,
    String name,
    double stretch,
    int parent,
    UnmodifiableListView<Effect> effects,
    UnmodifiableListView<MaskProperty> maskProperties,
    this.referenceId,
    this.timeRemapping,
  }) : super(
          transform: transform,
          autoOrient: autoOrient,
          blendMode: blendMode,
          is3D: is3D,
          index: index,
          inPoint: inPoint,
          outPoint: outPoint,
          startTime: startTime,
          name: name,
          stretch: stretch,
          parent: parent,
          effects: effects,
          maskProperties: maskProperties,
        );

  PrecompLayer._fromJson({
    Map<String, dynamic> json,
    this.referenceId,
    this.timeRemapping,
  }) : super._fromJson(json);

  static PrecompLayer fromJson(Map<String, dynamic> json) {
    assert(json != null);
    assert(json['ty'] == 0);
    return PrecompLayer._fromJson(
      json: json,
      referenceId: json['refId'],
      timeRemapping: ValueProperty.fromJson(json['tm']),
    );
  }

  final String referenceId;
  final ValueProperty timeRemapping;

  @override
  Path toPath(double frameTime) => null;

  String get _extraProperties => '';
}
