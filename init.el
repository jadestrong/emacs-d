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

;; Basic paths and variables other things need
(require 'init-utils)
(require 'init-paths)

;; use-package - used in other places
(require 'init-use-package)

(require 'init-editing)
(require 'init-interface)

(use-package init-window-gui
             :if (display-graphic-p))
(use-package init-osx
             :if *is-a-mac*)
(use-package init-linux
             :if *is-linux*)

;; Modes
(require 'init-ido)

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

;; start a server, unless one is already running
(require 'server)
(unless (server-running-p)
  (server-start))
