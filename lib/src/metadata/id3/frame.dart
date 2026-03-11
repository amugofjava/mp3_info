// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:mp3_info/src/metadata/id3/chapter_frame.dart';
import 'package:mp3_info/src/metadata/id3/comment_frame.dart';
import 'package:mp3_info/src/metadata/id3/frame_header.dart';
import 'package:mp3_info/src/metadata/id3/text_frame.dart';
import 'package:mp3_info/src/metadata/id3/unsupported_frame.dart';

/// An abstract representation of an ID3 frame.
///
/// ID3 tags are composed of multiple frames, each containing a specific
/// piece of metadata. This class provides the base functionality for
/// parsing and handling these frames.
abstract class Frame {
  /// The size of the standard ID3v2 frame header in bytes.
  static const int headerSize = 10;

  /// The size of a 32-bit integer in bytes (used in ID3v2 frames).
  static const int intSize = 4;

  static const int textEncodingISO88591 = 0;
  static const int textEncodingUTF16 = 1;
  static const int textEncodingUTF16BE = 2;
  static const int textEncodingUTF8 = 3;

  /// Returns the offset to the next frame, if available.
  int? get nextFrame;

  /// Returns the remaining bytes after this frame.
  Uint8List get remainingBytes;

  Frame();

  void parse();

  /// Parses a frame from the given [bytes] starting at the [offset].
  ///
  /// This factory method identifies the frame type and returns the
  /// appropriate concrete [Frame] implementation (e.g., [ChapterFrame], [TextFrame]).
  factory Frame.fromBytes({required int offset, required Uint8List bytes}) {
    final frameHeader = FrameHeader(offset: offset, bytes: bytes);

    switch (frameHeader.name) {
      case 'CHAP':
        return ChapterFrame(frameHeader: frameHeader, tags: bytes);
      case 'COMM':
        return CommentFrame(frameHeader: frameHeader, tags: bytes);
      case 'IPLS':
      case 'TALB':
      case 'TBPM':
      case 'TCOM':
      case 'TCON':
      case 'TCOP':
      case 'TDAT':
      case 'TDLY':
      case 'TENC':
      case 'TEXT':
      case 'TFLT':
      case 'TIME':
      case 'TIT1':
      case 'TIT2':
      case 'TIT3':
      case 'TKEY':
      case 'TLAN':
      case 'TLEN':
      case 'TMED':
      case 'TOAL':
      case 'TOFN':
      case 'TOLY':
      case 'TOPE':
      case 'TORY':
      case 'TOWN':
      case 'TPE1':
      case 'TPE2':
      case 'TPE3':
      case 'TPE4':
      case 'TPOS':
      case 'TPUB':
      case 'TRCK':
      case 'TRDA':
      case 'TRSN':
      case 'TRSO':
      case 'TSIZ':
      case 'TSRC':
      case 'TSSE':
      case 'TYER':
      case 'TXXX':
      case 'TDES':
        return TextFrame(frameHeader: frameHeader, tags: bytes);
      default:
        return UnsupportedFrame(frameHeader: frameHeader, tags: bytes);
    }
  }

  String readString(Uint8List bytes, {int? encoding}) {
    final encodingByte = encoding ?? bytes[0];
    final terminatedStringBytes =
        encoding == null ? bytes.sublist(1) : bytes.sublist(0);

    switch (encodingByte) {
      case Frame.textEncodingISO88591:
        return parseLatinString(terminatedStringBytes);
      case Frame.textEncodingUTF16:
        return parseUTF16BOMString(terminatedStringBytes);
      case Frame.textEncodingUTF16BE:
        return parseUTF16BEString(terminatedStringBytes);
      case Frame.textEncodingUTF8:
        return parseUTF8String(terminatedStringBytes);
      default:
        return parseLatinString(terminatedStringBytes);
    }
  }

  String parseLatinString(Uint8List bytes) {
    var input = terminatedString(Frame.textEncodingISO88591, bytes);

    return latin1.decode(input);
  }

  String parseUTF8String(Uint8List bytes) {
    var input = terminatedString(Frame.textEncodingISO88591, bytes);

    return const Utf8Decoder().convert(input);
  }

  String parseUTF16BEString(Uint8List bytes) {
    return _parseUTF16String(bytes, false);
  }

  String parseUTF16LEString(Uint8List bytes) {
    return _parseUTF16String(bytes, true);
  }

  String parseUTF16BOMString(Uint8List bytes) {
    final bom = bytes.sublist(0, 2);
    if (bom[0] == 0xFF && bom[1] == 0xFE) {
      return _parseUTF16String(bytes.sublist(2), true);
    } else if (bom[0] == 0xFE && bom[1] == 0xFF) {
      return _parseUTF16String(bytes.sublist(2), false);
    }

    return '';
  }

  /// Helper method for parsing UTF-16 encoded strings from raw bytes.
  String _parseUTF16String(Uint8List bytes, bool littleEndian) {
    var input = terminatedString(Frame.textEncodingUTF16, bytes);

    var sb = <int>[];
    var ptr = 0;

    for (var b = 0; b < input.length; b += 2) {
      var byte1 = input[b];
      var byte2 = input[b + 1];

      if (littleEndian) {
        sb.add(byte1);
        sb[ptr] |= (byte2 << 8);
      } else {
        sb.add(byte2);
        sb[ptr] |= (byte1 << 8);
      }

      ptr++;
    }

    return String.fromCharCodes(sb);
  }

  int terminatedStringBytes(int encoding, Uint8List bytes,
      {bool includeTerminatorBytes = false}) {
    var pos = 0;
    var terminator = 0;

    for (var p = 0; p < bytes.length; p++) {
      /// Single byte encoding, return the position
      if (encoding == Frame.textEncodingISO88591 ||
          encoding == Frame.textEncodingUTF8) {
        if (bytes[p] == 0) {
          terminator = 1;
          break;
        }
      } else {
        /// For double byte encoding, keep going until we find a pair.
        if (p < bytes.length - 1 && bytes[p] == 0 && bytes[p + 1] == 0) {
          terminator = 2;
          break;
        }
      }

      pos++;
    }

    return includeTerminatorBytes ? pos + terminator : pos;
  }

  Uint8List terminatedString(int encoding, Uint8List bytes) {
    var pos = terminatedStringBytes(encoding, bytes);

    if (pos > 0) {
      return bytes.sublist(0, pos);
    }

    return Uint8List(0);
  }
}
