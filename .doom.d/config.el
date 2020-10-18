;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Geraldo Fada"
      user-mail-address "geraldofada.neto@gmail.com")


;; Fluffy
(setq doom-font (font-spec :family "Fira Code" :size 12))
(setq doom-theme 'doom-horizon)
(setq display-line-numbers-type nil)
(setq fancy-splash-image "y:/.doom.d/black-hole.png") ;; change splash art
(global-visual-line-mode t) ;; wrap line


;; NOTE: as of 2020-10-17 this seems to be fixed, but i'm not sure so i'll be leaving it in here
;; Counsel rg workaround
;; - source: https://github.com/hlissner/doom-emacs/issues/3215#issuecomment-641575701
(after! counsel
  (setq counsel-rg-base-command "rg -M 240 --with-filename --no-heading --line-number --color never %s --path-separator / ."))

;; Avy config
(setq avy-all-windows t)

;; Org mode config
;; NOTE: z (work) and y (home) drives are specified using subst on windows
(setq slipbox-path "z:/notes/slipbox/")
(setq org-directory "z:/notes/agenda/")
(setq org-agenda-files '("z:/notes/agenda/"))

(after! org
  (setq org-superstar-headline-bullets-list nil)
  )

(use-package! org-roam
  :defer t
  :init
    (setq org-roam-directory slipbox-path)
    (setq org-roam-graph-viewer "C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe")
    (setq org-roam-graph-executable "C:/Program Files/Graphviz/2.44.1/bin/dot.exe")
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

;; Dart + Flutter
(use-package! dart
  :defer t
  :init
  (setq lsp-dart-sdk-dir "z:/devtools/dart/2.9.3")
  (setq lsp-dart-flutter-sdk-dir "Z:/devtools/flutter/1.20.4")
  (setq lsp-dart-closing-labels nil)
)

;; Persist Emacs initial frame
;; - source: https://github.com/hlissner/doom-emacs/blob/develop/docs/api.org#persist-emacs-initial-frame-position-dimensions-andor-full-screen-state-across-sessions
(when-let (dims (doom-store-get 'last-frame-size))
  (cl-destructuring-bind ((left . top) width height fullscreen) dims
    (setq initial-frame-alist
          (append initial-frame-alist
                  `((left . ,left)
                    (top . ,top)
                    (width . ,width)
                    (height . ,height)
                    (fullscreen . ,fullscreen))))))

(defun save-frame-dimensions ()
  (doom-store-put 'last-frame-size
                  (list (frame-position)
                        (frame-width)
                        (frame-height)
                        (frame-parameter nil 'fullscreen))))

(add-hook 'kill-emacs-hook #'save-frame-dimensions)
