(*
 *
 * Copyright (c) 2000, 2001, 2002 Fabrice Bellard
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
 * Conversion of libavutil/cpu.h
 * avutil version 51.11.0
 *
 *)

{$IfNDef AVUTIL_CPU_H}
	{$Define AVUTIL_CPU_H}

const

  AV_CPU_FLAG_FORCE         = $80000000; (* force usage of selected flags (OR) *)

    (* lower 16 bits - CPU features *)
  AV_CPU_FLAG_MMX           = $0001;     ///< standard MMX
  AV_CPU_FLAG_MMXEXT        = $0002;     ///< SSE integer functions or AMD MMX ext
  AV_CPU_FLAG_MMX2          = $0002;     ///< SSE integer functions or AMD MMX ext
  AV_CPU_FLAG_3DNOW         = $0004;     ///< AMD 3DNOW
  AV_CPU_FLAG_SSE           = $0008;     ///< SSE functions
  AV_CPU_FLAG_SSE2          = $0010;     ///< PIV SSE2 functions
  AV_CPU_FLAG_SSE2SLOW      = $40000000; ///< SSE2 supported, but usually not faster
  AV_CPU_FLAG_3DNOWEXT      = $0020;     ///< AMD 3DNowExt
  AV_CPU_FLAG_SSE3          = $0040;     ///< Prescott SSE3 functions
  AV_CPU_FLAG_SSE3SLOW      = $20000000; ///< SSE3 supported, but usually not faster
  AV_CPU_FLAG_SSSE3         = $0080;     ///< Conroe SSSE3 functions
  AV_CPU_FLAG_ATOM          = $10000000; ///< Atom processor, some SSSE3 instructions are slower
  AV_CPU_FLAG_SSE4          = $0100;     ///< Penryn SSE4.1 functions
  AV_CPU_FLAG_SSE42         = $0200;     ///< Nehalem SSE4.2 functions
  AV_CPU_FLAG_AVX           = $4000;     ///< AVX functions: requires OS support even if YMM registers aren't used
  AV_CPU_FLAG_IWMMXT        = $0100;     ///< XScale IWMMXT 
  AV_CPU_FLAG_ALTIVEC       = $0001;     ///< standard


(**
 * Return the flags which specify extensions supported by the CPU.
 *)
function av_get_cpu_flags(): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Disables cpu detection and forces the specified flags.
 * -1 is a special case that disables forcing of specific flags.
 *)
procedure av_force_cpu_flags(flags: cint);
  cdecl; external LIB_AVUTIL;

(* The following CPU-specific functions shall not be called directly. *)
function ff_get_cpu_flags_arm(): cint;
  cdecl; external LIB_AVUTIL;
function ff_get_cpu_flags_ppc(): cint;
  cdecl; external LIB_AVUTIL;
function ff_get_cpu_flags_x86(): cint;
  cdecl; external LIB_AVUTIL;
  
{$EndIf} (* AVUTIL_CPU_H *)
