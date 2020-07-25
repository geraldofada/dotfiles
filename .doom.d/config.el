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

(setq slipbox-path "z:/slipbox/")
(setq bib-path "y:/Google Drive/Backups/slipbox_refs.bib")
(setq org-directory "y:/.org/")

(after! org
  (setq org-superstar-headline-bullets-list nil))

(after! org-roam
  (setq org-roam-directory slipbox-path))

(after! org-ref
  (setq bibtex-completion-bibliography bib-path)
  (setq bibtex-completion-notes-path slipbox-path)
  (setq bibtex-completion-pdf-field "File")

  (setq ivy-re-builders-alist
        '((ivy-bibtex . ivy--regex-ignore-order)
          (t . ivy--regex-plus)))

  (setq org-ref-completion-library 'org-ref-ivy-cite)
  (setq org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-helm-bibtex)
  (setq org-ref-default-bibliography (list bib-path))
  (setq org-ref-bibliography-notes (concat slipbox-path "bibnotes.org"))
  (setq org-ref-notes-directory slipbox-path)
  (setq org-ref-notes-function 'orb-edit-notes)
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
