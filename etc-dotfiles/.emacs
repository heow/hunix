
;; hate that damn toolbar and menu

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(tool-bar-mode '0)
;(menu-bar-mode '0)
(mouse-wheel-mode '1)
(show-paren-mode '1)

;; colors
;(set-background-color "sea green") 
;(set-face-foreground 'modeline "firebrick")
;(set-background-color "firebrick")
;(set-cursor-color "purple")

;; kludge around gimp keyboard mappings.
;(keyboard-translate ?\C-h ?\C-?)
;(keyboard-translate ?\C-? ?\C-h)
(global-set-key "\C-h" 'backward-delete-char-untabify)
(global-set-key "\M-h" 'help)
(global-set-key [mode-line C-mouse-1] 'mouse-tear-off-window)

;; print
;(setq lpr-command "~/bin/printcode")

;; disable autosave
(setq auto-save-default nil)

;; specify where backup files are stored
(setq backup-directory-alist (quote ((".*" . "~/.emacs-backups"))))

(defun switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))
(global-set-key [f12] 'switch-to-scratch)

(defun goto-prev-mark ()
  (interactive)
  (set-mark-command 1))
(global-set-key [27 67108896] 'goto-prev-mark) ;; ESC C-SPC

(defun increment-number-at-point ()
  (interactive)
  (skip-chars-backward "0123456789")
  (or (looking-at "[0123456789]+")
      (error "No number at point"))
  (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))

;; grab these by 
;; 1. doing the command interactively
;; 2. C-x ESC ESC C-a C-k C-g
;; 3. paste
(global-set-key '[67108908] 'next-line)
(global-set-key '[67108910] 'scroll-down)
(global-set-key '[67108903] 'scroll-up)

;; Windows
;(set-default-font "-*-Lucida Console-normal-r-*-*-11-82-96-96-c-*-iso8859-1")

;; speedbar
;(define-key-after (lookup-key global-map [menu-bar tools])
;[speedbar] '("Speedbar" . speedbar-frame-mode) [calendar])
;(global-set-key [(f4)] 'speedbar-get-focus)
;(speedbar-add-supported-extension ".rb")
;(speedbar-add-supported-extension ".asp")

;;
;; 3rd party utilities
;;
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir "~/.emacs-site-lisp/")
           (default-directory my-lisp-dir))
      (setq load-path (cons my-lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

(add-to-list 'load-path "/usr/share/emacs/site-lisp")

;; old-school sucker
(require 'fpl-moo)

;; tramp
(if (featurep 'tramp)
    (progn
      (require 'tramp)
      (setq tramp-default-method "scp")

      ; turn off tramp backup and autosave
      ;(require 'backup-dir)
      (setq tramp-backup-directory-alist backup-directory-alist)
      (setq tramp-auto-save-directory "~/.emacs-backups")
      (setq auto-save-file-name-transforms '(("\\`/[^/]*:\\(.+/\\)*\\(.*\\)" "~/.emacs-backups")))  ))

;; IDO / IBS
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)
(require 'bs)
(global-set-key "\C-x\C-b" 'bs-show)
(setq bs-must-always-show-regexp "repl\\|shell")
(require 'ibs) ;; C-tab!
(global-set-key "\C-xb" 'ibs-select)

;;
;; muse
;; http://www.emacswiki.org/cgi-bin/wiki/MuseMode
;;
;(require 'muse-mode nil t)
;(if (featurep 'muse-mode)
;    (progn
;
;      (require 'muse-html)
;      (require 'muse-wiki)
;      (require 'muse-project)
;
;      ; fix some bindings
;      (local-unset-key "\C-x\C-e")
;      (local-unset-key "\M-\C-x")
;
;;; nuke it
;;; TODO: upgrade muse/emacs and remove
;;      (local-set-key "\C-x\C-e" 'eval-defun)
;;      (local-set-key "\M-\C-x" 'eval-defun)
;      (global-set-key "\C-x\C-e" 'eval-defun)
;      (global-set-key "\M-\C-x" 'eval-defun)
;
;      ;(setq muse-file-extension nil muse-mode-auto-p t)
;     
;      (setq muse-project-alist
;            '(
;              ("CategoryPersonal"
;               ("~/prj-personal/doc-wiki" :default "index")
;               (:base "html" :path "~/res/wiki-personal")
;               (:base "pdf"  :path "~/res/wiki-personal") )
;
;              ("CategoryWork"
;               ("~/prj-work/doc-wiki" :default "index")
;               (:base "html" :path "~/res/wiki-work")
;               (:base "pdf"  :path "~/res/wiki-work") )
;              )) 
;
;      (defun browse-dir (dir-as-string)
;        (start-process-shell-command 
;         "browse-gui" 
;         "*scratch*" 
;         (concat "~/.hunix/bin/br " dir-as-string)))
;
;      (defun xterm-dir (dir-as-string)
;        (start-process-shell-command 
;         "browse-xterm" 
;         "*scratch*" 
;         (concat "~/.hunix/bin/xt " dir-as-string)))
;         ;"/usr/bin/rox-filer" "--new" dir-as-string))
;      ))

;;
;; eshell
;;
;(require 'eshell)
;(setq eshell-banner-message "Hacks and glory await!\n\n")
;(defun eshell-new ()
;  (interactive)
;  (eshell "eshell"))
;(global-set-key "" 'eshell)
;;(setq bs-must-always-show-regexp "eshell") ; always show in buffer list
;
;;(add-hook 'eshell-mode-hook 'ansi-color-for-comint-mode-on)
;(ansi-color-for-comint-mode-on)
;
;; ansi-color filter
;;(add-hook 'eshell-preoutput-filter-functions 'ansi-color-filter-apply)
;
;; ansi-color support
;(add-hook 'eshell-preoutput-filter-functions 'ansi-color-apply)

;;
;; nrepl
;; https://github.com/kingtim/nrepl.el
;;
(setq nrepl-popup-stacktraces nil) ; stop errors from popping up
(add-hook 'nrepl-mode-hook 'paredit-mode) ; enable paredit for nrepl

(setq bs-must-always-show-regexp "repl\\|shell")

;(global-set-key [f11] 'run-lisp)

;(setq inferior-lisp-program "/usr/bin/clisp")
;(setq inferior-lisp-program "/usr/bin/lisp")
;(setq inferior-lisp-program "/usr/bin/sbcl")
;(setq inferior-lisp-program "/home/heow/prj-personal/abcl/abcl")
;(define-slime-dialect abcl "abcl")

;; 
;; CL SLIME
;; 
;(require 'slime)
;(add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
;(add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))

;;
;; ediff customizations
;;
(defconst ediff-ignore-similar-regions t)
(defconst ediff-use-last-dir t)
(defconst ediff-diff-options " -b ")

;;
;; markdown
;;
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (append '(
		("\\.md$" . markdown-mode)
		("\\.markdown$" . markdown-mode)
		)auto-mode-alist))

;;
;; misc
;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bs-must-always-show-regexp "lisp")
 '(column-number-mode t)
 '(gud-gdb-command-name "gdb --annotate=1")
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(large-file-warning-threshold nil)
 '(mu-worlds
   (quote
    (["Lambda" "lambda.moo.mud.org" 8888 "heow" "lambdanarf"])))
 '(package-selected-packages
   (quote
    (fold-this dockerfile-mode gnu-elpa-keyring-update cider paredit)))
 '(ssh-host "localhost")
 '(ssh-program "/usr/bin/ssh")
 '(ssh-remote-user "heow")
 '(tab-width 4)
 '(vc-cvs-stay-local nil)
 '(vc-follow-symlinks t)
 '(version-control nil))

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; MELPA
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
