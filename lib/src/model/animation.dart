import 'dart:collection';

import '../parsers.dart';
import 'layers.dart';

class LottieAnimation {
  LottieAnimation({
    this.inPoint,
    this.outPoint,
    this.frameRate,
    this.width,
    this.height,
    this.is3D,
    this.version,
    this.name,
    this.layers,
    this.referenceLayers,
    this.assets,
    this.chars,
  })  : assert(inPoint != null),
        assert(outPoint != null),
        assert(frameRate != null),
        assert(width != null),
        assert(height != null),
        assert(is3D != null),
        assert(version != null),
        durationInSeconds = (outPoint - inPoint) / frameRate;

  static LottieAnimation fromJson(Map<String, dynamic> json) {
    assert(json != null);
    List<Layer> layers = parseList(json['layers'], Layer.fromJson);
    final double inPoint = parseDouble(json['ip']);
    final double outPoint = parseDouble(json['op']);
    return LottieAnimation(
      inPoint: inPoint,
      outPoint: outPoint,
      frameRate: parseDouble(json['fr']),
      width: parseDouble(json['w']),
      is3D: json['ddd'] == 1,
      height: parseDouble(json['h']),
      version: json['v'],
      name: json['nm'],
      layers: UnmodifiableListView<Layer>(layers.where((Layer layer) {
        return layer.outPoint >= inPoint && layer.inPoint <= outPoint;
      }).toList()),
      referenceLayers: UnmodifiableListView<Layer>(layers.where((Layer layer) {
        return layer.outPoint < inPoint || layer.index > outPoint;
      }).toList()),
      assets: Assets.fromJson(json['assets']),
      chars: parseList(json['chars'], Chars.fromJson),
    );
  }

  static const double _kEpsillon = 1e-10;

  final double inPoint;
  final double outPoint;
  final double frameRate;
  final double durationInSeconds;
  final double width;
  final double height;
  final bool is3D;
  final String version;
  final String name;
  final UnmodifiableListView<Layer> layers;
  final UnmodifiableListView<Layer> referenceLayers;
  final Assets assets;
  final UnmodifiableListView<Chars> chars;

  double frameTimeForProgress(double progress) {
    return (inPoint + progress * (outPoint - inPoint)).clamp(inPoint, outPoint + _kEpsillon);
  }

  @override
  String toString() => '$runtimeType{'
      'inPoint: $inPoint, '
      'outPoint: $outPoint, '
      'frameRate: $frameRate, '
      'durationInSeconds: $durationInSeconds, '
      'width: $width, '
      'height: $height, '
      'is3D: $is3D, '
      'version: $version, '
      'name: $name, '
      'layers: $layers, '
      'assets: $assets, '
      'fchars: $chars'
      '}';
}

class Assets {
  const Assets({this.images, this.precomps});

  static const Assets empty = Assets(
    images: <String, Image>{},
    precomps: <String, UnmodifiableListView<Layer>>{},
  );

  static Assets fromJson(List<dynamic> json) {
    if (json == null) {
      return null;
    }
    if (json.isEmpty) {
      return Assets.empty;
    }
    Map<String, UnmodifiableListView<Layer>> precomps = <String, UnmodifiableListView<Layer>>{};
    Map<String, Image> images = <String, Image>{};
    for (Map<String, dynamic> assetJson in json.cast<Map<String, dynamic>>()) {
      assert(assetJson['id'] != null);
      final List<dynamic> layers = assetJson['layers'];
      if (layers != null) {
        precomps[assetJson['id']] = parseList(layers, Layer.fromJson);
        continue;
      }
      final String imageLocation = assetJson['p'];
      if (imageLocation != null) {
        images[assetJson['id']] = Image.fromJson(assetJson);
      }
    }
    return Assets(images: images, precomps: precomps);
  }

  final Map<String, Image> images;
  final Map<String, UnmodifiableListView<Layer>> precomps;
}

class Image {
  const Image({
    this.height,
    this.width,
    this.id,
    this.name,
    this.path,
  });

  static Image fromJson(Map<String, dynamic> json) {
    assert(json != null);
    return Image(
      height: parseInt(json['h']),
      width: parseInt(json['w']),
      id: json['id'],
      name: json['p'],
      path: json['u'],
    );
  }

  final int height;
  final int width;
  final String id;
  final String name;
  final String path;
}

class Chars {
  static Chars fromJson(Map<String, dynamic> json) {
    return null;
  }
}
