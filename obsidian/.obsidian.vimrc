" Yank to system clipboard
set clipboard=unnamed

" Allow <Space> to be used in custom mappings
unmap <Space>

" Open context menu on space-q (correct spelling errors, etc.)
exmap context obcommand editor:context-menu
nmap <Space>q :context<CR>
