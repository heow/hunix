;; fpl-moo.el
;; Version: 1.1.22
;; Author: Francis Litterio (franl@world.std.com)
;;
;; This package is a MOO client for Emacs.  This package works fine in Emacs
;; version 20.4, but I don't know if it still works in version 19.  Let me know
;; if you have problems using this package in version 19.
;;
;; INSTALLATION INSTRUCTIONS:
;;
;; This package is based on fpl-react.el, so you must download that package as
;; well (it may have been included with this file in whatever archive you got
;; this file in).  Put both fpl-moo.el and fpl-react.el in some directory (I'll
;; call it ELISPDIR here), and add this code to your .emacs startup file:
;;
;; (setq load-path (append load-path '("/path/to/ELISPDIR")))
;; (require 'fpl-moo)
;; (setq fpl-moo-sites    ;; This is your personal list of MOO sites.
;;       '(("LambdaMOO"                ;; A site ID string of your choice.
;;          "lambda.moo.mud.org" 8888  ;; Host and port #.
;;          prompt "LambdaMOO: ")      ;; Prompt string.
;;
;;         ("LambdaMOO-Joe"
;;          "lambda.moo.mud.org" 8888
;;          prompt "LambdaMOO: "
;;          player "Joe"               ;; Auto-connect as player Joe.
;;          password ask)              ;; Prompt for password.
;;
;;         ("LambdaMOO-Guest"
;;          "lambda.moo.mud.org" 8888
;;          prompt "LambdaMOO: "
;;          connect "guest")))         ;; Auto-connect as guest, no password.
;;
;; Then define a keybinding for the function fpl-moo-connect, like this:
;;
;; (define-key global-map "\C-cm" 'fpl-moo-connect)
;;
;; When you type that key sequence, you are prompted to enter one of the site ID
;; strings you provided in the variable fpl-moo-sites.  Type TAB at the prompt
;; to see a list of possible IDs.  There are several popular MOOs already built
;; into this package, so you may not even need to set fpl-moo-sites.  If you
;; just press ENTER at the prompt, you are then prompted to enter a hostname and
;; port number in the format HOSTNAME:PORTNUM.


(require 'cl)
(require 'fpl-react)

(defconst fpl-moo-version "1.1.22" "Version number of package fpl-moo.el.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; User options.  These are the only variables you should have to change
;; to configure this package.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defvar fpl-moo-sites nil
  "\\<fpl-moo-mode-map>
*Use this variable to specify your favorite MOO sites to connect to.
There's also a list of builtin sites (so this package is useful right away),
kept in the variable fpl-moo-builtin-sites.  The function fpl-moo-connect
consults fpl-moo-sites before fpl-moo-builtin-sites, so you can override any of
the builtin sites.  The value of fpl-moo-sites is a list, each element of which
is a list of this form (where bracketed elements are optional):

	(ID HOSTNAME PORTNUMBER [ATTRIBUTE VALUE] ...)

ID is a string that uniquely identifies the site.  Supply ID to the function
fpl-moo-connect in the minibuffer (interactively) or as an argument
(programmatically).

HOSTNAME is a string specifying a host on the Internet in symbolic or dotted
decimal form (e.g., \"foo.bar.com\" or \"128.197.2.62\").

PORTNUMBER is the TCP/IP port number to which the connection is made.

All remaining elements must come in pairs.  Each pair consists of a symbol
which is used to identify an attribute and an arbitrary Lisp form which is the
value of that attribute.  Here's a list of the supported attributes and a
description of their values:

connect   A string specifying arguments to a \"connect\" command issued by this
	  client on your behalf when you first connect.  A value of \"goober
	  froboz\" means to login as player \"goober\" with password \"froboz\".
	  A value of \"guest\" means to connect as player \"guest\" without a
	  password.  See attributes player and password for a more flexible
	  way to auto-connect.  This attribute is ignored if either the player
	  or password attributes are present.

player    A string specifying a player name to auto-connect as.  This attribute
	  supercedes the connect attribute.  If this attribute is absent, but
	  the password attribute is present, you are prompted to enter a player
	  name.

password  A string specifying the MOO password to use for the userid specified
	  in the player attribute.  The presense of this attribute cuases the
	  connect attribute to be ignored.  If this attribute is absent, but
	  the player attribute is present, you are prompted to enter a
	  password.  If this attribute's value is the symbol ask, you are
	  prompted to enter a password and what you type is hidden.  If this
	  attribute's value is the symbol ask-no-hide, you are prompted to
	  enter a password and you can see the password as you enter it.

prompt	  A string specifying a prompt to display at the bottom of the MOO
	  interaction buffer.  The prompt may contain newline characters.
	  Leading newlines cause blank lines to appear before the remainder of
	  the prompt.  If you desire no prompt for this connection, specify
	  the empty string (\"\") as the value of this attribute.  If you
	  desire the default prompt (specified in the variable
	  fpl-moo-default-prompt), omit this attribute.  You can change the
	  prompt dynamically by typing \"\\[fpl-moo-set-prompt]\" in the MOO
	  interaction buffer.

commands  A string specifying commands to be sent to the MOO upon first
	  connecting.  These commands are sent _after_ automatic login via
	  the connect attribute (see above).  If you don't want any commands
	  sent automatically, omit this attribute.  If this attribute's value
	  does not end with a newline, one is appended.

history	  A number specifying the maximum number of commands saved in the
	  command history for the corresponding MOO's interaction buffer.
	  If this attribute is not specified, the default value is taken
	  from fpl-moo-history-max.  If you specify 0 for this attribute,
	  the corresponding MOO connection will keep no command history,
	  and it is not possible to activate command history later.")


(defvar fpl-moo-builtin-sites
  '(("Boo MOO"		     "pinot.callamer.com" 1234 prompt "Boo MOO: ")
    ("ChibaMOO"		     "chiba.picosof.com" 7777 prompt "ChibaMOO: ")
    ("CyberSphere"	     "vv.com" 7777 prompt "CyberSphere: ")
    ("Diversity University"  "206.212.27.32" 8888 prompt "Diversity University: ")
    ("Dragonsfire"	     "moo.eskimo.com" 7777 prompt "Dragonsfire: ")
    ("Entropy"		     "monsoon.weather.brockport.edu" 7777 prompt "Entropy: ")
    ("Eon"		     "mcmuse.mc.maricopa.edu" 8888 prompt "Eon: ")
    ("Harper's Tale"	     "srcrisc.srce.hr" 8888 prompt "Harper's Tale: ")
    ("Jay's House"	     "jhm.ccs.neu.edu" 1709 prompt "Jay's House: ")
    ("LambdaMOO"	     "lambda.moo.mud.org" 8888 prompt "LambdaMOO: ")
    ("d2dream"           "dtdream.mujido.com"  9911 prompt "d2dream: ")
    ("Metaverse"	     "metaverse.io.com" 7777 prompt "Metaverse: ")
    ("MuMoo"		     "chestnut.enmu.edu" 7777 prompt "MuMoo: ")
    ("PMC"		     "hero.village.virginia.edu" 7777 prompt "PMC: ")
    ("Road to Nowhere"	     "freak.org" 7777 prompt "Road to Nowhere: ")
    ("StarMOO"		     "asimov.elk-grove.k12.il.us" 6879 prompt "StarMOO: ")
    ("SyrinxMOO"	     "cimsun.aidt.edu" 2112 prompt "SyrinxMOO: ")
    ("TNG-MOO"		     "tng-moo.dungeon.com" 1701 prompt "TNG-MOO: ")
    ("TrekMOO"		     "trekmoo.microserve.com" 2499 prompt "TrekMOO: ")
    ("University of MOO"     "moo.cs.uwindsor.ca" 7777 prompt "University of MOO: ")
    ("ValhallaMOO"	     "valhalla.acusd.edu" 4444 prompt "ValhallaMOO: ")
    ("ZenMOO"		     "cheshire.cc.oxy.edu" 7777 prompt "ZenMOO: "))
  "A ready-made list of MOO sites that this package can connect to.  None of
these sites are configured to automatically connect.  This variable's value has
the same form as the variable fpl-moo-sites.  If you're thinking of altering
this variable, instead set fpl-moo-sites in your .emacs file.")


(defvar fpl-moo-default-connect-id nil
  "*If non-nil, this should be a string that will appear in the minibuffer
as the default MOO ID to connect to when fpl-moo-connect is invoked
interactively.  If fpl-moo-connect has been invoked before, then this
variable is ignored in favor of the most recently entered MOO id.")


(defvar fpl-moo-default-prompt "> "
  "*A string specifying the prompt used in the MOO interaction buffer if no
prompt was specified via the prompt attribute in fpl-moo-sites.  If you want
no prompt at all, set this variable to the empty string (\"\") prior to
opening a MOO connection with fpl-moo-connect.")


(defvar fpl-moo-keep-prompt-near-bottom t
  "*If non-nil, the prompt is kept within fpl-moo-max-text-gap lines of the
bottom of the window at all times.")


(defvar fpl-moo-max-text-gap 0
  "\\<fpl-moo-mode-map>
*If non-nil, this variable must be an integer that specifies the number of blank
lines that will appear at the bottom of the window (when
fpl-moo-keep-prompt-near-bottom is non-nil) or when you type
\\[fpl-moo-display-max-text] in a MOO interaction buffer.  If nil, Emacs
scrolls the window normally, but this can result in empty space in the
bottom half of the window.")


(defvar fpl-moo-control-u-kills-line nil
  "*If non-nil, you can type C-u instead of C-c C-u to kill the current input
line.  This lets you treat the MOO prompt more like a shell prompt, but it
blocks the use of C-u as a command prefix argument in the MOO interaction
buffer.  When this variable is non-nil, C-c C-u invokes universal-argument.")


(defvar fpl-moo-mode-hook nil
  "*Functions on this hook are called when fpl-moo-mode is started in the MOO
connection buffer.  Use this hook to customize the keymap fpl-moo-mode-map or
just about anything else.")


(defvar fpl-moo-mode-command-hook nil
  "\\<fpl-moo-mode-map>
*Functions on this hook are called just before an interactive command
is sent to the MOO.  During the execution of these functions, the command
is accessible in the variable fpl-moo-command.  Modifying that variable
modified the actual command sent to the MOO.")


(defvar fpl-moo-edit-mode-hook nil
  "*The functions added to this hook are called when fpl-moo-edit-mode is
activated in a MOO Edit buffer.  Use this hook to configure
fpl-moo-edit-mode-map and to configure the MOO Edit buffer (e.g., to set
fill-column).")


(defvar fpl-moo-connect-hook nil
  "*The functions on this hook are called after a new MOO connection is made.
When these functions are called, the connection is open and the MOO
interaction buffer is the current buffer, and all automatic interactions have
completed (such as auto-login, etc.).  These hook functions can send commands
to the MOO using (process-send-string (get-buffer-process (current-buffer))
\"command\"), but they should _not_ assume anything about the locations of point
or mark or about the contents of the buffer.")


(defvar fpl-moo-history-max 50
  "*Specifies the default maximum number of commands to save in the command
history for each MOO interaction buffer.  If you desire a different maximum for
a specific entry in fpl-moo-sites, use the history attribute in that entry.  Set
this value to 0 to disable command history (except in those MOO interaction
buffers for which fpl-moo-sites specifies a non-zero history attribute).  Once a
MOO interaction buffer is created without command history, it is not possible
later to activate command history for that buffer.")


(defvar fpl-moo-history-access-anywhere nil
  "\\<fpl-moo-mode-map>
*If non-nil, you can move through the command history regardless of
where point is positioned in the MOO interaction buffer.  If nil,
\\[fpl-moo-history-previous] and \\[fpl-moo-history-next] behave like \\[previous-line] and \\[next-line] respectively
when point is not positioned at the prompt.  See also: documentation
for variables fpl-moo-previous-line-command and fpl-moo-next-line-command.")


(defvar fpl-moo-previous-line-command (function previous-line)
  "\\<fpl-moo-mode-map>
*The value of this variable is a function taking an optional integer
argument.  That function is invoked by \\[fpl-moo-history-previous] when point
is positioned before the current command and fpl-moo-history-access-anywhere
is nil.")


(defvar fpl-moo-next-line-command (function next-line)
  "\\<fpl-moo-mode-map>
*The value of this variable is a function taking an optional integer
argument.  That function is invoked by \\[fpl-moo-history-next] when point
is positioned before the current command and fpl-moo-history-access-anywhere
is nil.")


(defvar fpl-moo-new-frame nil
  "*This variable applies only if window-system is non-nil.  If
non-nil, fpl-moo-connect creates new frame for each new MOO
connection.")


(defvar fpl-moo-edit-new-frame t
  "*This variable applies only if window-system is non-nil.  If non-nil, new MOO
Edit buffers are displayed in new frames.  If its value is not nil and not t, it
is an alist specifying the frame parameters to use when creating the new frame
(see the documentation for the function frame-parameters for more
information).")


;; TODO: Not used yet.  Ultimately, we want to eliminate a global face in favor
;; of a face per MOO interaction buffer, each of which is created at
;; connect-time, so the user can alter these variables between connections.
;; TODO: Also need two new functions: fpl-moo-set-prompt-foreground and
;; fpl-moo-set-prompt-background.
;;
;;(defvar fpl-moo-prompt-background (or (cdr (assoc 'background-color
;;						  default-frame-alist))
;;				      "white")
;;  "*This variable specifies the background color of the prompt that appears in
;;MOO interaction buffers.  Presently, all MOO interaction buffers share the same
;;prompt background color.")
;;
;;
;;(defvar fpl-moo-prompt-foreground "red")
;;  "*This variable specifies the foreground color of the prompt that appears in
;;MOO interaction buffers.  Presently, all MOO interaction buffers share the same
;;prompt foreground color.")


(when (not (facep 'fpl-moo-default-highlight-face))
  (make-face 'fpl-moo-default-highlight-face)
  (set-face-foreground 'fpl-moo-default-highlight-face "lightblue"))


(defvar fpl-moo-highlight-face 'fpl-moo-default-highlight-face
  "*This variable applies only if window-system is non-nil.  If this
variable is non-nil, its value is a symbol specifying a face to use to
highlight commands in the MOO interaction buffer.  If its value is nil, no
highlighting occurs.  Changing this variable does not alter the faces of
already-highlit commands, but all newly entered commands will use the new
face.")


(defvar fpl-moo-edit-buffer-disposition 'hide
  "*Specifies what to do with MOO Edit buffers after their contents are sent
to the MOO.  This variable's value is one of these symbols with these meanings:

'keep		Means keep the buffer displayed.

'hide		Means stop displaying the buffer, but do not kill it.  If
		fpl-moo-edit-new-frame is set to a non-nil value, the frame
		displaying the MOO Edit buffer is deleted and the buffer
		is buried, otherwise the buffer is simply buried.

'kill		Means kill the buffer and delete the window and frame displaying
		it.  This is dangerous if you are programming verbs.  A syntax
		error in your verb causes the verb not to be programmed, but
		the edit buffer is killed anyway.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; User functional interface.  These are the only functions users should call
;; to use this package.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun fpl-moo-connect (id &optional no-new-frame)
  "Connect to the MOO specified by ID (see the documentation for the variable
fpl-moo-sites).  If optional argument NO-NEW-FRAME is non-nil, the value of
fpl-moo-new-frame is ignored and the MOO interaction buffer is displayed in the
currently selected frame.  Interactively, provide a prefix argument to prevent
a new frame from being created."

  (interactive (list (let ((completion-ignore-case t))
		       (completing-read "MOO id (or RET to enter host/port): "
					(append '((""))
						fpl-moo-sites
						fpl-moo-builtin-sites)
					nil 'confirm
					(cons (or (car fpl-moo-id-history)
						  fpl-moo-default-connect-id
						  "")
					      0)
					(cons 'fpl-moo-id-history 1)))
		     current-prefix-arg))
  ;; Validate argument.

  (if (not (stringp id))
      (error "fpl-moo-connect: argument #1 not a string!"))

  ;; Does the user want to enter the hostname and port manually?

  (if (string= "" id)
      (let ((host+port)
	    (colonpos)
	    (hostname)
	    (port)
	    (moo-id)
	    (site))
	(setq host+port
	      (read-from-minibuffer "Enter hostname:port (in that form): "
				    (cons (or (car fpl-moo-hostport-history) "") 0)
				    nil nil (cons 'fpl-moo-hostport-history 1))
	      colonpos (save-match-data (string-match ":" host+port)))
	(if (null colonpos)
	    (error "Invalid hostname:port format!"))
	(setq hostname (substring host+port 0 colonpos)
	      port (string-to-int (substring host+port (1+ colonpos) nil)))
	(if (= 0 port)
	    (error "Port number must be a string of digits!"))
	(setq moo-id (format "%s:%s" hostname port)
	      site (list (list moo-id hostname port
			       'synthetic t
			       'prompt (concat moo-id ": "))))
	(setq id moo-id)
	(if (not (member site fpl-moo-sites))
	    (setq fpl-moo-sites (append site fpl-moo-sites)))))

  ;; Initialize.

  (fpl-moo-init-process-list)
  (fpl-moo-init-autoreactions id)

  ;; Make a new frame?

  (if (and (null no-new-frame)
	   window-system
	   fpl-moo-new-frame)
      (select-frame (make-frame)))

  ;; Determine the prompt.

  (let ((prompt (fpl-moo-attribute id 'prompt))
	(connect-command nil))
    (if (null prompt)
	(setq prompt fpl-moo-default-prompt))
    (if (not (stringp prompt))
	(setq prompt "> "))

    ;; Collect auto-connect information

    (setq connect-command (fpl-moo-get-connect-command id))

    ;; Spawn the network connection.

    (let ((fpl-react-show-buffer t)
	  (fpl-react-position-at-end t)
	  (connection nil))
      (if (null (setq connection (fpl-react-spawn id)))
	  (error "fpl-moo-connect: connection failed!"))

      ;; The MOO interaction buffer is now current, so we can access
      ;; buffer-local variables.

      (add-hook 'fpl-react-cleanup-hook 'fpl-moo-cleanup)
      (setq fpl-moo-process-mark (process-mark connection)
	    fpl-moo-prompt prompt
	    fpl-moo-id id
	    fpl-moo-id-buffer-alist (cons (cons id (current-buffer))
					  fpl-moo-id-buffer-alist)
	    fpl-react-text-gap fpl-moo-max-text-gap)

      (make-local-variable 'scroll-conservatively)
      (put 'scroll-conservatively 'permanent-local t)
      (setq scroll-conservatively 100)

      (goto-char fpl-moo-process-mark)
      (insert fpl-moo-prompt)
      (fpl-moo-highlight fpl-moo-process-mark (point))

      ;; Auto-connect if user desires.

      (if connect-command
	  (process-send-string connection connect-command))

      ;; Send any initial commands.

      (let ((commands (fpl-moo-attribute fpl-moo-id 'commands)))
	(if (and commands (stringp commands))
	    (progn
	      (if (not (string= "\n" (substring commands -1 nil)))
		  (setq commands (concat commands "\n")))
	      (process-send-string connection commands)))))

    (fpl-moo-mode)
    (run-hooks 'fpl-moo-connect-hook)

    ;; Maybe define C-u to kill the current input line in the MOO interaction
    ;; buffer.  We do this here so as to delay as long as possible before
    ;; examining fpl-moo-control-u-kills-line.  This lets the user set the
    ;; variable in functions that have been added to fpl-moo-connect-hook.

    (when fpl-moo-control-u-kills-line
      (define-key (current-local-map) "\C-u"	 'fpl-moo-kill-line)
      (define-key (current-local-map) "\C-c\C-u" 'universal-argument))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!  ATTENTION!
;;
;; Nothing below this comment should be of any concern to users of this
;; package.  All user interfaces are defined above.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defvar fpl-moo-id-history nil
  "Contains the history of responses entered by the user to the ID prompt
displayed by fpl-moo-connect.")


(defvar fpl-moo-hostport-history nil
  "Contains the history of responses entered by the user to the HOSTNAME:PORTNUM
prompt displayed by fpl-moo-connect.")


(defvar fpl-moo-lines-history nil
  "Contains the history of responses entered by the user to the line-count
prompt displayed by fpl-moo-send-buffer.")


(defvar fpl-moo-seconds-history nil
  "Contains the history of responses entered by the user to the seconds-to-pause
prompt displayed by fpl-moo-send-buffer.")


(defvar fpl-moo-id nil
  "Holds a string which is the value of ID passed to fpl-moo-connect for this
MOO interaction buffer.  This variable is local to all buffers.  This variable
is used to mark MOO interaction buffers, so it must be nil in any buffer that is
not a MOO interaction buffer.  This variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-id)
(put 'fpl-moo-id 'permanent-local t)


(defvar fpl-moo-id-buffer-alist nil
  "Holds an alist of (MOOID . BUFFER) elements, where MOOID is the string
passed to fpl-moo-connect that created a MOO connection, and BUFFER is the
buffer object for that connection.  This variable must not be local to any
buffer.")


(defvar fpl-moo-prompt ""
  "\\<fpl-moo-mode-map>
Holds the prompt string for each MOO interaction buffer.  DO NOT set
this variable directly!  Instead, type \"\\[fpl-moo-set-prompt]\" in
the MOO interaction buffer.  This variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-prompt)
(put 'fpl-moo-prompt 'permanent-local t)


(defvar fpl-moo-process-mark nil
  "This is the process mark in the buffer that is associated with the
current MOO connection.  Do not set it directly.  It's value is
maintained in a consistent manner by the code in this package.  If
it's value is not correct all of the time, bad things happen.  This
variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-process-mark)
(put 'fpl-moo-process-mark 'permanent-local t)


(defun fpl-moo-get-connect-command (id)
  "Returns the auto-connect command after collecting the player name and password.
Returns nil if auto-connection should not happen."
  (let ((connect (fpl-moo-attribute id 'connect))
	(player (fpl-moo-attribute id 'player))
	(password (fpl-moo-attribute id 'password))
	(command "")
	(pw-reader (function read-passwd)))
    (if (or connect player password)
	(if (not (or player password))
	    (concat "connect " connect "\n")
	  (if (null player)
	      (setq player (read-string "MOO player name: ")))
	  (when (or (null password)
		    (memq password '(ask ask-no-hide)))
	    (if (eq password 'ask-no-hide)
		(setq pw-reader (function read-string)))
	    (setq password (funcall pw-reader (concat player "'s MOO password: "))))
	  (concat "connect " player " " password "\n")))))

(defun fpl-moo-init-process-list ()
  "Prepend builtin and user MOO site entries to fpl-react-processes.  Do this
before each connection is spawned so that we don't miss any changes the user
makes to fpl-moo-sites between calls to fpl-moo-connect."
  (let ((sites (append fpl-moo-sites fpl-moo-builtin-sites))
	(one-site nil)
	(hostname nil))
    (while sites
      (setq one-site (car sites))
      (setq fpl-react-processes
	    (cons (list (car one-site) 'conn nil nil (list (cadr one-site)
							   (caddr one-site)))
		  fpl-react-processes))
      (setq sites (cdr sites)))))


(defun fpl-moo-init-autoreactions (id)
  "Set up autoreactions for handling things like local editing."

  ;; The first autoreaction registered is the last one processed.
  ;; We need to do line wrapping last, so we must register it first.

  (fpl-react-register id "^.+$" 'fpl-moo-wrap-line 'replace 'all)
  (fpl-react-register id "^#\\$# edit name: .* upload: " 'fpl-moo-local-edit
		      'replace 'all))


(defun fpl-moo-attribute (id attribute)
  "Finds the element of either fpl-moo-sites or fpl-moo-builtin-sites identified
by the string ID, and returns the Lisp form associated with the symbol
ATTRIBUTE in that element.  If no such ATTRIBUTE exists, returns nil.  See the
documentation for the variable fpl-moo-sites."
  (if (not (stringp id))
      (error "fpl-moo-attribute: argument #1 is not a string!"))
  (if (not (symbolp attribute))
      (error "fpl-moo-attribute: argument #2 is not a symbol!"))

  (let ((element (or (assoc id fpl-moo-sites)
		     (assoc id fpl-moo-builtin-sites)))
	(scanner nil)
	(result nil))
    (if (null element)
	nil
      (setq element (cdr (cdr (cdr element)))
	    scanner element)
      (while scanner
	(if (eq (car scanner) attribute)
	    (setq result (car (cdr scanner))
		  scanner nil))
	(setq scanner (cdr (cdr scanner))))
      result)))


(defun fpl-moo-mode-pre-command-hook ()
  "Added to pre-command-hook in each MOO interaction buffer.  It makes sure that
insertion commands cause input to go to the end of the buffer if point is
positioned before the input line."
  (if (and (eq this-command 'self-insert-command)
	   (< (point) (+ fpl-moo-process-mark (length fpl-moo-prompt))))
      (goto-char (point-max))
    (when (and (memq this-command
		     '(delete-backward-char
		       backward-delete-char-untabify
		       backward-kill-word
		       backward-kill-paragraph
		       backward-kill-sentence))
	       (= (point) (+ fpl-moo-process-mark (length fpl-moo-prompt))))
      ;; This is not the best solution, because backward-kill-paragraph and
      ;; -sentence can delete the "x" and part or all of the prompt!
      ;; One option is to ignore delete commands in this hook and cleanup
      ;; after them in fpl-moo-mode-post-command-hook.
      (insert "x"))))


(defun fpl-moo-mode-post-command-hook ()
  "Added to post-command-hook in each MOO interaction buffer."
  (save-excursion
    (if (not (= fpl-moo-process-mark (point)))
	(goto-char fpl-moo-process-mark))

    ;; We are now positioned at the process mark.  Make sure there's a valid
    ;; prompt just to the right of this location.  This doesn't cleanly handle
    ;; the case where the prompt is partially deleted.  That can be solved by
    ;; using the read-only text property.

    (when (not (looking-at fpl-moo-prompt))
      (insert fpl-moo-prompt)
      (fpl-moo-highlight (marker-position fpl-moo-process-mark) (point-max))))

  ;; Highlight the prompt and the user's command text.  We only do this when
  ;; point is past fpl-moo-process-mark because fpl-moo-highlight has the
  ;; annoying side-effect of deactivating the mark which dehighlights the region
  ;; in transient-mark-mode.

  (if (> (point) fpl-moo-process-mark)
      (fpl-moo-highlight (marker-position fpl-moo-process-mark) (point-max)))
  
  ;; If point is at or past the process-mark, then the user is "at the
  ;; prompt" and we display the maximum possible text (unless
  ;; configured not to).  We also prevent the user from positioning
  ;; the cursor over the prompt itself (something that most people
  ;; find confusing).  Thanks to Andreas Bogk for making me do this!

  (when (and fpl-moo-keep-prompt-near-bottom
	     (>= (window-point (selected-window)) fpl-moo-process-mark))
      (fpl-moo-display-max-text)

      ;; This should be done by setting the 'intangible text property on the
      ;; prompt.
      (let ((end-of-prompt (+ fpl-moo-process-mark (length fpl-moo-prompt))))
	(if (< (point) end-of-prompt)
	    (goto-char end-of-prompt)))))


(defun fpl-moo-highlight (start end)
  "Highlight the text in the current buffer between START and END using the
face specified by fpl-moo-highlight-face.  If fpl-moo-highlight-face is nil,
this function does nothing."
  (if (and fpl-moo-highlight-face window-system)
      (put-text-property start end 'face fpl-moo-highlight-face)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support MOO interaction mode.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar fpl-moo-mode-map nil
  "Keymap for fpl-moo-mode.  Customize this keymap via fpl-moo-mode-hook.

Special commands:

\\{fpl-moo-mode-map}
")


;; Initialize fpl-moo-mode-map.

(if (null fpl-moo-mode-map)
    (setq fpl-moo-mode-map
	  (let ((map (make-sparse-keymap)))
	    (define-key map "\C-a"	'fpl-moo-beginning-of-line)
	    (define-key map "\C-m"	'fpl-moo-send-line)
	    (define-key map "\C-ce"	'fpl-moo-display-edit-buffer)
	    (define-key map "\C-cw"	'fpl-moo-toggle-linewrap)
	    (define-key map "\C-c\C-b"	'fpl-moo-send-buffer)
	    (define-key map "\C-cd"	'fpl-moo-kill-last-edit-buffer)
	    (define-key map "\C-c\C-d"	'fpl-moo-kill-all-edit-buffers)
	    (define-key map "\C-c\C-e"	'fpl-moo-edit-display-last-buffer)
	    (define-key map "\C-c\C-r"	'fpl-moo-display-max-text)
	    (define-key map "\C-c\C-u"	'fpl-moo-kill-line)
	    (define-key map "\C-c\C-c"	'fpl-moo-clear-buffer)
	    (define-key map "\C-cp"	'fpl-moo-set-prompt)
	    (define-key map "\M-\r"	'fpl-moo-display-max-text)
	    (define-key map "\C-n"	'fpl-moo-history-next)
	    (define-key map "\C-p"	'fpl-moo-history-previous)
	    (define-key map "\M-n"	'next-line)
	    (define-key map "\M-p"	'previous-line)
	    (define-key map [down]	'fpl-moo-history-next)
	    (define-key map [up]	'fpl-moo-history-previous)
	    (define-key map [M-down]	'next-line)
	    (define-key map [M-up]	'previous-line)
	    map)))


(defun fpl-moo-mode ()
  "MOO interaction mode, a major mode used by the package fpl-moo.el to allow
user interaction with a MOO.

Special commands:

\\{fpl-moo-mode-map}
"
  (interactive)

  ;; First, the standard major mode stuff.

  (kill-all-local-variables)
  (use-local-map fpl-moo-mode-map)
  (setq mode-name "MOO")
  (setq major-mode 'fpl-moo-mode)

  ;; Second, MOO mode stuff.  Be careful not to do anything that will
  ;; break if fpl-moo-mode is switched off then on again by the user.

  (make-local-hook 'pre-command-hook)
  (add-hook 'pre-command-hook 'fpl-moo-mode-pre-command-hook 'append 'local)
  (make-local-hook 'post-command-hook)
  (add-hook 'post-command-hook 'fpl-moo-mode-post-command-hook 'append 'local)

  ;; Make the command history vector, fpl-moo-history, if necessary.
  ;; If no history is being kept, leave fpl-moo-history set to nil.

  (if (null fpl-moo-history)
      (let ((site-history-max (fpl-moo-attribute fpl-moo-id 'history))
	    (max nil))
	(if (and site-history-max
		 (not (integerp site-history-max)))
	    (setq site-history-max nil))

	(setq max (or site-history-max fpl-moo-history-max))
	(if (> max 0)
	    (setq fpl-moo-history
		  (make-vector max nil)))))

  ;; Lastly, run user hook functions.

  (run-hooks 'fpl-moo-mode-hook))

  
(defun fpl-moo-set-prompt (&optional new-prompt)
  "\\<fpl-moo-mode-map>
Set the prompt for the MOO connection associated with the current buffer.
This is bound to \"\\[fpl-moo-set-prompt]\" in every MOO
interaction buffer."
  (interactive "sNew prompt: ")
  (if (null fpl-moo-id)
      (error "fpl-moo-set-prompt: this is not a MOO interaction buffer!"))

  (if (null new-prompt)
      (setq new-prompt fpl-moo-prompt))

  ;; TODO: Use a new marker (fpl-moo-end-prompt) to mark the end of the prompt.
  ;; This function should delete all text between fpl-moo-process-mark and
  ;; fpl-moo-end-prompt prior to inserting the new prompt.  This function should
  ;; be called from the rest of this package to restore the prompt.

  (let* ((here (set-marker (make-marker) (point)))
	 (end-of-prompt (+ fpl-moo-process-mark (length fpl-moo-prompt)))
	 (go-back (not (= end-of-prompt here))))
    (goto-char end-of-prompt)
    (delete-region fpl-moo-process-mark end-of-prompt)
    (insert new-prompt)
    (fpl-moo-highlight fpl-moo-process-mark (point))
    (setq fpl-moo-prompt new-prompt)
    (if go-back
	(goto-char here))))


(defun fpl-moo-display-max-text (&optional window)
  "Scroll WINDOW (or the selected window) so as to display the maximum amount of
text.  If WINDOW is non-nil and a valid window, select that window first."
  (interactive)
  (if window
      (select-window window))
  (let ((here (point)))
    (goto-char (point-max))
    (recenter (- (1+ fpl-moo-max-text-gap)))
    (goto-char here)))


;; This seems excessive.  Don't use it yet.  Is there a better way?
;; This _could_ be used to dynamically re-wrap paragraphs when the window
;; width changes!

(defun fpl-moo-window-size-change-handler (frame)
  "Finds any MOO interaction buffer windows on FRAME, selects each one, and calls
fpl-moo-display-max-text after selecting each one."
  (let ((startwin (frame-first-window))
	(curwin nil)
	(done nil))
    (setq curwin startwin)
    (while (not done)
      (select-window curwin)
      (if (and fpl-moo-id
	       (>= (window-point) fpl-moo-process-mark))
	  (fpl-moo-display-max-text))

      (setq curwin (next-window curwin 'nominibuf nil))
      (setq done (eq curwin startwin)))))

;; This setq is never undone, because we can never know when it is
;; safe to remove our function from the list.

;; This breaks draging mode lines when multiple windows are displayed!
;;
;; (if (not (memq (function fpl-moo-window-size-change-handler)
;; 	       window-size-change-functions))
;;     (setq window-size-change-functions
;; 	  (cons (function fpl-moo-window-size-change-handler)
;; 		window-size-change-functions)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support editing and sending the command line.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fpl-moo-send-line ()
  "\\<fpl-moo-mode-map>
When point is positioned after the last prompt in the current MOO buffer, sends
all text past the end of the last prompt to the MOO as a command.  If there is
no text following the prompt, sends a single newline character.

If there is no prompt in the current MOO interaction buffer, sends all text
after the process mark.  If point is not after the prompt, moves point to the
end of the buffer, and sends no command."

  (interactive)
  (let ((command nil)
	(end-of-prompt nil)
	(process (get-buffer-process (current-buffer))))
    (if (or (null process)
	    (not (eq (process-status process) 'open)))
	(error "fpl-moo-send-line: current buffer has no connection!"))
    (if (null fpl-moo-process-mark)
	(error "fpl-moo-send-line: current buffer's process-mark not set!"))

    ;; Find the right end of the most recent prompt in the buffer.

    (save-excursion
      (goto-char fpl-moo-process-mark)
      (if (not (looking-at fpl-moo-prompt))
	  ;; This should never happen now.
	  (insert fpl-moo-prompt)))
    (setq end-of-prompt (+ fpl-moo-process-mark (length fpl-moo-prompt)))

    (if (< (point) end-of-prompt)
	(goto-char (point-max))	;; No command sent ... just move point.

      ;; Extract a command from the buffer and send it to the MOO.
      
      ;; IMPORTANT: Make sure that point stays to the right of the process mark
      ;; during this function.  This causes window-point in non-selected windows
      ;; showing the MOO buffer to move so as to display the maximum possible
      ;; text.  If we don't do tis, window-point in non-selected windows falls
      ;; behind the new prompt and never moves, ultimately leaving those windows
      ;; NOT showing the current prompt.  Doing it this way means that in
      ;; fpl-moo-wrap-line we don't have to visit every window showing the MOO
      ;; buffer and scroll it manually.  Thankfully, window-point in
      ;; non-selected windows behaves like a marker.

      (goto-char (point-max))
      ;; (delete-horizontal-space) ;; This deletes trailing spaces in the prompt!!!
      (setq command (buffer-substring end-of-prompt (point)))
      (delete-region end-of-prompt (point))
      (goto-char fpl-moo-process-mark)
      (insert (concat fpl-moo-prompt command "\n"))
      (fpl-moo-highlight fpl-moo-process-mark (point))

      ;; Maintain this invariant: the string which is the value of
      ;; fpl-moo-prompt is always found in the buffer immediately to
      ;; the right of the process mark.

      (set-marker fpl-moo-process-mark (point))
      (goto-char (point-max))

      ;; Give the user a chance to frob the command string.

      (let ((fpl-moo-command (concat command "\n")))
	(run-hooks 'fpl-moo-mode-command-hook)

	;; Add the command to the history list, and send it to the MOO.

	(fpl-moo-history-add command)
	(process-send-string process fpl-moo-command)))))


(defun fpl-moo-beginning-of-line ()
  "Move to beginning of the current line, taking into account the possible
presence of the prompt."
  (interactive)
  (if (< (point) (+ fpl-moo-process-mark (length fpl-moo-prompt)))
      (beginning-of-line)
    (beginning-of-line)
    (if (not (= ?\n (aref fpl-moo-prompt (1- (length fpl-moo-prompt)))))
	(save-match-data
	  (let* ((index (string-match "\n[^\n]*$" fpl-moo-prompt))
		 (last-prompt-line (substring fpl-moo-prompt
					      (1+ (or index -1))))
		 (last-line-length (length last-prompt-line)))
	    (if (and (> last-line-length 0)
		     (looking-at last-prompt-line))
		(goto-char (+ (point) last-line-length))))))))


(defun fpl-moo-kill-line (&optional delete)
  "Erase the current command line.  If point is not on the current command line,
tell the user so.  If optional argument DELETE is non-nil, don't save the line
on the kill ring, otherwise it is saved."
  (interactive)
  (let ((end-of-prompt (+ fpl-moo-process-mark (length fpl-moo-prompt))))
    (if (< (point) end-of-prompt)
	(error "fpl-moo-kill-line: point is not on the current command!"))
    (funcall (if delete 'delete-region 'kill-region)
	     end-of-prompt (point-max))))


(defun fpl-moo-clear-buffer ()
  "Erases the contents of the buffer, leaving only the prompt.  The kill ring does
NOT get a copy of the deleted text."
  (interactive)
  ;; This is simple, because we rely on fpl-moo-mode-post-command-hook to do the
  ;; work of inserting the prompt back into the empty buffer.
  (let* ((command (if (> (point) fpl-moo-process-mark)
		     (buffer-substring (+ fpl-moo-process-mark (length fpl-moo-prompt))
				       (point-max))))
	 (offset (if command (- (point-max) (point)))))
    (delete-region (point-min) (point-max))
    (when command
      (insert command)
      (goto-char (- (point-max) offset)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support sending buffers and files.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fpl-moo-send-buffer (&optional buffer lines pause)
  "Sends the contents of BUFFER to the MOO associated with the current
buffer, as long as BUFFER is not a MOO-interaction buffer.  You may
narrow BUFFER to a subset of itself, and this function will only send
what is visible in the narrowed buffer.  BUFFER must end with a
newline for the command on the last line to be executed by the MOO.
If optional argument BUFFER is nil, the current buffer is sent.
Optional argument LINES is the number of lines to send at a time with
a pause of PAUSE seconds between each send.  If LINES is 0, the entire
buffer is sent at once.  If LINES is not a non-negative integer, a
default value of 10 is used.  If PAUSE is not a positive integer, a
default value of 1 second is used.

The contents of BUFFER do not appear in the MOO interaction buffer.
All you see is the output of the commands that are sent."
  (interactive
   (list (read-buffer "Buffer to send: " nil 'require-match)
	 (condition-case nil
	     (read-from-minibuffer "Lines to send each cycle: "
				   (cons (or (car fpl-moo-lines-history) "15") 0)
				   nil 'parseit (cons 'fpl-moo-lines-history 1))
	   (error 10))
	 (condition-case nil
	     (read-from-minibuffer "Seconds between cycles: "
				   (cons (or (car fpl-moo-seconds-history) "1") 0)
				   nil 'parseit (cons 'fpl-moo-seconds-history 1))
	   (error 1))))

  (fpl-moo-real-send-buffer buffer lines pause))


(defun fpl-moo-send-file (filename)
  "..."
  (interactive "fFile to send: ")
  ;; Probably call fpl-moo-real-send-buffer.
  (error "Not implemented yet!"))


(defun fpl-moo-real-send-buffer (buffer lines pause)
  "Non-interactive function that really sends a buffer's contents to the MOO."
  (if (or (not (integerp lines))
	  (< lines 0))
      (error "fpl-moo-send-buffer: argument #2 must be a non-negative integer!"))
  (if (or (not (integerp pause))
	  (< pause 1))
      (error "fpl-moo-send-buffer: argument #2 must be a positive integer!"))
  (if (null buffer)
      (setq buffer (current-buffer))
    (setq buffer (get-buffer buffer)))	; Accept buffer names too.
  (if (not (bufferp buffer))
      (error "fpl-moo-send-buffer: Arg #1 is not a buffer!"))

  (save-excursion
    (let* ((process (get-buffer-process (current-buffer))))
      (if (not (processp process))
	  (error "Failed to find process object for buffer \"%s\"!"
		 (buffer-name buffer)))
      (set-buffer buffer)
      (if (stringp fpl-moo-id)
	  (error "You cannot send the contents of a MOO interaction buffer!"))
      (if (= 0 (buffer-size))
	  (error "Buffer contains no text!"))
      
      ;; Send the buffer.

      (if (= 0 lines)
	  (process-send-string process (buffer-string))
	(save-excursion
	  (goto-char (point-min))
	  (let ((loc (point)))
	    (while (< (point) (point-max))
	      (forward-line lines)
	      (process-send-string process (buffer-substring loc (point)))
	      (sit-for pause)
	      (setq loc (point)))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support command-line history.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar fpl-moo-history nil
  "A vector holding the commands that the user has submitted to the
MOO so far.  The vector implements a circularly linked list of
commands.  The vector is created when MOO mode is first activated in
the MOO interaction buffer (which happens when each connection is
made), but not when MOO mode is subsequently activated.  At the moment
it is created, its size is taken from the value of the history
attribute in fpl-moo-sites, or, if no such attribute is specified, from
fpl-moo-history-max.  This variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-history)
(put 'fpl-moo-history 'permanent-local t)


(defvar fpl-moo-history-newest nil
  "The index into the vector fpl-moo-history of the element which
contains the newest user command.  This variable is incremented after
each new command is stored in fpl-moo-history.  It's value wraps back
to 0 when it reaches the end of the vector fpl-moo-history.  This
variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-history-newest)
(put 'fpl-moo-history-newest 'permanent-local t)


(defvar fpl-moo-history-oldest nil
  "The index into the vector fpl-moo-history of the element which
contains the oldest user command.  Once fpl-moo-history-newest wraps
past the end of fpl-moo-history, this variable is incremented after
each new command is stored in fpl-moo-history.  It's value wraps back
to 0 when it reaches the end of the vector fpl-moo-history.  This
variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-history-oldest)
(put 'fpl-moo-history-oldest 'permanent-local t)


(defvar fpl-moo-history-current nil
  "Either nil or the index into the vector fpl-moo-history of the
element containing the currently displayed command.  If nil, then the
user is not traversing the command history, either because there is no
history yet or a command has just been sent to the MOO.  This variable
is decremented by fpl-moo-history-previous and incremented by
fpl-moo-history-next.  It's value wraps when it reaches either end of
the vector fpl-moo-history.  This variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-history-current)
(put 'fpl-moo-history-current 'permanent-local t)


(defun fpl-moo-history-add (command)
  "Add string COMMAND to the history list for this MOO interaction
buffer (if history is being kept for it).  If the history list is
full, the oldest element drops off.  Trailing newlines are removed
from COMMAND before it is added to the history list."
  (if fpl-moo-history
      (let ((hist-length (length fpl-moo-history)))

	;; Strip trailing newlines from COMMAND.

	(while (and (> (length command) 0)
		    (= ?\n (aref command (1- (length command)))))
	  (setq command (substring command 0 -1)))

	(setq fpl-moo-history-current nil)

	;; Don't add to history commands that are nothing but newlines.

	(if (not (string= "" command))
	    (progn
	      (if (null fpl-moo-history-newest)
		  (setq fpl-moo-history-newest 0)
		(setq fpl-moo-history-newest
		      (% (1+ fpl-moo-history-newest) hist-length)))

	      ;; Add the command to the history.

	      (aset fpl-moo-history fpl-moo-history-newest command)

	      ;; Since fpl-moo-history is a circularly linked list implemented
	      ;; in a vector, once every element of the vector is in use,
	      ;; fpl-moo-history-newest ends up forever chasing one element
	      ;; behind fpl-moo-history-oldest as new commands are entered.

	      (if (null fpl-moo-history-oldest)
		  (setq fpl-moo-history-oldest 0)
		(if (= fpl-moo-history-newest fpl-moo-history-oldest)
		    ;; The vector is full, and the chase is on ...

		    (setq fpl-moo-history-oldest
			  (% (1+ fpl-moo-history-oldest) hist-length)))))))))


(defun fpl-moo-history-previous (prefix)
  "Display the previous command in the command history for the current MOO
interaction buffer."
  (interactive "p")

  (if (null fpl-moo-history)
      (error "No command history being kept for this MOO connection!"))

  ;; Fail if point not positioned within the current command.

  (let ((at-current-command
	 (>= (point) (+ fpl-moo-process-mark (length fpl-moo-prompt)))))
    (if (and (not at-current-command)
	     (null fpl-moo-history-access-anywhere))
	(funcall fpl-moo-previous-line-command prefix)

      ;; Position point at the most recent command prompt and show maximum
      ;; text, but only if we weren't there already.

      (if (not at-current-command)
	  (fpl-moo-display-max-text))

      ;; Detect if we're as far back in time as we can go.

      (if (or (null fpl-moo-history-newest)
	      (and fpl-moo-history-current
		   (= fpl-moo-history-current fpl-moo-history-oldest)))
	  (error "At beginning of command history!"))

      ;; Adjust fpl-moo-history-current back one element in the history list.

      (if (null fpl-moo-history-current)
	  (setq fpl-moo-history-current fpl-moo-history-newest)
	(setq fpl-moo-history-current (1- fpl-moo-history-current))
	(if (< fpl-moo-history-current 0)
	    (setq fpl-moo-history-current (1- (length fpl-moo-history)))))
      
      (let ((hist-string (aref fpl-moo-history fpl-moo-history-current)))
	(if (not (stringp hist-string))
	    (error "fpl-moo-history-previous: found a non-string in the history!"))

	;; Update the command line and our current position in the history
	;; vector.

	(fpl-moo-kill-line 'delete)	; Delete current command.
	(insert hist-string)
	(fpl-moo-highlight fpl-moo-process-mark (point))))))


(defun fpl-moo-history-next (prefix)
  "Display the next command in the command history for the current MOO
interaction buffer."
  (interactive "p")

  (if (null fpl-moo-history)
      (error "No command history being kept for this MOO connection!"))

  ;; Fail if point not positioned within the current command.

  (let ((at-current-command
	 (>= (point) (+ fpl-moo-process-mark (length fpl-moo-prompt)))))
    (if (and (not at-current-command)
	     (null fpl-moo-history-access-anywhere))
	(funcall fpl-moo-next-line-command prefix)

      ;; Position point at the most recent command prompt and show maximum
      ;; text, but only if we weren't there already.

      (if (not at-current-command)
	  (fpl-moo-display-max-text))

      ;; Detect if we're as far forward in time as we can go.

      (if (or (null fpl-moo-history-newest)
	      (null fpl-moo-history-current)
	      (= fpl-moo-history-current fpl-moo-history-newest))
	  (error "At end of command history!"))

      ;; Adjust fpl-moo-history-current forward one element in the history
      ;; list.

      (setq fpl-moo-history-current
	    (% (1+ fpl-moo-history-current) (length fpl-moo-history)))
      
      (let ((hist-string (aref fpl-moo-history fpl-moo-history-current)))
	(if (not (stringp hist-string))
	    (error "fpl-moo-history-next: found a non-string in the history!"))

	;; Update the command line and our current position in the history
	;; vector.

	(fpl-moo-kill-line 'delete)	; Delete current command.
	(insert hist-string)
	(fpl-moo-highlight fpl-moo-process-mark (point))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support line wrapping.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar fpl-moo-wrap-enabled t
  "\\<fpl-moo-mode-map>
If non-nil, do line wrapping.  If nil, don't do it.
Use \"\\[fpl-moo-toggle-linewrap]\" to toggle line wrapping.  This variable
is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-wrap-enabled)
(put 'fpl-moo-warp-enabled 'permanent-local t)


(defun fpl-moo-toggle-linewrap ()
  "Toggle line wrapping on or off."
  (interactive)
  (if (setq fpl-moo-wrap-enabled (not fpl-moo-wrap-enabled))
      (message "Line wrapping is now enabled.")
    (message "Line wrapping is now disabled.")))


(defun fpl-moo-window-width (buffer)
  "Returns the width of the narrowest window displaying BUFFER.  If no
window is displaying the buffer, returns 70."
  (let ((moowindows (get-buffer-window-list buffer 'nominibuf t)))
    (if moowindows
	(apply (function min) (mapcar (function window-width) moowindows))
      70)))


(defun fpl-moo-wrap-line ()
  "Word wrap one line of output from the MOO.  This function is also responsible
for keeping alls windows positioned on MOO interaton buffer according to the
value of fpl-moo-max-text-gap."
  (if fpl-moo-wrap-enabled
      (let ((done nil)
	    (line-start (marker-position start))
	    (line-end (marker-position end))
	    (width (fpl-moo-window-width (marker-buffer start))))
	(while (and (not done)
		    (>= (- line-end line-start) width))
	  (goto-char (1- (+ line-start width)))
	  (if (or (search-backward-regexp "[ \t]" line-start t)
		  (search-forward-regexp "[ \t]" line-end t))
	      (progn
		(delete-horizontal-space)
		(newline)
		(setq line-start (point)
		      line-end (marker-position end)))
	    ;; No more whitespace at which to wrap the line.  Terminate the loop.
	    (setq done t))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code to support local editing.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar fpl-moo-edit-frame nil
  "This variable is local to all buffers.  If a new frame is created to
display a MOO Edit buffer, this variable's value is that frame.  It is used to
determine whether to delete the current frame after the MOO Edit buffer has
been sent to the MOO and fpl-moo-edit-buffer-disposition's value is 'hide or
'kill.")

(make-variable-buffer-local 'fpl-moo-edit-frame)
(put 'fpl-moo-edit-frame 'permanent-local t)


(defvar fpl-moo-edit-name nil
  "Buffer local variable that holds the name of the entity being edited.
fpl-moo-local-edit sets this variable, and fpl-moo-edit-capture uses it to
give a name to the MOO Edit buffer that it creates.  This variable is
local to all buffers.")

(make-variable-buffer-local 'fpl-moo-edit-name)
(put 'fpl-moo-edit-name 'permanent-local t)


(defvar fpl-moo-edit-upload nil
  "Holds a string which is the upload command for the current MOO Edit
buffer.  This variable is local to all buffers.")

(make-variable-buffer-local 'fpl-moo-edit-upload)
(put 'fpl-moo-edit-upload 'permanent-local t)


(defvar fpl-moo-edit-capture-buffer nil
  "Holds the buffer object that is the capture buffer used by
fpl-moo-edit-capture, which is installed as an autoreaction filter
function (see package fpl-react.el for details).  This variable is
local to all buffers, but it's value in the capture buffer is not
used.")

(make-variable-buffer-local 'fpl-moo-edit-capture-buffer)
(put 'fpl-moo-edit-capture-buffer 'permanent-local t)


(defvar fpl-moo-edit-connection nil
  "Holds the process object for the MOO connection that a given MOO Edit
buffer should be sent to.  This variable is used by fpl-moo-edit-send-buffer.
This variable is local to all buffers, but its value is only meaningfull
in a MOO Edit buffer.")

(make-variable-buffer-local 'fpl-moo-edit-connection)
(put 'fpl-moo-edit-connection 'permanent-local t)


(defvar fpl-moo-edit-last-displayed-buffer nil
  "Holds the buffer object that is the most recently displayed MOO Edit
buffer.  If no MOO Edit buffer has yet been displayed or if the most
recently displayed MOO Edit buffer no longer exists, this is nil.  This
variable must not be local to any buffer.")


(defvar fpl-moo-edit-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-c"	'fpl-moo-edit-send-buffer)
    (define-key map "\C-c\C-m"	'fpl-moo-edit-set-moo)
    (define-key map "\C-c\C-w"	'fpl-moo-edit-insert-signature)
    map)
  "Keymap for fpl-moo-edit-mode.  Customize this keymap via fpl-moo-edit-mode-hook.

Special commands:

\\{fpl-moo-edit-mode-map}
")


(defun fpl-moo-edit-mode ()
  "MOO Edit mode, a major mode used for editting arbitrary text, MOO objects,
properties, and verbs in preparation for sending to a MOO as input.

Special commands:

\\{fpl-moo-edit-mode-map}
"
  (interactive)

  ;; First, the standard major mode stuff.

  (kill-all-local-variables)
  (use-local-map fpl-moo-edit-mode-map)
  (setq mode-name "MOO-Edit")
  (setq major-mode 'fpl-moo-edit-mode)

  ;; Second, MOO Edit mode stuff.  Be careful not to do anything that will
  ;; break if fpl-moo-edit-mode is switched off then on again by the user.

  ;; Why should we override the user's choice here?
  ;;(setq fill-column 75)

  ;; Lastly, run user hook functions.

  (run-hooks 'fpl-moo-edit-mode-hook))

  
(defun fpl-moo-local-edit ()
  "This function is called whenever the MOO emits the trigger text that tells
this client to prepare to capture text for local editing."

  ;; Extract the information we need from the current line, storing it in
  ;; buffer-local variables so this code is reentrant in the presence of
  ;; multiple MOO connections.

  (goto-char end)
  (end-of-line)
  (let ((line (buffer-substring start (point))))
    (beginning-of-line 2)
    (delete-region start (point))
    (string-match "^#\\$\# edit name: \\(.*\\) upload: \\(.*\\)$" line)
    (setq fpl-moo-edit-name (substring line (match-beginning 1) (match-end 1))
	  fpl-moo-edit-upload (substring line (match-beginning 2) (match-end 2))))

  (if (= (point) fpl-moo-process-mark)

      ;; There is no text after the trigger line, so we just install
      ;; fpl-moo-edit-capture to capture the text to come and return.

      (fpl-react-set-filter (current-buffer)
			    (function fpl-moo-edit-capture))

    ;; There is text after the trigger line, so we make the first call to
    ;; fpl-moo-edit-capture.  We leave that text in the buffer for future
    ;; autoreaction processing.

    (let ((leftover nil))
      (setq fpl-moo-capture-buffer nil
	    leftover (fpl-moo-edit-capture (get-buffer-process (current-buffer))
					   (buffer-substring (point)
							     fpl-moo-process-mark)))
      (delete-region (point) fpl-moo-process-mark)

      ;; Maybe install a filter function to capture more dot-quoted text.
      ;; If fpl-moo-edit-capture returned a non-string, there is more to
      ;; capture.  If it returned "", there is no more to capture and there
      ;; was no leftover text, so we're all done.

      (if (and (stringp leftover)
	       (> (length leftover) 0))
	  (progn
	    (insert leftover)
	    (set-marker fpl-moo-process-mark (point)))

	;; fpl-moo-edit-capture returns a non-string object if it still needs to
	;; capture more text.

	(if (not (stringp leftover))
	    (fpl-react-set-filter (current-buffer)
				  (function fpl-moo-edit-capture))))))

  ;; Prevent other autoreactions from being triggered for this line.

  'fpl-react-final-autoreaction)


(defun fpl-moo-edit-capture (process string)
  "Capture lines of local-edit output from the MOO, and de-dot-quote them.
When the last line of the local-edit output is seen, make the MOO Edit buffer.
fpl-moo-edit-capture returns any text that's not part of the local-edit
download (or "" if it captured exactly everything it needed).
fpl-moo-edit-capture returns a non-string object if it still needs to capture
more text."

  (let ((leftover nil)
	(start nil))
    (save-excursion
      (set-buffer (or fpl-moo-edit-capture-buffer
		      (setq fpl-moo-edit-capture-buffer
			    (generate-new-buffer " *MOO Edit Capture Buffer*"))))

      ;; Insert STRING at point in the capture buffer, and de-dot-quote each
      ;; complete line.  If we find the termination line (i.e., "."), we hand
      ;; back the remaining text to our caller.

      (setq start (point))
      (insert string)
      (goto-char start)
      (while (progn (end-of-line)
		    (and (eolp) (not (eobp))))
	(let ((end-of-line (point))
	      (line nil))
	  (beginning-of-line)
	  (setq line (buffer-substring (point) end-of-line))

	  (if (string= "." line)
	      (setq leftover (progn
			       (beginning-of-line 2)
			       (prog1
				   (buffer-substring (point) (point-max))
				 (delete-region (point) (point-max)))))

	    ;; De-dot-quote the line, and leave point at the beginning of the
	    ;; next line.

	    (if (and (>= (length line) 2)
		     (string= ".." (substring line 0 2)))
		(delete-char 1))
	    (beginning-of-line 2)))))

    (if (null leftover)
	
	;; Returning nil prevents autoreaction processing of STRING.  It also
	;; tells fpl-moo-local-edit that we need to capture more text.

	nil

      ;; Create and display the MOO Edit buffer.

      (set-buffer (process-buffer process))
      (let ((capture-buffer fpl-moo-edit-capture-buffer)
	    (upload-command fpl-moo-edit-upload)
	    (id fpl-moo-id))
	(setq fpl-moo-edit-capture-buffer nil)

	(save-excursion
	  (set-buffer (fpl-moo-edit-make-buffer fpl-moo-edit-name))
	  (insert (concat upload-command "\n"))
	  (insert-buffer capture-buffer)

	  (kill-buffer capture-buffer)
	  (goto-char (point-min))
	  (forward-line)   ;; Leave point on first editable line.

	  ;; Display the MOO Edit buffer.

	  (fpl-moo-display-edit-buffer (current-buffer)))

	;; Deinstall this function as the user filter (if necessary).

	(let ((moo-buffer (process-buffer process)))
	  (if (eq (function fpl-moo-edit-capture)
		  (fpl-react-get-filter moo-buffer))
	      (fpl-react-set-filter moo-buffer nil)))

	;; Return the leftover string for further processing.  Note that
	;; leftover may be "" right now.

	leftover))))


(defun fpl-moo-display-edit-buffer (&optional buffer-to-display)
  "Makes and displays and empty MOO Edit buffer.  If optional argument
BUFFER-TO-DISPLAY is non-nil, it is the buffer to display.  Otherwise a new
edit buffer is created.  Returns the window object of the window displaying
the buffer."
  (interactive)
  (let* ((edit-buffer (or buffer-to-display
			  (fpl-moo-edit-make-buffer "workspace")))
	 (pop-up-frames (if window-system
			    (not (not fpl-moo-edit-new-frame))))
	 (default-frame-alist (append (and (listp fpl-moo-edit-new-frame)
					   fpl-moo-edit-new-frame)
				      default-frame-alist)))

    ;; We do delete-windows-on to guarantee that display-buffer creates a new
    ;; frame when pop-up-frames is non-nil and to guarantee that display-buffer
    ;; uses the current frame when pop-up-frames is nil.

    (delete-windows-on edit-buffer)
    (setq fpl-moo-edit-last-displayed-buffer edit-buffer)

    ;; We use display-buffer instead of pop-to-buffer, because there is no
    ;; way to properly leave the edit buffer selected.  This function is called
    ;; from within too many save-excursion's (thanks to fpl-react.el).

    (let ((win (display-buffer edit-buffer))
	  (window-min-height 10))
      (shrink-window-if-larger-than-buffer win)
      (save-excursion
	(set-buffer edit-buffer)
	(setq fpl-moo-edit-frame (window-frame win))))))


(defun fpl-moo-edit-display-last-buffer ()
  "Display the most recently displayed MOO Edit buffer."
  (interactive)
  (if (not (buffer-live-p fpl-moo-edit-last-displayed-buffer))
      (error "Most recently display MOO Edit buffer does not exist.")
    (fpl-moo-display-edit-buffer fpl-moo-edit-last-displayed-buffer)))


(defun fpl-moo-edit-make-buffer (&optional name moo-process)
  "\\<fpl-moo-edit-mode>
Makes an empty edit buffer which the user can use for editing arbitrary
text to be sent to the MOO.  Returns the buffer object, but does nothing to
display that buffer to the user.  Each edit buffer is associated with an
active MOO connection.

Type \"\\[fpl-moo-send-edit-buffer]\" to send the contents
of the edit buffer to the associated MOO.  Optional argument NAME is a string
to be used to name the edit buffer.  Optional argument MOO-PROCESS is a
process object to which the contents of the edit buffer will be sent.  If
MOO-PROCESS is omitted, the contents will be sent to the MOO associated
with the buffer this command was invoked in."

  (interactive)
  (if (and moo-process
	   (not (processp moo-process)))
      (error "fpl-moo-make-edit-buffer: argument #2 is not a process object!"))
  
  ;; Associate this MOO Edit buffer with a network connection only if that
  ;; connection was to a MOO.

  (if (and (null moo-process)
	   fpl-moo-id)
      (setq moo-process (get-buffer-process (current-buffer))))

  (let* ((ebuf-name (concat (or fpl-moo-id "MOO") ":"
			    (or name "workspace")))
	 (edit-buffer (get-buffer ebuf-name)))
    (save-excursion
      (if (or (not (bufferp edit-buffer))
	      (not (y-or-n-p "Reuse existing edit buffer? ")))
	  (set-buffer (setq edit-buffer (generate-new-buffer ebuf-name)))
	(set-buffer edit-buffer)
	(erase-buffer))
      (setq fpl-moo-edit-connection moo-process)
      (fpl-moo-edit-mode)
      (if (null moo-process)
	  (message (substitute-command-keys "No MOO for this buffer!  Type \\<fpl-moo-edit-mode-map>\"\[fpl-moo-edit-set-moo]\" to assign one."))))
    
    ;; Return the buffer object.

    edit-buffer))


(defun fpl-moo-kill-last-edit-buffer ()
  "Kill the most recently displayed MOO Edit buffer.  User must confirm the
action."
  (interactive)
  (if (not (buffer-live-p fpl-moo-edit-last-displayed-buffer))
      (error "Most recently display MOO Edit buffer does not exist."))
  (if (yes-or-no-p (concat "Kill buffer "
			   (buffer-name fpl-moo-edit-last-displayed-buffer)
			   "? "))
      (kill-buffer fpl-moo-edit-last-displayed-buffer)))


(defun fpl-moo-kill-all-edit-buffers ()
  "Kills all edit buffers, then tells the user how many buffers were killed."
  (interactive)
  (if (yes-or-no-p "Really delete all edit buffers? ")
      (let ((bufs (buffer-list))
	    (buf)
	    (count 0))
	(save-excursion
	  (while bufs
	    (setq buf (car bufs))
	    (if (buffer-live-p buf)
		(progn
		  (set-buffer buf)
		  (if (eq major-mode 'fpl-moo-edit-mode)
		      (progn
			(kill-buffer buf)
			(setq count (1+ count))))))
	    (setq bufs (cdr bufs)))
	  (message (format "%d buffers killed." count))))))


(defun fpl-moo-edit-send-buffer ()
  "Sends the current buffer, which must be a MOO Edit buffer, to its associated
MOO.  The buffer is not modified in any way before being sent."

  (interactive)
  (if (null fpl-moo-edit-connection)
      (error "This edit buffer is not associated with a MOO!"))

  (let ((this-frame (selected-frame)))

    ;; Send the data to the MOO.

    (process-send-string fpl-moo-edit-connection (buffer-string))
    (not-modified)
    (message "Buffer contents sent to MOO.")

    ;; Then dispose of this buffer according to fpl-moo-edit-buffer-diposition.

    (cond ((eq 'keep fpl-moo-edit-buffer-disposition)
	   nil)

	  ((eq 'hide fpl-moo-edit-buffer-disposition)
	   (let ((buffer (current-buffer)))
	     (if (and window-system
		      (eq this-frame fpl-moo-edit-frame)
		      (> (length (frame-list)) 1))
		 (delete-frame fpl-moo-edit-frame))
	     (delete-windows-on buffer t)
	     (bury-buffer buffer)))

	  ((eq 'kill fpl-moo-edit-buffer-disposition)
	   (let ((buffer (current-buffer)))
	     (if (and window-system
		      (eq this-frame fpl-moo-edit-frame)
		      (> (length (frame-list)) 1))
		 (delete-frame fpl-moo-edit-frame))
	     (delete-windows-on buffer t)
	     (kill-buffer buffer)))

	  (t
	   (error "Invalid value for fpl-moo-edit-buffer-disposition: %s"
		  (prin1-to-string fpl-moo-edit-buffer-disposition))))))


(defun fpl-moo-edit-set-moo ()
  "Set the MOO with which this edit buffer should be associated."
  (error "Sorry, fpl-moo-edit-set-moo is not ready yet!")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;                   UNDER CONSTRUCTION                   ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )


(defun fpl-moo-edit-insert-signature ()
  (interactive)
  "Inserts the contents of ~/.moo-signature at point.  This function is
available in all MOO-Edit buffers, but is intended for use only when
composing MOO mail."
  (insert-file "~/.moo-signature"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Cleanup.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fpl-moo-cleanup ()
  "Called from the fpl-react cleanup routine.  When this function is called
the current buffer is the process interaction buffer."
  (remove-hook 'pre-command-hook 'fpl-moo-mode-pre-command-hook)
  (remove-hook 'post-command-hook 'fpl-moo-mode-post-command-hook)
  (setq fpl-moo-id-buffer-alist (delete (assoc fpl-moo-id fpl-moo-id-buffer-alist)
					fpl-moo-id-buffer-alist)))


(provide 'fpl-moo)
