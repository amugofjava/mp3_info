// Copyright 2019-2020 Ben Hills (ben.hills@amugofjava.me.uk).
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents a single chapter entry from an ID3 tag.
///
/// A chapter specifies a portion of the audio, defined by a [startTime]
/// and optionally an [endTime], with an optional [title].
class ID3Chapter {
  /// The start time of the chapter in milliseconds.
  int startTime;

  /// The end time of the chapter in milliseconds, if available.
  int? endTime;

  /// The title of the chapter, if available.
  String? title;

  ID3Chapter({required this.startTime, this.endTime, this.title});
}
