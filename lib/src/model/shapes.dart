import 'dart:ui';

import 'package:meta/meta.dart';

import '../parsers.dart';
import 'properties.dart';

abstract class Shape {
  const Shape({
    this.matchName,
    this.name,
  });

  static const Map<String, TypedListParser> _kShapeParsers = {
    'el': EllipseShape.fromJson,
    'fl': FillShape.fromJson,
    'gr': ShapeGroup.fromJson,
    'gf': GradientFillShape.fromJson,
    'mm': MergeShape.fromJson,
    'rc': RectShape.fromJson,
    'rd': RoundShape.fromJson,
    'sh': VertexShape.fromJson,
    'sr': StarShape.fromJson,
    'st': StrokeShape.fromJson,
    'tm': TrimShape.fromJson,
    'tr': TransformShape.fromJson,
  };

  static Shape fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    assert(json['ty'] != null);
    final TypedListParser parser = _kShapeParsers[json['ty']];
    return parser?.call(json);
  }

  final String matchName;
  final String name;

  Path toPath(double frameTime);

  String get _extraProperties;

  @override
  String toString() => '$runtimeType{$name, matchName: $matchName$_extraProperties}';
}

abstract class DirectedShape extends Shape {
  const DirectedShape({
    String matchName,
    String name,
    this.direction,
  }) : super(matchName: matchName, name: name);

  final int direction;
  bool get isClockwise => direction != 3;

  @override
  String get _extraProperties => ', direction: $direction$_childExtraProperties';

  String get _childExtraProperties;
}

class MergeShape extends Shape {
  const MergeShape({String name, String matchName, this.type})
      : super(name: name, matchName: matchName);

  static MergeShape fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return MergeShape(
      matchName: json['mn'],
      name: json['nm'],
      type: parsePathOperation(json['mm'] ?? 1),
    );
  }

  /// The type of merge this is.
  ///
  /// A `null` value indicates that this is a simple additive operation, i.e.
  /// [Path.addPath].
  final PathOperation type;

  /// Perform the merge operation this shape represents on the two paths.
  Path merge(Path first, Path second) {
    if (type == null) {
      return first..addPath(second, Offset.zero);
    }
    return Path.combine(type, first, second);
  }

  @override
  Path toPath(double frameTime) => throw UnimplementedError();

  @override
  String get _extraProperties => ', type: $type';
}

class ShapeGroup extends Shape {
  const ShapeGroup({
    this.propertyCount,
    this.shapes,
    String matchName,
    String name,
  }) : super(matchName: matchName, name: name);

  static ShapeGroup fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return ShapeGroup(
      matchName: json['mn'],
      name: json['nm'],
      propertyCount: parseInt(json['np']),
      shapes: parseList(json['it'], Shape.fromJson),
    );
  }

  final int propertyCount;
  final List<Shape> shapes;

  @override
  @override
  Path toPath(double frameTime) {
    Path path = Path();
    for (Shape shape in shapes) {
      path.addPath(shape.toPath(frameTime), Offset.zero);
    }
    return path;
  }

  @override
  String get _extraProperties => ', propertyCount: $propertyCount, $shapes';
}

class EllipseShape extends DirectedShape {
  const EllipseShape({
    String matchName,
    String name,
    int direction,
    this.position,
    this.size,
  }) : super(matchName: matchName, name: name, direction: direction);

  static EllipseShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return EllipseShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      position: MultiDimensionalProperty.fromJson(json['p']),
      size: MultiDimensionalProperty.fromJson(json['s']),
    );
  }

  final MultiDimensionalProperty position;
  final MultiDimensionalProperty size;

  @override
  Path toPath(double frameTime) {
    final ellipseSize = size.valueAt(frameTime);
    if (ellipseSize == null) {
      return null;
    }
    final ellipsePosition = position.valueAt(frameTime);
    if (ellipsePosition == null) {
      return null;
    }
    print('ELLIPSE SHAPE DRAW REQUEST $ellipseSize $ellipsePosition');
    return Path()
      ..addOval(Rect.fromLTWH(
        ellipsePosition.dx,
        ellipsePosition.dy,
        ellipseSize.dx,
        ellipseSize.dy,
      ));
  }

  @override
  String get _childExtraProperties => ', position: $position, size: $size';
}

