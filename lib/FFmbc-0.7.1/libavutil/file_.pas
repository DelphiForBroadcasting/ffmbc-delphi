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
 * Conversion of libavutil/file.h
 * avutil version 51.11.0
 *
 *)

 unit file_;


{$Define AVUTIL_FILE_H}
{$MINENUMSIZE 4} (* use 4-byte enums *)

interface

uses
  ctypes;

(**
 * @file
 * Misc file utilities.
 *)

(**
 * Read the file with name filename, and put its content in a newly
 * allocated buffer or map it with mmap() when available.
 * In case of success set *bufptr to the read or mmapped buffer, and
 * *size to the size in bytes of the buffer in *bufptr.
 * The returned buffer must be released with av_file_unmap().
 *
 * @param log_offset loglevel offset used for logging
 * @param log_ctx context used for logging
 * @return a non negative number in case of success, a negative value
 * corresponding to an AVERROR error code in case of failure
 *)
function av_file_map(const filename: PAnsiChar; var bufptr: pcuint8; size: psize_t;
                log_offset: cint; log_ctx: Pointer): cint;
	cdecl; external LIB_AVUTIL;

(**
 * Unmap or free the buffer bufptr created by av_file_map().
 *
 * @param size size in bytes of bufptr, must be the same as returned
 * by av_file_map()
 *)
procedure av_file_unmap(bufptr: pcuint8; size: size_t);
	cdecl; external LIB_AVUTIL;

implementation



end.
