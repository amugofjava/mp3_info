// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mp3_info/src/metadata/model/chapter.dart';
import 'package:mp3_info/src/metadata/model/comment.dart';

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

  /// TPE1: The song artist.
  String artist = '';

  /// TPE2: The song artist.
  String albumArtist = '';

  /// TALB: The song album.
  String album = '';

  /// TDAT: The song album.
  String date = '';

  /// TDLY: The playlist delay.
  String delay = '';

  /// TENC: Encoded by.
  String encodedBy = '';

  /// TFLT: File type.
  String fileType = '';

  /// TIME: Time.
  String time = '';

  /// TIT1: Content group description.
  String groupDescription = '';

  /// TKEY: Initial key.
  String key = '';

  /// TEXT: Lyricist/Text writer
  String writer = '';

  /// TLAN: Language
  String language = '';

  /// TLEN: Length
  String length = '';

  /// TMED: Media type
  String mediaType = '';

  /// TOAL: Original title
  String originalTitle = '';

  /// TOFL: Original filename
  String originalFilename = '';

  /// TOLY: Original writer
  String originalWriter = '';

  /// TOPE: Original writer
  String originalArtist = '';

  /// TORY: Original year
  String originalYear = '';

  /// TOWN: File owner/licensee
  String owner = '';

  /// TPE3: Performer/conductor
  String performer = '';

  /// TPE4: Interpreted, remixed, or otherwise modified by
  String modifiedBy = '';

  /// TRDA: Recording dates
  String recordingDates = '';

  /// TRSN: Internet radio station name
  String stationName = '';

  /// TRSO: Internet radio station owner
  String stationOwner = '';

  /// TSIZ: Size
  String size = '';

  /// TSRC: ISRC (international standard recording code)
  String recordingCode = '';

  /// TSEE: Software/Hardware and settings used for encoding
  String encodingSettings = '';

  /// TXXX: User defined text information frame
  String information = '';

  /// TBPM: Beats per minute.
  String bpm = '';

  /// TCOP: The song album.
  String copyright = '';

  /// TPOS: The song album.
  String disc = '';

  /// TCON: The genre.
  String genre = '';

  /// TCOP: The composer.
  String composer = '';

  /// TPUB: The publisher.
  String publisher = '';

  /// TYER: The composer.
  String year = '';

  /// TRCK: The song track.
  String track = '';

  /// TIT2: The song title.
  String title = '';

  /// TIT3: The song description.
  String description = '';

  /// Any comment extracted from the COMM frame.
  Comment? comment;

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
