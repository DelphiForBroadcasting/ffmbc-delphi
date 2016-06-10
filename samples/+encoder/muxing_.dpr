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

var
  in_ctx : PAVFormatContext;
  out_ctx : PAVFormatContext;
  in_codec_ctx : PAVCodecContext;
  //out_codec_ctx : PAVCodecContext;
  in_codec : PAVCodec;
  out_codec : PAVCodec;
  in_video_st, out_video_st : PAVStream;
  videoStream : integer = -1;


function open_input_file(filename: PAnsiChar): integer;
var
  i: integer;
begin

  // Open video file
  if(av_open_input_file(@in_ctx, filename, nil, 0, nil) <> 0) then
  begin
    result:= -1; // Couldn't open file
    exit;
  end;

    // Retrieve stream information
  if(av_find_stream_info(in_ctx) < 0)  then
  begin
    result:=-1; // Couldn't find stream information
    exit;
  end;

  // Find the first video stream
  for i := 0 to in_ctx.nb_streams-1 do
  begin
    if(PAVStream(in_ctx.streams^).codec.codec_type = AVMEDIA_TYPE_VIDEO) then
    begin
      videoStream := i;
      // Get a pointer to the codec context for the video stream
      in_video_st:=PAVStream(in_ctx.streams^);
      in_codec_ctx := in_video_st.codec;
      break;
    end;
    inc(PAVStream(in_ctx.streams));
  end;

  if(videoStream = -1)  then
  begin
    result:= -1; // Didn't find a video stream
    exit;
  end;

  // Find the decoder for the video stream
  in_codec := avcodec_find_decoder(in_codec_ctx.codec_id);
  if not assigned(in_codec) then
  begin
    writeln('Unsupported input codec!');
    result:= -1; // Codec not found
    exit;
  end;

  // Open codec
  if(avcodec_open2(in_codec_ctx, in_codec, nil) < 0) then
  begin
    result:= -1; // Could not open codec
    exit;
  end;

  result:=0;
end;

function create_out_file(filename : pansichar): integer;
begin
    // Allocate output format context
    avformat_alloc_output_context2(@out_ctx, nil, nil, filename);
    if not Assigned(out_ctx.oformat) then
    begin
        writeln('Could not allocate output format');
        exit;;
    end;

    out_video_st := av_new_stream(out_ctx, 0);
    if not assigned(out_video_st) then
    begin
      writeln('Could not alloc stream');
      exit;
    end;

    // Set encoding options
    out_video_st.codec.codec_id := CODEC_ID_DVVIDEO;
    out_video_st.codec.codec_type := AVMEDIA_TYPE_VIDEO;
    out_video_st.codec.width:=in_codec_ctx.width;
    out_video_st.codec.height:=in_codec_ctx.height;
    out_video_st.codec.time_base.den := 25;
    out_video_st.codec.time_base.num := 1;
    out_video_st.codec.thread_count:=4;
    out_video_st.codec.debug := 1;
    out_video_st.codec.bit_rate_tolerance:=4000000;
    out_video_st.codec.pix_fmt:=PIX_FMT_YUV411P;
    out_video_st.codec.qcompress := 0.5;

    out_video_st.codec.flags := out_video_st.codec.flags or CODEC_FLAG_INTERLACED_DCT or CODEC_FLAG_INTERLACED_ME;
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
    out_video_st.codec.interlaced := 2;


    if(out_ctx.oformat.flags and AVFMT_GLOBALHEADER)=AVFMT_GLOBALHEADER then
      out_video_st.codec.flags := out_video_st.codec.flags or CODEC_FLAG_GLOBAL_HEADER;

    // Find the encoder for the video stream
    out_codec := avcodec_find_encoder(out_video_st.codec.codec_id);
    if not assigned(out_codec) then
    begin
      writeln('Unsupported output codec!');
      result:=-1; // Codec not found
      exit;
    end;
    // Open codec
    if(avcodec_open2(out_video_st.codec, out_codec, nil) < 0) then
    begin
        result:= -1; // Could not open codec
        exit;
    end;

    avio_open(out_ctx.pb, filename, AVIO_FLAG_WRITE);
    write_output_file_header(out_ctx);

    result:= 0;
end;



var
  picture         : PAVFrame;
  picture_size    : integer;
  tmp_picture     : PAVFrame;
  out_size : integer;
  frame_count : integer;
  frame_finished : integer;
  packet, OutPacket : TAVPacket;
  buffer : pcuint8;
  img_convert_ctx : PSwsContext;
  retval : integer;


