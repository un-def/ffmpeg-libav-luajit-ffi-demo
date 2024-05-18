local function _print(fd, ...)
    for idx = 1, select('#', ...) do
        fd:write(tostring(select(idx, ...)))
    end
    fd:write('\n')
end

local function print_stderr(...)
    _print(io.stderr, ...)
end

local function print_stdout(...)
    _print(io.stdout, ...)
end


local filename = arg[1]
if not filename then
    print_stderr('usage: ', arg[0], ' FILE')
    os.exit(1)
end


local ffi = require('ffi')

local lavu = ffi.load('libavutil')
local lavc = ffi.load('libavcodec')
local lavf = ffi.load('libavformat')


ffi.cdef[[
    typedef struct AVDictionaryEntry {
        char *key;
        char *value;
    } AVDictionaryEntry;

    typedef struct AVDictionary {
        int count;
        AVDictionaryEntry *elems;
    } AVDictionary;

    int av_strerror(int errnum, char *errbuf, size_t errbuf_size);

    unsigned avutil_version(void);
    unsigned avcodec_version(void);
    unsigned avformat_version(void);
]]


local function get_av_error(err_num)
    local err_buf = ffi.new('char[256]')
    local ret = lavu.av_strerror(err_num, err_buf, 256)
    if ret == 0 then
        return ffi.string(err_buf)
    else
        return nil
    end
end


-- #define AV_VERSION_INT(a, b, c) ((a)<<16 | (b)<<8 | (c))
local function make_av_version_int(major, minor, micro)
    return bit.bor(bit.lshift(major, 16), bit.lshift(minor, 8), micro)
end

local function parse_av_version_int(av_version_int)
    local major_minor = bit.rshift(av_version_int, 8)
    return bit.rshift(major_minor, 8), bit.band(major_minor, 0xff), bit.band(av_version_int, 0xff)
end


local lavu_version_int = lavu.avutil_version()
local lavu_version = {parse_av_version_int(lavu_version_int)}
print_stderr('lavu ', lavu_version[1], '.', lavu_version[2], '.', lavu_version[3])

local lavc_version_int = lavc.avcodec_version()
local lavc_version = {parse_av_version_int(lavc_version_int)}
print_stderr('lavc ', lavc_version[1], '.', lavc_version[2], '.', lavc_version[3])

local lavf_version_int = lavf.avformat_version()
local lavf_version = {parse_av_version_int(lavf_version_int)}
print_stderr('lavf ', lavf_version[1], '.', lavf_version[2], '.', lavf_version[3])


local function if_then_else(cond, then_value, else_value)
    if cond then
        return then_value
    end
    return else_value or ''
end

ffi.cdef(
    [[
        typedef struct AVFormatContext {
            const void *av_class;
            const void *iformat;
            const void *oformat;
            void *priv_data;
            void *pb;
            int ctx_flags;
            unsigned int nb_streams;
            void **streams;
    ]]
    ..
    -- #define FF_API_FORMAT_FILENAME (LIBAVFORMAT_VERSION_MAJOR < 59)
    -- #if FF_API_FORMAT_FILENAME
    --     attribute_deprecated char filename[1024];
    -- #endif
    if_then_else(lavf_version[1] < 59, [[
            char filename[1024];
    ]])
    ..
    -- https://github.com/FFmpeg/FFmpeg/commit/c8db1006ef5cb0f40f485fe6ce255892d8af5eb3
    if_then_else(lavf_version[1] >= 61, [[
            unsigned int nb_stream_groups;
            void **stream_groups;
            unsigned int nb_chapters;
            void **chapters;
    ]])
    ..
    [[
            char *url;
            int64_t start_time;
            int64_t duration;
            int64_t bit_rate;
            unsigned int packet_size;
            int max_delay;
            int flags;
            int64_t probesize;
            int64_t max_analyze_duration;
            const uint8_t *key;
            int keylen;
            unsigned int nb_programs;
            void **programs;
            int video_codec_id;
            int audio_codec_id;
            int subtitle_codec_id;
    ]]
    ..
    -- https://github.com/FFmpeg/FFmpeg/commit/c8db1006ef5cb0f40f485fe6ce255892d8af5eb3
    if_then_else(lavf_version[1] >= 61,
        [[
            int data_codec_id;
        ]], [[
            unsigned int max_index_size;
            unsigned int max_picture_buffer;
            unsigned int nb_chapters;
            void **chapters;
        ]]
    )
    ..
    [[
            AVDictionary *metadata;
        } AVFormatContext;
    ]]
)

ffi.cdef[[
    typedef struct AVInputFormat AVInputFormat;

    int avformat_open_input(AVFormatContext **ps, const char *url, const AVInputFormat *fmt, AVDictionary **options);
    int avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options);
    void avformat_close_input(AVFormatContext **ps);
]]


-- overridden below
local function av_dict_iterate(dict, tag)
    return
end

-- https://github.com/FFmpeg/FFmpeg/blob/n7.0/doc/APIchanges
-- 2022-11-06 - 9dad237928 - lavu 57.42.100 - dict.h
--   Add av_dict_iterate().
if lavu_version_int >= make_av_version_int(57, 42, 100) then
    print_stderr('lavu >= 57.42.100, using av_dict_iterate')
    ffi.cdef[[
        AVDictionaryEntry *av_dict_iterate(const AVDictionary *m, const AVDictionaryEntry *prev);
    ]]
    av_dict_iterate = function(dict, tag) return lavu.av_dict_iterate(dict, tag) end
else
    print_stderr('lavu < 57.42.100, using av_dict_get')
    -- https://github.com/FFmpeg/FFmpeg/commit/9dad2379283cbf5842cff14c0e34b97958698201
    ffi.cdef[[
        AVDictionaryEntry *av_dict_get(
            const AVDictionary *m, const char *key, const AVDictionaryEntry *prev, int flags);
    ]]
    local AV_DICT_IGNORE_SUFFIX = 2
    av_dict_iterate = function(dict, tag) return lavu.av_dict_get(dict, '', tag, AV_DICT_IGNORE_SUFFIX) end
end


local fmt_ctx_ptr = ffi.new('AVFormatContext *[1]')

local err_num = lavf.avformat_open_input(fmt_ctx_ptr, filename, nil, nil)
if err_num ~= 0 then
    print_stderr('error: ', get_av_error(err_num))
    os.exit(2)
end

local fmt_ctx = fmt_ctx_ptr[0]

local err_num = lavf.avformat_find_stream_info(fmt_ctx, nil)
if err_num < 0 then
    print_stderr('error:', get_av_error(err_num))
    os.exit(2)
end

local tag = ffi.new('AVDictionaryEntry *')
while true do
    tag = av_dict_iterate(fmt_ctx.metadata, tag)
    if tag == nil then
        break
    end
    print_stdout('  ', ffi.string(tag.key), ': ', ffi.string(tag.value))
end

lavf.avformat_close_input(fmt_ctx_ptr)
