(asdf:defsystem :cl-kytea
  :serial t
  :pathname "cl"
  :components
  ((:file "kytea-wrap")
   (:file "kytea"))
  :depends-on (:cffi))
