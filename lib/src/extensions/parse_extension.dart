// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mp3_info/src/exceptions/invalid_int_exception.dart';

/// Extension on [List<int>] for parsing integers from raw bytes.
extension ByteParser on List<int> {
  /// Parses a 32-bit integer from a list of 4 bytes.
  ///
  /// If [syncSafe] is true, it parses the bytes as an ID3v2 syncsafe integer (7 bits per byte).
  /// Otherwise, it parses them as a standard big-endian 32-bit integer.
  ///
  /// Throws [InvalidIntException] if the list length is not exactly 4.
  int parseInt({bool syncSafe = false}) {
    int value = 0;

    if (length == 4) {
      if (syncSafe) {
        value = ((this[0] & 0x7f) << 21) + ((this[1] & 0x7f) << 14) + ((this[2] & 0x7f) << 7) + (this[3] & 0x7f);
      } else {
        value = (this[0] << 24) + (this[1] << 16) + (this[2] << 8) + (this[3]);
      }
    } else {
      throw InvalidIntException('Byte list contains an invalid number of bytes: $length. Expected 4');
    }

    return value;
  }
}
