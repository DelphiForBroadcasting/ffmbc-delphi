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
 *
 *
 *
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavformat/avio.h
 * avutil version 51.11.0
 *
 *)
 
(**
 * @file
 * Buffered I/O operations
 *)

unit avio;

{$MINENUMSIZE 4} 
{$LEGACYIFEND ON}
{$Define AVFORMAT_AVIO_H}

interface

uses
  SysUtils,
  ctypes,
  avutil;

const
  AVIO_SEEKABLE_NORMAL = 0001; (**< Seeking works like for a local file *)

type
  TReadWriteFunc = function(opaque: Pointer; buf: pcuint8; buf_size: cint): cint; cdecl;
  TSeekFunc = function(opaque: Pointer; offset: cint64; whence: cint): cint64; cdecl;

type
(**
 * Bytestream IO Context.
 * New fields can be added to the end with minor version bumps.
 * Removal, reordering and changes to existing fields require a major
 * version bump.
 * sizeof(AVIOContext) must not be used outside libav*.
 *
 * @note None of the function pointers in AVIOContext should be called
 *       directly, they should only be set by the client application
 *       when implementing custom I/O. Normally these are set to the
 *       function pointers specified in avio_alloc_context()
 *)
  PPAVIOContext = ^PAVIOContext;
  PAVIOContext = ^TAVIOContext;
  TAVIOContext = record
    buffer: PByteArray;  (**< Start of the buffer. *)
    buffer_size: cint;   (**< Maximum buffer size *)
    buf_ptr: PByteArray; (**< Current position in the buffer *)
    buf_end: PByteArray; (**< End of the data, may be less than
                              buffer+buffer_size if the read function returned
                              less data than requested, e.g. for streams where
                              no more data has been received yet. *)
    opaque: pointer;     (**< A private pointer, passed to the read/write/seek/...
                              functions. *)
    read_packet: TReadWriteFunc;
    write_packet: TReadWriteFunc;
    seek: TSeekFunc;
    pos: cint64;         (**< position in the file of the current buffer *)
    eof_reached: cint;   (**< true if eof reached *)
    write_flag: cint;    (**< true if open for writing *)
	{$IF FF_API_OLD_AVIO} 
		is_streamed: cint; deprecated 'not use';
	{$IFEND}  
    max_packet_size: cint;
    checksum: culong;
    checksum_ptr: PByteArray;
    update_checksum: function (checksum: culong; const buf: pcuint8; size: cuint): culong; cdecl;
    error: cint;         (**< contains the error code or 0 if no error happened *)
    (**
     * Pause or resume playback for network streaming protocols - e.g. MMS.
     *)
    read_pause: function(opaque: Pointer; pause: cint): cint; cdecl;
    (**
     * Seek to a given timestamp in stream with the specified stream_index.
     * Needed for some network streaming protocols which don't support seeking
     * to byte position.
     *)
    read_seek: function(opaque: Pointer; stream_index: cint;
                        timestamp: cint64; flags: cint): cint64; cdecl;
    (**
     * A combination of AVIO_SEEKABLE_ flags or 0 when the stream is not seekable.
     *)
    seekable: cint;
	max_buf_ptr : PByteArray;
  end;

(* unbuffered I/O *)

{$IF FF_API_OLD_AVIO} 

{$IFEND} // FF_API_OLD_AVIO 

(**
 * Return AVIO_FLAG_* access flags corresponding to the access permissions
 * of the resource in url, or a negative value corresponding to an
 * AVERROR code in case of failure. The returned access flags are
 * masked by the value in flags.
 *
 * @note This function is intrinsically unsafe, in the sense that the
 * checked resource may change its existence or permission status from
 * one call to another. Thus you should not trust the returned value,
 * unless you are sure that no other processes are accessing the
 * checked resource.
 *)
function avio_check(const url: PAnsiChar; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * The callback is called in blocking functions to test regulary if
 * asynchronous interruption is needed. AVERROR_EXIT is returned
 * in this case by the interrupted function. 'NULL' means no interrupt
 * callback is given.
 *)  
