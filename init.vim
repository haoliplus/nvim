" This file is called becaused of ${VIMINIT}

" replace , using \,
" append the parent directory to runtimepath
let &runtimepath.=','.escape(expand('<sfile>:p:h'), '\,')

" Load machine-local environment variables before initializing Lua and plugins.
let s:local_env = expand('<sfile>:p:h') . '/env.local.lua'
if filereadable(s:local_env)
  execute 'source ' . fnameescape(s:local_env)
endif

set guicursor=
set listchars=tab:>→,trail:~,eol:↵
set list
lua require('init')
