if !exists('*g:textobj_function_cheetah_select') || exists("g:textobj_function_testing")
	let s:begin_pattern = '^\s*#def'
	let s:end_pattern = '^\s*#end def'
	function! g:textobj_function_cheetah_select(object_type)
		return textobj#function#select_by_keyword_pair(s:begin_pattern, s:end_pattern, a:object_type)
	endfunction

	function! s:test_cheetah()
		TAssertOn
		try
			:e  ~/.vim/bundle/textobj_function/test/cheetah_test.tmpl
			"test outer function 
			:4
			let b:test_range = g:textobj_function_cheetah_select('a')
			TAssert b:test_range[1][1] == 4 && b:test_range[2][1] == 33

			:42
			let b:test_range = g:textobj_function_cheetah_select('a')
			TAssert b:test_range[1][1] == 35 && b:test_range[2][1] == 83

			"test inner function
			:42
			let b:test_range = g:textobj_function_cheetah_select('i')
			TAssert b:test_range[1][1] == 36 && b:test_range[2][1] == 82 
			echo "PASS"
		catch
			TLogVAR b:test_range
			echo "FAILED" v:exception
		endtry
	endfunction

	if (exists("g:textobj_function_testing"))
		call s:test_cheetah()
	endif
endif

let b:textobj_function_select = function('g:textobj_function_cheetah_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

