(*
 * copyright (c) 2001 Fabrice Bellard
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation;
 * version 2 of the License.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 **
 *
 *
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavformat/avformat.h
 * libavformat version 53.6.0
 *)

unit avformat;

{$MINENUMSIZE 4}

{$LEGACYIFEND ON}

{$DEFINE AVFORMAT_AVFORMAT_H}

interface

uses
  system.SysUtils,
  ctypes,
  avcodec,
  avio,
  avutil,
  opt,
  rational;

{$INCLUDE version.pas}


(**
 * Return the LIBAVFORMAT_VERSION_INT constant.
 *)
function avformat_version(): cuint;
  cdecl; external LIB_AVFORMAT;

(**
 * Return the libavformat build-time configuration.
 *)
function avformat_configuration(): PansiChar;
  cdecl; external LIB_AVFORMAT;

(**
 * Return the libavformat license.
 *)
function avformat_license(): PansiChar;
  cdecl; external LIB_AVFORMAT;


(**
 * @defgroup metadata_api Public Metadata API
 * @{
 * The metadata API allows libavformat to export metadata tags to a client
 * application using a sequence of key/value pairs. Like all strings in FFmpeg,
 * metadata must be stored as UTF-8 encoded Unicode. Note that metadata
 * exported by demuxers isn't checked to be valid UTF-8 in most cases.
 * Important concepts to keep in mind:
 * -  Keys are unique; there can never be 2 tags with the same key. This is
 *    also meant semantically, i.e., a demuxer should not knowingly produce
 *    several keys that are literally different but semantically identical.
 *    E.g., key=Author5, key=Author6. In this example, all authors must be
 *    placed in the same tag.
 * -  Metadata is flat, not hierarchical; there are no subtags. If you
 *    want to store, e.g., the email address of the child of producer Alice
 *    and actor Bob, that could have key=alice_and_bobs_childs_email_address.
 * -  Several modifiers can be applied to the tag name. This is done by
 *    appending a dash character ('-') and the modifier name in the order
 *    they appear in the list below -- e.g. foo-eng-sort, not foo-sort-eng.
 *    -  language -- a tag whose value is localized for a particular language
 *       is appended with the ISO 639-2/B 3-letter language code.
 *       For example: Author-ger=Michael, Author-eng=Mike
 *       The original/default language is in the unqualified "Author" tag.
 *       A demuxer should set a default if it sets any translated tag.
 *    -  sorting  -- a modified version of a tag that should be used for
 *       sorting will have '-sort' appended. E.g. artist="The Beatles",
 *       artist-sort="Beatles, The".
 *
 * -  Demuxers attempt to export metadata in a generic format, however tags
 *    with no generic equivalents are left as they are stored in the container.
 *    Follows a list of generic tag names:
 *
 @verbatim
 album        -- name of the set this work belongs to
 album_artist -- main creator of the set/album, if different from artist.
                 e.g. "Various Artists" for compilation albums.
 artist       -- main creator of the work
 comment      -- any additional description of the file.
 composer     -- who composed the work, if different from artist.
 copyright    -- name of copyright holder.
 creation_time-- date when the file was created, preferably in ISO 8601.
 date         -- date when the work was created, preferably in ISO 8601.
 disc         -- number of a subset, e.g. disc in a multi-disc collection.
 encoder      -- name/settings of the software/hardware that produced the file.
 encoded_by   -- person/group who created the file.
 filename     -- original name of the file.
 genre        -- <self-evident>.
 language     -- main language in which the work is performed, preferably
                 in ISO 639-2 format. Multiple languages can be specified by
                 separating them with commas.
 performer    -- artist who performed the work, if different from artist.
                 E.g for "Also sprach Zarathustra", artist would be "Richard
                 Strauss" and performer "London Philharmonic Orchestra".
 publisher    -- name of the label/publisher.
 service_name     -- name of the service in broadcasting (channel name).
 service_provider -- name of the service provider in broadcasting.
 title        -- name of the work.
 track        -- number of this work in the set, can be in form current/total.
 variant_bitrate -- the total bitrate of the bitrate variant that the current stream is part of
 @endverbatim
 *
 * Look in the examples section for an application example how to use the Metadata API.
 *
 * @}
 *)

{$IF FF_API_OLD_METADATA2}
(**
 * @defgroup old_metadata Old metadata API
 * The following functions are deprecated, use
 * their equivalents from libavutil/dict.h instead.
 * @
 *)

const
  AV_METADATA_MATCH_CASE      = AV_DICT_MATCH_CASE;
  AV_METADATA_IGNORE_SUFFIX   = AV_DICT_IGNORE_SUFFIX;
  AV_METADATA_DONT_STRDUP_KEY = AV_DICT_DONT_STRDUP_KEY;
  AV_METADATA_DONT_STRDUP_VAL = AV_DICT_DONT_STRDUP_VAL;
  AV_METADATA_DONT_OVERWRITE  = AV_DICT_DONT_OVERWRITE;


type

  PAVMetadata = PAVDictionary;
  TAVMetadata = TAVDictionary;
  PAVMetadataTag = PAVDictionaryEntry;
  TAVMetadataTag = TAVDictionaryEntry ;

  PAVMetadataConv = ^TAVMetadataConv;
  TAVMetadataConv = record
  end;

(**
 * Get a metadata element with matching key.
 *
 * @param prev Set to the previous matching element to find the next.
 *             If set to NULL the first matching element is returned.
 * @param flags Allows case as well as suffix-insensitive comparisons.
 * @return Found tag or NULL, changing key or value leads to undefined behavior.
 *)
function av_metadata_get(m: PAVDictionary; const key: PAnsiChar;
                         const prev: PAVDictionaryEntry; flags: cint): PAVDictionaryEntry;
  cdecl; external LIB_AVFORMAT;

(**
 * Set the given tag in *pm, overwriting an existing tag.
 *
 * @param pm pointer to a pointer to a metadata struct. If *pm is NULL
 * a metadata struct is allocated and put in *pm.
 * @param key tag key to add to *pm (will be av_strduped depending on flags)
 * @param value tag value to add to *pm (will be av_strduped depending on flags).
 *        Passing a NULL value will cause an existing tag to be deleted.
 * @return >= 0 on success otherwise an error code <0
 *)
function av_metadata_set2(var pm: PAVDictionary; const key: PAnsiChar; const value: PAnsiChar; flags: cint): cint;
  cdecl; external LIB_AVFORMAT; deprecated;

(**
 * Copy metadata from one AVDictionary struct into another.
 * @param dst pointer to a pointer to a AVDictionary struct. If *dst is NULL,
 *            this function will allocate a struct for you and put it in *dst
 * @param src pointer to source AVDictionary struct
 * @param flags flags to use when setting metadata in *dst
 * @note metadata is read using the AV_DICT_IGNORE_SUFFIX flag
 *)
procedure av_metadata_copy(dst: PPAVDictionary; src: PAVDictionary; flags: cint);
  cdecl; external LIB_AVFORMAT; deprecated;

(**
 * Free all the memory allocated for an AVDictionary struct.
 *)
procedure av_metadata_free(m: PPAVDictionary);
  cdecl; external LIB_AVFORMAT; deprecated;
(**
 * @}
 *)
{$IFEND}

(* packet functions *)

(**
 * Allocate and read the payload of a packet and initialize its fields with
 * default values.
 *
 * @param pkt packet
 * @param size desired payload size
 * @return >0 (read size) if OK, AVERROR_xxx otherwise
 *)
function av_get_packet(s: PAVIOContext; var pkt: TAVPacket; size: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Read data and append it to the current content of the AVPacket.
 * If pkt->size is 0 this is identical to av_get_packet.
 * Note that this uses av_grow_packet and thus involves a realloc
 * which is inefficient. Thus this function should only be used
 * when there is no reasonable way to know (an upper bound of)
 * the final size.
 *
 * @param pkt packet
 * @param size amount of data to read
 * @return >0 (read size) if OK, AVERROR_xxx otherwise, previous data
 *         will not be lost even if an error occurs.
 *)
function av_append_packet(s: PAVIOContext; var pkt: TAVPacket; size: cint): cint;
  cdecl; external LIB_AVFORMAT;



