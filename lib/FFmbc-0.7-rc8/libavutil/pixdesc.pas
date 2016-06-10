(*
 * pixel format descriptor
 * Copyright (c) 2009 Michael Niedermayer <michaelni@gmx.at>
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
 * Conversion of libavutil/pixdesc.h
 * avutil version 51.11.0
 *)

{$ifndef AVUTIL_PIXDESC_H}
	{$define AVUTIL_PIXDESC_H}

//#include <inttypes.h>
//#include "pixfmt.h"



Type
  TAVComponentDescriptor = record
    plane : cuint16;            ///< which of the 4 planes contains the component
    (**
     * Number of elements between 2 horizontally consecutive pixels minus 1.
     * Elements are bits for bitstream formats, bytes otherwise.
     *)
    step_minus1 :cuint16;
     (**
     * Number of elements before the component of the first pixel plus 1.
     * Elements are bits for bitstream formats, bytes otherwise.
     *)
    offset_plus1 : cuint16;
    shift : cuint16;            ///< number of least significant bits that must be shifted away to get the value
    depth_minus1 : cuint16;            ///< number of bits in the component minus 1
end;

(**
 * Descriptor that unambiguously describes how the bits of a pixel are
 * stored in the up to 4 data planes of an image. It also stores the
 * subsampling factors and number of components.
 *
 * @note This is separate of the colorspace (RGB, YCbCr, YPbPr, JPEG-style YUV
 *       and all the YUV variants) AVPixFmtDescriptor just stores how values
 *       are stored not what these values represent.
 *)
Type
  PAVPixFmtDescriptor = ^TAVPixFmtDescriptor;
  TAVPixFmtDescriptor = record
    name : PAnsiChar;
    nb_components: cuint16;       ///< The number of components each pixel has, (1-4)

    (**
     * Amount to shift the luma width right to find the chroma width.
     * For YV12 this is 1 for example.
     * chroma_width = -((-luma_width) >> log2_chroma_w)
     * The note above is needed to ensure rounding up.
     * This value only refers to the chroma components.
     *)
    log2_chroma_w: cuint16;       ///< chroma_width = -((-luma_width )>>log2_chroma_w)

    (**
     * Amount to shift the luma height right to find the chroma height.
     * For YV12 this is 1 for example.
     * chroma_height= -((-luma_height) >> log2_chroma_h)
     * The note above is needed to ensure rounding up.
     * This value only refers to the chroma components.
     *)
    log2_chroma_h: cuint16;
    flags: cuint16;

    (**
     * Parameters that describe how pixels are packed.
     * If the format has 2 or 4 components, then alpha is last.
     * If the format has 1 or 2 components, then luma is 0.
     * If the format has 3 or 4 components,
     * if the RGB flag is set then 0 is red, 1 is green and 2 is blue;
     * otherwise 0 is luma, 1 is chroma-U and 2 is chroma-V.
     *)
    comp: array[0..3] of TAVComponentDescriptor;
end;

Const
  PIX_FMT_BE        = 1; ///< Pixel format is big-endian.
  PIX_FMT_PAL       = 2; ///< Pixel format has a palette in data[1], values are indexes in this palette.
  PIX_FMT_BITSTREAM = 4; ///< All values of a component are bit-wise packed end to end.
  PIX_FMT_HWACCEL   = 8;  ///< Pixel format is an HW accelerated format.
  PIX_FMT_PLANAR    = 16; ///< At least one pixel component is not in the first data plane
  PIX_FMT_RGB       = 32; ///< The pixel format contains RGB-like data (as opposed to YUV/grayscale)

(**
 * Read a line from an image, and write the values of the
 * pixel format component c to dst.
 *
 * @param data the array containing the pointers to the planes of the image
 * @param linesize the array containing the linesizes of the image
 * @param desc the pixel format descriptor for the image
 * @param x the horizontal coordinate of the first pixel to read
 * @param y the vertical coordinate of the first pixel to read
 * @param w the width of the line to read, that is the number of
 * values to write to dst
 * @param read_pal_component if not zero and the format is a paletted
 * format writes the values corresponding to the palette
 * component c in data[1] to dst, rather than the palette indexes in
 * data[0]. The behavior is undefined if the format is not paletted.
 *)
Procedure av_read_image_line(dst : pcuint16; const data : PArray4pcuint8; const linesize :TArray4Integer;
                        const desc : PAVPixFmtDescriptor; x, y, c, w, read_pal_component : cint);
  cdecl; external LIB_AVUTIL;

(**
 * Write the values from src to the pixel format component c of an
 * image line.
 *
 * @param src array containing the values to write
 * @param data the array containing the pointers to the planes of the
 * image to write into. It is supposed to be zeroed.
 * @param linesize the array containing the linesizes of the image
 * @param desc the pixel format descriptor for the image
 * @param x the horizontal coordinate of the first pixel to write
 * @param y the vertical coordinate of the first pixel to write
 * @param w the width of the line to write, that is the number of
 * values to write to the image line
 *)
Procedure av_write_image_line(const src : pcuint16; data : PArray4pcuint8; const linesize : TArray4Integer;
                         const desc : PAVPixFmtDescriptor; x, y, c, w : cint);
  cdecl; external LIB_AVUTIL;
(**
 * Return the pixel format corresponding to name.
 *
 * If there is no pixel format with name name, then looks for a
 * pixel format with the name corresponding to the native endian
 * format of name.
 * For example in a little-endian system, first looks for "gray16",
 * then for "gray16le".
 *
 * Finally if no pixel format has been found, returns AV_PIX_FMT_NONE.
 *)
Function av_get_pix_fmt(name : PAnsiChar) : TAVPixelFormat;
  cdecl; external LIB_AVUTIL;
(**
 * Return the short name for a pixel format, NULL in case pix_fmt is
 * unknown.
 *
 * @see av_get_pix_fmt(), av_get_pix_fmt_string()
 *)
Function av_get_pix_fmt_name(pix_fmt : TAVPixelFormat) : PAnsiChar;
  cdecl; external LIB_AVUTIL;
(**
 * Print in buf the string corresponding to the pixel format with
 * number pix_fmt, or an header if pix_fmt is negative.
 *
 * @param buf the buffer where to write the string
 * @param buf_size the size of buf
 * @param pix_fmt the number of the pixel format to print the
 * corresponding info string, or a negative value to print the
 * corresponding header.
 *)
Function av_get_pix_fmt_string (buf : PAnsiChar; buf_size : cint; pix_fmt : TAVPixelFormat) : PAnsiChar;
  cdecl; external LIB_AVUTIL;
(**
 * Return the number of bits per pixel used by the pixel format
 * described by pixdesc.
 *
 * The returned number of bits refers to the number of bits actually
 * used for storing the pixel information, that is padding bits are
 * not counted.
 *)
Function av_get_bits_per_pixel(const pixdesc : PAVPixFmtDescriptor) : cint;
  cdecl; external LIB_AVUTIL;

 {$endif} (* AVUTIL_PIXDESC_H *)

