(cl:in-package #:cl-user)


(defpackage lense
  (:use #:cl #:alexandria)
  (:shadow cl:read cl:write alexandria:compose)
  (:export
   #:basic-lense
   #:compose
   #:composed-lense
   #:for
   #:fundamental-lense
   #:access
   #:view-class
   #:gather
   #:read
   #:transform
   #:write))
