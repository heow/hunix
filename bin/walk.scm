#!/usr/bin/scsh -s
!#
;(display "hey there punk\n")
;(display "this is what was passed in: ")
;(display (argv 1))
;(display " done \n\n")
;
;;;; use pipes
;(define output (run/sexps (| (ps) (tail -1))))
;(display "the tail of ps: ")
;(display output)

(define (walk-dir d)
  (with-cwd d
            (for-each (lambda (f)
                        (if (file-directory? f) (walk-dir (file-name-as-directory f)))
                        (display f)
                        (display "\n"))
                      (directory-files d)) ))

(walk-dir ".")