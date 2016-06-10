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
 *
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/avutil.h
 * avutil version 51.11.0
 *)

unit avutil;


{$MINENUMSIZE 4}


{$IFDEF DARWIN}
  {$linklib libavutil}
{$ENDIF}

interface

uses
  SysUtils,
  ctypes,
  {$IFDEF UNIX}
  BaseUnix,
  {$ENDIF}
  opt,
  rational;


(**
 * Return the LIBAVUTIL_VERSION_INT constant.
 *)
function avutil_version(): cuint;
  cdecl; external LIB_AVUTIL;

(**
 * Return the libavutil build-time configuration.
 *)
function avutil_configuration(): PAnsiChar;
  cdecl; external LIB_AVUTIL;

(**
 * Return the libavutil license.
 *)
function avutil_license(): PAnsiChar;
  cdecl; external LIB_AVUTIL;

(**
 * @addtogroup lavu_media Media Type
 * @brief Media Type
 *)

type
  TAVMediaType = (
    AVMEDIA_TYPE_UNKNOWN = -1,  ///< Usually treated as AVMEDIA_TYPE_DATA
    AVMEDIA_TYPE_VIDEO,
    AVMEDIA_TYPE_AUDIO,
    AVMEDIA_TYPE_DATA,          ///< Opaque data information usually continuous
    AVMEDIA_TYPE_SUBTITLE,
    AVMEDIA_TYPE_NB
  );


const
  FF_LAMBDA_SHIFT = 7;
  FF_LAMBDA_SCALE = (1 shl FF_LAMBDA_SHIFT);
  FF_QP2LAMBDA    = 118; ///< factor to convert from H.263 QP to lambda
  FF_LAMBDA_MAX   = (256*128-1);
 
  FF_QUALITY_SCALE = FF_LAMBDA_SCALE; //FIXME maybe remove
 
  AV_NOPTS_VALUE   = $8000000000000000;
  AV_TIME_BASE     = 1000000;
  AV_TIME_BASE_Q   : TAVRational = (num: 1; den: AV_TIME_BASE);

type
  TAVPictureType = (
    AV_PICTURE_TYPE_NONE = 0, ///< Undefined
    AV_PICTURE_TYPE_I,     ///< Intra
    AV_PICTURE_TYPE_P,     ///< Predicted
    AV_PICTURE_TYPE_B,     ///< Bi-dir predicted
    AV_PICTURE_TYPE_S,     ///< S(GMC)-VOP MPEG4
    AV_PICTURE_TYPE_SI,    ///< Switching Intra
    AV_PICTURE_TYPE_SP,    ///< Switching Predicted
    AV_PICTURE_TYPE_BI     ///< BI type
  );

(**
 * Return a single letter to describe the given picture type
 * pict_type.
 *
 * @param[in] pict_type the picture type @return a single character
 * representing the picture type, '?' if pict_type is unknown
 *)
function av_get_picture_type_char(pict_type: TAVPictureType): PAnsiChar;
  cdecl; external LIB_AVUTIL;
 
{ #include "common.h"
#include "error.h"
#include "mathematics.h"
#include "rational.h"
#include "intfloat_readwrite.h"
#include "log.h"
#include "pixfmt.h"}

{$INCLUDE cpu.pas}
{$INCLUDE error.pas}
{$INCLUDE mathematics.pas}
{$INCLUDE mem.pas}
{$INCLUDE intfloat_readwrite.pas}
{$INCLUDE log.pas}
{$INCLUDE pixfmt.pas}
{$INCLUDE samplefmt.pas}
{$INCLUDE audioconvert.pas}

implementation


end.
