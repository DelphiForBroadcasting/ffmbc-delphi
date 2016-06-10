(*
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
 *
 * Conversion to Pascal Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 *
 * Conversion of libavutil/dict.h
 * avutil version 51.11.0
 *
 *)

(**
 * @file
 * Public dictionary API.
 * @deprecated
 *  AVDictionary is provided for compatibility with libav. It is both in
 *  implementation as well as API inefficient. It does not scale and is
 *  extremely slow with large dictionaries.
 *  It is recommended that new code uses our tree container from tree.c/h
 *  where applicable, which uses AVL trees to achieve O(log n) performance.
 *)

{$IfNDef AVUTIL_DICT_H}
	{$Define AVUTIL_DICT_H}
	
(**
 * @defgroup dict_api Public Dictionary API
 * @{
 * Dictionaries are used for storing key:value pairs. To create
 * an AVDictionary, simply pass an address of a NULL pointer to
 * av_dict_set(). NULL can be used as an empty dictionary wherever
 * a pointer to an AVDictionary is required.
 * Use av_dict_get() to retrieve an entry or iterate over all
 * entries and finally av_dict_free() to free the dictionary
 * and all its contents.
 *
 * @code
 * AVDictionary *d = NULL;                // "create" an empty dictionary
 * av_dict_set(&d, "foo", "bar", 0);      // add an entry
 *
 * char *k = av_strdup("key");            // if your strings are already allocated,
 * char *v = av_strdup("value");          // you can avoid copying them like this
 * av_dict_set(&d, k, v, AV_DICT_DONT_STRDUP_KEY | AV_DICT_DONT_STRDUP_VAL);
 *
 * AVDictionaryEntry *t = NULL;
 * while (t = av_dict_get(d, "", t, AV_DICT_IGNORE_SUFFIX)) {
 *     <....>                             // iterate over all entries in d
 * }
 *
 * av_dict_free(&d);
 * @endcode
 *
 * @}
 *)

	
	