const
  AVPROBE_SCORE_MAX   = 100;   ///< Maximum score, half of that is used for file-extension-based detection
  AVPROBE_PADDING_SIZE = 32;   ///< extra allocated bytes at the end of the probe buffer

  //! Demuxer will use url_fopen, no opened file should be provided by the caller.
  AVFMT_NOFILE        = $0001;
  AVFMT_NEEDNUMBER    = $0002; (**< Needs '%d' in filename. *)
  AVFMT_SHOW_IDS      = $0008; (**< Show format stream IDs numbers. *)
  AVFMT_RAWPICTURE    = $0020; (**< Format wants AVPicture structure for
                                      raw picture data. *)
  AVFMT_GLOBALHEADER  = $0040; (**< Format wants global header. *)
  AVFMT_NOTIMESTAMPS  = $0080; (**< Format does not need / have any timestamps. *)
  AVFMT_GENERIC_INDEX = $0100; (**< Use generic index building code. *)
  AVFMT_TS_DISCONT    = $0200; (**< Format allows timestamp discontinuities. *)
  AVFMT_VARIABLE_FPS  = $0400; (**< Format allows variable fps. *)
  AVFMT_NODIMENSIONS  = $0800; (**< Format does not need width/height *)
  AVFMT_NOSTREAMS     = $1000; (**< Format does not require any streams *)
  AVFMT_NOBINSEARCH   = $2000; (**< Format does not allow to fallback to binary search via read_timestamp *)
  AVFMT_NOGENSEARCH   = $4000; (**< Format does not allow to fallback to generic search *)
  AVFMT_TS_NONSTRICT  = $8000; (**< Format does not require strictly
                                       increasing timestamps, but they must
                                       still be monotonic *)
  AVINDEX_KEYFRAME = $0001;

  AV_DISPOSITION_DEFAULT   = $0001;
  AV_DISPOSITION_DUB       = $0002;
  AV_DISPOSITION_ORIGINAL  = $0004;
  AV_DISPOSITION_COMMENT   = $0008;
  AV_DISPOSITION_LYRICS    = $0010;
  AV_DISPOSITION_KARAOKE   = $0020;

  (**
   * Track should be used during playback by default.
   * Useful for subtitle track that should be displayed
   * even when user did not explicitly ask for subtitles.
   *)
  AV_DISPOSITION_FORCED    = $0040;
  AV_DISPOSITION_HEARING_IMPAIRED  = $0080;  (**< stream for hearing impaired audiences *)
  AV_DISPOSITION_VISUAL_IMPAIRED   = $0100;  (**< stream for visual impaired audiences *)
  AV_DISPOSITION_CLEAN_EFFECTS     = $0200;  (**< stream without voice *)

  MAX_REORDER_DELAY = 16;
  MAX_PROBE_PACKETS = 2500;

  AV_PROGRAM_RUNNING = 1;

  AVFMTCTX_NOHEADER         = $0001; (**< signal that no header is present
                                         (streams are added dynamically) *)
  AVFMT_NOOUTPUTLOOP        = -1;
  AVFMT_INFINITEOUTPUTLOOP  = 0;
  AVFMT_FLAG_GENPTS         = $0001; ///< Generate missing pts even if it requires parsing future frames.
  AVFMT_FLAG_IGNIDX         = $0002; ///< Ignore index.
  AVFMT_FLAG_NONBLOCK       = $0004; ///< Do not block when reading packets from input.
  AVFMT_FLAG_IGNDTS         = $0008; ///< Ignore DTS on frames that contain both DTS & PTS
  AVFMT_FLAG_NOFILLIN       = $0010; ///< Do not infer any values from other values, just return what is stored in the container
  AVFMT_FLAG_NOPARSE        = $0020; ///< Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the fillin code works on frames and no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has been disabled
  {$IF FF_API_FLAG_RTP_HINT}
    AVFMT_FLAG_RTP_HINT     = $0040; ///< Deprecated, use the -movflags rtphint muxer specific AVOption instead
  {$IFEND}
  AVFMT_FLAG_CUSTOM_IO      = $0080; ///< The caller has supplied a custom AVIOContext, don't avio_close() it.
  AVFMT_FLAG_MP4A_LATM      = $8000; ///< Enable RTP MP4A-LATM payload
  AVFMT_FLAG_SORT_DTS       = $10000; ///< try to interleave outputted packets by dts (using this flag can slow demuxing down)
  AVFMT_FLAG_PRIV_OPT       = $20000; ///< Enable use of private options by delaying codec open (this could be made default once all code is converted)
  AVFMT_FLAG_KEEP_SIDE_DATA = $40000; ///< Dont merge side data but keep it seperate.

  FF_FDEBUG_TS              = $0001;

  RAW_PACKET_BUFFER_SIZE    = 2500000;


(*************************************************)
(* fractional numbers for exact pts handling *)

type
 (**
  * The exact value of the fractional number is: 'val + num / den'.
  * num is assumed to be 0 <= num < den.
  *)
  PAVFrac = ^TAVFrac;
  TAVFrac = record
    val, num, den: cint64;
  end;

(*************************************************)
(* input/output formats *)

  PPAVCodecTag = ^PAVCodecTag;
  PAVCodecTag = ^TAVCodecTag;
  TAVCodecTag = record

  end;

  (**
   * This structure contains the data a format has to probe a file.
   *)
  TAVProbeData = record
    filename: PAnsiChar;
    buf: PByteArray;  (**< Buffer must have AVPROBE_PADDING_SIZE of extra allocated bytes filled with zero. *)
    buf_size: cint;   (**< Size of buf except extra allocated bytes *)
  end;


  PAVFormatParameters = ^TAVFormatParameters;
  TAVFormatParameters = record
  {$IF FF_API_FORMAT_PARAMETERS}
    time_base: TAVRational;
    sample_rate: cint;
    channels: cint;
    width: cint;
    height: cint;
    pix_fmt: TAVPixelFormat;
    channel: cint; (**< Used to select DV channel. *)
    standard: PAnsiChar; (**< deprecated, use demuxer-specific options instead. *)

    { Delphi does not support bit fields -> use bf_flags instead
    unsigned int mpeg2ts_raw:1;  (**< Force raw MPEG-2 transport stream output, if possible. *)
    unsigned int mpeg2ts_compute_pcr:1; (**< Compute exact PCR for each transport
                                  stream packet (only meaningful if
                                  mpeg2ts_raw is TRUE). *)
    unsigned int initial_pause:1;       (**< Do not begin to play the stream
                                        immediately (RTSP only). *)
    unsigned int prealloced_context:1;
    }
    bf_flags: byte; // 0:mpeg2ts_raw/1:mpeg2ts_compute_pcr/2:initial_pause/3:prealloced_context
    {$IFEND}
  end;


  PPAVFormatContext = ^PAVFormatContext;
  PAVFormatContext = ^TAVFormatContext;


  PAVOutputFormat = ^TAVOutputFormat;
  TAVOutputFormat = record
    name: PAnsiChar;
    (**
     * Descriptive name for the format, meant to be more human-readable
     * than name. You should use the NULL_IF_CONFIG_SMALL() macro
     * to define it.
     *)
    long_name: PAnsiChar;
    mime_type: PAnsiChar;
    extensions: PAnsiChar; (**< comma-separated filename extensions *)
    (**
     * size of private data so that it can be allocated in the wrapper
     *)
    priv_data_size: cint;
    (* output support *)
    audio_codec: TCodecID; (**< default audio codec *)
    video_codec: TCodecID; (**< default video codec *)
    write_header: function (c: PAVFormatContext): cint; cdecl;
    write_packet: function (c: PAVFormatContext; pkt: PAVPacket): cint; cdecl;
    write_trailer: function (c: PAVFormatContext): cint; cdecl;
    (**
     * can use flags: AVFMT_NOFILE, AVFMT_NEEDNUMBER, AVFMT_RAWPICTURE,
     * AVFMT_GLOBALHEADER, AVFMT_NOTIMESTAMPS, AVFMT_VARIABLE_FPS,
     * AVFMT_NODIMENSIONS, AVFMT_NOSTREAMS
     *)
    flags: cint;

    dummy: pointer;

    interleave_packet: function (s: PAVFormatContext; out_: PAVPacket;
                                 in_: PAVPacket; flush: cint): cint; cdecl;

    (**
     * List of supported codec_id-codec_tag pairs, ordered by "better
     * choice first". The arrays are all terminated by CODEC_ID_NONE.
     *)
    codec_tag:  PPAVCodecTag;

    subtitle_codec: TCodecID; (**< default subtitle codec *)

    metadata_conv: PAVMetadataConv;

    priv_class: PAVClass; ///< AVClass for the private context

    get_output_timestamp: procedure (s: PAVFormatContext; stream: cint;
                                 dts: Pcint64; wall: Pcint64); cdecl;

    (* private fields *)
    next: PAVOutputFormat;
  end;


  PAVProbeData = ^TAVProbeData;

  PAVInputFormat = ^TAVInputFormat;
  TAVInputFormat = record
    (**
     * A comma separated list of short names for the format. New names
     * may be appended with a minor bump.
     *)
    name: PAnsiChar;

    (**
     * Descriptive name for the format, meant to be more human-readable
     * than name. You should use the NULL_IF_CONFIG_SMALL() macro
     * to define it.
     *)
    long_name: PAnsiChar;

    (**
     * Size of private data so that it can be allocated in the wrapper.
     *)
    priv_data_size: cint;

    (**
     * Tell if a given file has a chance of being parsed as this format.
     * The buffer provided is guaranteed to be AVPROBE_PADDING_SIZE bytes
     * big so you do not have to check for that unless you need more.
     *)
    read_probe: function (p: PAVProbeData): cint; cdecl;

    (**
     * Read the format header and initialize the AVFormatContext
     * structure. Return 0 if OK. 'ap' if non-NULL contains
     * additional parameters. Only used in raw format right
     * now. 'av_new_stream' should be called to create new streams.
     *)
    read_header: function (c: PAVFormatContext;
                           ap: PAVFormatParameters): cint; cdecl;

    (**
     * Read one packet and put it in 'pkt'. pts and flags are also
     * set. 'av_new_stream' can be called only if the flag
     * AVFMTCTX_NOHEADER is used.
     * @return 0 on success, < 0 on error.
     *         When returning an error, pkt must not have been allocated
     *         or must be freed before returning
     *)
    read_packet: function (c: PAVFormatContext; var pkt: TAVPacket): cint; cdecl;

    (**
     * Close the stream. The AVFormatContext and AVStreams are not
     * freed by this function
     *)
    read_close: function (c: PAVFormatContext): cint; cdecl;

