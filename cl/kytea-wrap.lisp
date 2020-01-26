(defpackage :cl-kytea.wrap
  (:use :cl)
  (:export :new
           :calculate-ws))
(in-package :cl-kytea.wrap)

(cffi:define-foreign-library kytea
  (:unix "libkytea.so"))

(cffi:use-foreign-library kytea)

(cffi:define-foreign-library kytea-wrap
  (:unix "libkytea_wrap.so"))

(cffi:use-foreign-library kytea-wrap)

(cffi:defcfun ("kytea_wrap_new" new) :pointer)
(cffi:defcfun ("kytea_wrap_calculateWS" calculate-ws) :pointer
  (self :pointer)
  (sent :string))
