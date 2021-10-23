;; =============================================================================
;; TODO
;; =============================================================================
;; NOTE: if something isn't working, check if :demand should be set
;;
;; Global:
;; INPROGRESS: setup <localleader>
;; Fix:
;; TODO: get which-key paging keybindings working
;; Packages:
;; TODO: LSP: better keybindings for some lsp functionality like lsp-find-definition, lsp-find-references, etc.
;; TODO: LSP: setup debugger (dap-mode)
;; INPROGRESS: smartparens (TODO: bindings; configure)
;; TODO: yascroll
;; TODO: writegood mode
;; TODO: a spell checker, with settings turned to the minimum. or grammarly
;; TODO: org-noter?
;; TODO: outline mode
;; TODO: selectrum and icomplete?
;; Languages: (lsp and repl at least)
;; TODO: Bash
;; TODO: C and C++
;; TODO: GDscript
;; TODO: Grammarly has lsp-mode support lol
;; TODO: HTML/CSS/Javascript/JSON
;; TODO: Haskell
;; TODO: Java
;; TODO: Markdown
;; TODO: Rust
;; INPROGRESS: SQL
;; INPROGRESS: Latex; Latex org integration
;; TODO: XML/YAML/TOML
;; Ideas:
;; MAYBE: something like https://tonsky.me/blog/sublime-writer/, maybe using wordsmith mode
;; MAYBE: https://tecosaur.github.io/emacs-config/config.html
;; MAYBE: https://github.com/wasamasa/dotemacs/blob/master/init.org
;; MAYBE: https://lepisma.xyz/2017/10/28/ricing-org-mode/index.html
;; MAYBE: https://mstempl.netlify.app/post/beautify-org-mode/
;; MAYBE: https://github.com/emacs-tw/awesome-emacs#key-bindings

(setq user-full-name "Taylor G. Lunt"
      user-mail-address "taylor@taylor.gl")
;; =============================================================================
;; GENERAL
;; =============================================================================
;; Clean up the interface
(setq inhibit-startup-message t)
(setq visible-bell t)
(setq frame-resize-pixelwise t) ;; for tiling window manager
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(global-visual-line-mode t)