{$IF FF_API_READ_SEEK}
    (**
     * Seek to a given timestamp relative to the frames in
     * stream component stream_index.
     * @param stream_index Must not be -1.
     * @param flags Selects which direction should be preferred if no exact
     *              match is available.
     * @return >= 0 on success (but not necessarily the new offset)
     *)
    read_seek: function (c: PAVFormatContext; stream_index: cint;
                  timestamp: cint64; flags: cint): cint; cdecl;
{$IFEND}

    (**
     * Gets the next timestamp in stream[stream_index].time_base units.
     * @return the timestamp or AV_NOPTS_VALUE if an error occurred
     *)
    read_timestamp: function (s: PAVFormatContext; stream_index: cint;
                              pos: pint64; pos_limit: cint64): cint64; cdecl;

    (**
     * Can use flags: AVFMT_NOFILE, AVFMT_NEEDNUMBER.
     *)
    flags: cint;

    (**
     * If extensions are defined, then no probe is done. You should
     * usually not use extension format guessing because it is not
     * reliable enough
     *)
    extensions: PAnsiChar;

    (**
     * General purpose read-only value that the format can use.
     *)
    value: cint;

    (**
     * Start/resume playing - only meaningful if using a network-based format
     * (RTSP).
     *)
    read_play: function (c: PAVFormatContext): cint; cdecl;

    (**
     * Pause playing - only meaningful if using a network-based format
     * (RTSP).
     *)
    read_pause: function (c: PAVFormatContext): cint; cdecl;

    codec_tag : PPAVCodecTag;

    (**
     * Seek to timestamp ts.
     * Seeking will be done so that the point from which all active streams
     * can be presented successfully will be closest to ts and within min/max_ts.
     * Active streams are all streams that have AVStream.discard < AVDISCARD_ALL.
     *)
    read_seek2: function (s:            PAVFormatContext;
                          stream_index: cint;
                          min_ts:       cint64;
                          ts:           cint64;
                          max_ts:       cint64;
                          flags:        cint): cint; cdecl;

    {$IF FF_API_OLD_METADATE2}
      metadata_conv: PAVMetadataConv;
    {$IFEND}

    priv_class : PAVClass; ///< AVClass for the private context

    (* private fields *)
    next: PAVInputFormat;
  end;

  TAVStreamParseType = (
    AVSTREAM_PARSE_NONE,
    AVSTREAM_PARSE_FULL,       (**< full parsing and repack *)
    AVSTREAM_PARSE_HEADERS,    (**< Only parse headers, do not repack. *)
    AVSTREAM_PARSE_TIMESTAMPS, (**< full parsing and interpolation of timestamps for frames not starting on a packet boundary *)
    AVSTREAM_PARSE_FULL_ONCE   (**< full parsing and repack of the first frame only, only implemented for H.264 currently *)
  );

  PAVIndexEntry = ^TAVIndexEntry;
  TAVIndexEntry = record
    pos: cint64;
    timestamp: cint64;        (**<
                               * Timestamp in AVStream.time_base units, preferably the time from which on correctly decoded frames are available
                               * when seeking to this entry. That means preferable PTS on keyframe based formats.
                               * But demuxers can choose to store a different timestamp, if it is more convenient for the implementation or nothing better
                               * is known
                               *)
    { Delphi doesn't support bitfields -> use flags_size instead
    int flags:2;
    int size:30; //Yeah, trying to keep the size of this small to reduce memory requirements (it is 24 vs. 32 bytes due to possible 8-byte alignment).
    }
    flags_size: cint; // 0..1: flags, 2..31: size
    min_distance: cint;         (**< Minimum distance between this and the previous keyframe, used to avoid unneeded searching. *)
  end;

  PStreamInfo = ^TStreamInfo;
  TStreamInfo = record
    last_dts: cint64;
    duration_gcd: cint64;
    last_dts_frame : cint;
    duration_count: cint;
    duration_error: array[0..7] of cdouble;
    codec_info_duration: cint64;
  end; (* use in TAVStream record *)

  PAVPacketList = ^TAVPacketList;

 (**
 * Stream structure.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVStream) must not be used outside libav*.
 *)
  PPAVStream = ^PAVStream;
  PAVStream = ^TAVStream;
  TAVStream = record
    index: cint;    (**< stream index in AVFormatContext *)
    id: cint;       (**< format-specific stream ID *)
    codec: PAVCodecContext; (**< codec context *)
    (**
     * Real base framerate of the stream.
     * This is the lowest framerate with which all timestamps can be
     * represented accurately (it is the least common multiple of all
     * framerates in the stream). Note, this value is just a guess!
     * For example, if the time base is 1/90000 and all frames have either
     * approximately 3600 or 1800 timer ticks, then r_frame_rate will be 50/1.
     *)
    r_frame_rate: TAVRational;
    priv_data: pointer;

    (* internal data used in av_find_stream_info() *)
    first_dts: cint64;

    (**
     * encoding: pts generation when outputting stream
     *)
    pts: TAVFrac;

    (**
     * This is the fundamental unit of time (in seconds) in terms
     * of which frame timestamps are represented. For fixed-fps content,
     * time base should be 1/framerate and timestamp increments should be 1.
     * decoding: set by libavformat
     * encoding: set by libavformat in av_write_header
     *)
    time_base: TAVRational;
    pts_wrap_bits: cint; (* number of bits in pts (used for wrapping control) *)
    (* ffmpeg.c private use *)
    stream_copy: cint; (**< If set, just copy stream. *) {deprecated}
    discard: TAVDiscard; ///< Selects which packets can be discarded at will and do not need to be demuxed.
{$IFDEF FF_API_AVSTREAM_QUALITY}
    //FIXME move stuff to a flags field?
    (**
     * Quality, as it has been removed from AVCodecContext and put in AVVideoFrame.
     * MN:dunno if thats the right place, for it
     *)
    quality: cfloat; {deprecated}
{$ENDIF}

    (**
     * Decoding: pts of the first frame of the stream in presentation order, in stream time base.
     * Only set this if you are absolutely 100% sure that the value you set
     * it to really is the pts of the first frame.
     * This may be undefined (AV_NOPTS_VALUE).
     * @note The ASF header does NOT contain a correct start_time the ASF
     * demuxer must NOT set this.
     *)
    start_time: cint64;

    (**
     * Decoding: duration of the stream, in stream time base.
     * If a source file does not specify a duration, but does specify
     * a bitrate, this value will be estimated from bitrate and file size.
     *)
    duration: cint64;


    (* av_read_frame() support *)
    need_parsing: TAVStreamParseType;
    parser: PAVCodecParserContext;

    cur_dts: cint64;
    last_IP_duration: cint;
    last_IP_pts: cint64;
    (* av_seek_frame() support *)
    index_entries: PAVIndexEntry; (**< Only used if the format does not
                                       support seeking natively. *)
    nb_index_entries: cint;
    index_entries_allocated_size: cuint;


    nb_frames: cint64;                 ///< number of frames in this stream if known or 0

    disposition: cint; (**< AV_DISPOSITION_* bitfield *)

    probe_data: TAVProbeData;
    pts_buffer: array [0..MAX_REORDER_DELAY] of cint64;


    (**
     * sample aspect ratio (0 if unknown)
     * - encoding: Set by user.
     * - decoding: Set by libavformat.
     *)
    sample_aspect_ratio: TAVRational;

    metadata: PAVDictionary;

    {* Intended mostly for av_read_frame() support. Not supposed to be used by *}
    {* external applications; try to use something else if at all possible.    *}
    cur_ptr:  pByteArray;
    cur_len: cint;
    cur_pkt: TAVPacket;

    // Timestamp generation support:
    (**
     * Timestamp corresponding to the last dts sync point.
     *
     * Initialized when AVCodecParserContext.dts_sync_point >= 0 and
     * a DTS is received from the underlying container. Otherwise set to
     * AV_NOPTS_VALUE by default.
     *)
    reference_dts: cint64;

    (**
     * Number of packets to buffer for codec probing
     * NOT PART OF PUBLIC API
     *)
    probe_packets: cint;

    (**
     * last packet in packet_buffer for this stream when muxing.
     * used internally, NOT PART OF PUBLIC API, dont read or write from outside of libav*
     *)
    last_in_packet_buffer: PAVPacketList;


    (**
     * Average framerate
     *)
    avg_frame_rate: TAVRational;

    (**
     * Number of frames that have been demuxed during av_find_stream_info()
     *)
    codec_info_nb_frames: cint;

    (**
     * Stream Identifier
     * This is the MPEG-TS stream identifier +1
     * 0 means unknown
     *)
    stream_identifier: cint;

    interleaver_chunk_size: cint64;
    interleaver_chunk_duration: cint64;

    (**
     * Stream information used internally by av_find_stream_info()
     *)
    info: PStreamInfo;

    (**
     * flag to indicate that probing is requested
     * NOT PART OF PUBLIC API
     *)
    request_probe: cint;
  end; (*  sizeof(TAVStream) =   *)


