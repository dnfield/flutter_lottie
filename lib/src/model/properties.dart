import 'dart:collection';
import 'dart:ui';

import 'package:meta/meta.dart';

import '../parsers.dart';
import 'keyframes.dart';

final Expando<Keyframe> _frameCache = Expando<Keyframe>();

S _frameForTime<S extends Keyframe>(
  UnmodifiableListView<S> keyframes,
  double frameTime,
) {
  if (keyframes == null || keyframes.isEmpty) {
    return null;
  }
  assert(frameTime != null);
  if (keyframes.last.endTime <= frameTime) {
    return keyframes.last;
  } else if (frameTime <= keyframes.first.startTime) {
    return keyframes.first;
  } else {
    return keyframes.lastWhere((S keyframe) => keyframe.containsFrame(frameTime));
  }
}

@immutable
class LottieTangent {
  const LottieTangent(this.x, this.y, this.z);

  static LottieTangent fromJson(List<dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.isEmpty) {
      return const LottieTangent(0.0, 0.0, 0.0);
    }

    assert(json.length == 2 || json.length == 3);
    double x = parseDouble(json[0]);
    double y = parseDouble(json[1]);
    double z = json.length == 3 ? parseDouble(json[2]) : 0.0;

    return LottieTangent(x, y, z);
  }

  final double x;
  final double y;
  final double z;

  @override
  bool operator ==(Object other) {
    return other is LottieTangent && other.x == x && other.y == y && other.z == z;
  }

  @override
  int get hashCode => hashValues(x, y, z);
}

@immutable
abstract class PropertyBase<T> {
  const PropertyBase({
    this.expression,
    this.propertyIndex,
  });

  final String expression;
  final int propertyIndex;

  T valueAt(double frameTime);
}

@immutable
abstract class MultiDimensionalProperty extends PropertyBase<Offset> {
  const MultiDimensionalProperty({String expression, int propertyIndex})
      : super(expression: expression, propertyIndex: propertyIndex);

  static MultiDimensionalProperty fromJson<T>(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json['a'] == 0 || json['k'] is List<num>) {
      return MultiDimensionalPropertyConstant.fromJson(json);
    }
    return MultiDimensionalPropertyKeyframed.fromJson(json);
  }
}

@immutable
class MultiDimensionalPropertyConstant extends MultiDimensionalProperty {
  const MultiDimensionalPropertyConstant({
    this.value,
    String expression,
    int propertyIndex,
  }) : super(expression: expression, propertyIndex: propertyIndex);

