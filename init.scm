(require-builtin steel/random as rand::)

(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

;; Picking one from the possible themes
(define possible-themes '("ayu_mirage" "tokyonight_storm" "gruvbox_light"))

(define (select-random lst)
  (let ([index (rand::rng->gen-range 0 (length lst))]) (list-ref lst index)))

(define (randomly-pick-theme options)
  ;; Randomly select the theme from the possible themes list
  (helix.theme (select-random options)))

(define (pick-theme)
  (randomly-pick-theme possible-themes))