(**
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVProgram) must not be used outside libav*.
 *)
  PPAVProgram = ^PAVProgram;
  PAVProgram = ^TAVProgram;
  TAVProgram = record
    id: cint;
    flags: cint;
    discard: TAVDiscard;        ///< selects which program to discard and which to feed to the caller
    stream_index: Pcuint;
    nb_stream_indexes: cuint;
    metadata: PAVDictionary;

    program_num: cint;
    pmt_pid: cint;
    pcr_pid: cint;
  end; (* sizeof(TAVProgram) = *)


  PPAVChapter = ^PAVChapter;
  PAVChapter = ^TAVChapter;
  TAVChapter = record
    id: cint;                 ///< unique ID to identify the chapter
    time_base: TAVRational;   ///< time base in which the start/end timestamps are specified
    start, end_: cint64;     ///< chapter start/end time in time_base units
    metadata: PAVDictionary;
  end; (* sizeof(TAVChapter) = *)

 (**
  * Format I/O context.
  * New fields can be added to the end with minor version bumps.
  * Removal, reordering and changes to existing fields require a major
  * version bump.
  * sizeof(AVFormatContext) must not be used outside libav*, use
  * avformat_alloc_context() to create an AVFormatContext.
  *)

  TAVFormatContext = record
    (**
     * A class for logging and AVOptions. Set by avformat_alloc_context().
     * Exports (de)muxer private options if they exist.
     *)
    av_class: PAVClass; (**< Set by avformat_alloc_context. *)

    (**
     * Can only be iformat or oformat, not both at the same time.
     *
     * decoding: set by avformat_open_input().
     * encoding: set by the user.
     *)
    iformat: PAVInputFormat;
    oformat: PAVOutputFormat;

    priv_data: pointer;

    pb: PAVIOContext;

    (**
     * A list of all streams in the file. New streams are created with
     * avformat_new_stream().
     *
     * decoding: streams are created by libavformat in avformat_open_input().
     * If AVFMTCTX_NOHEADER is set in ctx_flags, then new streams may also
     * appear in av_read_frame().
     * encoding: streams are created by the user before avformat_write_header().
     *)
    nb_streams: cuint;
    streams: PPAVStream;

    filename: array [0..1023] of AnsiChar; (* input or output filename *)
    (* stream info *)
{$IF FF_API_TIMESTAMP}
    (**
     * @deprecated use 'creation_time' metadata tag instead
     *)
    timestamp: cint64;
{$IFEND}

    ctx_flags: cint; (**< Format-specific flags, see AVFMTCTX_xx *)

    (* private data for pts handling (do not modify directly). *)
    (**
     * This buffer is only needed when packets were already buffered but
     * not decoded, for example to get the codec parameters in MPEG
     * streams.
     *)
    packet_buffer: PAVPacketList;

    (**
     * Decoding: position of the first frame of the component, in
     * AV_TIME_BASE fractional seconds. NEVER set this value directly:
     * It is deduced from the AVStream values.
     *)
    start_time: cint64;
    (**
     * Decoding: duration of the stream, in AV_TIME_BASE fractional
     * seconds. Only set this value if you know none of the individual stream
     * durations and also dont set any of them. This is deduced from the
     * AVStream values if not set.
     *)
    duration: cint64;

    (**
     * decoding: total file size, 0 if unknown
     *)
    file_size: cint64;

    unused0 : cint;

    (* av_read_frame() support *)
    cur_st: PAVStream;

    (* av_seek_frame() support *)
    data_offset: cint64; (**< offset of the first packet *)

    mux_rate: cint;

    packet_size: cuint;

    preload: cint;

    max_delay: cint;

{$IF FF_API_LOOP_OUTPUT}
    (**
     * number of times to loop output in formats that support it
     *
     * @deprecated use the 'loop' private option in the gif muxer.
     *)
    loop_output: cint;
{$IFEND}

    flags: cint;