  static MultiDimensionalPropertyConstant fromJson<T>(Map<String, dynamic> json) {
    assert(json != null);
    return MultiDimensionalPropertyConstant(
      value: parseOffsetFromList(json['k']),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final Offset value;

  @override
  Offset valueAt(double frameTime) => value;

  @override
  String toString() => '$runtimeType{$value}';
}

@immutable
class MultiDimensionalPropertyKeyframed extends MultiDimensionalProperty {
  const MultiDimensionalPropertyKeyframed({
    int propertyIndex,
    String expression,
    this.keyframes,
    this.inTangent,
    this.outTangent,
  });

  static MultiDimensionalPropertyKeyframed fromJson<T>(Map<String, dynamic> json) {
    assert(json != null);
    return MultiDimensionalPropertyKeyframed(
      keyframes: parseKeyframeList(json['k'], OffsetKeyframe.fromJson),
      inTangent: LottieTangent.fromJson(json['ti']),
      outTangent: LottieTangent.fromJson(json['to']),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final UnmodifiableListView<OffsetKeyframe> keyframes;
  final LottieTangent inTangent;
  final LottieTangent outTangent;

  @override
  Offset valueAt(double frameTime) {
    Keyframe keyframe = _frameCache[this];
    if (keyframe == null || !keyframe.containsFrame(frameTime)) {
      keyframe = _frameForTime<OffsetKeyframe>(keyframes, frameTime);
      _frameCache[this] = keyframe;
    }
    if (keyframe == null) {
      return null;
    }
    final Offset lerpedOffset = keyframe.lerp(frameTime);
    final double start = keyframe.start.toDouble();
    final double end = keyframe.end.toDouble();
    return Offset.lerp(Offset(start, start), Offset(end, end), lerpedOffset.dx);
  }

  @override
  String toString() => '$runtimeType{'
      'keyframes: $keyframes,'
      'inTangent: $inTangent,'
      'outTangent: $outTangent'
      '}';
}

@immutable
abstract class ValueProperty extends PropertyBase<double> {
  const ValueProperty({String expression, int propertyIndex})
      : super(expression: expression, propertyIndex: propertyIndex);

  static ValueProperty fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json['a'] == 0 || json['k'] is num) {
      return ValuePropertyConstant.fromJson(json);
    }
    return ValuePropertyKeyframed.fromJson(json);
  }
}

@immutable
class ValuePropertyConstant extends ValueProperty {
  const ValuePropertyConstant({
    this.value,
    String expression,
    int propertyIndex,
  }) : super(expression: expression, propertyIndex: propertyIndex);

  static ValuePropertyConstant fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return ValuePropertyConstant(
      value: parseDouble(json['k']),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final double value;

  @override
  double valueAt(double frameTime) => value;

  @override
  String toString() => '$runtimeType{$value}';
}

@immutable
class ValuePropertyKeyframed extends ValueProperty {
  const ValuePropertyKeyframed({
    this.keyframes,
    String expression,
    int propertyIndex,
  }) : super(expression: expression, propertyIndex: propertyIndex);

  static ValuePropertyKeyframed fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return ValuePropertyKeyframed(
      keyframes: parseKeyframeList(json['k'], ValueKeyframe.fromJson),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final UnmodifiableListView<ValueKeyframe> keyframes;

  @override
  double valueAt(double frameTime) {
    throw UnimplementedError();
  }

  @override
  String toString() => '$runtimeType{$keyframes}';
}

@immutable
abstract class ShapeProperty extends PropertyBase<ShapePropertyData> {
  const ShapeProperty({String expression, int propertyIndex})
      : super(expression: expression, propertyIndex: propertyIndex);

  static ShapeProperty fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json['a'] == 0 || json['k'] is num) {
      return ShapePropertyConstant.fromJson(json);
    }
    return ShapePropertyKeyframed.fromJson(json);
  }
}

@immutable
class ShapePropertyConstant extends ShapeProperty {
  const ShapePropertyConstant({
    this.shape,
    String expression,
    int propertyIndex,
  }) : super(expression: expression, propertyIndex: propertyIndex);

  static ShapePropertyConstant fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return ShapePropertyConstant(
      shape: ShapePropertyData.fromJson(
        json['k'].cast<Map<String, dynamic>>(),
      ),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final ShapePropertyData shape;

  ShapePropertyData valueAt(double progres) => shape;

  @override
  String toString() => '$runtimeType{$shape}';
}

@immutable
class ShapePropertyKeyframed extends ShapeProperty {
  const ShapePropertyKeyframed({
    this.keyframes,
    this.inTangent,
    this.outTangent,
    String expression,
    int propertyIndex,
  }) : super(expression: expression, propertyIndex: propertyIndex);

  static ShapePropertyKeyframed fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return ShapePropertyKeyframed(
      keyframes: parseKeyframeList(json['k'], ShapeKeyframe.fromJson),
      inTangent: LottieTangent.fromJson(json['ti']),
      outTangent: LottieTangent.fromJson(json['to']),
      expression: json['x'],
      propertyIndex: parseInt(json['ix']),
    );
  }

  final UnmodifiableListView<ShapeKeyframe> keyframes;
  final LottieTangent inTangent;
  final LottieTangent outTangent;

  @override
  ShapePropertyData valueAt(double frameTime) {
    throw UnimplementedError();
  }

  String toString() =>
      '$runtimeType{keyframes: $keyframes, inTangent: $inTangent, outTangent: $outTangent}';
}
