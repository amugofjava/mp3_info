// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mp3_info/src/constants/mp3_constants.dart';
import 'package:mp3_info/src/exceptions/invalid_file_exception.dart';
import 'package:mp3_info/src/extensions/parse_extension.dart';
import 'package:mp3_info/src/model/id3/chapter_frame.dart';
import 'package:mp3_info/src/model/id3/frame.dart';
import 'package:mp3_info/src/model/id3/id3_chapter.dart';
import 'package:mp3_info/src/model/id3/text_frame.dart';

import 'constants/client_constants.dart';
import 'model/id3/id3.dart';
import 'mp3.dart';

/// A utility class for processing MP3 files and extracting metadata.
///
/// [MP3Processor] provides methods to read MP3 data from files, byte arrays,
/// or remote URLs, and returns an [MP3Info] object containing the extracted
/// information.
class MP3Processor {
  /// The size of the ID3v2 header.
  static const mp3HeaderSize = 10;

  /// Index of the first byte in a 4-byte frame header.
  static int frame1 = 0;

  /// Index of the second byte in a 4-byte frame header.
  static int frame2 = 1;

  /// Index of the third byte in a 4-byte frame header.
  static int frame3 = 2;

  /// Index of the fourth byte in a 4-byte frame header.
  static int frame4 = 3;

  /// Processes the MP3 data from a [File].
  ///
  /// Set [includeID3] to false to skip ID3 tag processing.
  static MP3Info fromFile(File file, {bool includeID3 = true}) {
    final bytes = file.readAsBytesSync();
    final instance = MP3Processor();
    return instance._processBytes(bytes, includeID3: includeID3);
  }

  /// Processes the MP3 data from a list of [bytes].
  ///
  /// Set [includeID3] to false to skip ID3 tag processing.
  static MP3Info fromBytes(Uint8List bytes, {bool includeID3 = true}) {
    final instance = MP3Processor();
    return instance._processBytes(bytes, includeID3: includeID3);
  }

  /// Processes the MP3 data from a remote [uri].
  ///
  /// Set [includeID3] to false to skip ID3 tag processing.
  /// [userAgent] is used for the HTTP request.
  static Future<MP3Info> fromUri(String uri,
      {String userAgent = 'https://github.com/amugofjava/mp3_info/v0.2.2',
      bool includeID3 = true}) async {
    final instance = MP3Processor();
    var url = Uri.parse(uri);
    var bytes = await _fetchHttpRange(url, 9, userAgent);

    if (includeID3 && bytes.isNotEmpty) {
      var id3Size = instance.isID3Tagged(bytes);
      if (id3Size > 10) {
        bytes = await _fetchHttpRange(url, id3Size + mp3HeaderSize, userAgent);
      }
    }

    return instance._processBytes(bytes);
  }

  /// Checks if the given [bytes] start with an ID3 tag.
  ///
  /// Returns the total size of the ID3 tag including the header.
  int isID3Tagged(Uint8List bytes) {
    if (bytes.length < 10) return 0;
    var tag = bytes.sublist(0, 3);

    if (latin1.decode(tag) == 'ID3') {
      var total = bytes.sublist(6, 10).parseInt(syncSafe: true);
      return total + mp3HeaderSize;
    }

    return 0;
  }

  /// Fetches a range of bytes from a remote URL.
  static Future<Uint8List> _fetchHttpRange(
      Uri uri, int bytes, String userAgent) async {
    var resp = await http.get(uri, headers: {
      'range': 'bytes=0-$bytes',
      'cache-control': 'no-cache',
      'User-Agent': userAgent
    });

    if (resp.statusCode == 206) {
      return resp.bodyBytes;
    }

    return Uint8List(0);
  }

  /// The ID3 header is 10 bytes long with bytes 7-10 containing the length of
  /// the ID3 tag space (excluding the 10 byte header itself. This function
  /// calculates the start of the first MP3 frame.
  (int, ID3?) _processID3(Uint8List bytes, {bool processTag = true}) {
    var tagSpaceSize = bytes.sublist(6, 10).parseInt(syncSafe: true);
    var majorVersion = bytes[3];
    var minorVersion = bytes[4];
    var flags = bytes[5];
    var syncSafe = (0x40 & flags != 0);
    var extended = (0x20 & flags != 0);
    var footer = (0x10 & flags != 0);

    if (processTag) {
      /// We currently only support v3 of the spec
      if (majorVersion == 3) {
        final id3 = ID3(
          majorVersion: majorVersion,
          minorVersion: minorVersion,
          syncSafe: syncSafe,
          extendedHeader: extended,
          footer: footer,
          headerSize: tagSpaceSize,
        );

        var tags = bytes.sublist(10, tagSpaceSize + mp3HeaderSize);
        var tagPointer = 0;

        while (tagPointer > -1 && tagPointer < tagSpaceSize) {
          try {
            final frame = Frame.fromBytes(offset: tagPointer, bytes: tags);
            frame.parse();

            switch (frame) {
              case ChapterFrame():
                id3.chapters.add(ID3Chapter(
                  startTime: frame.startTime,
                  endTime: frame.endTime,
                  title: frame.chapterName,
                ));
              case TextFrame():
                switch (frame.frameHeader.name) {
                  case 'COMM':
                    id3.comment = frame.value;
                  case 'IPLS':
                    id3.people = frame.value;
                  case 'TPE1':
                    id3.artist = frame.value;
                  case 'TALB':
                    id3.album = frame.value;
                  case 'TCOP':
                    id3.copyright = frame.value;
                  case 'TIT2':
                    id3.title = frame.value;
                }
            }

            tagPointer = frame.nextFrame ?? -1;
          } catch (e) {
            print('Error processing frame: $e');
            tagPointer = -1;
          }
        }

        return ((tagSpaceSize + Frame.headerSize), id3);
      }
    }
    return ((tagSpaceSize + Frame.headerSize), null);
  }

