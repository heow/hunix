;; fpl-react.el
;; Version: 1.2.4
;; Author: Francis Litterio
;;	   franl@world.std.com
;;	   http://world.std.com/~franl/
;;
;; An elisp package that lets you spawn asynchronous processes or network
;; connections and register elisp forms to be automatically evaluated in
;; response to patterns in the output.
;;
;; Author:
;;
;;	Fran Litterio
;;	franl@world.std.com
;;	http://world.std.com/~franl/
;;
;; Installation:
;;
;; To install this package, place this file in a directory named in your
;; load-path variable, and put this in your .emacs file:
;;
;;	(require 'fpl-react)
;;
;; If you'd prefer to autoload this file, put the below autoload forms into
;; your .emacs startup file.
;;
;;	(autoload 'fpl-react-spawn "fpl-react"
;;	  "Spawn a process or network connection and react to its output." t t)
;;	
;;	(autoload 'fpl-react-register "fpl-react"
;;	  "Register an autoreaction." nil t)
;;	
;;	(autoload 'fpl-react-deregister "fpl-react"
;;	  "Deregister an autoreaction. " nil t)
;;
;; Usage:
;;
;;	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	;;                   UNDER CONSTRUCTION                   ;;
;;	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defconst fpl-react-version "1.2.4" "Version number of package fpl-react.el.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; User options.  These are the only variables users should have to change
;; to configure this package.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defvar fpl-react-processes nil
  "*This variable specifies which processes and network connections that
fpl-react-spawn can spawn.  Add your entries to this list, but do not add them
in the source to this package, because you'll lose your changes when you
upgrade to a new version of this package.  Instead, append or prepend your
entries to this list in your .emacs startup file (if you are an end user) or
in your package's initialization phase (if you are authoring a package that
uses this one).

This variable's value is a list, each element of which is a list of the form

	(ID TYPE FILTER BUFFERNAME SPAWNINFO)

ID is a string that names the process.  Pass this string to fpl-react-spawn
to spawn this process or this network connection.  If you have more than one
entry with the same name, all but the first is ignored.  The name of the
process buffer is derived from ID but is not the same as ID.  When
fpl-react-spawn is invoked interactively, you can enter this string in the
minibuffer.

TYPE is a symbol that specifies the kind of process to create.  The symbol
conn means to open a TCP/IP connection to a given port on a given host (via
open-network-stream), and proc means to spawn a child process (via
start-process) which runs a given program.  Once spawned, input can be sent to
the process/connection via process-send-string.

FILTER is a function or nil.  FILTER is a user-supplied function that is used
to filter the output in any fashion the user wishes.  If nil, no user filter
function is called, and the process output is inserted directly in the process
buffer.  FILTER is _not_ installed as the actual filter function (via
set-process-filter) for the process.  Instead, the actual filter function,
which is defined by this package, calls FILTER, passing it two arguments: a
process object and a string containing some output from that process.

FILTER is called before the output is scanned for regular expressions (i.e.,
before any autoreactions take place) and with the process mark positioned
immediately after the last output inserted in the buffer (this is an invariant
that FILTER _must_ maintain).  FILTER is called with the process buffer as the
current buffer.  FILTER is free to modify the process buffer, but it should
not expect point or mark to be in any given locations, and it should respect
the fact that the user may be typing into the process buffer at that moment.

If FILTER returns a string, that string is used in place of the original output
of the process for all further processsing, including autoreaction processing
(see the function fpl-react-register).  The string is inserted in the buffer at
the process mark, and the process mark is advanced.  If a non-string object is
returned (e.g., nil, t, 99), no further processing of the output occurs,
including autoreaction processing, and nothing is inserted into the buffer.

BUFFERNAME is either nil or a string naming the buffer to be created for the
process or network connection.  If nil, the name of the buffer will be ID.
At buffer-creation time, if the desired name is already in use, a unique name
is generated via generate-new-buffer-name.

