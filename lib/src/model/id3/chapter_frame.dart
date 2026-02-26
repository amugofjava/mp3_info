// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:mp3_info/src/extensions/parse_extension.dart';
import 'package:mp3_info/src/model/id3/frame.dart';
import 'package:mp3_info/src/model/id3/frame_header.dart';
import 'package:mp3_info/src/model/id3/text_frame.dart';

/// A 'CHAP' (Chapter) frame in an ID3v2 tag.
///
/// It marks a specific point in the audio, with start/end times and an optional title.
/// Specification: https://id3.org/id3v2-chapters-1.0
class ChapterFrame extends Frame {
  /// The header for this frame.
  final FrameHeader frameHeader;

  /// The raw byte data of the ID3 tag.
  final Uint8List tags;

  /// A unique identifier for the chapter.
  Uint8List elementId = Uint8List(0);

  /// The title of the chapter.
  String chapterName = '';

  /// The start time of the chapter in milliseconds.
  int startTime = 0;

  /// The end time of the chapter in milliseconds.
  int endTime = 0;

  /// The start offset of the chapter in bytes.
  int startTimeZeroOffset = 0;

  /// The end offset of the chapter in bytes.
  int endTimeZeroOffset = 0;

  ChapterFrame({required this.frameHeader, required this.tags});

  /// Parses the chapter frame data.
  @override
  void parse() {
    var eid = 0;

    for (var element = 0; element < frameHeader.data.length; element++) {
      if (frameHeader.data[element] == 0) {
        eid = element;
        break;
      }
    }

    elementId = frameHeader.data.sublist(0, eid);

    var offset = eid + 1;

    startTime =
        frameHeader.data.sublist(offset, offset + Frame.intSize).parseInt();
    offset += Frame.intSize;

    endTime =
        frameHeader.data.sublist(offset, offset + Frame.intSize).parseInt();
    offset += Frame.intSize;

    startTimeZeroOffset =
        frameHeader.data.sublist(offset, offset + Frame.intSize).parseInt();
    offset += Frame.intSize;

    endTimeZeroOffset =
        frameHeader.data.sublist(offset, offset + Frame.intSize).parseInt();
    offset += Frame.intSize;

    var bytesRemaining = frameHeader.data.sublist(offset);

    do {
      var subFrame = Frame.fromBytes(offset: 0, bytes: bytesRemaining);
      bytesRemaining = subFrame.remainingBytes;

      if (subFrame is TextFrame) {
        chapterName = subFrame.value;
      }
    } while (bytesRemaining.isNotEmpty);
  }

  @override
  int? get nextFrame =>
      frameHeader.size + frameHeader.offset + Frame.headerSize;

  @override
  Uint8List get remainingBytes => tags.sublist(nextFrame ?? 0);
}
