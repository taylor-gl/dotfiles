;;; init.el --- Taylor G. Lunt's Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Colemak: the navigation cluster is h (backward) n (down) e (up) i (forward)
;; p (end) -- globally in KEYBINDINGS, per-mode via `taylor-gl/colemak-motion'.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   BASICS & INTERFACE                                                                |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
(setq user-full-name "Taylor G. Lunt"
      user-mail-address "taylor@taylor.gl")

;; Clean up the interface (bars and frame geometry live in early-init.el, so
;; they never flash on screen)
(setq visible-bell t
      frame-resize-pixelwise t) ;; For tiling window manager
(tooltip-mode -1)
(set-fringe-mode 10)
(global-visual-line-mode t)
(setq-default cursor-type 'bar)

;; When quitting the only window in a frame, delete that frame, rather than minimizing it
(setq frame-auto-hide-function #'delete-frame)
(setq-default x-stretch-cursor t) ;; Stretch the cursor to the width of a glyph (even e.g. a tab glyph)
(show-paren-mode) ;; Highlight matching parens

(setq warning-minimum-level :warning)

;; Choose fonts
;; One family across the whole desktop: Iosevka mono for code, Aile (its
;; proportional cut) for UI, Etoile (its serif cut) for prose. Same skeleton
;; everywhere, so nothing on screen is foreign to anything else.
(set-face-attribute 'default nil :family "Iosevka Nerd Font Mono" :height 120)
(set-face-attribute 'fixed-pitch nil :family "Iosevka Nerd Font Mono" :height 120)
(set-face-attribute 'variable-pitch nil :family "Iosevka Etoile" :height 125)

;; Performance (or the illusion thereof)
(setq bidi-inhibit-bpa t
      bidi-paragraph-direction 'left-to-right
      echo-keystrokes 0.01
      jit-lock-defer-time 0
      fast-but-imprecise-scrolling t)

;; early-init.el disables GC for the whole of startup; this puts it back
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 100000000
                  gc-cons-percentage 0.1)))

;; Better default behaviors
(global-subword-mode 1) ;; Movement commands use subwords rather than words for symbols like ThisAndThat
(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-nonexistent-file-or-buffer nil)
(setq-default indent-tabs-mode nil) ;; Make tab insert spaces
(setq kill-buffer-query-functions nil ;; Don't ask me for confirmation when closing buffers with running processes etc.
      sentence-end-double-space nil
      save-interprogram-paste-before-kill t ;; Save clipboard text to kill ring before replacing it, so clipboard text is not lost
      mouse-wheel-scroll-amount '(4 ((control) . 8)) ;; Scroll four lines at a time unless control held
      mouse-wheel-progressive-speed nil ;; No scroll acceleration, because who would want that?
      initial-major-mode #'fundamental-mode ;; Scratch buffer mode
      initial-scratch-message nil ;; Scratch buffer starts empty
      delete-by-moving-to-trash t ;; Delete files to the trash
      next-screen-context-lines 25
      scroll-preserve-screen-position t)

;; When `custom-file' is nil, Customize writes into init.el instead.  Point it
;; at a throwaway nothing ever loads back.
(setq custom-file (expand-file-name "emacs-custom-discarded.el" temporary-file-directory))

;; Auto-saving
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 5  ;; save after 5 seconds of idle time
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save-list/" user-emacs-directory) t))
      create-lockfiles nil)


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   PACKAGE MANAGEMENT                                                                |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
;; straight.el bootstrap boilerplate.
(setq straight-use-package-by-default t)
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

