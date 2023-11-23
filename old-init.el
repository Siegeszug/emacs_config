(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)
(setq visible-bell t)

(setq split-width-threshold (/ (display-pixel-width) 3))
(setq split-height-threshold (/ (display-pixel-height) 4))

(defun kmd/set-font-faces ()
  (message "Setting faces")
  (set-face-attribute 'default nil :font "Fira Code Retina" :height 120)
  (set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 120))

(if (daemonp)
    (add-hook 'after-make-frame-functions
	      (lambda (frame)
		(setq doom-modeline-icon t)
		(with-selected-frame frame
		  (toggle-frame-fullscreen)
		  (kmd/set-font-faces))))
  (kmd/set-font-faces))

(add-hook 'window-setup-hook 'toggle-frame-fullscreen)
(set-frame-parameter (selected-frame) 'alpha '(90 . 90))
(add-to-list 'default-frame-alist '(alpha . (90 . 90)))
;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Makes the stupid auto save files fuck off.
(setq backup-directory-alist
      '((".*" . "~/autosaves/")))
(setq auto-save-file-name-transforms
      '((".*"  "~/autosaves/" t)))



;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)
;; (defun bugfix-display-line-numbers--turn-on (fun &rest args)
;;   "Avoid `display-line-numbers-mode' in `image-mode' and related.
;; Around advice for FUN with ARGS."
;;   (unless (derived-mode-p 'image-mode 'docview-mode 'pdf-view-mode)
;;     (apply fun args)))
;; (advice-add 'display-line-numbers--turn-on :around #'bugfix-display-line-numbers--turn-on)

(display-time)
(display-battery-mode)
(electric-pair-mode)
(show-paren-mode)

(setq doc-view-resolution 200)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook
		doc-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package diminish)

(use-package ivy
  :diminish ivy-mode
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package pdf-tools)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package multiple-cursors)
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(use-package general)
(use-package hydra)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; (use-package edwina
;;   :ensure t
;;   :config
;;   (setq display-buffer-base-action '(display-buffer-below-selected))
;;   (edwina-mode 1))

;; Org mode stuff starts here

(defun kmd/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  (setq org-image-actual-width (/ (display-pixel-width) 3)))

(use-package org
  :hook (org-mode . kmd/org-mode-setup)
  :config
  (setq org-hide-emphasis-markers t)
  (setq org-src-tab-acts-natively t)
  (setq org-agenda-files
	'("/home/yata_/Agendas/tasks.org"))
  ;;	'("/home/yata_/Documents/org-mode-tests/tasks.org"))
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-return-follows-link t)
  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "/home/yata_/Agendas/tasks.org" "Inbox")
       "* TODO %?\n  %U\n  %a" :empty-lines 1)

      ("th" "Task Here" entry (file+olp "/home/yata_/Agendas/tasks.org" "Inbox")
       "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)))

  (define-key global-map (kbd "C-c t")
    (lambda () (interactive) (org-capture nil)))
    
      
  (setq org-refile-targets
	'(("archive.org" :maxlevel . 1)
	  ("tasks.org" :maxlevel . 1)))
  ;; Save Org buffers after refiling
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

(unless (package-installed-p 'org-present)
  (package-install 'org-present))

(defun kmd/org-present-start ()
  ;; Center the presentation and wrap lines
  (visual-fill-column-mode 1)
  (visual-line-mode 1)

  ;; Tweak font sizes
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 4.0) variable-pitch)
                                     (org-document-title (:height 1.75) org-document-title)
                                     (org-code (:height 1.55) org-code)
                                     (org-verbatim (:height 1.55) org-verbatim)
                                     (org-block (:height 1.25) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))

  (setq header-line-format " "))

(defun kmd/org-present-prepare-slide (buffer-name heading)
  (org-indent-mode 0)
  ;; Show only top-level headlines
  (org-overview)
  
  ;; Unfold the current entry
  (org-show-entry)

  ;; Show only direct subheadings of the slide but don't expand them
  (org-show-children))

(add-hook 'org-present-after-navigate-functions 'kmd/org-present-prepare-slide)


(defun kmd/org-present-end ()
  ;; Stop centering the document
  (org-indent-mode 1)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil))

(add-hook 'org-present-mode-hook 'kmd/org-present-start)
(add-hook 'org-present-mode-quit-hook 'kmd/org-present-end)


(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup))


(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))

