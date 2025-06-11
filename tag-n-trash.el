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

;;; tag-n-trash.el --- Highlight and clean up debug code -*- lexical-binding: t; -*-

(defface tag-n-trash-highlight-face
  '((t :inherit font-lock-warning-face :foreground "#ff6c6b" :weight bold :extend t))
  "Face for trash block."
  :group 'tag-n-trash)

(defvar tag-n-trash--keywords
  '(("^\\s-*# BEGIN_TRASH\\(\\(.\\|\n\\)*?\\)# END_TRASH\\s-*$"
     (0 'tag-n-trash-highlight-face prepend)))
  "Font-lock keywords used to highlight trash code blocks.")


(defun tag-n-trash--setup-highlighting ()
  "Add font-lock highlighting for trash blocks."
  (font-lock-add-keywords nil tag-n-trash--keywords 'append))

(defun tag-n-trash--remove-highlighting ()
  "Remove font-lock highlighting for trash blocks."
  (font-lock-remove-keywords nil tag-n-trash--keywords))



;;;###autoload
(defun tag-n-trash-empty-block ()
  "Insert a # BEGIN_TRASH / # END_TRASH block and place point inside."
  (interactive)
  (let ((indent (current-indentation)))
    (insert (make-string indent ?\s) "# BEGIN_TRASH\n")
    (insert (make-string indent ?\s) "\n")
    (insert (make-string indent ?\s) "# END_TRASH\n")
    (forward-line -2)
    (end-of-line)))

;;;###autoload
(defun tag-n-trash-cleanup ()
  "Remove all # BEGIN_TRASH to # END_TRASH blocks in the buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\s-*# BEGIN_TRASH\\s-*$" nil t)
      (let ((begin (match-beginning 0)))
        (if (re-search-forward "^\\s-*# END_TRASH\\s-*$" nil t)
            (let ((end (match-end 0)))
              ;; Delete the region from BEGIN to END, including both lines
              (delete-region begin (1+ end))) ; 1+ to delete trailing newline
          (message "No matching # END_TRASH found"))))))


;;;###autoload
(define-minor-mode tag-n-trash-mode
  "Minor mode to highlight and manage trash/debug code."
  :lighter " 🗑"
  (if tag-n-trash-mode
      (progn
        (tag-n-trash--setup-highlighting)
        (font-lock-flush)
        (font-lock-ensure))
    (tag-n-trash--remove-highlighting)
    (font-lock-flush)
    (font-lock-ensure)))

(provide 'tag-n-trash)
;;; tag-n-trash.el ends here
