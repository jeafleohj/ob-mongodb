;;; ob-mongodb.el --- Babel Functions for Mongodb  -*- lexical-binding: t; -*-

;; Copyright (C)

;; Author: Jhony Angulo
;; Keywords: literate programming, reproducible research
;; Homepage: https://orgmode.org
;; Version: 0.01

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Simple code block that looks like e.g.
;;
;; #+begin_src mongodb
;; test
;; #+end_src


;;; Requirements:

;; Use this section to list the requirements of this language.  Most
;; languages will require that at least the language be installed on
;; the user's system, and the Emacs major mode relevant to the
;; language be installed as well.

;;; Code:
(require 'ob)
(require 'ob-eval)

(defconst org-babel-header-args:mongodb
  '((dbhost     . :any)
    (dbport     . :any)
    (dbuser     . :any)
    (dbpassword . :any)
    (database   . :any))
  "MongoDB-specific header arguments.")

;; optionally define a file extension for this language
(add-to-list 'org-babel-tangle-lang-exts '("mongodb" . "js"))

;; optionally declare default header arguments for this language
(defvar org-babel-default-header-args:mongodb '())

(defun org-babel-sql-dbstring-mongodb (host port user password database)
  "Make mongosh command line args for database connection.
`mongosh' is the preferred command line tool."
  (mapconcat #'identity
             (delq nil
                   (list "mongosh"
                         "--quiet"
                         (when host (format "--host \"%s\"" host))
                         (when port (format "--port \"%s\"" port))
                         (when user (format "--username \"%s\"" user))
                         (when password (format "--password \"%s\"" password))
                         (when database (format "\"%s\"" database))))
             " "))

(defun org-babel-execute:mongodb (body params)
  "Execute a block of Mongodb code with org-babel.
This function is called by `org-babel-execute-src-block'"
  ;; This was added for me to understand org eval functionality
  ;; (message (format "%S" params))
  (let* ((result-params (assq :result-params params))
         (dbhost (cdr (assq :dbhost params)))
         (dbport (cdr (assq :dbport params)))
         (dbuser (cdr (assq :dbuser params)))
         (dbpassword (cdr (assq :dbpassword params)))
         (database (cdr (assq :database params))))

    (with-temp-buffer
      (insert
       (org-babel-eval
        (org-babel-sql-dbstring-mongodb dbhost dbport dbuser dbpassword database)
        body))
      (replace-regexp ".+> " "" nil 0 (point-max))
      (buffer-string))))

(eval-after-load "org"
  '(add-to-list 'org-src-lang-modes '("mongodb" . js)))

(provide 'ob-mongodb)
;;; ob-mongodb.el ends here
