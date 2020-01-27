(defpackage :cl-kytea.wrap
  (:use :cl)
  (:export :new
           :calculate-ws
           :calculate-tags
           :tag
           :tag-name
           :tag-score
           :word
           :word-surface
           :word-tags))
(in-package :cl-kytea.wrap)

(cffi:define-foreign-library kytea
  (:unix "libkytea.so"))

(cffi:use-foreign-library kytea)

(cffi:define-foreign-library kytea-wrap
  (:unix "libkytea_wrap.so"))

(cffi:use-foreign-library kytea-wrap)

(cffi:defcstruct tag
  (tag-name  :string)
  (tag-score :double))

(cffi:defcstruct word
  (word-surface :string)
  (word-tags    (:pointer (:pointer (:struct tag)))))

(cffi:defcfun ("kytea_wrap_new" new) :pointer)

(cffi:defcfun ("kytea_wrap_calculateWS" calculate-ws) :pointer
  (self :pointer)
  (sent :string))

(cffi:defcfun ("kytea_wrap_calculateTags" calculate-tags) :pointer
  (self :pointer)
  (sent :string))

