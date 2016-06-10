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
 *)

unit avdevice;

{$MINENUMSIZE 4}

{$LEGACYIFEND ON}

{$IFDEF DARWIN}
  {$linklib libswscale}
{$ENDIF}

{$Define AVDEVICE_AVDEVICE_H}

interface

uses
  ctypes,
  avutil;

{$ifndef FF_API_V4L}
{$define FF_API_V4L              (LIBAVDEVICE_VERSION_MAJOR < 54)}
{$endif}

(**
 * Return the LIBAVDEVICE_VERSION_INT constant.
 *)
function avdevice_version(): cunsigned;
	cdecl; external LIB_AVDEVICE;

(**
 * Return the libavdevice build-time configuration.
 *)
function avdevice_configuration(): PAnsiChar;
	cdecl; external LIB_AVDEVICE;
	
(**
 * Return the libavdevice license.
 *)
function avdevice_license(): PAnsiChar;
	cdecl; external LIB_AVDEVICE;
	
(**
 * Initialize libavdevice and register all the input and output devices.
 * @warning This function is not thread safe.
 *)
procedure avdevice_register_all();
	cdecl; external LIB_AVDEVICE;

{$include dv1394.pas}

implementation

end.

