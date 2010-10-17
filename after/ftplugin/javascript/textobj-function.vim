if !exists('*g:textobj_function_javascript_select') || exists("g:textobj_function_testing")
	let s:function_pattern = '\s*[A-Za-z0-9_.]\+\s*[:=]\s*function\|\s*function'
	function! g:textobj_function_javascript_select(object_type)
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

	function! s:test_javascript()
		TAssertOn
		try
			:e  ~/.vim/bundle/textobj_function/test/js_test.js
			"test outer function 
			:127
			let b:test_range = g:textobj_function_javascript_select('a')
			TAssert b:test_range[1][1] == 123 && b:test_range[2][1] == 141

			:83
			let b:test_range = g:textobj_function_javascript_select('a')
			TAssert b:test_range[1][1] == 74 && b:test_range[2][1] == 93

			"test inner function
			:127
			let b:test_range = g:textobj_function_javascript_select('i')
			TAssert b:test_range[1][1] == 123 && b:test_range[2][1] == 140 
			echo "PASS"
		catch
			TLogVAR b:test_range
			echo "FAILED"
		endtry
	endfunction

	if (exists("g:textobj_function_testing"))
		call s:test_javascript()
	endif
endif

let b:textobj_function_select = function('g:textobj_function_javascript_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