{$IF FF_API_LOOP_INPUT}
    (**
     * @deprecated, use the 'loop' img2 demuxer private option.
     *)
    loop_input: cint;
{$IFEND}

    (**
     * decoding: size of data to probe; encoding: unused.
     *)
    probesize: cuint;

    (**
     * Maximum time (in AV_TIME_BASE units) during which the input should
     * be analyzed in avformat_find_stream_info().
     *)
    max_analyze_duration: cint;

    key: pByteArray;
    keylen : cint;

    nb_programs: cuint;
    programs: PPAVProgram;

    (**
     * Forced video codec_id.
     * Demuxing: Set by user.
     *)
    video_codec_id: TCodecID;

    (**
     * Forced audio codec_id.
     * Demuxing: Set by user.
     *)
    audio_codec_id: TCodecID;

    (**
     * Forced subtitle codec_id.
     * Demuxing: Set by user.
     *)
    subtitle_codec_id: TCodecID;

    (**
     * Maximum amount of memory in bytes to use for the index of each stream.
     * If the index exceeds this size, entries will be discarded as
     * needed to maintain a smaller size. This can lead to slower or less
     * accurate seeking (depends on demuxer).
     * Demuxers for which a full in-memory index is mandatory will ignore
     * this.
     * muxing  : unused
     * demuxing: set by user
     *)
    max_index_size: cuint;

    (**
     * Maximum amount of memory in bytes to use for buffering frames
     * obtained from realtime capture devices.
     *)
    max_picture_buffer: cuint;
    nb_chapters: cuint;
    chapters: PPAVChapter;

    (**
     * Flags to enable debugging.
     *)
    debug: cint;


    (**
     * Raw packets from the demuxer, prior to parsing and decoding.
     * This buffer is used for buffering packets until the codec can
     * be identified, as parsing cannot be done without knowing the
     * codec.
     *)
    raw_packet_buffer: PAVPacketList;
    raw_packet_buffer_end: PAVPacketList;

    packet_buffer_end: PAVPacketList;


    metadata: PAVDictionary;


    (**
     * Remaining size available for raw_packet_buffer, in bytes.
     * NOT PART OF PUBLIC API
     *)
    raw_packet_buffer_remaining_size: cint;


    (**
     * Start time of the stream in real world time, in microseconds
     * since the unix epoch (00:00 1st January 1970). That is, pts=0
     * in the stream was captured at this real world time.
     * - encoding: Set by user.
     * - decoding: Unused.
     *)
    start_time_realtime: cint64;

    (**
     * decoding: number of frames used to probe fps
     *)
    fps_probe_size: cint;

    (**
     * Transport stream id.
     * This will be moved into demuxer private options. Thus no API/ABI compatibility
     *)
    ts_id: cint;

    (**
     * Decoding: total stream bitrate in bit/s, 0 if not
     * available. Never set it directly if the file_size and the
     * duration are known as FFmpeg can compute it automatically.
     *)
    bit_rate: cint64;
  end;  (* sizeof(TAVFormatContext) =  *)


  TAVPacketList = record
    pkt: TAVPacket;
    next: PAVPacketList;
  end;



{$IF FF_API_OLD_METADATA2}
  (**
   * This function is provided for compatibility reason and currently does nothing.
   *)
  procedure av_metadata_conv(ctx: PAVFormatContext; const  d_conv: PAVMetadataConv; const  s_conv: PAVMetadataConv);
    cdecl; external LIB_AVFORMAT; deprecated;
{$IFEND}

(**
 * If f is NULL, returns the first registered input format,
 * if f is non-NULL, returns the next registered input format after f
 * or NULL if f is the last one.
 *)
function av_iformat_next(f: PAVInputFormat): PAVInputFormat;
    cdecl; external LIB_AVFORMAT;
(**
 * If f is NULL, returns the first registered output format,
 * if f is non-NULL, returns the next registered input format after f
 * or NULL if f is the last one.
 *)
function av_oformat_next(f: PAVOutputFormat): PAVOutputFormat;
    cdecl; external LIB_AVFORMAT;


{$IF FF_API_GUESS_IMG2_CODEC}
  function av_guess_image2_codec(const filename: PAnsiChar): TCodecID;
      cdecl; external LIB_AVFORMAT;
{$IFEND}

(* XXX: Use automatic init with either ELF sections or C file parser *)
(* modules. *)

(* utils.c *)
procedure av_register_input_format(format: PAVInputFormat);
  cdecl; external LIB_AVFORMAT;
procedure av_register_output_format(format: PAVOutputFormat);
  cdecl; external LIB_AVFORMAT;

(**
 * Return the output format in the list of registered output formats
 * which best matches the provided parameters, or return NULL if
 * there is no match.
 *
 * @param short_name if non-NULL checks if short_name matches with the
 * names of the registered formats
 * @param filename if non-NULL checks if filename terminates with the
 * extensions of the registered formats
 * @param mime_type if non-NULL checks if mime_type matches with the
 * MIME type of the registered formats
 *)
function av_guess_format(const short_name: PAnsiChar;
                         const filename: PAnsiChar;
                         const mime_type: PAnsiChar): PAVOutputFormat;
  cdecl; external LIB_AVFORMAT;

(**
 * Guess the codec ID based upon muxer and filename.
 *)
function av_guess_codec(fmt: PAVOutputFormat; const short_name: PAnsiChar;
                        const filename: PAnsiChar; const mime_type: PAnsiChar;
                        type_: TAVMediaType): TCodecID;
  cdecl; external LIB_AVFORMAT;

(**
 * Send a nice dump of a packet to the specified file stream.
 *
 * @param f The file stream pointer where the dump should be sent to.
 * @param pkt packet to dump
 * @param dump_payload True if the payload must be displayed, too.
 * @param st AVStream that the packet belongs to
 *)
procedure av_pkt_dump2(f: PAVFile; pkt: PAVPacket; dump_payload: cint; st: PAVStream);
  cdecl; external LIB_AVFORMAT;

(**
 * Send a nice dump of a packet to the log.
 *
 * @param avcl A pointer to an arbitrary struct of which the first field is a
 * pointer to an AVClass struct.
 * @param level The importance level of the message, lower values signifying
 * higher importance.
 * @param pkt packet to dump
 * @param dump_payload True if the payload must be displayed, too.
 * @param st AVStream that the packet belongs to
 *)
procedure av_pkt_dump_log2(avcl: Pointer; level: cint; pkt: PAVPacket; dump_payload: cint;
                      st: PAVStream);
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_PKT_DUMP}
  procedure av_pkt_dump(f: PAVFile; pkt: PAVPacket; dump_payload: cint);
    cdecl; external LIB_AVFORMAT;
  procedure av_pkt_dump_log(avcl: Pointer; level: cint; pkt: PAVPacket; dump_payload: cint);
    cdecl; external LIB_AVFORMAT;
{$IFEND}

(**
 * Initialize libavformat and register all the muxers, demuxers and
 * protocols. If you do not call this function, then you can select
 * exactly which formats you want to support.
 *
 * @see av_register_input_format()
 * @see av_register_output_format()
 * @see av_register_protocol()
 *)
procedure av_register_all();
  cdecl; external LIB_AVFORMAT;

(**
 * Get the CodecID for the given codec tag tag.
 * If no codec id is found returns CODEC_ID_NONE.
 *
 * @param tags list of supported codec_id-codec_tag pairs, as stored
 * in AVInputFormat.codec_tag and AVOutputFormat.codec_tag
 *)
function av_codec_get_id(var tags: PAVCodecTag; tag: cuint): TCodecID;
  cdecl; external LIB_AVFORMAT;

(**
 * Getsthe codec tag for the given codec id id.
 * If no codec tag is found returns 0.
 *
 * @param tags list of supported codec_id-codec_tag pairs, as stored
 * in AVInputFormat.codec_tag and AVOutputFormat.codec_tag
 *)
function av_codec_get_tag(var tags: PAVCodecTag; id: TCodecID): cuint;
  cdecl; external LIB_AVFORMAT;

(* media file input */

(**
 * Find AVInputFormat based on the short name of the input format.
 *)
function av_find_input_format(short_name: PAnsiChar): PAVInputFormat;
  cdecl; external LIB_AVFORMAT;

(**
 * Guess file format.
 *
 * @param is_opened Whether the file is already opened; determines whether
 *                  demuxers with or without AVFMT_NOFILE are probed.
 *)
function av_probe_input_format(pd: PAVProbeData; is_opened: cint): PAVInputFormat;
  cdecl; external LIB_AVFORMAT;

(**
 * Guess the file format.
 *
 * @param is_opened Whether the file is already opened; determines whether
 *                  demuxers with or without AVFMT_NOFILE are probed.
 * @param score_max A probe score larger that this is required to accept a
 *                  detection, the variable is set to the actual detection
 *                  score afterwards.
 *                  If the score is <= AVPROBE_SCORE_MAX / 4 it is recommended
 *                  to retry with a larger probe buffer.
 *)
function av_probe_input_format2(pd: PAVProbeData; is_opened: cint; score_max: PCint): PAVInputFormat;
  cdecl; external LIB_AVFORMAT;

(**
 * Guess the file format.
 *
 * @param is_opened Whether the file is already opened; determines whether
 *                  demuxers with or without AVFMT_NOFILE are probed.
 * @param score_ret The score of the best detection.
 *)
function av_probe_input_format3(pd: PAVProbeData; is_opened: cint; score_ret: Pcint): PAVInputFormat;
  cdecl; external LIB_AVFORMAT;


(**
 * Probe a bytestream to determine the input format. Each time a probe returns
 * with a score that is too low, the probe buffer size is increased and another
 * attempt is made. When the maximum probe size is reached, the input format
 * with the highest score is returned.
 *
 * @param pb the bytestream to probe
 * @param fmt the input format is put here
 * @param filename the filename of the stream
 * @param logctx the log context
 * @param offset the offset within the bytestream to probe from
 * @param max_probe_size the maximum probe buffer size (zero for default)
 * @return 0 in case of success, a negative value corresponding to an
 * AVERROR code otherwise
 *)
function av_probe_input_buffer(pb: PAVIOContext; var fmt: PAVInputFormat;
                          const filename: PAnsiChar; logctx: Pointer;
                          offset: cuint; max_probe_size: cuint): cint;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_FORMAT_PARAMETERS}
