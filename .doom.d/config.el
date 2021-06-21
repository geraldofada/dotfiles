;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Geraldo Fada"
      user-mail-address "geraldofada.neto@gmail.com")


;; Fluffy
(setq doom-font (font-spec :family "JetBrains Mono" :size 13 ))
(setq doom-theme 'doom-horizon)
(setq display-line-numbers-type nil)
(setq fancy-splash-image "~/.doom.d/black-hole.png") ;; change splash art
(global-visual-line-mode t) ;; wrap line

;; C lang config
(after! ccls
  (setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
  (set-lsp-priority! 'ccls 2)) ; optional as ccls is the default in Doom

;; Avy config
(setq avy-all-windows t)

;; Org mode config
(setq slipbox-path "~/notes/slipbox/")
(setq org-directory "~/notes/agenda/")
(setq org-agenda-files '("~/notes/agenda/"))

(setq calendar-week-start-day 0
          calendar-day-name-array ["Domingo" "Segunda" "Terça" "Quarta"
                                   "Quinta" "Sexta" "Sábado"]
          calendar-month-name-array ["Janeiro" "Fevereiro" "Março" "Abril"
                                     "Maio" "Junho" "Julho" "Agosto"
                                     "Setembro" "Outubro" "Novembro" "Dezembro"])

(after! org
  (setq org-superstar-headline-bullets-list nil)
  (setq org-log-done 'time)
  (setq org-agenda-start-with-log-mode t)
  )

(use-package! org-roam
  :defer t
  :init
    (setq org-roam-directory slipbox-path)
    ;; filetags to the head
    (setq org-roam-capture-templates
          '(("d" "default" plain (function org-roam--capture-get-point)
                "%?"
                :file-name "%<%Y%m%d%H%M%S>"
                :head "#+title: ${title}\n#+date: %<%Y-%m-%d %H:%M:%S>\n#+filetags: "
                :unnarrowed t))
    )
    (setq org-roam-tag-sources '(vanilla))
    (setq org-roam-db-update-method 'immediate)
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
    (setq +latex-viewers '(zathura))
  )

(map! :after latex
      :map LaTeX-mode-map
      :localleader
      :desc "Compile all and view" "v" #'TeX-command-run-all
  )
