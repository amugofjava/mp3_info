// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:mp3_info/mp3_info.dart';
import 'package:mp3_info/src/exceptions/invalid_file_exception.dart';
import 'package:test/test.dart';

void main() {
  Duration tenSeconds = Duration(seconds: 10);
  File input_128kbps_441_stereo = File("test_files/test_128kpbs_441khz_stereo_10s.mp3");
  File input_256kbps_48_stereo = File("test_files/test_256kpbs_48khz_stereo_10s.mp3");
  File input_256kbps_48_mono = File("test_files/test_256kpbs_48khz_mono_10s.mp3");
  File input_sine_wav = File("test_files/test_sine_48khz_10s.wav");

  group('128Kbps 44.1KHz Dual channel', () {
    MP3Info mp3 = MP3Processor.fromFile(input_128kbps_441_stereo);

    setUp(() {
    });

    test('MPEG Version 1', () {
      expect(mp3.version, Version.MPEG_1);
    });

    test('MPEG Layer III', () {
      expect(mp3.layer, Layer.MPEG_III);
    });

    test('CRC set', () {
      expect(mp3.crc, true);
    });

    test('Duration 10 seconds', () {
      expect(mp3.duration, tenSeconds);
    });

    test('Bitrate 128Kbps', () {
      expect(mp3.bitrate, 128);
    });

    test('Sample rate 44.1KHz', () {
      expect(mp3.sampleRate, SampleRate.rate_44100);
    });

    test('Channel mode stereo', () {
      expect(mp3.channelMode, ChannelMode.stereo);
    });
  });

  group('256Kbps 48KHz Dual channel', () {
    MP3Info mp3 = MP3Processor.fromFile(input_256kbps_48_stereo);

    setUp(() {
    });

    test('MPEG Version 1', () {
      expect(mp3.version, Version.MPEG_1);
    });

    test('MPEG Layer III', () {
      expect(mp3.layer, Layer.MPEG_III);
    });

    test('CRC set', () {
      expect(mp3.crc, true);
    });

    test('Duration 10 seconds', () {
      expect(mp3.duration, tenSeconds);
    });

    test('Bitrate 128Kbps', () {
      expect(mp3.bitrate, 256);
    });

    test('Sample rate 44.1KHz', () {
      expect(mp3.sampleRate, SampleRate.rate_48000);
    });

    test('Channel mode stereo', () {
      expect(mp3.channelMode, ChannelMode.stereo);
    });
  });

  group('256Kbps 48KHz Single channel', () {
    MP3Info mp3 = MP3Processor.fromFile(input_256kbps_48_mono);

    setUp(() {
    });

    test('MPEG Version 1', () {
      expect(mp3.version, Version.MPEG_1);
    });

    test('MPEG Layer III', () {
      expect(mp3.layer, Layer.MPEG_III);
    });

    test('CRC set', () {
      expect(mp3.crc, true);
    });

    test('Duration 10 seconds', () {
      expect(mp3.duration, tenSeconds);
    });

    test('Bitrate 128Kbps', () {
      expect(mp3.bitrate, 256);
    });

    test('Sample rate 44.1KHz', () {
      expect(mp3.sampleRate, SampleRate.rate_48000);
    });

    test('Channel mode stereo', () {
      expect(mp3.channelMode, ChannelMode.single_channel);
    });
  });

  group('Non-MP3 file', () {
    setUp(() {
    });

    // When testing an exception the function to be tested cannot have any
    // parameters. Therefore we wrap in a closure to get around this.
    test('Process WAV file', () {
      expect(() => MP3Processor.fromFile(input_sine_wav), throwsA(TypeMatcher<InvalidMP3FileException>()));
    });
  });
}
