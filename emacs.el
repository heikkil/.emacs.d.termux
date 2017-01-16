;;;; Do not modify this file by hand.  It was automatically generated
;;;; from `emacs.org` in the same directory. See that file for more
;;;; information.
;;;;
;;;; If you cannot find the `emacs.org` file, see the source
;;;; repository at https://github.com/heikkil/emacs-literal-config


(use-package dash
  :config
  (if (>= emacs-major-version 24)
      (use-package dash-functional)
    (message "Warning: dash-functional needs Emacs v24")))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)
(setq gc-cons-threshold 20000000)

(defun my-minibuffer-setup-hook ()
(setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
(setq gc-cons-threshold 20000000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)
(add-to-list 'load-path
             (concat user-emacs-directory
                     (convert-standard-filename "elisp/")))

(setq dired-listing-switches "-alh")

(defun my/->string (str)
  (cond
   ((stringp str) str)
   ((symbolp str) (symbol-name str))))

(defun my/->mode-hook (name)
  "Turn mode name into hook symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?\\(-hook\\)?$"
                                    "-mode-hook"
                                    (my/->string name))))

(defun my/->mode (name)
  "Turn mode name into mode symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?$"
                                    "-mode"
                                    (my/->string name))))

(defun my/turn-on (&rest mode-list)
  "Turn on the given (minor) modes."
  (dolist (m mode-list)
    (funcall (my/->mode m) +1)))

