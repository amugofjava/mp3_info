// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Enumeration of supported MPEG versions.
enum Version {
  /// Unknown or unsupported version.
  unknown,

  /// MPEG-1.
  mpeg1,

  /// MPEG-2.
  mpeg2,

  /// MPEG-2.5.
  mpeg25,
}

/// Enumeration of supported MPEG layers.
enum Layer {
  /// Unknown or unsupported layer.
  unknown,

  /// Layer I.
  mpegI,

  /// Layer II.
  mpegII,

  /// Layer III.
  mpegIII,
}

/// Enumeration of supported audio sample rates.
enum SampleRate {
  /// 32.0 KHz.
  rate_32000,

  /// 44.1 KHz.
  rate_44100,

  /// 48.0 KHz.
  rate_48000,
}

/// Enumeration of supported channel modes.
enum ChannelMode {
  /// Standard stereo.
  stereo,

  /// Joint stereo.
  jointStereo,

  /// Dual channel (two mono tracks).
  dualChannel,

  /// Single channel (mono).
  singleChannel,
}

/// Enumeration of emphasis types.
enum Emphasis {
  /// No emphasis applied.
  none,

  /// 50/15 ms emphasis.
  ms5015,

  /// Reserved for future use.
  reserved,

  /// CCITT J.17 emphasis.
  ccit,
}
