(*
 * Copyright (c) 2003 Fabrice Bellard
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *)

(**
 * @file
 * libavformat API example.
 *
 * Output a media file in any supported libavformat format.
 * The default codecs are used.
 * @example doc/examples/muxing.c
 *)

program muxing_;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.StrUtils,
  System.SysUtils,
  System.Classes,
  math,
  VCL.Graphics,
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

type
  va_list = array[0..$FFFF] of pointer;


(* 5 seconds stream duration *)
const
  STREAM_DURATION   = 30.0;
  STREAM_FRAME_RATE = 25; (* 25 images/s *)
  STREAM_NB_FRAMES  = (STREAM_DURATION * STREAM_FRAME_RATE);
  STREAM_PIX_FMT   = PIX_FMT_YUV422P10LE; (* default pix_fmt *) //yuv444p10
  sws_flags        : integer = SWS_BICUBIC;

var
  OperBegin, OperEnd: TTimeStamp;


(**
 * Convert an error code into a text message.
 * @param error Error code to be converted
 * @return Corresponding error text (not thread-safe)
 *)
function get_error_text(const error : integer): ansistring;
var
  error_buffer: array[0..254] of ansichar;
begin
    av_strerror(error, error_buffer, sizeof(error_buffer));
    result:=ansistring(error_buffer);
end;

(** Write the trailer of the output file container. *)
Function write_output_file_trailer(output_format_context: PAVFormatContext): integer;
var
  error : integer;
begin
  error := av_write_trailer(output_format_context);
  if (error < 0) then
  begin
    //format('Could not write output file trailer (error %s)',[get_error_text(error)]);
    result:=error;
  end;
  result:=0;
end;

(** Write the header of the output file container. *)
function write_output_file_header(output_format_context : PAVFormatContext): integer;
var
  error : integer;
begin
  error:=avformat_write_header(output_format_context, nil);
  if (error < 0) then
  begin
    //format('Could not write output file header (error %s)',[get_error_text(error)]);
    result:=error;
  end;
  result:=0;
end;

(** Initialize one data packet for reading or writing. *)
procedure init_packet(var packet: TAVPacket);
begin
    av_init_packet(packet);
    (** Set the packet data and size so that it is recognized as being empty. *)
    packet.data := nil;
    packet.size := 0;
end;

(**************************************************************)
(* audio output *)
var
  t, tincr, tincr2        : Single;
  samples                 : PCint16;
  audio_outbuf            : pByteArray;
  audio_outbuf_size       : integer;
  audio_input_frame_size  : integer;




procedure DoSomethingWithTheImage (pCodecCtx: PAVCodecContext; pFrameRGB: PAVFrame);
var
  bmp: TBitmap;
  i: integer;
begin
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf24bit;
    bmp.Width := pCodecCtx.width;
    bmp.Height := pCodecCtx.height;

    for i := 0 to bmp.Height - 1 do
      CopyMemory ( bmp.ScanLine [i], pointer (integer (pFrameRGB.data [0]) + bmp.Width * 3 * i), bmp.Width * 3 );

    bmp.SaveToFile ( format ( 'c:\temp\example_%d.bmp', [GetTickCount] ) );
  finally
    bmp.free;
  end;
end;



(*
 * add an audio output stream
 * OK
 *)
function add_audio_stream(oc: PAVFormatContext; codec_id: TCodecID): PAVStream;
var
  c: PAVCodecContext;
  st: PAVStream;
begin
  st:=av_new_stream(oc, 1);
  if not assigned(st) then
  begin
    writeln('Could not alloc stream');
    exit;
  end;

  c:= st.codec;
  c.codec_id:=codec_id;
  c.codec_type:=AVMEDIA_TYPE_AUDIO;

  (* put sample parameters *)
  c.sample_fmt:=AV_SAMPLE_FMT_S16;
  c.bit_rate:=64000;
  c.sample_rate:=44100;
  c.channels:=2;

  //some formats want stream headers to be separate
  if (oc.oformat.flags and AVFMT_GLOBALHEADER)>0 then
    c.flags:=c.flags or CODEC_FLAG_GLOBAL_HEADER;

  result:=st;
end;


(*
 * OK
 *)
Procedure open_audio(oc: PAVFormatContext; st: PAVStream);
var
  c     : PAVCodecContext;
  codec : PAVCodec;
