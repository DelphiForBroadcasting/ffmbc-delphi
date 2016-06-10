program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  avcodec in '../../lib/FFmbc-0.7/libavcodec/avcodec.pas',
  avformat in '../../lib/FFmbc-0.7/libavformat/avformat.pas',
  avio in '../../lib/FFmbc-0.7/libavformat/avio.pas',
  avutil in '../../lib/FFmbc-0.7/libavutil/avutil.pas',
  opt in '../../lib/FFmbc-0.7/libavutil/opt.pas',
  rational in '../../lib/FFmbc-0.7/libavutil/rational.pas',
  imgutils in '../../lib/FFmbc-0.7/libavutil/imgutils.pas',
  fifo in '../../lib/FFmbc-0.7/libavutil/fifo.pas',
  file_ in '../../lib/FFmbc-0.7/libavutil/file_.pas',
  ctypes in '../../lib/FFmbc-0.7/ctypes.pas',
  swscale in '../../lib/FFmbc-0.7/libswscale/swscale.pas',
  avdevice in '../../lib/FFmbc-0.7/libavdevice/avdevice.pas',
  postprocess in '../../lib/FFmbc-0.7/libpostproc/postprocess.pas';
label
  usage, version;

var
  fmt_ctx : PAVFormatContext;
  tag : PAVDictionaryEntry;
  d : PAVDictionary;
  k, v : PAnsiChar;
  i : integer;
  ret : integer;
  errorstr : string;
begin
  try
    fmt_ctx := nil;
    tag := nil;
    d:=nil;
    if ParamCount<=0 then
    begin
      goto usage;
    end;

    if SameText(ParamStr(1), '--version') or
    SameText(ParamStr(1), '-version') or
    SameText(ParamStr(1), '--v') or
    SameText(ParamStr(1), '-v')then
    begin
      goto version;
    end;

    if not fileexists(ParamStr(1)) then
    begin
      writeln(Format('error: %s not find.', [ParamStr(1)]));
      exit;
    end;

    writeln(Format('%s %s', [extractfilename(ParamStr(0)), ParamStr(1)]));

    av_register_all();
    ret:=avformat_open_input(@fmt_ctx, PAnsiChar(AnsiString(ParamStr(1))), nil, nil);
    if  ret < 0 then
    begin
      av_strerror(ret, PAnsiChar(errorstr), 1024);
      writeln(Format('error: [avformat_open_input][%s]', [errorstr]));
      exit;
    end;

    // "create" an empty dictionary
    av_dict_set(fmt_ctx.metadata, 'test1', 'value', 0);      // add an entry
    k := av_strdup('test2');            // if your strings are already allocated,
    v := av_strdup('value');          // you can avoid copying them like this
    av_dict_set(fmt_ctx.metadata, k, v, AV_DICT_DONT_STRDUP_KEY or AV_DICT_DONT_STRDUP_VAL);

    writeln('Metadata:');
    repeat
      tag := av_dict_get(fmt_ctx.metadata, '', tag, AV_DICT_IGNORE_SUFFIX);
      if assigned(tag) then  writeln(format('   %s=%s', [tag.key, tag.value]));
    until not assigned(tag);

    avformat_free_context(fmt_ctx);
    readln;
    exit;

    usage :
    begin
      writeln(Format('Usage:  %s [file]', [extractfilename(ParamStr(0))]));
      writeln('Example:');
      writeln(Format('  %s test.mov', [extractfilename(ParamStr(0))]));
      exit;
    end;

    version :
    begin
      writeln('/*');
      writeln(' * Copyright (c) 2011 Reinhard Tartler');
      writeln(' * ');
      writeln(' * Permission is hereby granted, free of charge, to any person obtaining a copy');
      writeln(' * of this software and associated documentation files (the "Software"), to deal');
      writeln(' * in the Software without restriction, including without limitation the rights');
      writeln(' * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell');
      writeln(' * copies of the Software, and to permit persons to whom the Software is');
      writeln(' * furnished to do so, subject to the following conditions:');
      writeln(' * ');
      writeln(' * The above copyright notice and this permission notice shall be included in');
      writeln(' * all copies or substantial portions of the Software.');
      writeln(' * ');
      writeln(' * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR');
      writeln(' * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,');
      writeln(' * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL');
      writeln(' * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER');
      writeln(' * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,');
      writeln(' * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN');
      writeln(' * THE SOFTWARE.');
      writeln(' *');
      writeln(' * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>');
      writeln(' *');
      writeln(' */');
      exit;
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
