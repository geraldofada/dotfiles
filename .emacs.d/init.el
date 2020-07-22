;; ===== Default settings =====
;; Backup stuff
(setq backup-directory-alist '(("." . "~/.emacs.d/backups"))
      backup-by-copying t     ; Don't delink hardlinks
      version-control t       ; Use version numbers on backups
      delete-old-versions t   ; Automatically delete excess backups
      kept-new-versions 10    ; how many of the newest versions to keep
      kept-old-versions 5     ; and how many of the old
      )

;; Hide menu
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(global-eldoc-mode -1) ; Disable Eldoc
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq initial-scratch-message "")

;; Tab insert 4 spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; Font settings
(set-face-attribute 'default nil :font "Hack-10" )
(set-frame-font "Hack-10" nil t)

;; ESC always quits hack
;; source: https://emacs.stackexchange.com/a/14759
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))
;; ========================================



;; ===== Packages settings =====
(require 'package)
(setq package-enable-at-startup nil) ; Prevents packages to load before startup
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "https://melpa.org/packages/")))
(package-initialize)

;; use-package init
(unless (package-installed-p 'use-package) ; unless it is already installed
  (package-refresh-contents)               ; update packages archive
  (package-install 'use-package))          ; and install the most recent version of use-package

(require 'use-package)

;; basic packages init
;; must have
(use-package counsel :ensure t
    :config
    (ivy-mode 1)
    (setq ivy-height 15))
(use-package counsel-projectile :ensure t)
(use-package evil :ensure t
    :config (evil-mode 1))
(use-package magit :ensure t)
(use-package evil-magit :ensure t)
;; fluffy
(use-package zenburn-theme :ensure t
    :config
    (load-theme 'zenburn t)
    (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line          nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line          nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :background "gray22")))
(use-package minions :ensure t
    :config (minions-mode 1))
(use-package moody :ensure t
    :config
    (setq x-underline-at-descent-line t)
    (moody-replace-mode-line-buffer-identification)
    (moody-replace-vc-mode))
;; utility packages
(use-package which-key :ensure t
    :config (which-key-mode))
(use-package projectile :ensure t
    :config
    (projectile-mode +1)
    (setq projectile-completion-system 'ivy))
(use-package avy :ensure t
    :config (setq avy-timeout-seconds 0.3))

;; general pkg for keybinds
(use-package general :ensure t
:config

(general-define-key
    ;; basic keybinds
    :keymaps '(normal visual insert emacs)
    :prefix "SPC"
    :non-normal-prefix "C-SPC"
    ;; M-x
    "SPC" '(counsel-M-x :wk "exec")
    ;; buffer
    "b"   '(:ignore t :wk "buffer")
    "bb"  '(ivy-switch-buffer :wk "buffer list")
    "bd"  '(kill-buffer-and-window :wk "delete buffer")
    ;; window
    "w"   '(:ignore t :wk "window")
    "w/" '(split-window-vertically :wk "split horizontally")
    "wv" '(split-window-horizontally :wk "split vertically")
    "wd" '(delete-window :wk "delete window")
    "wk" '(windmove-up :wk "go up")
    "wj" '(windmove-down :wk "go down")
    "wl" '(windmove-right :wk "go right")
    "wh" '(windmove-left :wk "go left")
    "wr" '(ivy-resume :wk "restore session")
    ;; search
    "/"   '(counsel-rg :wk "rg")
    "s"   '(:ignore t :wk "search")
    "ss"  '(swiper-isearch :wk "search here")
    ;;jump
    "j"   '(:ignore t :wk "jump")
    "jj"  '(avy-goto-char-2 :wk "jump to char")
    "jl"  '(avy-goto-line :wk "jump to line")
    ;; file
    "f"   '(:ignore t :wk "file")
    "ff"  '(counsel-find-file :wk "find files")
    "fr"  '(counsel-recentf :wk "recent files")
    "fs"  '(save-buffer :wk "save")
    ;; projectile
    "p"   '(:ignore t :wk "project")
    "p/"  '(counsel-projectile-rg :wk "project rg")
    "pf"  '(projectile-find-file :wk "project find file")
    "pr"  '(projectile-recentf :wk "project recent files")
    "pb"  '(projectile-switch-to-buffer :wk "project buffer")
    "pk"  '(projectile-kill-buffers :wk "project kill buffers")
    "pp"  '(projectile-command-map :wk "projectile command")
    ;; quit
    "q"   '(:ignore t :wk "quit")
    "qq"  '(save-buffers-kill-emacs :wk "save and quit")
    ;; applications
    "a"   '(:ignore t :wk "applications")
    "ag"  '(:ignore t :wk "magit")
    "ags" '(magit-status :wk "status")
    "agc" '(with-editor-finish :wk "finish commit")
    )

(general-define-key
    ;; ivy buffer navigation
    :keymaps '(ivy-minibuffer-map ivy-switch-buffer-map)
    "C-j"    'ivy-next-line
    "C-k"    'ivy-previous-line
    "M-j"    'ivy-end-of-buffer
    "M-k"    'ivy-beginning-of-buffer
    "C-y"    'ivy-scroll-up-command
    "C-e"    'ivy-scroll-down-command
    "C-d"    'ivy-switch-buffer-kill
    )
)
;; ========================================



;; ===== Save current Window location and size =====
;; source: https://gist.github.com/synic/0357fdc2dcc777d89d1e
(defun save-framegeometry ()
  "Gets the current frame's geometry and saves to ~/.emacs.d/framegeometry."
  (let (
        (framegeometry-left (frame-parameter (selected-frame) 'left))
        (framegeometry-top (frame-parameter (selected-frame) 'top))
        (framegeometry-width (frame-parameter (selected-frame) 'width))
        (framegeometry-height (frame-parameter (selected-frame) 'height))
        (framegeometry-file (expand-file-name "~/.emacs.d/framegeometry"))
        )

    (when (not (number-or-marker-p framegeometry-left))
      (setq framegeometry-left 0))
    (when (not (number-or-marker-p framegeometry-top))
      (setq framegeometry-top 0))
    (when (not (number-or-marker-p framegeometry-width))
      (setq framegeometry-width 0))
    (when (not (number-or-marker-p framegeometry-height))
      (setq framegeometry-height 0))

    (with-temp-buffer
      (insert
       ";;; This is the previous emacs frame's geometry.\n"
       ";;; Last generated " (current-time-string) ".\n"
       "(setq initial-frame-alist\n"
       "      '(\n"
       (format "        (top . %d)\n" (max framegeometry-top 0))
       (format "        (left . %d)\n" (max framegeometry-left 0))
       (format "        (width . %d)\n" (max framegeometry-width 0))
       (format "        (height . %d)))\n" (max framegeometry-height 0)))
      (when (file-writable-p framegeometry-file)
        (write-file framegeometry-file))))
  )

(defun load-framegeometry ()
  "Loads ~/.emacs.d/framegeometry which should load the previous frame's
geometry."
  (let ((framegeometry-file (expand-file-name "~/.emacs.d/framegeometry")))
    (when (file-readable-p framegeometry-file)
      (load-file framegeometry-file)))
  )

;; Restore Frame size and location, if we are using gui emacs
(if window-system
    (progn
    (add-hook 'after-init-hook 'load-framegeometry)
    (add-hook 'kill-emacs-hook 'save-framegeometry))
)
;; ========================================



;; ===== Custom set variable auto-gen =====
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (magit counsel zenburn-theme which-key use-package general evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; ========================================
