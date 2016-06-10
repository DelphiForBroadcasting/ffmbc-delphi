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
 * Conversion of libavutil/crc.h
 * avutil version 51.11.0
 *)

 unit crc;

{$define AVUTIL_CRC_H}
{$MINENUMSIZE 4} (* use 4-byte enums *)

interface

uses
  ctypes;


(*
 * #include <stdint.h>
 * #include "attributes.h"
 *)
type

 TAVCRC = cuint32;
 PAVCRC = ^TAVCRC;

 TAVCRCId  = (	AV_CRC_8_ATM,
				AV_CRC_16_ANSI,
				AV_CRC_16_CCITT,
				AV_CRC_32_IEEE,
				AV_CRC_32_IEEE_LE,  (*< reversed bitorder version of AV_CRC_32_IEEE *)
				AV_CRC_MAX         (*< Not part of public API! Do not use outside libavutil. *)
			  );
  
function av_crc_init(ctx: PAVCRC; le: cint; bits: cint; poly: cuint32; ctx_size: cint): cint;
  cdecl; external LIB_AVUTIL; 
function av_crc_get_table(crc_id: TAVCRCId): PAVCRC;
  cdecl; external LIB_AVUTIL; 
function av_crc(const ctx: PAVCRC; start_crc: cuint32; const buffer: Pcuint8; length: size_t): cuint32;  
  cdecl; external LIB_AVUTIL;
implementation

end.
