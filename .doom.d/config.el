;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Geraldo Fada"
      user-mail-address "geraldofada.neto@gmail.com")


;; Fluffy
(setq doom-font (font-spec :family "Fira Code" :size 12))
(setq doom-theme 'doom-horizon)
(setq display-line-numbers-type nil)
(setq fancy-splash-image "~/.doom.d/black-hole.png") ;; change splash art
(global-visual-line-mode t) ;; wrap line


;; NOTE: as of 2020-10-17 this seems to be fixed
;; Counsel rg workaround
;; - source: https://github.com/hlissner/doom-emacs/issues/3215#issuecomment-641575701
;; (after! counsel
;;   (setq counsel-rg-base-command "rg -M 240 --with-filename --no-heading --line-number --color never %s --path-separator / ."))

;; Avy config
(setq avy-all-windows t)

;; Org mode config
;; NOTE: z (work) and y (home) drives are specified using subst on windows
(setq slipbox-path "~/notes/slipbox/")
(setq org-directory "~/notes/agenda/")
(setq org-agenda-files '("~/notes/agenda/"))

(after! org
  (setq org-superstar-headline-bullets-list nil)
  (setq org-log-done 'time)
  (setq org-agenda-start-with-log-mode t)
  )

(use-package! org-roam
  :defer t
  :init
    (setq org-roam-directory slipbox-path)
    ;; (setq org-roam-graph-viewer "C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe")
    ;; (setq org-roam-graph-executable "C:/Program Files/Graphviz/2.44.1/bin/dot.exe")
    ;; filetags to the head
    (setq org-roam-capture-templates
          '(("d" "default" plain (function org-roam--capture-get-point)
                "%?"
                :file-name "%<%Y%m%d%H%M%S>-${slug}"
                :head "#+title: ${title}\n#+filetags: "
                :unnarrowed t))
    )
    ;; (remove-hook 'org-roam-title-change-hook 'org-roam--update-links-on-title-change)
    ;; (remove-hook 'org-roam-title-change-hook 'org-roam--update-file-name-on-title-change)
  )

(use-package! deft
  :defer t
  :init
    (setq deft-directory slipbox-path)
  )

;; Ledger mode
(use-package! ledger
  :defer t
  :init
    (add-to-list 'auto-mode-alist '("\\.\\(h?ledger\\|journal\\|j\\)$" . ledger-mode))
  )

;; Latex
(use-package! latex
  :defer t
  :init
    (setq +latex-viewers '(sumatrapdf))
  )

(map! :after latex
      :map LaTeX-mode-map
      :localleader
      :desc "Compile all and view" "v" #'TeX-command-run-all
  )
