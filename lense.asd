(cl:in-package #:cl-user)


(asdf:defsystem lense
  :name "lense"
  :version "0.0.0"
  :license "BSD-2"
  :author "Marek Kochanowicz"
  :maintainer "Marek Kochanowicz"
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
               (:file "documentation")))
