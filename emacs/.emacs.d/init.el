;;; init.el --- Ludwig's Emacs configuration

;;; Code:

;; Garbage collector kicks in when 100Mb is used
(setq gc-cons-threshold 50000000)

(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-verbose t)

(setq user-mail-address "ludwig@lud.cc"
      user-full-name "Ludwig PACIFICI")

(use-package exec-path-from-shell
  :ensure t
  :config
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "LD_LIBRARY_PATH"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package clang-format
  :ensure t)

(use-package cc-mode
  :config
  (setq-default c-basic-offset 2)
  (setq c-default-style "linux")
  (add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
  (define-key c++-mode-map (kbd "C-M-<tab>") #'clang-format-region))

(use-package clojure-mode
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'parinfer-mode)
  (add-hook 'clojure-mode-hook #'subword-mode))

(use-package inf-clojure
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'inf-clojure-minor-mode))

(use-package doc-view
  :config
  (setq doc-view-continuous t)
  (setq doc-view-resolution 500))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package font-lock-studio
  :ensure t)

(use-package smex
  :ensure t)

(use-package avy
  :ensure t
  :bind
  ("C-;" . avy-goto-char-2))

(use-package counsel
  :ensure t
  :config
  (setq-default counsel-find-file-ignore-regexp "~$"))

(use-package swiper
  :ensure t
  :bind ("C-c i s" . swiper))

(use-package rg
  :ensure t
  :bind ("C-c g" . rg))

(use-package ivy
  :ensure t
  :bind
  ("M-x" . counsel-M-x)
  ("C-x C-f" . counsel-find-file)
  :config
  (ivy-mode 1)
  (setq-default enable-recursive-minibuffers t
                ivy-count-format ""
                ivy-display-style nil
                ivy-initial-inputs-alist nil
                ivy-re-builders-alist '((t . ivy--regex-fuzzy))
                ivy-use-selectable-prompt t
                ivy-use-virtual-buffers t)
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package json-mode
  :ensure t)

(use-package lisp-mode
  :config
  (add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
  (define-key emacs-lisp-mode-map (kbd "C-c C-c") #'eval-defun)
  (define-key emacs-lisp-mode-map (kbd "C-c C-b") #'eval-buffer)
  (add-hook 'lisp-interaction-mode-hook #'eldoc-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status))
  :config
  (setq magit-repository-directories '(("~" . 1))
        magit-section-visibility-indicator nil))

(use-package markdown-mode
  :ensure t
  :config
  (setq markdown-command "/sbin/pandoc"))

(use-package octave-mode
  :mode "\\.m\\'"  :config
  (add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
  (add-hook 'octave-mode-hook
            (lambda ()
              (abbrev-mode 1)
              (auto-fill-mode 1)
              (if (eq window-system 'x)
                  (font-lock-mode 1)))))

(use-package rust-mode
  :ensure t
  :config
  (setq racer-rust-src-path (concat (substring (shell-command-to-string "rustc --print sysroot") 0 -1) "/lib/rustlib/src/rust/src")))

(use-package racer
  :ensure t
  :hook ((rust-mode . racer-mode)
         (rust-mode . eldoc-mode)
         (rust-mode . rust-enable-format-on-save)))

(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode))

(use-package saveplace
  :config
  (setq-default save-place t))

(use-package scss-mode
  :ensure t)

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-dark t)
  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line nil :overline line)
    (set-face-attribute 'mode-line-inactive nil :overline line)
    (set-face-attribute 'mode-line-inactive nil :underline line)
    (set-face-attribute 'mode-line nil :box nil)
    (set-face-attribute 'mode-line-inactive nil :box nil))
  (set-face-foreground 'vertical-border (face-background 'default)))

(use-package moody
  :ensure t
  :config
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package minions
  :ensure t
  :config (minions-mode 1))

(use-package which-key
  :ensure t
  :init (which-key-mode))

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-separator "/")
  (setq uniquify-after-kill-buffer-p t)
  (setq uniquify-ignore-buffers-re "^\\*"))

(use-package toml-mode
  :ensure t)

(use-package yaml-mode
  :ensure t)

(use-package org
  :ensure t)

(use-package tuareg
  :ensure t)

(use-package merlin
  :after tuareg
  :ensure t
  :bind ("C-M-i" . completion-at-point)
  :hook (tuareg-mode . merlin-mode))

(use-package utop
  :after tuareg
  :ensure t
  :config
  (setq utop-command "opam config exec -- utop -emacs")
  :hook (tuareg-mode . utop-minor-mode))

(eval-when-compile
  (setq opam-share
        (substring
         (shell-command-to-string "opam config var share 2> /dev/null")
         0 -1))
  (add-to-list 'load-path (concat opam-share "/emacs/site-lisp"))
  (require 'dune)
  (require 'ocamlformat)
  (setq-default ocamlformat-show-errors 'disable)
  (add-hook 'before-save-hook 'ocamlformat-before-save))

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(autoload 'ibuffer "ibuffer" "List buffers." t)
(blink-cursor-mode -1)
(column-number-mode 1)
(delete-selection-mode t)
(global-auto-revert-mode t)
(global-hl-line-mode t)
(line-number-mode 1)
(menu-bar-mode 0)
(savehist-mode t)
(scroll-bar-mode -1)
(set-cursor-color "#d54e53")
(set-face-attribute 'default nil :family "Iosevka Thin" :height 180 :weight 'normal :width 'normal :slant 'normal)
(setq indent-tabs-mode nil
      tab-width 2)

(setq-default auto-save-timeout 60
              current-language-environment "English"
              cursor-in-non-selected-windows t
              cursor-type 'box
              grep-highlight-matches t
              grep-scroll-output t
              indent-tabs-mode nil
              inhibit-splash-screen t
              initial-scratch-message ""
              load-prefer-newer t
              mode-require-final-newline t
              require-final-newline 't
              ring-bell-function 'ignore
              scroll-preserve-screen-position t
              shift-select-mode nil
              tramp-default-method "ssh"
              x-stretch-cursor t)
(show-paren-mode t)
(size-indication-mode 0)
(tool-bar-mode 0)
(transient-mark-mode t)
(toggle-frame-fullscreen)

;;;;;;;;;;;;;;;;;;;;;;;;
;; Character encoding ;;
;;;;;;;;;;;;;;;;;;;;;;;;
(setq locale-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-input-method nil) ;; No funky input for normal editing
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8") ;; prefer utf-8 for language settings
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

(defun dont-kill-emacs ()
  (interactive)
  (error (substitute-command-keys "To exit emacs: \\[kill-emacs]")))
(global-set-key "\C-x\C-c" 'dont-kill-emacs)

(defun dont-suspend-emacs ()
  (interactive)
  (error (substitute-command-keys "To suspend emacs: \\[suspend-frame]")))
(global-set-key "\C-x\C-z" 'dont-suspend-emacs)

(defun endless/isearch-symbol-with-prefix (p)
  "Like isearch, unless prefix argument is provided.
With a prefix argument P, isearch for the symbol at point."
  (interactive "P")
  (let ((current-prefix-arg nil))
    (call-interactively
     (if p #'isearch-forward-symbol-at-point
       #'isearch-forward))))
(global-set-key [remap isearch-forward] #'endless/isearch-symbol-with-prefix)

(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "C-c l") 'what-line)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key "\C-cc" 'compile)
(global-set-key "\C-cr" 'recompile)
(global-set-key [f11] 'toggle-frame-fullscreen)
(global-unset-key (kbd "C-z"))

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta))
(setq x-super-keysym 'meta)

;; init.el ends here