class RectShape extends DirectedShape {
  const RectShape({
    String matchName,
    String name,
    int direction,
    this.position,
    this.size,
    this.cornerRadii,
  }) : super(matchName: matchName, name: name, direction: direction);

  static RectShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return RectShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      position: MultiDimensionalProperty.fromJson(json['p']),
      size: MultiDimensionalProperty.fromJson(json['s']),
      cornerRadii: ValueProperty.fromJson(json['r']),
    );
  }

  final MultiDimensionalProperty position;
  final MultiDimensionalProperty size;
  final ValueProperty cornerRadii;

  @override
  @override
  Path toPath(double frameTime) {
    final rectSize = size.valueAt(frameTime);
    if (rectSize == null) {
      return null;
    }
    final rectPosition = position.valueAt(frameTime);
    if (rectPosition == null) {
      return null;
    }
    final double radius = cornerRadii.valueAt(frameTime) ?? 0;
    print('ELLIPSE SHAPE DRAW REQUEST $rectSize $rectPosition');
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rectPosition.dx,
          rectPosition.dy,
          rectSize.dx,
          rectSize.dy,
        ),
        Radius.circular(radius),
      ));
  }

  @override
  String get _childExtraProperties =>
      ', position: $position, size: $size, cornerRadii: $cornerRadii';
}

class RoundShape extends DirectedShape {
  const RoundShape({
    String matchName,
    String name,
    int direction,
    this.radius,
  }) : super(matchName: matchName, name: name, direction: direction);

  static RoundShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return RoundShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      radius: ValueProperty.fromJson(json['r']),
    );
  }

  final ValueProperty radius;

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('ROUND SHAPE DRAW REQUEST');
  }

  @override
  String get _childExtraProperties => ', radius: $radius';
}

class VertexShape extends DirectedShape {
  const VertexShape({
    String matchName,
    String name,
    int direction,
    this.vertices,
  }) : super(matchName: matchName, name: name, direction: direction);

  static VertexShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return VertexShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      vertices: ShapeProperty.fromJson(json['ks']),
    );
  }

  final ShapeProperty vertices;

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('VERTEX SHAPE DRAW REQUEST');
  }

  @override
  String get _childExtraProperties => ', vertices: $vertices}';
}

class StrokeShape extends DirectedShape {
  const StrokeShape({
    String matchName,
    String name,
    int direction,
    this.cap,
    this.join,
    this.miterLimit,
    this.opacity,
    this.width,
    this.color,
  }) : super(matchName: matchName, name: name, direction: direction);

  static StrokeShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return StrokeShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      cap: parseStrokeCap(json['lc'] ?? 2),
      join: parseStrokeJoin(json['lj'] ?? 2),
      miterLimit: parseDouble(json['ml']),
      opacity: ValueProperty.fromJson(json['o']),
      width: ValueProperty.fromJson(json['w']),
      color: MultiDimensionalProperty.fromJson(json['c']),
    );
  }

  final StrokeCap cap;
  final StrokeJoin join;
  final double miterLimit;
  final ValueProperty opacity;
  final ValueProperty width;
  final MultiDimensionalProperty color;

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('STROKE SHAPE DRAW REQUEST');
  }

  @override
  String get _childExtraProperties => ', cap: $cap, join: $join, miterLimit: $miterLimit, '
      'opacity: $opacity, width: $width, color: $color';
}

class FillShape extends DirectedShape {
  const FillShape({
    String matchName,
    String name,
    int direction,
    this.opacity,
    this.color,
  }) : super(matchName: matchName, name: name, direction: direction);

  static FillShape fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return FillShape(
      matchName: json['mn'],
      name: json['nm'],
      direction: parseInt(json['d']),
      opacity: ValueProperty.fromJson(json['o']),
      color: MultiDimensionalProperty.fromJson(json['c']),
    );
  }

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('FILL SHAPE DRAW REQUEST');
  }

  final ValueProperty opacity;
  final MultiDimensionalProperty color;

  @override
  String get _childExtraProperties => ', opacity: $opacity, color: $color';
}

