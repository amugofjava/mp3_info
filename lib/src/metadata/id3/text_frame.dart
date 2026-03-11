// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mp3_info/src/metadata/id3/frame.dart';
import 'package:mp3_info/src/metadata/id3/frame_header.dart';

/// Represents an ID3 text frame (e.g., TIT2, TPE1, COMM).
///
/// This class handles the parsing of text frames, including different
/// encoding formats.
class TextFrame extends Frame {
  /// The header for this frame.
  final FrameHeader frameHeader;

  /// The raw tag bytes.
  final Uint8List tags;

  /// The parsed text value of the frame.
  String value = '';

  TextFrame({required this.frameHeader, required this.tags});

  /// Parses the text data from the frame, considering the encoding byte. We'll assume
  /// the correct encoding from the first byte, rather than checking up to 2 for UTF16.
  @override
  void parse() {
    value = readString(frameHeader.data);
  }

  @override
  int? get nextFrame =>
      frameHeader.size + frameHeader.offset + Frame.headerSize;

  @override
  Uint8List get remainingBytes => tags.sublist(nextFrame ?? 0);
}
