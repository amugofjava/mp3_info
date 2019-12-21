// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum Version {
  unknown,
  MPEG_1,
  MPEG_2,
  MPEG_2_5,
}

enum Layer {
  unknown,
  MPEG_I,
  MPEG_II,
  MPEG_III,
}

enum SampleRate {
  rate_32000,
  rate_44100,
  rate_48000,
}

enum ChannelMode {
  stereo,
  joint_stereo,
  dual_channel,
  single_channel,
}
