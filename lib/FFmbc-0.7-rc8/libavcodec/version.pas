(*
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
 * Conversion of libavcodec/version.h
 * avcodec version 53.9.0
 *
 *)
 
 
{$IfNDef AVCODEC_VERSION_H}
	{$Define AVCODEC_VERSION_H}

(**
 * Those FF_API_* defines are not part of public API.
 * They may change, break or disappear at any time.
 *)



  {$ifndef FF_API_PALETTE_CONTROL}
  const
    FF_API_PALETTE_CONTROL = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_OLD_SAMPLE_FMT}
  const
    FF_API_OLD_SAMPLE_FMT = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_OLD_AUDIOCONVERT}
  const
    FF_API_OLD_AUDIOCONVERT = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_ANTIALIAS_ALGO}
  const
    FF_API_ANTIALIAS_ALGO = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_REQUEST_CHANNELS}
  const
    FF_API_REQUEST_CHANNELS = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_OPT_H}
  const
    FF_API_OPT_H = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_THREAD_INIT}
  const
    FF_API_THREAD_INIT = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_OLD_FF_PICT_TYPES}
  const
    FF_API_OLD_FF_PICT_TYPES = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_FLAC_GLOBAL_OPTS}
  const
    FF_API_FLAC_GLOBAL_OPTS = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_GET_PIX_FMT_NAME}
  const
    FF_API_GET_PIX_FMT_NAME = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_ALLOC_CONTEXT}
  const
    FF_API_ALLOC_CONTEXT    = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_AVCODEC_OPEN}
  const
    FF_API_AVCODEC_OPEN     = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}
  {$ifndef FF_API_DRC_SCALE}
  const
    FF_API_DRC_SCALE        = (LIBAVCODEC_VERSION_MAJOR < 54);
  {$endif}

{$EndIf} (* AVCODEC_VERSION_H *)