begin
  try
    (* Initialize libavcodec, and register all codecs and formats. *)
    av_register_all();
    frame_count:=0;
    if (ParamCount <> 2) then
    begin
      writeln(format('usage: %s output_file'+#10#13+
               'API example program to output a media file with libavformat.'+#10#13+
               'This program generates a synthetic audio and video stream, encodes and'+#10#13+
               'muxes them into a file named output_file.'+#10#13+
               'The output format is automatically guessed according to the file extension.'+#10#13+
               'Raw images can also be output by using ''%%d'' in the filename.'+#10#13, [ParamStr(0)]));
      exit;
    end;


    if open_input_file(PansiChar(AnsiString(ParamStr(1))))<0 then
        exit;
    if create_out_file(PansiChar(AnsiString(ParamStr(2))))<0 then
        exit;

    av_dump_format(in_ctx, 0, PansiChar(AnsiString(ParamStr(1))), 0);
    av_dump_format(out_ctx, 0, PansiChar(AnsiString(ParamStr(2))), 1);

    //Allocate frame for decoding
    tmp_picture := avcodec_alloc_frame();

    //Allocate frame fro encoding
    picture := avcodec_alloc_frame();
    avpicture_alloc(PAVPicture(picture), out_video_st.codec.pix_fmt, out_video_st.codec.width, out_video_st.codec.height);



    picture_size := avpicture_get_size(out_video_st.codec.pix_fmt, out_video_st.codec.width, out_video_st.codec.height);
    picture_size:=picture_size*2;

   // avpicture_fill(PAVPicture(picture), buffer, out_codec_ctx.pix_fmt, out_codec_ctx.width, out_codec_ctx.height);

    //Crate scaler context
    img_convert_ctx := sws_getContext(in_codec_ctx.width,  in_codec_ctx.height,  in_codec_ctx.pix_fmt,
                                    out_video_st.codec.width, out_video_st.codec.height, out_video_st.codec.pix_fmt,
                                    SWS_BICUBIC, nil, nil, nil);
    if not assigned(img_convert_ctx) then
    begin
      writeln('Cannot initialize the conversion context');
      exit;
    end;


  init_packet(packet);

  while (av_read_frame(in_ctx, packet) >= 0) do
  begin
    if(packet.stream_index = videoStream) then
    begin
      inc(frame_count);
      writeln(format('Encoding frame %d', [frame_count]));
      //Decode
      retval := avcodec_decode_video2(in_codec_ctx, tmp_picture, frame_finished, @packet);
      if (retval < 0) then
        writeln(format('Error decoding frame %d', [frame_count]));

      if (tmp_picture.pts <> AV_NOPTS_VALUE) then
        tmp_picture.pts := av_rescale_q(packet.pts, in_video_st.time_base, in_codec_ctx.time_base);

      //Scale
      retval := sws_scale(img_convert_ctx, @tmp_picture.data, @tmp_picture.linesize,
                               0, out_video_st.codec.height, @picture.data, @picture.linesize);
      if (retval < 1) then
        writeln(format('Error scaling frame %d', [frame_count]));


      if (picture.pts <> AV_NOPTS_VALUE) then
        picture.pts := av_rescale_q(picture.pts, in_codec_ctx.time_base, out_video_st.codec.time_base);

      buffer:=nil;
      buffer:=av_malloc(picture_size);

      //Encode
      out_size := avcodec_encode_video(out_video_st.codec, buffer, picture_size, picture);
      if (out_size < 0) then
      begin
        writeln(format('Error encoding frame %d', [frame_count]));
      end else
      begin
        init_packet(OutPacket);


        //Write
        //if (out_codec_ctx.coded_frame.pts <> AV_NOPTS_VALUE) then
        //  packet.pts := av_rescale_q(out_codec_ctx.coded_frame.pts, out_codec_ctx.time_base, out_video_st.time_base);
       if (OutPacket.pts <> AV_NOPTS_VALUE) then
          OutPacket.pts := av_rescale_q(packet.pts{out_codec_ctx.coded_frame.pts}, out_video_st.codec.time_base, out_video_st.time_base);
        if (OutPacket.dts <> AV_NOPTS_VALUE) then
          OutPacket.dts := av_rescale_q(packet.dts{out_codec_ctx.coded_frame.pts}, out_video_st.codec.time_base, out_video_st.time_base);


        if (out_video_st.codec.coded_frame.key_frame)>0 then
        begin



          OutPacket.flags := OutPacket.flags or AV_PKT_FLAG_KEY;
          writeln(format('frame %d is key', [frame_count]));
        end;
          OutPacket.stream_index := out_video_st.index;
          OutPacket.data := buffer;
          OutPacket.size := out_size;
          av_interleaved_write_frame(out_ctx, @OutPacket);
        end;

        av_free(buffer);
        av_free_packet(@OutPacket);


      end;
    end;

    write_output_file_trailer(out_ctx);


    av_free_packet(@packet);
    av_free(buffer);
   // av_free(picture);
    av_free(tmp_picture);
    avcodec_close(in_codec_ctx);
    avcodec_close(out_video_st.codec);
    av_close_input_file(in_ctx);
    avio_close(out_ctx.pb);

    readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.





