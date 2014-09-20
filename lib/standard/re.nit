# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2014 Alexis Laferrière <alexis.laf@xymus.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Regular expression support for all services based on `Pattern`
#
# Implemented using libc regular expressions.
#
# The main entities are `Text::to_re` and `Regex`.
module re

import string_search
import gc
import error

in "C Header" `{
	#include <sys/types.h>
	#include <regex.h>
`}

# Main extern class to wrap libc regular expression support
#
# It is recommanded to use the higher level API offered by the class `Regex`,
# but it can still be used for advanced purpose or in optimized code.
#
# To use this class and other `private` entities of this module, use `intrude import standard::re`
private extern class NativeRegex `{ regex_t* `}
	# Allocate a new `NativeRegex`, it must then be compiled using `regcomp` before calling `regexec`
	new malloc `{ return malloc(sizeof(regex_t)); `}

	# Compile the regular expression `regex` into a form that is suitable for subsequent `regexec` searches
	fun regcomp(regex: NativeString, cflags: Int): Int `{
		return regcomp(recv, regex, cflags);
	`}

	# Match `string` against the precompiled pattern buffer of `self`, locating matches
	#
	# `nmatch` and `pmatch` are used to provide information regarding the location of any matches.
	# `eflags` may be the bitwise-or of one or both of `flag_notbol` and `flag_noteol`.
	fun regexec(string: NativeString, nmatch: Int, pmatch: NativeMatchArray, eflags: Int): Int `{
		return regexec(recv, string, nmatch, pmatch, eflags);
	`}

	# Match `string` against the precompiled pattern buffer of `self`, do not locate matches
	#
	# `eflags` may be the bitwise-or of one or both of `flag_notbol` and `flag_noteol`.
	fun regexec_match_only(string: NativeString, eflags: Int): Int `{
		return regexec(recv, string, 0, NULL, eflags);
	`}

	# Free the memory allocated to the pattern buffer by the compiling process
	#
	# Does not free the memory holding `self`, use `free` for this purpose.
	fun regfree `{ regfree(recv); `}

	# Turn the error codes that can be returned by both `regcomp` and `regexec` into error message strings
	fun regerror(errcode: Int): NativeString `{
		size_t len = regerror(errcode, recv, NULL, 0);
		char *message = malloc(len);
		regerror(errcode, recv, message, len);

		return message;
	`}

	# This field holds the number of parenthetical subexpressions in the regular expression that was compiled.
	fun re_nsub: Int `{ return recv->re_nsub; `}
end

# Flags for `NativeRegex::regcomp`

private fun flag_extended: Int `{ return REG_EXTENDED; `}
private fun flag_icase: Int `{ return REG_ICASE; `}
private fun flag_nosub: Int `{ return REG_NOSUB; `}
private fun flag_newline: Int `{ return REG_NEWLINE; `}

# Flags for `NativeRegex::regexec`

private fun flag_notbol: Int `{ return REG_NOTBOL; `}
private fun flag_noteol: Int `{ return REG_NOTEOL; `}

# Errors of `NativeRegex::regexec`

private fun error_nomatch: Int `{ return REG_NOMATCH; `}
private fun error_espace: Int `{ return REG_ESPACE; `}

redef universal Int
	private fun is_nomatch: Bool `{ return recv == REG_NOMATCH; `}
end

# An array of `regmatch_t` or a pointer to one
private extern class NativeMatchArray `{ regmatch_t* `}
	# Allocate a new array of `length` `regmatch_t`
	new malloc(length: Int) `{ return malloc(length * sizeof(regmatch_t)); `}

	# The offset in string of the beginning of a substring
	fun rm_so: Int `{ return recv->rm_so; `}

	# The offset in string of the end of the substring
	fun rm_eo: Int `{ return recv->rm_eo; `}

	# Get a pointer to the element at `index`, can also be used as a subarray
	fun [](index: Int): NativeMatchArray `{ return recv + index; `}
end

redef extern class NativeString
	private fun substring_from(index: Int): NativeString `{ return recv + index; `}
end

redef class Text
	# Get a `Regex` instance from `self`
	fun to_re: Regex do return new Regex(self.to_s)
end

