// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'constants/client_constants.dart';

/// An instance of MP3 metadata.
class MP3Info {
  /// The MPEG [Version] which is one of 1, 2, or 2.5.
  final Version version;

  /// The MPEG [Layer] which is one of I, II or III.
  final Layer layer;

  /// The [SampleRate] which is one of 32KHz, 44.1KHz or 48KHz
  final SampleRate sampleRate;

  /// The [ChannelMode] which is one of stereo, joint stereo, dual channel or
  /// single channel..
  final ChannelMode channelMode;

  /// The bitrate which can range between 32bps and 448bps.
  ///
  /// The range available is dependent upon the MPEG [Version] and [Layer]]
  /// version.
  final int bitrate;

  /// Indicates whether the MP3 is protected by CRC
  final bool crc;

  /// The calculated [Duration] of the MP3.
  final Duration duration;

  /// Indicates whether MP3 is copyrighted
  final bool copyrighted;

  /// Indicates whether the files is the original or a copy
  final bool original;

  /// The emphasis value for this mp3: none,50/15 ms or CCIT J.17.
  final Emphasis emphasis;

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
  );
}