begin
  c := st.codec;

  (* find the audio encoder *)
  codec := avcodec_find_encoder(c.codec_id);
  if not assigned(codec) then
  begin
    writeln('codec not found');
    exit;
  end;

  (* open it *)
  if (avcodec_open(c, codec) < 0) then
  begin
    writeln('Could not open audio codec');
    exit;
  end;

  (* init signal generator *)
    t     := 0;
    tincr := 2 * M_PI * 110.0 / c.sample_rate;
    (* increment frequency by 110 Hz per second *)
    tincr2 := 2 * M_PI * 110.0 / c.sample_rate / c.sample_rate;

    audio_outbuf_size:=10000;
    audio_outbuf:=av_malloc(audio_outbuf_size);

    if c.frame_size<=1 then
    begin
      audio_input_frame_size:= audio_outbuf_size div c.channels;
      case st.codec.codec_id of
        CODEC_ID_PCM_S16LE :
          begin

          end;
        CODEC_ID_PCM_S16BE :
          begin

          end;
        CODEC_ID_PCM_U16LE :
          begin

          end;
        CODEC_ID_PCM_U16BE :
          begin
            audio_input_frame_size:= audio_input_frame_size  shr 1;
          end;
      end;
    end else audio_input_frame_size:= c.frame_size;

    samples := av_malloc(audio_input_frame_size * av_get_bytes_per_sample(c.sample_fmt) *  c.channels);
    if not Assigned(samples) then
    begin
      writeln('Could not allocate audio samples buffer');
      exit;
    end;

end;


(* Prepare a 16 bit dummy audio frame of 'frame_size' samples and
 * 'nb_channels' channels. *)
Procedure get_audio_frame(samples : pcint16; frame_size : integer; nb_channels : integer);
var
    j, i, v: integer;

    q : pcint16;
begin
  q := samples;
  for j := 0 to frame_size-1 do
  begin
    v := round(sin(t) * 10000);
    //v:=Round(24576.0 * sin((i*2.0*PI) / 48.0));
    for i := 0 to nb_channels-1 do
    begin
      PSmallInt(q)^:=v;
      inc(PSmallInt(q),1);
      t     := t+tincr;
      tincr := tincr+tincr2;
    end;
  end;
end;

Procedure write_audio_frame(oc: PAVFormatContext; st: PAVStream);
var
   c :  PAVCodecContext;
   pkt :  TAVPacket;

begin

  av_init_packet(&pkt);
  c := st.codec;

  get_audio_frame(samples, audio_input_frame_size, c.channels);
  pkt.size:= avcodec_encode_audio(c, pcuint8(audio_outbuf), audio_outbuf_size, samples);

  if (Assigned(c.coded_frame) and (c.coded_frame.pts<> AV_NOPTS_VALUE)) then
  begin
    pkt.pts:= av_rescale_q(c.coded_frame.pts, c.time_base, st.time_base);
  end;

  pkt.flags:=pkt.flags or AV_PKT_FLAG_KEY;
  pkt.stream_index:=st.index;
  pkt.data:= pByteArray(audio_outbuf);

  (* Write the compressed frame to the media file. *)
  if (av_interleaved_write_frame(oc, @pkt) <> 0) then
  begin
    writeln('Error while writing audio frame');
    exit;
  end;
end;


Procedure close_audio(oc: PAVFormatContext; st: PAVStream);
begin
  avcodec_close(st.codec);
  av_free(samples);
  av_free(audio_outbuf);
end;


var
  (**************************************************************)
  (* video output *)
  picture, tmp_picture : PAVFrame;
  video_outbuf  : pByteArray;
  frame_count, video_outbuf_size : integer;

 (* Add a video output stream. *)
Function add_video_stream(oc: PAVFormatContext; codec_id: TCodecID): PAVStream;
var
  c: PAVCodecContext;
  st: PAVStream;
