;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(add-hook 'emacs-startup-hook 'toggle-frame-maximized)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Samuel J Pearce"
      user-mail-address "sjpearce27@gmail.com")
	  
(defun insert-system-name()
(interactive)
"Get current system's name"
(insert (format "%s" (system-name)))
)

(defun system-is-my-laptop()
(interactive)
"Return true if the system we are running on is my laptop"
(string-equal (system-name) "SAMUEL-LAPTOP")
)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function.
(setq doom-theme 'doom-nord)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(if (system-is-my-laptop)
    (set 'org-directory "c:/Users/sjpea/OneDrive/Documents/org/")
 (set 'org-directory "d:/OneDrive/Documents/org/"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.


;; Org Mode Config ----------------------------

(setq org-startup-folded t)

;;Start org-protocol
(server-start)
(require 'org-protocol)
(require 'org-roam-protocol)

(load-file "~/.emacs.d/+org-protocol-check-filename-for-protocol.el")
(advice-add 'org-protocol-check-filename-for-protocol :override '+org-protocol-check-filename-for-protocol)

;; Set org-capture templates
(setq org-agenda-inbox (concat org-directory "/inbox.org"))
  (setq org-capture-templates
        `(("i" "inbox" entry (file org-agenda-inbox)
           "* TODO %?")
          ("l" "link" entry (file org-agenda-inbox)
           "* TODO %(org-cliplink-capture)" :immediate-finish t)
          ("c" "org-protocol-capture" entry (file org-agenda-inbox)
           "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)
          ("p" "project ideas" entry (file+headline org-agenda-inbox "Project Ideas")
           "* TODO %?")
          )
        )
;; Set org-ref defaults
 (setq reftex-default-bibliography (concat org-directory "/roam/roam-ref.bib"))
  (setq org-ref-default-bibliography (concat org-directory "/roam/roam-ref.bib"))

;; Elfeed/elfeed-org config -----------------------------
(setq rmh-elfeed-org-files (list (concat org-directory "elfeed.org")))
(map! :leader
      :desc "elfeed"
     "o e" #'elfeed)

(after! elfeed
  (setq elfeed-search-filter "@1-month-ago +unread"))
(add-hook! 'elfeed-search-mode-hook 'elfeed-update)

;; Set ESS R directory
 (setq ess-directory-containing-R "c:/Program Files")
 (require 'ess-site)
