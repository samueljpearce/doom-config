;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(add-hook 'emacs-startup-hook 'toggle-frame-maximized)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Samuel J Pearce"
      user-mail-address "samueljpearce@mailbox.org")
	  
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
(set 'org-directory "c:/Users/sjpea/Documents/icedrive/documents/org")

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

        ;; Org-gtd
(setq org-edna-use-inheritance t)
(org-edna-mode 1)
(setq org-gtd-update-ack "3.0.0")

(use-package! org-gtd
  :after org
  :demand t ;; without this, the package won't be loaded, so org-agenda won't be configured
  :custom
  ;; where org-gtd will put its files. This value is also the default one.
  (org-gtd-directory (concat org-directory "/gtd/"))
  ;; package: https://github.com/Malabarba/org-agenda-property
  ;; I think this makes the agenda easier to read
  ;;(org-agenda-property-position 'next-line)
  ;; package: https://www.nongnu.org/org-edna-el/
  ;; org-edna is used to make sure that when a project task gets DONE,
  ;; the next TODO is automatically changed to NEXT.
  (org-edna-use-inheritance t)
  (org-gtd-organize-hooks '(org-gtd-set-area-of-focus org-set-tags-command))
  :config
  (org-edna-mode)
  :bind
  (("C-c d c" . org-gtd-capture)
   ("C-c d e" . org-gtd-engage)
   ("C-c d p" . org-gtd-process-inbox)
   ("C-c d n" . org-gtd-show-all-next)
   ("C-c d s" . org-gtd-show-stuck-projects)
   :map org-gtd-clarify-map
   ("C-c c" . org-gtd-organize)))

        ;; Set org-capture templates
(use-package! org-capture
  :config
  (setq org-capture-templates `(("c" "Cookbook"
                                 entry (file "cookbook.org")
                                                   "%(org-chef-get-recipe-from-url)"
                                                   :empty-lines 1)
                                 ("m" "Manual Cookbook"
                                  entry (file "cookbook.org")
                                  "* %^{Recipe title: }\n  :PROPERTIES:\n  :source-url:\n  :servings:\n  :prep-time:\n  :cook-time:\n  :ready-in:\n  :END:\n** Notes   \n** Ingredients\n   %?\n** Directions\n\n")))
)
;(setq org-agenda-inbox (concat org-directory "/inbox.org"))
;  (setq org-capture-templates
;        `(("i" "inbox" entry (file org-agenda-inbox)
;           "* TODO %?")
;          ("l" "link" entry (file org-agenda-inbox)
;           "* TODO %(org-cliplink-capture)" :immediate-finish t)
;          ("c" "org-protocol-capture" entry (file org-agenda-inbox)
;           "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)
;          ("p" "project ideas" entry (file+headline org-agenda-inbox "Project Ideas")
;           "* TODO %?")
;          )
;        )

;;Start org-protocol
(server-start)
(require 'org-protocol)
(require 'org-roam-protocol)

;; Set citar defaults
(use-package! citar
  :custom
  (citar-bibliography (concat org-directory "/bib/zotero.bib"))
  (citar-notes-path (concat org-directory "/roam/references"))
  :bind
  (:map org-mode-map :package org ("C-c b" . #'org-cite-insert)))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode)
  :custom
  (citar-org-roam-note-title-template "${author} (${year}). ${title}")
  ;;(citar-org-roam-capture-template-key "r")
  )
;; Org Roam
(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (concat org-directory "/roam"))
  (org-roam-dailies-directory "journals/")
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :if-new(file+head "pages/%<%Y%m%d%H%M%S>-${slug}.org"
                        "#+title: ${title} \n#+created: %u \n#+modified:")
      :immediate-finish t
      :unnarrowed t)
     ("r" "reference" plain
     "%?"
     :target(file+head "references/${citekey}.org"
                       "#+title: ${title} \n#+created: %u \n#+modified:")
     :immediate-finish t
     :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %<%I:%M %p>: %?"
      :target(file+head "%<%Y-%m-%d>.org"
                        "#+title: %<%Y-%m-%d>\n")))))
  :config
  (require 'org-roam-dailies)

(setq org-roam-graph-executable "P:/Program Files/Graphviz/bin/dot.exe")
(setq org-roam-graph-viewer "C:/Program Files (x86)/BraveSoftware/Brave-Browser/Application/brave.exe")

;; org-roam-ui (successor to org-roam-server)
(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
    :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

;;(load-file "~/.emacs.d/+org-protocol-check-filename-for-protocol.el")
;;(advice-add 'org-protocol-check-filename-for-protocol :override '+org-protocol-check-filename-for-protocol)


;; Elfeed/elfeed-org config -----------------------------
(setq rmh-elfeed-org-files (list (concat org-directory "/elfeed.org")))
;; (map! :leader
;;       :desc "elfeed"
;;       "o e" #'elfeed)
(map! :map elfeed-search-mode-map
      :leader
      :n "m u" #'elfeed-update)
(after! elfeed
  (setq elfeed-search-filter "@1-month-ago +unread"))
(add-hook! 'elfeed-search-mode-hook 'elfeed-update)

;; Elfeed Dashboard
(use-package elfeed-dashboard
  :load-path "~/.emacs.d/.local/straight/repos/elfeed-dashboard/"
  :config (setq elfeed-dashboard-file "~/.emacs.d/.local/straight/repos/elfeed-dashboard/elfeed-dashboard.org"))

(map! :leader
      :desc "elfeed-dashboard"
      "o e" #'elfeed-dashboard)
;; Set ESS R directory
 (setq ess-directory-containing-R "c:/Program Files")
 (require 'ess-site)

;; Set ledger-mode config
(setq ledger-binary-path "C:/ProgramData/chocolatey/bin")
(autoload 'ledger-mode "ledger-mode" "A major mode for Ledger" t)
(add-to-list 'load-path
              (expand-file-name "~/.emacs.d/.local/straight/repos/ledger-mode"))
(add-to-list 'auto-mode-alist '("\\.ledger$" . ledger-mode))
