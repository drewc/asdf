(in-package #:common-lisp-user)

(load (make-pathname :name "script-support" :defaults *load-pathname*))

(in-package #:asdf-test)

(declaim (optimize (speed 2) (safety 3) #-allegro (debug 3)
		   #+(or cmu scl) (c::brevity 2)))
(proclaim '(optimize (speed 2) (safety 3) #-allegro (debug 3)
		     #+(or cmu scl) (c::brevity 2)))

(defun my-compile-file (&rest args) (apply 'compile-file args))
#+ecl (trace my-compile-file)

(cond
  ((not (probe-file *asdf-lisp*))
   (leave-lisp "Testsuite failed: unable to find ASDF source" 3))
  ((and (probe-file *asdf-fasl*)
        (> (file-write-date *asdf-fasl*) (file-write-date *asdf-lisp*))
        (ignore-errors (load *asdf-fasl*)))
   (leave-lisp "Reusing previously-compiled ASDF" 0))
  (t
   (let ((tmp (make-pathname :name "asdf-tmp" :defaults *asdf-fasl*)))
     (ensure-directories-exist *asdf-fasl*)
     (multiple-value-bind (result warnings-p errors-p)
         ;; style warnings shouldn't abort the compilation [2010/02/03:rpg]
         (handler-bind (#+sbcl (sb-c::simple-compiler-note #'muffle-warning)
                        #+(and ecl (not ecl-bytecmp))
			((or c:compiler-note c::compiler-debug-note
			     c:compiler-warning) ;; ECL emits more serious warnings than it should.
                               #'muffle-warning)
			#-(or cmu scl)
                        (style-warning
                         #'(lambda (w)
                             ;; escalate style-warnings to warnings - we don't want them.
                             (warn "Can you please fix ASDF to not emit style-warnings? Got a ~S:~%~A"
                              (type-of w) w)
                             (muffle-warning w))))
           (my-compile-file *asdf-lisp* :output-file tmp :print t :verbose t))
       (declare (ignore result))
       (cond
         (errors-p
          (leave-lisp "Testsuite failed: ASDF compiled with ERRORS" 2))
         #-(or ecl scl xcl)
	 ;; ECL 11.1.1 has spurious warnings, same with XCL 0.0.0.291.
         ;; SCL has no warning but still raises the warningp flag since 2.20.15 (?)
         (warnings-p
          (leave-lisp "Testsuite failed: ASDF compiled with warnings" 1))
         (t
          (when warnings-p
            (format t "Your implementation raised warnings, but they were ignored~%"))
          (when (probe-file *asdf-fasl*)
            (delete-file *asdf-fasl*))
          (rename-file tmp *asdf-fasl*)
          (leave-lisp "ASDF compiled cleanly" 0)))))))
