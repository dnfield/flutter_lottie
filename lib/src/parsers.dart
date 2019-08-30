import 'dart:collection';
import 'dart:ui';

typedef ValueParser<T> = T Function(List<dynamic> json);

int parseInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is List<dynamic>) {
    return parseInt(value[0]);
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return null;
}

double parseDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is List<dynamic>) {
    return parseDouble(value[0]);
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return null;
}

UnmodifiableListView<double> parseDoubleList(List<dynamic> list) {
  if (list == null) {
    return null;
  }
  if (list.isEmpty) {
    return UnmodifiableListView<double>(const <double>[]);
  }
  if (list is List<double>) {
    return list;
  }
  List<double> result = <double>[];
  for (dynamic value in list) {
    if (value is double) {
      result.add(value);
    } else if (value is num) {
      result.add(value.toDouble());
    }
  }
  assert(result.length == list.length);
  return UnmodifiableListView<double>(result);
}

UnmodifiableListView<Offset> parseOffsetList(List<dynamic> list) {
  if (list == null) {
    return null;
  }
  final List<Offset> values = <Offset>[];
  if (list.isEmpty) {
    return UnmodifiableListView<Offset>(values);
  }
  if (list[0] is List<dynamic>) {
    for (List<dynamic> sublist in list.cast<List<dynamic>>()) {
      assert(sublist.length >= 2);
      assert(sublist[0] is num);
      values.add(Offset(sublist[0].toDouble(), sublist[1].toDouble()));
    }
  }
  return UnmodifiableListView<Offset>(values);
}

typedef TypedListParser<T> = T Function(Map<String, dynamic>);
typedef PeekingTypedListParser<T> = T Function(Map<String, dynamic>, Map<String, dynamic>);

UnmodifiableListView<T> parseList<T>(
  List<dynamic> list,
  TypedListParser<T> func, {
  bool test(T element),
}) {
  if (list == null) {
    return null;
  }
  assert(func != null);
  List<T> value = <T>[];
  if (list.isEmpty) {
    return UnmodifiableListView<T>(value);
  }
  for (Map<String, dynamic> json in list.cast<Map<String, dynamic>>()) {
    T element = func(json);
    if (test == null || test(element) != false) {
      value.add(element);
    }
  }
  return UnmodifiableListView<T>(value);
}

UnmodifiableListView<T> parseKeyframeList<T>(
  List<dynamic> list,
  PeekingTypedListParser<T> func, {
  bool test(T element),
}) {
  if (list == null) {
    return null;
  }
  assert(func != null);
  List<T> value = <T>[];
  if (list.isEmpty) {
    return UnmodifiableListView<T>(value);
  }
  for (int i = 0; i < list.length - 1; i++) {
    Map<String, dynamic> json = list[i] as Map<String, dynamic>;
    Map<String, dynamic> nextJson = list[i + 1] as Map<String, dynamic>;

    T element = func(json, nextJson);
    if (test == null || test(element) != false) {
      value.add(element);
    }
  }
  return UnmodifiableListView<T>(value);
}

Offset parseOffset(Map<String, dynamic> json) {
  if (json == null) {
    return null;
  }
  return Offset(parseDouble(json['x']), parseDouble(json['y']));
}

Offset parseOffsetFromList(List<dynamic> json) {
  if (json == null) {
    return null;
  }
  if (json.isEmpty) {
    return Offset.zero;
  }
  assert(json.length >= 2);
  return Offset(parseDouble(json[0]), parseDouble(json[1]));
}

Size parseSizeFromList(List<dynamic> json) {
  if (json == null) {
    return null;
  }
  if (json.isEmpty) {
    return Size.zero;
  }
  assert(json.length >= 2);
  return Size(parseDouble(json[0]), parseDouble(json[1]));
}

BlendMode parseBlendMode(int mode) {
  assert(mode != null);
  // https://github.com/airbnb/lottie-web/blob/master/docs/json/helpers/blendMode.json
  const List<BlendMode> kBlendModes = <BlendMode>[
    BlendMode.srcOver, // 0:'normal'
    BlendMode.multiply, // 1:'multiply'
    BlendMode.screen, // 2:'screen'
    BlendMode.overlay, // 3:'overlay
    BlendMode.darken, // 4:'darken'
    BlendMode.lighten, // 5:'lighten'
    BlendMode.colorDodge, // 6:'color-dodge'
    BlendMode.colorBurn, // 7:'color-burn'
    BlendMode.hardLight, // 8:'hard-light'
    BlendMode.softLight, // 9:'soft-light'
    BlendMode.difference, // 10:'difference'
    BlendMode.exclusion, // 11:'exclusion'
    BlendMode.hue, // 12:'hue'
    BlendMode.saturation, // 13:'saturation'
    BlendMode.color, // 14:'color'
    BlendMode.luminosity, // 15:'luminosity'
  ];
  if (mode >= kBlendModes.length) {
    print('Unsupported blend mode $mode, defaulting to BlendMode.srcOver');
    return BlendMode.srcOver;
  }

  return kBlendModes[mode];
}

StrokeCap parseStrokeCap(int cap) {
  assert(cap != null);
  assert(cap >= 1 && cap <= 3);
  // https://github.com/airbnb/lottie-web/blob/master/docs/json/helpers/lineCap.json
  const List<StrokeCap> kStrokeCaps = <StrokeCap>[
    StrokeCap.butt, // 1: butt
    StrokeCap.round, // 2: round
    StrokeCap.square, // 3: square
  ];
  return kStrokeCaps[cap - 1];
}

StrokeJoin parseStrokeJoin(int join) {
  assert(join != null);
  assert(join >= 1 && join <= 3);
  // https://github.com/airbnb/lottie-web/blob/master/docs/json/helpers/lineJoin.json
  const List<StrokeJoin> kStrokeJoins = <StrokeJoin>[
    StrokeJoin.miter, // 1: miter
    StrokeJoin.round, // 2: round
    StrokeJoin.bevel, // 3: bevel
  ];
  return kStrokeJoins[join - 1];
}

PathOperation parsePathOperation(int mode) {
  assert(mode != null);
  assert(mode >= 1 && mode <= 5);

  const List<PathOperation> kPathOperations = <PathOperation>[
    null, // "mm": 1; we'll just add the path in this case.
    PathOperation.union, // "mm": 2
    PathOperation.difference, // "mm": 3
    PathOperation.intersect, // "mm": 4
    PathOperation.xor, // "mm": 5
  ];
  return kPathOperations[mode - 1];
}
