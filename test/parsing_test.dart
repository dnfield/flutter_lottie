import 'dart:convert';
import 'dart:ui';

import 'package:flutter_lottie/src/model/animation.dart';
import 'package:flutter_lottie/src/player.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('Dot', () {
    final Map<String, dynamic> hamburger = json.decode(dot);
    final LottieAnimation animation = LottieAnimation.fromJson(hamburger);
    FakeCanvas canvas = FakeCanvas();
    final player = LottiePlayer(animation);
    for (double i = 0; i < 1; i += .1) {
      player.drawFrame(
        canvas: canvas,
        progress: i,
        size: Size(10, 10),
      );
    }
  });
}

class FakeCanvas implements Canvas {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    print(invocation.memberName);
    print(invocation.positionalArguments);
  }
}

const String dot = '''{
  "v": "5.1.9",
  "fr": 60,
  "ip": 0,
  "op": 241,
  "w": 1280,
  "h": 800,
  "nm": "tap-01",
  "ddd": 0,
  "assets": [],
  "layers": [
    {
      "ddd": 0,
      "ind": 1,
      "ty": 4,
      "nm": "DRAG",
      "sr": 1,
      "ks": {
        "o": {
          "a": 1,
          "k": [
            {
              "i": {
                "x": [
                  0.833
                ],
                "y": [
                  0.833
                ]
              },
              "o": {
                "x": [
                  0.167
                ],
                "y": [
                  0.167
                ]
              },
              "n": [
                "0p833_0p833_0p167_0p167"
              ],
              "t": 55,
              "s": [
                0
              ],
              "e": [
                100
              ]
            },
            {
              "i": {
                "x": [
                  0.833
                ],
                "y": [
                  0.833
                ]
              },
              "o": {
                "x": [
                  0.167
                ],
                "y": [
                  0.167
                ]
              },
              "n": [
                "0p833_0p833_0p167_0p167"
              ],
              "t": 70,
              "s": [
                100
              ],
              "e": [
                80
              ]
            },
            {
              "i": {
                "x": [
                  0.833
                ],
                "y": [
                  0.833
                ]
              },
              "o": {
                "x": [
                  0.167
                ],
                "y": [
                  0.167
                ]
              },
              "n": [
                "0p833_0p833_0p167_0p167"
              ],
              "t": 187,
              "s": [
                80
              ],
              "e": [
                0
              ]
            },
            {
              "t": 208
            }
          ],
          "ix": 11
        },
        "r": {
          "a": 0,
          "k": 0,
          "ix": 10
        },
        "p": {
          "a": 1,
          "k": [
            {
              "i": {
                "x": 0.45,
                "y": 1
              },
              "o": {
                "x": 0,
                "y": 0
              },
              "n": "0p45_1_0_0",
              "t": 55,
              "s": [
                640,
                592,
                0
              ],
              "e": [
                640,
                400,
                0
              ],
              "to": [
                0,
                0,
                0
              ],
              "ti": [
                0,
                0,
                0
              ]
            },
            {
              "t": 91
            }
          ],
          "ix": 2
        },
        "a": {
          "a": 0,
          "k": [
            20.047,
            44.047,
            0
          ],
          "ix": 1
        },
        "s": {
          "a": 0,
          "k": [
            100,
            100,
            100
          ],
          "ix": 6
        }
      },
      "ao": 0,
      "shapes": [
        {
          "ty": "gr",
          "it": [
            {
              "d": 1,
              "ty": "el",
              "s": {
                "a": 1,
                "k": [
                  {
                    "i": {
                      "x": [
                        0.9,
                        0.9
                      ],
                      "y": [
                        1,
                        1
                      ]
                    },
                    "o": {
                      "x": [
                        0.65,
                        0.65
                      ],
                      "y": [
                        0,
                        0
                      ]
                    },
                    "n": [
                      "0p9_1_0p65_0",
                      "0p9_1_0p65_0"
                    ],
                    "t": 91,
                    "s": [
                      124,
                      124
                    ],
                    "e": [
                      95,
                      95
                    ]
                  },
                  {
                    "i": {
                      "x": [
                        0.833,
                        0.833
                      ],
                      "y": [
                        0.833,
                        0.833
                      ]
                    },
                    "o": {
                      "x": [
                        0.167,
                        0.167
                      ],
                      "y": [
                        0.167,
                        0.167
                      ]
                    },
                    "n": [
                      "0p833_0p833_0p167_0p167",
                      "0p833_0p833_0p167_0p167"
                    ],
                    "t": 103,
                    "s": [
                      95,
                      95
                    ],
                    "e": [
                      95,
                      95
                    ]
                  },
                  {
                    "i": {
                      "x": [
                        0.2,
                        0.2
                      ],
                      "y": [
                        1,
                        1
                      ]
                    },
                    "o": {
                      "x": [
                        0.4,
                        0.4
                      ],
                      "y": [
                        0,
                        0
                      ]
                    },
                    "n": [
                      "0p2_1_0p4_0",
                      "0p2_1_0p4_0"
                    ],
                    "t": 187,
                    "s": [
                      95,
                      95
                    ],
                    "e": [
                      124,
                      124
                    ]
                  },
                  {
                    "t": 208
                  }
                ],
                "ix": 2
              },
              "p": {
                "a": 0,
                "k": [
                  0,
                  0
                ],
                "ix": 3
              },
              "nm": "Ellipse Path 1",
              "mn": "ADBE Vector Shape - Ellipse",
              "hd": false
            },
            {
              "ty": "fl",
              "c": {
                "a": 0,
                "k": [
                  0.341176470588,
                  0.541176470588,
                  0.882352941176,
                  1
                ],
                "ix": 4
              },
              "o": {
                "a": 0,
                "k": 100,
                "ix": 5
              },
              "r": 1,
              "nm": "Fill 1",
              "mn": "ADBE Vector Graphic - Fill",
              "hd": false
            },
            {
              "ty": "tr",
              "p": {
                "a": 0,
                "k": [
                  20.047,
                  44.047
                ],
                "ix": 2
              },
              "a": {
                "a": 0,
                "k": [
                  0,
                  0
                ],
                "ix": 1
              },
              "s": {
                "a": 0,
                "k": [
                  100,
                  100
                ],
                "ix": 3
              },
              "r": {
                "a": 0,
                "k": 0,
                "ix": 6
              },
              "o": {
                "a": 0,
                "k": 100,
                "ix": 7
              },
              "sk": {
                "a": 0,
                "k": 0,
                "ix": 4
              },
              "sa": {
                "a": 0,
                "k": 0,
                "ix": 5
              },
              "nm": "Transform"
            }
          ],
          "nm": "Ellipse 1",
          "np": 3,
          "cix": 2,
          "ix": 1,
          "mn": "ADBE Vector Group",
          "hd": false
        }
      ],
      "ip": 0,
      "op": 694,
      "st": 12.5,
      "bm": 0
    }
  ],
  "markers": []
}''';
