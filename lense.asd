(cl:in-package #:cl-user)


(asdf:defsystem lense
  :name "lense"
  :version "0.0.0"
  :license "BSD-2"
  :author "Marek Kochanowicz"
  :maintainer "Marek Kochanowicz"
  :description "Racket style lenses for the Common Lisp."
  :depends-on (:alexandria
               :documentation-utils-extensions
               :closer-mop)
  :serial T
  :pathname "src"
  :components ((:file "package")
               (:file "macros")
               (:file "types")
               (:file "protocol")
               (:file "implementation")
               (:file "view")
               (:file "documentation")))
