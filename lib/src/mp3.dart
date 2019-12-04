// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'constants/client_constants.dart';

class MP3Info {
  final Version version;
  final Layer layer;
  final SampleRate sampleRate;
  final ChannelMode channelMode;
  final int bitrate;
  final bool crc;
  final Duration duration;

  MP3Info(
    this.version,
    this.layer,
    this.sampleRate,
    this.channelMode,
    this.bitrate,
    this.crc,
    this.duration,
  );
}
