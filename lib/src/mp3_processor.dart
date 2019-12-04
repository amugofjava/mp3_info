// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mp3_info/src/constants/mp3_constants.dart';
import 'package:mp3_info/src/exceptions/invalid_file_exception.dart';

import 'constants/client_constants.dart';
import 'mp3.dart';

/// This class handles the processing of an MP3 file. This version does not support
/// ID3 tags and, for now, just reads enough of the ID3 header (if present) in order
/// to discover the first frame of the MP3. From here we read the 10 byte frame header
/// and break it down into its constituent parts: Frame sync, MPEG version, MPEG layer,
/// bitrate, sample rate, channel count and CRC check. We also computer the duration.
class MP3Processor {
  static MP3Info fromFile(File file) {
    Uint8List bytes = file.readAsBytesSync();

    MP3Processor instance = MP3Processor();

    return instance._processBytes(bytes);
  }

  /// The ID3 header is 10 bytes long with bytes 7-10 containing the length of
  /// the ID3 tag space (excluding the 10 byte header itself. This function
  /// calculates the start of the first MP3 frame.
  int _processID3(Uint8List bytes) {
    var headerSize =
        (bytes[6] << 21) + (bytes[7] << 14) + (bytes[8] << 7) + (bytes[9]);

    return headerSize + 10;
  }

  _processMpegVersion(Uint8List frameHeader) {
    var version = frameHeader[1] & mpegVersionMask;

    switch (version) {
      case mpegVersion1:
        return Version.MPEG_1;
        break;
      case mpegVersion2:
        return Version.MPEG_2;
        break;
      case mpegVersion2_5:
        return Version.MPEG_2_5;
        break;
    }
  }

  _processMpegLayer(Uint8List frameHeader) {
    int mpegLayer = frameHeader[1] & mpegLayerMask;

    switch (mpegLayer) {
      case layer1:
        return Layer.MPEG_I;
        break;
      case layer2:
        return Layer.MPEG_II;
        break;
      case layer3:
        return Layer.MPEG_III;
        break;
    }
  }

  bool _processCrcCheck(Uint8List frameHeader) {
    int mpegProtection = frameHeader[1] & mpegProtectionMask;

    return mpegProtection == mpegProtectionMask;
  }

  int _processBitRate(Uint8List frameHeader, Version version, Layer layer) {
    int sampleInfo = frameHeader[2];
    int bitRate = (sampleInfo & mpegBitRateMask) >> 4;
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

  SampleRate _processSampleRate(Uint8List frameHeader) {
    int sampleRate = (frameHeader[2] & mpegSampleRateMask) >> 2;
    SampleRate rate;

    switch(sampleRate) {
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
    int fileSizeBits = fileSizeBytes * 8;
    int bitRateBits = bitRate * 1000;

    double seconds = fileSizeBits / bitRateBits;

    return Duration(seconds: seconds.floor());
  }

  ChannelMode _processChannelMode(Uint8List frameHeader) {
    int channelMode = (frameHeader[3] & mpegChannelModeMask) >> 6;
    ChannelMode mode;

    switch(channelMode) {
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

  MP3Info _processBytes(Uint8List bytes) {
    var header = bytes.sublist(0, 10);
    var tag = header.sublist(0, 3);
    var firstFrameOffset = 0;

    // Does the MP3 start with an ID3 tag?
    firstFrameOffset = latin1.decode(tag) == "ID3" ? _processID3(header) : 0;

    Uint8List frameHeaderBytes =
        bytes.sublist(firstFrameOffset, firstFrameOffset + 10);

    // Ensure we have a valid MP3 frame
    int frameSync1 = frameHeaderBytes[0] & frameSyncA;
    int frameSync2 = frameHeaderBytes[1] & frameSyncB;

    if (frameSync1 == 0xFF && frameSync2 == 0xE0) {
      int fileSize = bytes.length - firstFrameOffset;

      Version version = _processMpegVersion(frameHeaderBytes);
      Layer layer = _processMpegLayer(frameHeaderBytes);
      bool crcCheck = _processCrcCheck(frameHeaderBytes);
      int bitRate = _processBitRate(frameHeaderBytes, version, layer);
      SampleRate sampleRate = _processSampleRate(frameHeaderBytes);
      Duration duration = _processDuration(fileSize, bitRate);
      ChannelMode mode = _processChannelMode(frameHeaderBytes);

      return MP3Info(
        version,
        layer,
        sampleRate,
        mode,
        bitRate,
        crcCheck,
        duration,
      );
    } else {
      throw InvalidMP3FileException('The file cannot be processed as it is not a valid MP3 file');
    }
  }
}
