;;; golint.el --- lint for the Go source code

;; Copyright 2013 The Go Authors. All rights reserved.
;; Use of this source code is governed by a BSD-style
;; license that can be found in the LICENSE file.

;; URL: https://github.com/golang/lint

;;; Commentary:

;; To install golint, add the following lines to your .emacs file:
;;   (add-to-list 'load-path "PATH CONTAINING golint.el" t)
;;   (require 'golint)
;;
;; After this, type M-x golint on Go source code.
;; You can also auto invoke golint after save by adding the
;; following into .emacs file:
;;   (add-hook 'after-save-hook 'golint)
;;
;; Usage:
;;   C-x `
;;     Jump directly to the line in your code which caused the first message.
;; 
;;   For more usage, see Compilation-Mode:
;;     http://www.gnu.org/software/emacs/manual/html_node/emacs/Compilation-Mode.html

;;; Code:
(require 'compile)

(defun go-lint-buffer-name (mode) 
 "*Golint*") 

(defun golint-process-setup ()
  "Setup compilation variables and buffer for `golint'."
  (run-hooks 'golint-setup-hook))

(defun close-if-no-error (compilation-buffer process-result)
  "close the golint buffer if no error was found"
  (interactive)
  (when (and
         (string-match "*golint*" (buffer-name compilation-buffer))
         (string-match "finished" process-result))
    (setq err_count 0)
    (condition-case nil
        (while t
          (next-error)
          (setq err_count (+ err_count 1))
          )
      (error nil))
    (when (eq err_count 0)
      (kill-buffer "*golint*")
      )
    )
  )

(define-compilation-mode golint-mode "golint"
  "Golint is a linter for Go source code."
  (set (make-local-variable 'compilation-scroll-output) nil)
  (set (make-local-variable 'compilation-disable-input) t)
  (set (make-local-variable 'compilation-process-setup-function)
       'golint-process-setup)
  (set (make-local-variable 'compilation-finish-functions)
       'close-if-no-error)

)

;;;###autoload
(defun golint ()
  "Run golint on the current file and populate the fix list. Pressing C-x ` will jump directly to the line in your code which caused the first message."
  (interactive)
  (if (eq major-mode 'go-mode)
      (compilation-start
       (mapconcat #'shell-quote-argument
                  (list "golint" (expand-file-name buffer-file-name)) " ")
       'golint-mode)))

(provide 'golint)

;;; golint.el ends here