begin
  st:= av_new_stream(oc, 0);
  if not assigned(st) then
  begin
    writeln('Could not alloc video stream');
    exit;
  end;
  c:= st.codec;
  c.codec_id:= codec_id;
  c.codec_type:= AVMEDIA_TYPE_VIDEO;
  c.width:=1920;
  c.height:=1080;
  c.time_base.den := 25;
  c.time_base.num := 1;
  c.thread_count:=8;
  c.thread_type := FF_THREAD_SLICE;
  c.profile:=3;
  c.debug := 1;


  (**
     * Global quality for codecs which cannot change it per frame.
     * This should be proportional to MPEG-1/2/4 qscale.
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.flags:=c.flags or CODEC_FLAG_QSCALE;
  c.global_quality := FF_QP2LAMBDA * 4;

  (**
     * number of bits the bitstream is allowed to diverge from the reference.
     *           the reference can be CBR (for CBR pass1) or VBR (for pass2)
     * - encoding: Set by user; unused for constant quantizer encoding.
     * - decoding: unused
  *)
  c.bit_rate_tolerance:=4000000;
  c.bit_rate := 16448000;//1200000;

  (**
     * Motion estimation algorithm used for video coding.
     * 1 (zero), 2 (full), 3 (log), 4 (phods), 5 (epzs), 6 (x1), 7 (hex),
     * 8 (umh), 9 (iter), 10 (tesa) [7, 8, 10 are x264 specific, 9 is snow specific]
     * - encoding: MUST be set by user.
     * - decoding: unused
  *)
  c.me_method:=5;

  (**
     * the number of pictures in a group of pictures, or 0 for intra_only
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.gop_size := 12;

  c.pix_fmt:=PIX_FMT_YUV422P10LE;


  (* - encoding parameters *)
  c.qcompress:= 0.5;  ///< amount of qscale change between easy & hard scenes (0.0-1.0)
  c.qblur:=0.5;      ///< amount of qscale smoothing over time (0.0-1.0)

  (**
     * minimum quantizer
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.qmin:=2;

  (**
     * maximum quantizer
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.qmax:=31;

  (**
     * maximum quantizer difference between frames
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.max_qdiff:=3;

  (**
     * maximum number of B-frames between non-B-frames
     * Note: The output will be delayed by max_b_frames+1 relative to the input.
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.max_b_frames:=0;

  (**
     * qscale factor between IP and B-frames
     * If > 0 then the last P-frame quantizer will be used (q= lastp_q*factor+offset).
     * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
     * - encoding: Set by user.
     * - decoding: unused
  *)
  c.b_quant_factor:=1.25;


  c.flags := c.flags or CODEC_FLAG_INTERLACED_DCT or CODEC_FLAG_INTERLACED_ME;
  (**
     * Video contains at least one interlaced frame.
     * For codec that support mixing interlaced and progressive frames, you must check
     * AVFrame->interlaced_frame which will not be set for progressive frames.
     * Values:
     * -1: forced progressive (dv progressive or stored interlaced)
     *  0: progressive,
     *  1: top field first,
     *  2: bottom field first
     * - encoding: unused
     * - decoding: Set by libavcodec
    *)
  c.interlaced := 1;


  c.timecode_frame_start := 1000000;


  (* Some formats want stream headers to be separate. *)
   if ((oc.oformat.flags and AVFMT_GLOBALHEADER) > 0) then
       c.flags := c.flags or CODEC_FLAG_GLOBAL_HEADER;

   result:=st;
end;

function alloc_picture(pix_fmt: TAVPixelFormat; width: integer; height: integer): PAVFrame;
var
  picture : PAVFrame;
  picture_buf: pcuint8;
  size  : integer;
begin
  picture:= avcodec_alloc_frame;
  if not assigned(picture) then
  begin
    result:=nil;
    exit;
  end;
  size:=avpicture_get_size(pix_fmt, width, height);
  picture_buf:=av_malloc(size);
  if not assigned(picture_buf) then
  begin
    av_free(picture);
    result:=nil;
    exit;
  end;

  avpicture_fill(PAVPicture(picture), picture_buf, pix_fmt, width, height);

  result:=picture;
end;


Procedure open_video(oc: PAVFormatContext; st: PAVStream);
var
  codec : PAVCodec;
  c : PAVCodecContext;
begin

  c := st.codec;
  (* find the video encoder *)
  codec:= avcodec_find_encoder(c.codec_id);
  if not assigned(codec) then
  begin
    writeln('video codec not found');
    exit;
  end;


  (* open the codec *)
  if (avcodec_open(c, codec) < 0) then
  begin
    writeln('Could not open video codec');
    exit;
  end;

  video_outbuf:=nil;

  if (oc.oformat.flags and AVFMT_RAWPICTURE)<=0 then
  begin
    (* allocate output buffer *)
    (* XXX: API change will be done *)
    (* buffers passed into lav* can be allocated any way you prefer,
       as long as they're aligned enough for the architecture, and
       they're freed appropriately (such as using av_free for buffers
       allocated with av_malloc) *)
    video_outbuf_size:=avpicture_get_size(PIX_FMT_YUV422P10LE, c.width, c.height);
    video_outbuf_size:=video_outbuf_size*2;
    video_outbuf:= av_malloc(video_outbuf_size);
  end;

  (* allocate the encoded raw picture *)
  picture:= alloc_picture(c.pix_fmt, c.width, c.height);
  if not assigned(picture) then
  begin
    writeln('Could not allocate picture');
    exit;
  end;


  (* if the output format is not YUV420P, then a temporary YUV420P
       picture is needed too. It is then converted to the required
       output format *)
  tmp_picture:=nil;
  if c.pix_fmt<>PIX_FMT_YUV422P10LE then
  begin
    tmp_picture:=alloc_picture(PIX_FMT_YUV422P10LE, c.width, c.height);
    if not assigned(tmp_picture) then
    begin
      writeln('Could not allocate temporary picture');
      exit;
    end;
  end;
end;

(* Prepare a dummy image. *)
Procedure fill_yuv_image(pict : PAVFrame; frame_index: integer;
                           width: integer; height: integer);
var
  x, y, i : integer;
begin
  i := frame_index;
  (* Y *)
  for y := 0 to height-1 do
    for x := 0 to width-1 do
      pByte(pict.data[0])[y * pict.linesize[0] + x] := x + y + i * 3;

  (* Cb and Cr *)
  for y := 0 to (height div 2)-1 do
    for x := 0 to (width div 2)-1 do
    begin
      pByte(pict.data[1])[y * pict.linesize[1] + x] := 128 + y + i * 2;
      pByte(pict.data[2])[y * pict.linesize[2] + x] := 64 + x + i * 5;
    end;
end;

Procedure write_video_frame(oc: PAVFormatContext; st: PAVStream);
var
  out_size, ret : integer;
  c : PAVCodecContext;
  img_convert_ctx : PSwsContext;
  pkt : TAVPacket;
begin
  c := st.codec;

  if (frame_count >= STREAM_NB_FRAMES) then
  begin
        (* No more frames to compress. The codec has a latency of a few
         * frames if using B-frames, so we get the last frames by
         * passing the same picture again. *)
  end else
  begin
    if (c.pix_fmt <> PIX_FMT_YUV422P10LE) then
    begin
      (* as we only generate a YUV420P picture, we must convert it
       * to the codec pixel format if needed *)
     if not assigned(img_convert_ctx) then
     begin
        img_convert_ctx:= sws_getContext(c.width, c.height,
                                        PIX_FMT_YUV422P10LE,
                                        c.width, c.height,
                                        c.pix_fmt, sws_flags, 0, 0, 0);
        if not assigned(img_convert_ctx) then
        begin
          writeln('Cannot initialize the conversion context');
          exit;
        end;
     end;


     fill_yuv_image(tmp_picture, frame_count, c.width, c.height);
     sws_scale(img_convert_ctx ,@tmp_picture.data, @tmp_picture.linesize,
                     0, c.height, @picture.data, @picture.linesize);
    end else
    begin
       fill_yuv_image(picture, frame_count, c.width, c.height);
    end;
  end;


  if (oc.oformat.flags and AVFMT_RAWPICTURE)>0 then
  begin

    (* Raw video case - directly store the picture in the packet *)

    av_init_packet(pkt);

    pkt.flags         := pkt.flags or AV_PKT_FLAG_KEY;
    pkt.stream_index  := st.index;
    pkt.data          := picture.data[0];
    pkt.size          := sizeof(TAVPicture);

    ret := av_interleaved_write_frame(oc, @pkt);
  end else
  begin
    //DoSomethingWithTheImage(c, picture);

    (* encode the image *)
    out_size:= avcodec_encode_video(c, video_outbuf, video_outbuf_size, picture);


    (* if zero size, it means the image was buffered *)
    if out_size>0 then
    begin
      av_init_packet(pkt);
      if c.coded_frame.pts<>AV_NOPTS_VALUE then
        pkt.pts:= av_rescale_q(c.coded_frame.pts, c.time_base, st.time_base);
      if c.coded_frame.key_frame>0 then
        pkt.flags:= pkt.flags or AV_PKT_FLAG_KEY;
      pkt.stream_index:= st.index;
      pkt.data:=video_outbuf;
      pkt.size:=out_size;
      ret:= av_interleaved_write_frame(oc, @pkt);
    end else
    begin
      ret:=0;
    end;
  end;

  if ret<>0 then
  begin
    writeln('Error while writing video frame');
    exit;
  end;

  inc(frame_count)

end;

Procedure close_video(oc: PAVFormatContext; st: PAVStream);
begin
    avcodec_close(st.codec);
    av_free(picture.data[0]);
    av_free(picture);
    if assigned(tmp_picture) then
    begin
      av_free(tmp_picture.data[0]);
      av_free(tmp_picture);
    end;
    av_free(video_outbuf);
end;

var
  filename : PAnsiChar;
  fmt: PAVOutputFormat;
  out_fmt_ctx : PAVFormatContext;
  audio_st, video_st: PAVStream;
  audio_codec, video_codec : PAVCodec;
  audio_pts, video_pts: double;
  ret, i: integer;
  bmp: TBitmap;
begin
  try
    (* Initialize libavcodec, and register all codecs and formats. *)
    av_register_all();
    av_log_set_level(AV_LOG_DEBUG);

    if (ParamCount <> 1) then
    begin
      writeln(format('usage: %s output_file'+#10#13+
               'API example program to output a media file with libavformat.'+#10#13+
               'This program generates a synthetic audio and video stream, encodes and'+#10#13+
               'muxes them into a file named output_file.'+#10#13+
               'The output format is automatically guessed according to the file extension.'+#10#13+
               'Raw images can also be output by using ''%%d'' in the filename.'+#10#13, [ParamStr(0)]));
      exit;
    end;

    filename:=PansiChar(AnsiString(ParamStr(1)));

    avformat_alloc_output_context2(@out_fmt_ctx, nil, PAnsiChar('mov'), filename);


    if not assigned(out_fmt_ctx) then
    begin
      writeln('Could not deduce output format from file extension.');
      exit;
    end;



    fmt := out_fmt_ctx.oformat;

    (* Add the audio and video streams using the default format codecs
     * and initialize the codecs. *)
    video_st := nil;
    audio_st := nil;

    if (fmt.video_codec <> CODEC_ID_NONE)  then
        video_st := add_video_stream(out_fmt_ctx,  CODEC_ID_PRORES);

    if (fmt.audio_codec <> CODEC_ID_NONE) then
        audio_st := add_audio_stream(out_fmt_ctx, CODEC_ID_PCM_S16LE);

    av_dump_format(out_fmt_ctx, 0, filename, 1);

    (* Now that all the parameters are set, we can open the audio and
     * video codecs and allocate the necessary encode buffers. *)
    if assigned(video_st) then
      open_video(out_fmt_ctx, video_st);
    if assigned(audio_st) then
      open_audio(out_fmt_ctx,audio_st);

    av_dump_format(out_fmt_ctx, 0, filename, 1);


    (* open the output file, if needed *)
    if (fmt.flags and AVFMT_NOFILE) <=0 then
    begin
        if (avio_open(out_fmt_ctx.pb, filename, AVIO_FLAG_WRITE) < 0) then
        begin
          writeln(Format('Could not open "%s"', [filename]));
          exit;
        end;
    end;

    (* Write the stream header, if any. *)
    if (write_output_file_header(out_fmt_ctx) < 0) then
    begin
      writeln('Error occurred when opening output file');
      exit;
    end;


    while true do
    begin
      (* Compute current audio and video time. *)
      if Assigned(audio_st)then
        audio_pts := audio_st.pts.val * audio_st.time_base.num / audio_st.time_base.den
      else
        audio_pts := 0.0;

      if Assigned(video_st) then
        video_pts := video_st.pts.val * video_st.time_base.num / video_st.time_base.den
      else
        video_pts := 0.0;

      if ((not Assigned(audio_st) or (audio_pts >= STREAM_DURATION)) and
            (not Assigned (video_st) or (video_pts >= STREAM_DURATION))) then
        break;


      (* write interleaved audio and video frames *)
      if (not assigned(video_st) or (Assigned(video_st) and Assigned(audio_st) and (audio_pts < video_pts))) then
      begin
        write_audio_frame(out_fmt_ctx, audio_st);
      end else begin
        write_video_frame(out_fmt_ctx, video_st);
      end;
    end;


    (* Write the trailer, if any. The trailer must be written before you
     * close the CodecContexts open when you wrote the header; otherwise
     * av_write_trailer() may try to use memory that was freed on
     * av_codec_close(). *)
    write_output_file_trailer(out_fmt_ctx);

    (* Close each codec. *)
    if Assigned(video_st) then
      close_video(out_fmt_ctx, video_st);
    if Assigned(audio_st) then
      close_audio(out_fmt_ctx, audio_st);




    (* Free the streams. *)
    for i:= 0 to out_fmt_ctx.nb_streams-1 do
    begin
      {av_freep(oc.streams^.codec);
      av_freep(oc.streams^);
      inc(oc.streams);  }
    end;


    if (fmt.flags and AVFMT_NOFILE)<AVFMT_NOFILE then
    begin
      (* Close the output file. *)
      avio_close(out_fmt_ctx.pb);
    end;

    (* free the stream *)
    av_free(out_fmt_ctx);
    readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.





