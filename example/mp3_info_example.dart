import 'dart:io';

import 'package:mp3_info/mp3_info.dart';

void main() {
  final mp3 = MP3Processor.fromFile(
      File('test_files/test_128kpbs_441khz_stereo_10s.mp3'));

  print('MP3: test_128kpbs_441khz_stereo_10s.mp3');

  switch (mp3.sampleRate) {
    case SampleRate.rate_32000:
      print('Sample rate: 32KHz');
      break;
    case SampleRate.rate_44100:
      print('Sample rate: 44.1KHz');
      break;
    case SampleRate.rate_48000:
      print('Sample rate: 48KHz');
      break;
  }

  print('Bit rate: ${mp3.bitrate}bps');
  print('Duration: ${mp3.duration}');
}
