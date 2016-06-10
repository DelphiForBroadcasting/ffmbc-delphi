{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2004 by Marco van de Voort, member of the
    Free Pascal development team

    Implements C types for in header conversions

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


 **********************************************************************}

unit ctypes;

{$LEGACYIFEND ON}

interface

uses
  System.SysUtils;

type
  qword = int64;  // Keep h2pas "uses ctypes" headers working with delphi.



  { the following type definitions are compiler dependant }
  { and system dependant                                  }

  cint8                  = shortint;           pcint8                 = ^cint8;
  cuint8                 = byte;               pcuint8                = ^cuint8;
  cchar                  = cint8;              pcchar                 = ^cchar;
  cschar                 = cint8;              pcschar                = ^cschar;
  cuchar                 = cuint8;             pcuchar                = ^cuchar;

  cint16                 = smallint;           pcint16                = ^cint16;
  cuint16                = word;               pcuint16               = ^cuint16;
  cshort                 = cint16;             pcshort                = ^cshort;
  csshort                = cint16;             pcsshort               = ^csshort;
  cushort                = cuint16;            pcushort               = ^cushort;

  cint32                 = longint;            pcint32                = ^cint32;
  cuint32                = longword;           pcuint32               = ^cuint32;
  cint                   = cint32;             pcint                  = ^cint;              { minimum range is : 32-bit    }
  csint                  = cint32;             pcsint                 = ^csint;             { minimum range is : 32-bit    }
  cuint                  = cuint32;            pcuint                 = ^cuint;             { minimum range is : 32-bit    }
  csigned                = cint;               pcsigned               = ^csigned;
  cunsigned              = cuint;              pcunsigned             = ^cunsigned;

  cint64                 = int64;              pcint64                = ^cint64;
  cuint64                = qword;              pcuint64               = ^cuint64;
  clonglong              = cint64;             pclonglong             = ^clonglong;
  cslonglong             = cint64;             pcslonglong            = ^cslonglong;
  culonglong             = cuint64;            pculonglong            = ^culonglong;

  cbool                  = longbool;           pcbool                 = ^cbool;
  
  size_t                 = cardinal;           psize_t                = ^size_t;
  

{$if defined(cpu64) and not(defined(win64) and defined(cpux86_64))}
  clong                  = int64;              pclong                 = ^clong;
  cslong                 = int64;              pcslong                = ^cslong;
  culong                 = qword;              pculong                = ^culong;
{$else}
  clong                  = longint;            pclong                 = ^clong;
  cslong                 = longint;            pcslong                = ^cslong;
  culong                 = cardinal;           pculong                = ^culong;
{$ifend}

  cfloat                 = single;             pcfloat                = ^cfloat;
  cdouble                = double;             pcdouble               = ^cdouble;
  clongdouble            = extended;           pclongdouble           = ^clongdouble;


  pByteArray = pcuint8;

type
  TArray256Integer = array[0..255] of cint;
  TArray4Integer = array[0..3] of cint;
  PArray4Integer = ^TArray4Integer;
  TArray4pcuint8 = array[0..3] of pcuint8;
  PArray4pcuint8 = ^TArray4pcuint8;
  PAVFile = Pointer;

