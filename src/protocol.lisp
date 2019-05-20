(cl:in-package #:lense)


(defgeneric gather (lense &optional destination-vector))

(defun compose (lense &rest more-lenses)
  (make-instance
   'composed-lense
   :internal-lenses (reduce (lambda (collection lense)
                              (gather lense collection))
                            (cons lense more-lenses)
                            :initial-value (make-array 4 :element-type t
                                                         :adjustable t
                                                         :fill-pointer 0))))

(defgeneric read (lense object))

(defgeneric write (lense value object))

(defgeneric transform (lense transformation object)
  (:method ((lense fundamental-lense) transformation object)
    (ensure-functionf transformation)
    (let* ((value (read lense object))
           (new-value (funcall transformation value)))
      (write lense new-value object))))

(defgeneric access (lense object)
  (:method ((lense fundamental-lense) object)
    (read lense object)))

(defgeneric (setf access) (value lense object)
  (:method (value (lense fundamental-lense) object)
    (write lense value object)))
