(defpackage :cl-kytea
  (:use :cl)
  (:export :kytea
           :load-kytea
           :destroy-kytea
           :calculate-ws))
(in-package :cl-kytea)

(defclass kytea ()
  ((wrap
    :initarg :wrap
    :accessor kytea-wrap)))

(defun load-kytea ()
  (make-instance 'kytea :wrap (cl-kytea.wrap:new)))

(defun destroy-kytea (kytea)
  (cffi:foreign-free (kytea-wrap kytea))
  (setf (kytea-wrap kytea) (cffi:null-pointer)))

(defun calculate-ws (kytea string)
  (let ((result (cffi:with-foreign-string (s string)
                  (cl-kytea.wrap:calculate-ws (kytea-wrap kytea) s))))
    (unwind-protect
         (loop for i from 0
               for word-ptr = (cffi:mem-aref result :pointer i)
               while (not (cffi:null-pointer-p word-ptr))
               collect (cffi:foreign-string-to-lisp word-ptr))
      (loop for i from 0
            for word-ptr = (cffi:mem-aref result :pointer i)
            while (not (cffi:null-pointer-p word-ptr))
            do (cffi:foreign-free word-ptr))
      (cffi:foreign-free result))))
