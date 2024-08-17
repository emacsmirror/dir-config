;;; test-dir-config.el --- Test dir-config -*- lexical-binding: t; -*-

;; Copyright (C) 2024 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti
;; Version: 0.9.9
;; URL: https://github.com/jamescherti/dir-config.el
;; Keywords: convenience
;; Package-Requires: ((emacs "24.1"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; Test the `dir-config' package.

;;; Code:

(require 'dir-config)

(defvar test-dir-config-successful nil)
(defvar test-dir-config-successful2 nil)
(defvar test-dir-config-code-buffer nil)

(defun test-dir-config--reset ()
  (when test-dir-config-code-buffer
    (kill-buffer test-dir-config-code-buffer)
    (setq test-dir-config-code-buffer nil))

  (setq dir-config-allowed-directories nil)
  (setq test-dir-config-successful nil)
  (setq test-dir-config-successful2 nil))

(defun test-dir-config ()
  "Test dir-config."
  (interactive)
  (let* ((base-dir (expand-file-name "~/test-dir-config"))
         (dir-config-file (expand-file-name ".dir-config.el" base-dir))

         (src-dir (expand-file-name "src" base-dir))
         (src-dir-config-file (expand-file-name ".dir-config.el" src-dir))

         (code-dir (expand-file-name "code" src-dir))
         (code-file (expand-file-name "file.py" code-dir)))
    (setq dir-config-file-names '(".dir-config.el"))
    ;; Prerequisites
    (when (file-exists-p base-dir)
      (error "The directory '%s' should not exist" base-dir))
    (make-directory code-dir t)
    (global-dir-config-mode 1)
    (with-temp-buffer
      (insert "(setq test-dir-config-successful t)\n")
      (write-file dir-config-file))
    (with-temp-buffer
      (insert "#!/usr/bin/env python\n")
      (insert "print('Hello world')\n")
      (write-file code-file))

    ;; Test
    (message "Test 1")
    (setq test-dir-config-code-buffer (find-file-noselect code-file))
    (unless test-dir-config-code-buffer
      (error "The buffer was not created: %s" code-file))
    (when (bound-and-true-p test-dir-config-successful)
      (error "The file '%s' was not supposed to be loaded (not allowed)"
             dir-config-file))

    ;; Test
    (message "Test 2")
    (test-dir-config--reset)
    (setq dir-config-allowed-directories (list base-dir))
    (setq test-dir-config-code-buffer (find-file-noselect code-file))
    (unless (bound-and-true-p test-dir-config-successful)
      (error "The file '%s' was supposed to be loaded because it was allowed"
             dir-config-file))

    ;; Test
    (message "Test 3")
    (test-dir-config--reset)
    (setq dir-config-allowed-directories (list src-dir))
    (setq test-dir-config-code-buffer (find-file-noselect code-file))
    (when (bound-and-true-p test-dir-config-successful)
      (error "The file '%s' was not supposed to be loaded (not allowed)"
             dir-config-file))

    ;; Test
    (message "Test 4")
    (test-dir-config--reset)
    (setq dir-config-allowed-directories (list src-dir))
    (with-temp-buffer
      (insert "(setq test-dir-config-successful2 t)\n")
      (write-file src-dir-config-file))
    (setq test-dir-config-code-buffer (find-file-noselect code-file))
    (when (bound-and-true-p test-dir-config-successful)
      (message "[DEBUG] Loaded: " dir-config--file)
      (error "The file '%s' was not supposed to be loaded"
             dir-config-file))
    (unless (bound-and-true-p test-dir-config-successful2)
      (message "[DEBUG] Loaded: " dir-config--file)
      (error "The file '%s' was supposed to be loaded"
             src-dir-config-file))))

(provide 'test-dir-config)
;;; test-dir-config.el ends here