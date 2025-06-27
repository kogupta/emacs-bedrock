;;; Minimal init.el

;;; Contents:
;;;
;;;  - Basic settings
;;;  - Discovery aids
;;;  - Minibuffer/completion settings
;;;  - Interface enhancements/defaults
;;;  - Tab-bar configuration
;;;  - Theme
;;;  - Optional extras
;;;  - Built-in customization framework

;;; Guardrail

(when (< emacs-major-version 29)
  (error "Emacs Bedrock only works with Emacs 29 and newer; you have version %s" emacs-major-version))

;;;   Basic settings

;; Package initialization
(with-eval-after-load 'package
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))

(setopt inhibit-splash-screen t)                ;; turn off the welcome screen
(setopt initial-major-mode 'org-mode)           ;; default mode for the *scratch* buffer
(setq initial-scratch-message nil)              ;; disable initial message in scratch buffer

;; Automatically reread from disk if the underlying file changes
(setopt auto-revert-avoid-polling t)
;; Some systems don't do file notifications well; see
;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

(electric-pair-mode t)              ;; Automatically insert closing parens
(show-paren-mode 1)                 ;; Visualize matching parens
(setq-default indent-tabs-mode nil) ;; Prefer spaces to tabs
(savehist-mode t)                   ;; Save history in minibuffer to keep recent commands easily accessible

;; save desktop
(desktop-save-mode)
(setq desktop-path '("~/.emacs.d/.cache"))
(desktop-read)

;; Improve frame title to show file path.
(setq frame-title-format
      '("%b - "
	(:eval (if (buffer-file-name)
		   (abbreviate-file-name (buffer-file-name))
		 "%b"))))

;; When you visit a file, point goes to the last place where it
;; was when you previously visited the same file.
;; http://www.emacswiki.org/emacs/SavePlace
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (concat user-emacs-directory ".places"))

;; Turn on recent file mode so that you can more easily switch to
;; recently edited files when you first start emacs
(setq recentf-save-file (concat user-emacs-directory ".recentf"))
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 40)

;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control) ; You can use other modifiers here

;; Fix archaic defaults
(setopt sentence-end-double-space nil)

;; Make right-click do something sensible
(when (display-graphic-p)
  (context-menu-mode))

(setq uniquify-buffer-name-style 'forward
      window-resize-pixelwise t
      frame-resize-pixelwise t
      load-prefer-newer t

      ;; Store automatic customisation options elsewhere
      custom-file (expand-file-name "custom.el" user-emacs-directory)

      ring-bell-function 'ignore ;; Never ding at me, ever
      make-backup-files nil      ;; disable backup files
      auto-save-default nil      ;; stop creating #autosave# files
      create-lockfiles nil       ;; No need for ~ files when editing
      vc-follow-symlinks t
      ;; clipboard/selection shenanigans
      x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      )