# A regular expression pattern
#
# Used as a `Pattern` on intances of `Text` to call `has`, `search_all`, `replace`, etc.
#
# Example:
#
#     var re = "ab+a".to_re
#     assert "aabbbbaaaaba".search_all(re).join(", ") == "abbbba, aba"
#     assert "aabbbbaaaaba".has(re)
#     assert "aabbbbaaaaba".replace(re, "+") == "a+aa+"
#     assert "aabbbbaaaaba".split(re) == ["a", "aa", ""]
class Regex
	super Finalizable
	super Pattern

	# The `String` source of this regular expression
	var string: String is writable

	# Treat the pattern as a POSIX extended regular expression (the default)
	#
	# If `false`, it is treated as a POSIX basic regular expression (BRE).
	#
	# The extended syntax supports `?`, `+` and `|`. Also, `\` causes the following
	# character to be used as literal.
	var extended = true is writable

	# Ignore case when matching letters
	var ignore_case = false is writable

	# Optimize `self` for `is_in` and `String::has`, but do not support searches
	#
	# If `true`, `self` cannont be used with `String::search_all`, `String::replace`
	# or `String::split`.
	var optimize_is_in = false is writable

	# Treat a newline in string as dividing string into multiple lines
	#
	# So that `$` can match before the newline and `^` can match after.
	# Also, don’t permit `.` to match a newline, and don’t permit `[^…]` to match a newline.
	#
	# Otherwise, newline acts like any other ordinary character.
	var newline = false is writable

	# Do not regard the beginning of the specified string as the beginning of a line
	#
	# More generally, don’t make any assumptions about what text might precede it.
	var not_bol = false is writable

	# Do not regard the end of the specified string as the end of a line
	#
	# More generally, don’t make any assumptions about what text might follow it.
	var not_eol = false is writable

	# Cache of the last used compiled regular expression
	private var native: nullable NativeRegex = null

	# Cache of a single `regmatch_t` to prevent many calls to `malloc`
	private var native_match = new NativeMatchArray.malloc(0) is lazy

	# `cflags` of the last successful `compile`
	private var cflags_cache = 0

	# `string` of the last successful `compile`
	private var string_cache: nullable String = null

	# Compile the regular expression, if needed
	#
	# Return `null` on success and an `Error` otherwise.
	#
	# This method is always called by `get_match` and `has_match`, but the user
	# should call it to check for errors.
	#
	#     assert "ab".to_re.compile == null
	#     assert "[ab".to_re.compile.message == "Unmatched [ or [^"
	fun compile: nullable Error
	do
		var cflags = 0
		if extended then cflags = cflags.bin_or(flag_extended)
		if ignore_case then cflags = cflags.bin_or(flag_icase)
		if optimize_is_in then cflags = cflags.bin_or(flag_nosub)
		if newline then cflags = cflags.bin_or(flag_newline)

		var native = self.native
		var need_compilation = native == null or cflags != cflags_cache or string != string_cache

		if need_compilation then

			# Initial allocation
			if native == null then
				native = new NativeRegex.malloc
				self.native = native
			end

			var res = native.regcomp(string.to_cstring, cflags)

			# All is good
			if res == 0 then
				# Update the cache
				self.native = native

				# We store these to know if we need to recompile or not
				self.cflags_cache = cflags
				self.string_cache = string

				return null
			end

			var error_cstr = native.regerror(res)

			# We leave it to the lib to decide how to allocate the string that we keep
			var error_str = error_cstr.to_s_with_copy
			error_cstr.free

			return new Error(error_str)
		end

		return null
	end

	redef fun finalize
	do
		var native = self.native
		if native != null then
			native.regfree
			native.free
			self.native = null
			self.native_match.free
		end
	end

	private fun gather_eflags: Int
	do
		var eflags = 0
		if not_bol then eflags = eflags.bin_or(flag_notbol)
		if not_eol then eflags = eflags.bin_or(flag_noteol)
		return eflags
	end

	private fun get_error(errcode: Int): String
	do
		# Error, should be out of memory but we cover any possible error anyway
		var error_cstr = native.regerror(errcode)

		# We leave it to the lib to decide how to allocate the string that we keep
		var error_str = error_cstr.to_s_with_copy
		error_cstr.free

		return error_str
	end

	#     assert "ab".to_re.is_in("abcd")
	#     assert "ab".to_re.is_in("cdab")
	#     assert not "ab".to_re.is_in("acdb")
	#     assert "ab".to_re.is_in("ab")
	redef fun is_in(text)
	do
		var comp_res = compile
		assert comp_res == null else "Regex compilation failed with: {comp_res.message}\n".output

		# Actually execute
		var eflags = gather_eflags
		var res = native.regexec_match_only(text.to_cstring, eflags)

		# Got a match?
		if res == 0 then return true

		# Got no match, not an error?
		if res.is_nomatch then return false

		# Error, should be out of memory but we cover any possible error anyway
		var error_str = get_error(res)
		"Regex search failed with: {error_str}\n".output
		abort
	end

	# require: not optimize_is_in
	#
	#     assert "l".to_re.search_index_in("hello world", 0) == 2
	#     assert "el+o".to_re.search_index_in("hello world", 0) == 1
	#     assert "l+".to_re.search_index_in("hello world", 3) == 3
	#     assert "z".to_re.search_index_in("hello world", 0) == -1
	redef fun search_index_in(text, from)
	do
		assert not optimize_is_in

		var comp_res = compile
		assert comp_res == null else "Regex compilation failed with: {comp_res.message}\n".output

		# Actually execute
		text = text.to_s
		var cstr = text.substring_from(from).to_cstring
		var eflags = gather_eflags
		var match = self.native_match

		var res = native.regexec(cstr, 1, match, eflags)

		# Found one?
		if res == 0 then return match.rm_so + from

		# No more match?
		if res.is_nomatch then return -1

		# Error, should be out of memory but we cover any possible error anyway
		var error_str = get_error(res)
		"Regex search failed with: {error_str}\n".output
		abort
	end

	# require: not optimize_is_in
	#
	#     assert "l".to_re.search_in("hello world", 0).from == 2
	#     assert "el+o".to_re.search_in("hello world", 0).from == 1
	#     assert "l+".to_re.search_in("hello world", 3).from == 3
	#     assert "z".to_re.search_in("hello world", 0) == null
	redef fun search_in(text, from)
	do
		assert not optimize_is_in

		var comp_res = compile
		assert comp_res == null else "Regex compilation failed with: {comp_res.message}\n".output

		# Actually execute
		text = text.to_s
		var cstr = text.substring_from(from).to_cstring
		var eflags = gather_eflags
		var match = self.native_match
		var matches = new Array[Match]

		var res = native.regexec(cstr, 1, match, eflags)

		# Found one?
		if res == 0 then return new Match(text, from + match.rm_so, match.rm_eo - match.rm_so)

		# No more match?
		if res.is_nomatch then return null

		# Error, should be out of memory but we cover any possible error anyway
		var error_str = get_error(res)
		"Regex search failed with: {error_str}\n".output
		abort
	end

	# require: not optimize_is_in
	#
	#     assert "ab".to_re.search_all_in("abbab").join(", ") == "ab, ab"
	#     assert "b+".to_re.search_all_in("abbabaabbbbbcab").join(", ") == "bb, b, bbbbb, b"
	redef fun search_all_in(text)
	do
		assert not optimize_is_in

		var comp_res = compile
		assert comp_res == null else "Regex compilation failed with: {comp_res.message}\n".output

		# Actually execute
		text = text.to_s
		var cstr = text.to_cstring
		var eflags = gather_eflags
		var eflags_or_notbol = eflags.bin_or(flag_notbol)
		var match = self.native_match
		var matches = new Array[Match]

		var res = native.regexec(cstr, 1, match, eflags)
		var d = 0
		while res == 0 do
			matches.add new Match(text, d + match.rm_so, match.rm_eo - match.rm_so)
			if d == match.rm_eo then
				d += 1
			else d = d + match.rm_eo
			cstr = cstr.substring_from(match.rm_eo)
			res = native.regexec(cstr, 1, match, eflags_or_notbol)
		end

		# No more match?
		if res.is_nomatch then return matches

		# Error, should be out of memory but we cover any possible error anyway
		var error_str = get_error(res)
		"Regex search failed with: {error_str}\n".output
		abort
	end

	redef fun to_s do return "/{string}/"
end