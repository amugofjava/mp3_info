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
  - [x] Copyright flag
  - [x] Origin (original/copy))
  - [x] Emphasis
- [x] CBR (Constant Bitrate) support
- [ ] VBR (Variable Bitrate) support
- [ ] ID3 v2 Tag support
  - [ ] AENC Audio encryption
  - [ ] APIC Attached picture
  - [x] CHAP Chapters
  - [ ] COMM Comments
  - [ ] COMR Commercial frame
  - [ ] ENCR Encryption method registration
  - [ ] EQUA Equalization
  - [ ] ETCO Event timing codes
  - [ ] GEOB General encapsulated object
  - [ ] GRID Group identification registration
  - [ ] IPLS Involved people list
  - [ ] LINK Linked information
  - [ ] MCDI Music CD identifier
  - [ ] MLLT MPEG location lookup table
  - [ ] OWNE Ownership frame
  - [ ] PRIV Private frame
  - [ ] PCNT Play counter
  - [ ] POPM Popularimeter
  - [ ] POSS Position synchronisation frame
  - [ ] RBUF Recommended buffer size
  - [ ] RVAD Relative volume adjustment
  - [ ] RVRB Reverb
  - [ ] SYLT Synchronized lyric/text
  - [ ] SYTC Synchronized tempo codes
  - [ ] TALB Album/Movie/Show title
  - [ ] TBPM BPM (beats per minute)
  - [ ] TCOM Composer
  - [ ] TCON Content type
  - [ ] TCOP Copyright message
  - [ ] TDAT Date
  - [ ] TDLY Playlist delay
  - [ ] TENC Encoded by
  - [ ] TEXT Lyricist/Text writer
  - [ ] TFLT File type
  - [ ] TIME Time
  - [ ] TIT1 Content group description
  - [x] TIT2 Title/songname/content description
  - [ ] TIT3 Subtitle/Description refinement
  - [ ] TKEY Initial key
  - [ ] TLAN Language(s)
  - [ ] TLEN Length
  - [ ] TMED Media type
  - [ ] TOAL Original album/movie/show title
  - [ ] TOFN Original filename
  - [ ] TOLY Original lyricist(s)/text writer(s)
  - [ ] TOPE Original artist(s)/performer(s)
  - [ ] TORY Original release year
  - [ ] TOWN File owner/licensee
  - [ ] TPE1 Lead performer(s)/Soloist(s)
  - [ ] TPE2 Band/orchestra/accompaniment
  - [ ] TPE3 Conductor/performer refinement
  - [ ] TPE4 Interpreted, remixed, or otherwise modified by
  - [ ] TPOS Part of a set
  - [ ] TPUB Publisher
  - [ ] TRCK Track number/Position in set
  - [ ] TRDA Recording dates
  - [ ] TRSN Internet radio station name
  - [ ] TRSO Internet radio station owner
  - [ ] TSIZ Size
  - [ ] TSRC ISRC (international standard recording code)
  - [ ] TSSE Software/Hardware and settings used for encoding
  - [ ] TYER Year
  - [ ] TXXX User defined text information frame
  - [ ] UFID Unique file identifier
  - [ ] USER Terms of use
  - [ ] USLT Unsychronized lyric/text transcription
  - [ ] WCOM WCOM Commercial information
  - [ ] WCOP Copyright/Legal information
  - [ ] WOAF Official audio file webpage
  - [ ] WOAR Official artist/performer webpage
  - [ ] WOAS Official audio source webpage
  - [ ] WORS Official internet radio station homepage
  - [ ] WPAY Payment
  - [ ] WPUB Publishers official webpage
  - [ ] WXXX User defined URL link frame

