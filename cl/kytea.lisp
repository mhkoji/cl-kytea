(defpackage :cl-kytea
  (:use :cl)
  (:export :kytea
           :load-kytea
           :destroy-kytea
           :calculate-ws
           :calculate-tags
           :calculate-1st-tags))
(in-package :cl-kytea)

(defclass kytea ()
  ((wrap
    :initarg :wrap
    :accessor kytea-wrap)))

(defun load-wrap (args)
  (assert (every #'stringp args))
  (let ((argc (length args))
	(argv (cffi:foreign-alloc :string
				  :initial-contents args
				  :null-terminated-p t)))
    (unwind-protect (cl-kytea.wrap:new argc argv)
      (dotimes (i argc)
	(cffi:foreign-free (cffi:mem-aref argv :pointer i)))
      (cffi:foreign-free argv))))

(defun load-kytea (&rest args)
  (let ((wrap (load-wrap args)))
    (make-instance 'kytea :wrap wrap)))

(defun destroy-kytea (kytea)
  (cl-kytea.wrap:destroy (kytea-wrap kytea))
  (setf (kytea-wrap kytea) (cffi:null-pointer)))


(defun calculate-ws-collect-word-surfaces (result)
  (loop for i from 0
        for surface = (cffi:mem-aref result :string i)
        while surface collect surface))

(defun calculate-ws (kytea string)
  (let ((result (cffi:with-foreign-string (s string)
                  (cl-kytea.wrap:calculate-ws (kytea-wrap kytea) s))))
    (unwind-protect (calculate-ws-collect-word-surfaces result)
      (cl-kytea.wrap:calculate-ws-destroy result))))


(defun calculate-tags-collect-words (result)
  (loop for i from 0
        for word = (cffi:mem-aref result '(:struct cl-kytea.wrap:word) i)
        for surface  = (getf word 'cl-kytea.wrap:word-surface)
        for tags-ptr = (getf word 'cl-kytea.wrap:word-tags)

        while surface

        for tags = (loop for j from 0
                         for possible-tags-ptr
                             = (cffi:mem-aref tags-ptr :pointer j)
                         while (not (cffi:null-pointer-p possible-tags-ptr))
                         for possible-tags
                             = (loop for k from 0
                                     for tag
                                         = (cffi:mem-aref
                                            possible-tags-ptr
                                            '(:struct cl-kytea.wrap:tag)
                                            k)
                                     for name
                                         = (getf tag
                                                 'cl-kytea.wrap:tag-name)
                                     for score
                                         = (getf tag
                                                 'cl-kytea.wrap:tag-score)
                                     while name collect (cons name score))
                         collect possible-tags)
        collect (list surface tags)))

(defun calculate-tags (kytea string)
  (let ((result (cffi:with-foreign-string (s string)
                  (cl-kytea.wrap:calculate-tags (kytea-wrap kytea) s))))
    (unwind-protect (calculate-tags-collect-words result)
      (cl-kytea.wrap:calculate-tags-destroy result))))

(defun calculate-1st-tags (kytea string)
  (loop for (surface tags) in (calculate-tags kytea string)
        collect (cons surface (mapcar #'caar tags))))
