if !exists('*g:textobj_function_python_select') || exists("g:textobj_function_testing")
	let s:blank_line_pattern = '^\s*\(#.*\)\?$'
	let s:func_pattern = '^\s*def'
	function! g:textobj_function_python_select(object_type)
		return s:select_{a:object_type}()
	endfunction

	function! s:select_a()
		let cur_lineno = line('.')
		" find beginning of the function
		if getline('.') =~ s:func_pattern
			let b = getpos('.')
			let func_indent = indent('.')
			let cur_lineno += 1
		else
			let line_no = line('.')
			let min_indent = indent(line_no)
			while line_no > 0
				let cur_indent = indent(line_no)
				if getline(line_no) =~ s:blank_line_pattern
					let line_no = line_no - 1
					continue
				endif
				if getline(line_no) =~ s:func_pattern
					exec line_no
					let b = getpos('.')
					let func_indent = indent(line_no)
					break
				endif
				if cur_indent < min_indent
					let min_indent = cur_indent
				endif
				let line_no = line_no - 1
			endwhile	
			if line_no == 0
				return 0
			endif
		endif
		
		" find ending of the function
		exec cur_lineno
		
		let total_line = line('$')
		let line_no = cur_lineno
		let last_non_blank_line = cur_lineno
		while line_no < total_line
			if getline(line_no) =~ s:blank_line_pattern
				let line_no = line_no + 1
				continue
			endif
			if indent(line_no) <= func_indent
				break
			endif
			let last_non_blank_line = line_no
			let line_no = line_no + 1
		endwhile
		exec last_non_blank_line
		let e = getpos('.')

		return ['V', b, e]
	endfunction

	function! s:select_i()
		let outer_range = s:select_a()
		if type(outer_range) == 0
			return 0
		else
			let inner_range = outer_range
			let inner_range[1][1] += 1
			return inner_range
	endfunction

	function! s:test_python()
		TAssertOn
		try
			:e  ~/.vim/bundle/textobj_function/test/py_test.py
			"test outer function 
			:21
			let b:test_range = g:textobj_function_python_select('a')
			TAssert b:test_range[1][1] == 14 && b:test_range[2][1] == 27

			:146
			let b:test_range = g:textobj_function_python_select('a')
			TAssert b:test_range[1][1] == 146 && b:test_range[2][1] == 171

			"test inner function
			:49
			let b:test_range = g:textobj_function_python_select('i')
			TAssert b:test_range[1][1] == 33 && b:test_range[2][1] == 83 
			echo "PASS"
		catch
			TLogVAR b:test_range
			echo "FAILED:" v:exception
		endtry
	endfunction

	if (exists("g:textobj_function_testing"))
		call s:test_python()
	endif
endif

let b:textobj_function_select = function('g:textobj_function_python_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

