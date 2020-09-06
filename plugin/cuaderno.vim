if exists('g:loaded_cuaderno')
  finish
endif
let g:loaded_cuaderno = 1

let s:month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

" checking configuration variables
if !exists('g:journal_path')
    let g:journal_path = '~/.notes'
endif

if !exists('g:note_path')
    let g:note_path = '~/.notes/articles'
endif

if !exists('g:todo_path')
    let g:todo_path = '~/.notes/notes'
endif


function! s:ShowTree() abort
    if exists(":NERDTree")
        execute 'NERDTree'
    else
        execute 'Vexplore'
    endif
    " back to previous window
    execute 'wincmd p'
endfunction


function! s:GotoFolder(path) abort
    let path = expand(a:path)
    if !isdirectory(path)
        call mkdir(path, "p")
    endif
    execute 'cd' path
    return path
endfunction


function! s:GenericEntry(path, filename, title) abort
    let file_path = s:GotoFolder(a:path)
    let filename = file_path . '/' . tolower(a:filename)
    call s:ShowTree()
    execute "e " . filename

    " if a file does not exists, it's created
    setlocal autochdir
    nnoremap <buffer>  gf :e <cfile><cr>

    if a:title != "" && !filereadable(filename)
        call setline(1, '# ' . a:title)
        call setline(2, '')
        call setline(3, '')
    endif
    " go to the end of the entry
    execute 'normal G$'
endfunction


" path, entry_date
function! s:JournalEntry(path, ...) abort
    let date = get(a:, 1, strftime('%Y-%m-%d'))

    if date == "today"
        let entry_date = strftime('%Y-%m-%d')
    elseif date == "yesterday"
        let entry_date = trim(system('date -I --date="yesterday"'))
    elseif date == "tomorrow"
        let entry_date = trim(system('date -I --date="tomorrow"'))
    elseif trim(system('date -I --date="' . date . '"')) == date
        " date =~ '^\d\{4}-[0-1]\d-[0-3]\d$'
        let entry_date = date
    else
        echom "Journal: " . date . " is a wrong date!"
        return
    endif

    let filename = entry_date . '.md'
    call s:GenericEntry(a:path, filename, entry_date)
endfunction


function! s:TodoEntry(path, ...) abort
    let date = get(a:, 1, strftime('%Y-%m'))
    let month_aux = date[-2:]
    if trim(system('date -I --date="' . date .'-01"')) == date . '-01'
        " if date =~ '^\d\{4}-[0-1]\d$' && str2nr(month_aux) <= 12
        let entry_date = date
        let year = date[0:3]
        let month = date[-2:]
        let title = "TODO, " . year . ' ' . s:month_names[str2nr(month) - 1]
    else
        echom "Todo: " . date . " is not valid yyyy-mm date!"
        return
    endif
    let filename = 'todo.' . entry_date . '.md'
    call s:GenericEntry(a:path, filename, title)
endfunction


:command! -nargs=? Journal call s:JournalEntry(g:journal_path, <f-args>)
:command! -nargs=? Todo call s:TodoEntry(g:todo_path, <f-args>)
