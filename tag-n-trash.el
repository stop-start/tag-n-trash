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
;; Package-Requires: ((emacs "25.1"))
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

;;; tag-n-trash.el --- Highlight temporary or debug code for deletion -*- lexical-binding: t; -*-

(defgroup tag-n-trash nil
  "Highlight and manage temporary trash/debug code."
  :group 'convenience)

(defface tag-n-trash-face
  '((t :inherit font-lock-comment-face :foreground "#ff6c6b" :weight bold))
  "Face for trash-marked code."
  :group 'tag-n-trash)

(defun tag-n-trash--match-block (limit)
  "Match block of code between #<trash> and #</trash> up to LIMIT."
  (when (re-search-forward "^[ \t]*#<trash>" limit t)
    (let ((start (match-beginning 0)))
      (if (re-search-forward "^[ \t]*#</trash>" limit t)
          (let ((end (match-end 0)))
            (set-match-data (list start end))
            t)
        nil))))

(defvar tag-n-trash--font-lock-keywords
  '(("^[ \t]*\\(?:;;\\|#\\|//\\)[ \t]*TRASH:.*$" . 'tag-n-trash-face)
    (tag-n-trash--match-block . 'tag-n-trash-face)))

;;;###autoload
(define-minor-mode tag-n-trash-mode
  "Highlight and manage temporary trash/debug code."
  :lighter " 🗑"
  :group 'tag-n-trash
  (if tag-n-trash-mode
      (progn
        ;; Remove problematic stateful hooks
        ;; Add font-lock rules only
        (font-lock-add-keywords nil tag-n-trash--font-lock-keywords 'append)
        (font-lock-flush))
    (font-lock-remove-keywords nil tag-n-trash--font-lock-keywords)
    (font-lock-flush)))


;;;###autoload
(defun tag-n-trash-cleanup ()
  "Remove all lines marked as trash."
  (interactive)
  (save-excursion
    ;; Remove single-line TRASH comments
    (goto-char (point-min))
    (while (re-search-forward "^[ \t]*;;[ \t]*TRASH:.*$" nil t)
      (replace-match ""))

    ;; Remove blocks from #<trash> to #</trash>
    (goto-char (point-min))
    (while (re-search-forward "^[ \t]*#<trash>" nil t)
      (let ((start (match-beginning 0)))
        (when (re-search-forward "^[ \t]*#</trash>" nil t)
          (let ((end (line-end-position)))
            (delete-region start (min (point-max) (1+ end)))))))))


(provide 'tag-n-trash)
;;; tag-n-trash.el ends here
