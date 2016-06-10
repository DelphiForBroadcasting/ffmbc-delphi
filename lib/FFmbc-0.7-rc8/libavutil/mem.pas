(*
 * copyright (c) 2006 Michael Niedermayer <michaelni@gmx.at>
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
 * Conversion of libavutil/mem.h
 * avutil version 51.11.0
 *)



(* 
 * @file
 *memory handling functions 
 *)
 
{$IfNDef AVUTIL_MEM_H}
	{$Define AVUTIL_MEM_H}

(**
 * Allocate a block of size bytes with alignment suitable for all
 * memory accesses (including vectors if available on the CPU).
 * @param size Size in bytes for the memory block to be allocated.
 * @return Pointer to the allocated block, NULL if the block cannot
 * be allocated.
 * @see av_mallocz()
 *)
function av_malloc(size: size_t): pointer;
  cdecl; external LIB_AVUTIL; {av_malloc_attrib av_alloc_size(1)}


(**
 * Allocate or reallocate a block of memory.
 * If ptr is NULL and size > 0, allocate a new block. If 
 * size is zero, free the memory block pointed to by ptr.
 * @param ptr Pointer to a memory block already allocated with
 * av_malloc(z)() or av_realloc() or NULL.
 * @param size Size in bytes for the memory block to be allocated or
 * reallocated.
 * @return Pointer to a newly reallocated block or NULL if the block
 * cannot be allocated or the function is used to free the memory block.
 * @see av_fast_realloc()
 *)
function av_realloc(ptr: pointer; size: size_t): pointer;
  cdecl; external LIB_AVUTIL; {av_alloc_size(2)}

(**
 * Free a memory block which has been allocated with av_malloc(z)() or
 * av_realloc().
 * @param ptr Pointer to the memory block which should be freed.
 * @note ptr = NULL is explicitly allowed.
 * @note It is recommended that you use av_freep() instead.
 * @see av_freep()
 *)
procedure av_free(ptr: pointer);
  cdecl; external LIB_AVUTIL;

(**
 * Allocate a block of size bytes with alignment suitable for all
 * memory accesses (including vectors if available on the CPU) and
 * zeroes all the bytes of the block.
 * @param size Size in bytes for the memory block to be allocated.
 * @return Pointer to the allocated block, NULL if it cannot be allocated.
 * @see av_malloc()
 *)
function av_mallocz(size: size_t): pointer;
  cdecl; external LIB_AVUTIL; {av_malloc_attrib av_alloc_size(1)}

(**
 * Duplicate the string s.
 * @param s string to be duplicated.
 * @return Pointer to a newly allocated string containing a
 * copy of s or NULL if the string cannot be allocated.
 *)
function av_strdup(const s: PAnsiChar): PAnsiChar;
  cdecl; external LIB_AVUTIL; {av_malloc_attrib}

(**
 * Free a memory block which has been allocated with av_malloc(z)() or
 * av_realloc() and set the pointer pointing to it to NULL.
 * @param ptr Pointer to the pointer to the memory block which should
 * be freed.
 * @see av_free()
 *)
procedure av_freep (ptr: pointer);
  cdecl; external LIB_AVUTIL;

(**
 * Add an element to a dynamic array.
 *
 * @param tab_ptr Pointer to the array.
 * @param nb_ptr  Pointer to the number of elements in the array.
 * @param elem    Element to be added.
 *)
procedure av_dynarray_add(tab_ptr: pointer; nb_ptr: PCint; elem: pointer);
  cdecl; external LIB_AVUTIL;

{$EndIf} (* AVUTIL_MEM_H *)



