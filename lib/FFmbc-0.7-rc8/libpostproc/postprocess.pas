(*
 * Copyright (C) 2001-2003 Michael Niedermayer (michaelni@gmx.at)
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *)
 
 
(**
 * @file
 * @brief
 *     external postprocessing API
 *)
 
  
unit postprocess;

{$MINENUMSIZE 4}

{$LEGACYIFEND ON}

{$Define POSTPROC_POSTPROCESS_H}

interface

uses
  ctypes,
  avutil;
  
  
(**
 * Return the LIBPOSTPROC_VERSION_INT constant.
 *)
function postproc_version(): cunsigned; 
	cdecl; external LIB_POSTPROC;

(**
 * Return the libpostproc build-time configuration.
 *)
function postproc_configuration(): PAnsiChar; 
	cdecl; external LIB_POSTPROC;

(**
 * Return the libpostproc license.
 *)
function postproc_license(): PAnsiChar;
	cdecl; external LIB_POSTPROC;

const
	PP_QUALITY_MAX = 6;

type
	pQP_STORE_T = ^QP_STORE_T;
	QP_STORE_T  = cint8;

	pp_context  = Pointer;
	pp_mode     = Pointer;
	
	
//{$IF LIBPOSTPROC_VERSION_MAJOR < (52 shl 16)}
	pp_help = PAnsiChar; ///< a simple help text
//{$ELSE}
//	pp_help = array[0..0] of AnsiChar; ///< a simple help text
//{$IFEND}

type
  TArray4cint = array[0..3] of cint;
  TArray4pcuint8 = array[0..3] of cuint8;
  pArray4pcuint8 = ^TArray4pcuint8;



procedure pp_postprocess(src: pArray4pcuint8; const srcStride: TArray4cint;
                     dst: pArray4pcuint8; const dstStride: TArray4cint;
                     horizontalSize: cint; verticalSize: cint;
                     const QP_store: pQP_STORE_T; QP_stride: cint;
                     var mode: pp_mode; var ppContext: pp_context; pict_type: cint); 
	cdecl; external LIB_POSTPROC;



(**
 * returns a pp_mode or NULL if an error occurred
 * name is the string after "-pp" on the command line
 * quality is a number from 0 to PP_QUALITY_MAX
 *)
function pp_get_mode_by_name_and_quality(const name: PAnsiChar; quality : cint): pp_mode; 
	cdecl; external LIB_POSTPROC;
procedure pp_free_mode(var mode: pp_mode); 
	cdecl; external LIB_POSTPROC;

function pp_get_context(width: cint; height: cint; flags: cint): pp_context; 
	cdecl; external LIB_POSTPROC;
procedure pp_free_context(ppContext: pp_context); 
	cdecl; external LIB_POSTPROC;


const
	PP_CPU_CAPS_MMX   	= $80000000;
	PP_CPU_CAPS_MMX2 	= $20000000;
	PP_CPU_CAPS_3DNOW 	= $40000000;
	PP_CPU_CAPS_ALTIVEC = $10000000;

	PP_FORMAT         	= $00000008;
	PP_FORMAT_420    	= ($00000011 or PP_FORMAT);
	PP_FORMAT_422    	= ($00000001 or PP_FORMAT);
	PP_FORMAT_411    	= ($00000002 or PP_FORMAT);
	PP_FORMAT_444    	= ($00000000 or PP_FORMAT);

	PP_PICT_TYPE_QP2  	= $00000010; ///< MPEG2 style QScale
  
  
implementation

end.