class Gradient {
  const Gradient();
  static Gradient fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    final int stopCount = (parseInt(json['p']) ?? 0) - 1;
    if (stopCount < 0) {
      return null;
    }
    return Gradient();
  }
}

abstract class GradientFillShape extends DirectedShape {
  const GradientFillShape({
    String matchName,
    String name,
    this.startPoint,
    this.endPoint,
    // this.highlightLength,
    // this.highlightAngle,
    this.colors,
    this.stops,
  });

  static GradientFillShape fromJson(Map<String, dynamic> json) {
    throw 'TODO';
  }

  final MultiDimensionalProperty startPoint;
  final MultiDimensionalProperty endPoint;
  final MultiDimensionalProperty colors;
  final MultiDimensionalProperty stops;
}

class StarShape extends DirectedShape {
  const StarShape({
    String matchName,
    String name,
    this.position,
    this.innerRadius,
    this.innerRoundness,
    this.outerRadius,
    this.outerRoundness,
    this.rotation,
    this.points,
  }) : super(matchName: matchName, name: name);

  static StarShape fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return StarShape(
      matchName: json['mn'],
      name: json['nm'],
      position: MultiDimensionalProperty.fromJson(json['p']),
      innerRadius: ValueProperty.fromJson(json['ir']),
      innerRoundness: ValueProperty.fromJson(json['is']),
      outerRadius: ValueProperty.fromJson(json['or']),
      outerRoundness: ValueProperty.fromJson(json['os']),
      rotation: ValueProperty.fromJson(json['r']),
      points: ValueProperty.fromJson(json['pt']),
    );
  }

  final MultiDimensionalProperty position;
  final ValueProperty innerRadius;
  final ValueProperty innerRoundness;
  final ValueProperty outerRadius;
  final ValueProperty outerRoundness;
  final ValueProperty rotation;
  final ValueProperty points;

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('STAR SHAPE DRAW REQUEST');
  }

  @override
  String get _childExtraProperties =>
      ', position: $position, innerRadius: $innerRadius, innerRoundness: $innerRoundness, '
      'outerRadius: $outerRadius, outerRoundness: $outerRoundness, rotation: $rotation, points: $points';
}

class TransformShape extends Shape {
  const TransformShape({
    String name,
    this.anchorPoint,
    this.position,
    this.scale,
    this.opacity,
    this.rotation,
    this.skew,
    this.skewAxis,
  }) : super(name: name);

  static TransformShape fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TransformShape(
      name: json['nm'],
      anchorPoint: MultiDimensionalProperty.fromJson(json['a']),
      position: MultiDimensionalProperty.fromJson(json['p']),
      scale: MultiDimensionalProperty.fromJson(json['s']),
      rotation: ValueProperty.fromJson(json['r']),
      opacity: ValueProperty.fromJson(json['o']),
      skew: ValueProperty.fromJson(json['sk']),
      skewAxis: ValueProperty.fromJson(json['sa']),
    );
  }

  final MultiDimensionalProperty anchorPoint;
  final MultiDimensionalProperty position;
  final MultiDimensionalProperty scale;
  final ValueProperty rotation;
  final ValueProperty opacity;
  final ValueProperty skew;
  final ValueProperty skewAxis;
  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('TRANSFORM SHAPE DRAW REQUEST');
  }

  @override
  String get _extraProperties => ', anchorPoint: $anchorPoint, position: $position, '
      'scale: $scale, rotation: $rotation, opacity: $opacity, skew: $skew, skewAxis: $skewAxis';
}

class TrimShape extends Shape {
  const TrimShape({
    String name,
    String matchName,
    this.start,
    this.end,
    this.offset,
  }) : super(name: name, matchName: matchName);

  static TrimShape fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return TrimShape(
      name: json['nm'],
      matchName: json['mn'],
      start: ValueProperty.fromJson(json['s']),
      end: ValueProperty.fromJson(json['e']),
      offset: ValueProperty.fromJson(json['o']),
    );
  }

  final ValueProperty start;
  final ValueProperty end;
  final ValueProperty offset;

  @override
  void drawShape({
    @required Canvas canvas,
    @required double frameTime,
    @required Size size,
  }) {
    print('TRIM SHAPE DRAW REQUEST');
  }

  @override
  String get _extraProperties => ', start: $start, end: $end, offset: $offset';
}
