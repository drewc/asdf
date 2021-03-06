#!/usr/bin/cl -sp asdf -E main

(in-package :asdf)

(uiop-debug)

(defun collect-asd (table asd)
  (multiple-value-bind (previous foundp)
      (gethash (pathname-name asd) table)
    (when (or (not foundp) (< (length (pathname-directory previous))
                              (length (pathname-directory asd))))
      (setf (gethash (pathname-name asd) table) asd))))

(defun update-cache (directory)
  (let* ((dir (ensure-pathname directory
                               :namestring :native
                               :ensure-absolute t :want-non-wild t :ensure-directory t
                               :want-existing t))
         (table (make-hash-table :test 'equal)))
    (collect-sub*directories-asd-files
     dir :collect #'(lambda (asd) (collect-asd table asd)) :ignore-cache t)
    (with-output-file (s (subpathname dir ".cl-source-registry.cache")
                         :if-exists :rename-and-delete :if-does-not-exist :create)
      (format s "(:source-registry-cache~{~% ~S~})~%"
              (sort (loop :for p :being :the :hash-values :of table
                          :collect (unix-namestring (enough-pathname p dir)))
                    'string<)))))

(defun main (argv)
  (map () 'update-cache argv))
