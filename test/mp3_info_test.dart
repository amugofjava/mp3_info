// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:mp3_info/mp3_info.dart';
import 'package:mp3_info/src/exceptions/invalid_file_exception.dart';
import 'package:test/test.dart';

void main() {
  final tenSeconds = 10;
  final input_128kbps_441_stereo =
      File('test_files/test_128kpbs_441khz_stereo_10s.mp3');
  final input_256kbps_441_mono_copyright_emphasis_none =
      File('test_files/test_256kbps_441khz_mono_emphasis_none_10s.mp3');
  final input_256kbps_441_mono_copyright_emphasis_ccit =
      File('test_files/test_256kbps_441khz_mono_emphasis_ccit_10s.mp3');
  final input_256kbps_48_stereo =
      File('test_files/test_256kpbs_48khz_stereo_10s.mp3');
  final input_256kbps_48_mono =
      File('test_files/test_256kpbs_48khz_mono_10s.mp3');
  final input_sine_wav = File('test_files/test_sine_48khz_10s.wav');

  group('128Kbps 44.1KHz Dual channel', () {
    final mp3 = MP3Processor.fromFile(input_128kbps_441_stereo);

    setUp(() {});

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
      expect(mp3.duration.inSeconds, tenSeconds);
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

  group('128Kbps 44.1KHz Joint stereo; copyrighted; emphasis none', () {
    final mp3 =
        MP3Processor.fromFile(input_256kbps_441_mono_copyright_emphasis_none);

    setUp(() {});

    test('Duration 10 seconds', () {
      expect(mp3.duration.inSeconds, tenSeconds);
    });

    test('Bitrate 256Kbps', () {
      expect(mp3.bitrate, 256);
    });

    test('Sample rate 44.1KHz', () {
      expect(mp3.sampleRate, SampleRate.rate_44100);
    });

    test('Channel mode joint stereo', () {
      expect(mp3.channelMode, ChannelMode.single_channel);
    });

    test('Is copyrighted', () {
      expect(mp3.copyrighted, true);
    });

    test('Is original', () {
      expect(mp3.original, true);
    });

    test('No emphasis', () {
      expect(mp3.emphasis, Emphasis.none);
    });
  });

  group('128Kbps 44.1KHz Joint stereo; copyrighted; emphasis CCIT', () {
    final mp3 =
        MP3Processor.fromFile(input_256kbps_441_mono_copyright_emphasis_ccit);

    setUp(() {});

    test('Duration 10 seconds', () {
      expect(mp3.duration.inSeconds, tenSeconds);
    });

    test('Bitrate 256Kbps', () {
      expect(mp3.bitrate, 256);
    });

    test('Sample rate 44.1KHz', () {
      expect(mp3.sampleRate, SampleRate.rate_44100);
    });

    test('Channel mode joint stereo', () {
      expect(mp3.channelMode, ChannelMode.single_channel);
    });

    test('Is copyrighted', () {
      expect(mp3.copyrighted, true);
    });

    test('CCIT emphasis', () {
      expect(mp3.emphasis, Emphasis.ccit);
    });
  });

  group('256Kbps 48KHz Dual channel', () {
    final mp3 = MP3Processor.fromFile(input_256kbps_48_stereo);

    setUp(() {});

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
      expect(mp3.duration.inSeconds, tenSeconds);
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
    test('Is not copyrighted', () {
      expect(mp3.copyrighted, false);
    });

    test('Is a copy', () {
      expect(mp3.original, false);
    });

    test('No emphasis', () {
      expect(mp3.emphasis, Emphasis.none);
    });
  });

  group('256Kbps 48KHz Single channel', () {
    final mp3 = MP3Processor.fromFile(input_256kbps_48_mono);

    setUp(() {});

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
      expect(mp3.duration.inSeconds, tenSeconds);
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
    setUp(() {});

    // When testing an exception the function to be tested cannot have any
    // parameters. Therefore we wrap in a closure to get around this.
    test('Process WAV file', () {
      expect(() => MP3Processor.fromFile(input_sine_wav),
          throwsA(TypeMatcher<InvalidMP3FileException>()));
    });
  });
}
