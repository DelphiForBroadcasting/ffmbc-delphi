(*
 * copyright (c) 2009 Michael Niedermayer
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
 *)

{$IFNDEF AVFORMAT_METADATA_H}
  {$DEFINE AVFORMAT_METADATA_H}

(**
 * @file
 * internal metadata API header
 * see avformat.h or the public API!
 *)


type
 PAVMetadataConv = ^TAVMetadataConv;
 TAVMetadataConv = record
    native : PAnsiChar;
    generic: PAnsiChar;
  end;
{$IF NOT FF_API_OLD_METADATA2}
  PAVMetadataConv = ^TAVMetadataConv;
  TAVMetadataConv = record
  end;
{$IFEND}

procedure ff_metadata_conv(pm: PPAVDictionary, const d_conv: AVMetadataConv; const s_conv: PAVMetadataConv);
  cdecl; external LIB_AVFORMAT;
procedure ff_metadata_conv_ctx(ctx: PAVFormatContext; const  d_conv: PAVMetadataConv; const s_conv: AVMetadataConv);
  cdecl; external LIB_AVFORMAT;

{$ENDIF} (* AVFORMAT_METADATA_H *)