(set-face-attribute 'default nil :font "Consolas" :height 130) ;; height = px * 100

;; start server, open files using `emacsclient -n`
(load "server")
(unless (server-running-p) (server-start))

;;;   Discovery aids

;; Show the help buffer after startup
(add-hook 'after-init-hook 'help-quick)

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; Add extra context to Emacs documentation to help make it easier to
;; search and understand. This configuration uses the keybindings
;; recommended by the package author.
(use-package helpful
  :ensure t
  :bind (("C-h f" . #'helpful-callable)
         ("C-h v" . #'helpful-variable)
         ("C-h k" . #'helpful-key)
         ("C-c C-d" . #'helpful-at-point)
         ("C-h F" . #'helpful-function)
         ("C-h C" . #'helpful-command)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer/completion settings
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; For help, see: https://www.masteringemacs.org/article/understanding-minibuffer-completion

(setopt enable-recursive-minibuffers t)                ; Use the minibuffer whilst in the minibuffer
(setopt completion-cycle-threshold 1)                  ; TAB cycles candidates
(setopt completions-detailed t)                        ; Show annotations
(setopt tab-always-indent 'complete)                   ; When I hit TAB, try to complete, otherwise, indent
(setopt completion-styles '(basic initials substring)) ; Different styles to match input to candidates

(setopt completion-auto-help 'always)                  ; Open completion always; `lazy' another option
(setopt completions-max-height 20)                     ; This is arbitrary
(setopt completions-detailed t)
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)            ; Much more eager
(setopt completion-auto-select t)                      ; See `C-h v completion-auto-select' for more possible values

(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete) ; TAB acts more like how it does in the shell

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t)                        ; Show current line in modeline
(setopt column-number-mode t)                      ; Show column as well

(setopt x-underline-at-descent-line nil)           ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t)   ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil)      ; By default, don't underline trailing spaces
;; (setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

;; We won't set these, but they're good to know about
;;
;; (setopt indent-tabs-mode nil)
;; (setopt tab-width 4)

;; Misc. UI tweaks
(blink-cursor-mode -1)          ;; Steady cursor
(pixel-scroll-precision-mode 1) ;; Smooth scrolling

;; Use common keystrokes by default
(cua-mode)

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3)           ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Tab-bar configuration
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the tab-bar as soon as tab-bar functions are invoked
(setopt tab-bar-show 1)

;; Add the time to the tab-bar, if visible
(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
;; (setopt display-time-format "%a %F %T")
;; (setopt display-time-interval 1)
;; (display-time-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Theme
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq custom-safe-themes t)
(use-package emacs
  :config
  ;; light themes: modus-operandi, ef-elea-light, ef-spring
  ;; dark themes:  modus-vivendi,  ef-elea-dark, ef-melissa-dark
  (load-theme 'ef-elea-light t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Optional extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Uncomment the (load-file …) lines or copy code from the extras/ elisp files as desired

;; UI/UX enhancements mostly focused on minibuffer and autocompletion interfaces
;; These ones are *strongly* recommended!
(load-file (expand-file-name "extras/base.el" user-emacs-directory))

;; Vim-bindings in Emacs (evil-mode configuration)
;; (load-file (expand-file-name "extras/vim-like.el" user-emacs-directory))
(setq evil-disable-insert-state-bindings t)
(use-package evil
  :ensure t
  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)

  ;; Enable this if you want C-u to scroll up, more like pure Vim
                                        ;(setq evil-want-C-u-scroll t)

  :config
  (evil-mode)
  )

(setq evil-default-state 'emacs)

;; Org-mode configuration
;; WARNING: need to customize things inside the elisp file before use! See
;; the file extras/org-intro.txt for help.
(load-file (expand-file-name "extras/org.el" user-emacs-directory))

;; start with this file
(find-file "~/depot/kong/kg-kong-kground/notes.org")

;; ==== personal functions ====

;; config edit/reload
(defun config-visit()
  (interactive)
  (find-file user-init-file))
(global-set-key (kbd "C-c e") 'config-visit)

(defun config-reload()
  (interactive)
  (load-file user-init-file)
  (message "Config reloaded!"))
(global-set-key (kbd "C-c r") 'config-reload)

;; jump to scratch file
(defun switch-to-scratch-buffer ()
  "Switch to the current session's scratch buffer."
  (interactive)
  (switch-to-buffer "*scratch*"))
(bind-key "C-c s" #'switch-to-scratch-buffer)

;; jump to notes
(defun switch-to-notes ()
  "Switch to Notes"
  (interactive)
  (find-file "~/depot/kong/kg-kong-kground/notes.org"))
(bind-key "C-c n" #'switch-to-notes)

;; split vertically/horizontally with C-x 3 and C-x 2
(defun split-right-and-buffer-list ()
  (interactive)
  (split-window-horizontally)
  (other-window 1)
  (consult-buffer))
(global-set-key (kbd "C-x 3") 'split-right-and-buffer-list)

(defun split-below-and-buffer-list ()
  (interactive)
  (split-window-vertically)
  (other-window 1)
  (consult-buffer))
(global-set-key (kbd "C-x 2") 'split-below-and-buffer-list)

(defun save-and-switch-buffer ()
  (interactive)
  (when (and (buffer-file-name)
             (not (bound-and-true-p archive-subfile-mode)))
    (save-buffer))
  (ido-switch-buffer))

;; when switching out of emacs, all unsaved files will be saved
(defun save-all-unsaved ()
  "Save all unsaved files - when switching away from emacs"
  (interactive)
  (save-some-buffers t))
(add-hook 'focus-out-hook 'save-all-unsaved)

(defun save-and-switch-buffer ()
  (interactive)
  (when (and (buffer-file-name)
             (not (bound-and-true-p archive-subfile-mode)))
    (save-buffer))
  (consult-buffer))

