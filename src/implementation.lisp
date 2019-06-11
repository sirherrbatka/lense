(cl:in-package #:lense)


(defmethod initialize-instance :after ((lense fundamental-lense)
                                       &key &allow-other-keys)
  (c2mop:set-funcallable-instance-function lense (curry #'read lense)))

(defmethod gather ((lense fundamental-lense)
                   &optional (destination-vector
                              (make-array 0 :fill-pointer 0
                                            :adjustable t)))
  (check-type destination-vector (and vector (satisfies adjustable-array-p)))
  (vector-push-extend lense destination-vector)
  destination-vector)

(defmethod gather ((lense composed-lense)
                   &optional (destination-vector
                              (make-array 0 :fill-pointer 0
                                            :adjustable t)))
  (check-type destination-vector (and vector (satisfies adjustable-array-p)))
  (map nil (lambda (sublense)
             (gather sublense destination-vector))
       (internal-lenses lense))
  destination-vector)

(defmethod read ((lense basic-lense) object)
  (funcall (read-callback lense) object))

(defmethod write ((lense basic-lense) value object)
  (funcall (write-callback lense) object value))

(defmethod read ((lense composed-lense) object)
  (reduce (lambda (source sublense) (read sublense source))
          (the vector (internal-lenses lense))
          :initial-value object))

(defmethod transform ((lense composed-lense) transformation object)
  (ensure-functionf transformation)
  (let* ((sublenses (internal-lenses lense))
         (length (length sublenses))
         (last (1- length)))
    (declare (type vector sublenses)
             (type fixnum last length))
    (loop for i from 0 below last
          for sublense = (aref sublenses i)
          do (setf object (read sublense object)))
    (transform (aref sublenses last) transformation object)))

(defmethod write ((lense composed-lense) value object)
  (let* ((sublenses (internal-lenses lense))
         (length (fill-pointer sublenses))
         (last (1- length)))
    (declare (type vector sublenses)
             (type fixnum last length))
    (loop for i from 0 below last
          for sublense across sublenses
          do (setf object (read sublense object)))
    (write (aref sublenses last) value object)))
