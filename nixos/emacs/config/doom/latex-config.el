;; Fix the wrong LaTeX major mode being loaded due to AUCTeX issue.
;; https://github.com/doomemacs/doomemacs/issues/8191#issuecomment-2522039422
(setq major-mode-remap-alist major-mode-remap-defaults)

(after! latex
  (setq reftex-default-bibliography "References.bib")

  (add-hook! 'LaTeX-mode-hook
    (defun disable-auto-fill ()
      (auto-fill-mode 0))
    (map! :map LaTeX-mode-map
          :localleader "s" #'LaTeX-section
          :localleader "e" #'LaTeX-environment
          :localleader "c" #'LaTeX-close-environment
          :localleader "ii" #'LaTeX-insert-item
          :localleader "m" #'TeX-insert-macro) )

  ;; LaTeX font bindings from Spacemacs
  (defun latex/font-bold () (interactive) (TeX-font nil ?\C-b))
  (defun latex/font-medium () (interactive) (TeX-font nil ?\C-m))
  (defun latex/font-code () (interactive) (TeX-font nil ?\C-t))
  (defun latex/font-emphasis () (interactive) (TeX-font nil ?\C-e))
  (defun latex/font-italic () (interactive) (TeX-font nil ?\C-i))
  (defun latex/font-clear () (interactive) (TeX-font nil ?\C-d))
  (defun latex/font-calligraphic () (interactive) (TeX-font nil ?\C-a))
  (defun latex/font-small-caps () (interactive) (TeX-font nil ?\C-c))
  (defun latex/font-sans-serif () (interactive) (TeX-font nil ?\C-f))
  (defun latex/font-normal () (interactive) (TeX-font nil ?\C-n))
  (defun latex/font-serif () (interactive) (TeX-font nil ?\C-r))
  (defun latex/font-oblique () (interactive) (TeX-font nil ?\C-s))
  (defun latex/font-upright () (interactive) (TeX-font nil ?\C-u))
  (map! :map LaTeX-mode-map :localleader "xb"  'latex/font-bold)
  (map! :map LaTeX-mode-map :localleader "xc"  'latex/font-code)
  (map! :map LaTeX-mode-map :localleader "xe"  'latex/font-emphasis)
  (map! :map LaTeX-mode-map :localleader "xi"  'latex/font-italic)
  (map! :map LaTeX-mode-map :localleader "xr"  'latex/font-clear)
  (map! :map LaTeX-mode-map :localleader "xo"  'latex/font-oblique)
  (map! :map LaTeX-mode-map :localleader "xfc" 'latex/font-small-caps)
  (map! :map LaTeX-mode-map :localleader "xff" 'latex/font-sans-serif)
  (map! :map LaTeX-mode-map :localleader "xfr" 'latex/font-serif)
  (map! :map LaTeX-mode-map :localleader "fe"  'LaTeX-fill-environment)
  (map! :map LaTeX-mode-map :localleader "fp"  'LaTeX-fill-paragraph)
  (map! :map LaTeX-mode-map :localleader "fr"  'LaTeX-fill-region)
  (map! :map LaTeX-mode-map :localleader "fs"  'LaTeX-fill-section))
