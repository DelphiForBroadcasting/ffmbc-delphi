(*
    tutorial01.c

    This tutorial was written by Stephen Dranger (dranger@gmail.com).

    Conversion to Delphi by Oleksandr Nazaruk (mail@freehand.com.ua)
    Tested on Windows 8.1 64bit rus, compiled with Delphi XE5

    A small sample program that shows how to use libavformat and libavcodec to
    read video from a file.

    Run using

    tutorial01 myvideofile.mpg

    to write the first five frames from "myvideofile.mpg" to disk in BMP
    format.
*)

program tutorial01;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  VCL.Graphics,
  avcodec in '../lib/FFmbc-0.7/libavcodec/avcodec.pas',
  avformat in '../lib/FFmbc-0.7/libavformat/avformat.pas',
  avio in '../lib/FFmbc-0.7/libavformat/avio.pas',
  avutil in '../lib/FFmbc-0.7/libavutil/avutil.pas',
  opt in '../lib/FFmbc-0.7/libavutil/opt.pas',
  rational in '../lib/FFmbc-0.7/libavutil/rational.pas',
  imgutils in '../lib/FFmbc-0.7/libavutil/imgutils.pas',
  fifo in '../lib/FFmbc-0.7/libavutil/fifo.pas',
  file_ in '../lib/FFmbc-0.7/libavutil/file_.pas',
  ctypes in '../lib/FFmbc-0.7/ctypes.pas',
  swscale in '../lib/FFmbc-0.7/libswscale/swscale.pas',
  avdevice in '../lib/FFmbc-0.7/libavdevice/avdevice.pas',
  postprocess in '../lib/FFmbc-0.7/libpostproc/postprocess.pas';

procedure SaveFrame(pFrameRGB: PAVFrame; width: integer; height: integer; iFrame: integer);
var
  bmp: TBitmap;
  i: integer;
begin
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf32bit;
    bmp.Width := width;
    bmp.Height := height;

    for i := 0 to bmp.Height - 1 do
      CopyMemory ( bmp.ScanLine[i], pointer(integer(pFrameRGB.data[0]) + bmp.Width * 4 * i), bmp.Width * 4);

    bmp.SaveToFile(format('frame_%d.bmp', [iFrame]));
  finally
    bmp.free;
  end;
end;

var
  i, videoStream  : integer;
  src_filename    : ansistring;
  pFormatCtx      : PAVFormatContext = nil;
  pCodecCtx       : PAVCodecContext = nil;
  pCodec          : PAVCodec = nil;
  optionsDict     : PAVDictionary = nil;
  pFrame          : PAVFrame = nil;
  pFrameRGB       : PAVFrame = nil;
  packet          : TAVPacket;
  frameFinished   : integer;
  numBytes        : integer;
  buffer          : pcuint8 = nil;
  sws_ctx         : PSwsContext = nil;

begin
  try
    if (ParamCount < 1) then
    begin
      writeln('Please provide a movie file');
      exit;
    end;

    src_filename:=(AnsiString(ParamStr(1)));

    // Register all formats and codecs
    av_register_all();

    // Open video file
    if (avformat_open_input(@pFormatCtx, PAnsiChar(src_filename), nil, nil)<>0) then
    begin
      writeln(format('Could not open source file %s', [src_filename]));
      exit;
    end;

    // Retrieve stream information
    if avformat_find_stream_info(pFormatCtx , nil) < 0 then
    begin
      writeln(format('Could not find stream information', []));
      exit;
    end;

    // Dump information about file onto standard error
    av_dump_format(pFormatCtx, 0, PAnsiChar(src_filename), 0);

    // Find the first video stream
    videoStream:=-1;
    for i:=0 to pFormatCtx.nb_streams-1 do
    begin
      if pFormatCtx.streams^.codec.codec_type =  AVMEDIA_TYPE_VIDEO then
      begin
        videoStream := i;
        // Get a pointer to the codec context for the video stream
        pCodecCtx:=pFormatCtx.streams^.codec;
        break;
      end;
      inc(pFormatCtx.streams);
    end;

    if videoStream=-1 then
    begin
      writeln('Didn''t find a video stream');
      exit;
    end;

    // Find the decoder for the video stream
    pCodec:=avcodec_find_decoder(pCodecCtx.codec_id);
    if not assigned(pCodec) then
    begin
      writeln('Unsupported codec!');
      exit;
    end;

    // Open codec
    if avcodec_open2(pCodecCtx, pCodec, @optionsDict)<0 then
    begin
      writeln('Could not open codec');
      exit;
    end;

    // Allocate video frame
    pFrame:=avcodec_alloc_frame;

    // Allocate an AVFrame structure
    pFrameRGB:=avcodec_alloc_frame();
    if not assigned(pFrameRGB) then
    begin
      writeln('Could not allocate AVFrame structure');
      exit;
    end;

    // Determine required buffer size and allocate buffer
    numBytes:=avpicture_get_size(PIX_FMT_RGB24, pCodecCtx.width,  pCodecCtx.height);
    buffer:=av_malloc(numBytes*sizeof(pcuint8));

    sws_ctx :=
    sws_getContext
    (
        pCodecCtx.width,
        pCodecCtx.height,
        pCodecCtx.pix_fmt,
        pCodecCtx.width,
        pCodecCtx.height,
        PIX_FMT_RGB32,
        SWS_BILINEAR,
        nil,
        nil,
        nil
    );

    // Assign appropriate parts of buffer to image planes in pFrameRGB
    // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
    // of AVPicture
    avpicture_fill(PAVPicture(pFrameRGB), buffer, PIX_FMT_RGB32, pCodecCtx.width, pCodecCtx.height);

    // Read frames and save first five frames to disk
    i:=0;
    while(av_read_frame(pFormatCtx, packet)>=0) do
    begin
      // Is this a packet from the video stream?
      if(packet.stream_index=videoStream) then
      begin
        // Decode video frame
        avcodec_decode_video2(pCodecCtx, pFrame, frameFinished, @packet);

        // Did we get a video frame?
        if frameFinished>0 then
        begin
	        // Convert the image from its native format to RGB
          sws_scale
          (
            sws_ctx,
            @pFrame.data,
            @pFrame.linesize,
            0,
            pCodecCtx.height,
            @pFrameRGB.data,
            @pFrameRGB.linesize
          );

	        // Save the frame to disk
          inc(i);
	        if(i<=5)  then
          begin
	          SaveFrame(pFrameRGB, pCodecCtx.width, pCodecCtx.height, i);
          end;
        end;
        // Free the packet that was allocated by av_read_frame
        av_free_packet(@packet);
      end;
    end;

    // Free the RGB image
    av_free(buffer);
    av_free(pFrameRGB);

    // Free the YUV frame
    av_free(pFrame);

    // Close the codec
    avcodec_close(pCodecCtx);

    // Close the video file
    av_close_input_file(pFormatCtx);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.




