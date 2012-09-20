
;; hate that damn toolbar and menu
;(tool-bar-mode '0)
(menu-bar-mode '0)
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

;; cua keyboard, as much as it kills me
(global-set-key [home]    'beginning-of-line)
(global-set-key [end]     'end-of-line)
(global-set-key [C-left]  'backward-word)
(global-set-key [C-right] 'forward-word)
(global-unset-key "\C-o")
(global-set-key   "\C-o"  'backward-word)
(global-unset-key "\C-u")
(global-set-key   "\C-u"  'forward-word)
(global-set-key   "\C-\M-u" 'universal-argument)
(global-set-key [C-home] 'beginning-of-buffer)
(global-set-key [C-end] 'end-of-buffer)
(global-set-key [C-insert] 'copy-region-as-kill)
(global-set-key [S-insert] 'yank)
(global-set-key [C-delete] 'kill-region)
(global-set-key [S-delete] 'kill-region)
(global-set-key [S-left] 'set-mark-command)
(global-set-key [S-right] 'set-mark-command)
(global-set-key [S-up] 'set-mark-command)
(global-set-key [S-down] 'set-mark-command)
(global-set-key [C-f4] 'kill-buffer)
(global-set-key [C-s] 'search-fwd)

;; grab these by 
;; 1. doing the command interactively
;; 2. C-x ESC ESC C-a C-k C-g
;; 3. paste
(global-set-key '[67108908] 'next-line)
(global-set-key '[67108910] 'scroll-down)
(global-set-key '[67108903] 'scroll-up)

;; dvorak movement keys
(global-unset-key "\M-u")
(global-set-key "\M-u" 'forward-char)
(global-unset-key "\M-o")
(global-set-key "\M-o" 'backward-char)
(global-unset-key "\M-e")
(global-set-key "\M-e" 'forward-char)
(global-unset-key "\M-a")
(global-set-key "\M-a" 'backward-char)

;; Windows
;(set-default-font "-*-Lucida Console-normal-r-*-*-11-82-96-96-c-*-iso8859-1")

;; speedbar
;(define-key-after (lookup-key global-map [menu-bar tools])
;[speedbar] '("Speedbar" . speedbar-frame-mode) [calendar])
(global-set-key [(f4)] 'speedbar-get-focus)
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
(require 'muse-mode nil t)
(if (featurep 'muse-mode)
    (progn

      (require 'muse-html)
      (require 'muse-wiki)
      (require 'muse-project)

      ; fix some bindings
      (local-unset-key "\C-x\C-e")
      (local-unset-key "\M-\C-x")

;; nuke it
;; TODO: upgrade muse/emacs and remove
;      (local-set-key "\C-x\C-e" 'eval-defun)
;      (local-set-key "\M-\C-x" 'eval-defun)
      (global-set-key "\C-x\C-e" 'eval-defun)
      (global-set-key "\M-\C-x" 'eval-defun)

      ;(setq muse-file-extension nil muse-mode-auto-p t)
     
      (setq muse-project-alist
            '(
              ("CategoryPersonal"
               ("~/prj-personal/doc-wiki" :default "index")
               (:base "html" :path "~/res/doc/wiki-personal")
               (:base "pdf"  :path "~/res/doc/wiki-personal") )

              ("CategoryWork"
               ("~/prj-work/doc-wiki" :default "index")
               (:base "html" :path "~/res/doc/wiki-work")
               (:base "pdf"  :path "~/res/doc/wiki-work") )
              )) 

      (defun browse-dir (dir-as-string)
        (start-process-shell-command 
         "browse-gui" 
         "*scratch*" 
         (concat "~/.hunix/bin/br " dir-as-string)))

      (defun xterm-dir (dir-as-string)
        (start-process-shell-command 
         "browse-xterm" 
         "*scratch*" 
         (concat "~/.hunix/bin/xt " dir-as-string)))
         ;"/usr/bin/rox-filer" "--new" dir-as-string))
      ))

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

;; cvs support
;(autoload 'cvs-update "pcl-cvs" nil t)
;(global-set-key [(f12)] 'cvs-update)

;; svn support
;(require 'psvn)

;; ssh
;(require 'ssh)

;;
;; ACL
;;
;(load "/opt/acl/acl62/eli/fi-site-init")

;;
;; slime/lisp
;; see http://cl-cookbook.sourceforge.net/.emacs
;;
;(modify-coding-system-alist 'process "lisp" 'unix) ; CR <--> CRLF
;
;;(defvar hyperspec-prog "/usr/share/emacs21/site-lisp/ilisp/extra/hyperspec")
;
;(global-set-key [f1]
;		'(lambda ()
;		  (interactive)
;		  ;(load-library hyperspec-prog)
;          (setq common-lisp-hyperspec-root "file:///home/heow/res/books-tech/HyperSpec/")
;          (setq common-lisp-hyperspec-symbol-table (concat common-lisp-hyperspec-root "Data/Map_Sym.txt"))
;		  (common-lisp-hyperspec (thing-at-point 'symbol))))
;
;(setq auto-mode-alist
;      (append '(
;		("\\.emacs$" . emacs-lisp-mode)
;		("\\.lisp$" . lisp-mode)
;		("\\.lsp$" . lisp-mode)
;		("\\.cl$" . lisp-mode)
;		("\\.clp$" . lisp-mode)
;		)auto-mode-alist))

(require 'slime)
(eval-after-load 'slime '(setq slime-protocol-version 'ignore))
(slime-setup '(slime-repl))
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

;;;
;;; clojure
;;;

;;; clojure-mode
;(add-to-list 'load-path "~/.hunix/opt/clj/clojure-mode")
(require 'clojure-mode)
; 
;;; slime
(add-to-list 'load-path "~/.hunix/opt/clj/slime")
(eval-after-load "slime"
   '(progn
 ;     (setq slime-use-autodoc-mode nil)
      (slime-setup '(slime-repl
 		    slime-fancy
 		    slime-fuzzy
 		    slime-banner))
      (setq slime-complete-symbol*-fancy t)
      (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)

      (fset 'compile-and-goto-repl "\C-x\C-s\C-c\C-k\C-c\C-z")
      (global-set-key [f6] 'compile-and-goto-repl)
      ))
 
(defvar package-activated-list nil "Hack: used in `slime-changelog-date' but not defined anywhere")

(require 'slime)

;;; paredit
(autoload 'paredit-mode "paredit"
      "Minor mode for pseudo-structurally editing Lisp code." t)
    (add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
    (add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
    (add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
    (add-hook 'scheme-mode-hook           (lambda () (paredit-mode +1)))
    (add-hook 'clojure-mode-hook           (lambda () (paredit-mode +1)))

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
;; xml
;;
(defun bf-pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t) 
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

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
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(ssh-host "localhost")
 '(ssh-program "/usr/bin/ssh")
 '(ssh-remote-user "heow")
 '(tab-width 4)
 '(vc-cvs-stay-local nil)
 '(vc-follow-symlinks t)
 '(version-control nil))

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
;(when
;    (load
;     (expand-file-name "~/.emacs.d/elpa/package.el"))
;  (package-initialize))

;;
;; always start as server
;;
(server-start)

