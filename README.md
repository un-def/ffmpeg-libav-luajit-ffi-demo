# FFmpeg libav + LuaJIT FFI demo

## Contents

### [`show_metadata.lua`](https://github.com/un-def/ffmpeg-libav-luajit-ffi-demo/blob/master/show_metadata.lua)

libavformat metadata extraction API usage example adopted from [`show_metadata.c`](https://github.com/FFmpeg/FFmpeg/blob/n7.0/doc/examples/show_metadata.c).

#### Output Examples

<details>
  <summary>FFmpeg 4.4</summary>

  ```
  $ ffmpeg -version | head -1
  ffmpeg version 4.4.2-0ubuntu0.22.04.1 Copyright (c) 2000-2021 the FFmpeg developers

  $ lua show_metadata.lua Big_Buck_Bunny_1080_10s_10MB.webm
  lavu 56.70.100
  lavc 58.134.100
  lavf 58.76.100
  lavu < 57.42.100, using av_dict_get
    title: Big Buck Bunny, Sunflower version
    GENRE: Animation
    MAJOR_BRAND: isom
    MINOR_VERSION: 1
    COMPATIBLE_BRANDS: isomavc1
    COMPOSER: Sacha Goedegebure
    ARTIST: Blender Foundation 2008, Janus Bager Kristensen 2013
    COMMENT: Creative Commons Attribution 3.0 - http://bbb3d.renderfarming.net
    ENCODER: Lavf58.14.100
  ```
</details>

<details>
  <summary>FFmpeg 5.1</summary>

  ```
  $ ffmpeg -version | head -1
  ffmpeg version 5.1.4-0+deb12u1 Copyright (c) 2000-2023 the FFmpeg developers

  $ lua show_metadata.lua UHD_HDR_test_v11.mkv
  lavu 57.28.100
  lavc 59.37.100
  lavf 59.27.100
  lavu < 57.42.100, using av_dict_get
    encoder: libebml v1.3.3 + libmatroska v1.4.4
    creation_time: 2015-10-28T20:07:20.000000Z
  ```
</details>

<details>
  <summary>FFmpeg 6.1</summary>

  ```
  $ ffmpeg -version | head -1
  ffmpeg version 6.1.1-3ubuntu5 Copyright (c) 2000-2023 the FFmpeg developers

  $ lua show_metadata.lua ChID-BLITS-EBU-Narration.mp4
  lavu 58.29.100
  lavc 60.31.102
  lavf 60.16.100
  lavu >= 57.42.100, using av_dict_iterate
    major_brand: mp42
    minor_version: 0
    compatible_brands: mp42isom
    creation_time: 2012-07-22T17:48:25.000000Z
    encoder: Fraunhofer IIS MPEG-4 Audio Encoder 03.02.11.01_MPEGScbr_SXPro
  ```
</details>

<details>
  <summary>FFmpeg 7.0</summary>

```
$ ffmpeg -version | head -1
ffmpeg version n7.0 Copyright (c) 2000-2024 the FFmpeg developers

$ lua show_metadata.lua Sample_BeeMoved_96kHz24bit.flac
lavu 59.8.100
lavc 61.3.100
lavf 61.1.100
lavu >= 57.42.100, using av_dict_iterate
  ALBUM: Bee Moved
  TITLE: Bee Moved
  album_artist: Blue Monday FM
  MRAT: 0
  ARTIST: Blue Monday FM
```
</details>
