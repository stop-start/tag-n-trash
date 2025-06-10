;;; tag-n-trash.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Elinor Natanzon
;;
;; Author: Elinor Natanzon <stop.start.dev@gmail.com>
;; Maintainer: Elinor Natanzon <stop.start.dev@gmail.com>
;; Created: June 10, 2025
;; Modified: June 10, 2025
;; Version: 0.1
;; Keywords: convenience, tools
;; Homepage: https://gitlab.com/stop.start/tag-n-trash
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.

;;; Commentary:

;;;; tag-n-trash-mode allows you to visually mark and highlight temporary or debug
;; code (like `print` statements or test scaffolding) and clean them up easily.
;;
;; - Use `;; TRASH:` at the beginning of a line for single-line marks.
;; - Use `#<trash>` and `#</trash>` for multi-line blocks.
;;
;; All marked code is highlighted, and `tag-n-trash-cleanup` will delete it.

;;; Code:

(defgroup tag-n-trash nil
  "Highlight and manage temporary trash/debug code."
  :group 'convenience)

(defface tag-n-trash-face
  '((t :inherit font-lock-comment-face :foreground "#ff6c6b" :weight bold))
  "Face for trash-marked code."
  :group 'tag-n-trash)

(defvar tag-n-trash--font-lock-keywords
  '(("^[ \t]*;;[ \t]*TRASH:.*$" . 'tag-n-trash-face)
    ("^[ \t]*#<trash>.*$" . 'tag-n-trash-face)
    ("^[ \t]*#</trash>.*$" . 'tag-n-trash-face)
    ("^[ \t]*\\(.*\\)$"
     (0 (when (and (boundp 'tag-n-trash--in-block)
                   tag-n-trash--in-block)
          'tag-n-trash-face))))
  "Font-lock rules for `tag-n-trash-mode`.")

(defvar-local tag-n-trash--in-block nil
  "Internal flag for tracking if inside a trash block.")

(defun tag-n-trash--update-block-state ()
  "Update font-lock state for trash block."
  (save-excursion
    (goto-char (point-min))
    (setq tag-n-trash--in-block nil)
    (while (re-search-forward "^.*$" nil t)
      (let ((line (match-string 0)))
        (cond
         ((string-match-p "^[ \t]*#<trash>" line)
          (setq tag-n-trash--in-block t))
         ((string-match-p "^[ \t]*#</trash>" line)
          (setq tag-n-trash--in-block nil)))))))

;;;###autoload
(define-minor-mode tag-n-trash-mode
  "Highlight and manage temporary trash/debug code."
  :lighter " 🗑"
  :group 'tag-n-trash
  (if tag-n-trash-mode
      (progn
        (add-hook 'after-change-functions #'tag-n-trash--after-change nil t)
        (tag-n-trash--update-block-state)
        (font-lock-add-keywords nil tag-n-trash--font-lock-keywords 'append)
        (font-lock-flush))
    (remove-hook 'after-change-functions #'tag-n-trash--after-change t)
    (font-lock-remove-keywords nil tag-n-trash--font-lock-keywords)
    (font-lock-flush)))

(defun tag-n-trash--after-change (_beg _end _len)
  "Update block state after changes."
  (when tag-n-trash-mode
    (tag-n-trash--update-block-state)
    (font-lock-flush)))

;;;###autoload
(defun tag-n-trash-cleanup ()
  "Remove all lines marked as trash."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((case-fold-search nil))
      (while (re-search-forward "^[ \t]*;;[ \t]*TRASH:.*$" nil t)
        (replace-match ""))
      (goto-char (point-min))
      (while (re-search-forward "^[ \t]*#<trash>\\(.*\n\\)*?[ \t]*#</trash>.*$" nil t)
        (replace-match "")))))

(provide 'tag-n-trash)
;;; tag-n-trash.el ends here