const
  AV_DICT_MATCH_CASE      = 1;
  AV_DICT_IGNORE_SUFFIX   = 2;
  AV_DICT_DONT_STRDUP_KEY = 4;    (**< Take ownership of a key that's been
                                       allocated with av_malloc() and children. *)
  AV_DICT_DONT_STRDUP_VAL = 8;    (**< Take ownership of a value that's been
                                       allocated with av_malloc() and chilren. *)
  AV_DICT_DONT_OVERWRITE  = 16;   (**< Don't overwrite existing entries. *)
  AV_DICT_APPEND          = 32;   (**< If the entry already exists, append to it.  Note that no
                                    delimiter is added, the strings are simply concatenated. *)
									
(**
 * Used attributes: "language", "mime"
 *)
 
 
type
  PAVMetadataAttribute = ^TAVMetadataAttribute;
  TAVMetadataAttribute = record
    key:   PAnsiChar;
    value: PAnsiChar;
  end;	
 
type
  PAVMetadataAttributes = ^TAVMetadataAttributes;
  TAVMetadataAttributes = record
    count: cuint;
    elems: PAVMetadataAttribute;
  end;	 
  
type
  TAVMetadataType = (
    METADATA_STRING, ///< UTF-8
    METADATA_INT,
    METADATA_FLOAT,
    METADATA_BYTEARRAY
  );
 
type
  PAVDictionaryEntry = ^TAVDictionaryEntry;
  TAVDictionaryEntry = record
    key			: PAnsiChar;
    value		: PAnsiChar;
	type_		: TAVMetadataType;
	len			: cuint;
	attributes	: PAVMetadataAttributes; 
  end;
  
(* with the "help" of libavutil/internal.h: *)
type
  PPAVDictionary = ^PAVDictionary;
  PAVDictionary = ^TAVDictionary;
  TAVDictionary = TAVMetadataAttribute; // ????????????????????????????????????????????????????  len: 102; dict.h; typedef struct AVDictionary AVDictionary;

(**
 * Get a dictionary entry with matching key.
 *
 * @param prev Set to the previous matching element to find the next.
 *             If set to NULL the first matching element is returned.
 * @param flags Allows case as well as suffix-insensitive comparisons.
 * @return Found entry or NULL, changing key or value leads to undefined behavior.
 *)
function av_dict_get(m: PAVDictionary; const key: PAnsiChar; const prev: PAVDictionaryEntry; flags: cint): PAVDictionaryEntry;
  cdecl; external LIB_AVUTIL;

(**
 * Set the given entry in *pm, overwriting an existing entry.
 *
 * @param pm pointer to a pointer to a dictionary struct. If *pm is NULL
 * a dictionary struct is allocated and put in *pm.
 * @param key entry key to add to *pm (will be av_strduped depending on flags)
 * @param value entry value to add to *pm (will be av_strduped depending on flags).
 *        Passing a NULL value will cause an existing tag to be deleted.
 * @return >= 0 on success otherwise an error code <0
 *)
function av_dict_set(var pm: PAVDictionary; const key: PAnsiChar; const value: PAnsiChar; flags: cint): cint;
  cdecl; external LIB_AVUTIL;
function av_dict_unset(m: PAVDictionary; const key: PAnsiChar): cint;
  cdecl; external LIB_AVUTIL;
   
(**
 * Sets the given tag in m
 * @param pm pointer to a pointer to a metadata struct. If *pm is NULL
 * @param e point to the newly created entry
 * @param type tag type
 * @param key tag key to add to m (will be av_strduped depending on flags)
 * @param value tag value to add to m (will be av_strduped depending on flags)
 * @param value tag value len
 * @param flags flags regarding key and value parameters
 * @return >= 0 on success otherwise an error code <0
 *)
function av_dict_set_custom(var pm: PAVDictionary; var e: PAVDictionaryEntry; type_: TAVMetadataType; const key: PAnsiChar; const value: PAnsiChar; len: cuint; flags: cint): cint;
  cdecl; external LIB_AVUTIL;
function av_dict_set_int(var pm: PAVDictionary; const key: PAnsiChar; value: cint): cint;
  cdecl; external LIB_AVUTIL;
function av_dict_set_float(var pm: PAVDictionary; const key: PAnsiChar; value: cdouble): cint;
  cdecl; external LIB_AVUTIL;

(**
 * Get attribute of the given metadata with matching key.
 * @return Found tag or NULL, changing key or value leads to undefined behavior.
 *)
function av_metadata_get_attribute(tag: PAVDictionaryEntry; const key: PAnsiChar): PAnsiChar;
 cdecl; external LIB_AVUTIL;
(**
 * Sets attribute to the given tag
 * @param key attribute key to add to tag (will be av_strduped)
 * @param value attribute value to add to tag (will be av_strduped)
 * @return >= 0 on success otherwise an error code <0
 *)
function av_metadata_set_attribute(tag: PAVDictionaryEntry; const key: PAnsiChar; const value: PAnsiChar): cint;
 cdecl; external LIB_AVUTIL;
function av_metadata_copy_attributes(otag: PAVDictionaryEntry; itag: PAVDictionaryEntry): cint;
 cdecl; external LIB_AVUTIL;

(**
 * Copy entries from one AVDictionary struct into another.
 * @param dst pointer to a pointer to a AVDictionary struct. If *dst is NULL,
 *            this function will allocate a struct for you and put it in *dst
 * @param src pointer to source AVDictionary struct
 * @param flags flags to use when setting entries in *dst
 * @note metadata is read using the AV_DICT_IGNORE_SUFFIX flag
 *)
procedure av_dict_copy(var dst: PAVDictionary; src: PAVDictionary; flags: cint);
  cdecl; external LIB_AVUTIL;

(**
 * Free all the memory allocated for an AVDictionary struct
 * and all keys and values.
 *)
procedure av_dict_free(var m: PAVDictionary);
  cdecl; external LIB_AVUTIL;

{$EndIf} (* AVUTIL_DICT_H *)
  

