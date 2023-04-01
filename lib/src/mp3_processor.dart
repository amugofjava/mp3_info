// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mp3_info/src/constants/mp3_constants.dart';
import 'package:mp3_info/src/exceptions/invalid_file_exception.dart';

import 'constants/client_constants.dart';
import 'mp3.dart';

/// Processes an MP3 file extracting key metadata information. The current version
/// does not support extracting metadata from ID3 tags.
class MP3Processor {
  static int FRAME_1 = 0;
  static int FRAME_2 = 1;
  static int FRAME_3 = 2;
  static int FRAME_4 = 3;

  /// Process the MP3 contained within the [File] instance.
  static MP3Info fromFile(File file) {
    final bytes = file.readAsBytesSync();

    final instance = MP3Processor();

    return instance._processBytes(bytes);
  }

  /// Process the MP3 from a list of bytes
  static MP3Info fromBytes(Uint8List bytes) {
    final instance = MP3Processor();

    return instance._processBytes(bytes);
  }

  /// The ID3 header is 10 bytes long with bytes 7-10 containing the length of
  /// the ID3 tag space (excluding the 10 byte header itself. This function
  /// calculates the start of the first MP3 frame.
  int _processID3(Uint8List bytes) {
    var headerSize = (bytes[6] << 21) + (bytes[7] << 14) + (bytes[8] << 7) + (bytes[9]);

    return headerSize + 10;
  }

  Version _processMpegVersion(Uint8List frameHeader) {
    var version = frameHeader[FRAME_2] & mpegVersionMask;

    switch (version) {
      case mpegVersion1:
        return Version.MPEG_1;
      case mpegVersion2:
        return Version.MPEG_2;
      case mpegVersion2_5:
        return Version.MPEG_2_5;
    }

    return Version.unknown;
  }

  Layer _processMpegLayer(Uint8List frameHeader) {
    final mpegLayer = frameHeader[FRAME_2] & mpegLayerMask;

    switch (mpegLayer) {
      case layer1:
        return Layer.MPEG_I;
      case layer2:
        return Layer.MPEG_II;
      case layer3:
        return Layer.MPEG_III;
    }

    return Layer.unknown;
  }

  bool _processCrcCheck(Uint8List frameHeader) {
    final mpegProtection = frameHeader[FRAME_2] & mpegProtectionMask;

    return mpegProtection > 0;
  }

  int? _processBitRate(Uint8List frameHeader, Version version, Layer layer) {
    final sampleInfo = frameHeader[FRAME_3];
    final bitRate =
        (sampleInfo & mpegBitRateMask) >> 4; // Easier to compare if we shift the bits down.
    Map<int, int> bitRateMap;

    if (version == Version.MPEG_1) {
      if (layer == Layer.MPEG_I) {
        bitRateMap = bitrate_v1_l1;
      } else if (layer == Layer.MPEG_II) {
        bitRateMap = bitrate_v1_l2;
      } else {
        bitRateMap = bitrate_v1_l3;
      }
    } else {
      if (layer == Layer.MPEG_I) {
        bitRateMap = bitrate_v2_l1;
      } else if (layer == Layer.MPEG_II) {
        bitRateMap = bitrate_v2_l2;
      } else {
        bitRateMap = bitrate_v2_l3;
      }
    }

    return bitRateMap[bitRate];
  }

  SampleRate? _processSampleRate(Uint8List frameHeader) {
    final sampleRate = (frameHeader[FRAME_3] & mpegSampleRateMask);
    SampleRate? rate;

    switch (sampleRate) {
      case sample32:
        rate = SampleRate.rate_32000;
        break;
      case sample44:
        rate = SampleRate.rate_44100;
        break;
      case sample48:
        rate = SampleRate.rate_48000;
        break;
    }

    return rate;
  }

  Duration _processDuration(int fileSizeBytes, int bitRate) {
    final fileSizeBits = fileSizeBytes * 8;
    final bitRateBits = bitRate * 1000;

    final seconds = fileSizeBits / bitRateBits;
    final milliseconds = (seconds * 1000).floor();

    return Duration(milliseconds: milliseconds);
  }

  ChannelMode _processChannelMode(Uint8List frameHeader) {
    final channelMode = (frameHeader[FRAME_4] & mpegChannelModeMask);
    ChannelMode mode;

    switch (channelMode) {
      case channelStereo:
        mode = ChannelMode.stereo;
        break;
      case channelJointStereo:
        mode = ChannelMode.joint_stereo;
        break;
      case channelDualChannel:
        mode = ChannelMode.dual_channel;
        break;
      default:
        mode = ChannelMode.single_channel;
        break;
    }

    return mode;
  }

  bool _processCopyright(Uint8List frameHeader) {
    final copyright = (frameHeader[FRAME_4] & mpegCopyrightMask);

    return copyright > 0;
  }

  bool _processOriginal(Uint8List frameHeader) {
    final original = (frameHeader[FRAME_4] & mpegOriginalMask);

    return original > 0;
  }

  Emphasis? _processEmphasis(Uint8List frameHeader) {
    final emphasis = (frameHeader[FRAME_4] & mpegEmphasisMask);
    Emphasis? e;

    switch (emphasis) {
      case emphasisNone:
        e = Emphasis.none;
        break;
      case emphasis5015:
        e = Emphasis.ms5015;
        break;
      case emphasisReserved:
        e = Emphasis.reserved;
        break;
      case emphasisCCIT:
        e = Emphasis.ccit;
        break;
    }

    return e;
  }

  MP3Info _processBytes(Uint8List bytes) {
    var header = bytes.sublist(0, 10);
    var tag = header.sublist(0, 3);
    var firstFrameOffset = 0;

    // Does the MP3 start with an ID3 tag?
    firstFrameOffset = latin1.decode(tag) == 'ID3' ? _processID3(header) : 0;

    final frameHeaderBytes = bytes.sublist(firstFrameOffset, firstFrameOffset + 10);

    // Ensure we have a valid MP3 frame
    final frameSync1 = frameHeaderBytes[0] & frameSyncA;
    final frameSync2 = frameHeaderBytes[1] & frameSyncB;

    if (frameSync1 == 0xFF && frameSync2 == 0xE0) {
      final fileSize = bytes.length - firstFrameOffset;

      final version = _processMpegVersion(frameHeaderBytes);
      final layer = _processMpegLayer(frameHeaderBytes);
      final crcCheck = _processCrcCheck(frameHeaderBytes);
      final bitRate = _processBitRate(frameHeaderBytes, version, layer)!;
      final sampleRate = _processSampleRate(frameHeaderBytes);
      final duration = _processDuration(fileSize, bitRate);
      final mode = _processChannelMode(frameHeaderBytes);
      final copyrighted = _processCopyright(frameHeaderBytes);
      final original = _processOriginal(frameHeaderBytes);
      final emphasis = _processEmphasis(frameHeaderBytes);

      return MP3Info(
        version,
        layer,
        sampleRate,
        mode,
        bitRate,
        crcCheck,
        duration,
        copyrighted,
        original,
        emphasis,
      );
    } else {
      throw InvalidMP3FileException('The file cannot be processed as it is not a valid MP3 file');
    }
  }
}
