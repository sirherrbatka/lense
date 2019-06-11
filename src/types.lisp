(cl:in-package #:lense)


(defclass fundamental-lense (c2mop:funcallable-standard-object)
  ()
  (:metaclass c2mop:funcallable-standard-class))

(defclass basic-lense (fundamental-lense)
  ((%read-callback :initarg :read-callback
                   :reader read-callback)
   (%write-callback :initarg :write-callback
                    :reader write-callback)))

(defclass composed-lense (fundamental-lense)
  ((%internal-lenses :initarg :internal-lenses
                     :reader internal-lenses)))
