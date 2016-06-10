(*
 * AVOptions
 * copyright (c) 2005 Michael Niedermayer <michaelni@gmx.at>
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
 * Conversion of libavutil/opt.h
 * avutil version 51.11.0
 *
 *
 *)

unit opt;

interface

//{$IfNDef AVUTIL_OPT_H}
	{$Define AVUTIL_OPT_H} 
	
(**
 * @file
 * AVOptions
 *)



uses
  ctypes,
  rational;

(*
 * #include "rational.h"
 * #include "avutil.h"
 * #include "dict.h"
 *)

{$INCLUDE dict.pas}
 
type
  TAVOptionType = (
    FF_OPT_TYPE_FLAGS,
    FF_OPT_TYPE_INT,
    FF_OPT_TYPE_INT64,
    FF_OPT_TYPE_DOUBLE,
    FF_OPT_TYPE_FLOAT,
    FF_OPT_TYPE_STRING,
    FF_OPT_TYPE_RATIONAL,
    FF_OPT_TYPE_BINARY,  ///< offset must point to a pointer immediately followed by an int for the length
    FF_OPT_TYPE_CONST = 128
  );

const
  AV_OPT_FLAG_ENCODING_PARAM  = 1;   ///< a generic parameter which can be set by the user for muxing or encoding
  AV_OPT_FLAG_DECODING_PARAM  = 2;   ///< a generic parameter which can be set by the user for demuxing or decoding
  AV_OPT_FLAG_METADATA        = 4;   ///< some data extracted or inserted into the file like title, comment, ...
  AV_OPT_FLAG_AUDIO_PARAM     = 8;
  AV_OPT_FLAG_VIDEO_PARAM     = 16;
  AV_OPT_FLAG_SUBTITLE_PARAM  = 32;

type
  (**
   * AVOption
   *)
  PAVOption = ^TAVOption;
  TAVOption = record
    name: PAnsiChar;
    
    (**
     * short English help text
     * @todo What about other languages?
     *)
    help: PAnsiChar;

    (**
     * The offset relative to the context structure where the option
     * value is stored. It should be 0 for named constants.
     *)
    offset: cint;
    type_: TAVOptionType;

    (**
     * the default value for scalar options
     *)
    default_val: record
      case cint of
	    0: (dbl: cdouble);
		1: (str: PAnsiChar);
        2: (i64: cint64);       
        (* TODO those are unused now *)
        3: (q: TAVRational);
      end;
    min: cdouble;                ///< minimum valid value for the option
    max: cdouble;                ///< maximum valid value for the option

    flags: cint;
//FIXME think about enc-audio, ... style flags

    (**
     * The logical unit to which the option belongs. Non-constant
     * options and corresponding named constants share the same
     * unit. May be NULL.
     *)
    unit_: PAnsiChar;
  end;

//{$INCLUDE log.pas}

//{$INCLUDE pixfmt.pas}

{$IF FF_API_FIND_OPT}
(**
 * Look for an option in obj. Look only for the options which
 * have the flags set as specified in mask and flags (that is,
 * for which it is the case that opt->flags & mask == flags).
 *
 * @param[in] obj a pointer to a struct whose first element is a
 * pointer to an AVClass
 * @param[in] name the name of the option to look for
 * @param[in] unit the unit of the option to look for, or any if NULL
 * @return a pointer to the option found, or NULL if no option
 * has been found
 *)
function av_find_opt(obj: Pointer; const name: PAnsiChar; const unit_: PAnsiChar; mask: cint; flags: cint): PAVOption;
  cdecl; external LIB_AVUTIL;
{$IFEND}

(**
 * Set the field of obj with the given name to value.
 *
 * @param[in] obj A struct whose first element is a pointer to an
 * AVClass.
 * @param[in] name the name of the field to set
 * @param[in] val The value to set. If the field is not of a string
 * type, then the given string is parsed.
 * SI postfixes and some named scalars are supported.
 * If the field is of a numeric type, it has to be a numeric or named
 * scalar. Behavior with more than one scalar and +- infix operators
 * is undefined.
 * If the field is of a flags type, it has to be a sequence of numeric
 * scalars or named flags separated by '+' or '-'. Prefixing a flag
 * with '+' causes it to be set without affecting the other flags;
 * similarly, '-' unsets a flag.
 * @param[out] o_out if non-NULL put here a pointer to the AVOption
 * found
 * @param alloc when 1 then the old value will be av_freed() and the
 *                     new av_strduped()
 *              when 0 then no av_free() nor av_strdup() will be used
 * @return 0 if the value has been set, or an AVERROR code in case of
 * error:
 * AVERROR(ENOENT) if no matching option exists
 * AVERROR(ERANGE) if the value is out of range
 * AVERROR(EINVAL) if the value is not valid
 *)
function av_set_string3(obj: Pointer; const name: PAnsiChar; const val: PAnsiChar; alloc: cint; var o_out: PAVOption): cint;
  cdecl; external LIB_AVUTIL;

function av_set_double(obj: pointer; const name: PAnsiChar; n: cdouble):     PAVOption;
  cdecl; external LIB_AVUTIL;
function av_set_q     (obj: pointer; const name: PAnsiChar; n: TAVRational): PAVOption;
  cdecl; external LIB_AVUTIL;