(require 'org-faces)
(dolist (face '((org-level-1 . 1.2)
		(org-level-2 . 1.1)
		(org-level-3 . 1.05)
		(org-level-4 . 1.0)
		(org-level-5 . 1.0)
		(org-level-6 . 1.0)
		(org-level-7 . 1.0)
		(org-level-8 . 1.0)))
  (set-face-attribute (car face) nil :weight 'regular :height (cdr face)))

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch) 

(defun kmd/org-mode-visual-fill ()
  (setq visual-fill-column-width 120
	visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . kmd/org-mode-visual-fill))

;; Org mode export formats
(use-package ox-twbs)


;; Agenda stuff

;; LaTeX
(use-package tex
  :ensure auctex)
(use-package latex-preview-pane)
(latex-preview-pane-enable)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(add-hook 'plain-TeX-mode-hook
          (lambda () (set (make-local-variable 'TeX-electric-math)
                          (cons "$" "$"))))
(add-hook 'LaTeX-mode-hook
          (lambda () (set (make-local-variable 'TeX-electric-math)
                          (cons "\\(" "\\)"))))
;; Haskell
(use-package haskell-mode)

;; Coq
(use-package proof-general)

;; Python
(use-package elpy)
(elpy-enable)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("c5ded9320a346146bbc2ead692f0c63be512747963257f18cc8518c5254b7bf5" "835868dcd17131ba8b9619d14c67c127aa18b90a82438c8613586331129dda63" "40b961730f8d3c63537d6c3e6601f15c6f6381b9239594c7bf80b7c6a94d3c24" "850bb46cc41d8a28669f78b98db04a46053eca663db71a001b40288a9b36796c" "b0e446b48d03c5053af28908168262c3e5335dcad3317215d9fdeb8bac5bacf9" "4a5aa2ccb3fa837f322276c060ea8a3d10181fecbd1b74cb97df8e191b214313" "e19ac4ef0f028f503b1ccafa7c337021834ce0d1a2bca03fcebc1ef635776bea" "e6f3a4a582ffb5de0471c9b640a5f0212ccf258a987ba421ae2659f1eaa39b09" "266ecb1511fa3513ed7992e6cd461756a895dcc5fef2d378f165fed1c894a78c" "82ef0ab46e2e421c4bcbc891b9d80d98d090d9a43ae76eb6f199da6a0ce6a348" "6c531d6c3dbc344045af7829a3a20a09929e6c41d7a7278963f7d3215139f6a7" "3d54650e34fa27561eb81fc3ceed504970cc553cfd37f46e8a80ec32254a3ec3" "a82ab9f1308b4e10684815b08c9cac6b07d5ccb12491f44a942d845b406b0296" "5784d048e5a985627520beb8a101561b502a191b52fa401139f4dd20acb07607" "3d47380bf5aa650e7b8e049e7ae54cdada54d0637e7bac39e4cc6afb44e8463b" "cbdf8c2e1b2b5c15b34ddb5063f1b21514c7169ff20e081d39cf57ffee89bc1e" "028c226411a386abc7f7a0fba1a2ebfae5fe69e2a816f54898df41a6a3412bb5" "613aedadd3b9e2554f39afe760708fc3285bf594f6447822dd29f947f0775d6c" "da186cce19b5aed3f6a2316845583dbee76aea9255ea0da857d1c058ff003546" "a9a67b318b7417adbedaab02f05fa679973e9718d9d26075c6235b1f0db703c8" "e8df30cd7fb42e56a4efc585540a2e63b0c6eeb9f4dc053373e05d774332fc13" "db3e80842b48f9decb532a1d74e7575716821ee631f30267e4991f4ba2ddf56e" "1d5e33500bc9548f800f9e248b57d1b2a9ecde79cb40c0b1398dec51ee820daf" "7a7b1d475b42c1a0b61f3b1d1225dd249ffa1abb1b7f726aec59ac7ca3bf4dae" default))
 '(doom-modeline-battery t)
 '(doom-modeline-checker-simple-format nil)
 '(doom-modeline-github t)
 '(doom-modeline-minor-modes t)
 '(doom-modeline-time t)
 '(package-selected-packages
   '(org-present latex-preview-pane pdf-tools doom-modeline all-the-icons multiple-cursors auctex elpy proof-general haskell-mode org-roam ox-twbs visual-fill-column visual-fill org-bullets magit diminish counsel-projectile projectile hydra general which-key use-package rainbow-delimiters ivy-rich helpful doom-themes counsel))
 '(revert-without-query '(".*.pdf"))
 '(safe-local-variable-values
   '((org-roam-db-location . "/home/yata_/Documents/isekai/isekaiRoam/org-roam.db")
     (org-roam-directory . "/home/yata_/Documents/isekai/isekaiRoam")
     (org-roam-db-location . "/home/yata_/Documents/isekaiRoam/org-roam.db")
     (org-roam-directory . "/home/yata_/Documents/isekaiRoam")
     (org-roam-db-location . "/home/yata_/RoamNotes/org-roam.db")
     (org-roam-directory . "/home/yata_/RoamNotes/")
     (org-roam-db-location file-truename "~/RoamNotes/org-roam.db")
     (org-roam-directory
      (file-truename "~/RoamNotes"))
     (org-roam-db-location . "/home/yata_/dnd/talmiar_notes/roam/org-roam.db")
     (org-roam-directory . "/home/yata_/dnd/talmiar_notes/roam"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
