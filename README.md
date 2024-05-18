# FFmpeg libav + LuaJIT FFI demo

## Contents

### [`show_metadata.lua`](https://github.com/un-def/ffmpeg-libav-luajit-ffi-demo/blob/master/show_metadata.lua)

libavformat metadata extraction API usage example adopted from [`show_metadata.c`](https://github.com/FFmpeg/FFmpeg/blob/n7.0/doc/examples/show_metadata.c).

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

```
$ ffmpeg -version 2>&1 | head -1
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
