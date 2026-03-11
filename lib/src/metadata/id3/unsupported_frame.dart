// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mp3_info/src/metadata/id3/frame.dart';
import 'package:mp3_info/src/metadata/id3/frame_header.dart';

/// A placeholder for ID3 frames that are not explicitly supported by the library.
///
/// This class allows the parser to gracefully skip over unknown or unsupported frames
/// without halting the parsing process.
class UnsupportedFrame extends Frame {
  /// The header of the unsupported frame.
  final FrameHeader frameHeader;

  /// The raw byte data of the ID3 tag.
  final Uint8List tags;

  UnsupportedFrame({required this.frameHeader, required this.tags});

  @override
  void parse() {}

  @override
  int? get nextFrame =>
      frameHeader.size + frameHeader.offset + Frame.headerSize;

  @override
  Uint8List get remainingBytes => tags.sublist(nextFrame ?? 0);
}
