" Better indent support for PHP by making it possible to indent HTML sections
" as well.
if exists("b:did_indent")
    finish
endif

" This script pulls in the default indent/php.vim with the :runtime command
" which could re-run this script recursively unless we catch that:
if exists('s:doing_indent_inits')
    finish
endif
let s:doing_indent_inits = 1
runtime! indent/html.vim
unlet b:did_indent
runtime! indent/php.vim
unlet s:doing_indent_inits

function! GetPhpHtmlIndent(lnum)
    if exists('*HtmlIndentGetter')
        let html_ind = HtmlIndentGetter(a:lnum)
    else
        let html_ind = HtmlIndentGet(a:lnum)
    endif
    let php_ind = GetPhpIndent()
    let js_ind = GetJsIndent(a:lnum)

    if js_ind > -1
        if InPhp(a:lnum) == 1
            return php_ind
        endif
        let js = '<script.*type\s*=.*javascript'
        if 0 < searchpair(js, '', '</script>', 'nWb')
                    \ && 0 < searchpair(js, '', '</script>', 'nW')
            " we're inside javascript
            return GetJsIndent(a:lnum)
        endif
    endif

    " priority one for php indent script
    if php_ind > -1
        return php_ind
    endif

    if html_ind > -1 && InPhp(a:lnum) > -1
        return html_ind
    endif

    return -1
endfunction

function! InPhp(lnum)
    if getline(a:num) =~ "^<?" && (0< searchpair('<?', '', '?>', 'nWb')
                \ || 0 < searchpair('<?', '', '?>', 'nW'))
        return 0
    elseif getline(a:num) =~ "^<?" && (0< searchpair('<?', '', '?>', 'nWb')
                \ && 0 < searchpair('<?', '', '?>', 'nW'))
        return 1
    else
        return -1
    endif

endfunction

setlocal indentexpr=GetPhpHtmlIndent(v:lnum)
setlocal indentkeys+=<>>