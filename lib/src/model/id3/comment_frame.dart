// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:mp3_info/src/model/id3/frame.dart';
import 'package:mp3_info/src/model/id3/frame_header.dart';

/// Represents an ID3 text frame (e.g., TIT2, TPE1, COMM).
///
/// This class handles the parsing of text frames, including different
/// encoding formats.
class CommentFrame extends Frame {
  /// The header for this frame.
  final FrameHeader frameHeader;

  /// The raw tag bytes.
  final Uint8List tags;

  /// The parsed text value of the frame.
  String value = '';

  String language = '';

  String description = '';

  CommentFrame({required this.frameHeader, required this.tags});

  /// Parses the text data from the frame, considering the encoding byte. We'll assume
  /// the correct encoding from the first byte, rather than checking up to 2 for UTF16.
  @override
  void parse() {
    final int encodingByte = frameHeader.data[0];
    language = latin1.decode(frameHeader.data.sublist(1, 4));
    final descBytes = terminatedStringBytes(
        encodingByte, frameHeader.data.sublist(4),
        includeTerminatorBytes: true);
    description = readString(frameHeader.data.sublist(4, 4 + descBytes),
        encoding: encodingByte);
    final valueBytes = frameHeader.data.sublist(4 + descBytes);
    value = readString(valueBytes, encoding: encodingByte);
  }

  @override
  int? get nextFrame =>
      frameHeader.size + frameHeader.offset + Frame.headerSize;

  @override
  Uint8List get remainingBytes => tags.sublist(nextFrame ?? 0);
}
