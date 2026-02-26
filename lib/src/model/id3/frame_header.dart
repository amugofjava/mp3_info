// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:mp3_info/src/extensions/parse_extension.dart';

/// Represents the header of an ID3v2 frame.
///
/// The header contains the frame ID, size, and flags.
class FrameHeader {
  /// The offset within the file where this frame starts.
  final int offset;

  /// The raw byte data of the MP3 file.
  final Uint8List bytes;

  /// The raw bytes of the current tag being processed.
  Uint8List? currentTag;

  /// The 4-character ID of the frame (e.g., 'TIT2', 'CHAP').
  Uint8List? id;

  /// The size of the frame data (excluding the header).
  int size = 0;

  /// The frame-specific flags.
  Uint8List? flags;

  /// The raw data of the frame itself.
  Uint8List data = Uint8List(0);

  /// The name of the frame, decoded from the [id].
  String? name;

  FrameHeader({
    required this.offset,
    required this.bytes,
  }) {
    if (bytes.length >= offset + 10) {
      currentTag = bytes.sublist(offset, offset + 10);
      id = currentTag!.sublist(0, 4);
      flags = currentTag!.sublist(8, 10);
      size = currentTag!.sublist(4, 8).parseInt();
      name = latin1.decode(id!).toString();
      data = bytes.sublist(offset + 10, offset + 10 + size);
    }
  }
}
