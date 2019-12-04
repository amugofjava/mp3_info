// Copyright 2019 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class InvalidMP3FileException implements Exception {
  final String error;

  InvalidMP3FileException(this.error);
}