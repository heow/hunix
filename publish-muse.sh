:;exec emacs -batch -l   "$0" "$@" --no-site-file -q  # -*- Emacs-Lisp -*-
;     @emacs -batch -l "%~f0"  %*  --no-site-file -q  & goto :EOF
;
; Gives a (usually) big random integer number, with no arguments.
;                  If a positive integer n is given, the range is [0,n) .
;
(require 'muse-mode)
(if (featurep 'muse-mode)
    (progn
      (require 'muse-html)
      (require 'muse-wiki)
      (require 'muse-project)
     
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

      (print "publishing personal wiki...")
      (muse-project-publish "CategoryPersonal")

      (print "publishing work wiki...")
      (muse-project-publish "CategoryWork")
      ))
;
;:EOF