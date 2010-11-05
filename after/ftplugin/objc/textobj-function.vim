if !exists('*g:textobj_function_objc_select') 
	let s:function_pattern = '^\s*[-+]\s*([a-zA-Z0-9_]\+)'
	function! g:textobj_function_objc_select(object_type)
		return textobj#function#select_by_keyword_brace(s:function_pattern, a:object_type)
	endfunction
endif

let b:textobj_function_select = function('g:textobj_function_objc_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

