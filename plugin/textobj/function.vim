" textobj-function - Text objects for functions
" Version: 0.1.0
" Copyright (C) 2007-2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
if exists('g:loaded_textobj_function') && !exists("g:textobj_function_testing")  "{{{1
  finish
endif








" Interface  "{{{1

call textobj#user#plugin('function', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'af',  '*select-a-function*': 's:select_a',
\        'select-i': 'if',  '*select-i-function*': 's:select_i'
\      }
\    })







" Pre-defined Select Functions.  "{{{1
" Keyword + {}
function! s:select_a_by_keyword_brace(function_pattern)
	let curline = getpos('.')
	normal $
	if (search(a:function_pattern, 'bW') == 0)
		return 0
	endif
	let b = getpos('.')
	if (search('{', 'W') == 0)
		return 0
	endif
	normal %
	let e = getpos('.')
	if (curline[1] > e[1])
		return 0
	else
		return ['V', b, e]
	endif
endfunction

function! s:select_i_by_keyword_brace(function_pattern)
	let curline = getpos('.')
	normal $
	if (search(a:function_pattern, 'bW') == 0)
		return 0
	endif
	if (search('{', 'W') == 0)
		return 0
	endif
	normal j
	let b = getpos('.')
	normal k%k
	let e = getpos('.')
	if (curline[1] > e[1] + 1)
		return 0
	else
		return ['V', b, e]
	endif
endfunction

function! textobj#function#select_by_keyword_brace(function_pattern, object_type)
	return s:select_{a:object_type}_by_keyword_brace(a:function_pattern)
endfunction

" Keyword Pair
function! s:select_a_by_keyword_pair(begin_pattern, end_pattern)
	let curline = getpos('.')
	normal $
	if (search(a:begin_pattern, 'bW') == 0)
		return 0
	endif
	let b = getpos('.')
	if (search(a:end_pattern, 'W') == 0)
		return 0
	endif
	let e = getpos('.')
	if (curline[1] > e[1])
		return 0
	else
		return ['V', b, e]
	endif
endfunction

function! s:select_i_by_keyword_pair(begin_pattern, end_pattern)
	let outer_range = s:select_a_by_keyword_pair(a:begin_pattern, a:end_pattern)
	if type(outer_range) == 0
		return 0
	else
		let inner_range = outer_range
		let inner_range[1][1] += 1
		let inner_range[2][1] -= 1
		return inner_range
endfunction

function! textobj#function#select_by_keyword_pair(begin_pattern, end_pattern, object_type)
	return s:select_{a:object_type}_by_keyword_pair(a:begin_pattern, a:end_pattern)
endfunction

" Misc.  "{{{1
function! s:select(object_type)
  return exists('b:textobj_function_select')
  \      ? b:textobj_function_select(a:object_type)
  \      : 0
endfunction

function! s:select_a()
  return s:select('a')
endfunction

function! s:select_i()
  return s:select('i')
endfunction

function! s:move_to_begin()
	let range = s:select_i()
	if type(range) == 0
		return
	else
		exec range[1][1]
	endif
endfunction

function! s:move_to_end()
	let range = s:select_i()
	if type(range) == 0
		return
	else
		exec range[2][1]
	endif
endfunction

nmap [m :call <SID>move_to_begin()<CR>
nmap ]m :call <SID>move_to_end()<CR>





" Fin.  "{{{1

let g:loaded_textobj_function = 1








" __END__
" vim: foldmethod=marker
