" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    100


if !exists('g:cfilehandler#show_qfl')
    " Run this command after setting the |quickfix| list to open or 
    " close the quickfix list.
    let g:cfilehandler#show_qfl = {'open': 'copen', 'close': 'cclose'}   "{{{2
endif


if !exists('g:cfilehandler#lines_expr')
    let g:cfilehandler#lines_expr = 'min([&previewheight, &lines / 2, qfln])'   "{{{2
endif


let s:cfilehandlerfiles = {}
let s:starttime = localtime()


" Setup the file watcher for the current buffer.
" :nodoc:
function! cfilehandler#SetupWatcher() "{{{3
    if exists('b:cfilehandler_file') && !empty(b:cfilehandler_file)
        autocmd! CfileHandler CursorHold,CursorHoldI <buffer>
        autocmd CfileHandler CursorHold,CursorHoldI <buffer> call cfilehandler#Watch()
    endif
endf


" If the file b:cfilehandler_file exists, watch it for changes and read 
" its contents into the |quickfix| list.
" :nodoc:
function! cfilehandler#Watch() "{{{3
    if exists('b:cfilehandler_file') && !empty(b:cfilehandler_file) && filereadable(b:cfilehandler_file)
        let new_mtime = getftime(b:cfilehandler_file)
        if new_mtime > s:starttime
            let new_size = getfsize(b:cfilehandler_file)
            let old_mtime = get(get(s:cfilehandlerfiles, b:cfilehandler_file, {}), 'mtime', 0)
            let old_size = get(get(s:cfilehandlerfiles, b:cfilehandler_file, {}), 'size', 0)
            " TLogVAR new_size, old_mtime, new_size, old_size
            if new_mtime > old_mtime || new_size != old_size
                let s:cfilehandlerfiles[b:cfilehandler_file] = {'mtime': new_mtime, 'size': new_size}
                if new_size == 0
                    call setqflist([])
                    call cfilehandler#CmdPost()
                else
                    exec 'cgetfile' b:cfilehandler_file
                endif
            endif
        endif
    endif
endf


" :nodoc:
function! cfilehandler#CmdPre() "{{{3
    let b:cfilehandler_pos = getpos('.')
    let b:cfilehandler_qfl = getqflist()
    autocmd CfileHandler CursorMoved,CursorMovedI <buffer> call cfilehandler#ResetPos()
endf


" :nodoc:
function! cfilehandler#ResetPos() "{{{3
    if exists('b:cfilehandler_pos')
        call setpos('.', b:cfilehandler_pos)
    endif
    silent autocmd! CfileHandler CursorMoved,CursorMovedI <buffer>
endf


" :nodoc:
function! cfilehandler#CmdPost() "{{{3
    if !empty(g:cfilehandler#show_qfl)
        let qfl = getqflist()
        if b:cfilehandler_qfl != qfl
            let bufnr = bufnr('%')
            let qfln = len(qfl)
            " TLogVAR qfln
            if qfln == 0
                exec g:cfilehandler#show_qfl.close
            else
                exec g:cfilehandler#show_qfl.open
                if &ft == 'qf' && !empty(g:cfilehandler#lines_expr)
                    let lines = eval(g:cfilehandler#lines_expr)
                    " TLogVAR lines
                    if lines != 0
                        exec 'resize' lines
                    endif
                endif
                " TLogVAR bufnr, bufnr('%')
                if bufnr != bufnr('%')
                    wincmd p
                endif
            endif
        endif
    endif
endf


