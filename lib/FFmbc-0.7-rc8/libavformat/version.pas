(*
 * Version macros.
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
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavformat/version.h
 * avcodec version 53.6.0
 *
 *)


{$IfNDef AVFORMAT_VERSION_H}
	{$Define AVFORMAT_VERSION_H}

(**
 * Those FF_API_* defines are not part of public API.
 * They may change, break or disappear at any time.
 *)

{$IFNDEF FF_API_OLD_METADATA2}
const
  FF_API_OLD_METADATA2           = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_READ_SEEK}
const
  FF_API_READ_SEEK               = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_OLD_AVIO}
const
  FF_API_OLD_AVIO                = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_DUMP_FORMAT}
const
  FF_API_DUMP_FORMAT             = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_PARSE_DATE}
const
  FF_API_PARSE_DATE              = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_FIND_INFO_TAG}
const
  FF_API_FIND_INFO_TAG           = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_PKT_DUMP}
const
  FF_API_PKT_DUMP                = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_GUESS_IMG2_CODEC}
const
  FF_API_GUESS_IMG2_CODEC        = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_SDP_CREATE}
const
  FF_API_SDP_CREATE              = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_ALLOC_OUTPUT_CONTEXT}
const
  FF_API_ALLOC_OUTPUT_CONTEXT    = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_FORMAT_PARAMETERS}
const
  FF_API_FORMAT_PARAMETERS       = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_FLAG_RTP_HINT}
const
  FF_API_FLAG_RTP_HINT           = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_AVSTREAM_QUALITY}
const
  FF_API_AVSTREAM_QUALITY        = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_LOOP_INPUT}
const
  FF_API_LOOP_INPUT              = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_LOOP_OUTPUT}
const
  FF_API_LOOP_OUTPUT             = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}
{$IFNDEF FF_API_TIMESTAMP}
const
  FF_API_TIMESTAMP               = (LIBAVFORMAT_VERSION_MAJOR < 54);
{$ENDIF}

{$EndIf} (* AVFORMAT_VERSION_H *)