;; Fonts
;; The following must use default-frame-alist rather than set-face-attribute, otherwise
;; emacsclient starts with the wrong font size compared to emacs proper
;;(add-to-list 'default-frame-alist '(font . "FantasqueSansMono Nerd Font Mono-12"))
;; (set-face-attribute 'variable-pitch nil :font "Noto Sans" :height 126 :weight 'regular)
(set-face-attribute 'default nil :family "FantasqueSansMono Nerd Font" :height 120)

;; Performance (or the illusion thereof)
;; emacs >= 27 required:
;; (setq bidi-inhibit-bpa t)
(setq bidi-paragraph-direction 'left-to-right)
(setq-default bidi-paragraph-direction 'left-to-right)
(setq echo-keystrokes 0.01)
;; lower than default undo limit so it doesn't crash my emacs or cause problems with undo-tree
(setq undo-limit 10000
      undo-outer-limit 4000000
      undo-strong-limit 15000)
(setq gc-cons-threshold 100000000) ;; recommended for lsp-mode
;; emacs >= 27 required:
;; (setq read-process-output-max (* 1024 1024)) ;; 1mb read: recommended for lsp-mode

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

;; Scrolling
;; TODO control scrolling currently affects zoom
(setq mouse-wheel-scroll-amount '(3 ((control) . 6))) ;; two lines at a time unless control held
(setq mouse-wheel-progressive-speed nil) ;; no scroll acceleration, because who would want that?

;; Do not force files to end with a newline
(setq require-final-newline nil)

;; Auto-saving
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 5)  ;; save after 5 seconds of idle time
(setq backup-directory-alist
      `(("." . ,"~/.emacs.d/backups")))
(setq auto-save-file-name-transforms
      `((".*" ,(concat user-emacs-directory "auto-save-list/") t)))

;; Don't ask me for confirmation when closing buffers with running processes etc.
(setq kill-buffer-query-functions nil)

;; Scratch buffer
(setq initial-major-mode #'fundamental-mode)
(setq initial-scratch-message nil)

;; Delete files to the trash
(setq-default delete-by-moving-to-trash t)

;; Stretch the cursor to the width of a glyph (even e.g. a tab glyph)
(setq-default x-stretch-cursor t)

;; Disable warning messages
(setq warning-minimum-level :error)

;; Count words within CamelCaseWords as seperate words
(global-subword-mode 1)

;; =============================================================================
;; PACKAGES AND KEYBINDINGS
;; =============================================================================
;; Set up straight.el and use-package for package management
(setq straight-use-package-by-default t)
;; bootstrap boilerplate needed to install straight.el:
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

;; Setup general -- better keybindings and leader key
;; Use like this in use-package blocks to define mode-specific keybindings under <localleader> (SPC m):
;; :init
;; (taylor-gl/localleader-def-create! org-mode-map
;; "SPC" 'save-buffer)
(defmacro taylor-gl/localleader-def-create! (keymap &rest body)
  "Create a definer named taylor-gl/localleader-def-KEYMAP in the global SPC m <localleader> menu."
  (declare (indent 2))
  `(progn
     (general-create-definer ,(intern (concat "taylor-gl/localleader-def-" (symbol-name keymap)))
       :states '(normal insert visual emacs)
       :keymaps ',keymap
       :prefix "SPC m"
       :global-prefix "C-SPC m")
     (,(intern (concat "taylor-gl/localleader-def-" (symbol-name keymap)))
      ,@body)))

(use-package general
  :demand
  :config
  (general-evil-setup t)
  (general-create-definer taylor-gl/leader-def
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC"
    "" '(:ignore t :which-key "<leader>"))
  ;; many of these come from doom emacs
  (taylor-gl/leader-def
    "SPC" #'save-buffer
    "RET" #'counsel-bookmark
    "TAB" #'(lambda (&optional arg) (interactive "P")(org-agenda-list arg)) ;; open agenda for next month
    "/" #'comment-line
    ":" #'counsel-M-x
    ";" #'pp-eval-expression
    "=" #'format-all-buffer
    "b" #'(:ignore t :which-key "buffer")
    "b b" #'(counsel-switch-buffer :which-key "switch buffers")
    "b d" #'(kill-current-buffer :which-key "kill this buffer")
    "b D" #'(kill-buffer :which-key "kill a buffer")
    "b k" #'(crux-kill-other-buffers :which-key "kill all other buffers")
    "b n" #'(next-buffer :which-key "next buffer")
    "b p" #'(crux-switch-to-previous-buffer :which-key "previous buffer")
    "b m" #'(bookmark-set :which-key "bookmark")
    "b M" #'(bookmark-delete :which-key "remove bookmark")
    "b z" #'(hydra-zoom/body :which-key "zoom")
    "e" #'(:ignore t :which-key "edit")
    "e y" #'(flycheck-copy-errors-as-kill :which-key "yank error")
    "e n" #'(flycheck-next-error :which-key "next error")
    "e p" #'(flycheck-previous-error :which-key "previous error")
    "e l" #'(flycheck-list-errors :which-key "list errors")
    "e v" #'(flycheck-verify-setup :which-key "verify flycheck checker")
    "f" #'(:ignore t :which-key "file")
    "f i" #'(crux-find-user-init-file :which-key "find init.el")
    "f d" #'(dired-jump :which-key "dir of this file")
    "f f" #'(counsel-find-file :which-key "find file")
    "f l" #'(counsel-locate :which-key "locate file")
    "f r" #'(counsel-recentf :which-key "recent file")
    "f SPC" #'(write-file :which-key "save file as...")
    "g" #'(:ignore t :which-key "git")
    "g B" #'(magit-blame-addition :which-key "blame")
    "g d" #'(magit-diff-buffer-file :which-key "diff this file")
    "g g" #'(magit-status :which-key "status")
    "g G" #'(magit-status-here :which-key "status here")
    "g e" #'(git-gutter:previous-hunk :which-key "previous hunk")
    "g h" #'(git-gutter:mark-hunk :which-key "select hunk")
    "g n" #'(git-gutter:next-hunk :which-key "next hunk")
    "g r" #'(git-gutter:revert-hunk :whick-key "revert hunk")
    "g s" #'(git-gutter:stage-hunk :whick-key "stage hunk")
    "g t" #'(magit-todos-list :whick-key "list repo todos")
    ;; replaced by bookmarking todo.org
    ;; TODO: fix this so it works again
    ;; "t" #'((lambda () (interactive)(counsel-find-file "~/Dropbox/emacs/todo.org")) :which-key "todo.org")
    "h" #'(:ignore t :which-key "help")
    "h b" #'(describe-personal-keybindings :which-key "describe personal keybindings")
    "h c" #'(describe-char :which-key "describe char")
    "h e" #'(view-echo-area-messages :which-key "show echo")
    "h f" #'(helpful-function :which-key "describe function")
    "h k" #'(describe-key-briefly :which-key "describe key")
    "h K" #'(helpful-key :which-key "describe key in depth")
    "h m" #'(describe-mode :which-key "describe modes")
    "h M" #'(+default/man-or-woman :which-key "man page")
    "h r" #'(info-emacs-manual :which-key "emacs info pages")
    "h v" #'(helpful-variable :which-key "describe variable")
    "i" #'(:ignore t :which-key "insert")
    "i d" #'(crux-insert-date :which-key "insert date")
    "i e" #'(yas-visit-snippet-file :which-key "edit snippet")
    "i n" #'(yas-new-snippet :which-key "new snippet")
    "i s" #'(yas-insert-snippet :which-key "insert snippet")
    "i x" #'(crux-delete-buffer-and-file :which-key "delete current buffer file")
    "m" #'(:ignore t :which-key "<localleader>")
    "p" '(:keymap projectile-command-map :package projectile :which-key "project")
    "u" #'(:ignore t :which-key "undo")
    "u l" #'(undo-tree-undo :which-key "undo (last)")
    "u r" #'(undo-tree-redo :which-key "redo")
    "u u" #'(undo-tree-visualize :which-key "view tree")
    "q" #'(:ignore t :which-key "quit")
    "q e" #'(save-buffers-kill-emacs :which-key "quit emacs")
    "q E" #'(evil-quit-all-with-error-code :which-key "quit emacs without saving")
    "q q" #'(save-buffers-kill-terminal :which-key "quit frame")
    "r" #'(:ignore t :which-key "roam")
    "r d" #'(org-roam-buffer-toggle-display :which-key "roam display")
    "r b" #'(helm-bibtex :which-key "view bibliography")
    "r c" #'(org-roam-capture :which-key "capture note")
    "r f" #'(org-roam-find-file :which-key "find roam note")
    "r g" #'(org-roam-graph :which-key "graph")
    "r i" #'(org-roam-insert :which-key "insert note citation")
    "r l" #'(org-ref-insert-link :which-key "insert link to reference")
    "r p" #'(org-mark-ring-goto :which-key "previous note")
    "r r" #'(org-roam-buffer-toggle-display :which-key "start roam")
    "r t" #'(org-roam-tag-add :which-key "add tag")
    "r T" #'(org-roam-tag-delete :which-key "delete tag")
    "r u" #'(org-roam-update :which-key "update roam now")
    "r x" #'(crux-delete-buffer-and-file :which-key "delete this note")
    "s" #'(:ignore t :which-key "search")
    "s f" #'(counsel-locate :which-key "file locate")
    "s i" #'(counsel-imenu :which-key "imenu (find symbol)")
    "s n" #'(hl-todo-next :which-key "next hl-todo symbol")
    "s p" #'(hl-todo-previous :which-key "previous hl-todo symbol")
    "s r" #'(counsel-mark-ring :which-key "mark ring")
    "s t" #'(swiper-isearch-thing-at-point :which-key "thing at point")
    "w" #'(:ignore t :which-key "window")
    "w +" #'(evil-window-increase-height :which-key "increase height")
    "w -" #'(evil-window-decrease-height :which-key "decrease height")
    "w >" #'(evil-window-increase-width :which-key "increase width")
    "w <" #'(evil-window-decrease-width :which-key "decrease width")
    "w =" #'(balance-windows :which-key "balance windows")
    "w d" #'(evil-window-delete :which-key "delete")
    "w h" #'(evil-window-left :which-key "left")
    "w n" #'(evil-window-down :which-key "down")
    "w e" #'(evil-window-up :which-key "up")
    "w i" #'(evil-window-right :which-key "right")
    "w n" #'(evil-window-next :which-key "next")
    "w p" #'(evil-window-mru :which-key "previous")
    "w s" #'(evil-window-split :which-key "split above/below")
    "w v" #'(evil-window-vsplit :which-key "split left/right")
    "w H" #'(+evil/window-move-left :which-key "left")
    "w N" #'(+evil/window-move-down :which-key "down")
    "w E" #'(+evil/window-move-up :which-key "up")
    "w I" #'(+evil/window-move-right :which-key "right")
    "x" #'(:ignore t :which-key "regex")
    "x c" #'(how-many :which-key "count occurences")
    "x f" #'(flush-lines :which-key "flush lines")
    "x h" #'(highlight-regexp :which-key "highlight")
    "x k" #'(keep-lines :which-key "keep lines")
    "x r" #'(query-replace :which-key "replace")
    "x R" #'(query-replace-regexp :which-key "replace regex")
    ))

;; Setup which-key -- shows a menu of which keybindings are available
(use-package which-key
  :init
  (which-key-mode)
  (setq which-key-sort-uppercase-first nil)
  ;; TODO: get these keybindings working
  ;; :general
  ;; (:keymaps 'which-key-C-h-map
	;; "j" nil
	;; "k" nil
	;; "n" which-key-show-next-page-cycle
	;; "e" which-key-show-previous-page-cycle
	;; "l" which-key-undo-key
	;; "C-l" which-key-undo-key)
  :diminish
  :custom ;; must use :custom, not :config
  (which-key-allow-evil-operators t)
  (which-key-setup-side-window-bottom)
  (which-key-idle-delay 0.01)
  (which-key-idle-secondary-delay 0.01))

;; Setup hydra
(use-package hydra
  :demand)

(defhydra hydra-zoom (nil nil)
  "zoom"
  ("e" text-scale-increase "increase")
  ("n" text-scale-decrease "decrease"))

;; Setup crux
(use-package crux
  :after evil
  :demand t
  :general
  (:states 'normal
	         "go" #'crux-smart-open-line
	         "gO" #'crux-smart-open-line-above)
  :config
  (crux-reopen-as-root-mode t))

;; Setup undo-tree
(use-package undo-tree
  :demand
  :general
  (:keymaps undo-tree-visualizer-mode-map
	          "e" #'undo-tree-visualize-undo
	          "n" #'undo-tree-visualize-redo
	          "h" #'undo-tree-visualize-switch-branch-left
	          "i" #'undo-tree-visualize-switch-branch-right
	          "C-e" #'undo-tree-visualize-undo-to-x
	          "C-n" #'undo-tree-visualize-redo-to-x)
  :init
  (setq undo-tree-enable-undo-in-region)
  :config
  (global-undo-tree-mode)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  (setq undo-tree-auto-save-history t)
  )

;; =============================================================================
;; INTERFACE
;; =============================================================================
;; Set the window title based on save state and the buffer title (based on tecosaur's config)
(setq frame-title-format
      '(""
        (:eval
         (format (if (buffer-modified-p) "💾︎ %s" " %s") (buffer-name)))))

;; Setup counsel/ivy/swiper
(use-package counsel ;; includes ivy and swiper
  :diminish
  :after evil
  :general
  (:states 'normal
           "?" #'swiper-isearch
           ":" #'counsel-M-x)
  (:keymaps 'minibuffer-local-map
            "C-r" #'counsel-minibuffer-history)
  :demand
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d) ")
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)") ;; hide certain files; from doom emacs
  )

;; Setup ivy-prescient for better sorting and filtering of ivy results
(use-package prescient
  :demand
  :after counsel
  :config
  (prescient-persist-mode 1)
  )

(use-package ivy-prescient
  :demand
  :after counsel prescient
  :config
  (ivy-prescient-mode 1)
  )

;; Setup ivy-rich
(use-package ivy-rich
  :diminish
  :demand
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev))

;; Setup helpful -- better help menus
(use-package helpful
  :demand
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable))

;; Setup doom-modeline from doom emacs
(use-package doom-modeline
  :ghook 'after-init-hook
  :init
  (setq doom-modeline-enable-word-count t)
  (setq doom-modeline-icon t)
  :config
  ;; Show column number in doom-modeline
  (column-number-mode)
  )

;; Setup all-the-icons
;; (Needed by doom-modeline)
(use-package all-the-icons)

(use-package all-the-icons-dired
  :ghook #'dired-mode-hook)

;; Setup doom-themes
(use-package doom-themes
  :demand
  :custom-face
  ;; change ugly org-level-1 etc. color choices
  (outline-1 ((t (:foreground "#fadb2f")))) ;; only bold level 1 face
  (outline-2 ((t (:foreground "#8ec07c"))))
  (outline-3 ((t (:foreground "#a2bbb1"))))
  (outline-4 ((t (:foreground "#8ec07c"))))
  (outline-5 ((t (:foreground "#a2bbb1"))))
  (outline-6 ((t (:foreground "#8ec07c"))))
  (outline-7 ((t (:foreground "#a2bbb1"))))
  (outline-8 ((t (:foreground "#8ec07c"))))
  :config
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  (load-theme 'doom-gruvbox t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; Setup whitespace (to visualize trailing whitespace etc.)
(use-package whitespace
  :demand
  :init
  (global-whitespace-mode)
  :config
  (setq whitespace-style '(face trailing tabs tab-mark)))

;; Setup rainbow-delimiters
(use-package rainbow-delimiters
  :ghook 'prog-mode-hook)

;; Setup evil-goggles (highlights evil motions)
(use-package evil-goggles
  :after evil
  :ghook 'evil-mode-hook
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

;; Setup hl-line (highlights the current line)
(use-package hl-line
  :straight (:type built-in)
  :demand
  :config
  (global-hl-line-mode 1))

;; Setup paren
(use-package paren
  :straight (:type built-in)
  :demand
  :config
  (show-paren-mode +1))

;; Setup saveplace (saves place in file)
(use-package saveplace
  :straight (:type built-in)
  :demand
  :init
  (save-place-mode t)
  (setq save-place-file "~/.emacs.d/.saveplace"))

;; Setup typo.el for inserting typographic symbols
(use-package typo
  :ghook 'markdown-mode-hook
  :demand
  :config
  (typo-global-mode 1))

;; ligatures
(setq taylor-gl/custom-prettify-symbols-alist '(
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
                                                ("therefore" . ?∴)
                                                ("because" . ?∵)
                                                ("&&" . ?∧)
                                                ("||" . ?∨)
                                                ("<=" . ?≤)
                                                (">=" . ?≥)
                                                ;; ("<<" . ?≪)
                                                ;; (">>" . ?≫)
                                                ("/=" . ?≠)
                                                ("!=" . ?≠)
                                                ("~>" . ?⇝)
                                                ("<~" . ?⇜)
                                                ("~~>" . ?⟿)
                                                ("<=<" . ?↢)
                                                (">=>" . ?↣)
                                                ("->" . ?→)
                                                ("-->" . ?⟶)
                                                ("<-" . ?←)
                                                ("<--" . ?⟵)
                                                ("<=>" . ?⇔)
                                                ("<==>" . ?⟺)
                                                ("=>" . ?⇒)
                                                ("==>" . ?⟹)
                                                ("<=" . ?⇐)
                                                ("<==" . ?⟸)
                                                (" *** " . (?  (Br . Bl) ?⁂ (Br . Bl) ? ))
                                                ))

;; Setup hl-todo
(use-package hl-todo
  :demand
  :general
  (:states '(motion normal visual operator)
           "] t" #'hl-todo-next
           "[ t" #'hl-todo-previous
           )
  :config
  (global-hl-todo-mode 1)
  (setq hl-todo-keyword-faces
        '(("FIXME"   . "#fb4932")
          ("GOTCHA"  . "#fb4932")
          ("TODO" . "#fb4932")
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

;; Setup shackle for buffer/window placement
(use-package shackle
  :demand
  :init
  (setq shackle-rules '((("^\\*\\(?:[Cc]ompil\\(?:ation\\|e-Log\\)\\|Messages\\)" "^\\*info\\*$" "\\`\\*magit-diff: .*?\\'" grep-mode "*Flycheck errors*") :regexp t :align below :noselect t :size 0.3)
                        ("^\\*\\(?:Wo\\)?Man " :regexp t :align right :select t)
                        ("^\\*Calc" :regexp t :align below :select t :size 0.3)
                        ("^\\*Alchemist" :regexp t :align below :select t :size 0.3 :same nil)
                        ("^\\*lsp-help" :regexp t :select t :align bottom :size 0.2)
                        (("^\\*Warnings" "^\\*Warnings" "^\\*CPU-Profiler-Report " "^\\*Memory-Profiler-Report " "^\\*Process List\\*" "*Error*") :regexp t :align below :noselect t :size 0.2)
                        ("^\\*\\(?:Proced\\|timer-list\\|Abbrevs\\|Output\\|Occur\\|unsent mail\\)\\*" :regexp t :ignore t)
                        (("*shell*" "*eshell*") :popup t :select t)
                        ("*ag search*" :regexp t :popup t :select t :align below :size 0.3)
                        ("^ \\*undo-tree\\*" :regexp t :other t :align right :select t :size 0.2)
                        ("^\\*\\([Hh]elp\\|Apropos\\)" :regexp t :align right :select t)
                        ("\\`\\*magit.*?\\*\\'" :regexp t :align t :size 0.4 :inhibit-window-quit t)
                        ))
  (setq shackle-default-rule '(:select t :same t)) ;; reuse current window for new buffers by default
  (setq shackle-default-size 0.4)
  :config
  (shackle-mode)
  )

;; Setup dired
(use-package dired
  :straight (:type built-in)
  :ghook ('dired-mode-hook #'dired-hide-details-mode)
  :config
  (setq dired-dwim-target t)
  (setq find-file-visit-truename t)
  (setq dired-ls-F-marks-symlinks t)
  (setq dired-auto-revert-buffer t)
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)
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

;; =============================================================================
;; EVIL MODE
;; =============================================================================
;; Setup evil
(use-package evil
  :demand
  :general
  ;; Reimplementing some of the colemak evil rebindings from here https://github.com/wbolster/evil-colemak-basics
  ;; I do use the t-f-j rotation
  (:states '(motion normal visual)
	         "e" #'evil-previous-visual-line
	         "ge" #'evil-previous-visual-line
	         "E" #'evil-lookup
	         "f" #'evil-forward-word-end
	         "F" #'evil-forward-WORD-end
	         "gf" #'evil-backward-word-end
	         "gF" #'evil-backward-WORD-end
	         "gt" #'find-file-at-point
	         "gT" #'evil-find-file-at-point-with-line
	         "i" #'evil-forward-char
	         "gj" #'evil-backward-word-end
	         "gJ" #'evil-backward-WORD-end
	         "k" #'evil-search-next
	         "K" #'evil-search-previous
	         "gk" #'evil-next-match
	         "gK" #'evil-previous-match
	         "n" #'evil-next-visual-line
	         "gn" #'evil-next-visual-line
	         "gN" #'evil-next-visual-line
	         "zi" #'evil-scroll-column-right
	         "zI" #'evil-scroll-right)
  (:states '(normal visual)
	         "l" #'undo-tree-undo
	         "C-r" #'undo-tree-redo
	         "N" #'evil-join
	         "gN" #'evil-join-whitespace)
  (:states 'normal
	         "u" #'evil-insert
	         "U" #'evil-insert-line)
  (:states 'visual
	         "U" #'evil-insert)
  (:states '(motion operator)
	         "e" #'evil-previous-line
	         "n" #'evil-next-line)
  (:states '(visual operator)
	         "u" evil-inner-text-objects-map)
  (:states 'operator
	         "i" #'evil-forward-char)
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq evil-want-fine-undo t)
  ;; Start certain modes in normal mode
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  ;; Start certain modes in emacs mode
  (add-to-list 'evil-emacs-state-modes 'custom-mode)
  (add-to-list 'evil-emacs-state-modes 'eshell-mode))

;; Setup evil-collection -- evil keybindings for many modes
(defun taylor-gl/colemak-translation (_mode mode-keymaps &rest _rest)
  (evil-collection-translate-key 'normal mode-keymaps
    ;; colemak hnei is qwerty hjkl
    "n" "j"
    "e" "k"
    "i" "l"
    ;; add back nei
    ;; "j" "e"
    ;; "k" "n"
    ;; "l" "i"
    ;; other evil-colemak-basics stuff -- ignore for now
    ;; "k" "n"
    ;; "K" "N"
    ;; "u" "i"
    ;; "U" "I"
    ;; "l" "u"
    ;; "N" "J"
    ;; "E" "K"
    ;; "f" "e"
    ;; "F" "E"
    ;; "t" "f"
    ;; "T" "F"
    ;; "j" "t"
    ;; "J" "T"
    ))
(use-package evil-collection
  ;; check evil-collection-mode-list; remove magit and do manually
  :after evil general
  :ghook ('evil-collection-setup-hook #'taylor-gl/colemak-translation)
  :demand
  :general
  ;; TODO unbind RET, n, e from the evil mode maps when in Info-mode
  (:keymaps 'Info-mode-map
            "n" #'Info-next-reference
            "e" #'Info-prev-reference)
  :init
  :config
  (evil-collection-init)
  )

;; Setup evil-snipe
;; evil-surround uses the s/S keybinding in visual/operator modes,
;; so in operator mode, evil-snipe uses z/Z and x/X for sniping
(use-package evil-snipe
  :after evil
  :demand t
  :general
  (:states '(motion normal visual operator)
	         "j" #'evil-snipe-j
	         "J" #'evil-snipe-J
	         ;; "s" 'evil-snipe-s -- is set by evil-snipe-mode below
	         ;; "S" 'evil-snipe-S -- is set by evil-snipe-mode below
	         "t" #'evil-snipe-t
	         "T" #'evil-snipe-T
	         )
  :config
  (evil-snipe-mode t)
  ;; evil-snipe-def used because of https://github.com/hlissner/evil-snipe/issues/46
  (evil-snipe-def 1 inclusive "t" "T")
  (evil-snipe-def 1 exclusive "j" "J")
  ;; (evil-snipe-override-mode t)
  (setq evil-snipe-show-prompt nil)
  (setq evil-snipe-repeat-keys nil)
  )

;; Setup evil numbers (for increment/decrement at point)
(use-package evil-numbers
  :after evil
  :general
  (:keymaps 'evil-normal-state-map
            "g =" #'evil-numbers/inc-at-pt
            "g -" #'evil-numbers/dec-at-pt)
  )

;; Setup evil-surround
;; E.g. ys<textobject>) will surround with (parens).
;; Also, ds) will delete a pair of (parens).
(use-package evil-surround
  :after evil evil-snipe ;; after evil-snipe to override s/S keybinding
  :demand t
  :config
  (global-evil-surround-mode 1))

;; Setup avy (for jumping)
(use-package avy
  :after evil
  :general
  (:states 'normal
           "/" #'evil-avy-goto-char-2
           "M-*" #'avy-pop-mark)
  :demand t
  :config
  ;; avy-keys colemak (used for characters which pop up when jumping)
  ;; These correspond to: a r s t d h n e i o '
  (avy-setup-default)
  (setq avy-keys '(97 114 115 116 100 104 110 101 105 111 39))
  (setq avy-background t)
  (setq avy-all-windows nil)
  ;; make shorter sequences for words closer to point
  (setq avy-orders-alist
        '((avy-goto-char . avy-order-closest)
          (avy-goto-word-0 . avy-order-closest)))
  )

(defun +evil--window-swap (direction)
  "Move current window to the next window in DIRECTION.
If there are no windows there and there is only one window, split in that
direction and place this window there. If there are no windows and this isn't
the only window, use evil-window-move-* (e.g. `evil-window-move-far-left')."
  (when (window-dedicated-p)
    (user-error "Cannot swap a dedicated window"))
  (let* ((this-window (selected-window))
         (this-buffer (current-buffer))
         (that-window (windmove-find-other-window direction nil this-window))
         (that-buffer (window-buffer that-window)))
    (when (or (minibufferp that-buffer)
              (window-dedicated-p this-window))
      (setq that-buffer nil that-window nil))
    (if (not (or that-window (one-window-p t)))
        (funcall (pcase direction
                   ('left  #'evil-window-move-far-left)
                   ('right #'evil-window-move-far-right)
                   ('up    #'evil-window-move-very-top)
                   ('down  #'evil-window-move-very-bottom)))
      (unless that-window
        (setq that-window
              (split-window this-window nil
                            (pcase direction
                              ('up 'above)
                              ('down 'below)
                              (_ direction))))
        (with-selected-window that-window
          (switch-to-buffer (doom-fallback-buffer)))
        (setq that-buffer (window-buffer that-window)))
      (with-selected-window this-window
        (switch-to-buffer that-buffer))
      (with-selected-window that-window
        (switch-to-buffer this-buffer))
      (select-window that-window))))

(defun +evil/window-move-left ()
  "Swap windows to the left."
  (interactive) (+evil--window-swap 'left))
(defun +evil/window-move-right ()
  "Swap windows to the right"
  (interactive) (+evil--window-swap 'right))
(defun +evil/window-move-up ()
  "Swap windows upward."
  (interactive) (+evil--window-swap 'up))
(defun +evil/window-move-down ()
  "Swap windows downward."
  (interactive) (+evil--window-swap 'down))

;; =============================================================================
;; ORG
;; =============================================================================
;; Setup org
(use-package org
  :mode ("\\.org\\'" . org-mode)
  :general
  (:keymaps 'org-read-date-minibuffer-local-map
            "C-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-day 1)))
            "C-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-week 1)))
            "C-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-week 1)))
            "C-i" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-day 1)))
            "C-S-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-month 1)))
            "C-S-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-year 1)))
            "C-S-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-year 1)))
            "C-S-i" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-month 1)))
            )
  (:keymaps 'org-mode-map
            :states '(normal)
            "RET" #'+org/dwim-at-point
            "<return>" #'+org/dwim-at-point
            "M-h" #'org-metaleft
            "M-n" #'org-metadown
            "M-e" #'org-metaup
            "M-i" #'org-metaright
            "M-H" #'org-shiftmetaleft
            "M-N" #'org-shiftmetadown
            "M-E" #'org-shiftmetaup
            "M-I" #'org-shiftmetaright
            "M-f" #'org-forward-sentence
            "C-H" #'org-shiftcontrolleft
            "C-N" #'org-shiftcontroldown
            "C-E" #'org-shiftcontrolup
            "C-E" #'org-shiftcontrolright
            ;; TODO: put these in 'normal and 'visual mode maps
            ;; "g h" 'org-up-element
            ;; "g n" 'org-forward-element
            ;; "g e" 'org-backward-element
            ;; "g i" 'org-down-element
            )
  :init
  (taylor-gl/localleader-def-create! org-mode-map
      "'" #'org-edit-special
      "*" #'org-ctrl-c-star
      "-" #'org-ctrl-c-minus
      "-" #'org-ctrl-c-minus
      "." #'(org-goto :which-key "goto")
      "c" #'(org-insert-todo-heading :which-key "item insert checkbox/todo")
      "i" #'(org-toggle-item :which-key "toggle item")
      "t" #'(org-todo :which-key "set TODO state")
      "x" #'(:ignore t :which-key "table")
      "x -" #'(org-table-insert-hline :which-key "horizontal line")
      "x a" #'(org-table-align :which-key "align")
      "x c" #'(org-table-create-or-convert-from-region :which-key "create")
      "x h" #'(org-table-field-info :which-key "field info")
      "x s" #'(org-table-sort-lines :which-key "sort")
      "x r" #'(org-table-recalculate :which-key "recalculate")
      "x d" #'(:ignore t :which-key "delete")
      "x d c" #'(org-table-delete-column :which-key "column")
      "x d r" #'(org-table-kill-row :which-key "row")
      "x i" #'(:ignore t :which-key "insert")
      "x i c" #'(org-table-insert-column :which-key "column")
      "x i -" #'(org-table-insert-hline :which-key "horizontal line")
      "x i _" #'(org-table-hline-and-move :which-key "horizontal line and move")
      "x i r" #'(org-table-insert-row :which-key "row")
      "d" #'(:ignore t :which-key "deadline/schedule")
      "d d" #'(org-deadline :which-key "set deadline")
      "d s" #'(org-schedule :which-key "set schedule")
      "d t" #'(org-time-stamp :which-key "time stamp")
      "d T" #'(org-time-stamp-inactive :which-key "time stamp inactive")
      "g" #'(:ignore t :which-key "goto")
      "g g" #'(counsel-org-goto :which-key "goto heading")
      "g G" #'(counsel-org-goto-all :which-key "goto heading (all)")
      "g c" #'(org-clock-goto :which-key "goto clock")
      "g i" #'(org-id-goto :which-key "goto id")
      "g r" #'(org-refile-goto-last-stored :which-key "goto last refile")
      "g x" #'(org-capture-goto-last-stored :which-key "goto last capture")
      "l" #'(:ignore t :which-key "link")
      "l c" #'(org-cliplink :which-key "clip")
      "l i" #'(org-id-store-link :which-key "store using id")
      "l l" #'(org-insert-link :which-key "insert")
      "l L" #'(org-insert-all-links :which-key "insert all links")
      "l s" #'(org-store-link :which-key "store")
      "l S" #'(org-insert-last-stored-link :which-key "insert last stored link")
      )
  :config
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
  (variable-pitch-mode 1)
  (general-add-hook 'org-mode-hook #'taylor-gl/setup-prettify-symbols-mode)
  (auto-fill-mode 0)
  (setq org-ellipsis " ▼"
        org-directory "~/Dropbox/emacs/"
        org-agenda-files '("~/Dropbox/emacs/todo.org" "~/Dropbox/emacs/reference.org" "~/Dropbox/emacs/work.org")
        org-agenda-span 'month ;; show one month of agenda at a time
        org-modules '(ol-bibtex org-habit)
        org-link-shell-confirm-function nil ;; don't annoy me by asking for confirmation
        ;; don't show DONE items in agenda
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-use-time-grid nil
        org-agenda-search-headline-for-time nil
        org-latex-packages-alist '(("" "clrscode3e" t)
                                   ("" "mathtools" t)
                                   ("" "amssymb" t))
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
(use-package org-cliplink)
(use-package org-bullets
  :after org
  :ghook 'org-mode-hook
  :custom
  (org-bullets-bullet-list '("◇" "◆" "◉" "●" "○" "●" "○" "●" "○" "●" "○" "●")))

(use-package evil-org
  :after (evil org)
  :ghook ('(org-mode-hook org-agenda-mode-hook))
  :general
  (:states '(visual operator)
	         :keymap 'evil-inner-text-objects-map
	         :prefix "u"
	         "e" #'evil-org-inner-object
	         "E" #'evil-org-inner-element
	         "r" #'evil-org-inner-greater-element
	         "R" #'evil-org-inner-subtree)
  (:states '(visual operator)
	         :keymap 'evil-inner-text-objects-map
	         :prefix "a"
	         "e" #'evil-org-an-object
	         "E" #'evil-org-an-element
	         "r" #'evil-org-a-greater-element
	         "R" #'evil-org-a-subtree)
  ;; These are modified from 'evil-org-agenda-set-keys in evil-org-agenda, which I couldn't make
  ;; work on its own. Also modified for colemak.
  (:states 'motion
	         :keymaps 'org-agenda-mode-map
	         ;; open
	         "<tab>" #'org-agenda-goto
	         "S-<return>" #'org-agenda-goto
	         "g TAB" #'org-agenda-goto
	         "RET" #'org-agenda-switch-to

	         ;; close
	         "q" #'org-agenda-quit

	         ;; motion
	         "n" #'org-agenda-next-line
	         "e" #'org-agenda-previous-line
	         "gn" #'org-agenda-next-item
	         "ge" #'org-agenda-previous-item
	         "gN" #'org-agenda-next-item
	         "gE" #'org-agenda-previous-item
	         "gH" #'evil-window-top
	         "gM" #'evil-window-middle
	         "gL" #'evil-window-bottom
	         "C-n" #'org-agenda-next-item
	         "C-e" #'org-agenda-previous-item
	         "[[" #'org-agenda-earlier
	         "]]" #'org-agenda-later

	         ;; manipulation
	         "N" #'org-agenda-priority-down
	         "E" #'org-agenda-priority-up
	         "H" #'org-agenda-do-date-earlier
	         "I" #'org-agenda-do-date-later
	         "t" #'org-agenda-todo
	         "M-n" #'org-agenda-drag-line-forward
	         "M-e" #'org-agenda-drag-line-backward
	         "C-S-h" #'org-agenda-todo-previousset ; Original binding "C-S-<left>"
	         "C-S-i" #'org-agenda-todo-nextset ; Original binding "C-S-<right>"

	         ;; undo
	         "l" #'org-agenda-undo

	         ;; actions
	         "dd" #'org-agenda-kill
	         "dA" #'org-agenda-archive
	         "da" #'org-agenda-archive-default-with-confirmation
	         "ct" #'org-agenda-set-tags
	         "ce" #'org-agenda-set-effort
	         "cT" #'org-timer-set-timer
	         "i" #'org-agenda-diary-entry
	         "a" #'org-agenda-add-note
	         "A" #'org-agenda-append-agenda
	         "C" #'org-agenda-capture

	         ;; mark
	         "m" #'org-agenda-bulk-toggle
	         "~" #'org-agenda-bulk-toggle-all
	         "*" #'org-agenda-bulk-mark-all
	         "%" #'org-agenda-bulk-mark-regexp
	         "M" #'org-agenda-bulk-unmark-all
	         "x" #'org-agenda-bulk-action

	         ;; refresh
	         "gr" #'org-agenda-redo
	         "gR" #'org-agenda-redo-all

	         ;; quit
	         "ZQ" #'org-agenda-exit
	         "ZZ" #'org-agenda-quit

	         ;; display
	         "gD" #'org-agenda-view-mode-dispatch
	         "ZD" #'org-agenda-dim-blocked-tasks

	         ;; filter
	         "sc" #'org-agenda-filter-by-category
	         "sr" #'org-agenda-filter-by-regexp
	         "se" #'org-agenda-filter-by-effort
	         "st" #'org-agenda-filter-by-tag
	         "s^" #'org-agenda-filter-by-top-headline
	         "ss" #'org-agenda-limit-interactively
	         "S" #'org-agenda-filter-remove-all

	         ;; clock
	         "I" #'org-agenda-clock-in ; Original binding
	         "O" #'org-agenda-clock-out ; Original binding
	         "cg" #'org-agenda-clock-goto
	         "cc" #'org-agenda-clock-cancel
	         "cr" #'org-agenda-clockreport-mode

	         ;; go and show
	         "." #'org-agenda-goto-today
	         "gc" #'org-agenda-goto-calendar
	         "gC" #'org-agenda-convert-date
	         "gd" #'org-agenda-goto-date
	         "gh" #'org-agenda-holidays
	         "gm" #'org-agenda-phases-of-moon
	         "gs" #'org-agenda-sunrise-sunset
	         "gt" #'org-agenda-show-tags

	         "p" #'org-agenda-date-prompt
	         "P" #'org-agenda-show-the-flagging-note

	         ;; Others
	         "+" #'org-agenda-manipulate-query-add
	         "-" #'org-agenda-manipulate-query-subtract)
  :init
  (setq evil-org-retain-visual-state-on-shift t)
  (setq evil-org-special-o/O '(table-row))
  (setq evil-org-use-additional-insert t)
  :config
  (evil-org-set-key-theme '(navigation insert additional calendar))
  (setq evil-org-movement-bindings
	      '((up . "e") (down . "n")
	        (left . "h") (right . "i")))
  )

;; TODO: fix this put in use-package:
;;(with-eval-after-load 'org-faces
;;(dolist (face '((org-level-1)
;;              (org-level-2)
;;              (org-level-3)
;;              (org-level-4)
;;              (org-level-5)
;;              (org-level-6)
;;              (org-level-7)
;;              (org-level-8)))
;;(set-face-attribute (car face) nil :font "Noto Sans" :weight 'regular :height 1.1)
;;)
;; making certain things fixed-pitch
;;(require 'org-indent)
;;(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
;;(set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
;;(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
;;(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
;;(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
;;(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
;;(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
;;(set-face-attribute 'org-table nil :inherit '(shadow fixed-pitch)))

;; Setup org-roam for zettelkasten
(use-package org-roam
  :after org
  :ghook 'after-init-hook
  :custom
  (org-roam-directory "~/Dropbox/emacs/roam"))
;; org-ref and helm-bibtex for use with org-roam
(use-package org-ref
  :config
  (setq reftex-default-bibliography '("~/Dropbox/emacs/roam/bibliography/references.bib"))
  (setq org-ref-bibliography-notes "~/Dropbox/emacs/roam/bibliography/notes.org"
        org-ref-default-bibliography '("~/Dropbox/emacs/roam/bibliography/references.bib")
        org-ref-pdf-directory "~/Dropbox/emacs/roam/bibliography/bibtex-pdfs/")
  (setq bibtex-completion-pdf-open-function #'org-open-file))
(use-package helm-bibtex
  :config
  (setq bibtex-completion-bibliography
        '("~/Dropbox/emacs/roam/bibliography/references.bib"))
  (setq bibtex-completion-library-path '("~/Dropbox/emacs/roam/bibliography/bibtex-pdfs/"))
  (setq bibtex-completion-pdf-open-function
        (lambda (fpath)
          (call-process "evince" nil 0 nil fpath))))


;; =============================================================================
;; CODE
;; =============================================================================
;; various coding-related modes
(defconst code-mode-hooks
  '(prog-mode-hook python-mode-hook elisp-mode-hook elixir-mode-hook emacs-lisp-mode-hook typescript-mode js-mode web-mode)
  )

(defun taylor-gl/setup-indent (n)
  ;; general
  (setq tab-width n)
  ;; java/c/c++
  (setq c-basic-offset n)
  ;; web development
  (setq js-indent-level n) ; js-mode
  (setq web-mode-markup-indent-offset n) ; web-mode, html tag in html file
  (setq web-mode-css-indent-offset n) ; web-mode, css in html file
  (setq web-mode-code-indent-offset n) ; web-mode, js code in html file
  (setq web-mode-block-padding n)
  (setq css-indent-offset n)
  (setq typescript-indent-level n)
  )

(defun taylor-gl/setup-prettify-symbols-mode ()
  (setq prettify-symbols-alist taylor-gl/custom-prettify-symbols-alist)
  (setq prettify-symbols-unprettify-at-point 'right-edge) ;; don't form ligatures under the cursor
  (prettify-symbols-mode 1)
  )

(defun taylor-gl/setup-code-mode ()
  (setq indent-tabs-mode nil)
  (taylor-gl/setup-indent 2)
  (taylor-gl/setup-prettify-symbols-mode)
  (setq display-fill-column-indicator-column 100)
  )

;; Setup smartparens
;; (use-package smartparens
  ;; :demand
  ;; TODO disable auto paren insertion
  ;; :config
  ;; (require 'smartparens-config)
  ;; (sp-pair "\\\\(" "\\\\)" :actions '(wrap))
  ;; (sp-pair "\\{" "\\}" :actions '(wrap))
  ;; (sp-pair "\\(" "\\)" :actions '(wrap))
  ;; (sp-pair "\\\"" "\\\"" :actions '(wrap))
  ;; (sp-pair "/*" "*/" :actions '(wrap))
  ;; (sp-pair "\"" "\"" :actions '(wrap))
  ;; (sp-pair "'" "'" :actions '(wrap))
  ;; (sp-pair "(" ")" :actions '(wrap))
  ;; (sp-pair "[" "]" :actions '(wrap))
  ;; (sp-pair "{" "}" :actions '(wrap))
  ;; (sp-pair "`" "`" :actions '(wrap))
  ;; )

;; setup ligatures and code mode settings
(mapc
 (lambda (code-mode-hook)
   (general-add-hook code-mode-hook #'taylor-gl/setup-code-mode)
   ;; (general-add-hook code-mode-hook #'smartparens-mode)
   (general-add-hook code-mode-hook #'display-fill-column-indicator-mode)
   (general-add-hook code-mode-hook #'format-all-ensure-formatter)
   )
 code-mode-hooks)

;; setup projectile
(use-package projectile
  :demand t
  :general
  (:keymaps 'projectile-command-map
            "ESC" nil)
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

;; Setup ag (for use with projectile-ag)
(use-package ag
  :after projectile)

;; Setup smart-hungry-delete
;; Deletes multiple whitespace characters at once
(use-package smart-hungry-delete
  :demand t
  :general
  (:states 'insert
           "<backspace>" #'smart-hungry-delete-backward-char
           "C-d" #'smart-hungry-delete-forward-char)
  :config
	(smart-hungry-delete-add-default-hooks))

;; Setup company-mode (tab completion; integrates with lsp-mode)
(use-package company
  :demand
  :general
  (:keymaps 'company-active-map
            "RET" 'nil
            "<return>" 'nil
            "<tab>" #'company-complete-selection
            "TAB" #'company-complete-selection)
  :custom
  (comany-begin-commands '(self-insert-command))
  (company-idle-delay 0.0) ;; some people use 0.1 as "instant", but that is visibly non-instant
  (company-minimum-prefix-length 1)
  (company-require-match 'never)
  (company-tooltip-align-annotations t)
  (global-company-mode t))

;; Setup company-posframe (helps company look good even when in a buffer with variable pitch fonts e.g. org)
(use-package company-posframe
  :ghook 'company-mode-hook
  :config
  (company-posframe-mode 1))

;; Setup company-ctags for project-specific autocompletion
;; TODO crashes emacs
;;(use-package company-ctags
;;  :ghook 'company-mode-hook)

;; Setup flycheck (linting)
(use-package flycheck
  :demand
  :ghook (code-mode-hooks #'flycheck-mode)
  :init
  (flycheck-mode)
  :config
  (setq flycheck-idle-change-delay 0.05)
  )

;; Setup flycheck-pos-tip for flycheck info on hover
(use-package flycheck-pos-tip
  :after flycheck
  :ghook 'flycheck-mode-hook
  :config
  (flycheck-pos-tip-mode))

(use-package format-all
  :init
  :demand
  :ghook ('format-all-mode-hook #'format-all-ensure-formatter)
  )

;; Setup tide-mode for typescript
(use-package typescript-mode)

(defun setup-tide-mode ()
  (tide-setup)
  (flycheck-mode t)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
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
  :config
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
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
  :init
  (setq web-mode-enable-html-entities-fontification t)
  (setq web-mode-auto-close-style 1)
  (setq web-mode-enable-auto-quoting nil)
  (setq web-mode-enable-auto-pairing nil)
  (setq web-mode-enable-current-column-highlight t)
  (taylor-gl/localleader-def-create! web-mode-map
      "m" #'(web-mode-tag-match :which-key "jump to matching tag")
      "f" #'(web-mode-fold-or-unfold :which-key "fold/unfold tag")
      )
  :config
  (add-to-list 'web-mode-engines-alist '("elixir" . "\\.eex\\'"))
  (sp-with-modes '(web-mode)
    (sp-local-pair "<" nil :actions :rem)
    (sp-local-pair "% " " %"
                   :unless '(sp-in-string-p)
                   :post-handlers '(((lambda (&rest _ignored)
                                       (just-one-space)
                                       (save-excursion (insert " ")))
                                     "SPC" "=" "#")))
    (sp-local-pair "<% " " %>")
    (sp-local-pair "<%= " " %>")
    (sp-local-pair "<%# " " %>")
    (sp-local-pair "<-" ""))
  )

;; Setup elixir/phoenix
(use-package elixir-mode)
(use-package alchemist
  ;; NOTE currently using a local version of alchemist which I patched using a github pull request
  ;; for a bug which has not been merged into the main package. When the merge occurs, I will
  ;; go back to the elpa package. (The patch allows alchemist to use new Phoenix 3 dir structure.)
  ;; https://github.com/tonini/alchemist.el/pull/352
  ;; NOTE you can get a patch from a gitub pull request by appending ".patch" to the URL!
  ;; NOTE in order for the Phoenix commands to work, the Phoenix project must be in a folder matching
  ;; the name of the project.
  :ghook ('elixir-mode-hook #'alchemist-mode)
  :init
  (taylor-gl/localleader-def-create! alchemist-mode-map
      "i" #'(:ignore t :which-key "iex")
      "i c" #'(alchemist-compile-this-buffer :which-key "compile buffer")
      "i i" #'(alchemist-iex-compile-this-buffer-and-go :which-key "compile buffer and open iex")
      "i p" #'(alchemist-iex-project-run :which-key "compile project and open iex")
      "i r" #'(alchemist-iex-run :which-key "run iex")
      "i s" #'(alchemist-iex-send-current-line-and-go :which-key "send line to iex")
      "i R" #'(alchemist-iex-send-region-and-go :which-key "send region to iex")
      "f" #'(:ignore t :which-key "find")
      "f c" #'(alchemist-phoenix-find-controllers :which-key "controller (phoenix)")
      "f C" #'(alchemist-phoenix-find-channels :which-key "channel (phoenix)")
      "f l" #'(alchemist-project-find-lib :which-key "in lib dir")
      "f m" #'(alchemist-phoenix-find-models :which-key "model (phoenix)")
      "f r" #'(alchemist-phoenix-router :which-key "router file (phoenix)")
      "f s" #'(alchemist-phoenix-find-static :which-key "in static dir (phoenix)")
      "f t" #'(alchemist-project-find-test :which-key "test")
      "f T" #'(alchemist-phoenix-find-templates :which-key "template (phoenix)")
      "f v" #'(alchemist-phoenix-find-views :which-key "view (phoenix)")
      "f w" #'(alchemist-phoenix-find-web :which-key "web (phoenix)")
      "h" #'(:ignore t :which-key "help")
      "h b" #'(alchemist-goto-jump-back :which-key "goto jump back")
      "h d" #'(alchemist-goto-definition-at-point :which-key "goto definition at point")
      "h s" #'(alchemist-goto-list-symbol-definitions :which-key "goto symbol")
      "m" #'(:ignore t :which-key "mix")
      "m c" #'(alchemist-mix-compile :which-key "compile project")
      "m l" #'(alchemist-mix-rerun-last-task :which-key "rerun last task")
      "m m" #'(alchemist-mix :which-key "mix prompt")
      "m r" #'(alchemist-mix-run :which-key "run file/expression")
      "m R" #'(alchemist-phoenix-routes :which-key "mix phoenix.routes")
      "t" #'(:ignore t :which-key "test (mix)")
      "t b" #'(alchemist-mix-test-this-buffer :which-key "test buffer")
      "t p" #'(alchemist-mix-test-at-point :which-key "test at point")
      "t r" #'(alchemist-mix-rerun-last-test :which-key "rerun last test")
      "t v" #'(alchemist-mix-test :which-key "run tests")
      "t p" #'(alchemist-project-run-tests-for-current-file :which-key "run tests for this file")
      "t t" #'(alchemist-project-toggle-file-and-tests :which-key "toggle file and test")
      "t T" #'(alchemist-project-toggle-file-and-tests-other-window :which-key "toggle file and test (other window)")
      "x" #'(:ignore t :which-key "macroexpand")
      "x l" #'(alchemist-macroexpand-once-current-line :which-key "current line once")
      "x L" #'(alchemist-macroexpand-current-line :which-key "current line")
      "x r" #'(alchemist-macroexpand-once-region :which-key "region once")
      "x R" #'(alchemist-macroexpand-region :which-key "region")
      ))

(use-package exunit
  :ghook 'elixir-mode-hook
  :init
  (taylor-gl/localleader-def-create! elixir-mode-map
      "T" #'(:ignore t :which-key "test (exunit)")
      "T a" #'(exunit-verify-all :which-key "all files")
      "T r" #'(exunit-rerun :which-key "rerun last command")
      "T v" #'(exunit-verify :which-key "this file")
      "T s" #'(exunit-verify-single :which-key "single item on cursor")
      "T t" #'(exunit-toggle-file-and-test :which-key "toggle file and test")
      "T T" #'(exunit-toggle-file-and-test-other-window "toggle file and test (other window)")
      ))

;; Setup SQL
;; INPROGRESS: this was done in a hurry
;; TODO interactive mode
(use-package sql
  :mode (("\\.sql" . sql-mode)
	       ("\\.ddl" . sql-mode))
  )

(use-package sql-indent
  :after sql
  :ghook ('sqlind-minor-mode-hook 'sql-mode)
  )

;; Setup emacs-lisp
(use-package highlight-quoted
  :demand
  :ghook 'emacs-lisp-mode-hook)

;; Setup bash
;; INPROGRESS
(use-package sh-script
  :straight (:type built-in))

;; Setup Yaml
(use-package yaml-mode
  :mode "\\.yml\\'")

;; Setup LaTeX
;; INPROGRESS: this was done in a hurry
;; (use-package tex
;;   :mode ("\\.tex\\'" . LaTeX-mode)
;;   :init
;;   (setq TeX-parse-self t)
;;   (setq TeX-auto-save t)
;;   )
;; (use-package latex
;;   :config
;;   (setq ispell-parser 'tex))

;; (use-package auctex
;;   :after latex)
;; (use-package auctex-latexmk
;;   :after auctex
;;   :init
;;   (setq auctex-latexmk-inherit-TeX-PDF-mode t)
;;   :config
;;   (setq TeX-command-default "LatexMk")
;;   (auctex-latexmk-setup))
;; (use-package evil-tex
;;   :ghook 'LaTeX-mode-hook)
;; (use-package company-auctex
;;   ;; :ghook ???
;;   :config
;;   (company-auctex-init))
;; ;; (use-package company-reftex)
;; (use-package company-math
;;   :after latex
;;   :config
;;   (add-to-list 'company-backends 'company-math-symbols-unicode))

;; =============================================================================
;; MISC.
;; =============================================================================
;; Setup YASnippet
(use-package yasnippet
  :config
  (yas-global-mode 1))
(use-package yasnippet-snippets
  :after yasnippet)

;; Setup git
(use-package magit
  :init
  (setq magit-bury-buffer-function #'magit-restore-window-configuration)
  )
(use-package magit-todos
  :after magit hl-todo
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

;; =============================================================================
;; CUSTOM FUNCTIONS (from doom emacs if they start with +)
;; =============================================================================

;; =============================================================================
;; CUSTOM (don't edit by hand)
;; =============================================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(evil-org-agenda yasnippet-snippets which-key use-package smex rainbow-delimiters org-roam org-ref org-plus-contrib org-bullets magit ivy-rich helpful general evil-org evil-numbers evil-collection evil-colemak-basics doom-themes doom-modeline crux counsel avy all-the-icons-dired))
 '(warning-suppress-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-goggles-change-face ((t (:inherit diff-removed))))
 '(evil-goggles-delete-face ((t (:inherit diff-removed))))
 '(evil-goggles-paste-face ((t (:inherit diff-added))))
 '(evil-goggles-undo-redo-add-face ((t (:inherit diff-added))))
 '(evil-goggles-undo-redo-change-face ((t (:inherit diff-changed))))
 '(evil-goggles-undo-redo-remove-face ((t (:inherit diff-removed))))
 '(evil-goggles-yank-face ((t (:inherit diff-changed))))
 '(outline-1 ((t (:foreground "#fadb2f"))))
 '(outline-2 ((t (:foreground "#8ec07c"))))
 '(outline-3 ((t (:foreground "#a2bbb1"))))
 '(outline-4 ((t (:foreground "#8ec07c"))))
 '(outline-5 ((t (:foreground "#a2bbb1"))))
 '(outline-6 ((t (:foreground "#8ec07c"))))
 '(outline-7 ((t (:foreground "#a2bbb1"))))
 '(outline-8 ((t (:foreground "#8ec07c")))))
