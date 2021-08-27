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
    (set 'org-directory "c:/Users/sjpea/OneDrive/Documents/org")
 (set 'org-directory "d:/OneDrive/Documents/org"))

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

(use-package! org-gtd
  :after org
  :demand t ;; without this, the package won't be loaded, so org-agenda won't be configured
  :custom
  ;; where org-gtd will put its files. This value is also the default one.
  (org-gtd-directory (concat org-directory "/gtd/"))
  ;; package: https://github.com/Malabarba/org-agenda-property
  ;; this is so you can see who an item was delegated to in the agenda
  (org-agenda-property-list '("DELEGATED_TO"))
  ;; I think this makes the agenda easier to read
  (org-agenda-property-position 'next-line)
  ;; package: https://www.nongnu.org/org-edna-el/
  ;; org-edna is used to make sure that when a project task gets DONE,
  ;; the next TODO is automatically changed to NEXT.
  (org-edna-use-inheritance t)
  :config
  (org-edna-load)
  :bind
  (("C-c d c" . org-gtd-capture) ;; add item to inbox
  ("C-c d a" . org-agenda-list) ;; see what's on your plate today
  ("C-c d p" . org-gtd-process-inbox) ;; process entire inbox
  ("C-c d n" . org-gtd-show-all-next) ;; see all NEXT items
  ("C-c d s" . org-gtd-show-stuck-projects)) ;; see projects that don't have a NEXT item
  :init
  (bind-key "C-c c" 'org-gtd-clarify-finalize)) ;; the keybinding to hit when you're done editing an item in the processing phase

(use-package! org-agenda
  :ensure nil ;; this is how you tell use-package to manage a sub-package
  :after org-gtd ;; because we need to add the org-gtd directory to the agenda files
  :config
  ;; use as-is if you don't have an existing org-agenda setup
  ;; otherwise push the directory to the existing list
  (setq org-agenda-files (list org-gtd-directory))
  ;; a useful view to see what can be accomplished today
  (setq org-agenda-custom-commands '(("g" "Scheduled today and all NEXT items" ((agenda "" ((org-agenda-span 1))) (todo "NEXT"))))))

        ;; Set org-capture templates
(use-package! org-capture
  :ensure nil
  :after org-gtd
  :config
  (setq org-capture-templates `(("i" "Inbox"
                                 entry (file ,(org-gtd--path org-gtd-inbox-file-basename))
                                 "* %?\n%U\n\n  %i"
                                 :kill-buffer t)
                                ("l" "Todo with link"
                                 entry (file ,(org-gtd--path org-gtd-inbox-file-basename))
                                 "* %?\n%U\n\n  %i\n  %a"
                                 :kill-buffer t)
                                ("c" "Cookbook"
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

;; Org Roam
(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (concat org-directory "/roam"))
  (org-roam-dailies-directory "journals/")
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :if-new (file+head "pages/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n")
      :unnarrowed t))))
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

;; Set org-ref defaults
 (setq reftex-default-bibliography (concat org-directory "/roam/roam-ref.bib"))
  (setq org-ref-default-bibliography (concat org-directory "/roam/roam-ref.bib"))

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