(**
 * Allocate all the structures needed to read an input stream.
 *        This does not open the needed codecs for decoding the stream[s].
 * @deprecated use avformat_open_input instead.
 *)
function av_open_input_stream(ic_ptr: PPAVFormatContext;
                       pb: PAVIOContext; filename: PAnsiChar;
                       fmt: PAVInputFormat; ap: PAVFormatParameters): cint;
  cdecl; external LIB_AVFORMAT; deprecated 'Use avformat_open_input instead.';

(**
 * Open a media file as input. The codecs are not opened. Only the file
 * header (if present) is read.
 *
 * @param ic_ptr The opened media file handle is put here.
 * @param filename filename to open
 * @param fmt If non-NULL, force the file format to use.
 * @param buf_size optional buffer size (zero if default is OK)
 * @param ap Additional parameters needed when opening the file
 *           (NULL if default).
 * @return 0 if OK, AVERROR_xxx otherwise
 *
 * @deprecated use avformat_open_input instead.
 *)
function av_open_input_file(ic_ptr: PPAVFormatContext; filename: PAnsiChar;
                     fmt: PAVInputFormat; buf_size: cint;
                     ap: PAVFormatParameters): cint;
  cdecl; external LIB_AVFORMAT; deprecated 'use avformat_open_input instead';
{$IFEND}

(**
 * Open an input stream and read the header. The codecs are not opened.
 * The stream must be closed with av_close_input_file().
 *
 * @param ps Pointer to user-supplied AVFormatContext (allocated by avformat_alloc_context).
 *           May be a pointer to NULL, in which case an AVFormatContext is allocated by this
 *           function and written into ps.
 *           Note that a user-supplied AVFormatContext will be freed on failure.
 * @param filename Name of the stream to open.
 * @param fmt If non-NULL, this parameter forces a specific input format.
 *            Otherwise the format is autodetected.
 * @param options  A dictionary filled with AVFormatContext and demuxer-private options.
 *                 On return this parameter will be destroyed and replaced with a dict containing
 *                 options that were not found. May be NULL.
 *
 * @return 0 on success, a negative AVERROR on failure.
 *
 * @note If you want to use custom IO, preallocate the format context and set its pb field.
 *)
function avformat_open_input(ps: PPAVFormatContext; const filename: PAnsiChar; fmt: PAVInputFormat; options: PPAVDictionary): cint;
  cdecl; external LIB_AVFORMAT;

function av_demuxer_open(ic: PAVFormatContext; ap: TAVFormatParameters): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Allocate an AVFormatContext.
 * Can be freed with av_free() but do not forget to free everything you
 * explicitly allocated as well!
 *)
function avformat_alloc_context(): PAVFormatContext;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_ALLOC_OUTPUT_CONTEXT}
(**
 * @deprecated deprecated in favor of avformat_alloc_output_context2()
 *)
function avformat_alloc_output_context(const format: PAnsiChar;
                                       oformat: PAVOutputFormat;
                                       const filename: PAnsiChar): PAVFormatContext;
  cdecl; external LIB_AVFORMAT; deprecated 'deprecated in favor of avformat_alloc_output_context2()';
{$IFEND}

(**
 * Allocate an AVFormatContext for an output format.
 * avformat_free_context() can be used to free the context and
 * everything allocated by the framework within it.
 *
 * @param *ctx is set to the created format context, or to NULL in
 * case of failure
 * @param oformat format to use for allocating the context, if NULL
 * format_name and filename are used instead
 * @param format_name the name of output format to use for allocating the
 * context, if NULL filename is used instead
 * @param filename the name of the filename to use for allocating the
 * context, may be NULL
 * @return >= 0 in case of success, a negative AVERROR code in case of
 * failure
 *)
function avformat_alloc_output_context2(ctx: PPAVFormatContext; oformat: PAVOutputFormat;
        const format_name: PAnsiChar; const filename: PAnsiChar): cint;
  cdecl; external LIB_AVFORMAT;


{$IF FF_API_FORMAT_PARAMETERS}
  (**
   * Read packets of a media file to get stream information. This
   * is useful for file formats with no headers such as MPEG. This
   * function also computes the real framerate in case of MPEG-2 repeat
   * frame mode.
   * The logical file position is not changed by this function;
   * examined packets may be buffered for later processing.
   *
   * @param ic media file handle
   * @return >=0 if OK, AVERROR_xxx on error
   * @todo Let the user decide somehow what information is needed so that
   *       we do not waste time getting stuff the user does not need.
   *
   * @deprecated use avformat_find_stream_info.
   *)
  function av_find_stream_info(ic: PAVFormatContext): cint;
    cdecl; external LIB_AVFORMAT; deprecated 'use avformat_find_stream_info';
{$IFEND}

(**
 * Read packets of a media file to get stream information. This
 * is useful for file formats with no headers such as MPEG. This
 * function also computes the real framerate in case of MPEG-2 repeat
 * frame mode.
 * The logical file position is not changed by this function;
 * examined packets may be buffered for later processing.
 *
 * @param ic media file handle
 * @param options  If non-NULL, an ic.nb_streams long array of pointers to
 *                 dictionaries, where i-th member contains options for
 *                 codec corresponding to i-th stream.
 *                 On return each dictionary will be filled with options that were not found.
 * @return >=0 if OK, AVERROR_xxx on error
 *
 * @note this function isn't guaranteed to open all the codecs, so
 *       options being non-empty at return is a perfectly normal behavior.
 *
 * @todo Let the user decide somehow what information is needed so that
 *       we do not waste time getting stuff the user does not need.
 *)
function avformat_find_stream_info(ic: PAVFormatContext; options: PPAVDictionary): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Find the "best" stream in the file.
 * The best stream is determined according to various heuristics as the most
 * likely to be what the user expects.
 * If the decoder parameter is non-NULL, av_find_best_stream will find the
 * default decoder for the stream's codec; streams for which no decoder can
 * be found are ignored.
 *
 * @param ic                media file handle
 * @param type              stream type: video, audio, subtitles, etc.
 * @param wanted_stream_nb  user-requested stream number,
 *                          or -1 for automatic selection
 * @param related_stream    try to find a stream related (eg. in the same
 *                          program) to this one, or -1 if none
 * @param decoder_ret       if non-NULL, returns the decoder for the
 *                          selected stream
 * @param flags             flags; none are currently defined
 * @return  the non-negative stream number in case of success,
 *          AVERROR_STREAM_NOT_FOUND if no stream with the requested type
 *          could be found,
 *          AVERROR_DECODER_NOT_FOUND if streams were found but no decoder
 * @note  If av_find_best_stream returns successfully and decoder_ret is not
 *        NULL, then *decoder_ret is guaranteed to be set to a valid AVCodec.
 *)
function av_find_best_stream(ic: PAVFormatContext;
                        type_: TAVMediaType;
                        wanted_stream_nb: cint;
                        related_stream: cint;
                        decoder_ret: PPAVCodec;
                        flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Read a transport packet from a media file.
 *
 * This function is obsolete and should never be used.
 * Use av_read_frame() instead.
 *
 * @param s media file handle
 * @param pkt is filled
 * @return 0 if OK, AVERROR_xxx on error
 *)
