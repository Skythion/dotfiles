" tab
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" limite colonne
set colorcolumn=80

" confort
set number
set mouse=a

" Norminette : codes d'erreur affichés à droite, hors ALE
if has('patch-9.0.0067') && executable('norminette')
    highlight NormMsg ctermfg=203 guifg=#ff5f5f
    if empty(prop_type_get('norm'))
        call prop_type_add('norm', {'highlight': 'NormMsg'})
    endif

    let s:pat = '^\(Error\|Notice\):\s*\(\S\+\)\s*(line:\s*\(\d\+\), col:\s*\(\d\+\)):'

    function! s:Done(buf, seq, lines, dir) abort
        call delete(a:dir, 'rf')
        " résultat périmé : une vérification plus récente a été lancée
        if !bufloaded(a:buf) || getbufvar(a:buf, 'norm_seq') != a:seq
            return
        endif
        let l:last = len(getbufline(a:buf, 1, '$'))
        call prop_remove({'type': 'norm', 'bufnr': a:buf, 'all': 1}, 1, l:last)
        let l:by = {}
        for l:ln in a:lines
            let l:m = matchlist(l:ln, s:pat)
            if !empty(l:m) && l:m[3] + 0 <= l:last
                let l:by[l:m[3]] = get(l:by, l:m[3], []) + [l:m[2]]
            endif
        endfor
        for [l:n, l:codes] in items(l:by)
            call prop_add(l:n + 0, 0, {
            \ 'bufnr': a:buf, 'type': 'norm',
            \ 'text': join(l:codes, ', '),
            \ 'text_align': 'right', 'text_padding_left': 2})
        endfor
    endfunction

    function! s:Run() abort
        let l:buf = bufnr('%')
        let l:seq = getbufvar(l:buf, 'norm_seq', 0) + 1
        call setbufvar(l:buf, 'norm_seq', l:seq)
        if exists('b:norm_job') && job_status(b:norm_job) ==# 'run'
            call job_stop(b:norm_job)
        endif
        let l:dir = tempname()
        call mkdir(l:dir, 'p')
        let l:tmp = l:dir . '/' . expand('%:t')
        call writefile(getline(1, '$'), l:tmp)
        let l:lines = []
        let b:norm_job = job_start(['norminette', l:tmp], {
        \ 'out_mode': 'nl',
        \ 'out_cb': {ch, msg -> add(l:lines, msg)},
        \ 'close_cb': {ch -> s:Done(l:buf, l:seq, l:lines, l:dir)}})
    endfunction

    augroup norminette
        autocmd!
        autocmd BufReadPost,BufWritePost,InsertLeave,TextChanged *.c,*.h call s:Run()
    augroup END
endif