SPAWNINFO is a list that specifies how to spawn the process or network
connection.  If TYPE is conn, then SPAWNINFO is either (HOST PORTNUM) or
(HOST SERVICE).  HOST is the Internet hostname to connect to.  PORTNUM is the
port number to connect to.  SERVICE is a string specifying the name of the
service to connect to.  If TYPE is proc, then SPAWNINFO is a list of strings.
The first element is a command to spawn, and the remaining elements are
argument strings (which can be omitted if the command takes no arguments).
The command is _not_ fed to a shell first, but a relative filename is searched
for in the directories listed in the variable exec-path.")


(defvar fpl-react-strip-returns t
  "*Controls whether return (control-M) characters are automatically stripped
from the output of processes spawned by fpl-react-spawn.  A value of t means to
strip them, nil means don't.")


(defvar fpl-react-reuse-buffers nil
  "*If non-nil, fpl-react-spawn will reuse an existing buffer without prompting
for confirmation.  In no case will it resuse an existing buffer that has a
live process or network connection associated with it.")


(defvar fpl-react-show-buffer t
  "*Controls whether the process buffer is made visible when the process or
network connection is spawned.  If non-nil, the buffer is made visible.
Otherwise, no explicit action is taken by this package to display the buffer.
This variable is not buffer-local.")


(defvar fpl-react-position-at-end t
  "*If non-nil, point is positioned at the end of the process buffer prior to
spawning the process or network connection and a newline is insered there if
necessary to place point at the beginning of a line.")


(defvar fpl-react-cleanup-hook nil
  "*A hook run from this package's cleanup code, which runs when the
process dies or the network connection closes or when the interaction buffer
is killed.")

(make-variable-buffer-local 'fpl-react-cleanup-hook)
(put 'fpl-react-cleanup-hook 'permanent-local t)


(defvar fpl-react-text-gap nil
  "*If non-nil, this variable must be an integer specifying the number of blank
lines to show between the bottom of the process buffer and the end of the window
in which it is displayed.  If nil, let Emacs scroll the window as it normally
does, which can result in the bottom half of the window being empty space.")

(make-variable-buffer-local 'fpl-react-text-gap)
(put 'fpl-react-text-gap 'permanent-local t)


(defvar fpl-react-point-marker nil
  "This variable is bound to a marker that specifies the position of point within
the process buffer at the moment immediately prior to the evaluation of any
autoreaction forms.  Do NOT change the marker or the value of this variable from
an autoreaction form.")

(make-variable-buffer-local 'fpl-react-point-marker)
(put 'fpl-react-point-marker 'permanent-local t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; User functional interface.  These are the only functions users should call
;; to use this package.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fpl-react-spawn (id)
  "Spawn a process or network connection according to the definition of the
variable fpl-react-processes.  ID is a string that specifies which process or
network connection to spawn.

When the process is spawned, if an interaction buffer with the desired name
already exists (see the variable fpl-react-processes), and that buffer is
associated with a live process, a new interaction buffer is created with a
unique name.  If one already exists but has no live process, the user is
prompted to confirm reusing that buffer.  If fpl-react-reuse-buffers is
non-nil, no prompting occurs and the existing buffer is simply reused,
regardless of its contents.

The process mark is set to the location of point in the interaction buffer, so
all new output is inserted there.  If fpl-react-position-at-end is non-nil,
point is first positioned to the end of the buffer.  Returns the process
object."

  (interactive (list (completing-read "Process: " fpl-react-processes
				      nil 'confirm nil 'minibuffer-history)))
  (let* ((procinfo (or (assoc id fpl-react-processes)
		       (error "fpl-react-spawn: no process found with id \"%s\""
			      id)))
	 (type (nth 1 procinfo))
	 (filter (nth 2 procinfo)) 
	 (buffername (nth 3 procinfo))
	 (spawninfo (nth 4 procinfo))
	 (spawnfunc (cond ((eq type 'conn) 'open-network-stream)
			  ((eq type 'proc) 'start-process)))
	 (process nil)
	 (orig-buffer nil)
	 (buffer nil))

    ;; Validate arguments.

    (if (not (memq type '(conn proc)))
	(error "fpl-react-spawn: invalid process type: %s!" (prin1-to-string type)))
    (if filter
	(if (not (or (and (symbolp filter)
			  (fboundp filter))
		     (and (listp filter)
			  (eq 'lambda (car filter)))))
	    (error "fpl-react-spawn: filter is not a function!")))

    ;; Find the buffer that will eventually become the process buffer.  We
    ;; do this here, so that we can switch to the buffer right away, rather
    ;; than waiting until the first output from the process or network
    ;; connection.
    ;;
    ;; If the buffer already exists but has no process or no live
    ;; process associated with it, ask the user if she wants to reuse
    ;; it.  If fpl-react-reuse-buffers is non-nil, don't ask, just reuse
    ;; it.

    (if (null buffername)
	(setq buffername id))

    (if (null (setq buffer (get-buffer buffername)))
	(setq buffer (get-buffer-create buffername))

      ;; The buffer already exists.  If it has a live process or
      ;; network connection, make a new buffer with a unique name.

      (if (or (and (setq process (get-buffer-process buffer))
		   (memq (process-status process) '(run stop open)))
	      (and (null fpl-react-reuse-buffers)
		   (not (y-or-n-p
			 (format "Buffer \"%s\" already exists -- reuse it? "
				 buffername)))))
	  (setq buffer (generate-new-buffer buffername))))

    (if fpl-react-show-buffer
	(switch-to-buffer buffer)
      (setq orig-buffer (current-buffer))
      (set-buffer buffer))

    (if fpl-react-position-at-end
	(progn
	  (goto-char (point-max))
	  (if (not (bolp))
	      (newline))))

    ;; Record the spawn ID and the user filter function.

    (setq fpl-react-id id
	  fpl-react-user-filter filter)

    ;; Set kill-buffer-hook to do cleanup.

    (make-local-hook 'kill-buffer-hook)
    (add-hook 'kill-buffer-hook 'fpl-react-kill-buffer-hook)

    ;; Spawn the process or open the network connection.  No buffer is
    ;; associated with the process/connection and it has no filter for a short
    ;; time, so there's a window of vulnerability here.  If any data arrives
    ;; from the process/connection before the filter is set, it is discarded!
    ;;
    ;; NOTE: Do as little work as possible from the moment the process is
    ;;       spawned until the moment the process filter is set.  Keep the
    ;;       window of vulnerability as small as possible.

    (if (null (setq process (apply spawnfunc id nil spawninfo)))
	(error "fpl-react-spawn: %s returned nil!" (prin1-to-string spawnfunc)))

    ;; Set up the process filter, process sentinel, and process buffer.
    ;; We must set the process filter _before_ setting the process buffer
    ;; otherwise we risk having some process output go to the buffer
    ;; unfiltered.

    (set-marker (process-mark process) (point))
    (set-process-filter process 'fpl-react-filter)
    (set-process-sentinel process 'fpl-react-sentinel)
    (set-process-buffer process buffer)

    ;; Return the process object.

    (if (null fpl-react-show-buffer)
	(set-buffer orig-buffer))
    process))


(defun fpl-react-register (id regexp form &optional replace replace-all)
  "Register an autoreaction form as associated with ID, a string.  When a line
of output from a process or network connection spawned by passing ID to
fpl-react-spawn matches REGEXP, evaluate FORM.  If FORM is a symbol bound as a
function, that function will be called with no arguments instead of merely
evaluating the symbol.  If the optional argument REPLACE is non-nil, then the
most recently registered autoreaction for ID that has the same REGEXP is
deregistered prior to registering the new one.  If the optional argument
REPLACE-ALL is non-nil, then all autoreactions for ID having the same REGEXP are
deregistered prior to registering the new one.

ID is a string that was (or will be) passed to fpl-react-spawn.  Note: if you
register your autoreaction forms after calling fpl-react-spawn, there might not
be enough time to register all of them before the process emits output that
you want to react to.  Note that ID's autoreactions remain registered until
explicitly deregistered by fpl-react-deregister or implicitly deregistered by
fpl-react-register.  Killing the process or the process buffer does not change
what autoreactions are registered to a given ID.

FORM is evaluated at most once per line of output.  If REGEXP matches more
than one string on a line, only the first match causes FORM to be evaluated.
REGEXP is only matched against individual lines of output.  REGEXP does not
match across newlines.  More than one autoreaction can be registered for a
given ID with the same REGEXP.

FORM is evaluated with the current buffer set to the buffer associated with
ID and with the symbols \"start\" and \"end\" bound to markers marking
the starting and ending buffer positions of the text that matched REGEXP.
Point is wherever the client of this package (a person or another package)
left it when FORM began evaluation.  FORM is free to alter the buffer in any
way it wants -- this package is policy-free in that regard.  But beware that
the user may be in the midst of typing input into the buffer, so modifying the
location of point or mark or which buffer is current may interfere with the
user's activity.

FORM is evaluated with \"fpl-react-sym\" bound to an uninterned symbol.  The
uninterned symbol's variable and function bindings are initially void, and its
property list is initially nil.  Each time FORM is evaluated, \"fpl-react-sym\"
will be bound to the same uninterned symbol, which will not be altered in any
way by this package -- or any other package, since it's uninterned.  The
uninterned symbol is a place for FORM to save state between evaluations.  If
you wish to avoid frequent use of

	(eval fpl-react-sym)

to retrieve the value of the uninterned symbol, use \"get\" and \"put\" to
store and access values in properties on the symbol as follows:

	(put fpl-react-sym 'counter 99)
	(message \"The counter is now %d\" (get fpl-react-sym 'counter))

This has the added benefit of allowing an arbitrary number of values to be
stored."

  ;; Validate arguments.

  (if (not (stringp id))
      (error "fpl-react-register: argument #1 is not a string: %s"
	     (prin1-to-string id)))
  (if (not (stringp regexp))
      (error "fpl-react-register: argument #2 is not a string: %s"
	     (prin1-to-string regexp)))
  (if (and (symbolp form)
	   (not (fboundp form)))
      (error "fpl-react-register: symbol %s is not bound as a function!"
	     (prin1-to-string form)))

  ;; Register FORM to be an autoreaction to REGEXP for ID.

  (let ((reactions (assoc id fpl-react-reactions)))

    ;; Handle REPLACE and REPLACE-ALL being non-nil.

    (if replace
	(fpl-react-deregister id regexp replace-all))

    (if reactions
	(setcdr reactions
		(cons (list regexp (make-symbol "xyzzy") form)
		      (cdr reactions)))
      (setq fpl-react-reactions
	    (cons (list id (list regexp (make-symbol "xyzzy") form))
		  fpl-react-reactions))))

  ;; Return t.

  t)


(defun fpl-react-deregister (id regexp &optional all)
  "Deregister the most recently registered autoreaction for the (ID,
REGEXP) pair.  If optional argument ALL is non-nil, then all of ID's
autoreactions for REGEXP are deregistered."

  ;; Validate arguments.

  (if (not (stringp id))
      (error "fpl-react-deregister: argument #1 is not a string!"))

  (let* ((id-entry (assoc id fpl-react-reactions))
	 (reactions (cdr id-entry))
	 (element nil))
    (if (and id-entry (null reactions))
	(error "fpl-react-deregister: fpl-react-reactions is corrupted!"))
    (if reactions
	(progn
	  (if all
	      (while (setq element (assoc regexp reactions))
		(setq reactions (delq element reactions)))
	    (if (setq element (assoc regexp reactions))
		(setq reactions (delq element reactions))))
	  (setcdr id-entry reactions)))))


(defun fpl-react-get-filter (moo-buffer)
  "Returns the user filter function installed for MOO-BUFFER, a MOO
interaction buffer."

  (let ((buffer (if (stringp moo-buffer)
		    (get-buffer moo-buffer)
		  moo-buffer)))
    (if (not (bufferp moo-buffer))
	(error "fpl-react-get-buffer: %s: no such buffer!"
	       (prin1-to-string moo-buffer)))

    (save-excursion
      (set-buffer buffer)
      fpl-react-user-filter)))


(defun fpl-react-set-filter (moo-buffer filter)
  "Installs FILTER as the user filter function for the MOO interaction
buffer MOO-BUFFER.  After this function is called, the previous user filter
function (if any) is no longer installed."

  (interactive "bMOO interaction buffer: \naFilter function: ")
  (if (not (bufferp (get-buffer moo-buffer)))
      (error "fpl-react-set-buffer: \"%s\" is not a buffer name!"
	     moo-buffer))
  (if (and filter
	   (not (fboundp filter))
	   (not (eq 'lambda (car-safe filter))))
      (error "fpl-react-set-filter: argument #2 is not a function!"))

  (save-excursion
    (set-buffer moo-buffer)
    (setq fpl-react-user-filter filter)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!
;;
;; Nothing below this comment should be of any concern to users of this
;; package.  All user interfaces are defined above.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar fpl-react-user-filter nil
  "A variable, local to all buffers, that is a user-supplied filter function
for the process in the buffer in which this variable is local.")

(make-variable-buffer-local 'fpl-react-user-filter)
(put 'fpl-react-user-filter 'permanent-local t)


(defvar fpl-react-process-buffer nil
  "A variable, local to all buffers, that is set to t when fpl-react-spawn
associates a process or network connection with a given buffer.")

(make-variable-buffer-local 'fpl-react-process-buffer)
(put 'fpl-react-process-buffer 'permanent-local t)


(defvar fpl-react-reactions nil
  "This variable's value is a list that specifies a form to evaluate whenever
a given regular expression appears in the output of a process.  Elements of
this list are of the form

	(id (REGEXP SYMBOL FORM)
	    (REGEXP SYMBOL FORM)
	    ...)

ID is a string passed to fpl-react-spawn and fpl-react-register.  ID uniquely
identifies a given process or network connection.  REGEXP is a regular
expression.  SYMBOL is an uninterned symbol which is guaranteed not to be set
or modified in any way by this package.  FORM is a form to be evaluated when a
line of process output matches REGEXP.  If FORM is a symbol, then its function
binding is called (with no arguments) instead of simply evaluating FORM as a
variable.  See the documentation for the function fpl-react-register.")


(defvar fpl-react-id nil
  "This variable is local to all buffers.  It's value is the ID string passed to
the invocation of fpl-react-spawn that resulted in the creation of the buffer.")

(make-variable-buffer-local 'fpl-react-id)
(put 'fpl-react-id 'permanent-local t)


(defvar fpl-react-current-line ""
  "A variable, local to all buffers, that holds the current incomplete line
of output from the process.  An incomplete line is one that does not yet have
a trailing newline.")

(make-variable-buffer-local 'fpl-react-current-line)
(put 'fpl-react-current-line 'permanent-local t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fpl-react-sentinel (process string)
  "Generic sentinel for processes started by fpl-react-spawn."
  (let ((proc-buffer (process-buffer process))
	(moving nil))
    (if proc-buffer
	(progn
	  (setq moving (= (point) (point-max)))

	  (save-excursion
	    (set-buffer proc-buffer)
	    (goto-char (point-max))
	    (insert (concat "\n\n" string)))

	  (if moving
	      (goto-char (point-max)))

	  (if (not (memq (process-status process) '(run stop open)))
	      (fpl-react-cleanup proc-buffer)))

      ;; The process buffer is gone, so alert the user via the minibuffer.

      (ding)
      (message (concat "Process " (process-name process) ": " string)))))


;; This next function is the heart of this package.  Change it only if you
;; truly understand how it works.  You have been warned.

(defun fpl-react-filter (process string)
  "Generic filter for processes started by fpl-react-spawn.  Do not make one of
your own functions the process filter unless you thoroughly understand this
function and what it is doing."
  (let ((marker (process-mark process))
	(orig-buffer (current-buffer))
	(prev-marker nil)
	(move-point nil)
	(proc-buffer (process-buffer process))
	(orig-point nil)
	(user-filter-value nil))

    ;; Do our business in an unwind-protect form so we don't accidentally
    ;; mess up the current buffer if something barfs.

    (unwind-protect
	(progn
	  (set-buffer proc-buffer)
	  (setq orig-point (point)
		move-point (>= (point) marker))
	  (toggle-read-only -1)
	  (setq fpl-react-process-buffer t)
	  (if (null (marker-position marker))
	      (set-marker marker (point-max) proc-buffer))
	  (setq prev-marker (copy-marker marker))

	  ;; Call user filter function if necessary.

	  (if fpl-react-user-filter
	      (setq string (funcall fpl-react-user-filter process string)))

	  ;; Don't do anything more unless user filter function returned a
	  ;; string.

	  (when (and (stringp string)
		     (> (length string) 0))
	    (goto-char marker)

	    ;; Insert the string into the process buffer.  We can't use
	    ;; insert-before-markers here, because that will cause prev-marker
	    ;; to move (and we don't want it to).

	    (insert string)
	    (set-marker marker (point) proc-buffer)

	    ;; If we just inserted text to left of point, move point.

	    (if move-point
		(setq orig-point (+ orig-point (length string))))

	    ;; Remove C-m characters if necessary.

	    (if fpl-react-strip-returns
		(while (search-backward "\C-m" (marker-position prev-marker) t)
		  (delete-char 1)))

	    ;; Leave point where the user expects it to be.

	    (goto-char orig-point)

	    ;; If there are any autoreactions registered for this process,
	    ;; do them now.

	    (if fpl-react-reactions
		(fpl-react-do-autoreactions prev-marker marker))))

      ;; The cleanup part of the unwind-protect form.

      (set-buffer orig-buffer))))


(defun fpl-react-do-autoreactions (start end)
  "Perform autoreactions for the text delineated by the markers START and END
in the current buffer.  Note that START and END may not mark line boundaries."

  ;; Validate arguments.

  (if (= start end)
      (error "fpl-react-do-autoreactions: arguments #1 and #2 are equal!"))

  (let ((bufs (mapcar 'marker-buffer (list start end))))
    (if (or (not (eq (car bufs) (car (cdr bufs))))
	    (not (eq (car bufs) (current-buffer))))
	(error "fpl-react-do-autoreactions: all buffers do not match!")))

  ;; For each newline-terminated line after this buffer location,
  ;; scan that line for autoreactions.  END must be a marker for this
  ;; all to work correctly, because an autoreaction might insert text
  ;; into a line.

  (save-excursion
    (goto-char start)
    (beginning-of-line)
    (let ((start-of-line (set-marker (make-marker) (point)))
	  (start-of-next-line (make-marker)))

      (while (search-forward "\n" end t)
	(set-marker start-of-next-line (point))
	(fpl-react-do-autoreact-line start-of-line start-of-next-line)
	(goto-char start-of-next-line)
	(set-marker start-of-line (marker-position start-of-next-line))))))


(defun fpl-react-do-autoreact-line (start end)
  "Perform all autoreactions for the single line of text delineated by the
markers START and END in the current buffer.  END is positioned after the
trailing newline.  When this function is called, point is wherever it was
before the text was inserted in the process buffer by fpl-react-filter, and the
process marker is immediately after the inserted text.  The latter is an
invariant which must always be maintained by this code.

If the autoreaction form returns the symbol fpl-react-final-autoreaction,
autoreaction processing terminates even if there remain autoreactions that
were not tested for."
  (let ((reactions (cdr (assoc fpl-react-id fpl-react-reactions))))
    (if (null reactions)
	(error "fpl-react-do-autoreact-line: empty reactions list for id \"%s\""
	       (prin1-to-string fpl-react-id)))

    (while reactions
      (if (eq 'fpl-react-final-autoreaction
	      (fpl-react-do-one-reaction (car reactions) start end))
	  (setq reactions nil)
	(setq reactions (cdr reactions))))))


(defun fpl-react-do-one-reaction (reaction start end)
  "Perform one autoreaction for a line of text in the current buffer
delineated by the markers START and END.  Returns nil if no autoreaction was
executed.  Otherwise, returns the value of the autoreaction form that was
evaluated."

;;  (message (format "regexp: \"%s\", start: %d, end: %d, buffer: \"%s\"\n"
;;  		   (car reaction) (marker-position start)
;;  		   (marker-position end)
;;  		   (buffer-substring start end)))
  (goto-char start)
  (let* ((regexp (car reaction))
	 (end-of-match (search-forward-regexp regexp end t)))
    (if end-of-match
	(save-match-data
	  (let ((fpl-react-sym (nth 1 reaction))
		(form (nth 2 reaction))
		(start (set-marker (make-marker) (match-beginning 0)))
		(end (set-marker (make-marker) end-of-match)))
	    (goto-char end-of-match)
	    (if (and (symbolp form)
		     (fboundp form))
		(funcall form)
	      (eval form)))))))


(defun fpl-react-kill-buffer-hook ()
  "Added to kill-buffer-hook to do cleanup when the user kills a buffer
created by this package.  When this function is called the buffer being killed
is current."
  (if fpl-react-process-buffer
      (fpl-react-cleanup (current-buffer))))


(defun fpl-react-cleanup (buffer)
  "Resets buffer-local variables in BUFFER, a buffer object."

  ;; Validate argument.

  (if (not (bufferp buffer))
      (error "fpl-react-cleanup: argument #1 is not a buffer!"))

  ;; Do the cleanup.

  (save-excursion
    (set-buffer buffer)
    (setq fpl-react-process-buffer nil
	  fpl-react-user-filter nil
	  fpl-react-id nil
	  fpl-react-current-line nil)
    (run-hooks 'fpl-react-cleanup-hook)))


(provide 'fpl-react)			; It's a feature!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Debugging code.  Remove this prior to release.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq debug nil)

(defun fpl-react-test ()
  "..."
  (interactive)
  (setq debug-on-error t)
  (define-key global-map "\C-c=" 'fpl-react-spawn)
  (put 'eval-expression	'disabled nil)
  (setq fpl-react-processes
	(cons '("tick" proc nil "*tick*" ("/s/users/franl/elisp/dev/tick"))
	      fpl-react-processes))
  (fpl-react-register "tick" "[0-9]+"
		      '(let ((num (buffer-substring start end))
			     (beg nil)
			     (ctr (get fpl-react-sym 'counter)))
			 (beginning-of-line)
			 (setq beg (point))
			 ;;(insert "OK: ")
			 ;;(forward-char 5)
			 ;;(insert "\n")
			 (end-of-line)
			 (delete-region beg (point))
			 (if (string= num "0")
			     (progn
			       (put fpl-react-sym 'counter 99)
			       (insert " [counter set to 99]"))
			   (insert (format " %d" (or ctr 0)))
			   (put fpl-react-sym 'counter (1- ctr))))
		      'replace 'replace-all))
