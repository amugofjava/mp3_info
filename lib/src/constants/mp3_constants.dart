// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The bitrates available differ depending upon the MPEG version and layer version
const bitrate_v1_l1 = {
  0x01: 32,
  0x02: 64,
  0x03: 96,
  0x04: 128,
  0x05: 160,
  0x06: 192,
  0x07: 224,
  0x08: 256,
  0x09: 288,
  0x0A: 320,
  0x0B: 352,
  0x0C: 384,
  0x0D: 416,
  0x0E: 448,
};

const bitrate_v1_l2 = {
  0x01: 32,
  0x02: 48,
  0x03: 56,
  0x04: 64,
  0x05: 80,
  0x06: 96,
  0x07: 112,
  0x08: 128,
  0x09: 160,
  0x0A: 192,
  0x0B: 224,
  0x0C: 256,
  0x0D: 320,
  0x0E: 384,
};

const bitrate_v1_l3 = {
  0x01: 32,
  0x02: 40,
  0x03: 48,
  0x04: 56,
  0x05: 64,
  0x06: 80,
  0x07: 96,
  0x08: 112,
  0x09: 128,
  0x0A: 160,
  0x0B: 192,
  0x0C: 224,
  0x0D: 256,
  0x0E: 320,
};

const bitrate_v2_l1 = {
  0x01: 32,
  0x02: 48,
  0x03: 56,
  0x04: 64,
  0x05: 80,
  0x06: 96,
  0x07: 112,
  0x08: 128,
  0x09: 144,
  0x0A: 160,
  0x0B: 176,
  0x0C: 192,
  0x0D: 224,
  0x0E: 256,
};

const bitrate_v2_l2 = {
  0x01: 8,
  0x02: 16,
  0x03: 24,
  0x04: 32,
  0x05: 40,
  0x06: 48,
  0x07: 56,
  0x08: 64,
  0x09: 80,
  0x0A: 96,
  0x0B: 112,
  0x0C: 128,
  0x0D: 144,
  0x0E: 160,
};

const bitrate_v2_l3 = {
  0x01: 8,
  0x02: 16,
  0x03: 24,
  0x04: 32,
  0x05: 40,
  0x06: 48,
  0x07: 56,
  0x08: 64,
  0x09: 80,
  0x0A: 96,
  0x0B: 112,
  0x0C: 128,
  0x0D: 144,
  0x0E: 160,
};

/// The frame header consists of 4 bytes. Each frame contains information about the
/// MP3 file such as MPEG version, Layer version, bit rate etc. For constant bitrate
/// encoded files (CBR) each frame will be identical; for variable bitrate files
/// each frame may have different information about the bitrate. As we are not
/// always comparing a single bit we use these masks to strip out the parts we
/// need for the comparison.

/// The start of each frame contains a frame sync which is 11 bits long and should
/// all be set to 1. This allows us to check that the frame is valid.
const frameSyncA = 0xFF; // 11111111
const frameSyncB = 0xE0; // 11100000

/// The MPEG version is contained within bits 4 & 5 of byte 2. The MPEG version is
/// either 1, 2 or 2.5.
const mpegVersionMask = 0x18;

/// The MPEG layer version is contained within bits 6 & 7 of byte 2. The MPEG layer
/// can be I, II or III.
const mpegLayerMask = 0x06;

/// The 8th bit of byte 2 is 1 if the MP3 is protected by CRC, or 0 if not.
const mpegProtectionMask = 0x01;

/// The bitrate is contained within the first 4 bits of byte 3. The actual bitrate
/// depends upon the MPEG version and layer for a given bitrate mask.
const mpegBitRateMask = 0xF0;

/// The sample rate is contained within bits 5 & 6 of byte 3. The sample rates can
/// be either 32KHz, 44.1KHz or 48KHz
const mpegSampleRateMask = 0x0C;

/// The channel mode is contained within bits 1 & 2 of byte 4. The channel mode
/// can be one of stereo, joint stereo, dual channel or mono.
const mpegChannelModeMask = 0xC0;

/// Once masked, these constants can then be compared to the appropriate byte to
/// determine the MPEG version, layer, sample rate etc.
const mpegVersion1 = 0x18;
const mpegVersion2 = 0x10;
const mpegVersion2_5 = 0x00;

const layer1 = 0x06;
const layer2 = 0x04;
const layer3 = 0x02;

const sample44 = 0x00;
const sample48 = 0x01;
const sample32 = 0x02;

const channelStereo = 0x00;
const channelJointStereo = 0x01;
const channelDualChannel = 0x02;
const channelSingleChannel = 0x03;
