import 'dart:async';
import 'dart:typed_data';

import 'package:pcmtowave/pcmtowave.dart';
import 'package:rxdart/rxdart.dart';

class ConvertToWav {
  int sampleRate;

  int numChannels;

  int converMiliSeconds;

  List<int>? bytesSink = [];

  Timer? timer;

  StreamController<Uint8List> streamController = BehaviorSubject();

  ConvertToWav({
    this.sampleRate = 44100,
    this.numChannels = 2,
    this.converMiliSeconds = 1000,
  });

  void Function(Timer timer) get callBack => (timer) {
        final res = PcmToWave.pcmToWav(
          Uint8List.fromList(bytesSink!),
          sampleRate,
          numChannels,
        );

        streamController.add(res);

        bytesSink = [];
      };

  void run(Uint8List? pcmData) {
    bytesSink!.addAll(pcmData!.toList());

    timer ??= Timer.periodic(
      Duration(milliseconds: converMiliSeconds),
      callBack,
    );
  }

  Stream<Uint8List> get convert => streamController.stream;

  void dispose() {
    streamController.close();
    timer!.cancel();
  }
}
