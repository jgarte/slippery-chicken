(asdf:defsystem #:sc
  :description "algorithmic composition software in common lisp and clos"
  :author "Michael Edwards"
  :license  "GPL-3"
  :version "1.0.12"
  :serial t
  :pathname "src"
  :depends-on (#:cm)
   ;;  Is this the correct load order for these files?
  :components      ((:file "package")
;(:file "cmn") ; cmn
(:file "cmn-glyphs") ; cmn
(:file "cm") ; cm
(:file "cm-cm") ; cm
;(:file "samp5") ; clm
;(:file "sine") ; clm
;(:file "autoc") ; clm
(:file "cm-load" t)
(:file "utilities")
(:file "named-object")
(:file "music-xml")
(:file "linked-named-object")
(:file "sclist")
(:file "circular-sclist")
(:file "assoc-list")
(:file "recursive-assoc-list")
(:file "activity-levels")
(:file "activity-levels-env")
(:file "palette")
(:file "pitch-seq-palette")
(:file "globals")
(:file "sc-map")
(:file "set-map")
(:file "tempo")
(:file "rhythm")
(:file "pitch")
(:file "chord")
(:file "event")
(:file "instrument")
;; (:file "globals")
(:file "time-sig")
(:file "rthm-seq-bar")
(:file "change-data")
(:file "change-map")
(:file "instrument-change-map")
(:file "simple-change-map")
(:file "tempo-map")
(:file "sc-set")
(:file "tl-set")
(:file "complete-set")
(:file "set-palette")
(:file "pitch-seq")
(:file "sndfile")
(:file "sndfile-ext")
(:file "sndfile-palette")
(:file "sndfilenet")
(:file "rthm-seq")
(:file "rthm-seq-palette")
(:file "rthm-seq-map")
(:file "instrument-palette")
(:file "instruments")
(:file "player")
(:file "bar-holder")
(:file "sequenz")
(:file "ensemble")
(:file "l-for-lookup")
(:file "player-section")
(:file "section")
(:file "slippery-chicken")
(:file "piece")
(:file "slippery-chicken-edit")
(:file "clm") ; clm
(:file "permutations")
(:file "rthm-chain")
(:file "rthm-chain-slow")
(:file "cycle-repeats")
(:file "recurring-event")
(:file "intervals-mapper")
(:file "lilypond")
(:file "popcorn")
(:file "osc")
(:file "osc-sc")
(:file "osc-sc-bsd")
;(:file "get-spectrum") ; clm
(:file "spectra")
;(:file "control-wave") ; clm 
;(:file "control-wave-ins") ; clm
(:file "wolfram" t)
(:file "afu")
;(:file "reaper")
                    )) ; Can we ignore this file since we'll be packaging for Guix which doesn't package reaper?
