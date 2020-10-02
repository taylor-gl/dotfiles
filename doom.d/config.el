;; =============================================================================
;; GENERAL
;; =============================================================================
(setq user-full-name "Taylor Lunt"
      user-mail-address "taylorlunt@gmail.com")

(setq doom-font (font-spec :family "Fira Code" :size 14))
(setq doom-variable-pitch-font (font-spec :family "Advent Pro" :size 14))

;; disable line numbers for better performance
(setq display-line-numbers-type nil)
(setq garbage-collection-messages 1)

(setq create-lockfiles nil)

;; for tiling window manager
(setq frame-resize-pixelwise t)

(setq whitespace-style '(face trailing tabs tab-mark))

(setq-default fill-column 110)

;; Theming
(setq doom-theme 'doom-solarized-dark)
;; Change illegible snipe higlight color so highlighted characters are visible
(custom-set-faces!
  '(evil-snipe-first-match-face :background "#dc322f"))

;; enable soft wrapping in some modes
(add-hook! 'org-mode-hook #'+word-wrap-mode)
(add-hook! 'markdown-mode-hook #'+word-wrap-mode)

(auto-save-visited-mode 1)
(setq auto-save-visited-interval 5)  ;; save after 5 seconds of idle time

;; lower than default undo limit so it doesn't crash my emacs
(setq undo-limit 40000
      undo-outer-limit 8000000
      undo-strong-limit 100000)

(add-hook 'after-change-functions 'my-instant-save-buffer)

(map! :leader
  "/" 'comment-line)

;; emoji 😂
(use-package! emojify
  :config
  (add-hook 'after-init-hook #'global-emojify-mode))

;; async execution of org-babel src blocks
(use-package! ob-async)

;; haskell
(setq haskell-interactive-popup-errors nil)

;; dired
(setq dired-dwim-target t)
(add-hook! 'dired-mode-hook
    (dired-hide-details-mode))

;; hyphenate.sh must be in path
(defun hyphen-file ()
  "Soft-hyphenate using a shell script."
  (interactive)
  (shell-command-on-region (point-min) (point-max) "hyphenate.sh" (current-buffer) t)
  )
(defun unhyphen-file ()
  "Remove soft hyphens."
  (interactive)
  (while (search-forward "­" nil t)
    (replace-match "" nil t))
  )
(map! :leader
      "-" 'hyphen-file
      "–" 'unhyphen-file
      )

;; replace / with evil sniping whole buffer and ? with swiper isearch
;; (after! evil
  ;; (map! :leader
        ;; "s s" #'evil-ex-search-forward
        ;; "s z" #'evil-ex-search-backward
        ;; )
  ;; )
(after! swiper
  (map!
   :nev "/" #'evil-avy-goto-char-2
   :nev "?" #'swiper-isearch
   )
  )

;; elfeed
;; (map! :leader
      ;; "o e" 'elfeed
      ;; "o B" 'elfeed-search-browse-url
      ;; )
;; (setq rmh-elfeed-org-files (list "~/Dropbox/emacs/rss.org"))

;; scrolling
(setq mouse-wheel-scroll-amount '(2 ((control) . 5))) ;; two lines at a time unless control held

;; =============================================================================
;; ORG MODE
;; =============================================================================
(setq org-directory "~/Dropbox/emacs/")

;; programs for opening org-mode links
(after! org
  ;; (setq org-drill-scope 'directory)
  (setq org-modules '(ol-bibtex org-habit))
  (setq org-log-into-drawer t) ;; log into LOGBOOK drawer
  (setq org-file-apps '((auto-mode . emacs)
                        (directory . emacs)
                        ("\\.mm\\'" . default)
                        ("\\.x?html?\\'" . default)
                        ("\\.pdf\\'" . "evince \"%s\"")
                        ("\\.djvu\\'" . "evince \"%s\"")
                        ("\\.epub\\'" . "ebook-viewer \"%s\"")
                        ))

  (setq org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(i)" "SHOULD(s)" "MAYBE(m)" "NOTE(n)" "WAITING(w)" "NPC(p)" "MET(P)" "|" "DONE(d)" "ABANDONED(a)" )))
  (setq org-todo-keyword-faces '(
                                 ("TODO" :foreground "#d33628" :weight bold :underline f)
                                 ("INPROGRESS" :foreground "#cb4b16" :weight bold :underline f)
                                 ("WAITING" :foreground "#cb4b16" :weight bold :underline f)
                                 ("SHOULD" :foreground "#6c71c4" :weight bold :underline f)
                                 ("NOTE" :foreground "#6c71c4" :weight bold :underline f)
                                 ("MAYBE" :foreground "#b58900" :weight bold :underline f)
                                 ("MET" :foreground "#d33682" :weight bold :underline f)
                                 ("NPC" :foreground "#dc322f" :weight bold :underline f)
                                 ("DONE" :foreground "#839496" :weight bold :underline f)
                                 ("ABANDONED" :foreground "#839496" :weight bold :underline f)
                                 ))

  (setq calendar-holidays '(
                                (holiday-fixed 1 1 "New Year's Day")
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
                                                       calendar-daylight-time-zone-name)))
                                ))

)

;; I now use Anki instead
;; (use-package! org-drill
  ;; :after org)

;; Launch anki async
(defun anki-launch ()
  (interactive)
  (start-process "anki" nil "anki")
  )

;; don't annoy me by asking for confirmation
(setq org-link-shell-confirm-function nil)

;; don't show DONE items in agenda
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)

;; filter all :drill: items from org-agenda
;; (defun my-skip-tag(tag)
  ;; "Skip entries that are tagged TAG"
  ;; (let* ((entry-tags (org-get-tags-at (point))))
    ;; (if (member tag entry-tags)
        ;; (progn (outline-next-heading) (point))
      ;; nil)))
;; (setq org-agenda-custom-commands
      ;; '(("n" "Agenda and all TODOs"
         ;; ((agenda ""
                  ;; (
                   ;; (org-agenda-skip-function '(my-skip-tag "drill"))
                   ;; ))
          ;; (alltodo "")))))