function av_set_int   (obj: pointer; const name: PAnsiChar; n: cint64):      PAVOption;
  cdecl; external LIB_AVUTIL;
function av_get_double(obj: pointer; const name: PAnsiChar; var o_out: PAVOption): cdouble;
  cdecl; external LIB_AVUTIL;
function av_get_q     (obj: pointer; const name: PAnsiChar; var o_out: PAVOption): TAVRational;
  cdecl; external LIB_AVUTIL;
function av_get_int   (obj: pointer; const name: PAnsiChar; var o_out: PAVOption): cint64;
  cdecl; external LIB_AVUTIL;
function av_get_string(obj: pointer; const name: PAnsiChar; var o_out: PAVOption; buf: PAnsiChar; buf_len: cint): PAnsiChar;
  cdecl; external LIB_AVUTIL;
function av_next_option(obj: pointer; const last: PAVOption): PAVOption;
  cdecl; external LIB_AVUTIL;
procedure av_opt_list(obj: pointer; av_log_obj: pointer; const unit_: PAnsiChar; req_flags: cint; rej_flags: cint);
  cdecl; external LIB_AVUTIL;
(**
 * Show the obj options.
 *
 * @param req_flags requested flags for the options to show. Show only the
 * options for which it is opt->flags & req_flags.
 * @param rej_flags rejected flags for the options to show. Show only the
 * options for which it is !(opt->flags & req_flags).
 * @param av_log_obj log context to use for showing the options
 *)
function av_opt_show2(obj: pointer; av_log_obj: pointer; req_flags: cint; rej_flags: cint): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Set the values of all AVOption fields to their default values.
 *
 * @param s an AVOption-enabled struct (its first member must be a pointer to AVClass)
 *)
procedure av_opt_set_defaults(s: pointer);
  cdecl; external LIB_AVUTIL;

procedure av_opt_set_defaults2(s: Pointer; mask: cint; flags: cint);
  cdecl; external LIB_AVUTIL;

(**
 * Parse the key/value pairs list in opts. For each key/value pair
 * found, stores the value in the field in ctx that is named like the
 * key. ctx must be an AVClass context, storing is done using
 * AVOptions.
 *
 * @param opts options string to parse, may be NULL
 * @param key_val_sep a 0-terminated list of characters used to
 * separate key from value
 * @param pairs_sep a 0-terminated list of characters used to separate
 * two pairs from each other
 * @return the number of successfully set key/value pairs, or a negative
 * value corresponding to an AVERROR code in case of error:
 * AVERROR(EINVAL) if opts cannot be parsed,
 * the error code issued by av_set_string3() if a key/value pair
 * cannot be set
*)
function av_set_options_string(ctx: pointer; const opts: PAnsiChar;
                      const key_val_sep: PAnsiChar; const pairs_sep: PAnsiChar): cint;
  cdecl; external LIB_AVUTIL;


(**
 * Free all string and binary options in obj.
 *)
procedure av_opt_free(obj: pointer);
  cdecl; external LIB_AVUTIL;

(**
 * Check whether a particular flag is set in a flags field.
 *
 * @param field_name the name of the flag field option
 * @param flag_name the name of the flag to check
 * @return non-zero if the flag is set, zero if the flag isn't set,
 *         isn't of the right type, or the flags field doesn't exist.
 *)
function av_opt_flag_is_set(obj: pointer; const field_name: PAnsiChar; const flag_name: PAnsiChar): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Set all the options from a given dictionary on an object.
 *
 * @param obj a struct whose first element is a pointer to AVClass
 * @param options options to process. This dictionary will be freed and replaced
 *                by a new one containing all options not found in obj.
 *                Of course this new dictionary needs to be freed by caller
 *                with av_dict_free().
 *
 * @return 0 on success, a negative AVERROR if some option was found in obj,
 *         but could not be set.
 *
 * @see av_dict_copy()
 *)
function av_opt_set_dict(obj: pointer; var options: PAVDictionary): cint;
  cdecl; external LIB_AVUTIL;


const
  AV_OPT_SEARCH_CHILDREN = $0001;  (**< Search in possible children of the given object first.*)


(**
 * Look for an option in an object. Consider only options which
 * have all the specified flags set.
 *
 * @param[in] obj A pointer to a struct whose first element is a
 *                pointer to an AVClass.
 * @param[in] name The name of the option to look for.
 * @param[in] unit When searching for named constants, name of the unit
 *                 it belongs to.
 * @param opt_flags Find only options with all the specified flags set (AV_OPT_FLAG).
 * @param search_flags A combination of AV_OPT_SEARCH_*.
 *
 * @return A pointer to the option found, or NULL if no option
 *         was found.
 *
 * @note Options found with AV_OPT_SEARCH_CHILDREN flag may not be settable
 * directly with av_set_string3(). Use special calls which take an options
 * AVDictionary (e.g. avformat_open_input()) to set options found with this
 * flag.
 *)
function av_opt_find(obj: pointer; const name: PAnsiChar; const unit_: PAnsiChar;
                     opt_flags: cint; search_flags: cint): PAVOption;
  cdecl; external LIB_AVUTIL;

implementation


end.
 
//{$EndIf} (* AVUTIL_OPT_H *)
