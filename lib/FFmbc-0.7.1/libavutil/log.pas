(*
 * copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
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
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/imgutils.h
 * avutil version 51.11.0
 *)
 
 
{$IfNDef AVUTIL_LOG_H}
	{$Define AVUTIL_LOG_H}

type
(**
 * Describe the class of an AVClass context structure. That is an
 * arbitrary struct of which the first field is a pointer to an
 * AVClass struct (e.g. AVCodecContext, AVFormatContext etc.).
 *)
  PAVClass = ^TAVClass;
  TAVClass = record
    (**
     * The name of the class; usually it is the same name as the
     * context structure type to which the AVClass is associated.
     *)
    class_name: PAnsiChar;

    (**
     * A pointer to a function which returns the name of a context
     * instance ctx associated with the class.
     *)
    item_name: function(ctx: pointer): PAnsiChar; cdecl;

    (**
     * a pointer to the first option specified in the class if any or NULL
     *
     * @see av_set_default_options()
     *)
    option: PAVOption;

    (**
     * LIBAVUTIL_VERSION with which this structure was created.
     * This is used to allow fields to be added without requiring major
     * version bumps everywhere.
     *)
    version: cint;

    (**
     * Offset in the structure where log_level_offset is stored.
     * 0 means there is no such variable
     *)
    log_level_offset_offset: cint;

    (**
     * Offset in the structure where a pointer to the parent context for
     * logging is stored. For example a decoder could pass its AVCodecContext
     * to eval as such a parent context, which an av_log() implementation
     * could then leverage to display the parent context.
     * The offset can be NULL.
     *)
    parent_log_context_offset: cint;
    
    {**
     * A function for extended searching, e.g. in possible
     * children objects.
     *}
    opt_find: function(obj: Pointer; const name: PAnsiChar; const unit_: PAnsiChar; opt_flags: cint; search_flags: cint): PAVOption; cdecl;
end;

const
  AV_LOG_QUIET   = -8;

(**
 * Something went really wrong and we will crash now.
 *)
  AV_LOG_PANIC   =  0;

(**
 * Something went wrong and recovery is not possible.
 * For example, no header was found for a format which depends
 * on headers or an illegal combination of parameters is used.
 *)
  AV_LOG_FATAL   =  8;

(**
 * Something went wrong and cannot losslessly be recovered.
 * However, not all future data is affected.
 *)
  AV_LOG_ERROR   = 16;

(**
 * Something somehow does not look correct. This may or may not
 * lead to problems. An example would be the use of '-vstrict -2'.
 *)
  AV_LOG_WARNING = 24;

  AV_LOG_INFO    = 32;
  AV_LOG_VERBOSE = 40;

(**
 * Stuff which is only useful for libav* developers.
 *)
  AV_LOG_DEBUG   = 48;


(**
 * Send the specified message to the log if the level is less than or equal
 * to the current av_log_level. By default, all logging messages are sent to
 * stderr. This behavior can be altered by setting a different av_vlog callback
 * function.
 *
 * @param avcl A pointer to an arbitrary struct of which the first field is a
 * pointer to an AVClass struct.
 * @param level The importance level of the message, lower values signifying
 * higher importance.
 * @param fmt The format string (printf-compatible) that specifies how
 * subsequent arguments are converted to output.
 * @see av_vlog
 *)

type
  va_list = array[0..$FFFF] of pointer;
  TAVLOGCallback = procedure (ptr: pointer; level: cint; const fmt: PAnsiChar; const vl: va_list) of object;
  pAVLOGCallback = ^TAVLOGCallback;

procedure av_vlog(avcl: pointer; level: cint; const fmt: PAnsiChar; const vl: va_list);
  cdecl; external LIB_AVUTIL;

function av_log_get_level(): cint;
  cdecl; external LIB_AVUTIL;

procedure av_log_set_level(level: cint);
  cdecl; external LIB_AVUTIL;

{** to be translated if needed
void av_log_set_callback(void (*)(void*, int, const char*, va_list));
procedure av_log_set_callback(: TAVLOGCallback;
  cdecl; external av__util;
**}
procedure av_log_set_callback(avcl: Pointer);
  cdecl; external LIB_AVUTIL;

procedure av_log_default_callback(ptr: pointer; level: cint; const fmt: PAnsiChar; const vl: va_list);
  cdecl; external LIB_AVUTIL;

function av_default_item_name (ctx: pointer): PAnsiChar;
  cdecl; external LIB_AVUTIL;


(**
 * av_dlog macros
 * Useful to print debug messages that shouldn't get compiled in normally.
 *)
(** to be translated if needed
#ifdef DEBUG
#    define av_dlog(pctx, ...) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__)
#else
#    define av_dlog(pctx, ...) do { if (0) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__); } while (0)
#endif
**)

(**
 * Skip repeated messages, this requires the user app to use av_log() instead of
 * (f)printf as the 2 would otherwise interfere and lead to
 * "Last message repeated x times" messages below (f)printf messages with some
 * bad luck.
 * Also to receive the last, "last repeated" line if any, the user app must
 * call av_log(NULL, AV_LOG_QUIET, "%s", ""); at the end
 *)
const
  AV_LOG_SKIP_REPEATED = 1;

procedure av_log_set_flags(arg: cint);
  cdecl; external LIB_AVUTIL;
  
(**
 * Send a nice hexadecimal dump of a buffer to the specified file stream.
 *
 * @param f The file stream pointer where the dump should be sent to.
 * @param buf buffer
 * @param size buffer size
 *
 * @see av_hex_dump_log, av_pkt_dump, av_pkt_dump_log
 *)
type
  pFile = ^FILE;

procedure av_hex_dump(f : pFile; const buf: pcuint8; size: cint);
  cdecl; external LIB_AVUTIL;
(**
 * Send a nice hexadecimal dump of a buffer to the log.
 *
 * @param avcl A pointer to an arbitrary struct of which the first field is a
 * pointer to an AVClass struct.
 * @param level The importance level of the message, lower values signifying
 * higher importance.
 * @param buf buffer
 * @param size buffer size
 *
 * @see av_hex_dump, av_pkt_dump, av_pkt_dump_log
 *)
procedure av_hex_dump_log(avcl: pointer; level: cint; const buf: pcuint8; size: cint);
  cdecl; external LIB_AVUTIL;
  
{$EndIf} (* AVUTIL_LOG_H *)
