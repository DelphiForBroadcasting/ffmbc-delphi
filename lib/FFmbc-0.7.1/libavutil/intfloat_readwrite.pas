(*
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
 * 
 *
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/intfloat_readwrite.h
 * avutil version 51.11.0
 *)
 
{$ifndef AVUTIL_INTFLOAT_READWRITE_H}
	{$define AVUTIL_INTFLOAT_READWRITE_H}


(*
 * #include <stdint.h>
 * #include "attributes.h"
 *)
type
(* IEEE 80 bits extended float *)
  PAVExtFloat = ^TAVExtFloat;
  TAVExtFloat = record	
	exponent : array[0..2] of cuint8;
	mantissa : array[0..8] of cuint8;
  end;


function av_int2dbl(v: cint64): cdouble;
  cdecl; external LIB_AVUTIL;
function av_int2flt(v: cint32): cfloat;
  cdecl; external LIB_AVUTIL;
function av_ext2dbl(const ext: TAVExtFloat): cdouble;
  cdecl; external LIB_AVUTIL;
function av_dbl2int(d: cdouble): cint64;
  cdecl; external LIB_AVUTIL;
function av_flt2int(d: cfloat): cint32;
  cdecl; external LIB_AVUTIL;
function av_dbl2ext(d: cdouble): TAVExtFloat;
  cdecl; external LIB_AVUTIL;

{$EndIf} (* AVUTIL_INTFLOAT_READWRITE_H *)
