(in-package :asdf)

(defsystem package-inferred-system-test
  :class package-inferred-system
  :defsystem-depends-on
  #.(unless (find-class 'package-inferred-system nil) '(:asdf-package-inferred-system)))
