;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; $Id$
;;; Copyright (C) 1994, 1995 Free Software Foundation, Inc.
;;; Written by Sergey Poznyakoff.
;;; 
;;; This file is part of Cflow.
;;;  
;;; Cflow is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 1, or (at your option) any later 
;;; version.
;;;
;;; Cflow is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with cflow; see the file COPYING.  If not, write to the Free
;;; Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'cflow)

(defvar cflow-mode-map (make-sparse-keymap)
  "Keymap used in Cflow mode.")

(define-key cflow-mode-map "f" 'cflow-find-function)
(define-key cflow-mode-map "r" 'cflow-recursion-root)
(define-key cflow-mode-map "n" 'cflow-recursion-next)
(define-key cflow-mode-map "\C-t\C-d" 'cflow-goto-direct-tree)
(define-key cflow-mode-map "\C-t\C-r" 'cflow-goto-reverse-tree)
(define-key cflow-mode-map "x" 'cflow-goto-expand)

(define-key cflow-mode-map [menu-bar] (make-sparse-keymap))

(define-key cflow-mode-map [menu-bar cflow]
  (cons "Cflow" (make-sparse-keymap "Cflow")))

(define-key cflow-mode-map [menu-bar cflow cflow-recursion-next]
  '("Recursion next" . cflow-recursion-next))
(define-key cflow-mode-map [menu-bar cflow cflow-recursion-root]
  '("Recursion root" . cflow-recursion-root))
(define-key cflow-mode-map [menu-bar cflow cflow-goto-expand]
  '("Find expansion" . cflow-goto-expand))
(define-key cflow-mode-map [menu-bar cflow cflow-find-function]
  '("Find function" . cflow-find-function))
(define-key cflow-mode-map [menu-bar cflow cflow-goto-reverse-tree]
  '("Reverse call tree" . cflow-goto-reverse-tree))
(define-key cflow-mode-map [menu-bar cflow cflow-goto-direct-tree]
  '("Direct call tree" . cflow-goto-direct-tree))


(defun cflow-mode ()
  "Major mode for Cflow output files
Key bindings are:
     C-t C-d      Direct tree
     C-t C-r      Reverse tree
     f            Find function
     r            Go to recursion root
     n            Go to next recursive call
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map cflow-mode-map)
  (setq major-mode 'cflow-mode)
  (setq mode-name "Cflow")
  (make-variable-buffer-local 'cflow-recursion-root-line)
  (set-default 'cflow-recursion-root-line nil)
)

;; Find the function under cursor.
;; Switch to the proper buffer and go to the function header
(defun cflow-find-function ()
  (interactive)
  (let ((lst (cflow-find-default-function)))
    (cond
     (lst
      (switch-to-buffer (find-file-noselect (car lst)))
      (goto-line (car (cdr lst))))
     (t
      (error "No source/line information for this function.")))))

;; Parse a cflow listing line
;; Return (list SOURCE-NAME LINE-NUMBER)
(defun cflow-find-default-function ()
  (save-excursion
    (cond
     ((re-search-forward "\\([^ \t:]+\\):\\([0-9]+\\)"
			 (save-excursion (end-of-line) (point))
			 t)
      (list
       (buffer-substring (match-beginning 1) (match-end 1))
       (string-to-number (buffer-substring (match-beginning 2) (match-end 2)))))
     (t
      nil))))

;; If the cursor stays on a recursive call, then go to the root of
;; this call
(defun cflow-recursion-root ()
  (interactive)
  (let ((num (cond
	      ((save-excursion
		 (re-search-forward "(recursive: see \\([0-9]+\\))"
				    (save-excursion (end-of-line) (point))
				    t))
	       (string-to-number
		(buffer-substring (match-beginning 1) (match-end 1))))
	      (t
	       0))))
    (cond
     ((> num 0)
      (push-mark)
      (goto-line num))
     (t
      (error "Not a recursive call")))))

;; Go to next recursive call
(defun cflow-recursion-next ()
  (interactive)
  (save-excursion
    (cond
     ((re-search-forward "(R)"
			(save-excursion (end-of-line) (point))
			t)
     (setq cflow-recursion-root-line (count-lines 1 (point))))))
  (cond
   ((null cflow-recursion-root-line)
    (error "No recursive functions %d"))
   (t
    (let ((pos (save-excursion
		 (next-line 1)
		 (re-search-forward
		  (concat "(recursive: see "
			  (number-to-string cflow-recursion-root-line)
			  ")")
		  (point-max)
		  t))))
      (cond
       ((null pos)
	(goto-line cflow-recursion-root-line)
	(error "no more calls."))
       (t
	(push-mark)
	(goto-char pos)
	(beginning-of-line)))))))

(defun cflow-goto-expand ()
  (interactive)
  (let ((num (cond
	      ((save-excursion
		 (re-search-forward "\\[see \\([0-9]+\\)\\]"
				    (save-excursion (end-of-line) (point))
				    t))
		 (string-to-number
		  (buffer-substring (match-beginning 1) (match-end 1))))
	       (t
		0))))
    (cond
     ((> num 0)
      (push-mark)
      (goto-line num))
     (t
      (error "not expandable")))))


(defun cflow-goto-direct-tree ()
  (interactive)
  (let ((pos (save-excursion
	       (beginning-of-buffer)
	       (search-forward "Direct Tree:"
				(point-max)
				t))))
    (cond
     ((null pos)
      (error "No direct tree in this file?"))
     (t
      (goto-char pos)
      (recenter 0)
      (beginning-of-line)))))

(defun cflow-goto-reverse-tree ()
  (interactive)
  (let ((pos (save-excursion
	       (beginning-of-buffer)
	       (search-forward "Reverse Tree:"
			       (point-max)
			       t))))
    (cond
     ((null pos)
      (error "No reverse tree in this file?"))
     (t
      (goto-char pos)
      (recenter 0)
      (beginning-of-line)))))