;; Built in since Emacs 29.  straight's bootstrap has already enabled
;; `straight-use-package-mode', so `:straight' works against it.
(require 'use-package)
(setq use-package-always-defer t)

;; Setup general for keybindings
(use-package general
  :demand)


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   KEYBINDINGS                                                                       |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
;; I don't want TAB on C-i, nor RET on C-m. (Who would?)
;; It won't work to unmap them normally, because emacs sees RET == C-m etc.
;; Instead, I bind raw C-i input to new event <C-i>. Same with C-m
(defun taylor-gl/remap-C-i-and-C-m ()
  "Remove TAB from C-i and RET from C-m in TERMINAL."
  (define-key input-decode-map (kbd "C-i") (kbd "<C-i>"))
  (define-key input-decode-map (kbd "C-m") (kbd "<C-m>"))
  (define-key input-decode-map (kbd "M-i") (kbd "<M-i>"))
  (define-key input-decode-map (kbd "M-m") (kbd "<M-m>"))
  (define-key input-decode-map (kbd "C-M-i") (kbd "<C-M-i>"))
  (define-key input-decode-map (kbd "C-M-m") (kbd "<C-M-m>"))
  (define-key input-decode-map (kbd "H-C-i") (kbd "<H-C-i>"))
  (define-key input-decode-map (kbd "H-C-m") (kbd "<H-C-m>"))
  (define-key input-decode-map (kbd "H-C-M-i") (kbd "<H-C-M-i>"))
  (define-key input-decode-map (kbd "H-C-M-m") (kbd "<H-C-M-m>")))

;; Each daemon frame gets a fresh `input-decode-map', hence the hook; without the
;; daemon that hook never fires at all, hence the direct call.
(add-hook 'server-after-make-frame-hook #'taylor-gl/remap-C-i-and-C-m)
(taylor-gl/remap-C-i-and-C-m)

;; I want my basic movement keys on hnei (I use colemak), therefore:
;; Swap C-b and C-h etc.
;; (mnemonic: C-b opens the handBook)
;; (mnemonic: M-b marks paragrapH)
(general-define-key
 "C-h" 'backward-char
 "C-b" help-map
 "C-b C-b" 'help-for-help
 "M-h" 'backward-word
 "M-b" 'mark-paragraph)

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
 "C-M-e" 'backward-list)

;; Move C-f to C-i, and just leave C-f unbound
(general-define-key
 (kbd "<C-i>") 'forward-char
 (kbd "<tab>") 'indent-for-tab-command
 (kbd "<M-i>") 'forward-word
 "C-f" nil
 "M-f" nil
 "C-M-f" nil)

(general-define-key "C-/" nil)

;; Don't require pressing escape three (3!) times to exit
(general-define-key "<escape>" 'keyboard-escape-quit)

;; Don't use escape as a prefix key
(general-define-key
 "C-c <escape>" 'ignore
 "C-x <escape>" 'ignore
 "C-b <escape>" 'ignore)

;; Other global keybindings
(general-define-key
 "M-n" 'scroll-up
 "H-M-n" 'next-history-element
 "H-M-e" 'previous-history-element
 "M-e" 'scroll-down
 "<M-m>" 'back-to-indentation
 ;; Moving saving to C-s to be consistent with other applications a la cua-mode
 "C-s" 'taylor-gl/save-buffer
 [remap save-buffer] 'taylor-gl/save-buffer ;; so C-x C-s behaves the same
 "C-y" nil ;; moved to C-v with cua-mode
 "C-w" nil ;; moved to C-v with cua-mode
 "C-S-s" 'write-file ;; "Save as..."
 "H-." 'kmacro-end-and-call-macro
 "H-," 'set-mark-command
 "C-c <return>" 'vterm
 "C-c p <return>" 'projectile-run-vterm
 "H-a" 'previous-buffer
 "H-p" 'next-buffer
 "H-o" 'other-window
 "H-q" 'kill-current-buffer
 "H-m" 'exchange-point-and-mark
 "C-M-d" 'backward-kill-word
 "C-b <C-m>" 'describe-keymap ;; built in since Emacs 28
 "H-k" 'crux-kill-whole-line ;; C-S-backspace was awkward on my keyboard
 "C-k" 'crux-smart-kill-line
 "C-o" 'crux-smart-open-line
 "C-S-o" 'crux-smart-open-line-above
 "C-t" 'pop-global-mark ;; C-t was transpose-chars, but I only ever activated it by accident. Now it's C-t for "teleport"
 "C-c f u i f" 'taylor-gl/find-user-init-file)


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   COLEMAK MOTION LAYER                                                              |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
(cl-defun taylor-gl/colemak-motion
    (keymaps &key package back forward prev next end unbind also-control)
  "Apply my Colemak motion layer to KEYMAPS.

BACK, FORWARD, PREV, NEXT and END name the command bound to h, i, e, n and p
respectively.  Any role left out is not bound at all.

UNBIND is a list of keys to clear -- the QWERTY keys this layer displaces.
ALSO-CONTROL mirrors every binding onto its C- prefixed twin.
PACKAGE defers everything until that feature loads, so this can be called for
keymaps that do not exist yet."
  (let* ((roles `(("h" . ,back) ("i" . ,forward) ("e" . ,prev)
                  ("n" . ,next) ("p" . ,end)))
         (bindings
          (cl-loop for (key . cmd) in roles
                   when cmd
                   append (if also-control
                              (list key cmd (concat "C-" key) cmd)
                            (list key cmd))))
         (clears (cl-loop for key in unbind append (list key nil))))
    (apply #'general-define-key
           :keymaps keymaps
           (append (when package (list :package package))
                   bindings
                   clears))))