(defvar my/normal-base-modes
  (mapcar 'my/->mode '(text prog))
  "The list of modes that are considered base modes for
  programming and text editing. In an ideal world, this should
  just be text-mode and prog-mode, however, some modes that
  should derive from prog-mode derive from fundamental-mode
  instead. They are added here.")

(defun my/normal-mode-hooks ()
  "Returns the mode-hooks for `my/normal-base-modes`"
  (mapcar 'my/->mode-hook my/normal-base-modes))

;;(set-face-attribute 'default nil
;;                    :family "Inconsolata"
;;                    :height 140
;;                    :weight 'normal
;;                    :width 'normal)
;;     (set-fontset-font "fontset-default" nil
;;                       (font-spec :size 20 :name "Symbola:"))
(when (eq system-type 'darwin)
  (set-default-font "-*-Hack-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1"))
(defun my/insert-unicode (unicode-name)
  "Same as C-x 8 enter UNICODE-NAME."
  (insert-char (cdr (assoc-string unicode-name (ucs-names)))))

(bind-key "C-x 9" 'hydra-unicode/body)
(defhydra hydra-unicode (:hint nil)
  "
 Unicode  _e_ €  _s_ 0 w SPACE   _n_amed select
          _f_ ♀  _o_ °   _m_ µ
          _r_ ♂  _a_ →
        "
  ("e" (my/insert-unicode "EURO SIGN"))
  ("r" (my/insert-unicode "MALE SIGN"))
  ("f" (my/insert-unicode "FEMALE SIGN"))
  ("s" (my/insert-unicode "ZERO WIDTH SPACE"))
  ("o" (my/insert-unicode "DEGREE SIGN"))
  ("a" (my/insert-unicode "RIGHTWARDS ARROW"))
  ("m" (my/insert-unicode "MICRO SIGN"))
  ("n" counsel-unicode-char))

(global-prettify-symbols-mode 1)
(setq prettify-symbols-unprettify-at-point 'right-edge)
(auto-compression-mode)
(global-auto-revert-mode)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(cua-mode t)
(use-package abbrev
  :ensure nil
  :defer t
  :commands abbrev-mode
  ;;:diminish Abbr
  :config
  (progn
    (if (file-exists-p abbrev-file-name)
        (quietly-read-abbrev-file))
    (setq save-abbrevs 'silently)
    (add-hook 'expand-load-hook
              (lambda ()
                (add-hook 'expand-expand-hook 'indent-according-to-mode)
                (add-hook 'expand-jump-hook 'indent-according-to-mode)))))
(add-hook 'before-save-hook 'time-stamp)
(setq display-time-24hr-format t)

(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
          (vc-delete-file filename)
        (progn
          (delete-file filename)
          (message "Deleted file %s" filename)
          (kill-buffer))))))
(bind-key "C-c d" 'delete-file-and-buffer)

(defun my/kill-a-buffer (askp)
  (interactive "P")
  (if askp
      (kill-buffer (funcall completing-read-function
                            "Kill buffer: "
                            (mapcar #'buffer-name (buffer-list))))
    (kill-this-buffer)))
(bind-key "C-x k" 'my/kill-a-buffer)
(use-package magit
  :bind ("C-c g" . magit-status)
  :config
  (setq magit-push-always-verify nil)
  (setq magit-diff-options '("-b")) ; ignore whitespace
  (use-package magithub
    :disabled t))

(use-package git-commit :defer t)
(use-package git-gutter :defer t)
(use-package git-gutter-fringe :defer t)
(use-package gitattributes-mode :defer t)
(use-package gitconfig-mode :defer t)
(use-package gitignore-mode :defer t)

(use-package super-save
  :init (setq super-save-auto-save-when-idle t)  ; def 5 sec
  :config (super-save-initialize))
(delete-selection-mode nil)

(use-package shrink-whitespace
  :bind ("M-SPC" . shrink-whitespace))


(defun my/transpose-chars ()
  "Transpose two previous characters"
  (interactive)
  (backward-char)
  (transpose-chars 1))
(bind-key "C-t" 'my/transpose-chars)

(defun my/smart-self-insert-punctuation (count)
  "If COUNT=1 and the point is after a space, insert the relevant
character before any spaces."
  (interactive "p")
  (if (and (= count 1)
           (eq (char-before) ?\s))
      (save-excursion
        (skip-chars-backward " ")
        (self-insert-command 1))
    (self-insert-command count)))
(bind-key "," #'my/smart-self-insert-punctuation)
    ;; word-count
    (defun word-count nil "Count words in buffer" (interactive)
      (shell-command-on-region (point-min) (point-max) "wc -w"))

(defun count-words (start end)
  "Print number of words in the region."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (count-matches "\\sw+"))))



(define-minor-mode my/linum-mode
  "Toggle showing of line numbers.

Interactively with no argument, this command toggles the mode.  A
positive prefix argument enables the mode, any other prefix
argument disables it.  From Lisp, argument omitted or nil enables
the mode, `toggle' toggles the state."
  nil           ; The initial value.
  nil           ; The indicator for the mode line
  '()           ; The minor mode bindings.
  :group 'my/linum
  (nlinum-mode (if my/linum-mode 1 -1)))

(define-global-minor-mode my/global-linum-mode
  my/linum-mode
  (lambda () (my/linum-mode 1)))

(defun goto-line-with-feedback ()
  "Show line numbers temporarily, while prompting for the line number input"
  (interactive)
  (unwind-protect
      (progn
        (linum-relative-toggle)
        (nlinum-mode 1)
        (goto-line (read-number "Goto line: ")))
    (nlinum-mode -1)
    (linum-relative-toggle)))

(bind-key "C-x ," 'goto-line)
(bind-key [remap goto-line] 'goto-line-with-feedback)
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

(use-package aggressive-indent)

(use-package cperl-mode
  :mode "\\.\\([pP][Llm]\\|al\\)\\'"
  :interpreter ("perl" "perl5" "miniperl")
  :init
  (setq cperl-indent-level 4
        cperl-close-paren-offset -4
        cperl-continued-statement-offset 4
        cperl-indent-parens-as-block t
        cperl-tab-always-indent t)
  :config
  (defun my/cperl-mode-hook ()
    (my/turn-on 'show-paren-mode
                'abbrev-mode
                'electric-pair-mode
                'electric-operator-mode
                'aggressive-indent-mode))
  (add-hook 'cperl-mode-hook 'my/cperl-mode-hook t))
 (defun perltidy ()
    "Run perltidy on the current region or buffer."
    (interactive)
    ; Inexplicably, save-excursion doesn't work here.
    (let ((orig-point (point)))
      (unless mark-active (mark-defun))
      (shell-command-on-region (point) (mark) "perltidy -q" nil t)
      (goto-char orig-point)))

(eval-after-load 'cperl-mode
  '(bind-key  "C-c t" 'perltidy cperl-mode-map))


(setq my/lisps
      '(emacs-lisp lisp clojure extempore racket))

(defun my/general-lisp-hooks ()
  (my/turn-on 'paredit
              ;;'rainbow-delimiters
              'electric-pair-mode
              'show-paren-mode
              'aggressive-indent-mode
              'eldoc
              'abbrev-mode
              ;;'highlight-parentheses
              ))
(dolist (mode (mapcar 'my/->mode-hook my/lisps))
  (add-hook mode
            'my/general-lisp-hooks))

(use-package paredit
  :if (eq system-type 'darwin)
  :no-require t
  :config
  ;; C-left
  (bind-key "s-<left>" 'paredit-forward-barf-sexp paredit-mode-map)
  ;; C-right
  (bind-key "s-<right>" 'paredit-forward-slurp-sexp paredit-mode-map)
  ;; Alt-C-left
  (bind-key "M-s-<left>" 'paredit-backward-slurp-sexp paredit-mode-map)
  ;; Alt-C-right
  (bind-key "M-s-<right>" 'paredit-backward-barf-sexp paredit-mode-map))

(use-package eros
  :config
  (eros-mode 1))

;; Use the GDB visual debugging mode
(setq gdb-many-windows t)
;; Turn Semantic on
;;(require 'semantic/sb)
(semantic-mode 1)
;; Try to make completions when not typing
(global-semantic-idle-completions-mode 1)

(use-package auto-complete
  :defer t
  :init (setq ac-auto-show-menu t
              ac-quick-help-delay 0.5
              ac-use-fuzzy t)
  :config (global-auto-complete-mode +1))
(global-subword-mode +1)
(defhydra hydra-navigate (:color red
                          :hint nil)
  "
_f_: forward-char       _w_: forward-word       _n_: next-line
_b_: backward-char      _W_: backward-word      _p_: previous-line
^ ^                     _o_: subword-right      _,_: beginning-of-line
^ ^                     _O_: subword-left       _._: end-of-line

_s_: forward sentence   _a_: forward paragraph  _g_: forward page
_S_: backward sentence  _A_: backward paragraph _G_: backward page

_r_: recent files _B_: buffer list
_<left>_: previous buffer   _<right>_: next buffer
_<up>_: scroll-up           _<down>_: scroll-down

_[_: backward-sexp _]_: forward-sexp
_<_ beginning of buffer _>_ end of buffer _m_: set mark _/_: jump to mark
"

  ("f" forward-char)
  ("b" backward-char)
  ("w" forward-word)
  ("W" backward-word)
  ("n" next-line)
  ("p" previous-line)
  ("o" subword-right)
  ("O" subword-left)
  ("s" forward-sentence)
  ("S" backward-sentence)
  ("a" forward-paragraph)
  ("A" backward-paragraph)
  ("g" forward-page)
  ("G" backward-page)
  ("<right>" next-buffer)
  ("<left>" previous-buffer)
  ("r" recentf-open-files :color blue)
  ("m" org-mark-ring-push)
  ("/" org-mark-ring-goto :color blue)
  ("B" list-buffers)
  ("<up>" scroll-down)
  ("<down>" scroll-up)
  ("<" beginning-of-buffer)
  (">" end-of-buffer)
  ("." end-of-line)
  ("[" backward-sexp)
  ("]" forward-sexp)
  ("," beginning-of-line)
  ("q" nil "quit" :color blue))
(bind-key "M-n" 'hydra-navigate/body)
(bind-key "C-<backspace>"
          #'(lambda () (interactive)
              (kill-line 0)))
(defalias 'qrr 'query-replace-regexp)  ; M-C-S %


(defun narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
   Dwim means: region, org-src-block, org-subtree, or defun,
   whichever applies first. Narrowing to org-src-block actually
   calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is
already narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing
         ;; command. Remove this first conditional if you
         ;; don't want it.
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'latex-mode)
         (LaTeX-narrow-to-environment))
        (t (narrow-to-defun))))
(setq doc-view-continuous nil)
;;http://mbork.pl/2015-04-25_Some_Dired_goodies
;;
(defalias 'list-buffers 'ibuffer) ; make ibuffer default
(use-package bm
  :init
  (setq bm-in-lifo-order t)
  (setq bm-cycle-all-buffers t)
  (setq bm-highlight-style 'bm-highlight-only-fringe)
  (setq bm-marker 'bm-marker-left)
  :bind
  (("C-c x" . hydra-bookmark/body))
  ("<left-fringe>" . bm-next-mouse)
  ("<left-fringe>" . bm-previous-mouse)
  ("<left-fringe>" . bm-toggle-mouse)
  (" <mouse-5>" . bm-next-mouse)
  (" <mouse-4>" . bm-previous-mouse)
  (" <mouse-1>" . bm-toggle-mouse)
  :config
  (defhydra hydra-bookmark (:color blue :hint nil)
    "
     bookmark   |   Add^^          Move^^         Manage
  ----------------------------------------------------------------
                    _t_: toggle    _n_: next      _s_: show local
                    _y_: add temp  _p_: previous  _S_: show all
                    _r_: regexp    ^ ^            _x_: remove local
                    ^ ^            ^ ^            _X_: remove all
                "
    ("t" bm-toggle)
    ("n" bm-next :color red)
    ("p" bm-previous :color red)
    ("y" (bm-bookmark-add nil nil t))
    ("r" bm-bookmark-regexp)
    ("s" bm-show)
    ("S" bm-show-all)
    ("x" bm-remove-all-current-buffer)
    ("X" bm-remove-all-all-buffers)))

(setq save-interprogram-paste-before-kill t)

(use-package ivy
  :diminish (ivy-mode . "")
  :init
  (setq ivy-use-virtual-buffers t)
  (setq ivy-display-style 'fancy)
  (setq ivy-height 10)
  (setq ivy-count-format "(%d/%d) ")
  :bind (("C-s" . swiper)
         ("C-c C-r" . ivy-resume)
         ("M-x" . counsel-M-x)
         ("C-c b"   . ivy-push-view)
         ("C-c B"   . ivy-pop-view)
         ("M-y" . counsel-yank-pop)
         ("C-M-s" . avy-goto-char-timer)
         :map ivy-minibuffer-map
         ("M-y" . ivy-next-line))
  :config
  (ivy-mode 1)
  ;; Enable bookmarks and recentf in buffer list
  (setq ivy-use-virtual-buffers t)

  (setq ivy-re-builders-alist
        ;; allow regex input not in order
        '((t   . ivy--regex-ignore-order)))

  (custom-set-faces
   '(swiper-minibuffer-match-face-1
     ((t :background "#dddddd")))
   '(swiper-minibuffer-match-face-2
     ((t :background "#bbbbbb" :weight bold)))
   '(swiper-minibuffer-match-face-3
     ((t :background "#bbbbff" :weight bold)))
   '(swiper-minibuffer-match-face-4
     ((t :background "#ffbbff" :weight bold))))

  ;; advise swiper to recenter on exit
  ;; from http://pragmaticemacs.com/emacs/dont-search-swipe/
  (defun my/swiper-recenter (&rest args)
    "recenter display after swiper"
    (recenter))
  (advice-add 'swiper :after #'my/swiper-recenter))

;; restore key bindings to isearch due to character folding in emacs 25.1
(bind-key "C-`" 'isearch-forward)
(bind-key "C-r" 'isearch-backward)

;; Isearch convenience, space matches anything (non-greedy)
(setq search-whitespace-regexp ".*?")

;; http://endlessparentheses.com/leave-the-cursor-at-start-of-match-after-isearch.htmlh
;; This will only leave point at the start of search if you exit the
;; search with C-↵ instead of ↵.
(define-key isearch-mode-map [(control return)]
  #'isearch-exit-other-end)
(defun isearch-exit-other-end ()
  "Exit isearch, at the opposite end of the string."
  (interactive)
  (isearch-exit)
  (goto-char isearch-other-end))
(use-package avy
  :bind (("M-s" . avy-goto-word-1)))
(setq tramp-default-method "ssh")
(defun my/vsplit-last-buffer (prefix)
  "Split the window vertically and display the previous buffer."
  (interactive "p")
  (split-window-vertically)
  (other-window 1 nil)
  (if (= prefix 1)
    (switch-to-next-buffer)))
(defun my/hsplit-last-buffer (prefix)
  "Split the window horizontally and display the previous buffer."
  (interactive "p")
  (split-window-horizontally)
  (other-window 1 nil)
  (if (= prefix 1) (switch-to-next-buffer)))

(bind-key "C-x 2" 'my/vsplit-last-buffer)
(bind-key "C-x 3" 'my/hsplit-last-buffer)
(setq my/window-resize-step 10)

(bind-key "s-<left>"
          (lambda () (interactive)
            (shrink-window-horizontally my/window-resize-step)))
(bind-key "s-<right>"
          (lambda () (interactive)
            (enlarge-window-horizontally my/window-resize-step)))
(bind-key "s-<down>"
          (lambda () (interactive)
            (shrink-window my/window-resize-step)))
(bind-key "s-<up>"
          (lambda () (interactive)
            (enlarge-window my/window-resize-step)))
(defun google ()
  "Google the selected region if any, display a query prompt otherwise."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (url-hexify-string (if mark-active
                           (buffer-substring (region-beginning) (region-end))
                         (read-string "Google: "))))))
(defun my/edit-emacs-configuration ()
  "Open the main emacs configuration file."
  (interactive)
  (find-file "~/.emacs.d/emacs.el"))
(bind-key "C-c e" 'my/edit-emacs-configuration)

(use-package recentf
  :if (not noninteractive)
  :bind ( "C-x C-r" . recentf-open-files)
  :init
  (progn
    (recentf-mode 1)
    (setq recentf-auto-cleanup 'never) ;; cleanup interfers with tramp mode
    (setq recentf-max-saved-items 400
          recentf-max-menu-items 35)))
(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))
(setq calendar-latitude 60.47)
(setq calendar-longitude 25.73)
(setq calendar-location-name "Åtorp")
(use-package org
  :ensure org-plus-contrib
  :mode ("\\.txt$" . org-mode)
  :config
  (setq org-pretty-entities t)
  ;; Don't allow editing of folded regions
  (setq org-catch-invisible-edits 'error)
  (add-hook 'org-mode-hook
            (lambda ()
              (visual-line-mode)
              ;; (turn-on-org-cdlatex)
              (org-indent-mode))))

     (use-package org-autolist
       :config
       (add-hook 'org-mode-hook (lambda () (org-autolist-mode))))

     (use-package wc-mode
       :config
       ;; (add-hook 'org-mode-hook 'wc-mode) ;; too slow to have on by default
       )
(use-package suomalainen-kalenteri
  :defer t
  :init (setq org-agenda-start-on-weekday 1)) ;; 1 is default
;; speed-ups
(setq org-agenda-inhibit-startup t)
(setq org-agenda-use-tag-inheritance nil)
(setq org-tag-alist '(("ATORP"   . ?a)
                      ("TMI"     . ?i)
                      (:startgrouptag)
                      ("SCIENCE"   . ?z)
                        (:grouptags)
                          ("BIO"     . ?b)
                          ("HUMEVO"  . ?h)
                          ("BATS"    . ?t)
                          ("NATURE"  . ?n)
                      (:endgrouptag)

                      (:startgrouptag)
                      ("COMP"    . ?c)
                        (:grouptags)
                          ("GIT"     . ?g)
                          ("LATEX"   . ?l)
                          ("PERL"    . ?p)
                          ("SECURITY". ?s)
                          ("PYTHON"  . ?y)
                      (:endgrouptag)

                      (:startgrouptag)
                        ("EMACS"   . ?e)
                        (:grouptags)
                          ("ORG"     . ?o)
                      (:endgrouptag)

                      (:startgrouptag)
                      ("CULTURE"    . ?o)
                        (:grouptags)
                          ("FOOD"    . ?d)
                          ("PHOTO"   . ?f)
                          ("BOOK"    . ?k)
                          ("MOVIE"   . ?m)
                          ("WRITING" . ?w)
                          ("MUSIC"   . ?u)
                      (:endgrouptag)))
(use-package org-agenda
  :ensure nil
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :init
  (setq org-agenda-files '("~/Dropbox/org"))
  (setq org-return-follows-link t)
  (setq org-agenda-span 14)
  (setq org-deadline-warning-days 5)
  ;; clean agenda
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq lunar-phase-names
        '("● New Moon"
          "☽ First Quarter Moon"
          "○ Full Moon"
          "☾ Last Quarter Moon")))

(setq org-directory "~/Dropbox/org")
(setq org-default-notes-file "~/Dropbox/org/reference.org")
;; Capture templates for: general notes, TODO tasks, events
(setq org-capture-templates
      '(("n" "note" entry (file+datetree "~/Dropbox/org/reference.org")
         "* %?\n     :PROPERTIES:\n     :CREATED:  %U\n     :END:     \n%i")
        ("a" "appointment" entry (file  "~/Dropbox/org/gcal.org" )
         "* %?\n\n %^T\n\n:PROPERTIES:\n\n:END:\n\n")
        ("s" "code snippet" entry (file+datetree "~/Dropbox/org/reference.org")
         ;; Prompt for tag and language
         "* %?\t%^g\n     :PROPERTIES:\n     :CREATED:  %U\n     :END:     \n#+BEGIN_SRC %^{language}\n%i\n#+END_SRC")
        ("t" "todo" entry (file+datetree "~/Dropbox/org/todo.org")
         "* TODO %?\n     SCHEDULED: %t\n\n     :CREATED:  %U\n%i\n  Entered on %U")
        ("e" "event" entry (file+datetree "~/Dropbox/org/calendar.org")
         "* %?\n     :PROPERTIES:\n     :CREATED:  %U\n     :CATEGORY: event\n     :END:\n     %T\n%i")))
     ;; Disabled. 2016-11-27 package update to messed this up.
     (defun org-auto-tag ()
       (interactive)
       (let ((alltags (append org-tag-persistent-alist org-tag-alist))
             (headline-words  (split-string (upcase (org-get-heading t t)))))
         (mapcar (lambda (word)
                   (if (assoc word alltags)
a~S                       (org-toggle-tag word 'saon)))
                 headline-words)))
     ;; (add-hook 'org-capture-before-finalize-hook 'org-auto-tag)
     ;; (remove-hook 'org-capture-before-finalize-hook 'org-auto-tag)
(setq org-capture-templates
      (append '(("l" "Ledger entries")
                ("lm" "MasterCard" plain
                 (file "~/Documents/ledger/refile.led")
                 "
%(org-read-date)  %^{Payee}
     ; entered: %U
     Liabilities:MasterCard
     Expenses:%^{Account}              € %^{Amount}
" :empty-lines-before 1)
                ("lc" "Cash" plain
                 (file "~/Documents/ledger/refile.led")
                 "
%(org-read-date) * %^{Payee}
    ; entered: %U
    Expenses:Cash
    Expenses:%^{Account}              %^{Amount}
" :empty-lines-before 1 )
                ("ls" "SAR debit" plain
                 (file "~/Documents/ledger/refile.led")
                 "
%(org-read-date) * %^{Payee}
    ; entered: %U
    Assets:Samba
    Expenses:%^{Account}              %^{Amount} SAR
" :empty-lines-before 1 )
   ("le" "EUR debit" plain
                 (file "~/Documents/ledger/refile.led")
                 "
%(org-read-date) * %^{Payee}
    ; entered: %U
    Assets:Heikintili
    Expenses:%^{Account}               € %^{Amount}
" :empty-lines-before 1 ))
       org-capture-templates))
(use-package org-dropbox
  :defer 5
  :config (org-dropbox-mode))
;; Targets include this file and any file contributing to the agenda - up to 3 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 3)
                                 (org-agenda-files :maxlevel . 3))))

;; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)

;; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

;; Use IDO for both buffer and file completion and ido-everywhere to t
;;setq org-completion-use-ido t)
;;setq ido-everywhere t)
;;setq ido-max-directory-size 100000)
;;ido-mode (quote both))

;; Refile settings
;; Exclude DONE state tasks from refile targets
;;(defun bh/verify-refile-target ()
;;  "Exclude todo keywords with a done state from refile targets"
;;  (not (member (nth 2 (org-heading-components)) org-done-keywords)))
;;
;;(setq org-refile-target-verify-function 'bh/verify-refile-target)

(setq package-check-signature nil)

(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)
(setq org-log-note-clock-out t)

(setq org-clock-idle-time 10)
(bind-key "C-c w" 'hydra-org-clock/body)
(defhydra hydra-org-clock (:color blue :hint nil)
  "
^Clock:^ ^In/out^     ^Edit^   ^Summary^    | ^Timers:^ ^Run^           ^Insert
-^-^-----^-^----------^-^------^-^----------|--^-^------^-^-------------^------
(_?_)    _i_n         _e_dit   _g_oto entry | (_z_)     _r_elative      ti_m_e
^ ^     _c_ontinue   _q_uit   _d_isplay    |  ^ ^      cou_n_tdown     i_t_em
^ ^     _o_ut        ^ ^      _r_eport     |  ^ ^      _p_ause toggle
^ ^     ^ ^          ^ ^      ^ ^          |  ^ ^      _s_top
"
   ("i" org-clock-in)
   ("o" org-clock-out)
   ("c" org-clock-in-last)
   ("e" org-clock-modify-effort-estimate)
   ("q" org-clock-cancel)
   ("g" org-clock-goto)
   ("d" org-clock-display)
   ("r" org-clock-report)
   ("?" (org-info "Clocking commands"))

  ("r" org-timer-start)
  ("n" org-timer-set-timer)
  ("p" org-timer-pause-or-continue)
  ;; ("a" (org-timer 16)) ; double universal argument
  ("s" org-timer-stop)

  ("m" org-timer)
  ("t" org-timer-item)
  ("z" (org-info "Timers")))

;; http://endlessparentheses.com/changing-the-org-mode-ellipsis.html?source=rss
;;(setq org-ellipsis "…")
(setq org-ellipsis "⤵")
(setq org-hide-emphasis-markers t)

;; save cursor position
(use-package saveplace
  :defer t
  :config
  (setq-default save-place t))

(setq custom-file "/dev/null")

;; Save minibuffer history
;;(savehist-mode)﻿
(setf epa-pinentry-mode 'loopback)
(setq user-full-name "Heikki Lehväslaiho")
(setq user-mail-address "heikki.lehvaslaiho@gmail.com")
(setq make-backup-files t) ;; Enable backup files
;; Enable versioning
(setq version-control t)  ;; make numbered backups
(setq backup-by-copying t)
(setq kept-new-versions 20)
(setq kept-old-versions 5)
(setq delete-old-versions t)
;; Save all backup files in this directory.
(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/backups/"))))

;; disable lockfiles
(setq create-lockfiles nil)
(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'y-or-n-p)
(setq warning-suppress-types (quote ((undo discard-info))))
(setq large-file-warning-threshold 100000000)

(setq-default calc-multiplication-has-precedence nil)
(setq display-time-world-list
      '(("Europe/London" "London")
        ("Africa/Johannesburg" "Cape Town")
        ("Europe/Paris" "Paris")
        ("Europe/Amsterdam" "Amsterdam")
        ("Europe/Zurich" "Geneva")
        ("Europe/Helsinki" "Helsinki")
        ("Asia/Riyadh" "Jeddah")
        ("Indian/Mauritius" "Mauritius")
        ("Asia/Kolkata" "Delhi")
        ("Asia/Kathmandu" "Kathmandu")
        ("Asia/Tokyo" "Tokyo")
        ("America/New_York" "New York")
        ("America/Los_Angeles" "Seattle")))

(use-package eshell
  :config
  (setenv "PAGER" "cat")
  (defun eshell/d (&rest args)
    (dired (pop args) ".")))

;; no separate frame for the control panel
(csetq ediff-window-setup-function 'ediff-setup-windows-plain)
;; split horizontally
(csetq ediff-split-window-function 'split-window-horizontally)
;; ignore whitespace
(csetq ediff-diff-options "-w")


(defun my/->string (str)
  (cond
   ((stringp str) str)
   ((symbolp str) (symbol-name str))))

(defun my/->mode-hook (name)
  "Turn mode name into hook symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?\\(-hook\\)?$"
                                    "-mode-hook"
                                    (my/->string name))))

(defun my/->mode (name)
  "Turn mode name into mode symbol"
  (intern (replace-regexp-in-string "\\(-mode\\)?$"
                                    "-mode"
                                    (my/->string name))))

(defun my/turn-on (&rest mode-list)
  "Turn on the given (minor) modes."
  (dolist (m mode-list)
    (funcall (my/->mode m) +1)))

(defvar my/normal-base-modes
  (mapcar 'my/->mode '(text prog))
  "The list of modes that are considered base modes for
  programming and text editing. In an ideal world, this should
  just be text-mode and prog-mode, however, some modes that
  should derive from prog-mode derive from fundamental-mode
  instead. They are added here.")

(defun my/normal-mode-hooks ()
  "Returns the mode-hooks for `my/normal-base-modes`"
  (mapcar 'my/->mode-hook my/normal-base-modes))

(use-package dash
  :config
  (if (>= emacs-major-version 24)
      (use-package dash-functional)
    (message "Warning: dash-functional needs Emacs v24")))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

(setq gc-cons-threshold 20000000)

(defun my-minibuffer-setup-hook ()
(setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
(setq gc-cons-threshold 20000000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

(add-to-list 'load-path
             (concat user-emacs-directory
                     (convert-standard-filename "elisp/")))
