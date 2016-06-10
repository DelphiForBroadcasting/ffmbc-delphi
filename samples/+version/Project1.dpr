program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  avcodec in '../../lib/FFmbc-0.7.1/libavcodec/avcodec.pas',
  avformat in '../../lib/FFmbc-0.7.1/libavformat/avformat.pas',
  avio in '../../lib/FFmbc-0.7.1/libavformat/avio.pas',
  avutil in '../../lib/FFmbc-0.7.1/libavutil/avutil.pas',
  opt in '../../lib/FFmbc-0.7.1/libavutil/opt.pas',
  rational in '../../lib/FFmbc-0.7.1/libavutil/rational.pas',
  imgutils in '../../lib/FFmbc-0.7.1/libavutil/imgutils.pas',
  fifo in '../../lib/FFmbc-0.7.1/libavutil/fifo.pas',
  file_ in '../../lib/FFmbc-0.7.1/libavutil/file_.pas',
  crc in '../../lib/FFmbc-0.7.1/libavutil/crc.pas',
  ctypes in '../../lib/FFmbc-0.7.1/ctypes.pas',
  swscale in '../../lib/FFmbc-0.7.1/libswscale/swscale.pas',
  avdevice in '../../lib/FFmbc-0.7.1/libavdevice/avdevice.pas',
  postprocess in '../../lib/FFmbc-0.7.1/libpostproc/postprocess.pas';


var
  VERSION ,
  MAJOR, MINOR , MICRO: longint;
begin
  try

    av_register_all();

    writeln(LIBAVFORMAT_IDENT);
    writeln('');
    writeln(format('Configuration: %s', [string(avformat_configuration)]));
    writeln('');

    writeln(format('License: %s', [string(avformat_license)]));
    writeln('');

    VERSION:=avutil_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libavutil:     %s.dll     %s', [LIB_AVUTIL, AV_VERSION(MAJOR, MINOR, MICRO)]));

    VERSION:=avcodec_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libavcodec:    %s.dll    %s', [LIB_AVCODEC, AV_VERSION(MAJOR, MINOR, MICRO)]));

    VERSION:=avformat_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libavformat    %s.dll   %s', [LIB_AVFORMAT, AV_VERSION(MAJOR, MINOR, MICRO)]));

    VERSION:=avdevice_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libavdevice:   %s.dll   %s', [LIB_AVDEVICE, AV_VERSION(MAJOR, MINOR, MICRO)]));

    VERSION:=swscale_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libswscale:    %s.dll     %s', [LIB_SWSCALE, AV_VERSION(MAJOR, MINOR, MICRO)]));

    VERSION:=postproc_version();
    MAJOR:= VERSION shr 16;
    MINOR:= VERSION shr 8 and $ff;
    MICRO:= VERSION and $ff;
    writeln(format('libpostproc:   %s.dll   %s', [LIB_POSTPROC, AV_VERSION(MAJOR, MINOR, MICRO)]));
    readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
