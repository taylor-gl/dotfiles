;;+----------------------------------------------------------------------------------------+
;;|                                                                                        |
;;|   BASICS & INTERFACE                                                                   |
;;|                                                                                        |
;;+----------------------------------------------------------------------------------------+
(setq user-full-name "Taylor G. Lunt"
      user-mail-address "taylor@taylor.gl")

;; Clean up the interface
(setq inhibit-startup-message t
      visible-bell t
      frame-resize-pixelwise t) ;; For tiling window manager
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(global-visual-line-mode t)
(setq-default cursor-type 'bar)
(add-to-list 'default-frame-alist '(height . 60)) ;; The height of new frames
(add-to-list 'default-frame-alist '(width . 100)) ;; The width of new frames
(setq pop-up-frames t) ;; Make emacs generally use one window per frame
(setq frame-auto-hide-function #'delete-frame) ;; When quitting the only window in a frame, delete that frame, rather than minimizing it
(setq-default x-stretch-cursor t) ;; Stretch the cursor to the width of a glyph (even e.g. a tab glyph)
(show-paren-mode) ;; Highlight matching parens

;; Choose fonts
(set-face-attribute 'default nil :family "Fira Code" :height 105)
(set-face-attribute 'fixed-pitch nil :family "Fira Code" :height 105)
(set-face-attribute 'variable-pitch nil :family "Noto Serif" :height 100)

;; Performance (or the illusion thereof)
;; emacs >= 27 required:
(setq bidi-inhibit-bpa t
      bidi-paragraph-direction 'left-to-right
      bidi-paragraph-direction 'left-to-right
      echo-keystrokes 0.01
      jit-lock-defer-time 0
      fast-but-imprecise-scrolling t)

;; Better default behaviors
(global-set-key (kbd "<escape>") #'keyboard-escape-quit) ;; Make ESC quit prompts
(global-subword-mode 1) ;; Movement commands use subwords rather than words for symbols like ThisAndThat
(defalias 'yes-or-no-p 'y-or-n-p)
(setq kill-buffer-query-functions nil ;; Don't ask me for confirmation when closing buffers with running processes etc.
      indent-tabs-mode nil ;; Make tab insert spaces
      sentence-end-double-space nil
      save-interprogram-paste-before-kill t ;; Save clipboard text to kill ring before replacing it, so clipboard text is not lost
      mouse-wheel-scroll-amount '(3 ((control) . 6)) ;; Scroll two lines at a time unless control held
      mouse-wheel-progressive-speed nil ;; No scroll acceleration, because who would want that?
      custom-file (concat user-emacs-directory "custom.el") ;; Keep custom out of init.el
      initial-major-mode #'fundamental-mode ;; Scratch buffer mode
      initial-scratch-message nil ;; Scratch buffer starts empty
      delete-by-moving-to-trash t) ;; Delete files to the trash

;; Auto-saving
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 5  ;; save after 5 seconds of idle time
      backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backups/")))
      auto-save-file-name-transforms
      `((".*" ,(concat user-emacs-directory "auto-save-list/") t))
      create-lockfiles nil)

;; Add MELPA packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Set up straight.el and use-package for package management
(setq straight-use-package-by-default t)
;; Bootstrap boilerplate needed to install straight.el:
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)
(setq use-package-always-defer t)

;; Setup general for keybindings
(use-package general
  :demand)

;; Setup hydra for custom keybinding menus
(use-package hydra
  :demand)

;; I don't want TAB on C-i, nor RET on C-m
;; It won't work to unmap them normally, because emacs sees RET == C-m etc.
;; Instead I bind C-i to C-1, and C-m to C-2, and should use C-1 and C-2 to bind to C-i and C-m
(defun taylor-gl/remap-C-i-and-C-m ()
  "Remove TAB from C-i and RET from C-m."
  (interactive)
  (general-define-key
   :keymaps 'input-decode-map
   "C-i" "C-1"
   "C-m" "C-2"
   "M-i" "M-1"
   "M-m" "M-2"
   "C-M-i" "C-M-1"
   "C-M-m" "C-M-2"
   "H-C-i" "H-C-1"
   "H-C-M-i" "H-C-M-1"
   )
  )

;; This is added to after-make-frame-functions because each frame gets its own input-decode-map
(defun taylor-gl/make-frame-remap-C-i-and-C-m (frame)
  "A function for after-make-frame-functions which removes TAB from C-i and RET from C-m."
  (taylor-gl/remap-C-i-and-C-m)
  )
(add-to-list 'after-make-frame-functions #'taylor-gl/make-frame-remap-C-i-and-C-m)

;; Functions I want to call whenever I run emacsclient
;; I have to run taylor-gl/remap-C-i-and-C-m here because it isn't run on the initial emacsclient if there is no emacs daemon running otherwise
(defun taylor-gl/emacsclient ()
  (taylor-gl/remap-C-i-and-C-m)
  )

;; I want my basic movement keys on hnei (I use colemak), therefore:
;; Swap C-b and C-h etc.
;; (mnemonic: C-b opens the handBook)
;; (mnemonic: M-b marks paragrapH)
(general-define-key
 "C-h" 'backward-char
 "C-b" help-map
 "C-b C-b" 'help-for-help
 "M-h" 'backward-word
 "M-b" 'mark-paragraph
 )

;; Swap C-p and C-e etc.
;; (mnemonic: C-p moves Past the line)
;; (mnemonic: M-p moves Past the sentence)
;; (mnemonic: C-M-p moves Past the function)
(general-define-key
 "C-e" 'previous-line
 "C-p" 'end-of-visual-line
 "M-e" nil
 "M-p" 'forward-sentence
 "C-M-p" 'end-of-defun
 "C-M-e" 'backward-list
 )

;; Move C-f to C-i, and just leave C-f unbound
;; (Remember that I've bound C-1 to C-i)
(general-define-key
 "C-1" 'forward-char
 "M-1" 'forward-word
 "C-f" nil
 "M-f" nil
 "C-M-f" nil
 )

;; Don't require pressing escape three (3!) times to exit
(general-define-key "<escape>" 'keyboard-escape-quit)

;; Don't use escape as a prefix key
(general-define-key
 "C-c <escape>" 'ignore
 "C-x <escape>" 'ignore
 "C-b <escape>" 'ignore)

;; Other global keybindings
(general-define-key
 "M-n" 'forward-paragraph
 "M-e" 'backward-paragraph
 "M-2" 'back-to-indentation ;; Remember M-2 is actually M-m
 "C-s" 'save-buffer ;; Moving saving to C-s to be consistent with other applications a la cua-mode
 "C-y" nil ;; moved to C-v with cua-mode
 "C-w" nil ;; moved to C-v with cua-mode
 "C-S-s" 'write-file ;; "Save as..."
 "H-." 'kmacro-end-and-call-macro
 "H-SPC" 'set-mark-command
 "H-q" 'kill-this-buffer
 "H-w" 'delete-trailing-whitespace
 "H-m" 'exchange-point-and-mark
 "C-b C-2" 'describe-keymap ;; C-2 is C-m
 )


;;+----------------------------------------------------------------------------------------+
;;|                                                                                        |
;;|   PACKAGES                                                                             |
;;|                                                                                        |
;;+----------------------------------------------------------------------------------------+
;; Setup ag (for use with projectile-ag)
(use-package ag
  :after projectile)

(use-package beacon
  :demand
  :init
  (setq beacon-color "#68af9c"
        beacon-blink-when-focused t)
  :config
  (beacon-mode 1))

(use-package company
  :demand
  :general
  ("M-/" #'company-complete)
  (:keymaps 'company-active-map
            "RET" 'nil
            "<return>" 'nil
            "M-/" #'company-complete-selection
            "C-p" nil
            "C-e" #'company-select-previous-or-abort
            "C-h" nil
            "C-b" #'company-show-doc-buffer
            "<escape>" #'company-abort
            )
  :custom
  (company-backends '((company-yasnippet)))
  (company-idle-delay 0.0) ;; some people use 0.1 as "instant", but that is visibly non-instant
  (company-require-match 'never)
  (company-tooltip-align-annotations t)
  (company-format-margin-function #'company-dot-icons-margin)
  (global-company-mode t)
  )

(use-package counsel ;; includes ivy and swiper
  :demand
  :general
  ([remap apropos-command] 'counsel-apropos
   [remap bookmark-jump] 'counsel-bookmark
   [remap descbinds] 'counsel-descbinds
   [remap describe-face] 'counsel-describe-face
   [remap describe-function] 'counsel-describe-function
   [remap describe-symbol] 'counsel-describe-symbol
   [remap describe-variable] 'counsel-describe-variable
   [remap execute-extended-command] 'counsel-M-x
   [remap find-file] 'counsel-find-file
   [remap find-library] 'counsel-find-library
   [remap geiser-doc-look-up-manual] 'counsel-geiser-doc-look-up-manual
   [remap imenu] 'counsel-imenu
   [remap info-lookup-symbol] 'counsel-info-lookup-symbol
   [remap list-faces-display] 'counsel-faces
   [remap load-library] 'counsel-load-library
   [remap load-theme] 'counsel-load-theme
   [remap pop-to-mark-command] 'counsel-mark-ring
   [remap yank-pop] 'counsel-yank-pop
   "C-f" 'swiper ;; C-f for swiper mimics keybindings for other applications
   "C-c C-r" 'ivy-resume
   "H-C-f" 'counsel-find-file
   )
  (:Keymaps 'minibuffer-local-map
            "C-r" 'counsel-minibuffer-history)
  (:keymaps 'ivy-minibuffer-map
            "M-e" 'ivy-previous-history-element)
  (:keymaps 'ivy-occur-mode-map
            "j" nil
            "k" nil
            "n" 'ivy-occur-next-line
            "e" 'ivy-occur-previous-line)
  (:keymaps 'ivy-occur-grep-mode-map
            "j" nil
            "k" nil
            "l" nil
            "n" 'ivy-occur-next-line
            "e" 'ivy-occur-previous-line
            "i" 'forward-char)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d) ")
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)") ;; hide certain files; taken from doom emacs
  )

(use-package crux
  :demand t
  :general
  ("H-b" 'crux-switch-to-previous-buffer
   "M-o" 'crux-kill-line-backwards
   )
  :config
  (crux-reopen-as-root-mode t))

;; Setup cua-mode, which enables standard C-v, C-c, and C-x keybindings for undo, copying and pasting.
;; It also does other things, like causing typed text to replace the active region.
;; (CUA stands for Common User Access, which is a misnomer because it does not match up with IBM's
;; Common User Access standard.)
(use-package cua-base
  :straight (:type built-in)
  :init (cua-mode t)
  :config
  (setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
  (transient-mark-mode 1) ;; No region when it is not highlighted
  (setq cua-keep-region-after-copy t) ;; Standard Windows behaviour
  )

(use-package dired
  :straight (:type built-in)
  :ghook ('dired-mode-hook #'dired-hide-details-mode)
  :general
  (:keymaps 'dired-mode-map
            "b" 'describe-mode
            "e" 'dired-previous-line
            "h" nil
            "p" nil
            "C-M-p" nil
            "C-M-e" 'dired-prev-subdir
            "* C-p" nil
            "* C-e" 'dired-prev-marked-file
            )
  :config
  (setq dired-dwim-target t
        find-file-visit-truename t
        dired-ls-F-marks-symlinks t
        dired-auto-revert-buffer t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always)
  )

(use-package dired-x
  :after dired
  :straight (:type built-in)
  :ghook ('dired-mode-hook #'dired-omit-mode)
  :config
  (dired-omit-mode t)
  (setq dired-guess-shell-alist-user '(("\\.\\(?:pdf\\|djvu\\|eps\\)\\'" "evince")
                                       ("\\.\\(?:doc\\|docx\\|odt\\)\\'" "libreoffice")
                                       ("\\.\\(?:jpe?g\\|png\\|gif\\|xpm\\)\\'" "feh")
                                       ("\\.\\(?:xcf\\)\\'" "xdg-open")
                                       ("\\.csv\\'" "xdg-open")
                                       ("\\.tex\\'" "xdg-open")
                                       ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|rm\\|rmvb\\|ogv\\)\\(?:\\.part\\)?\\'" "xdg-open")
                                       ("\\.\\(?:mp3\\|flac\\)\\'" "xdg-open")
                                       ("\\.html?\\'" "xdg-open")
                                       ("\\.md\\'" "xdg-open")))
  (setq dired-omit-files "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)") ;; hide certain files
  )

;; Setup doom-modeline from doom emacs
(use-package doom-modeline
  :ghook 'after-init-hook
  :init
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-icon t)
  (setq doom-modeline-buffer-modification-icon nil)
  :config
  ;; Show column number in doom-modeline
  (column-number-mode)
  )

;; Setup doom-themes from doom themes (I use a custom pastel theme)
(use-package doom-themes
  :demand
  :custom-face
  (org-headline-done ((t (:foreground "#efc7e9")))) ;; light pink
  ;; change ugly org-level-1 etc. color choices
  (outline-1 ((t (:foreground "#ec3b82" )))) ;; cerise
  (outline-2 ((t (:foreground "#fa611f")))) ;; dark-orange
  (outline-3 ((t (:foreground "#ff9933")))) ;; light-orange
  (outline-4 ((t (:foreground "#fa611f")))) ;; dark-orange
  (outline-5 ((t (:foreground "#ff9933")))) ;; light-orange
  (outline-6 ((t (:foreground "#fa611f")))) ;; dark-orange
  (outline-7 ((t (:foreground "#ff9933")))) ;; light-orange
  (outline-8 ((t (:foreground "#fa611f")))) ;; dark-orange
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        pastel-brighter-comments t
        pastel-padded-modeline t)
  (load-theme 'pastel t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(defun taylor-gl/transpose-paragraphs-backward ()
  (interactive "*")
  (transpose-paragraphs -1)
  )
(use-package drag-stuff
  :demand
  :general
  (:keymaps 'drag-stuff-mode-map
            "H-e" 'drag-stuff-up
            "H-n" 'drag-stuff-down
            "H-C-n" 'transpose-paragraphs
            "H-C-e" 'taylor-gl/transpose-paragraphs-backward
            )
  :config
  (drag-stuff-global-mode 1)
  )

(use-package dot-mode
  :demand
  :config
  (global-dot-mode t)
  )

(use-package dumb-jump
  :demand
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read)
  )

(use-package expand-region
  :demand
  :general
  ("H-x" 'er/expand-region)
  )

(use-package fira-code-mode
  :custom (fira-code-mode-disabled-ligatures '("[]" "x" "<>" "#{" "#(", "{-"))  ; ligatures I don't want
  :config (fira-code-mode-set-font)
  :ghook ('(prog-mode-hook org-mode-hook))
  )

(use-package format-all
  :init
  :demand
  :ghook ('format-all-mode-hook #'format-all-ensure-formatter)
  :general
  ("C-c =" 'format-all-buffer
   "C-c +" 'format-all-region)
  )

(use-package git-gutter
  :demand t
  :init
  :config
  (global-git-gutter-mode t)
  (setq git-gutter:disabled-modes '(org-mode fundamental-mode image-mode pdf-view-mode))
  :custom
  (git-gutter:update-interval 1)
  )

(use-package git-gutter-fringe
  :demand t
  :after git-gutter
  :config
  (setq-default fringes-outside-margins t)
  ;; thin fringe bitmaps
  (define-fringe-bitmap 'git-gutter-fr:added [224]
    nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224]
    nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
    nil nil 'bottom)
  )

;; Add extra help functions like describe-keymap
(use-package help-fns+
  :demand)

;; Highlight quoted symbols in elisp
(use-package highlight-quoted
  :demand
  :ghook 'emacs-lisp-mode-hook)

(use-package hl-todo
  :demand
  :ghook ('org-mode-hook #'hl-todo-mode)
  :general (
            "C-c t n" #'hl-todo-next
            "C-c t e" #'hl-todo-previous
            )
  :config
  (global-hl-todo-mode 1)
  (setq hl-todo-keyword-faces
        '(("FIXME"   . "#fb4932")
          ("GOTCHA"  . "#fb4932")
          ("TODO" . "#fb4932")
          ("TODOS" . "#fb4932")
          ("XXX"  . "#fb4932")
          ("DEBUG"  . "#fe8019")
          ("INPROGRESS"  . "#fe8019")
          ("REVIEW"  . "#fe8019")
          ("WAITING"  . "#fe8019")
          ("STUB"   . "#fabd2f")
          ("MAYBE"  . "#fabd2f")
          ("SHOULD"  . "#fabd2f")
          ("HACK"  . "#b8bb26")
          ("NOTE"  . "#b8bb26")
          ("ABANDONED"  . "#a89984")
          ("DEPRECATED"  . "#a89984")
          ("DONE"  . "#a89984")
          )))

(use-package Info
  :straight (:type built-in)
  :general
  (:keymaps 'Info-mode-map
            "b" 'Info-help
            "e" 'Info-prev
            "h" 'beginning-of-buffer
            "p" 'end-of-buffer
            "B" 'describe-mode)
  )

(use-package prescient
  :demand
  :after counsel
  :config
  (prescient-persist-mode 1)
  (setq prescient-filter-method '(literal regexp initialism))
  )

(use-package ivy-prescient
  :demand
  :after counsel prescient
  :config
  (ivy-prescient-mode 1)
  )

(use-package ivy-rich
  :diminish
  :demand
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev))

(use-package magit
  :demand
  :general
  (:keymaps 'git-rebase-mode-map
            "h" nil
            "p" nil
            "e" 'git-rebase-backward-line
            "M-p" nil
            "M-e" 'git-rebase-move-line-up)
  (:keymaps 'magit-mode-map
            "B" 'magit-describe-section
            "H" 'magit-bisect
            "e" 'magit-section-backward
            "p" 'magit-ediff-dwim
            "M-p" nil
            "M-e" 'magit-section-backward-sibling)
  :config
  (setq magit-bury-buffer-function #'magit-restore-window-configuration)
  )

(use-package magit-todos
  :after magit
  :ghook ('magit-mode-hook #'magit-todos-mode)
  )

(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

(use-package org
  :mode ("\\.org\\'" . org-mode)
  :general
  ("H-c" 'org-capture)
  (:keymaps 'org-mode-map
            "M-b" 'org-transpose-element
            "C-c SPC" '+org/dwim-at-point
            "C-c C-b" nil
            "C-c C-e" nil
            "C-c C-f" nil
            "C-c C-h" 'org-backward-heading-same-level
            "C-c C-1" 'org-forward-heading-same-level
            "C-c C-e" 'org-previous-visible-heading
            "C-c C-p" 'org-export-dispatch
            "C-c M-b" nil
            "C-c M-f" nil
            "C-c M-h" 'org-previous-block
            "C-c M-1" 'org-next-block
            )
  (:keymaps 'org-read-date-minibuffer-local-map
            "M-p" nil
            "M-e" 'previous-history-element)
  (:keymaps 'org-read-date-minibuffer-local-map
            "C-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-day 1)))
            "C-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-week 1)))
            "C-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-week 1)))
            "C-1" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-day 1)))
            "C-S-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-month 1)))
            "C-S-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-year 1)))
            "C-S-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-year 1)))
            "C-S-1" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-month 1)))
            )
  (:keymaps 'org-mode-map
            "M-h" #'backward-word ;; would be org-metaleft but conflicts with backward-word binding
            "C-M-h" #'org-metaleft
            "M-n" #'org-metadown
            "M-e" #'org-metaup
            "M-1" #'forward-word ;; would be org-metaright but conflicts with forward-word binding
            "C-M-1" #'org-metaright
            "M-S-h" #'org-shiftmetaleft
            "M-S-n" #'org-shiftmetadown
            "M-S-e" #'org-shiftmetaup
            "M-S-1" #'org-shiftmetaright
            "M-S-f" #'org-forward-sentence
            "C-S-h" #'org-shiftcontrolleft
            "C-S-n" #'org-shiftcontroldown
            "C-S-e" #'org-shiftcontrolup
            "C-S-1" #'org-shiftcontrolright
            )
  (:keymaps '(org-agenda-mode-map org-agenda-keymap)
            "e" 'org-agenda-previous-line
            "p" 'org-agenda-set-effort
            "E" 'org-agenda-previous-item
            "P" 'org-agenda-entry-text-mode
            )
  :config
  (auto-fill-mode 0)
  (general-add-hook 'org-mode-hook #'taylor-gl/ligatures-mode)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
  (setq org-ellipsis " ▼"
        org-directory "~/Dropbox/emacs/"
        org-agenda-files '("~/Dropbox/emacs/todo.org" "~/Dropbox/emacs/reference.org" "~/Dropbox/emacs/work.org")
        org-agenda-span 'month ;; show one month of agenda at a time
        org-link-shell-confirm-function nil ;; don't annoy me by asking for confirmation
        ;; don't show DONE items in agenda
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-use-time-grid nil
        org-agenda-search-headline-for-time nil
        org-hide-emphasis-markers t
        org-startup-indented t
        org-file-apps '((auto-mode . emacs)
                        (directory . emacs)
                        ("\\.mm\\'" . default)
                        ("\\.x?html?\\'" . default)
                        ("\\.pdf\\'" . "evince \"%s\"")
                        ("\\.djvu\\'" . "evince \"%s\"")
                        ("\\.epub\\'" . "ebook-viewer \"%s\"")
                        )
        org-log-into-drawer t ;; log into LOGBOOK drawer
        org-M-RET-may-split-line nil
        org-blank-before-new-entry '((heading . nil) (plain-list-item . nil))
        org-capture-templates
        '(
          ("g" "General Inbox" entry (file+headline "~/Dropbox/emacs/todo.org" "General")
           "* TODO %?" :prepend 1 )
          ("f" "Finances Inbox" entry (file+headline "~/Dropbox/emacs/todo.org" "Finances")
           "* TODO %?" :prepend 1 )
          ("w" "Words Inbox" entry (file+headline "~/Dropbox/emacs/todo.org" "Words")
           "* %?" :prepend 1 )
          )
        org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(i)" "SHOULD(s)" "MAYBE(m)" "NOTE(n)" "WAITING(w)" "NPC(p)" "MET(P)" "|" "DONE(d)" "ABANDONED(a)" ))
        org-todo-keyword-faces '(
                                 ("TODO" :foreground "#fb4932" :weight bold)
                                 ("INPROGRESS" :foreground "#fe8019" :weight bold)
                                 ("WAITING" :foreground "#fe8019" :weight bold)
                                 ("SHOULD" :foreground "#fabd2f" :weight bold)
                                 ("NOTE" :foreground "#b8bb26" :weight bold)
                                 ("MAYBE" :foreground "#fabd2f" :weight bold)
                                 ("DONE" :foreground "#a89984" :weight bold)
                                 ("ABANDONED" :foreground "#928374" :weight bold)
                                 )
        calendar-holidays '((holiday-fixed 1 1 "New Year's Day")
                            (holiday-float 2 1 3 "Family Day")
                            (holiday-fixed 2 14 "Valentine's Day")
                            (holiday-fixed 3 17 "St. Patrick's Day")
                            (holiday-fixed 4 1 "April Fools' Day")
                            (holiday-easter-etc -2 "Good Friday")
                            (holiday-easter-etc 0 "Easter")
                            (holiday-easter-etc 1 "Easter Monday")
                            (holiday-float 5 0 2 "Mother's Day")
                            (holiday-float 5 1 -2 "Victoria Day")
                            (holiday-float 6 0 3 "Father's Day")
                            (holiday-fixed 7 1 "Canada Day")
                            (holiday-float 8 1 1 "Civic Holiday")
                            (holiday-float 9 1 1 "Labour Day")
                            (holiday-float 10 1 2 "Thanksgiving")
                            (holiday-fixed 10 31 "Halloween")
                            (holiday-fixed 11 11 "Remembrance Day")
                            (holiday-fixed 12 24 "Christmas Eve")
                            (holiday-fixed 12 25 "Christmas")
                            (holiday-fixed 12 26 "Boxing Day")
                            (solar-equinoxes-solstices)
                            (holiday-sexp calendar-daylight-savings-starts
                                          (format "Daylight Saving Time Begins %s"
                                                  (solar-time-string
                                                   (/ calendar-daylight-savings-starts-time
                                                      (float 60))
                                                   calendar-standard-time-zone-name)))
                            (holiday-sexp calendar-daylight-savings-ends
                                          (format "Daylight Saving Time Ends %s"
                                                  (solar-time-string
                                                   (/ calendar-daylight-savings-ends-time
                                                      (float 60))
                                                   calendar-daylight-time-zone-name))))))

(use-package org-bullets
  :after org
  :ghook 'org-mode-hook
  :custom
  (org-bullets-bullet-list '("◇" "◆" "◉" "●" "○" "●" "○" "●" "○" "●" "○" "●")))

;; Setup org-cliplink to automatically create org links from http links in clipboard
(use-package org-cliplink)

(use-package rainbow-delimiters
  :ghook 'prog-mode-hook)

(use-package projectile
  :demand t
  :general
  ("C-c p" 'projectile-command-map)
  (:keymaps 'projectile-command-map
            "ESC" nil)
  ("H-f" 'projectile-find-file
   "H-/" 'projectile-ag
   )
  :config
  (projectile-mode t)
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-ignored-projects '(
                                      "/home/taylor"
                                      "~/"
                                      "~/Dropbox/"
                                      "~/bl/"
                                      ))
  ;; projectile-ignored-projects is ignored when using 'alien projectile-indexing-method (default).
  ;; This is because "ag" is used by projectile for searching instead of native projectile search.
  ;; This sets command-line settings for ag which ignore certain files/directories.
  (when (executable-find "ag")
    (setq projectile-generic-command
          (let ((ag-cmd ""))
            (setq ag-ignorefile
                  (concat "--path-to-ignore" " "
                          (expand-file-name "ag_ignore" user-emacs-directory)))
            (concat "ag -0 --files-with-matches --nocolor --hidden --one-device --path-to-ignore ~/.ignore"))))
  )

(use-package saveplace
  :straight (:type built-in)
  :demand
  :init
  (save-place-mode t)
  (setq save-place-file (concat user-emacs-directory "saveplace/")))

;; Setup shackle for window management
;; :regexp -- the buffer name is a regexp
;; :select -- select the new window
;; :inhibit-window-quit -- makes it so q doesn't quit the window, which is good for reused windows!
;; :ignore -- don't show the new buffer at all
;; :other -- reuse the other window (open one if there isn't another)
;; :same -- reuse this window (consider inhibit-window-quit)
;; :popup -- always popup a new window
;; :align ('above 'below 'left 'right) and :size for customizing the new window
;; :frame -- always popup a new frame
(use-package shackle
  :demand
  :init
  (setq shackle-rules '((("^\\*\\(?:[Cc]ompil\\(?:ation\\|e-Log\\)\\|Messages\\)" "^\\*info\\*$" "\\`\\*magit-diff: .*?\\'" grep-mode "*Flycheck errors*") :regexp t :align below :size 0.3)
                        ("^\\*\\(?:Wo\\)?Man " :regexp t :frame t)
                        ("^\\*Calc" :regexp t :size 0.4 :popup t)
                        ("^\\*Alchemist" :regexp t :align below :select t :size 0.3 :popup t)
                        ("^\\*lsp-help" :regexp t :select t :align bottom :size 0.2 :popup t)
                        (("^\\*Warnings" "^\\*Warnings" "^\\*CPU-Profiler-Report " "^\\*Memory-Profiler-Report " "^\\*Process List\\*" "*Error*") :regexp t :align below :select t :size 0.2 :popup t)
                        ("^\\*\\(?:Proced\\|timer-list\\|Abbrevs\\|Output\\|unsent mail\\)\\*" :regexp t :ignore t :popup t)
                        ("*ag search*" :regexp t :popup t :select t :align below :size 0.4)
                        ("^ \\*undo-tree\\*" :regexp t :frame t)
                        ("^\\*\\([Hh]elp\\|Apropos\\)" :regexp t :frame t)
                        ("\\`\\*magit.*?\\*\\'" :regexp t :frame t)
                        (magit-status-mode :frame t)
                        (magit-log-mode :frame t)
                        ))
  (setq shackle-default-rule '(:select t :same t)) ;; reuse current window for new buffers by default
  (setq shackle-default-size 0.4)
  :config
  (shackle-mode)
  )

(use-package smart-hungry-delete
  :bind (("<backspace>" . smart-hungry-delete-backward-char)
         ("C-d" . smart-hungry-delete-forward-char))
  :defer nil
  :config (smart-hungry-delete-add-default-hooks)
  )

(defun taylor-gl/transpose-sexps-backward ()
  (interactive "*")
  (sp-transpose-sexp -1)
  )
(use-package smartparens
  :general
  ("H-C-1" 'sp-transpose-sexp
   "H-C-h" 'taylor-gl/transpose-sexps-backward
   "H-h" 'sp-backward-symbol
   "H-i" 'sp-forward-symbol
   "H-@" 'er/mark-symbol
   "H-s" 'taylor-gl/hydra-smartparens/body
   "C-H-s" 'taylor-gl/hydra-smartparens-slurp/body
   )
  :init
  (setq sp-autoinsert-pair nil)
  (defhydra taylor-gl/hydra-smartparens-transpose ()
    "transpose"
    ("i" sp-transpose-sexp "forward")
    ("h" taylor-gl/transpose-sexps-backward "backward")
    )
  (defhydra taylor-gl/hydra-smartparens-slurp ()
    "slurp"
    ("i"  sp-forward-slurp-sexp "forward")
    ("h" sp-backward-slurp-sexp "backward")
    )
  (defhydra taylor-gl/hydra-smartparens-barf ()
    "barf"
    ("i"  sp-forward-barf-sexp "forward")
    ("h" sp-backward-barf-sexp "backward")
    )
  (defhydra taylor-gl/hydra-smartparens ()
    "sexp"
    ("h" sp-backward-sexp "backward" :column "move")
    ("i" sp-forward-sexp "forward")
    ("n" sp-down-sexp "down")
    ("e" sp-backward-up-sexp "up")
    ("a" sp-beginning-of-sexp "beginning")
    ("p" sp-end-of-sexp "end")
    ("t" taylor-gl/hydra-smartparens-transpose/body "transpose" :column "edit" :exit t)
    ("m" sp-mark-sexp "mark" :exit t)
    ("w" sp-copy-sexp "copy" :exit t)
    ("k" sp-kill-sexp "kill" :exit t)
    ("u" sp-unwrap-sexp "unwrap" :exit t)
    ("b" taylor-gl/hydra-smartparens-barf/body "barf" :exit t)
    ("s" taylor-gl/hydra-smartparens-slurp/body "slurp" :exit t)
    )
  )

(use-package tree-sitter
  :demand)

(use-package tree-sitter-langs
  :after tree-sitter
  :demand
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  )

(use-package undo-tree
  :demand
  :general
  ("C-z" 'undo-tree-undo
   "S-C-z" 'undo-tree-redo
   "<mouse-8>" 'undo-tree-undo
   "<drag-mouse-8>" 'undo-tree-undo
   "<mouse-9>" 'undo-tree-redo
   "<drag-mouse-9>" 'undo-tree-redo
   )
  (:keymaps 'undo-tree-visualizer-mode-map
            "C-b" nil
            "C-h" 'undo-tree-visualize-switch-branch-left
            "C-f" nil
            "C-i" 'undo-tree-visualize-switch-branch-right
            "C-p" nil
            "C-e" 'undo-tree-visualize-undo
            "b" nil
            "h" 'undo-tree-visualize-switch-branch-left
            "f" nil
            "i" 'undo-tree-visualize-switch-branch-right
            "p" nil
            "e" 'undo-tree-visualize-undo)
  (:keymaps 'undo-tree-visualizer-selection-mode-map
            "C-b" nil
            "C-h" 'undo-tree-visualizer-select-left
            "C-f" nil
            "C-i" 'undo-tree-visualizer-select-right
            "C-p" nil
            "C-e" 'undo-tree-visualizer-select-previous
            "b" nil
            "h" 'undo-tree-visualizer-select-left
            "f" nil
            "i" 'undo-tree-visualizer-select-right
            "p" nil
            "e" 'undo-tree-visualizer-select-previous)
  :config
  (global-undo-tree-mode)
  (setq undo-tree-history-dir (let ((dir (concat user-emacs-directory
                                                 "undo/")))
                                (make-directory dir :parents)
                                dir))
  (setq undo-tree-history-directory-alist `(("." . ,undo-tree-history-dir)))
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-enable-undo-in-region t))

;; Setup uniquify for better buffer names
(use-package uniquify
  :straight (:type built-in)
  :config
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets)
  :demand)

(use-package which-key
  :demand
  :general
  (:keymaps 'which-key-C-h-map
            "p" nil
            "e" 'which-key-show-previous-page-cycle
            "C-p" nil
            "C-e" 'which-key-show-previous-page-cycle)
  :init
  (setq which-key-sort-uppercase-first nil)
  :config
  (which-key-mode)
  :custom ;; must be custom, not config
  (which-key-setup-side-window-bottom)
  (which-key-idle-delay 0.01)
  (which-key-idle-secondary-delay 0.01))

;; Setup whitespace (to visualize trailing whitespace etc.)
(use-package whitespace
  :straight (:type built-in)
  :demand
  :init
  (global-whitespace-mode)
  :config
  (setq whitespace-style '(face trailing tabs tab-mark)))

(use-package yasnippet
  :demand
  :init
  (setq yas-snippet-dirs '("~/Dropbox/dotfiles/snippets"))
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :demand
  :after yasnippet)


;;+----------------------------------------------------------------------------------------+
;;|                                                                                        |
;;|   PROGRAMMING MODES                                                                    |
;;|                                                                                        |
;;+----------------------------------------------------------------------------------------+
(defun taylor-gl/setup-indent (n)
  ;; general
  (setq tab-width n
        ;; java/c/c++
        c-basic-offset n
        ;; web development
        js-indent-level n ; js-mode
        web-mode-markup-indent-offset n ; web-mode, html tag in html file
        web-mode-css-indent-offset n ; web-mode, css in html file
        web-mode-code-indent-offset n ; web-mode, js code in html file
        web-mode-block-padding n
        css-indent-offset n
        typescript-indent-level n)
  )

(defun taylor-gl/setup-code-mode ()
  (taylor-gl/setup-indent 2)
  (setq display-fill-column-indicator-column 100)
  (display-fill-column-indicator-mode)
  (format-all-ensure-formatter)
  (setq company-backends '((company-yasnippet company-capf company-dabbrev-code company-keywords)))
  (setq company-minimum-prefix-length 2) ;; 3 by default, I want it a little more aggressive for coding
  )

;; Various coding-related modes
(defconst code-mode-hooks
  '(prog-mode-hook python-mode-hook elisp-mode-hook elixir-mode-hook emacs-lisp-mode-hook sh-mode typescript-mode js-mode web-mode)
  )

;; Configure code modes
(mapc
 (lambda (code-mode-hook)
   (general-add-hook code-mode-hook #'taylor-gl/setup-code-mode)
   (general-add-hook code-mode-hook #'smartparens-mode)
   )
 code-mode-hooks)

;; Setup tide-mode for typescript
(use-package typescript-mode)

(defun setup-tide-mode ()
  (tide-setup)
  ;; (flycheck-mode t)
  ;; (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (tide-hl-identifier-mode t)
  (setq company-tooltip-align-annotations t)
  )

(defun maybe-activate-tide-mode ()
  (when (and (stringp buffer-file-name)
             (string-match "\\.[tj]sx?\\'" buffer-file-name))
    (tide-setup)
    (tide-hl-identifier-mode)
    )
  )

(use-package tide
  :ghook ('typescript-mode-hook #'setup-tide-mode)
  :ghook ('web-mode-hook #'maybe-activate-tide-mode)
  :ghook ('js-mode-hook #'setup-tide-mode)
  :general
  (:keymaps 'tide-references-map
            "p" nil
            "e" 'tide-find-previous-reference)
  (:keymaps 'tide-project-errors-mode-map
            "p" nil
            "e" 'tide-find-previous-error)
  ;; :config
  ;; (flycheck-add-mode 'typescript-tslint 'web-mode)
  ;; (flycheck-add-mode 'javascript-eslint 'web-mode)
  ;; (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  ;; (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  )

;; Setup web-mode for HTML, CSS, JSX/TSX, elixir .eex files, etc.
(use-package web-mode
  :mode "\\.[px]?html?\\'"
  :mode "\\.\\(?:tpl\\|blade\\)\\(?:\\.php\\)?\\'"
  :mode "\\.erb\\'"
  :mode "\\.l?eex\\'"
  :mode "\\.jsp\\'"
  :mode "\\.as[cp]x\\'"
  :mode "\\.hbs\\'"
  :mode "\\.mustache\\'"
  :mode "\\.svelte\\'"
  :mode "\\.twig\\'"
  :mode "\\.jinja2?\\'"
  :mode "\\.eco\\'"
  :mode "wp-content/themes/.+/.+\\.php\\'"
  :mode "templates/.+\\.php\\'"
  :mode "\\.jsx\\'"
  :mode "\\.tsx\\'"
  :mode "\\.svg\\'"
  :general
  (:keymaps 'web-mode-map
            "C-c C-t b" nil
            "C-c C-t h" 'web-mode-tag-beginning
            "C-c C-t p" 'web-mode-tag-end
            "C-c C-t e" 'web-mode-tag-previous
            "C-c C-e b" nil
            "C-c C-e h" 'web-mode-element-beginning
            "C-c C-e p" 'web-mode-element-end
            "C-c C-e e" 'web-mode-element-previous
            "C-c C-b b" nil
            "C-c C-b h" 'web-mode-block-beginning
            "C-c C-b p" 'web-mode-block-end
            "C-c C-b e" 'web-mode-block-previous
            "C-c C-a b" nil
            "C-c C-a h" 'web-mode-attribute-beginning
            "C-c C-a p" 'web-mode-attribute-end
            "C-c C-a e" 'web-mode-attribute-previous)
  :init
  (setq web-mode-enable-html-entities-fontification t
        web-mode-auto-close-style 1
        web-mode-enable-auto-quoting nil
        web-mode-enable-auto-pairing nil
        web-mode-enable-current-column-highlight t)
  :config
  (add-to-list 'web-mode-engines-alist '("elixir" . "\\.eex\\'"))
  )

(use-package elixir-mode
  :ghook ('elixir-mode-hook #'taylor-gl/ligatures-mode)
  )

(use-package sh-script
  :straight (:type built-in))

(use-package slime
  :config
  (setq slime-lisp-implementations
        '(
          (sbcl ("/usr/bin/sbcl" "--dynamic-space-size" "2GB") :coding-system utf-8-unix)
          )
        slime-net-coding-system 'utf-8-unix
        slime-export-save-file t
        slime-contribs '(slime-fancy slime-repl slime-scratch slime-trace-dialog)
        lisp-simple-loop-indentation 1
        list-loop-keyword-indentation 6
        lisp-loop-forms-indentation 6)
  (add-hook 'slime-load-hook (lambda () (require 'slime-fancy)))
  )

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package typo
  :ghook 'markdown-mode-hook
  :config
  (typo-global-mode t)
  )


;;+----------------------------------------------------------------------------------------+
;;|                                                                                        |
;;|   UTILITY FUNCTIONS                                                                    |
;;|                                                                                        |
;;+----------------------------------------------------------------------------------------+
;; Based on crux-find-user-init-file, but opens in the same window
(defun taylor-gl/find-user-init-file ()
  "Edit the `user-init-file', in the same window."
  (interactive)
  (find-file user-init-file))

(general-define-key
 "C-c f u i f" 'taylor-gl/find-user-init-file)

(setq taylor-gl/prettify-symbols-alist '(
                                         ("#+BEGIN_SRC" . "†")
                                         ("#+END_SRC" . "†")
                                         ("#+BEGIN_QUOTE" . "†")
                                         ("#+END_QUOTE" . "†")
                                         ("#+begin_src" . "†")
                                         ("#+end_src" . "†")
                                         ("#+begin_quote" . "†")
                                         ("#+end_quote" . "†")
                                         ("lambda" . ?λ)
                                         ("infinity" . ?∞)
                                         ))

(defvar taylor-gl/ligatures--old-prettify-alist)

(defun taylor-gl/ligatures-mode--enable ()
  "Enable ligatures in current buffer."
  (setq-local taylor-gl/ligatures--old-prettify-alist prettify-symbols-alist)
  (setq-local prettify-symbols-alist (append taylor-gl/prettify-symbols-alist taylor-gl/ligatures--old-prettify-alist))
  (setq prettify-symbols-unprettify-at-point 'right-edge) ;; don't form ligatures under the cursor
  (prettify-symbols-mode t))

(defun taylor-gl/ligatures-mode--disable ()
  "Disable ligatures in current buffer."
  (setq-local prettify-symbols-alist taylor-gl/ligatures--old-prettify-alist)
  (prettify-symbols-mode -1))

(define-minor-mode taylor-gl/ligatures-mode
  "Ligatures minor mode"
  :lighter " Fira Code"
  (setq-local prettify-symbols-unprettify-at-point 'right-edge)
  (if taylor-gl/ligatures-mode
      (taylor-gl/ligatures-mode--enable)
    (taylor-gl/ligatures-mode--disable)))

(defun taylor-gl/ligatures-mode--setup ()
  "Setup ligatures Symbols"
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol"))

(provide 'taylor-gl/ligatures-mode)

;; +org/dwim-at-point is from doom-emacs
(defun +org--toggle-inline-images-in-subtree (&optional beg end refresh)
  "Refresh inline image previews in the current heading/tree."
  (let ((beg (or beg
                 (if (org-before-first-heading-p)
                     (line-beginning-position)
                   (save-excursion (org-back-to-heading) (point)))))
        (end (or end
                 (if (org-before-first-heading-p)
                     (line-end-position)
                   (save-excursion (org-end-of-subtree) (point)))))
        (overlays (cl-remove-if-not (lambda (ov) (overlay-get ov 'org-image-overlay))
                                    (ignore-errors (overlays-in beg end)))))
    (dolist (ov overlays nil)
      (delete-overlay ov)
      (setq org-inline-image-overlays (delete ov org-inline-image-overlays)))
    (when (or refresh (not overlays))
      (org-display-inline-images t t beg end)
      t)))

(defun +org--insert-item (direction)
  (let ((context (org-element-lineage
                  (org-element-context)
                  '(table table-row headline inlinetask item plain-list)
                  t)))
    (pcase (org-element-type context)
      ;; Add a new list item (carrying over checkboxes if necessary)
      ((or `item `plain-list)
       ;; Position determines where org-insert-todo-heading and org-insert-item
       ;; insert the new list item.
       (if (eq direction 'above)
           (org-beginning-of-item)
         (org-end-of-item)
         (backward-char))
       (org-insert-item (org-element-property :checkbox context))
       ;; Handle edge case where current item is empty and bottom of list is
       ;; flush against a new heading.
       (when (and (eq direction 'below)
                  (eq (org-element-property :contents-begin context)
                      (org-element-property :contents-end context)))
         (org-end-of-item)
         (org-end-of-line)))

      ;; Add a new table row
      ((or `table `table-row)
       (pcase direction
         ('below (save-excursion (org-table-insert-row t))
                 (org-table-next-row))
         ('above (save-excursion (org-shiftmetadown))
                 (+org/table-previous-row))))

      ;; Otherwise, add a new heading, carrying over any todo state, if
      ;; necessary.
      (_
       (let ((level (or (org-current-level) 1)))
         ;; I intentionally avoid `org-insert-heading' and the like because they
         ;; impose unpredictable whitespace rules depending on the cursor
         ;; position. It's simpler to express this command's responsibility at a
         ;; lower level than work around all the quirks in org's API.
         (pcase direction
           (`below
            (let (org-insert-heading-respect-content)
              (goto-char (line-end-position))
              (org-end-of-subtree)
              (insert "\n" (make-string level ?*) " ")))
           (`above
            (org-back-to-heading)
            (insert (make-string level ?*) " ")
            (save-excursion (insert "\n"))))
         (when-let* ((todo-keyword (org-element-property :todo-keyword context))
                     (todo-type    (org-element-property :todo-type context)))
           (org-todo
            (cond ((eq todo-type 'done)
                   ;; Doesn't make sense to create more "DONE" headings
                   (car (+org-get-todo-keywords-for todo-keyword)))
                  (todo-keyword)
                  ('todo)))))))

    (when (org-invisible-p)
      (org-show-hidden-entry))
    (when (and (bound-and-true-p evil-local-mode)
               (not (evil-emacs-state-p)))
      (evil-insert 1))))

(defun +org--get-property (name &optional bound)
  (save-excursion
    (let ((re (format "^#\\+%s:[ \t]*\\([^\n]+\\)" (upcase name))))
      (goto-char (point-min))
      (when (re-search-forward re bound t)
        (buffer-substring-no-properties (match-beginning 1) (match-end 1))))))

(defun +org-get-global-property (name &optional file bound)
  "Get a document property named NAME (string) from an org FILE (defaults to
current file). Only scans first 2048 bytes of the document."
  (unless bound
    (setq bound 256))
  (if file
      (with-temp-buffer
        (insert-file-contents-literally file nil 0 bound)
        (+org--get-property name))
    (+org--get-property name bound)))

(defun +org-get-todo-keywords-for (&optional keyword)
  "Returns the list of todo keywords that KEYWORD belongs to."
  (when keyword
    (cl-loop for (type . keyword-spec)
             in (cl-remove-if-not #'listp org-todo-keywords)
             for keywords =
             (mapcar (lambda (x) (if (string-match "^\\([^(]+\\)(" x)
                                (match-string 1 x)
                              x))
                     keyword-spec)
             if (eq type 'sequence)
             if (member keyword keywords)
             return keywords)))

(defun +org/dwim-at-point (&optional arg)
  "Do-what-I-mean at point.
If on a:
- checkbox list item or todo heading: toggle it.
- clock: update its time.
- headline: cycle ARCHIVE subtrees, toggle latex fragments and inline images in
  subtree; update statistics cookies/checkboxes and ToCs.
- footnote reference: jump to the footnote's definition
- footnote definition: jump to the first reference of this footnote
- table-row or a TBLFM: recalculate the table's formulas
- table-cell: clear it and go into insert mode. If this is a formula cell,
  recaluclate it instead.
- babel-call: execute the source block
- statistics-cookie: update it.
- latex fragment: toggle it.
- link: follow it
- otherwise, refresh all inline images in current tree."
  (interactive "P")
  (let* ((context (org-element-context))
         (type (org-element-type context)))
    ;; skip over unimportant contexts
    (while (and context (memq type '(verbatim code bold italic underline strike-through subscript superscript)))
      (setq context (org-element-property :parent context)
            type (org-element-type context)))
    (pcase type
      (`headline
       (cond ((memq (bound-and-true-p org-goto-map)
                    (current-active-maps))
              (org-goto-ret))
             ((and (fboundp 'toc-org-insert-toc)
                   (member "TOC" (org-get-tags)))
              (toc-org-insert-toc)
              (message "Updating table of contents"))
             ((string= "ARCHIVE" (car-safe (org-get-tags)))
              (org-force-cycle-archived))
             ((or (org-element-property :todo-type context)
                  (org-element-property :scheduled context))
              (org-todo
               (if (eq (org-element-property :todo-type context) 'done)
                   (or (car (+org-get-todo-keywords-for (org-element-property :todo-keyword context)))
                       'todo)
                 'done))))
       ;; Update any metadata or inline previews in this subtree
       (org-update-checkbox-count)
       (org-update-parent-todo-statistics)
       (when (and (fboundp 'toc-org-insert-toc)
                  (member "TOC" (org-get-tags)))
         (toc-org-insert-toc)
         (message "Updating table of contents"))
       (let* ((beg (if (org-before-first-heading-p)
                       (line-beginning-position)
                     (save-excursion (org-back-to-heading) (point))))
              (end (if (org-before-first-heading-p)
                       (line-end-position)
                     (save-excursion (org-end-of-subtree) (point))))
              (overlays (ignore-errors (overlays-in beg end)))
              (latex-overlays
               (cl-find-if (lambda (o) (eq (overlay-get o 'org-overlay-type) 'org-latex-overlay))
                           overlays))
              (image-overlays
               (cl-find-if (lambda (o) (overlay-get o 'org-image-overlay))
                           overlays)))
         (+org--toggle-inline-images-in-subtree beg end)
         (if (or image-overlays latex-overlays)
             (org-clear-latex-preview beg end)
           (org--latex-preview-region beg end))))

      (`clock (org-clock-update-time-maybe))

      (`footnote-reference
       (org-footnote-goto-definition (org-element-property :label context)))

      (`footnote-definition
       (org-footnote-goto-previous-reference (org-element-property :label context)))

      ((or `planning `timestamp)
       (org-follow-timestamp-link))

      ((or `table `table-row)
       (if (org-at-TBLFM-p)
           (org-table-calc-current-TBLFM)
         (ignore-errors
           (save-excursion
             (goto-char (org-element-property :contents-begin context))
             (org-call-with-arg 'org-table-recalculate (or arg t))))))

      (`table-cell
       (org-table-blank-field)
       (org-table-recalculate arg)
       (when (and (string-empty-p (string-trim (org-table-get-field)))
                  (bound-and-true-p evil-local-mode))
         (evil-change-state 'insert)))

      (`babel-call
       (org-babel-lob-execute-maybe))

      (`statistics-cookie
       (save-excursion (org-update-statistics-cookies arg)))

      ((or `src-block `inline-src-block)
       (org-babel-execute-src-block arg))

      ((or `latex-fragment `latex-environment)
       (org-latex-preview arg))

      (`link
       (let* ((lineage (org-element-lineage context '(link) t))
              (path (org-element-property :path lineage)))
         (if (or (equal (org-element-property :type lineage) "img")
                 (and path (image-type-from-file-name path)))
             (+org--toggle-inline-images-in-subtree
              (org-element-property :begin lineage)
              (org-element-property :end lineage))
           (org-open-at-point arg))))

      ((guard (org-element-property :checkbox (org-element-lineage context '(item) t)))
       (let ((match (and (org-at-item-checkbox-p) (match-string 1))))
         (org-toggle-checkbox (if (equal match "[ ]") '(16)))))

      (_
       (if (or (org-in-regexp org-ts-regexp-both nil t)
               (org-in-regexp org-tsr-regexp-both nil  t)
               (org-in-regexp org-link-any-re nil t))
           (call-interactively #'org-open-at-point)
         (+org--toggle-inline-images-in-subtree
          (org-element-property :begin context)
          (org-element-property :end context)))))))