;; Every per-mode motion override lives here; non-motion bindings stay in their
;; own package's `:general' block.
(taylor-gl/colemak-motion 'dired-mode-map :package 'dired
                          :prev #'dired-previous-line
                          :unbind '("h" "p"))

(taylor-gl/colemak-motion 'Info-mode-map :package 'info
                          :back #'beginning-of-buffer
                          :prev #'Info-prev
                          :end #'end-of-buffer)

(taylor-gl/colemak-motion 'magit-mode-map :package 'magit
                          :prev #'magit-section-backward)

(taylor-gl/colemak-motion 'git-rebase-mode-map :package 'git-rebase
                          :prev #'git-rebase-backward-line
                          :unbind '("h" "p"))

(taylor-gl/colemak-motion 'ivy-occur-mode-map :package 'ivy
                          :prev #'ivy-occur-previous-line
                          :next #'ivy-occur-next-line
                          :unbind '("j" "k"))

(taylor-gl/colemak-motion 'ivy-occur-grep-mode-map :package 'ivy
                          :forward #'forward-char
                          :prev #'ivy-occur-previous-line
                          :next #'ivy-occur-next-line
                          :unbind '("j" "k" "l"))

(taylor-gl/colemak-motion 'vundo-mode-map :package 'vundo
                          :back #'vundo-backward
                          :forward #'vundo-forward
                          :prev #'vundo-previous
                          :next #'vundo-next
                          :unbind '("b" "f"))

(taylor-gl/colemak-motion 'which-key-C-h-map :package 'which-key
                          :prev #'which-key-show-previous-page-cycle
                          :also-control t
                          :unbind '("p"))


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   WINDOW MANAGEMENT                                                                 |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
;; I used to use the Shackle package, but it sucked, and the vanilla way is better
;; Inspired by https://www.masteringemacs.org/article/demystifying-emacs-window-manager
(setq
 ;; Maximum number of side-windows to create on (left top right bottom)
 window-sides-slots '(0 0 1 1)
 ;; Apply display-buffer-alist rules to manual buffer switching. Also prevents misbehaved packages from
 ;; getting around display-buffer-alist rules by calling switch-to-buffer instead of display-buffer.
 switch-to-buffer-obey-display-actions t
 ;; Automatically select help buffers when they open
 help-window-select t)

;; Stop escape from closing other windows
(define-advice keyboard-escape-quit
    (:around (fn &rest args) taylor-gl/dont-close-windows)
  "Run FN with ARGS, but neutered so it can't delete my other windows."
  (let ((buffer-quit-function #'ignore))
    (apply fn args)))

(defun taylor-gl/major-mode-matcher (modes)
  "Return a `display-buffer' condition matching buffers derived from MODES."
  (lambda (buffer-name _action)
    (with-current-buffer buffer-name
      (apply #'derived-mode-p modes))))

(defun taylor-gl/command-matcher (commands)
  "Return a `display-buffer' condition matching when `this-command' is in COMMANDS."
  (lambda (&rest _)
    (memq this-command commands)))

(setq display-buffer-alist
      `(;; Display terminals in a right side-window
        (,(taylor-gl/major-mode-matcher
           '(term-mode vterm-mode shell-mode eshell-mode))
         (display-buffer-in-side-window)
         (side . right)
         (slot . 1)
         (window-parameters . ((no-delete-other-windows . t)))
         (window-width . 0.3))
        ;; Display ephemeral help/info/etc. buffers in a bottom side-window
        (,(taylor-gl/major-mode-matcher
           '(rg-mode apropos-mode compilation-mode debugger-mode grep-mode
                     help-mode Info-mode Man-mode messages-buffer-mode
                     reb-mode woman-mode))
         (display-buffer-in-side-window)
         (side . bottom)
         (slot . 0))
        (,(rx "*Register Preview*")
         (display-buffer-in-side-window)
         (side . bottom)
         (slot . 0))
        ;; Buffers being opened by links in e.g. ag-mode
        (,(taylor-gl/command-matcher '(compile-goto-error))
         (display-buffer-reuse-window
          display-buffer-use-some-window))
        ;; vundo asks for this itself, but an ACTION passed to `display-buffer' is
        ;; outranked by this alist, so the ".*" fallback swallows it.  Anything
        ;; else that passes its own action needs an entry here too.
        (,(rx bos " *vundo tree*" eos)
         (display-buffer-in-side-window)
         (side . bottom)
         (slot . 0)
         (window-height . 3))
        ;; Default settings for all other buffers
        (".*"
         (display-buffer-same-window))))


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   PACKAGES                                                                          |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
;; Provides `rg', which `projectile-ripgrep' (C-c p s r) calls into
(use-package rg
  :after projectile)

(use-package apheleia
  :demand
  :general
  ("C-c =" #'apheleia-format-buffer
   "C-c +" #'indent-region)
  :config
  ;; Mostly apheleia's own defaults, restated so a version bump can't silently
  ;; stop formatting my TypeScript.
  (dolist (entry '((typescript-ts-mode . prettier-typescript)
                   (tsx-ts-mode        . prettier-typescript)
                   (js-ts-mode         . prettier-javascript)
                   (json-ts-mode       . prettier-json)
                   (css-ts-mode        . prettier-css)
                   (web-mode           . prettier)
                   ;; No markdown entry on purpose: prose is not code
                   (elixir-ts-mode     . mix-format)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry)))
  (apheleia-global-mode +1))

;; Format on the saves I ask for, never on the ones `auto-save-visited-mode'
;; makes every five seconds.  Gating `after-save-hook' is not enough: after a
;; timer save the buffer is unmodified, so `save-buffer' is a no-op and the hook
;; never runs -- which is why the save command drives formatting itself.
(defvar taylor-gl/apheleia-explicit-save nil
  "Non-nil while a save I actually asked for is running.")

(define-advice apheleia-format-after-save
    (:around (fn &rest args) taylor-gl/only-on-explicit-save)
  "Run FN with ARGS only for saves I asked for, not for auto-saves."
  (when taylor-gl/apheleia-explicit-save
    (apply fn args)))

(defun taylor-gl/save-buffer ()
  "Save the buffer, then reformat it with apheleia.
Formatting runs here rather than on `after-save-hook' so that it happens even
when the buffer is unmodified, and so that it starts after `ws-butler' has
restored the trailing newline -- a buffer change while apheleia's async job is
in flight makes apheleia discard the reformat."
  (interactive)
  (let ((formattable (and (bound-and-true-p apheleia-mode)
                          (not (buffer-narrowed-p))
                          (apheleia--get-formatters))))
    (cond
     ((buffer-modified-p) (save-buffer))
     ;; Nothing to write and nothing to format: let `save-buffer' say so.
     ((not formattable) (save-buffer)))
    (when formattable
      (let ((taylor-gl/apheleia-explicit-save t))
        (apheleia-format-after-save)))))

;; Saving a file that doesn't parse yet is normal, and apheleia announces it
;; from a bare `message' in a process sentinel with no way to turn it off.
;; *Messages* and the formatter's log buffer still get it.
(defun taylor-gl/apheleia-failure-message-p (fmt args)
  "Non-nil if FMT and ARGS are apheleia's \"formatter failed\" message."
  (let ((s (cond ((and (equal fmt "%s") (stringp (car args))) (car args))
                 ((stringp fmt) fmt))))
    (and s
         (string-prefix-p "Failed to run " s)
         (string-search "apheleia" s))))

(define-advice message
    (:around (fn &optional fmt &rest args) taylor-gl/quiet-apheleia-failures)
  "Call FN with FMT and ARGS, muting apheleia's formatter-failed message."
  (if (taylor-gl/apheleia-failure-message-p fmt args)
      (let ((inhibit-message t))
        (apply fn fmt args))
    (apply fn fmt args)))

(use-package beacon
  :demand
  :init
  (setq beacon-blink-when-focused t)
  :config
  (beacon-mode 1))

(use-package calc
  :straight (:type built-in)
  :config
  (setq calc-display-trail nil))

(use-package cape
  :demand
  :after corfu
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  :config
  (setq cape-dabbrev-min-length 2))

(use-package corfu
  :demand
  :general
  ("M-/" #'completion-at-point)
  (:keymaps 'corfu-map
            ;; RET and TAB keep doing their normal buffer job while the popup is
            ;; open; M-/ is the only key that commits a completion.
            "RET" nil
            "<return>" nil
            "TAB" nil
            "<tab>" nil
            ;; Arrows move point and nothing else.  Takes two unbindings:
            ;; corfu-map binds the arrows literally AND remaps
            ;; `next-line'/`previous-line', so clearing the literal keys alone
            ;; leaves them falling through and getting remapped straight back in.
            "<up>" nil
            "<down>" nil
            [remap next-line] nil
            [remap previous-line] nil
            ;; M-p is forward-sentence here, so corfu doesn't get it either.
            "M-p" nil
            ;; With the remaps gone, the four popup-motion keys are bound by
            ;; hand.  These are the only keys that move the selection.
            "C-n" #'corfu-next
            "C-e" #'corfu-previous
            "M-n" #'corfu-next
            "M-e" #'corfu-previous
            ;; corfu puts its doc buffer on M-h, but M-h is backward-word here.
            "M-h" nil
            "M-/" #'corfu-insert
            "C-b" #'corfu-info-documentation
            "<escape>" #'corfu-quit)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-quit-no-match t)
  ;; The default, `insert', commits a lone exact match on its own.  For an LSP
  ;; candidate that applies the server's textEdit, which carries its own
  ;; replacement range and so eats characters I already typed.
  (corfu-on-exact-match nil)
  ;; The default previews the selection as real buffer text rather than an
  ;; overlay, so merely moving the selection rewrites the file.
  (corfu-preview-current nil)
  :config
  ;; corfu-info-documentation lives in an extension, not in corfu proper.
  (require 'corfu-info)
  (global-corfu-mode))

;; A coloured badge in the corfu margin showing each candidate's kind
(use-package kind-icon
  :demand
  :after corfu
  :init
  ;; Icons are SVGs, fetched once by svg-lib and then cached on disk
  (setq svg-lib-icons-dir (expand-file-name "svg-lib/" user-emacs-directory)
        kind-icon-default-face 'corfu-default ;; blend the badge into the popup
        kind-icon-blend-background nil)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

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
   "H-M-f" 'counsel-find-file)
  ;; I kept hitting counsel-minibuffer-history by accident, so it's gone.
  (:keymaps 'minibuffer-local-map
            "C-r" nil)
  (:keymaps 'ivy-minibuffer-map
            "M-e" 'ivy-previous-history-element)
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d) "
        ;; hide certain files; taken from doom emacs
        counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)"))

;; counsel-projectile adds alternative actions besides the default actions of e.g. opening a file for
;; projectile commands, but I mostly just use it for counsel-projectile-rg, which uses ivy instead of
;; an rg-mode buffer for searching in the current project.
(use-package counsel-projectile
  :after (counsel projectile)
  :demand
  :general
  ("H-/" 'counsel-projectile-rg))

(use-package crux
  :demand t
  :general
  ("M-o" 'crux-kill-line-backwards)
  :config
  (crux-reopen-as-root-mode t))

;; Setup cua-mode, which enables standard C-v, C-c, and C-x keybindings for undo, copying and pasting.
;; It also does other things, like causing typed text to replace the active region.
;; (CUA stands for Common User Access, which is a misnomer because it does not match up with IBM's
;; Common User Access standard.)
(use-package cua-base
  :straight (:type built-in)
  :general
  ("C-S-v" 'taylor-gl/paste-from-primary)
  :init (cua-mode t)
  :config
  (setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
  (transient-mark-mode 1) ;; No region when it is not highlighted
  (setq cua-keep-region-after-copy t)) ;; Standard Windows behaviour

;; For now, docs must manually be installed with devdocs-install
(use-package devdocs
  :demand t
  :general
  ("C-c C-d" 'devdocs-lookup))

(use-package diff-hl
  :demand
  :ghook
  ('magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
  ('magit-post-refresh-hook #'diff-hl-magit-post-refresh)
  :config
  (setq-default fringes-outside-margins t)
  (setq diff-hl-draw-borders nil) ;; solid bars
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)) ;; update as you type, not only on save

(use-package dired
  :straight (:type built-in)
  :ghook ('dired-mode-hook #'dired-hide-details-mode)
  :general
  (:keymaps 'dired-mode-map
            "b" 'describe-mode
            "C-M-p" nil
            "C-M-e" 'dired-prev-subdir
            "* C-p" nil
            "* C-e" 'dired-prev-marked-file)
  :config
  (setq dired-listing-switches "-alh" ;; h == human-readable file sizes
        dired-dwim-target t
        find-file-visit-truename t
        dired-ls-F-marks-symlinks t
        dired-auto-revert-buffer t
        dired-recursive-deletes 'always
        dired-recursive-copies 'always))

(use-package dired-x
  :after dired
  :straight (:type built-in)
  :ghook ('dired-mode-hook #'dired-omit-mode)
  :config
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
  (setq dired-omit-files "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)")) ;; hide certain files

(use-package mood-line
  :demand
  :straight (:host github :repo "jessiehildebrandt/mood-line" :type git)
  :config
  (mood-line-mode))

;; Time of day emacs theme changer
;; From https://yannesposito.com/posts/0014-change-emacs-theme-automatically/index.html
;;
;; Burning Sun ships as two generated doom themes (see dotfiles/theme/). The
;; boundaries match the cron entries that switch i3, kitty, rofi and helix, so
;; the whole desktop turns over at the same moment.
(add-to-list 'custom-theme-load-path
             (expand-file-name "~/Dropbox/dotfiles/emacs/themes/"))

(defvar taylor-gl/theme nil
  "The doom theme currently loaded by `taylor-gl/auto-update-theme'.")

(defconst taylor-gl/light-theme-start 7.5
  "Hour at which the paper theme takes over. Matches crontab.")

(defconst taylor-gl/dark-theme-start 22.0
  "Hour at which the dark theme takes over. Matches crontab.")

(defconst taylor-gl/theme-state-file
  (expand-file-name "burning-sun/variant"
                    (or (getenv "XDG_CACHE_HOME") "~/.cache"))
  "File holding the desktop's current Burning Sun variant.
Written by switch-to-{dark,light}-theme.sh, which cron and the bar's theme
button both run. Emacs follows it rather than deciding for itself, so a
mid-afternoon click on the button does not get argued with by the clock.")

(defun taylor-gl/desired-variant ()
  "Return `dark' or `paper'.
The state file is authoritative; the clock is only a fallback for a machine
where the switch scripts have never run."
  (or (ignore-errors
        (with-temp-buffer
          (insert-file-contents taylor-gl/theme-state-file)
          (let ((v (string-trim (buffer-string))))
            (cond ((equal v "dark") 'dark)
                  ((equal v "paper") 'paper)))))
      (let* ((now (decode-time (current-time)))
             (clock (+ (nth 2 now) (/ (nth 1 now) 60.0))))
        (if (and (>= clock taylor-gl/light-theme-start)
                 (< clock taylor-gl/dark-theme-start))
            'paper
          'dark))))

(defun taylor-gl/auto-update-theme ()
  "Load whichever Burning Sun variant the desktop is currently on.
Called at startup, on a timer as a self-heal, and by the switch scripts over
emacsclient so the button restyles emacs along with everything else."
  (interactive)
  (let ((theme (if (eq (taylor-gl/desired-variant) 'paper)
                   'burning-sun-paper
                 'burning-sun-dark)))
    (unless (eq theme taylor-gl/theme)
      ;; load-theme stacks rather than replaces, so the outgoing theme has to
      ;; be disabled explicitly or its faces bleed through the new one.
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme theme t)
      (setq taylor-gl/theme theme)))
  ;; Re-check at the next boundary in case emacs was asleep when cron fired.
  (let* ((now (decode-time (current-time)))
         (clock (+ (nth 2 now) (/ (nth 1 now) 60.0)))
         (next (if (and (>= clock taylor-gl/light-theme-start)
                        (< clock taylor-gl/dark-theme-start))
                   taylor-gl/dark-theme-start
                 taylor-gl/light-theme-start))
         (hh (floor next))
         (mm (round (* 60 (- next hh)))))
    (run-at-time (format "%02d:%02d" hh mm) nil #'taylor-gl/auto-update-theme)))

;; doom-themes supplies the face scaffolding; the Burning Sun themes are
;; generated on top of it (see dotfiles/theme/).
(use-package doom-themes
  :demand
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        burning-sun-dark-padded-modeline t
        burning-sun-paper-padded-modeline t)
  ;; The ansi-color faces (and the shell-mode colour bug that used to be
  ;; worked around here) are defined by the Burning Sun themes directly,
  ;; so they follow the scheme instead of doom-color lookups.
  (doom-themes-visual-bell-config)
  (taylor-gl/auto-update-theme))

(defun taylor-gl/transpose-paragraphs-backward ()
  "Transpose this paragraph with the previous one."
  (interactive "*")
  (transpose-paragraphs -1))

(use-package drag-stuff
  :demand
  :general
  (:keymaps 'drag-stuff-mode-map
            "H-e" 'drag-stuff-up
            "H-n" 'drag-stuff-down
            "H-C-n" 'transpose-paragraphs
            "H-C-e" 'taylor-gl/transpose-paragraphs-backward)
  :config
  (drag-stuff-global-mode 1))

(use-package dot-mode
  :demand
  :config
  (global-dot-mode t))

;; Copy environment variables from shell to emacs
;; Should help with some commands not working in emacs
(use-package exec-path-from-shell
  :demand
  :config
  (when (or (memq window-system '(mac ns x)) (daemonp))
    (exec-path-from-shell-initialize)))

(defun taylor-gl/mark-symbol ()
  "Mark the symbol at point."
  (interactive)
  (if-let* ((bounds (bounds-of-thing-at-point 'symbol)))
      (progn
        (push-mark (car bounds) nil t)
        (goto-char (cdr bounds)))
    (user-error "No symbol at point")))

(general-define-key "H-@" #'taylor-gl/mark-symbol)

;; Grows the region one syntactic step at a time, off the tree-sitter parse,
;; falling back to sexp/string/line where there is no grammar
(use-package expreg
  :demand
  :general
  ("H-x" #'expreg-expand
   "H-X" #'expreg-contract))

(use-package goto-chg
  :general
  ("H-z" 'goto-last-change))

;; Highlight quoted symbols in elisp
(use-package highlight-quoted
  :demand
  :ghook 'emacs-lisp-mode-hook)

(use-package hl-todo
  :demand
  :general
  ("C-c t n" #'hl-todo-next
   "C-c t e" #'hl-todo-previous)
  :config
  (global-hl-todo-mode 1)
  ;; The four gruvbox tiers these used to carry were already an urgency ramp,
  ;; so they map cleanly onto ember -> grey: the loudest keywords burn, and
  ;; the settled ones recede into the page. Values follow the loaded theme.
  (setq hl-todo-keyword-faces
        (let ((burn  (face-attribute 'error :foreground nil t))          ; ember
              (warm  (face-attribute 'font-lock-constant-face :foreground nil t))
              (cool  (face-attribute 'font-lock-keyword-face :foreground nil t))
              (quiet (face-attribute 'font-lock-comment-face :foreground nil t)))
          `(("FIXME"       . ,burn)
            ("GOTCHA"      . ,burn)
            ("TODO"        . ,burn)
            ("TODOs"       . ,burn)
            ("XXX"         . ,burn)
            ("DEBUG"       . ,warm)
            ("INPROGRESS"  . ,warm)
            ("REVIEW"      . ,warm)
            ("SHOULD"      . ,warm)
            ("WAITING"     . ,warm)
            ("STUB"        . ,warm)
            ("MAYBE"       . ,cool)
            ("HACK"        . ,cool)
            ("NOTE"        . ,cool)
            ("ANSWER"      . ,cool)
            ("ABANDONED"   . ,quiet)
            ("DEPRECATED"  . ,quiet)
            ("DONE"        . ,quiet)))))

(use-package info
  :straight (:type built-in)
  :general
  (:keymaps 'Info-mode-map
            "b" 'Info-help
            "B" 'describe-mode))

;; Emacs 28+ composes ligatures directly through Harfbuzz
(use-package ligature
  :demand
  :config
  (ligature-set-ligatures
   'prog-mode
   ;; The standard Fira Code set, minus the ones I never wanted:
   ;; "<>", "#{", "#(", "..", "[]", "x", "{-", "-}".
   '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
     ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
     "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
     "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
     "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
     "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
     "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
     "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
     ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
     "<$" "<=" "<-" "<<" "<+" "</" "#[" "#:" "#=" "#!" "##" "#?"
     "#_" "%%" ".=" ".-" ".?" "+>" "++" "?:" "?=" "?." "??" ";;"
     "/*" "/=" "/>" "//" "__" "(*" "*)" "\\\\" "://"))
  (global-ligature-mode t))

(use-package magit
  :demand
  :general
  (:keymaps 'git-rebase-mode-map
            "M-p" nil
            "M-e" 'git-rebase-move-line-up)
  (:keymaps 'magit-mode-map
            (kbd "<tab>") 'magit-section-toggle
            "B" 'magit-describe-section
            "H" 'magit-bisect
            "p" 'magit-ediff-dwim
            "M-p" nil
            "M-e" 'magit-section-backward-sibling)
  ("H-b" 'magit-blame)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1
        magit-commit-show-diff nil
        magit-diff-refine-hunk 'all))

(use-package magit-todos
  :after magit
  :ghook ('magit-mode-hook #'magit-todos-mode))

(use-package mixed-pitch
  :ghook 'text-mode-hook)

(use-package olivetti
  :commands olivetti-mode)

(use-package prescient
  :demand
  :after counsel
  :config
  (prescient-persist-mode 1)
  (setq prescient-filter-method '(literal regexp initialism)))

(use-package ivy-prescient
  :demand
  :after (counsel prescient)
  :config
  (ivy-prescient-mode 1))

(use-package ivy-rich
  :demand
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev))

(use-package jinx
  :ghook 'text-mode-hook)

(use-package projectile
  :demand t
  :general
  ("C-c p" 'projectile-command-map)
  (:keymaps 'projectile-command-map
            "ESC" nil)
  ("H-f" 'projectile-find-file)
  :config
  (projectile-mode t)
  (setq projectile-indexing-method 'hybrid
        ;; projectile compares against expanded truenames, so "~/" never matches
        projectile-ignored-projects (mapcar #'expand-file-name
                                            '("~/" "~/Dropbox/" "~/bl/")))
  ;; 'alien indexing ignores projectile-ignored-projects, because rg does the
  ;; searching; ~/.ignore applies the same exclusions either way
  (when (executable-find "rg")
    (setq projectile-generic-command
          "rg -0 --files --color=never --hidden --one-file-system --ignore-file ~/.ignore")))

(use-package rainbow-delimiters
  :ghook 'prog-mode-hook)

(use-package rainbow-mode
  :demand)

(use-package re-builder
  :straight (:type built-in)
  :init
  (setq reb-re-syntax 'string))

(use-package saveplace
  :straight (:type built-in)
  :demand
  :init
  ;; Read by save-place-mode on activation, so it has to be set before that
  (setq save-place-file (expand-file-name "saveplace" user-emacs-directory))
  (save-place-mode 1))

(use-package smart-hungry-delete
  :demand
  :general
  ("<backspace>" #'smart-hungry-delete-backward-char
   "C-d" #'smart-hungry-delete-forward-char)
  :config
  (smart-hungry-delete-add-default-hooks))

(use-package topsy
  :straight (:host github :repo "alphapapa/topsy.el" :type git)
  :ghook 'prog-mode-hook)

(use-package vundo
  :general
  ("C-z" 'undo
   "C-S-z" 'undo-redo
   "<mouse-8>" 'undo
   "<drag-mouse-8>" 'undo
   "<mouse-9>" 'undo-redo
   "<drag-mouse-9>" 'undo-redo
   "C-x u" 'vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols
        vundo-compact-display t))

;; Persists undo history across sessions
(use-package undo-fu-session
  :demand
  :init
  (setq undo-fu-session-directory
        (expand-file-name "undo-fu-session/" user-emacs-directory))
  :config
  (undo-fu-session-global-mode))

;; Setup uniquify for better buffer names
(use-package uniquify
  :straight (:type built-in)
  :demand
  :config
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

;; Makes an ivy-occur results buffer editable with C-x C-q, so a project-wide
;; search becomes a project-wide edit (C-c C-c applies it, C-c C-k discards it)
(use-package wgrep
  :demand
  :general
  (:keymaps 'wgrep-mode-map
            ;; Edits only reach the files via wgrep-finish-edit, so C-s means that
            "C-s" #'wgrep-finish-edit)
  :config
  (setq wgrep-auto-save-buffer t     ;; write the touched files, don't leave them modified
        wgrep-change-readonly-file t))

(use-package which-key
  :straight (:type built-in)
  :demand
  :custom
  (which-key-idle-delay 0.01)
  (which-key-idle-secondary-delay 0.01)
  (which-key-sort-uppercase-first nil)
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom))

;; Setup whitespace (to visualize trailing whitespace etc.)
(use-package whitespace
  :straight (:type built-in)
  :demand
  :config
  (setq whitespace-style '(face trailing tabs tab-mark)))

;; ws-butler trims whitespace only on changed lines when you save
(use-package ws-butler
  :demand
  :config
  (ws-butler-global-mode))


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   PROGRAMMING MODES                                                                 |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
(defconst taylor-gl/indent-variables
  '(tab-width
    c-basic-offset
    js-indent-level
    css-indent-offset
    typescript-ts-mode-indent-offset
    web-mode-markup-indent-offset
    web-mode-css-indent-offset
    web-mode-code-indent-offset
    web-mode-block-padding)
  "Every variable that means \"one indent level\" in some major mode I use.")

(defun taylor-gl/setup-indent (n)
  "Set every indent-width variable to N, buffer-locally."
  (setq-local indent-tabs-mode nil)
  (dolist (var taylor-gl/indent-variables)
    (set (make-local-variable var) n)))

(defun taylor-gl/setup-code-mode ()
  "Common setup for every programming buffer."
  (taylor-gl/setup-indent 2)
  (setq-local display-fill-column-indicator-column 100)
  (display-fill-column-indicator-mode)
  (whitespace-mode))

(general-add-hook 'prog-mode-hook #'taylor-gl/setup-code-mode)

;; Workaround to emacs 30.2/libtreesitter 0.26 bug
(load (expand-file-name "treesit-predicate-rewrite" user-emacs-directory) nil 'nomessage nil t)

(use-package treesit
  :straight (:type built-in)
  :demand
  :init
  (setq treesit-extra-load-path '("/home/taylorgl/.builds/tree-sitter-module/dist"))
  (setq treesit-language-source-alist
        '((tsx "https://github.com/tree-sitter/tree-sitter-typescript"
               "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master" "typescript/src")))
  :config
  ;; Emacs 30 ships these modes but gives .yaml and Dockerfile no auto-mode entry
  (dolist (entry '(("\\.tsx\\'" . tsx-ts-mode)
                   ("\\.ts\\'" . typescript-ts-mode)
                   ("\\.ya?ml\\'" . yaml-ts-mode)
                   ("\\(?:Dockerfile\\|Containerfile\\)\\(?:\\..*\\)?\\'" . dockerfile-ts-mode)
                   ("\\.dockerfile\\'" . dockerfile-ts-mode)))
    (add-to-list 'auto-mode-alist entry))
  ;; Both js keys are needed: auto-mode-alist names `javascript-mode', which is
  ;; only an alias for `js-mode', and major-mode-remap-alist matches the symbol.
  ;; Only the languages I actually meet inside a TS project are remapped -- the
  ;; other ts-modes indent less well than the modes they would replace.
  (dolist (from '((js-mode         . js-ts-mode)
                  (javascript-mode . js-ts-mode)
                  (sh-mode         . bash-ts-mode)
                  (css-mode        . css-ts-mode)
                  (json-mode       . json-ts-mode)
                  (js-json-mode    . json-ts-mode)))
    (add-to-list 'major-mode-remap-alist from)))

(defun taylor-gl/eglot-ensure-for-real-files ()
  "Run `eglot-ensure' only for buffers visiting real files."
  (when (and buffer-file-name
             (file-exists-p buffer-file-name)
             (not (string-match-p "\\.~[^/]+~\\'" (buffer-name))))
    (eglot-ensure)))

(use-package eglot
  :straight (:type built-in)
  :commands eglot
  :ghook
  ('(typescript-ts-mode-hook tsx-ts-mode-hook js-ts-mode-hook
     elixir-ts-mode-hook heex-ts-mode-hook)
   #'taylor-gl/eglot-ensure-for-real-files)
  :general
  (:keymaps 'eglot-mode-map
            "H-r" #'eglot-rename
            "C-c c r" #'eglot-rename
            "C-c c o" #'eglot-code-action-organize-imports)
  :config
  ;; One line in the echo area; the full signature goes to eldoc-box's childframe
  (setq eldoc-echo-area-use-multiline-p nil)
  ;; On-type formatting is the server rewriting the buffer as a side effect of an
  ;; ordinary self-inserted character: RET after `Enum.map([], fn ->' comes back
  ;; with a matching `end' I never typed.  Formatting is apheleia's job, on save.
  (add-to-list 'eglot-ignored-server-capabilities
               :documentOnTypeFormattingProvider)
  ;; `includeAutomaticOptionalChainCompletions' rewrites `foo.bar' to `foo?.bar'
  ;; when tsserver decides foo might be nullable, and its text edit covers the
  ;; dot I already typed.  It goes in initializationOptions because that is the
  ;; only place typescript-language-server merges arbitrary tsserver preferences.
  ;; The `:language-id's are not decoration.  Eglot only sends what is written
  ;; here; for a bare mode symbol it invents one by stripping "-ts-mode", so
  ;; tsx-ts-mode announces itself as "tsx" and js-ts-mode as "js".  Neither is a
  ;; language id typescript-language-server knows, and it classifies anything it
  ;; doesn't recognise as JavaScript.
  (add-to-list 'eglot-server-programs
               '(((typescript-ts-mode :language-id "typescript")
                  (tsx-ts-mode :language-id "typescriptreact")
                  (js-ts-mode :language-id "javascript"))
                 . ("typescript-language-server" "--stdio"
                    :initializationOptions
                    (:preferences
                     (:includeAutomaticOptionalChainCompletions :json-false)))))
  ;; ElixirLS reads completions out of compiled BEAM files, so the first
  ;; connection in a project blocks on a full `mix compile', and a module that
  ;; fails to compile stops appearing in the popup entirely.
  (add-to-list 'eglot-server-programs
               '((elixir-ts-mode heex-ts-mode) . ("elixir-ls"))))

;; The full eldoc documentation in a childframe, since the echo area is held to
;; one line
(use-package eldoc-box
  :ghook ('eglot-managed-mode-hook #'eldoc-box-hover-at-point-mode)
  :config
  (setq eldoc-box-max-pixel-width 800
        eldoc-box-max-pixel-height 400
        eldoc-box-clear-with-C-g t))

;; elixir-ts-mode indents an unparseable region with ((parent-is "ERROR")
;; prev-line 2), and `prev-line' means the literal line above, blank lines
;; included -- so RET after `Enum.map([], fn ->' re-indents the line I just left
;; to the blank line's column.  That rule assumes something closes the block for
;; you the moment you open it (on-type formatting, smartparens); I run neither.
;; Valid code still indents, and a misplaced line is fixed once it parses.
(defun taylor-gl/elixir-ts-no-indent-in-error ()
  "Leave lines inside an unparseable region at the column I typed them.
Rebuilds `treesit-simple-indent-rules' rather than modifying it in place:
`setf' on `alist-get' would `setcdr' the cons that elixir-ts-mode shares
with the global `elixir-ts--indent-rules', growing it once per buffer."
  (setq-local treesit-simple-indent-rules
              (mapcar (lambda (entry)
                        (if (eq (car entry) 'elixir)
                            (cons 'elixir
                                  (cons '((parent-is "ERROR") no-indent 0)
                                        (cdr entry)))
                          entry))
                      treesit-simple-indent-rules)))

(use-package elixir-ts-mode
  :mode ("\\.ex\\'" "\\.exs\\'")
  ;; Runs after the mode body, which is where `treesit-major-mode-setup' installs
  ;; the rules this overrides.
  :ghook ('elixir-ts-mode-hook #'taylor-gl/elixir-ts-no-indent-in-error))

(defconst taylor-gl/erlang-root
  (seq-find #'file-directory-p '("/usr/lib/erlang" "/usr/local/lib/erlang"))
  "Root of the installed Erlang, or nil if there isn't one.")

(defconst taylor-gl/erlang-emacs-dir
  (and taylor-gl/erlang-root
       (car (last (sort (file-expand-wildcards
                         (expand-file-name "lib/tools-*/emacs" taylor-gl/erlang-root))
                        #'string<))))
  "Directory holding erlang-mode, discovered from the installed tools app.")

(when taylor-gl/erlang-emacs-dir
  (add-to-list 'load-path taylor-gl/erlang-emacs-dir))

(use-package erlang
  :straight nil
  :when taylor-gl/erlang-emacs-dir
  :mode ("\\.erl\\'" . erlang-mode)
  :init
  (setq erlang-root-dir taylor-gl/erlang-root))

(use-package mmm-mode
  :demand
  :custom-face
  (mmm-default-submode-face ((t (:background nil))))
  :init
  (setq mmm-global-mode 'maybe
        mmm-parse-when-idle t
        mmm-set-file-name-for-modes '(web-mode))
  (let ((class 'elixir-eex)
        (submode 'web-mode)
        (front "^[ ]+~[HL]\"\"\"")
        (back "^[ ]+\"\"\""))
    (mmm-add-classes (list (list class :submode submode :front front :back back)))
    (mmm-add-mode-ext-class 'elixir-ts-mode nil class)))

;; Setup web-mode for HTML, CSS, elixir .eex files, etc.
(use-package web-mode
  :mode "\\.[px]?html?\\'"
  :mode "\\.\\(?:tpl\\|blade\\)\\(?:\\.php\\)?\\'"
  :mode "\\.erb\\'"
  :mode "\\.l?eex\\'"
  :mode "\\.h?eex\\'"
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
  :mode "\\.svg\\'"
  :ghook
  ('web-mode-hook
   (lambda ()
     (setq-local devdocs-current-docs
                 '("css" "html" "javascript" "react" "react_router"
                   "tailwindcss" "typescript"))))
  :general
  ;; web-mode's own prefixed motion commands, on the same hnei shape.
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

  (define-advice web-mode-guess-engine-and-content-type (:around (f &rest r) guess-engine-by-extension)
    (if (and buffer-file-name (equal "ex" (file-name-extension buffer-file-name)))
        (progn (setq web-mode-content-type "html")
               (setq web-mode-engine "elixir")
               (web-mode-on-engine-setted))
      (apply f r)))
  :config
  (add-to-list 'web-mode-engines-alist '("elixir" . "\\.eex\\'"))
  (setq-default web-mode-comment-formats (remove '("javascript" . "/*") web-mode-comment-formats))
  (add-to-list 'web-mode-comment-formats '("javascript" . "//"))
  (add-to-list 'web-mode-comment-formats '("typescript" . "//")))

(use-package sh-script
  :straight (:type built-in)
  ;; `sh-base-mode-hook', not `sh-mode-hook': `bash-ts-mode' derives from
  ;; sh-base-mode alongside sh-mode, not from sh-mode itself
  :ghook
  ('sh-base-mode-hook (lambda () (setq-local devdocs-current-docs '("bash")))))

(use-package slime
  :config
  (setq slime-lisp-implementations
        '((sbcl ("/usr/bin/sbcl" "--dynamic-space-size" "2GB") :coding-system utf-8-unix))
        slime-net-coding-system 'utf-8-unix
        slime-export-save-file t
        slime-contribs '(slime-fancy slime-repl slime-scratch slime-trace-dialog)
        lisp-simple-loop-indentation 1
        lisp-loop-keyword-indentation 6
        lisp-loop-forms-indentation 6)
  (add-hook 'slime-load-hook (lambda () (require 'slime-fancy))))

(use-package markdown-mode
  ;; Order matters: use-package pushes each :mode entry onto the front of
  ;; auto-mode-alist, so the one listed last is the one that wins.
  :mode (("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :ghook
  ('markdown-mode-hook (lambda () (setq-local devdocs-current-docs '("markdown"))))
  :init
  (setq markdown-command "pandoc")
  :config
  (set-face-attribute 'markdown-list-face nil :foreground "#555555"))

(use-package typo
  :demand
  :config
  (typo-global-mode t))


;;+-------------------------------------------------------------------------------------+
;;|                                                                                     |
;;|   UTILITY FUNCTIONS                                                                 |
;;|                                                                                     |
;;+-------------------------------------------------------------------------------------+
;; Based on crux-find-user-init-file, but opens in the same window
(defun taylor-gl/find-user-init-file ()
  "Edit the `user-init-file', in the same window."
  (interactive)
  (find-file user-init-file))

;; Similar to sort-lines, keep-lines, etc
(defun taylor-gl/uniquify-region-lines (beg end)
  "Remove duplicate adjacent lines between BEG and END."
  (interactive "*r")
  (save-excursion
    (goto-char beg)
    (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
      (replace-match "\\1"))))

(defun taylor-gl/uniquify-buffer-lines ()
  "Remove duplicate adjacent lines in the current buffer."
  (interactive)
  (taylor-gl/uniquify-region-lines (point-min) (point-max)))

(defun taylor-gl/paste-from-primary ()
  "Insert the X primary selection at point."
  (interactive)
  (insert (gui-get-primary-selection)))

(provide 'init)
;;; init.el ends here