procedure avio_set_interrupt_cb(interrupt_cb: Pointer);
  cdecl; external LIB_AVFORMAT;

(**
 * Allocate and initialize an AVIOContext for buffered I/O. It must be later
 * freed with av_free().
 *
 * @param buffer Memory block for input/output operations via AVIOContext.
 *        The buffer must be allocated with av_malloc() and friends.
 * @param buffer_size The buffer size is very important for performance.
 *        For protocols with fixed blocksize it should be set to this blocksize.
 *        For others a typical size is a cache page, e.g. 4kb.
 * @param write_flag Set to 1 if the buffer should be writable, 0 otherwise.
 * @param opaque An opaque pointer to user-specific data.
 * @param read_packet  A function for refilling the buffer, may be NULL.
 * @param write_packet A function for writing the buffer contents, may be NULL.
 *        The function may not change the input buffers content.
 * @param seek A function for seeking to specified byte position, may be NULL.
 *
 * @return Allocated AVIOContext or NULL on failure.
 *)
function avio_alloc_context(
                  buffer: PByteArray;
                  buffer_size: cint;
                  write_flag: cint;
                  opaque: Pointer;
                  read_packet: TReadWriteFunc;
                  write_packet: TReadWriteFunc;
                  seek: TSeekFunc): PAVIOContext;
  cdecl; external LIB_AVFORMAT;
		  