function av_read_packet(s: PAVFormatContext; var pkt: TAVPacket): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Return the next frame of a stream.
 *
 * The returned packet is valid
 * until the next av_read_frame() or until av_close_input_file() and
 * must be freed with av_free_packet. For video, the packet contains
 * exactly one frame. For audio, it contains an cint number of
 * frames if each frame has a known fixed size (e.g. PCM or ADPCM
 * data). If the audio frames have a variable size (e.g. MPEG audio),
 * then it contains one frame.
 *
 * pkt->pts, pkt->dts and pkt->duration are always set to correct
 * values in AVStream.time_base units (and guessed if the format cannot
 * provide them). pkt->pts can be AV_NOPTS_VALUE if the video format
 * has B-frames, so it is better to rely on pkt->dts if you do not
 * decompress the payload.
 *
 * @return 0 if OK, < 0 on error or end of file
 *)
function av_read_frame(s: PAVFormatContext; var pkt: TAVPacket): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Seek to the keyframe at timestamp.
 * 'timestamp' in 'stream_index'.
 * @param stream_index If stream_index is (-1), a default
 * stream is selected, and timestamp is automatically converted
 * from AV_TIME_BASE units to the stream specific time_base.
 * @param timestamp Timestamp in AVStream.time_base units
 *        or, if no stream is specified, in AV_TIME_BASE units.
 * @param flags flags which select direction and seeking mode
 * @return >= 0 on success
 *)
function av_seek_frame(s: PAVFormatContext; stream_index: cint; timestamp: cint64;
                       flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Seek to timestamp ts.
 * Seeking will be done so that the point from which all active streams
 * can be presented successfully will be closest to ts and within min/max_ts.
 * Active streams are all streams that have AVStream.discard < AVDISCARD_ALL.
 *
 * If flags contain AVSEEK_FLAG_BYTE, then all timestamps are in byte and
 * are the file position (this may not be supported by all demuxers).
 * If flags contain AVSEEK_FLAG_FRAME then all timestamps are in frames
 * in the stream with stream_index (this may not be supported by all demuxers).
 * Otherwise all timestamps are in units of the stream selected by stream_index
 * or if stream_index is -1, in AV_TIME_BASE units.
 * If flags contain AVSEEK_FLAG_ANY, then non-keyframes are treated as
 * keyframes (this may not be supported by all demuxers).
 *
 * @param stream_index index of the stream which is used as time base reference.
 * @param min_ts smallest acceptable timestamp
 * @param ts target timestamp
 * @param max_ts largest acceptable timestamp
 * @param flags flags
 * @return >=0 on success, error code otherwise
 *
 * @note This is part of the new seek API which is still under construction.
 *       Thus do not use this yet. It may change at any time, do not expect
 *       ABI compatibility yet!
 *)
function avformat_seek_file(s: PAVFormatContext; stream_index: cint; min_ts: cint64; ts: cint64;
                            max_ts: cint64; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Start playing a network-based stream (e.g. RTSP stream) at the
 * current position.
 *)
function av_read_play(s: PAVFormatContext): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Pause a network-based stream (e.g. RTSP stream).
 *
 * Use av_read_play() to resume it.
 *)
function av_read_pause(s: PAVFormatContext): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Free a AVFormatContext allocated by av_open_input_stream.
 * @param s context to free
 *)
procedure av_close_input_stream(s: PAVFormatContext);
  cdecl; external LIB_AVFORMAT;


(**
 * Close a media file (but not its codecs).
 *
 * @param s media file handle
 *)
procedure av_close_input_file(s: PAVFormatContext);
  cdecl; external LIB_AVFORMAT;

(**
 * Free an AVFormatContext and all its streams.
 * @param s context to free
 *)
procedure avformat_free_context(s: PAVFormatContext);
  cdecl; external LIB_AVFORMAT;

(**
 * Add a new stream to a media file.
 *
 * Can only be called in the read_header() function. If the flag
 * AVFMTCTX_NOHEADER is in the format context, then new streams
 * can be added in read_packet too.
 *
 * @param s media file handle
 * @param id file-format-dependent stream ID
 *)
function av_new_stream(s: PAVFormatContext; id: cint): PAVStream;
  cdecl; external LIB_AVFORMAT;

function av_new_program(s: PAVFormatContext; id: cint): PAVProgram;
  cdecl; external LIB_AVFORMAT;


(**
 * Set the pts for a given stream. If the new values would be invalid
 * (<= 0), it leaves the AVStream unchanged.
 *
 * @param s stream
 * @param pts_wrap_bits number of bits effectively used by the pts
 *        (used for wrap control, 33 is the value for MPEG)
 * @param pts_num numerator to convert to seconds (MPEG: 1)
 * @param pts_den denominator to convert to seconds (MPEG: 90000)
 *)
procedure av_set_pts_info(s: PAVStream; pts_wrap_bits: cint;
                   pts_num: cuint; pts_den: cuint);
  cdecl; external LIB_AVFORMAT;


const
  AVSEEK_FLAG_BACKWARD = 1; ///< seek backward
  AVSEEK_FLAG_BYTE     = 2; ///< seeking based on position in bytes
  AVSEEK_FLAG_ANY      = 4; ///< seek to any frame, even non-keyframes
  AVSEEK_FLAG_FRAME    = 8;

function av_find_default_stream_index(s: PAVFormatContext): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Get the index for a specific timestamp.
 * @param flags if AVSEEK_FLAG_BACKWARD then the returned index will correspond
 *                 to the timestamp which is <= the requested one, if backward
 *                 is 0, then it will be >=
 *              if AVSEEK_FLAG_ANY seek to any frame, only keyframes otherwise
 * @return < 0 if no such timestamp could be found
 *)
function av_index_search_timestamp(st: PAVStream; timestamp: cint64; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Add an index entry into a sorted list. Update the entry if the list
 * already contains it.
 *
 * @param timestamp timestamp in the timebase of the given stream
 *)
function av_add_index_entry(st: PAVStream; pos: cint64; timestamp: cint64;
                  size: cint; distance: cint; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;







(**
 * Perform a binary search using av_index_search_timestamp() and
 * AVInputFormat.read_timestamp().
 * This is not supposed to be called directly by a user application,
 * but by demuxers.
 * @param target_ts target timestamp in the time base of the given stream
 * @param stream_index stream number
 *)
function av_seek_frame_binary(s: PAVFormatContext; stream_index: cint;
                 target_ts: cint64; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Update cur_dts of all streams based on the given timestamp and AVStream.
 *
 * Stream ref_st unchanged, others set cur_dts in their native time base.
 * Only needed for timestamp wrapping or if (dts not set and pts!=dts).
 * @param timestamp new dts expressed in time_base of param ref_st
 * @param ref_st reference stream giving time_base of param timestamp
 *)
procedure av_update_cur_dts(s: PAVFormatContext; ref_st: PAVStream;
                            timestamp: cint64);
  cdecl; external LIB_AVFORMAT;

(**
 * Perform a binary search using read_timestamp().
 * This is not supposed to be called directly by a user application,
 * but by demuxers.
 * @param target_ts target timestamp in the time base of the given stream
 * @param stream_index stream number
 *)
type
  TReadTimestampFunc = function (pavfc: PAVFormatContext;
    arg2: cint; arg3: Pint64; arg4: cint64): cint64; cdecl;

function av_gen_search(s: PAVFormatContext; stream_index: cint;
                       target_ts: cint64; pos_min: cint64;
                       pos_max: cint64; pos_limit: cint64;
                       ts_min: cint64; ts_max: cint64;
                       flags: cint; ts_ret: Pint64;
                       read_timestamp: TReadTimestampFunc): cint64;
  cdecl; external LIB_AVFORMAT;


{$IF FF_API_FORMAT_PARAMETERS}
  (**
   * @deprecated pass the options to avformat_write_header directly.
   *)
  function av_set_parameters(s: PAVFormatContext; ap: PAVFormatParameters): cint;
    cdecl; external LIB_AVFORMAT; deprecated 'pass the options to avformat_write_header directly';
{$IFEND}

(**
 * Split a URL string into components.
 *
 * The pointers to buffers for storing individual components may be null,
 * in order to ignore that component. Buffers for components not found are
 * set to empty strings. If the port is not found, it is set to a negative
 * value.
 *
 * @param proto the buffer for the protocol
 * @param proto_size the size of the proto buffer
 * @param authorization the buffer for the authorization
 * @param authorization_size the size of the authorization buffer
 * @param hostname the buffer for the host name
 * @param hostname_size the size of the hostname buffer
 * @param port_ptr a pointer to store the port number in
 * @param path the buffer for the path
 * @param path_size the size of the path buffer
 * @param url the URL to split
 *)
procedure av_url_split(proto: PAnsiChar; proto_size: cint;
                       authorization: PAnsiChar; authorization_size: cint;
                       hostname: PAnsiChar; hostname_size: cint;
                       port_ptr: Pcint;
                       path: PAnsiChar; path_size: cint;
                       const url: PAnsiChar);
  cdecl; external LIB_AVFORMAT;


(**
 * Allocate the stream private data and write the stream header to
 * an output media file.
 *
 * @param s Media file handle, must be allocated with avformat_alloc_context().
 *          Its oformat field must be set to the desired output format;
 *          Its pb field must be set to an already openened AVIOContext.
 * @param options  An AVDictionary filled with AVFormatContext and muxer-private options.
 *                 On return this parameter will be destroyed and replaced with a dict containing
 *                 options that were not found. May be NULL.
 *
 * @return 0 on success, negative AVERROR on failure.
 *
 * @see av_opt_find, av_dict_set, avio_open, av_oformat_next.
 *)
function avformat_write_header(s: PAVFormatContext; options: PPAVDictionary): cint;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_FORMAT_PARAMETERS}
(**
 * Allocate the stream private data and write the stream header to an
 * output media file.
 * @note: this sets stream time-bases, if possible to stream->codec->time_base
 * but for some formats it might also be some other time base
 *
 * @param s media file handle
 * @return 0 if OK, AVERROR_xxx on error
 *
 * @deprecated use avformat_write_header.
 *)
