// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mp3_info/src/model/id3/id3_chapter.dart';

/// Represents the parsed metadata from an ID3 tag.
///
/// This includes the tag version, header flags, and common frames
/// like title, artist, comments, and chapters.
class ID3 {
  /// The major version of the ID3 tag (e.g., 3 for ID3v2.3).
  final int majorVersion;

  /// The minor version of the ID3 tag.
  final int minorVersion;

  /// Indicates whether the tag uses unsynchronisation.
  final bool syncSafe;

  /// Indicates whether the tag includes an extended header.
  final bool extendedHeader;

  /// Indicates whether the tag includes a footer.
  final bool footer;

  /// The size of the tag header in bytes.
  final int headerSize;

  /// A list of chapters extracted from the ID3 tag.
  final List<ID3Chapter> chapters = <ID3Chapter>[];

  /// TALB: The song album.
  String album = '';

  /// TCOP: The song album.
  String copyright = '';

  /// The song title extracted from the TIT2 frame.
  String title = '';

  /// The artist name extracted from the TPE1 frame.
  String artist = '';

  /// Any comment extracted from the COMM frame.
  String comment = '';

  /// IPLS
  String people = '';

  ID3({
    required this.majorVersion,
    required this.minorVersion,
    required this.syncSafe,
    required this.extendedHeader,
    required this.footer,
    required this.headerSize,
  });
}
