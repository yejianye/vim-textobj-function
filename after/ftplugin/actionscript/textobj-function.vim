if !exists('*g:textobj_function_actionscript_select') || exists("g:textobj_function_actionscript_testing")
	let s:function_pattern = '\(public\|private\|protected\).*function'
	function! g:textobj_function_actionscript_select(object_type)
		return s:select_{a:object_type}()
	endfunction

	function! s:select_a()
		let curline = getpos('.')
		normal $
		if (search(s:function_pattern, 'bW') == 0)
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

	function! s:select_i()
		let curline = getpos('.')
		normal $
		if (search(s:function_pattern, 'bW') == 0)
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

	function! s:test()
		:e  ~/.vim/bundle/textobj_function/after/ftplugin/actionscript/testcase.as
		:155
		let arange = g:textobj_function_actionscript_select('a')
		call Decho(arange)
		:155
		let irange = g:textobj_function_actionscript_select('i')
		call Decho(irange)
		if arange[1][1] == 148 && arange[2][1] == 163 && irange[1][1] == 149 && irange[2][1] == 162
			echo 'pass'
		endif
	endfunction

	if (exists("g:textobj_function_actionscript_testing"))
		call s:test()
	endif
endif

let b:textobj_function_select = function('g:textobj_function_actionscript_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

