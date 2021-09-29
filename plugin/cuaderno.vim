if exists('g:loaded_cuaderno')
  finish
endif

let g:loaded_cuaderno = 1


let s:month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']


" default values for configuration variables
if !exists('g:cuaderno_journal_path')
    let g:cuadernojournal_path = '~/.notes'
endif

if !exists('g:cuaderno_todo_path')
    let g:cuaderno_todo_path = '~/.notes/notes'
endif

if !exists('g:cuaderno_show_folder')
    let g:cuaderno_show_folder = 1
endif


" shows folder browser
function! s:ShowTree() abort
    " TODO file browser could be a parameter
    if g:cuaderno_show_folder != 0
        if exists(":NERDTree")
            execute 'NERDTree'
        else
            execute 'Vexplore'
        endif
        " back to previous window
        execute 'wincmd p'
    endif
endfunction


function! s:GotoFolder(path) abort
    let path = expand(a:path)
    " if folder does not exist, it's created
    if !isdirectory(path)
        call mkdir(path, "p")
    endif
    execute 'cd' path
    return path
endfunction


function! s:GenericEntry(path, filename, lines) abort
    let file_path = s:GotoFolder(a:path)
    let filename = file_path . '/' . tolower(a:filename)

    call s:ShowTree()

    execute "e " . filename
    " if a file does not exists, it's created
    setlocal autochdir
    nnoremap <buffer>  gf :e <cfile><cr>

    if len(a:lines) > 0 && !filereadable(filename)
        let nline = 1
        for l in a:lines
           call setline(nline, l)
           let nline += 1
        endfor
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
        echom "Journal: " . date . ", wrong date!"
        return
    endif

    let filename = entry_date . '.md'
    call s:GenericEntry(a:path, filename, ['# ' . entry_date])
endfunction


function! s:TodoEntry(path) abort
    let date = strftime('%Y-%m-week-%V')
    let year = strftime('%Y')
    let month = strftime('%m')
    let month_name = strftime('%B')
    let week = strftime('%V')
    let monday = system('date -dlast-monday +%d')
    let sunday = system('date -d"last-monday+6days" +%d')

    let filename = 'todo.' . date . '.md'
    let title = printf("# %s %s week %s", year, month_name, week)
    let text = printf(
        \ "From %s-%s-%2d to %s-%s-%2d",
        \ year, month, monday,
        \ year, month, sunday
        \)
    call s:GenericEntry(a:path, filename, [title, '', text])
endfunction


command! -nargs=? Journal call s:JournalEntry(g:cuaderno_journal_path, <f-args>)
command! Todo call s:TodoEntry(g:cuaderno_todo_path)

" nmap <Plug>CuadernoLinkToday "=strftime('[](./%Y-%m-%d.md)')<C-M>p

" if !hasmapto('<Plug>CuadernoLinkToday')
"     nmap tt <Plug>CuadernoLinkToday
" endif
