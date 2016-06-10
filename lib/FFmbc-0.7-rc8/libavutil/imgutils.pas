unit imgutils;
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
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/imgutils.h
 * avutil version 51.11.0
 *)

 
 //{$ifndef AVUTIL_IMGUTILS_H}
{$define AVUTIL_IMGUTILS_H}

interface

uses
  SysUtils,
  ctypes,
  rational,
  avutil;
  
(**
 * @file
 * misc image utilities
 *
 * @addtogroup lavu_picture
 * @{
 *)

{$INCLUDE pixdesc.pas}


(**
 * Compute the max pixel step for each plane of an image with a
 * format described by pixdesc.
 *
 * The pixel step is the distance in bytes between the first byte of
 * the group of bytes which describe a pixel component and the first
 * byte of the successive group in the same plane for the same
 * component.
 *
 * @param max_pixsteps an array which is filled with the max pixel step
 * for each plane. Since a plane may contain different pixel
 * components, the computed max_pixsteps[plane] is relative to the
 * component in the plane with the max pixel step.
 * @param max_pixstep_comps an array which is filled with the component
 * for each plane which has the max pixel step. May be NULL.
 *)


Procedure av_image_fill_max_pixsteps(max_pixsteps: TArray4Integer; max_pixstep_comps: TArray4Integer;
                                const pixdesc: PAVPixFmtDescriptor);
  cdecl; external LIB_AVUTIL;
(**
 * Compute the size of an image line with format pix_fmt and width
 * width for the plane plane.
 *
 * @return the computed size in bytes
 *)
Function av_image_get_linesize(pix_fmt: TAVPixelFormat; width, plane : cint) : cint;
  cdecl; external LIB_AVUTIL;
(**
 * Fill plane linesizes for an image with pixel format pix_fmt and
 * width width.
 *
 * @param linesizes array to be filled with the linesize for each plane
 * @return >= 0 in case of success, a negative error code otherwise
 *)
Function av_image_fill_linesizes(linesizes: TArray4Integer; pix_fmt: TAVPixelFormat; width : cint): cint;
  cdecl; external LIB_AVUTIL;
(**
 * Fill plane data pointers for an image with pixel format pix_fmt and
 * height height.
 *
 * @param data pointers array to be filled with the pointer for each image plane
 * @param ptr the pointer to a buffer which will contain the image
 * @param linesizes the array containing the linesize for each
 * plane, should be filled by av_image_fill_linesizes()
 * @return the size in bytes required for the image buffer, a negative
 * error code in case of failure
 *)
Function av_image_fill_pointers(data: PArray4pcuint8; pix_fmt: TAVPixelFormat; height: cint;
                           ptr : pcuint8; const linesizes: TArray4Integer): cint;
  cdecl; external LIB_AVUTIL;
(**
 * Allocate an image with size w and h and pixel format pix_fmt, and
 * fill pointers and linesizes accordingly.
 * The allocated image buffer has to be freed by using
 * av_freep(&pointers[0]).
 *
 * @param align the value to use for buffer size alignment
 * @return the size in bytes required for the image buffer, a negative
 * error code in case of failure
 *)
Function av_image_alloc(pointers: PArray4pcuint8; linesizes: TArray4Integer;
                   w, h : cint; pix_fmt : TAVPixelFormat; align : cint): cint;
  cdecl; external LIB_AVUTIL;
(**
 * Copy image plane from src to dst.
 * That is, copy "height" number of lines of "bytewidth" bytes each.
 * The first byte of each successive line is separated by *_linesize
 * bytes.
 *
 * bytewidth must be contained by both absolute values of dst_linesize
 * and src_linesize, otherwise the function behavior is undefined.
 *
 * @param dst_linesize linesize for the image plane in dst
 * @param src_linesize linesize for the image plane in src
 *)
Procedure av_image_copy_plane(dst: pcuint8; dst_linesize : cint;
                         const src : pcuint8; const src_linesize : cint;
                         bytewidth: cint; height: cint);
  cdecl; external LIB_AVUTIL;
(**
 * Copy image in src_data to dst_data.
 *
 * @param dst_linesizes linesizes for the image in dst_data
 * @param src_linesizes linesizes for the image in src_data
 *)
Procedure av_image_copy(dst_data: PArray4pcuint8; dst_linesizes: TArray4Integer;
                   const src_data: PArray4pcuint8; src_linesizes: TArray4Integer;
                   pix_fmt: TAVPixelFormat; width, height : cint);
  cdecl; external LIB_AVUTIL;

(**
 * Check if the given dimension of an image is valid, meaning that all
 * bytes of the image can be addressed with a signed int.
 *
 * @param w the width of the picture
 * @param h the height of the picture
 * @param log_offset the offset to sum to the log level for logging with log_ctx
 * @param log_ctx the parent logging context, it may be NULL
 * @return >= 0 if valid, a negative error code otherwise
 *)
Function av_image_check_size(w : cuint; h: cuint; log_offset : cint; log_ctx : Pointer): cint;
  cdecl; external LIB_AVUTIL;

Function avpriv_set_systematic_pal2(pal: TArray256Integer; pix_fmt: TAVPixelFormat): cint;
  cdecl; external LIB_AVUTIL;
(**
 * @}
 *)

implementation



end.

//{$EndIf} (* AVUTIL_IMGUTILS_H *)




