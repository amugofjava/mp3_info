// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Exception thrown when an invalid integer is encountered.
class InvalidIntException implements Exception {
  /// The error message associated with the exception.
  final String error;

  InvalidIntException(this.error);

  @override
  String toString() => 'InvalidIntException: $error';
}
