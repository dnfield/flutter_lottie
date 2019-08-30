import 'dart:collection';
import 'dart:ui';

import 'package:meta/meta.dart';

import '../parsers.dart';

@immutable
class ShapePropertyData {
  const ShapePropertyData({
    this.closed,
    this.inPoints,
    this.outPoints,
    this.vertices,
  });

  static ShapePropertyData fromJson(Map<String, dynamic> json) {
    return ShapePropertyData(
      closed: json['c'],
      inPoints: parseOffsetList(json['i']),
      outPoints: parseOffsetList(json['o']),
      vertices: parseOffsetList(json['v']),
    );
  }

  final bool closed;
  final UnmodifiableListView<Offset> inPoints;
  final UnmodifiableListView<Offset> outPoints;
  final UnmodifiableListView<Offset> vertices;

  @override
  String toString() => '$runtimeType{closed: $closed, inPoints: $inPoints outPoints: $outPoints, '
      'vertices: $vertices}';
}

@immutable
abstract class Keyframe {
  const Keyframe({
    this.startTime,
    this.endTime,
    this.start,
    this.end,
    this.inValue,
    this.outValue,
  })  : assert(startTime != null),
        assert(endTime != null),
        assert(startTime < endTime),
        assert(start != null),
        assert(end != null),
        assert(inValue != null),
        assert(outValue != null),
        length = endTime - startTime;

  final double startTime;
  final double endTime;
  final double length;
  final int start;
  final int end;
  final Offset inValue;
  final Offset outValue;

  bool containsFrame(double frameTime) {
    return startTime <= frameTime && frameTime <= endTime;
  }

  Offset lerp(double frameTime) {
    final double progress = (frameTime - startTime) / length;
    return Offset.lerp(inValue, outValue, progress);
  }

  @override
  String toString() => '$runtimeType{start: $start, time $startTime, endTime: $endTime, '
      'inValue: $inValue, outValue: $outValue}';
}

@immutable
class ValueKeyframe extends Keyframe {
  const ValueKeyframe({
    int start,
    int end,
    double time,
    double endTime,
    Offset inValue,
    Offset outValue,
  }) : super(
          start: start,
          end: end,
          startTime: time,
          endTime: endTime,
          inValue: inValue,
          outValue: outValue,
        );

  static ValueKeyframe fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> nextJson,
  ) {
    assert(json != null);
    assert(nextJson != null);
    return ValueKeyframe(
        start: parseInt(json['s']),
        end: parseInt(json['e'] ?? nextJson['s']),
        time: parseDouble(json['t']) ?? 0.0,
        endTime: parseDouble(nextJson['t']) ?? 0.0,
        inValue: parseOffset(json['i']),
        outValue: parseOffset(json['o']));
  }
}

@immutable
class ShapeKeyframe extends Keyframe {
  const ShapeKeyframe({
    double time,
    double endTime,
    int start,
    int end,
    Offset inValue,
    Offset outValue,
    this.shape,
  }) : super(
          startTime: time,
          endTime: endTime,
          start: start,
          end: end,
          inValue: inValue,
          outValue: outValue,
        );

  static ShapeKeyframe fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> nextJson,
  ) {
    assert(json != null);
    assert(nextJson != null);
    return ShapeKeyframe(
      shape: parseList(
        json['s']?.cast<Map<String, dynamic>>(),
        ShapePropertyData.fromJson,
      ),
      time: parseDouble(json['t']),
      start: parseInt(json['s']),
      end: parseInt(json['e'] ?? nextJson['s']),
      endTime: parseDouble(nextJson['s']),
      inValue: parseOffset(json['i']),
      outValue: parseOffset(json['o']),
    );
  }

  final UnmodifiableListView<ShapePropertyData> shape;

  @override
  String toString() => '$runtimeType{time: $startTime, inValue: $inValue, outValue: '
      '$outValue, shape: $shape';
}

@immutable
class OffsetKeyframe extends Keyframe {
  const OffsetKeyframe({
    int start,
    int end,
    double time,
    double endTime,
    Offset inValue,
    Offset outValue,
  }) : super(
          start: start,
          end: end,
          startTime: time,
          endTime: endTime,
          inValue: inValue,
          outValue: outValue,
        );

  static OffsetKeyframe fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> nextJson,
  ) {
    assert(json != null);
    assert(nextJson != null);
    return OffsetKeyframe(
      start: parseInt(json['s']),
      end: parseInt(json['e'] ?? nextJson['s']),
      time: parseDouble(json['t']),
      endTime: parseDouble(nextJson['t']),
      inValue: parseOffset(json['i']),
      outValue: parseOffset(json['o']),
    );
  }
}