function av_write_header(s: PAVFormatContext): cint;
  cdecl; external LIB_AVFORMAT; deprecated 'use avformat_write_header';
{$IFEND}

(**
 * Write a packet to an output media file.
 *
 * The packet shall contain one audio or video frame.
 * The packet must be correctly interleaved according to the container
 * specification, if not then av_interleaved_write_frame must be used.
 *
 * @param s media file handle
 * @param pkt The packet, which contains the stream_index, buf/buf_size,
 *            dts/pts, ...
 * @return < 0 on error, = 0 if OK, 1 if end of stream wanted
 *)
function av_write_frame(s: PAVFormatContext;  pkt: PAVPacket): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Write a packet to an output media file ensuring correct interleaving.
 *
 * The packet must contain one audio or video frame.
 * If the packets are already correctly interleaved, the application should
 * call av_write_frame() instead as it is slightly faster. It is also important
 * to keep in mind that completely non-interleaved input will need huge amounts
 * of memory to interleave with this, so it is preferable to interleave at the
 * demuxer level.
 *
 * @param s media file handle
 * @param pkt The packet, which contains the stream_index, buf/buf_size,
 *            dts/pts, ...
 * @return < 0 on error, = 0 if OK, 1 if end of stream wanted
 *)
function av_interleaved_write_frame(s: PAVFormatContext; pkt: PAVPacket): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Interleave a packet per dts in an output media file.
 *
 * Packets with pkt->destruct == av_destruct_packet will be freed inside this
 * function, so they cannot be used after it. Note that calling av_free_packet()
 * on them is still safe.
 *
 * @param s media file handle
 * @param out the interleaved packet will be output here
 * @param pkt the input packet
 * @param flush 1 if no further packets are available as input and all
 *              remaining packets should be output
 * @return 1 if a packet was output, 0 if no packet could be output,
 *         < 0 if an error occurred
 *)
function av_interleave_packet_per_dts(s: PAVFormatContext; _out: PAVPacket;
                                      pkt: PAVPacket; flush: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Write the stream trailer to an output media file and free the
 * file private data.
 *
 * May only be called after a successful call to av_write_header.
 *
 * @param s media file handle
 * @return 0 if OK, AVERROR_xxx on error
 *)
function av_write_trailer(s: PAVFormatContext): cint;
  cdecl; external LIB_AVFORMAT;


(**
 * Get timing information for the data currently output.
 * The exact meaning of "currently output" depends on the format.
 * It is mostly relevant for devices that have an internal buffer and/or
 * work in real time.
 * @param s          media file handle
 * @param stream     stream in the media file
 * @param dts[out]   DTS of the last packet output for the stream, in stream
 *                   time_base units
 * @param wall[out]  absolute time when that packet whas output,
 *                   in microsecond
 * @return  0 if OK, AVERROR(ENOSYS) if the format does not support it
 * Note: some formats or devices may not allow to measure dts and wall
 * atomically.
 *)
function av_get_output_timestamp(s: PAVFormatContext; stream: cint;
        dts: Pcint64; wall: Pcint64): cint;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_DUMP_FORMAT}
  (**
   * @deprecated Deprecated in favor of av_dump_format().
   *)
  procedure dump_format(ic: PAVFormatContext; index: cint; url: PAnsiChar;
                 is_output: cint);
    cdecl; external LIB_AVFORMAT; deprecated 'Deprecated in favor of av_dump_format()';
{$IFEND}

procedure av_dump_format(ic: PAVFormatContext; index: cint; const url: PAnsiChar;
               is_output: cint);
  cdecl; external LIB_AVFORMAT;

{$IFDEF FF_API_PARSE_DATE}
(**
 * Parse datestr and return a corresponding number of microseconds.
 *
 * @param datestr String representing a date or a duration.
 * See av_parse_time() for the syntax of the provided string.
 * @deprecated in favor of av_parse_time()
 *)
function parse_date(const datestr: PAnsiChar; duration: cint): cint64;
  cdecl; external LIB_AVFORMAT; deprecated 'in favor of av_parse_time()';
{$ENDIF}


(**
 * t in us.
 *)
procedure break_time(t: cint64; hours: pcint; mins: pcint; secs: pcint; us: pcint);
  cdecl; external LIB_AVFORMAT;

(**
 * Get the current time in microseconds.
 *)
function av_gettime(): cint64;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_FIND_INFO_TAG}
  (**
   * @deprecated use av_find_info_tag in libavutil instead.
   *)
  function find_info_tag(arg: PAnsiChar; arg_size: cint; tag1: PAnsiChar; info: PAnsiChar): cint;
    cdecl; external LIB_AVFORMAT; deprecated 'use av_find_info_tag in libavutil instead.';
{$IFEND}

(**
 * Return in 'buf' the path with '%d' replaced by a number.
 *
 * Also handles the '%0nd' format where 'n' is the total number
 * of digits and '%%'.
 *
 * @param buf destination buffer
 * @param buf_size destination buffer size
 * @param path numbered sequence string
 * @param number frame number
 * @return 0 if OK, -1 on format error
 *)
function av_get_frame_filename(buf: PAnsiChar; buf_size: cint;
                               const path: PAnsiChar; number: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Check whether filename actually is a numbered sequence generator.
 *
 * @param filename possible numbered sequence string
 * @return 1 if a valid numbered sequence string, 0 otherwise
 *)
function av_filename_number_test(filename: PAnsiChar): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Generate an SDP for an RTP session.
 *
 * @param ac array of AVFormatContexts describing the RTP streams. If the
 *           array is composed by only one context, such context can contain
 *           multiple AVStreams (one AVStream per RTP stream). Otherwise,
 *           all the contexts in the array (an AVCodecContext per RTP stream)
 *           must contain only one AVStream.
 * @param n_files number of AVCodecContexts contained in ac
 * @param buf buffer where the SDP will be stored (must be allocated by
 *            the caller)
 * @param size the size of the buffer
 * @return 0 if OK, AVERROR_xxx on error
 *)
function av_sdp_create(ac: PPAVFormatContext; n_files: cint; buf: PAnsiChar; size: cint): cint;
  cdecl; external LIB_AVFORMAT;

{$IF FF_API_SDP_CREATE}
  function avf_sdp_create(ac: PPAVFormatContext; n_files: cint; buff: PByteArray; size: cint): cint;
    cdecl; external LIB_AVFORMAT; deprecated;
{$IFEND}

(**
 * Return a positive value if the given filename has one of the given
 * extensions, 0 otherwise.
 *
 * @param extensions a comma-separated list of filename extensions
 *)
function av_match_ext(const filename: PAnsichar; const extensions: PAnsichar): cint;
  cdecl; external LIB_AVFORMAT;


implementation

end.

