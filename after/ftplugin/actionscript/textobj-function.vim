if !exists('*g:textobj_function_actionscript_select') || exists("g:textobj_function_testing")
	let s:function_pattern = '\(public\|private\|protected\).*function'
	function! g:textobj_function_actionscript_select(object_type)
		return textobj#function#select_by_keyword_brace(s:function_pattern, a:object_type)
	endfunction

	function! s:test_actionscript()
		TAssertOn
		:e  ~/.vim/bundle/textobj_function/test/as_test.as
		"test outer function 
		:155
		let arange = g:textobj_function_actionscript_select('a')
		TAssert arange[1][1] == 148 && arange[2][1] == 163

		"test inner function
		:155
		let irange = g:textobj_function_actionscript_select('i')
		TAssert irange[1][1] == 149 && irange[2][1] == 162 

		echo "PASS"
	endfunction

	if (exists("g:textobj_function_testing"))
		call s:test_actionscript()
	endif
endif

let b:textobj_function_select = function('g:textobj_function_actionscript_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

