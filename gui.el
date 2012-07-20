;;; -*- lexical-binding: t -*-

;; Color themes and graphical embellishment

;; show lines after end of buffer
(setq indicate-empty-lines t)

(defvar bw-after-frame-raise-hook '()
  "Hook called after a frame is raised. Functions receive a
  single arg, which is the frame that was raised.")

;; Theme files
(setq theme-dotfiles-dir (file-name-as-directory (concat dotfiles-dir "vendor/themes/")))
(make-directory theme-dotfiles-dir t)

;; load all custom themes
(defun load-custom-themes ()
  "Adds custom themes directory to themefiles"
  (interactive)
  (let ((base theme-dotfiles-dir))
    (add-to-list 'custom-theme-load-path base)
    (dolist (f (directory-files base))
      (let ((name (concat base "/" f)))
        (when (and (file-directory-p name)
                   (not (equal f ".."))
                   (not (equal f ".")))
          (add-to-list 'custom-theme-load-path name))))))

(load-custom-themes)

;; From:
;; http://emacs-fu.blogspot.co.uk/2011/01/setting-frame-title.html
(setq frame-title-format
      '("emacs@" (:eval (system-name)) ": "
        (:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(when (display-graphic-p)
  ;; show help in the echo area instead of as a tooltip
  (tooltip-mode -1)
  ;; make fringe-mode 4 pixels
  (fringe-mode 4)
  ;; blink the cursor
  (setq blink-cursor-interval 1.0)
  (blink-cursor-mode))

;; stop beeping at me
(setq visible-bell t)

;; if we do use line numbers, format them
(setq linum-format " %d ")
