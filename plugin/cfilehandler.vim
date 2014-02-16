" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/sbtqf_handler_vim
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    7
" GetLatestVimScripts: 0 0 :AutoInstall: sbtqf_handler.vim

if &cp || exists("loaded_sbtqf_handler")
    finish
endif
let loaded_sbtqf_handler = 1

let s:save_cpo = &cpo
set cpo&vim


augroup CfileHandler
    autocmd!
    autocmd BufEnter * call cfilehandler#SetupWatcher()
    autocmd QuickFixCmdPre cfile call cfilehandler#CmdPre()
    autocmd QuickFixCmdPost cfile call cfilehandler#CmdPost()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