;; disable flycheck in org files
(setq flycheck-global-modes '(not org-mode))

;; I don't want tab completion in org mode (rest are defaults in doom emacs)
(setq company-global-modes '(not erc-mode message-mode help-mode gud-mode eshell-mode org-mode))

;; =============================================================================
;; COLEMAK
;; =============================================================================
;; Using the colemak rebindings from here https://github.com/wbolster/evil-colemak-basics
(use-package! evil-colemak-basics
  :after evil
  :config
  (global-evil-colemak-basics-mode)
  (setq evil-colemak-basics-rotate-t-f-j nil)
  )

;; Doom
;; ie. window movement
(map! :leader
      "w j" nil
      "w k" nil
      "w l" nil
      "w J" nil
      "w K" nil
      "w L" nil
      "w C-j" nil
      "w C-k" nil
      "w C-l" nil
      )
(map! :leader
      "w h" 'evil-window-left
      "w n" 'evil-window-down
      "w e" 'evil-window-up
      "w i" 'evil-window-right
      "w k" 'evil-window-new
      "w H" '+evil/window-move-left
      "w N" '+evil/window-move-down
      "w E" '+evil/window-move-up
      "w I" '+evil/window-move-right
      "w C-h" 'evil-window-left
      "w C-n" 'evil-window-down
      "w C-e" 'evil-window-up
      "w C-i" 'evil-window-right
      "w C-k" 'evil-window-new
      )

;; avy-keys (used for characters which pop up when jumping)
;; These correspond to: a r s t d h n e i o '
(setq avy-keys '(97 114 115 116 100 104 110 101 105 111 39))

;; evil-easymotion (evilem-map, which are keybinds accessed after typing gs)
(after! evil-easymotion
  (map! :map evilem-map
        "j" nil
        "k" nil
        "g j" nil
        "g k" nil
        "N" nil
        "E" nil
        "n" #'evilem-motion-next-line
        "e" #'evilem-motion-previous-line
        "g n" #'evilem-motion-next-visual-line
        "g e" #'evilem-motion-previous-visual-line
        "k" #'evilem-motion-search-next
        "K" #'evilem-motion-search-previous
        "f" #'evilem-motion-forward-word-end
        "F" #'evilem-motion-forward-WORD-end
        "g f" #'evilem-motion-backward-word-end
        "g F" #'evilem-motion-backward-WORD-end
        "t" #'evilem-motion-find-char
        "T" #'evilem-motion-find-char-backward
        "j" #'evilem-motion-find-char-to
        "J" #'evilem-motion-find-char-to-backward
        )
  )

;; which-key paging keys
(after! which-key
  (map! :map which-key-C-h-map
        "j" nil
        "k" nil
        ; n is already set correctly because n/p can also be used for next/previous
        "e" #'which-key-show-previous-page-cycle
        "l" #'which-key-undo-key
        "C l" #'which-key-undo-key
        )
  )


;; Ivy
(map!
 "C-e" nil)
(after! ivy
  (map!
   "C-e" 'ivy-previous-line))

;; Org
(after! org
  (map!
   :nei "M-i" 'org-metaright
   :nei "M-n" 'org-metadown
   :nei "M-e" 'org-metaup
   :nei "S-h" 'org-shiftleft
   :nei "S-o" 'org-shiftright
   )
  ;; org schedule calendar movement with hnei
  (map! :map org-read-date-minibuffer-local-map "C-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-day 1))))
  (map! :map org-read-date-minibuffer-local-map "C-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-week 1))))
  (map! :map org-read-date-minibuffer-local-map "C-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-week 1))))
  (map! :map org-read-date-minibuffer-local-map "C-i" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-day 1))))
  (map! :map org-read-date-minibuffer-local-map "C-S-h" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-month 1))))
  (map! :map org-read-date-minibuffer-local-map "C-S-n" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-year 1))))
  (map! :map org-read-date-minibuffer-local-map "C-S-e" (lambda () (interactive) (org-eval-in-calendar '(calendar-backward-year 1))))
  (map! :map org-read-date-minibuffer-local-map "C-S-i" (lambda () (interactive) (org-eval-in-calendar '(calendar-forward-month 1))))
)
;; evil-org
(after! evil-org
  (map! :map evil-org-mode-map
        :vo "i r" nil
        :vo "i R" nil
        :vo "i e" nil
        :vo "i E" nil
        :vo "i" #'evil-forward-char
        :vo "u r" #'evil-org-inner-greater-element
        :vo "u R" #'evil-org-inner-subtree
        :vo "u e" #'evil-org-inner-object
        :vo "u E" #'evil-org-inner-element
   )
  )

;; Magit
;; TODO

;; Flycheck
;; TODO



;; =============================================================================
;; FIRA CODE LIGATURES
;; =============================================================================
;; from https://github.com/tonsky/FiraCode/wiki/Emacs-instructions
(defun fira-code-mode--make-alist (list)
  "Generate prettify-symbols alist from LIST."
  (let ((idx -1))
    (mapcar
     (lambda (s)
       (setq idx (1+ idx))
       (let* ((code (+ #Xe100 idx))
          (width (string-width s))
          (prefix ())
          (suffix '(?\s (Br . Br)))
          (n 1))
     (while (< n width)
       (setq prefix (append prefix '(?\s (Br . Bl))))
       (setq n (1+ n)))
     (cons s (append prefix suffix (list (decode-char 'ucs code))))))
     list)))

(defconst fira-code-mode--ligatures
  '("www" "**^&^&" "***$%#%" "**/" "*>" "*/" "\\\\" "\\\\\\"
    "{-" "[]" "::" ":::" ":=" "!!" "!=" "!==" "-}"
    "--" "---" "-->" "->" "->>" "-<" "-<<" "-~"
    "#{" "#[" "##" "###" "####" "#(" "#?" "#_" "#_("
    ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*"
    "/**" "/=" "/==" "/>" "//" "///" "&&" "||" "||="
    "|=" "|>" "^=" "$>" "++" "+++" "+>" "=:=" "=="
    "===" "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-" ">="
    ">=>" ">>" ">>-" ">>=" ">>>" "<*" "<*>" "<|" "<|>"
    "<$" "<$>" "<!--" "<-" "<--" "<->" "<+" "<+>" "<="
    "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~"
    "<~~" "</" "</>" "~@" "~-" "~=" "~>" "~~" "~~>" "%%"
    "x" ":" "+" "+" "*"))

(defvar fira-code-mode--old-prettify-alist)

(defun fira-code-mode--enable ()
  "Enable Fira Code ligatures in current buffer."
  (setq-local fira-code-mode--old-prettify-alist prettify-symbols-alist)
  (setq-local prettify-symbols-alist (append (fira-code-mode--make-alist fira-code-mode--ligatures) fira-code-mode--old-prettify-alist))
  (prettify-symbols-mode t))

(defun fira-code-mode--disable ()
  "Disable Fira Code ligatures in current buffer."
  (setq-local prettify-symbols-alist fira-code-mode--old-prettify-alist)
  (prettify-symbols-mode -1))

(define-minor-mode fira-code-mode
  "Fira Code ligatures minor mode"
  :lighter " Fira Code"
  (setq-local prettify-symbols-unprettify-at-point 'right-edge)
  (if fira-code-mode
      (fira-code-mode--enable)
    (fira-code-mode--disable)))

(defun fira-code-mode--setup ()
  "Setup Fira Code Symbols"
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol"))

(provide 'fira-code-mode)

(define-global-minor-mode global-fira-code-mode
  fira-code-mode
  (lambda () (fira-code-mode t)
    ))

(global-fira-code-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files (quote ("~/Dropbox/emacs/todo.org"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-snipe-first-match-face ((t (:background "#dc322f")))))
