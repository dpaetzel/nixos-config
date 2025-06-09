;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "Fira Code Nerd Font" :size 16 :style "Retina"))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-solarized-dark)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; Fish (and possibly other non-POSIX shells) is known to inject garbage
;;   output into some of the child processes that Emacs spawns. Many Emacs
;;   packages/utilities will choke on this output, causing unpredictable
;;   issues. To get around this, either:
;;
;;     - Add the following to $DOOMDIR/config.el:
(setq shell-file-name (executable-find "bash"))


(load "server")
(unless (server-running-p) (server-start))


;; (setq doom-localleader-key ",")


(defun alternate-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))


(map!
 :leader "w/" #'evil-window-vsplit
 :leader "w-" #'evil-window-split
 :leader :desc "Save all open files" "fS" #'evil-write-all
 :leader :desc "Mark buffer as done and close" "fq" #'server-edit
 :leader "TAB" #'alternate-buffer
 :leader "/" #'+default/search-project
 )


(map!
 :nv "j" #'next-line
 :nv "k" #'previous-line)


(setq-default
   whitespace-style '(face trailing tabs tab-mark))


(add-hook 'focus-out-hook (lambda () (evil-write-all nil)))


(map! :leader "j" 'evil-avy-goto-char :after avy)


;; Apparently we have to force-load this to make the keybind work. It's
;; otherwise loaded lazily on the first use of the default keybind (which I
;; never use).
(use-package! evil-surround)
(map! :map evil-surround-mode-map :v "s" 'evil-embrace-evil-surround-region)
(after! evil-surround
  (setq-default
   evil-surround-pairs-alist
   (append
    evil-surround-pairs-alist
    '((?„ . ("„" . "“"))
      (?“ . ("“" . "”"))
      (?‚ . ("‚" . "‘"))
      (?‘ . ("‘" . "’"))))
   ;; in order for evil-surround to work, I also have to instruct evil-embrace to
   ;; pass these keys through
   evil-embrace-evil-surround-keys
   (append
    evil-embrace-evil-surround-keys
    '(?„
      ?“
      ?‚
      ?‘))))


(use-package! python-black
  :demand t
  :after python
  :config
  (add-hook! 'python-mode-hook #'python-black-on-save-mode)
  ;; Feel free to throw your own personal keybindings here
  (map! :leader :desc "Blacken Buffer" "m b b" #'python-black-buffer)
  (map! :leader :desc "Blacken Region" "m b r" #'python-black-region)
  (map! :leader :desc "Blacken Statement" "m b s" #'python-black-statement)
)


;; Broken as of 2024-03-14 (hangs in iterations)
;;
;; (require 'julia-formatter)
;; (add-hook 'julia-mode-hook #'julia-formatter-mode)
;;
;; Custom.
(defun run-formatter-on-file ()
  "Run JuliaFormatter on the current file, handling TRAMP paths appropriately."
  (let* ((file-name (buffer-file-name))
         (formatter-path "~/5Code/JuliaFormatter.jl/compiled/bin/JuliaFormatter")
         (command (format "%s %s" formatter-path (shell-quote-argument file-name))))
    (if (file-remote-p file-name)
        (let* ((vec (tramp-dissect-file-name file-name))
               ;; (user (tramp-file-name-user vec))
               ;; (host (tramp-file-name-host vec))
               (localname (tramp-file-name-localname vec))
               (remote-command (format "%s %s" formatter-path (shell-quote-argument localname))))
          (message "Running remote command: %s" remote-command)
          (shell-command remote-command)
          (revert-buffer t t t)  ;; Revert buffer to reflect changes
          (message "Remote command executed and buffer reverted."))
      (progn
        (message "Running local command: %s" command)
        (shell-command command)
        (revert-buffer t t t)  ;; Revert buffer to reflect changes
        (message "Local command executed and buffer reverted.")))))

(defun add-juliaformatter-on-save-hook ()
  "Add a hook to run JuliaFormatter on save."
  (add-hook 'after-save-hook
            (lambda ()
              (when (string-match "\\.jl\\'" (buffer-file-name))
                (run-formatter-on-file)))
            nil t))  ; 't' makes the hook buffer-local, so it's only added for this specific mode
(add-hook 'julia-mode-hook 'add-juliaformatter-on-save-hook)
;; Local-only version I used before doing TRAMP stuff.
;; (defun add-juliaformatter-on-save-hook ()
;;   "Add a hook to run JuliaFormatter on save"
;;   (add-hook 'after-save-hook
;;             (lambda ()
;;               (when (string-match "\\.jl\\'" (buffer-file-name))
;;                 (let ((command (format "~/5Code/JuliaFormatter.jl/compiled/bin/JuliaFormatter %s" (shell-quote-argument (buffer-file-name)))))
;;                   (shell-command command))))
;;             nil t)) ; 't' makes the hook buffer-local, so it's only added for this specific mode
;; (add-hook 'julia-mode-hook 'add-juliaformatter-on-save-hook)


(use-package! stan-mode)
(use-package! flycheck-stan)
(add-hook 'stan-mode-hook (lambda () (setq comment-start "//"
                                           comment-end   ""
                                           comment-continue "//")))


(load! "latex-config.el")

;; https://github.com/doomemacs/doomemacs/issues/581#issuecomment-895462086
(defun dlukes/ediff-doom-config (file)
  "ediff the current config with the examples in doom-emacs-dir

There are multiple config files, so FILE specifies which one to
diff.
"
  (interactive
    (list (read-file-name "Config file to diff: " doom-private-dir)))
  (let* ((stem (file-name-base file))
          (customized-file (format "%s.el" stem))
          (template-file-regex (format "^%s.example.el$" stem)))
    (ediff-files
      (concat doom-private-dir customized-file)
      (car (directory-files-recursively
             doom-emacs-dir
             template-file-regex
             nil
             (lambda (d) (not (string-prefix-p "." (file-name-nondirectory d)))))))))
