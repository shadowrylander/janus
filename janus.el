;;; janus.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Put a description of the package here

;;; Code:

(require 'cl-lib)
(require 's)
(require 'dash)

(defvar meq/aliases '(
    :orange (orange flamingo-pink)))

(defvar meq/modes '(
    :light '()
    :dark '()))

(mapc #'(lambda (alias) (interactive)
        (mapc #'(lambda (color) (interactive)
            (push color (plist-get meq/modes :light))) (plist-get meq/aliases alias))) '(
    :orange))

(mapc #'(lambda (alias) (interactive)
        (mapc #'(lambda (color) (interactive)
            (push color (plist-get meq/modes :dark))) (plist-get meq/aliases alias))) '(
    ))

(defvar meq/faces `(
    ;; Adapted From: http://ergoemacs.org/emacs/elisp_define_face.html
    (flamingo-pink . (:alternate ((((class color) (background light))
                                    :foreground "#ab5dee" :bold t)
                                    (((class color) (background dark))
                                    :foreground "#fca78e" :bold t))
                    :original ((t (:foreground "#fca78e" :bold t)))
                    :aliases ,(plist-get meq/aliases :orange)))
    (orange . (:alternate ((((class color) (background light))
                                    :foreground "#ab5dee" :bold t)
                                    (((class color) (background dark))
                                    :foreground "#ffb86c" :bold t))
                    :original ((t (:foreground "#ffb86c" :bold t)))
                    :aliases ,(plist-get meq/aliases :orange)))))

;;;###autoload
(defmacro meq/set-alternate-color (color) (interactive)
    (face-spec-set
        (intern (concat "meq/" (symbol-name color)))
        (plist-get (cdr (assq color meq/faces)) :alternate)
        'face-defface-spec))

;;;###autoload
(defmacro meq/set-original-color (color) (interactive)
    (face-spec-set
        (intern (concat "meq/" (symbol-name color)))
        (plist-get (cdr (assq color meq/faces)) :original)
        'face-defface-spec))

;;;###autoload
(defun meq/same-color-switch (name mode) (interactive)
    (mapc #'(lambda (color) (interactive)
        (let* ((contains-list (mapcar #'(lambda (alias) (interactive)
            (and
                (s-contains? (symbol-name alias) name)
                (member alias (plist-get
                                meq/modes
                                (intern (concat ":" mode)))))) (plist-get (cdr color) :aliases))))
        (if (--any? (and it t) contains-list)
            (eval `(meq/set-alternate-color ,(car color)))
            (eval `(meq/set-original-color ,(car color)))))) meq/faces))

;; (mapc #'(lambda (color) (interactive)
;;     (eval `(defface
;;         ,(intern (concat "meq/" (symbol-name (car color))))
;;         ',(plist-get (cdr color) :original)
;;         ,(symbol-name (car color))))) meq/faces)

(mapc #'(lambda (color) (interactive)
    `(face-spec-set
        ,(intern (concat "meq/" (symbol-name (car color))))
        ',(plist-get (cdr color) :original)
        'face-defface-spec)) meq/faces)

;;;###autoload
(defun meq/load-theme (theme) (interactive)
    (let* ((name (symbol-name theme))
            (mode (car (last (split-string name "-")))))
        (setq current-theme theme)
        (setq current-theme-mode mode)
        (meq/same-color-switch name mode)
        (load-theme theme)))

;;;###autoload
(defun meq/which-theme nil (interactive)
    (when (member "--theme" command-line-args)
        (meq/load-theme (intern (concat
            (nth (1+ (seq-position command-line-args "--theme")) command-line-args)
            (if (member "--light" command-line-args) "-light" "-dark"))))))

;;;###autoload
(defun meq/switch-theme-mode nil (interactive)
    (meq/load-theme (intern (concat
        (replace-regexp-in-string "-dark" "" (replace-regexp-in-string "-light" "" (symbol-name current-theme)))
        "-"
        (if (string= current-theme-mode "light") "dark" "light")))))

(provide 'janus)
;;; janus.el ends here
