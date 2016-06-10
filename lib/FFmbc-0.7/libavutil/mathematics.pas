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
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/mathematics.h
 * avutil version 51.11.0
 *)
 
{$IfNDef AVUTIL_MATHEMATICS_H}
	{$Define AVUTIL_MATHEMATICS_H}
	
const
  M_E          = 2.7182818284590452354;   // e
  M_LN2        = 0.69314718055994530942;  // log_e 2
  M_LN10       = 2.30258509299404568402;  // log_e 10
  M_LOG2_10    = 3.32192809488736234787;  // log_2 10
  M_PHI        = 1.61803398874989484820;  // phi / golden ratio
  M_PI         = 3.14159265358979323846;  // pi
  M_SQRT1_2    = 0.70710678118654752440;  // 1/sqrt(2)
  M_SQRT2      = 1.41421356237309504880;  // sqrt(2)
  NAN          = $7fc00000;     
  INFINITY     = $7f800000;     

type
  TAVRounding = (
    AV_ROUND_ZERO     = 0, ///< Round toward zero.
    AV_ROUND_INF      = 1, ///< Round away from zero.
    AV_ROUND_DOWN     = 2, ///< Round toward -infinity.
    AV_ROUND_UP       = 3, ///< Round toward +infinity.
    AV_ROUND_NEAR_INF = 5 ///< Round to nearest and halfway cases away from zero.
  );

(**
 * Return the greatest common divisor of a and b.
 * If both a or b are 0 or either or both are <0 then behavior is
 * undefined.
 *)
function av_gcd(a: cint64; b: cint64): cint64;
  cdecl; external LIB_AVUTIL; {av_const}

(**
 * Rescale a 64-bit integer with rounding to nearest.
 * A simple a*b/c isn't possible as it can overflow.
 *)
function av_rescale (a, b, c: cint64): cint64;
  cdecl; external LIB_AVUTIL; {av_const}

(**
 * Rescale a 64-bit integer with specified rounding.
 * A simple a*b/c isn't possible as it can overflow.
 *
 * @return rescaled value a, or if AV_ROUND_PASS_MINMAX is set and a is
 *         INT64_MIN or INT64_MAX then a is passed through unchanged.
 *)
function av_rescale_rnd (a, b, c: cint64; enum: TAVRounding): cint64;
  cdecl; external LIB_AVUTIL; {av_const}

(**
 * Rescale a 64-bit integer by 2 rational numbers.
 *)
function av_rescale_q (a: cint64; bq, cq: TAVRational): cint64;
  cdecl; external LIB_AVUTIL; {av_const}


(**
 * Compare 2 timestamps each in its own timebases.
 * The result of the function is undefined if one of the timestamps
 * is outside the int64_t range when represented in the others timebase.
 * @return -1 if ts_a is before ts_b, 1 if ts_a is after ts_b or 0 if they represent the same position
 *)
function av_compare_ts(ts_a: cint64; tb_a: TAVRational; ts_b: cint64; tb_b: TAVRational): cint;
  cdecl; external LIB_AVUTIL;
 
(**
 * Compare 2 integers modulo mod.
 * That is we compare integers a and b for which only the least
 * significant log2(mod) bits are known.
 *
 * @param mod must be a power of 2
 * @return a negative value if a is smaller than b
 *         a positiv  value if a is greater than b
 *         0                if a equals          b
 *)
function av_compare_mod(a: cuint64; b: cuint64; modVar: cuint64): cint64;
  cdecl; external LIB_AVUTIL;

  
{$EndIf} (* AVUTIL_MATHEMATICS_H *)

