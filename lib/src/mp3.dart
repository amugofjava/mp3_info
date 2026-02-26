// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mp3_info/src/model/id3/id3.dart';

import 'constants/client_constants.dart';

/// Represents the metadata and audio properties of an MP3 file.
///
/// This class holds information extracted from both the MPEG audio frames
/// and any embedded ID3 tags.
class MP3Info {
  /// The MPEG version (1, 2, or 2.5).
  final Version version;

  /// The MPEG layer (I, II, or III).
  final Layer layer;

  /// The audio sample rate (e.g., 32KHz, 44.1KHz, 48KHz).
  final SampleRate? sampleRate;

  /// The channel mode (stereo, joint stereo, dual channel, or single channel).
  final ChannelMode channelMode;

  /// The bitrate of the audio in bits per second.
  /// The available range depends on the MPEG [Version] and [Layer].
  final int bitrate;

  /// Indicates whether the MP3 is protected by a Cyclic Redundancy Check (CRC).
  final bool crc;

  /// The calculated duration of the audio.
  final Duration duration;

  /// Indicates whether the MP3 is copyrighted.
  final bool copyrighted;

  /// Indicates whether the file is an original or a copy.
  final bool original;

  /// The emphasis applied to the audio (e.g., none, 50/15 ms, CCIT J.17).
  final Emphasis? emphasis;

  /// Contains the parsed ID3 metadata, if present.
  final ID3? id3;

  MP3Info(
    this.version,
    this.layer,
    this.sampleRate,
    this.channelMode,
    this.bitrate,
    this.crc,
    this.duration,
    this.copyrighted,
    this.original,
    this.emphasis,
    this.id3,
  );
}
