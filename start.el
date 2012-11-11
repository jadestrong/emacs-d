;;; -*- lexical-binding: t -*-

;; cl seems to be used by everything
(require 'cl)

;;; general global variables for configuration

;; base load path
(defconst dotfiles-dir
  (file-name-directory
   (or (buffer-file-name) load-file-name))
  "Base path for customised Emacs configuration")

(add-to-list 'load-path dotfiles-dir)

;; What OS/window system am I using?

;; Adapted from:
;; https://github.com/purcell/emacs.d/blob/master/init.el
(defconst *is-a-mac*
  (eq system-type 'darwin)
  "Is this running on OS X?")

(defconst *is-carbon-emacs*
  (and *is-a-mac* (eq window-system 'mac))
  "Is this the Carbon port of Emacs?")

(defconst *is-cocoa-emacs*
  (and *is-a-mac* (eq window-system 'ns))
  "Is this the Cocoa version of Emacs?")

(defconst *is-linux*
  (eq system-type 'gnu/linux)
  "Is this running on Linux?")

;;; custom elisp
(defun bw-add-to-load-path (dir)
  "Adds `dir` to load-path"
  (add-to-list 'load-path dir))

(defun bw-join-dirs (prefix suffix)
  "Joins `prefix` and `suffix` into a directory"
  (file-name-as-directory (concat prefix suffix)))

;;; load path stuff

;; external libraries I might have collected via submodules etc.
(defconst vendor-dotfiles-dir
  (bw-join-dirs dotfiles-dir "vendor")
  "Vendorised Emacs libraries")

(bw-add-to-load-path vendor-dotfiles-dir)

;;; general editing configuration

;; Turn off mouse interface early in startup to avoid momentary flash
;; of things I don't want.
(progn
  (dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
    (when (fboundp mode) (funcall mode -1))))

;; Don't show the splash screen
(setq inhibit-startup-screen t
      ;; Show the *scratch* on startup
      initial-buffer-choice t)

;; I got sick of typing "yes"
(defalias 'yes-or-no-p 'y-or-n-p)

;; I prefer spaces over tabs
(setq-default
 indent-tabs-mode nil
 ;; ... and I prefer 4-space indents
 tab-width 4)

;; UTF-8 please!
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Don't clobber things in the system clipboard when killing
(setq save-interprogram-paste-before-kill t)

;; nuke trailing whitespace when writing to a file
(add-hook 'write-file-hooks 'delete-trailing-whitespace)

;;; global interface changes

;; always highlight syntax
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;; Highlight matching parentheses
(show-paren-mode 1)
(setq show-paren-style 'parenthesis)

;; show keystrokes
(setq echo-keystrokes 0.1)

;; Always show line number in the mode line
(line-number-mode 1)
;; ... and show the column number
(column-number-mode 1)

;; Show bell
(setq visible-bell t)

;; start a server, unless one is already running
(require 'server)
(unless (server-running-p)
  (server-start))

;;; global GUI changes for window systems
(when (display-graphic-p)
  (progn
    (message "Loading window GUI config")

    ;; show help in the echo area instead of as a tooltip
    (tooltip-mode -1)

    ;; blink the cursor
    (setq blink-cursor-interval 1.0)
    (blink-cursor-mode)

    ;; indicate EOF empty lines in the gutter
    (setq indicate-empty-lines t)))

;;; Mac-specific stuff
(when *is-a-mac*
  (progn
    (message "Loading Mac config")

    ;; Mac hostnames have .local or similar appended
    (setq system-name (car (split-string system-name "\\.")))

    ;; OS X ls doesn't support --dired
    (setq dired-use-ls-dired nil)

    ;; Even though we may have set the Mac OS X Terminal's Alt key as the
    ;; emacs Meta key, we want to be able to insert a '#' using Alt-3 in
    ;; emacs as we would in other programs.
    (fset 'insert-pound "#")
    (define-key global-map "\M-3" 'insert-pound)

    (when (or *is-carbon-emacs*
	      *is-cocoa-emacs*)
      (progn
        (message "Loading Mac GUI config")
        ;; Mac GUI stuff
        ;; set my favourite Mac font as the default font
        (set-face-attribute 'default nil :foundry "apple"
                            :family "Inconsolata" :height 160)
        ;; (set-face-attribute 'default nil :foundry "adobe"
        ;;                     :family "Source Code Pro" :height 150)

        ;; meta key configuration

        ;; This makes left-option do M-
        (setq ns-alternate-modifier 'meta)
        ;; ... and right-option just do option.
        (setq ns-right-alternate-modifier nil)

        ;; command is super
        (setq ns-command-modifier 'super)
        ;; fn does nothing special for Emacs
        (setq ns-function-modifier 'nil)))))

;;; Linux stuff
(when *is-linux*
  (progn
    (message "Loading Linux config")))

;;; Modes

;; IDO mode
(message "Loading IDO mode")
(ido-mode t)
(ido-everywhere t)

(setq
 ;; Match arbitrary points in strings
 ido-enable-prefix nil
 ;; Match across entire string
 ido-enable-flex-matching t
 ;; Create a new buffer if there's no match candidate
 ido-create-new-buffer 'always
 ;; Don't try and guess if the string under point is a file
 ido-use-filename-at-point nil
 ;; case-insensitive matching
 ido-case-fold t)

;; TRAMP mode
(eval-after-load 'tramp
  '(progn
     (message "Loading TRAMP mode")
     ;; use SSH by default
     (setq tramp-default-method "ssh")
     ;; allow me to SSH to hosts and edit as sudo like:
     ;;   C-x C-f /sudo:example.com:/etc/something-owned-by-root
     ;; from: http://www.gnu.org/software/tramp/#Multi_002dhops
     (add-to-list 'tramp-default-proxies-alist
                  '(nil "\\`root\\'" "/ssh:%h:"))
     (add-to-list 'tramp-default-proxies-alist
                  '((regexp-quote (system-name)) nil nil))))

;; ediff mode
(eval-after-load 'ediff
  '(progn
     (message "Loading ediff mode")
     (setq
      ;; make two side-by-side windows
      ediff-split-window-function 'split-window-horizontally
      ;; ignore whitespace diffs
      ediff-diff-options          "-w"
      ;; Do everything in one frame always
      ediff-window-setup-function 'ediff-setup-windows-plain)))

;; uniquify mode
(message "Loading uniquify configuration")
(require 'uniquify)
;; this shows foo/bar and baz/bar when two files are named bar
(setq uniquify-buffer-name-style 'forward)
;; strip common buffer suffixes
(setq uniquify-strip-common-suffix t)
;; re-uniquify buffer names after killing one
(setq uniquify-after-kill-buffer-p t)

;;; Global keyboard combinations

;; map M-x to C-x C-m and C-c C-m, because M-x is in an awkward spot
(global-set-key (kbd "C-x C-m") 'execute-extended-command)
(global-set-key (kbd "C-c C-m") 'execute-extended-command)
;; Unset GNUs since it clashes with above and I don't use it
(global-unset-key (kbd "C-x m"))
;; unset M-x due to above
(global-unset-key (kbd "M-x"))

;; Use hippie-expand instead of dabbrev
(global-set-key (kbd "M-/") 'hippie-expand)

;; Copy readline's kill word
(global-set-key (kbd "C-w") 'backward-kill-word)
;; Since we've unset C-w, map it to something else
(global-set-key (kbd "C-x C-k") 'kill-region)
;; ... and the clumsy version
(global-set-key (kbd "C-c C-k") 'kill-region)

(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)
