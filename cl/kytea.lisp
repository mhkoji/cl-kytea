(defpackage :cl-kytea
  (:use :cl)
  (:export :kytea
           :load-kytea
           :destroy-kytea
           :calculate-ws
           :calculate-tags))
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
               for word-surface-ptr = (cffi:mem-aref result :pointer i)
               while (not (cffi:null-pointer-p word-surface-ptr))
               collect (cffi:foreign-string-to-lisp word-surface-ptr))
      (loop for i from 0
            for word-surface-ptr = (cffi:mem-aref result :pointer i)
            while (not (cffi:null-pointer-p word-surface-ptr))
            do (cffi:foreign-free word-surface-ptr))
      (cffi:foreign-array-free result))))


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

(defun calculate-tags-destory-result (result)
  ;; TODO
  (cffi:foreign-array-free result))

(defun calculate-tags (kytea string)
  (let ((result (cffi:with-foreign-string (s string)
                  (cl-kytea.wrap:calculate-tags (kytea-wrap kytea) s))))
    (unwind-protect (calculate-tags-collect-words result)
      (calculate-tags-destory-result result))))
