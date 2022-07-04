;;; pastel-theme -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: taylor-gl
;; Based on the doom-themes by hlissner
;;
;;; Commentary:
;;
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup pastel-theme nil
  "Options for the `pastel' theme."
  :group 'doom-themes)

(defcustom pastel-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'pastel-theme
  :type 'boolean)

(defcustom pastel-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'pastel-theme
  :type 'boolean)

(defcustom pastel-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'pastel-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme pastel
  "A light theme inspired by Atom One Light."

  ;; name        default   256       16
  ((bg         '("#fafafa" "white"   "white"        ))
   (fg         '("#383a42" "#424242" "black"        ))

   ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
   ;; but can also be useful as a basis for subtle highlights (e.g. for hl-line
   ;; or region), especially when paired with the `doom-darken', `doom-lighten',
   ;; and `doom-blend' helper functions.
   (bg-alt     '("#efc7e9" "white"   "white"        ))
   (fg-alt     '("#c6c7c7" "#c7c7c7" "brightblack"  ))

   ;; These should represent a spectrum from bg to fg, where base0 is a starker
   ;; bg and base8 is a starker fg. For example, if bg is light grey and fg is
   ;; dark grey, base0 should be white and base8 should be black.
   (base0      '("#f0f0f0" "#f0f0f0" "white"        ))
   (base1      '("#e7e7e7" "#e7e7e7" "brightblack"  ))
   (base2      '("#dfdfdf" "#dfdfdf" "brightblack"  ))
   (base3      '("#c6c7c7" "#c6c7c7" "brightblack"  ))
   (base4      '("#9ca0a4" "#9ca0a4" "brightblack"  ))
   (base5      '("#383a42" "#424242" "brightblack"  ))
   (base6      '("#202328" "#2e2e2e" "brightblack"  ))
   (base7      '("#1c1f24" "#1e1e1e" "brightblack"  ))
   (base8      '("#1b2229" "black"   "black"        ))

   (grey       base4)
   ;; red is actually more of a cerise
   (red        '("#ec3b82" "#ff5f87" "magenta"          ))
   (mid-pink    '("#e4a3db" "#e4a3db" "brightmagenta"      ))
   ;; magenta and violet are actually the same dark pink
   (magenta     '("#dd94d9" "#d787d7" "brightmagenta"      ))
   (violet     '("#dd94d9" "#d787d7" "brightmagenta"      ))
   ;; yellow is actually more of a light orange
   (yellow  '("#ff9933" "ff875f" "brightyellow"))
   (orange   '("#fa611f" "#ff5f00" "yellow"    ))
   ;; green is actually more of a light teal
   (green    '("#68af9c" "#5fafaf" "brightgreen"  ))
   (teal     '("#008081" "#008787" "green"        ))
   (blue    '("#557ebd" "#5f87af" "brightblue"   ))
   (dark-blue  '("#2657a7" "#005faf" "blue"         ))
   ;; cyan is actually more of a light blue-purple
   (cyan       '("#557ebd" "#5f87af" "brightcyan"   ))
   ;; dark is actually more of a dark blue-purple
   (dark-cyan  '("#5946b1" "#5f5f5f" "cyan"         ))

   ;; These are the "universal syntax classes" that doom-themes establishes.
   ;; These *must* be included in every doom themes, or your theme will throw an
   ;; error, as they are used in the base theme defined in doom-themes-base.
   (highlight      blue)
   (vertical-bar   (doom-darken base2 0.1))
   (selection      dark-blue)
   (builtin        magenta)
   (comments       (if pastel-brighter-comments mid-pink base4))
   (doc-comments   (doom-darken comments 0.15))
   (constants      violet)
   (functions      magenta)
   (keywords       red)
   (methods        cyan)
   (operators      blue)
   (type           yellow)
   (strings        green)
   (variables      (doom-darken magenta 0.36))
   (numbers        orange)
   (region         `(,(doom-darken (car bg-alt) 0.1) ,@(doom-darken (cdr base0) 0.3)))
   (error          red)
   (warning        yellow)
   (success        green)
   (vc-modified    orange)
   (vc-added       green)
   (vc-deleted     red)

   ;; These are extra color variables used only in this theme; i.e. they aren't
   ;; mandatory for derived themes.
   (modeline-fg              fg)
   (modeline-fg-alt          (doom-blend
                              violet base4
                              (if pastel-brighter-modeline 0.5 0.2)))
   (modeline-bg              (if pastel-brighter-modeline
                                 (doom-darken base2 0.05)
                               base1))
   (modeline-bg-alt          (if pastel-brighter-modeline
                                 (doom-darken base2 0.1)
                               base2))
   (modeline-bg-inactive     (doom-darken bg 0.1))
   (modeline-bg-alt-inactive `(,(doom-darken (car bg-alt) 0.05) ,@(cdr base1)))

   (-modeline-pad
    (when pastel-padded-modeline
      (if (integerp pastel-padded-modeline) pastel-padded-modeline 4))))

  ;;;; Base theme face overrides
  (((font-lock-doc-face &override) :slant 'italic)
   ((line-number &override) :foreground (doom-lighten base4 0.15))
   ((line-number-current-line &override) :foreground base8)
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if pastel-brighter-modeline base8 highlight))
   (shadow :foreground base4)
   (tooltip :background base1 :foreground fg)

   ;;;; centaur-tabs
   (centaur-tabs-unselected :background bg-alt :foreground base4)
   ;;;; css-mode <built-in> / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property             :foreground green)
   (css-selector             :foreground blue)
   ;;;; doom-modeline
   (doom-modeline-bar :background (if pastel-brighter-modeline modeline-bg highlight))
   ;;;; ediff <built-in>
   (ediff-current-diff-A        :foreground red   :background (doom-lighten red 0.8))
   (ediff-current-diff-B        :foreground green :background (doom-lighten green 0.8))
   (ediff-current-diff-C        :foreground blue  :background (doom-lighten blue 0.8))
   (ediff-current-diff-Ancestor :foreground teal  :background (doom-lighten teal 0.8))
   ;;;; helm
   (helm-candidate-number :background blue :foreground bg)
   ;;;; lsp-mode
   (lsp-ui-doc-background      :background base0)
   ;;;; magit
   (magit-blame-heading     :foreground orange :background bg-alt)
   (magit-diff-removed :foreground (doom-darken red 0.2) :background (doom-blend red bg 0.1))
   (magit-diff-removed-highlight :foreground red :background (doom-blend red bg 0.2) :bold bold)
   ;;;; markdown-mode
   (markdown-markup-face     :foreground base5)
   (markdown-header-face     :inherit 'bold :foreground red)
   ((markdown-code-face &override)       :background base1)
   (mmm-default-submode-face :background base1)
   ;;;; outline <built-in>
   ((outline-1 &override) :foreground red)
   ((outline-2 &override) :foreground orange)
   ;;;; org <built-in>
   ((org-block &override) :background base1)
   ((org-block-begin-line &override) :foreground fg :slant 'italic)
   (org-ellipsis :underline nil :background bg     :foreground red)
   ((org-quote &override) :background base1)
   ;;;; posframe
   (ivy-posframe               :background base0)
   ;;;; selectrum
   (selectrum-current-candidate :background base1)
   ;;;; vertico
   (vertico-current :background base1)
   ;;;; solaire-mode
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-alt-inactive
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt-inactive)))
   ;;;; web-mode
   (web-mode-current-element-highlight-face :background dark-blue :foreground bg)
   ;;;; wgrep <built-in>
   (wgrep-face :background base1)
   ;;;; whitespace
   ((whitespace-tab &override)         :background (unless (default-value 'indent-tabs-mode) base0))
   ((whitespace-indentation &override) :background (if (default-value 'indent-tabs-mode) base0)))

  ;;;; Base theme variable overrides-
  ()
  )

;;; pastel-theme.el ends here
