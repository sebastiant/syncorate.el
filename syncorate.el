;;; syncorate.el --- Emacs client interface for Syncorate

;; Author: Sebastian Tunstig <sebastian.tunstig@gmail.com>
;; Version: 1.0.0

;; Homepage: https://github.com/sebastiant/syncorate.el

;; Keywords: productivity gtd

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; Syncorate is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details
;;
;; You should have received a copy of the GNU General Public License
;; along with Syncorate.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;; Syncorate is an Emacs interface for the Syncorate service, see
;;; <https://syncorate.com/> for more information about the service.
;;; Functionality is limited to starting new Focus sessions as well as
;;; Displaying status in mode-line

;;; Code:

(defgroup syncorate nil
  "Syncorate client."
  :prefix "syncorate:"
  :group 'syncorate)

(defcustom syncorate-executable "syncorate"
  "Syncorate executable path."
  :group 'syncorate
  :type 'string)

(defcustom syncorate-mode-line-symbol "<$>"
  "Symbol to display in mode-line."
  :group 'syncorate
  :type 'string)

(defvar syncorate-mode-line-current-symbol "")

(defvar syncorate-state nil)

(defvar syncorate-timer nil)

(defvar syncorate-initialized nil)

(defface syncorate-mode-line-face
  '((t (:foreground "red" :bold t)))
  "Syncorate mode line face."
  :group 'syncorate)

(defun syncorate-propertized-mode-line ()
  "Get Mode-line symbol with set face."
  (propertize syncorate-mode-line-current-symbol 'face 'syncorate-mode-line-face))

(defun start-focus (duration activity)
  "Start a new Focus of DURATION minutes with focus on ACTIVITY."
  (shell-command (concat syncorate-executable " --duration " (number-to-string duration) " <<< \"" activity "\""))
  (syncorate-show-mode-line))

(defun syncorate-clear-mode-line ()
  "Remove Syncorate from mode-line."
    (setq syncorate-mode-line-current-symbol "")
    (force-mode-line-update))

(defun syncorate-show-mode-line ()
  "Display Syncorate in mode-line."
  (setq syncorate-mode-line-current-symbol syncorate-mode-line-symbol)
  (force-mode-line-update))

(defun syncorate-check-status ()
  "Print current syncorate-status."
  (let ((syncorate-new-state (replace-regexp-in-string "\n$" ""
                                                  (shell-command-to-string
                                                   (concat syncorate-executable " --state")))))
    (when (not (string-equal syncorate-new-state syncorate-state))
      (setq syncorate-state syncorate-new-state)
      (if (string-equal syncorate-state "focus")
          (syncorate-show-mode-line)
        (when (string-equal syncorate-state "standby")
          (message "Break!")
          (syncorate-clear-mode-line))))))

(defun syncorate-focus (duration activity)
  "Start a new Focus of DURATION minutes with focus on ACTIVITY."
  (interactive "nDuration in minutes: \nsActivity: ")
  (start-focus duration activity))

(unless syncorate-initialized
  (setq-default mode-line-misc-info (cons " " mode-line-misc-info))
  (setq-default mode-line-misc-info
                (cons '(:eval (syncorate-propertized-mode-line)) mode-line-misc-info))
  (setq syncorate-initialized t)
  (setq syncorate-timer (run-with-timer 0 5 'syncorate-check-status)))

(provide 'syncorate)

;;; syncorate.el ends here