  /// Internal method for determining the MPEG version from frame header.
  Version _processMpegVersion(Uint8List frameHeader) {
    var version = frameHeader[frame2] & mpegVersionMask;

    switch (version) {
      case mpegVersion1:
        return Version.mpeg1;
      case mpegVersion2:
        return Version.mpeg2;
      case mpegVersion2_5:
        return Version.mpeg25;
    }

    return Version.unknown;
  }

  Layer _processMpegLayer(Uint8List frameHeader) {
    final mpegLayer = frameHeader[frame2] & mpegLayerMask;

    switch (mpegLayer) {
      case layer1:
        return Layer.mpegI;
      case layer2:
        return Layer.mpegII;
      case layer3:
        return Layer.mpegIII;
    }

    return Layer.unknown;
  }

  /// Internal method for checking the CRC protection bit.
  bool _processCrcCheck(Uint8List frameHeader) {
    final mpegProtection = frameHeader[frame2] & mpegProtectionMask;
    return mpegProtection > 0;
  }

  /// Internal method for extracting the bitrate from the frame header.
  int? _processBitRate(Uint8List frameHeader, Version version, Layer layer) {
    final sampleInfo = frameHeader[frame3];
    final bitRate = (sampleInfo & mpegBitRateMask) >>
        4; // Easier to compare if we shift the bits down.
    Map<int, int> bitRateMap;

    if (version == Version.mpeg1) {
      if (layer == Layer.mpegI) {
        bitRateMap = bitrateV1L1;
      } else if (layer == Layer.mpegII) {
        bitRateMap = bitrateV1L2;
      } else {
        bitRateMap = bitrateV1L3;
      }
    } else {
      if (layer == Layer.mpegI) {
        bitRateMap = bitrateV2L1;
      } else if (layer == Layer.mpegII) {
        bitRateMap = bitrateV2L2;
      } else {
        bitRateMap = bitrateV2L3;
      }
    }

    return bitRateMap[bitRate];
  }

  /// Internal method for extracting the sample rate from the frame header.
  SampleRate? _processSampleRate(Uint8List frameHeader) {
    final sampleRate = (frameHeader[frame3] & mpegSampleRateMask);
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

  /// Internal method for calculating audio duration.
  Duration _processDuration(int fileSizeBytes, int bitRate) {
    final fileSizeBits = fileSizeBytes * 8;
    final bitRateBits = bitRate * 1000;

    final seconds = fileSizeBits / bitRateBits;
    final milliseconds = (seconds * 1000).floor();

    return Duration(milliseconds: milliseconds);
  }

  /// Internal method for determining the channel mode from frame header.
  ChannelMode _processChannelMode(Uint8List frameHeader) {
    final channelMode = (frameHeader[frame4] & mpegChannelModeMask);
    ChannelMode mode;

    switch (channelMode) {
      case channelStereo:
        mode = ChannelMode.stereo;
        break;
      case channelJointStereo:
        mode = ChannelMode.jointStereo;
        break;
      case channelDualChannel:
        mode = ChannelMode.dualChannel;
        break;
      default:
        mode = ChannelMode.singleChannel;
        break;
    }

    return mode;
  }

  /// Internal method for checking the copyright flag.
  bool _processCopyright(Uint8List frameHeader) {
    final copyright = (frameHeader[frame4] & mpegCopyrightMask);
    return copyright > 0;
  }

  /// Internal method for checking the original/copy flag.
  bool _processOriginal(Uint8List frameHeader) {
    final original = (frameHeader[frame4] & mpegOriginalMask);
    return original > 0;
  }

  /// Internal method for extracting emphasis information from frame header.
  Emphasis? _processEmphasis(Uint8List frameHeader) {
    final emphasis = (frameHeader[frame4] & mpegEmphasisMask);
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

  /// Processes raw bytes to extract [MP3Info].
  MP3Info _processBytes(Uint8List bytes, {bool includeID3 = true}) {
    var firstFrameOffset = 0;
    ID3? id3;

    if (bytes.length >= 10) {
      var tag = bytes.sublist(0, 3);

      if (latin1.decode(tag) == 'ID3') {
        (firstFrameOffset, id3) = _processID3(bytes, processTag: includeID3);
      }
    }

    if (bytes.length < firstFrameOffset + 10) {
      throw InvalidMP3FileException('File is too short to be a valid MP3 file');
    }

    final frameHeaderBytes =
        bytes.sublist(firstFrameOffset, firstFrameOffset + 10);
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
        id3,
      );
    } else {
      throw InvalidMP3FileException(
          'The file cannot be processed as it is not a valid MP3 file');
    }
  }
}