procedure avio_w8(s: PAVIOContext; b: cint); cdecl; external LIB_AVFORMAT;
procedure avio_write(s: PAVIOContext; const buf: PByteArray; size: cint); cdecl; external LIB_AVFORMAT;
procedure avio_wl64(s: PAVIOContext; val: cuint64); cdecl; external LIB_AVFORMAT;
procedure avio_wb64(s: PAVIOContext; val: cuint64); cdecl; external LIB_AVFORMAT;
procedure avio_wl32(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;
procedure avio_wb32(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;
procedure avio_wl24(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;
procedure avio_wb24(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;
procedure avio_wl16(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;
procedure avio_wb16(s: PAVIOContext; val: cuint); cdecl; external LIB_AVFORMAT;

(**
 * Write a NULL-terminated string.
 * @return number of bytes written.
 *)
function avio_put_str(s: PAVIOContext; const str: PAnsiChar): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Write 'count' bytes with the value 'val'
 *)
procedure avio_fill(s: PAVIOContext; val : cint; count: cint);
  cdecl; external LIB_AVFORMAT;

(**
 * Write a NULL-terminated string without the ending 0.
 *)
procedure avio_wtag(s: PAVIOContext; const str: PAnsiChar);
  cdecl; external LIB_AVFORMAT;
  
(**
 * Convert an UTF-8 string to UTF-16LE and write it.
 * @return number of bytes written.
 *)
function avio_put_str16le(s: PAVIOContext; const str: PAnsiChar): cint;
  cdecl; external LIB_AVFORMAT;

const
 (**
  * Passing this as the "whence" parameter to a seek function causes it to
  * return the filesize without seeking anywhere. Supporting this is optional.
  * If it is not supported then the seek function will return <0.
  *)
  AVSEEK_SIZE = $10000;

 (**
  * Oring this flag as into the "whence" parameter to a seek function causes it to
  * seek by any means (like reopening and linear reading) or other normally unreasonble
  * means that can be extreemly slow.
  * This may be ignored by the seek code.
  *)
  AVSEEK_FORCE = $20000;

(**
 * fseek() equivalent for AVIOContext.
 * @return new position or AVERROR.
 *)
function avio_seek(s: PAVIOContext; offset: cint64; whence: cint): cint64;
  cdecl; external LIB_AVFORMAT;

(**
 * Skip given number of bytes forward
 * @return new position or AVERROR.
 *)
function avio_skip(s: PAVIOContext; offset: cint64): cint64;
  cdecl; external LIB_AVFORMAT;

(**
 * ftell() equivalent for AVIOContext.
 * @return position or AVERROR.
 *)
function avio_tell(s: PAVIOContext): cint64; inline;

(**
 * Get the filesize.
 * @return filesize or AVERROR
 *)
function avio_size(s: PAVIOContext): cint64;
  cdecl; external LIB_AVFORMAT;

(**
 * feof() equivalent for AVIOContext.
 * @return non zero if and only if end of file
 *)
function url_feof(s: PAVIOContext): cint;
  cdecl; external LIB_AVFORMAT;
  
(** @warning currently size is limited *)
function avio_printf(s: PAVIOContext; const fmt: PAnsiChar; args: array of const): cint;
  cdecl; external LIB_AVFORMAT;

procedure avio_flush(s: PAVIOContext);
  cdecl; external LIB_AVFORMAT;

(**
 * Read size bytes from AVIOContext into buf.
 * @return number of bytes read or AVERROR
 *)
function avio_read(s: PAVIOContext; buf: PbyteArray; size: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * @name Functions for reading from AVIOContext
 * @
 *
 * @note return 0 if EOF, so you cannot use it if EOF handling is
 *       necessary
 *)
function avio_r8(s: PAVIOContext): cint; cdecl; external LIB_AVFORMAT;
function avio_rl16(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rl24(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rl32(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rl64(s: PAVIOContext): cuint64; cdecl; external LIB_AVFORMAT;
function avio_rb16(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rb24(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rb32(s: PAVIOContext): cuint; cdecl; external LIB_AVFORMAT;
function avio_rb64(s: PAVIOContext): cuint64; cdecl; external LIB_AVFORMAT;

(**
 * @
 *)
(**
 * Read a string from pb into buf. The reading will terminate when either
 * a NULL character was encountered, maxlen bytes have been read, or nothing
 * more can be read from pb. The result is guaranteed to be NULL-terminated, it
 * will be truncated if buf is too small.
 * Note that the string is not interpreted or validated in any way, it
 * might get truncated in the middle of a sequence for multi-byte encodings.
 *
 * @return number of bytes read (is always <= maxlen).
 * If reading ends on EOF or error, the return value will be one more than
 * bytes actually read.
 *)
function avio_get_str(pb: PAVIOContext; maxlen: cint; buf: PAnsiChar; buflen: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Read a UTF-16 string from pb and convert it to UTF-8.
 * The reading will terminate when either a null or invalid character was
 * encountered or maxlen bytes have been read.
 * @return number of bytes read (is always <= maxlen)
 *)
function avio_get_str16le(pb: PAVIOContext; maxlen: cint; buf: PAnsiChar; buflen: cint): cint;
  cdecl; external LIB_AVFORMAT;
function avio_get_str16be(pb: PAVIOContext; maxlen: cint; buf: PAnsiChar; buflen: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * @name URL open modes
 * The flags argument to avio_open must be one of the following
 * constants, optionally ORed with other flags.
 * @{
 *)
const
  AVIO_FLAG_READ  = 1;                                      (**< read-only *)
  AVIO_FLAG_WRITE = 2;                                      (**< write-only *)
  AVIO_FLAG_READ_WRITE = (AVIO_FLAG_READ or AVIO_FLAG_WRITE);  (**< read-write pseudo flag *)
(**
 * @
 *)

const
(**
 * Use non-blocking mode.
 * If this flag is set, operations on the context will return
 * AVERROR(EAGAIN) if they can not be performed immediately.
 * If this flag is not set, operations on the context will never return
 * AVERROR(EAGAIN).
 * Note that this flag does not affect the opening/connecting of the
 * context. Connecting a protocol will always block if necessary (e.g. on
 * network protocols) but never hang (e.g. on busy devices).
 * Warning:  non-blocking protocols is work-in-progress; this flag may be
 * silently ignored.
 *)
  AVIO_FLAG_NONBLOCK = 8;    


(**
 * Create and initialize a AVIOContext for accessing the
 * resource indicated by url.
 * @note When the resource indicated by url has been opened in
 * read+write mode, the AVIOContext can be used only for writing.
 *
 * @param s Used to return the pointer to the created AVIOContext.
 * In case of failure the pointed to value is set to NULL.
 * @param flags flags which control how the resource indicated by url
 * is to be opened
 * @return 0 in case of success, a negative value corresponding to an
 * AVERROR code in case of failure
 *)
function avio_open(var s: PAVIOContext; const url: PAnsiChar; flags: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Close the resource accessed by the AVIOContext s and free it.
 * This function can only be used if s was opened by avio_open().
 *
 * The internal buffer is automatically flushed before closing the
 * resource.
 *
 * @return 0 on success, an AVERROR < 0 on error.
 * @see avio_close
 *)
function avio_close(s: PAVIOContext): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Open a write only memory stream.
 *
 * @param s new IO context
 * @return zero if no error.
 *)
function avio_open_dyn_buf(var s: PAVIOContext): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Return the written size and a pointer to the buffer. The buffer
 * must be freed with av_free().
 * Padding of FF_INPUT_BUFFER_PADDING_SIZE is added to the buffer.
 *
 * @param s IO context
 * @param pbuffer pointer to a byte buffer
 * @return the length of the byte buffer
 *)
function avio_close_dyn_buf(s: PAVIOContext; var pbuffer: Pcuint8): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Iterate through names of available protocols.
 *
 * @param opaque A private pointer representing current protocol.
 *        It must be a pointer to NULL on first iteration and will
 *        be updated by successive calls to avio_enum_protocols.
 * @param output If set to 1, iterate over output protocols,
 *               otherwise over input protocols.
 *
 * @return A static string containing the name of current protocol or NULL
 *)
function avio_enum_protocols(var opaque: Pointer; output: cint): PAnsiChar;
  cdecl; external LIB_AVFORMAT;

(**
 * Pause and resume playing - only meaningful if using a network streaming
 * protocol (e.g. MMS).
 * @param pause 1 for pause, 0 for resume
 *)
function avio_pause(h: PAVIOContext; pause: cint): cint;
  cdecl; external LIB_AVFORMAT;

(**
 * Seek to a given timestamp relative to some component stream.
 * Only meaningful if using a network streaming protocol (e.g. MMS.).
 * @param stream_index The stream index that the timestamp is relative to.
 *        If stream_index is (-1) the timestamp should be in AV_TIME_BASE
 *        units from the beginning of the presentation.
 *        If a stream_index >= 0 is used and the protocol does not support
 *        seeking based on component streams, the call will fail with ENOTSUP.
 * @param timestamp timestamp in AVStream.time_base units
 *        or if there is no stream specified then in AV_TIME_BASE units.
 * @param flags Optional combination of AVSEEK_FLAG_BACKWARD, AVSEEK_FLAG_BYTE
 *        and AVSEEK_FLAG_ANY. The protocol may silently ignore
 *        AVSEEK_FLAG_BACKWARD and AVSEEK_FLAG_ANY, but AVSEEK_FLAG_BYTE will
 *        fail with ENOTSUP if used and not supported.
 * @return >= 0 on success
 * @see AVInputFormat: : read_seek
 *)
function avio_seek_time(h: PAVIOContext; stream_index: cint; timestamp: cint64; flags: cint): cint64;
  cdecl; external LIB_AVFORMAT;

implementation

{$IF FF_API_OLD_AVIO}
	function url_is_streamed(s: PAVIOContext): cint;
	begin
	  Result := s^.is_streamed;
	end;
{$IFEND}

function avio_tell(s: PAVIOContext): cint64; inline;
const
  SEEK_SET = 0;
  SEEK_CUR = 1;
  SEEK_END = 2;
begin
  Result := avio_seek(s, 0, SEEK_CUR);
end;


end.
