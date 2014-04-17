;;; org-hlc.el --- hidden-lines-cookies for folded Org-mode headlines

;; Copyright (C) 2013 Thorsten Jolitz

;; Author: Thorsten Jolitz <tjolitz at gmail dot com>
;; Keywords: org-mode, outline, visibility, overlays

;; This file is (NOT YET) part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 'hidden-lines-cookies' (hlc) are small cookies at the end of each folded
;; (and visible) headline in an Org-mode buffer that show the number of hidden
;; lines before the next visible headline.

;; hidden-lines-cookies can be handled with three user commands:
;; `org-hlc-show-hidden-lines-cookies', `org-hlc-hide-hidden-lines-cookies',
;; and the convenience command `org-hlc-toggle-hidden-lines-cookies' that
;; toggles between the two other commands conditional on the last one
;; executed.

;; The appearance of the cookies can be customized by changing the values of
;; four customizable variables: `org-hlc-hidden-lines-cookie-left-delimiter'
;; (with default value "["), `org-hlc-hidden-lines-cookie-right-delimiter'
;; (with default value ']), `org-hlc-hidden-lines-cookie-left-signal-char'
;; (with default value "#") and
;; `org-hlc-hidden-lines-cookie-right-signal-char' (with default value "").

;; Thus an exemplary folded headline with 165 hidden lines before the next
;; visible headline might look like this when hidden-lines-cookies are shown:

;; ,-----------------
;; | *** Headline [#165]
;; `-----------------


;;; Requires

(require 'org)

;;; Code:

;;;; Variables

(defvar org-hlc-hidden-lines-cookies-on-p nil
  "If non-nil, hidden-lines cookies are shown, otherwise hidden.")

(defgroup org-hlc nil
  "hidden-line-cookies for Org-mode."
  :prefix "org-hlc-"
  :group 'org)

(defcustom org-hlc-hidden-lines-cookie-left-delimiter "["
  "Left delimiter of cookie that shows number of hidden lines."
  :group 'org-hlc
  :type 'string)

(defcustom org-hlc-hidden-lines-cookie-right-delimiter "]"
  "Left delimiter of cookie that shows number of hidden lines."
  :group 'org-hlc
  :type 'string)

(defcustom org-hlc-hidden-lines-cookie-left-signal-char "#"
  "Left signal character of cookie that shows number of hidden lines."
  :group 'org-hlc
  :type 'string)

(defcustom org-hlc-hidden-lines-cookie-right-signal-char ""
  "Right signal character of cookie that shows number of hidden lines."
  :group 'org-hlc
  :type 'string)

(defvar org-hlc-hidden-lines-cookie-format-regexp
  (concat
   "\\( "
   (regexp-quote org-hlc-hidden-lines-cookie-left-delimiter)
   (regexp-quote org-hlc-hidden-lines-cookie-left-signal-char)
   "\\)"
   "\\([[:digit:]]+\\)"
   "\\("
   (regexp-quote org-hlc-hidden-lines-cookie-right-signal-char)
   ;; FIXME robust enough?
   (format "\\%s" org-hlc-hidden-lines-cookie-right-delimiter)
   "\\)")
  "Matches cookies that show number of hidden lines for folded subtrees.")

;;;; Functions

;; Calc and show line number of hidden body for all visible headlines
(defun org-hlc-write-hidden-lines-cookies ()
  "Show line number of hidden lines in folded headline."
  (save-excursion
    (goto-char (point-min))
    (and (outline-on-heading-p)
         (org-hlc-hidden-lines-cookie-status-changed-p)
         (org-hlc-set-hidden-lines-cookie))
    (while (not (eobp))
      (outline-next-visible-heading 1)
      (and (outline-on-heading-p)
           (org-hlc-hidden-lines-cookie-status-changed-p)
           (org-hlc-set-hidden-lines-cookie)))))


(defun org-hlc-hidden-lines-cookie-status-changed-p ()
  "Return non-nil if hidden-lines cookie needs modification."
  (save-excursion
    (save-match-data
      (or (not (outline-body-visible-p))
          (re-search-forward
           org-hlc-hidden-lines-cookie-format-regexp
           (line-end-position)
           'NO-ERROR)))))

(defun org-hlc-set-hidden-lines-cookie ()
  "Calculate and set number of hidden lines in folded headline."
  (let* ((folded-p (not (outline-body-visible-p)))
         (line-num-current-header (line-number-at-pos))
         (line-num-next-visible-header
          (save-excursion
            (outline-next-visible-heading 1)
            (line-number-at-pos)))
         (body-lines
          (1- (- line-num-next-visible-header line-num-current-header))))
    (if (re-search-forward
         org-hlc-hidden-lines-cookie-format-regexp
         (line-end-position)
         'NO-ERROR)
        (cond
         ((not folded-p) (replace-match ""))
         (folded-p (replace-match (format "%s" body-lines) nil nil nil 2)))
      (show-entry)
      (save-excursion
        (end-of-line)
        (insert
         (format
          " %s%s%s%s%s"
          org-hlc-hidden-lines-cookie-left-delimiter
          org-hlc-hidden-lines-cookie-left-signal-char
          body-lines
          org-hlc-hidden-lines-cookie-right-signal-char
          org-hlc-hidden-lines-cookie-right-delimiter)))
      (hide-entry))))

(defun org-hlc-show-hidden-lines-cookies ()
  "Show hidden-lines cookies for all visible and folded headlines."
  (interactive)
  (org-hlc-write-hidden-lines-cookies)
  (setq org-hlc-hidden-lines-cookies-on-p 1))

(defun org-hlc-hide-hidden-lines-cookies ()
  "Delete all hidden-lines cookies."
  (interactive)
  (let* ((base-buf (point-marker))
         (indirect-buf-name
          (generate-new-buffer-name
           (buffer-name (marker-buffer base-buf)))))
    (clone-indirect-buffer indirect-buf-name nil 'NORECORD)
    (save-excursion
      (switch-to-buffer indirect-buf-name)
      (show-all)
      (let ((indirect-buf (point-marker)))
        (org-hlc-write-hidden-lines-cookies)
        (switch-to-buffer (marker-buffer base-buf))
        (kill-buffer (marker-buffer indirect-buf))
        (set-marker indirect-buf nil))
      (set-marker base-buf nil)))
  (setq org-hlc-hidden-lines-cookies-on-p nil))

(defun org-hlc-toggle-hidden-lines-cookies ()
  "Toggles status of hidden-lines cookies between shown and hidden."
  (interactive)
  (if org-hlc-hidden-lines-cookies-on-p
      (org-hlc-hide-hidden-lines-cookies)
    (org-hlc-show-hidden-lines-cookies)))

;; From `outline-mode-easy-bindings'
;; Copied from: http://emacswiki.org/emacs/OutlineMinorMode

(defun outline-body-visible-p ()
  (save-excursion
    (outline-back-to-heading)
    (outline-end-of-heading)
    (not (outline-invisible-p))))

(provide 'org-hlc)

;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:

;;; org-hlc.el ends here
