(*
 * audio conversion
 * Copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
 * Copyright (c) 2008 Peter Ross
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
 * Conversion of libavcodec/audioconvert.h
 * avcodec version 51.11.0
 *
 *)


{$IfNDef AVCODEC_AUDIOCONVERT_H}
	{$Define AVCODEC_AUDIOCONVERT_H}

(**
 * @file
 * Audio format conversion routines
 *)


(* #include "libavutil/cpu.h"
 * #include "avcodec.h"
 * #include "libavutil/audioconvert.h"
 *)

{$IF FF_API_OLD_SAMPLE_FMT}
(**
 * @deprecated Use av_get_sample_fmt_string() instead.
 *)
procedure avcodec_sample_fmt_string(buf: PAnsiChar; buf_size: cint; sample_fmt: cint); deprecated 'Use av_get_sample_fmt_string() instead';
  cdecl; external LIB_AVCODEC;

(**
 * @deprecated Use av_get_sample_fmt_name() instead.
 *)
function avcodec_get_sample_fmt_name(sample_fmt: cint): PAnsiChar; deprecated 'Use av_get_sample_fmt_name() instead';
  cdecl; external LIB_AVCODEC;

(**
 * @deprecated Use av_get_sample_fmt() instead.
 *)
function avcodec_get_sample_fmt(const name: PAnsiChar): TAVSampleFormat; deprecated 'Use av_get_sample_fmt() instead';
  cdecl; external LIB_AVCODEC;
{$IFEND}

{$IF FF_API_OLD_AUDIOCONVERT}
(**
 * @deprecated Use av_get_channel_layout() instead.
 *)
function avcodec_get_channel_layout(const name: PAnsiChar): cint64; deprecated 'Use av_get_channel_layout() instead';
  cdecl; external LIB_AVCODEC;

(**
 * @deprecated Use av_get_channel_layout_string() instead.
 *)

procedure avcodec_get_channel_layout_string(buf: PAnsiChar; buf_size: cint; nb_channels: cint; channel_layout: cint64); deprecated 'Use av_get_channel_layout_string() instead.';
  cdecl; external LIB_AVCODEC;

(**
 * @deprecated Use av_get_channel_layout_nb_channels() instead.
 *)
function avcodec_channel_layout_num_channels(channel_layout: cint64): cint; deprecated 'Use av_get_channel_layout_nb_channels() instead';
  cdecl; external LIB_AVCODEC;
{$IFEND}

(**
 * Guess the channel layout
 * @param nb_channels
 * @param codec_id Codec identifier, or CODEC_ID_NONE if unknown
 * @param fmt_name Format name, or NULL if unknown
 * @return Channel layout mask
 *)
function avcodec_guess_channel_layout(nb_channels: cint; codec_id: TCodecID; const fmt_name: PAnsiChar): cint64;
  cdecl; external LIB_AVCODEC;

type
  PAVAudioConvert = ^TAVAudioConvert;
  TAVAudioConvert = record
    {internal structure}
  end;


(**
 * Create an audio sample format converter context
 * @param out_fmt Output sample format
 * @param out_channels Number of output channels
 * @param in_fmt Input sample format
 * @param in_channels Number of input channels
 * @param[in] matrix Channel mixing matrix (of dimension in_channel*out_channels). Set to NULL to ignore.
 * @param flags See AV_CPU_FLAG_xx
 * @return NULL on error
 *)
function av_audio_convert_alloc(out_fmt: TAVSampleFormat; out_channels: cint;
                                       in_fmt: TAVSampleFormat; in_channels: cint;
                                       const matrix: pcfloat; flags: cint): PAVAudioConvert;
  cdecl; external LIB_AVCODEC;

(**
 * Free audio sample format converter context
 *)
procedure av_audio_convert_free(ctx: PAVAudioConvert);
  cdecl; external LIB_AVCODEC;

(**
 * Convert between audio sample formats
 * @param[in] out array of output buffers for each channel. set to NULL to ignore processing of the given channel.
 * @param[in] out_stride distance between consecutive output samples (measured in bytes)
 * @param[in] in array of input buffers for each channel
 * @param[in] in_stride distance between consecutive input samples (measured in bytes)
 * @param len length of audio frame size (measured in samples)
 *
    function av_audio_convert(ctx: PAVAudioConvert;
                           void * const out[6], const int out_stride[6],
                     const void * const  in[6], const int  in_stride[6], int len): cint;
    cdecl; external LIB_AVCODEC;

 *)

{$EndIf} (* AVCODEC_AUDIOCONVERT_H *)