const
	INT_MIN = low(cint); 
	
	LIB_AVCODEC = 'avcodec-53';
	LIBAVCODEC_VERSION_MAJOR   = 53;
	LIBAVCODEC_VERSION_MINOR   = 9;
	LIBAVCODEC_VERSION_MICRO   = 0;
	LIBAVCODEC_VERSION_INT     = ((LIBAVCODEC_VERSION_MAJOR shl 16) or (LIBAVCODEC_VERSION_MINOR shl 8) or LIBAVCODEC_VERSION_MICRO);
  LIBAVCODEC_BUILD           = LIBAVCODEC_VERSION_INT;
  LIBAVCODECT_IDENT 		     = 'Lavc';

	LIB_AVFORMAT = 'avformat-53';
	LIBAVFORMAT_VERSION_MAJOR   = 53;
	LIBAVFORMAT_VERSION_MINOR   = 6;
	LIBAVFORMAT_VERSION_MICRO   = 0;
	LIBAVFORMAT_VERSION_INT     = ((LIBAVFORMAT_VERSION_MAJOR shl 16) or (LIBAVFORMAT_VERSION_MINOR shl 8) or LIBAVFORMAT_VERSION_MICRO);
  LIBAVFORMAT_BUILD           = LIBAVFORMAT_VERSION_INT;
	LIBAVFORMAT_IDENT           = 'FFmbc 0.7';

	LIB_AVUTIL = 'avutil-51';
	LIBAVUTIL_VERSION_MAJOR   = 51;
	LIBAVUTIL_VERSION_MINOR   = 11;
	LIBAVUTIL_VERSION_MICRO   = 0;
	LIBAVUTIL_VERSION_INT     = ((LIBAVUTIL_VERSION_MAJOR shl 16) or (LIBAVUTIL_VERSION_MINOR shl 8) or LIBAVUTIL_VERSION_MICRO);
  LIBAVUTIL_BUILD           = LIBAVUTIL_VERSION_INT;
	LIBAVUTIL_IDENT           = 'Lavu';

	LIB_AVDEVICE = 'avdevice-53';
	LIBAVDEVICE_VERSION_MAJOR   = 53;
	LIBAVDEVICE_VERSION_MINOR   = 2;
	LIBAVDEVICE_VERSION_MICRO   = 0;
	LIBAVDEVICE_VERSION_INT     = ((LIBAVDEVICE_VERSION_MAJOR shl 16) or (LIBAVDEVICE_VERSION_MINOR shl 8) or LIBAVDEVICE_VERSION_MICRO);
  LIBAVDEVICE_BUILD           = LIBAVUTIL_VERSION_INT;
	LIBAVDEVICE_IDENT           = 'Lavd';

	LIB_SWSCALE = 'swscale-2';
	LIBSWSCALE_VERSION_MAJOR   = 2;
	LIBSWSCALE_VERSION_MINOR   = 0;
	LIBSWSCALE_VERSION_MICRO   = 0;
	LIBSWSCALE_IDENT			= 'Lavs';
	
	LIB_POSTPROC = 'postproc-51';
	LIBPOSTPROC_VERSION_MAJOR   = 51;
	LIBPOSTPROC_VERSION_MINOR   = 2;
	LIBPOSTPROC_VERSION_MICRO   = 0; 
	LIBPOSTPROC_IDENT			= 'Lavp';
	
	function AV_NE(be, le: PAnsiChar): PAnsiChar; inline;
	function MKTAG  (a, b, c, d: AnsiChar): integer; inline;
	function MKBETAG(a, b, c, d: AnsiChar): integer; inline;
  function AV_VERSION_INT(a, b, c: cint): cuint;
  function AV_VERSION(a, b, c: cint): PAnsiChar;

implementation

function AV_NE(be, le: PAnsiChar): PAnsiChar; inline;
begin
  Result := le;
end;

function MKTAG(a, b, c, d: AnsiChar): integer; inline;
begin
  Result := (ord(a) or (ord(b) shl 8) or (ord(c) shl 16) or (ord(d) shl 24));
end;

function MKBETAG(a, b, c, d: AnsiChar): integer; inline;
begin
  Result := (ord(d) or (ord(c) shl 8) or (ord(b) shl 16) or (ord(a) shl 24));
end;


function AV_VERSION_INT(a, b, c: cint): cuint;
begin
 result:=((a shl 16) or (b shl 8) or c);
end; 

function AV_VERSION_DOT(a, b, c: cint): PAnsiChar;
begin
  result:=PAnsiChar(AnsiString(Format('%d.%02.2d.%02.2d',[a, b, c])));
end;

function AV_VERSION(a, b, c: cint): PansiChar;
begin
  result:=AV_VERSION_DOT(a, b, c);
end;

end.
