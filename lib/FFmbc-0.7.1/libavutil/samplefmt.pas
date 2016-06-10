(*
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
 * Conversion of libavutil/samplefmt.h
 * avutil version 51.11.0
 *)
 
 
{$ifndef AVUTIL_SAMPLEFMT_H}
	{$define AVUTIL_SAMPLEFMT_H}
	
(**
 * all in native-endian format
 *)

type
  TAVSampleFormat = (
    AV_SAMPLE_FMT_NONE = -1,
    AV_SAMPLE_FMT_U8,          ///< unsigned 8 bits
    AV_SAMPLE_FMT_S16,         ///< signed 16 bits
    AV_SAMPLE_FMT_S32,         ///< signed 32 bits
    AV_SAMPLE_FMT_FLT,         ///< float
    AV_SAMPLE_FMT_DBL,         ///< double
    AV_SAMPLE_FMT_NB           ///< Number of sample formats. DO NOT USE if linking dynamically
  );
  TAVSampleFormatArray = array [0 .. MaxInt div SizeOf(TAVSampleFormat) - 1] of TAVSampleFormat;
  PAVSampleFormatArray = ^TAVSampleFormatArray;

(**
 * Return the name of sample_fmt, or NULL if sample_fmt is not
 * recognized.
 *)
function av_get_sample_fmt_name(sample_fmt: TAVSampleFormat): {const} PAnsiChar;
  cdecl; external LIB_AVUTIL;

(**
 * Return a sample format corresponding to name, or AV_SAMPLE_FMT_NONE
 * on error.
 *)
function av_get_sample_fmt(const name: PAnsiChar): TAVSampleFormat;
  cdecl; external LIB_AVUTIL;

(**
 * Generate a string corresponding to the sample format with
 * sample_fmt, or a header if sample_fmt is negative.
 *
 * @param buf the buffer where to write the string
 * @param buf_size the size of buf
 * @param sample_fmt the number of the sample format to print the
 * corresponding info string, or a negative value to print the
 * corresponding header.
 * @return the pointer to the filled buffer or NULL if sample_fmt is
 * unknown or in case of other errors
 *)
function av_get_sample_fmt_string(buf: PAnsiChar; buf_size: cint; sample_fmt: TAVSampleFormat): PAnsiChar;
  cdecl; external LIB_AVUTIL;

{$IFDEF FF_API_GET_BITS_PER_SAMPLE_FMT}
(**
 * @deprecated Use av_get_bytes_per_sample() instead.
 *)
function av_get_bits_per_sample_fmt(sample_fmt: TAVSampleFormat): cint;
  cdecl; external LIB_AVUTIL;
{$ENDIF}

(**
 * Return number of bytes per sample.
 *
 * @param sample_fmt the sample format
 * @return number of bytes per sample or zero if unknown for the given
 * sample format
 *)
function av_get_bytes_per_sample(sample_fmt: TAVSampleFormat): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Fill plane data pointers and linesize for samples with sample
 * format sample_fmt.
 *
 * The audio_data array is filled with the pointers to the samples data planes:
 * for planar, set the start point of each channel's data within the buffer,
 * for packed, set the start point of the entire buffer only.
 *
 * The value pointed to by linesize is set to the aligned size of each
 * channel's data buffer for planar layout, or to the aligned size of the
 * buffer for all channels for packed layout.
 *
 * The buffer in buf must be big enough to contain all the samples
 * (use av_samples_get_buffer_size() to compute its minimum size),
 * otherwise the audio_data pointers will point to invalid data.
 *
 * @see enum AVSampleFormat
 * The documentation for AVSampleFormat describes the data layout.
 *
 * @param[out] audio_data  array to be filled with the pointer for each channel
 * @param[out] linesize    calculated linesize, may be NULL
 * @param buf              the pointer to a buffer containing the samples
 * @param nb_channels      the number of channels
 * @param nb_samples       the number of samples in a single channel
 * @param sample_fmt       the sample format
 * @param align            buffer size alignment (0 = default, 1 = no alignment)
 * @return                 >=0 on success or a negative error code on failure
 * @todo return minimum size in bytes required for the buffer in case
 * of success at the next bump
 *)
function av_samples_fill_arrays(audio_data: pointer; linesize: Pcint;
                                buf: Pcuint8;
				nb_channels: cint; nb_samples: cint; 
                                sample_fmt: TAVSampleFormat; align: cint): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Allocate a samples buffer for nb_samples samples, and fill data pointers and
 * linesize accordingly.
 * The allocated samples buffer can be freed by using av_freep(&audio_data[0])
 *
 * @see enum AVSampleFormat
 * The documentation for AVSampleFormat describes the data layout.
 *
 * @param[out] audio_data  array to be filled with the pointer for each channel
 * @param[out] linesize    aligned size for audio buffer(s), may be NULL
 * @param nb_channels      number of audio channels
 * @param nb_samples       number of samples per channel
 * @param align            buffer size alignment (0 = default, 1 = no alignment)
 * @return                 >=0 on success or a negative error code on failure
 * @todo return the size of the allocated buffer in case of success at the next bump
 * @see av_samples_fill_arrays()
 *)
function av_samples_alloc(audio_data: pointer; linesize: Pcint;
                          nb_channels: cint; nb_samples: cint;
			  sample_fmt: TAVSampleFormat; align: cint): cint;
  cdecl; external LIB_AVUTIL;
  
{$endif} (* AVUTIL_SAMPLEFMT_H *)
