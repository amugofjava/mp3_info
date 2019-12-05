# MP3 Info
Processes an MP3 file to extract key meta information such as MPEG version,
MPEG layer version, bitrate, sample rate and duration.

## Usage

A simple usage example:

```dart
import 'dart:io';

import 'package:mp3_info/mp3_info.dart';

main() {
  MP3Info mp3 = MP3Processor.fromFile(File("test_files/test_128kpbs_441khz_stereo_10s.mp3"));

  print('MP3: test_128kpbs_441khz_stereo_10s.mp3');

  switch(mp3.sampleRate) {
    case SampleRate.rate_32000:
      print('Sample rate: 32KHz');
      break;
    case SampleRate.rate_44100:
      print('Sample rate: 44.1KHz');
      break;
    case SampleRate.rate_48000:
      print('Sample rate: 48KHz');
      break;
  }

  print('Bit rate: ${mp3.bitrate}bps');
  print('Duration: ${mp3.duration}');
}
```

### Task list

- [x] MP3 Key fields
  - [x] MPEG version
  - [x] MPEG layer version
  - [x] Sample rate
  - [x] Bitrate
  - [x] Duration
  - [x] CRC check
  - [x] Channel mode
  - [ ] Mode extension
  - [ ] Copyright flag
  - [ ] Origin (original/copy))
  - [ ] Emphasis
- [x] CBR (Constant Bitrate) support
- [ ] VBR (Variable Bitrate) support
- [ ] ID3 Tag support
- [ ] ID1 Tag support
