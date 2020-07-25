;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; NOTE: z (work) and y (home) drives are specified using subst on windows

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Geraldo Fada"
      user-mail-address "geraldofada.neto@gmail.com")

;; Fluffy
(setq doom-font (font-spec :family "Fira Code" :size 13))
(setq doom-theme 'doom-sourcerer)
(setq display-line-numbers-type nil)
(setq fancy-splash-image "y:/.doom.d/black-hole.png") ;; change splash art
(global-visual-line-mode t) ;; wrap line


;; Counsel rg workaround
;; - source: https://github.com/hlissner/doom-emacs/issues/3215#issuecomment-641575701
(after! counsel
  (setq counsel-rg-base-command "rg -M 240 --with-filename --no-heading --line-number --color never %s --path-separator / ."))

;; Org mode config
(setq org-directory "y:/.org/")

(after! org
    (setq org-superstar-headline-bullets-list nil))
(after! org-roam
    (setq org-roam-directory "z:/slipbox/"))

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
