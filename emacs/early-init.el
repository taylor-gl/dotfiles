;;; early-init.el --- Runs before the GUI and before package.el -*- lexical-binding: t; -*-

;;; Commentary:

;; Only things that must happen before the first frame is drawn belong here.
;; Chrome set in init.el instead gets drawn and then removed, which is the
;; startup flicker.

;;; Code:

;; I use straight.el for packages, so package.el must not activate anything.
(setq package-enable-at-startup nil)

;; Emacs resizes the frame whenever the font, menu bar, tool bar or fringes
;; change; during startup that is several round-trips to the window manager.
(setq frame-inhibit-implied-resize t)

;; Turn the chrome off through frame parameters rather than through
;; `tool-bar-mode' and friends, so it is never drawn even once.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)

;; Default geometry for new frames, and start the first frame maximized.
(push '(height . 40) default-frame-alist)
(push '(width . 100) default-frame-alist)
(push '(fullscreen . maximized) initial-frame-alist)

;; Keep the mode variables consistent with the frame parameters above, so that
;; toggling them later behaves the way you'd expect.
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; No startup screen or echo-area blurb.  `inhibit-startup-echo-area-message'
;; only works when it holds your login name -- setting it to t does nothing.
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-splash-screen t
      inhibit-startup-echo-area-message (user-login-name))

;; Don't garbage collect at all while starting up; init.el lowers this to a
;; normal working value once startup is finished.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Async native compilation starts from a pristine environment, so it warns
;; about functions third-party packages only call behind a successful `require'.
;; `silent' still logs to *Warnings*, it just stops the buffer popping up.
(setq native-comp-async-report-warnings-errors 'silent)

;;; early-init.el ends here
