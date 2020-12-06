(cl:in-package #:lense)


(defclass view-class (c2mop:standard-class)
  ())

(defclass view-slot-definition (c2mop:standard-slot-definition)
  ((%computed-readers
     :initform nil
     :type list
     :accessor computed-readers
     :initarg :computed-readers)
   (%computed-writers
    :initform nil
    :type list
    :accessor computed-writers
    :initarg :computed-writers)
   (%lensep :initarg :lensep
            :type boolen
            :reader lensep)
   (%destination :initarg :destination
                 :reader destination)))

(defclass direct-view-slot-definition (c2mop:standard-direct-slot-definition
                                       view-slot-definition)
  ()
  (:default-initargs :lensep nil))

(defmethod initialize-instance :around ((slot direct-view-slot-definition)
                                        &rest args &key readers writers &allow-other-keys)
  (remf args :readers)
  (remf args :writers)
  (apply #'call-next-method slot
         :computed-readers readers
         :computed-writers writers
         args))

(defclass effective-view-slot-definition (c2mop:standard-effective-slot-definition
                                          view-slot-definition)
  ())

(defmethod c2mop:direct-slot-definition-class ((class view-class)
                                               &rest initargs)
  (declare (ignore initargs))
  (find-class 'direct-view-slot-definition))

(defmethod c2mop:effective-slot-definition-class ((class view-class)
                                                  &rest initargs)
  (declare (ignore initargs))
  (find-class 'effective-view-slot-definition))

(defmethod c2mop:validate-superclass ((class view-class)
                                      (super c2mop:standard-class))
  t)

(defmethod c2mop:compute-effective-slot-definition
    ((class view-class) name direct-slot-definitions)
  (let ((last-definition (first direct-slot-definitions))
        (result (call-next-method)))
    (setf (slot-value result '%lensep) (lensep last-definition))
    (setf (slot-value result '%computed-readers)
          (remove-duplicates (apply #'append (mapcar #'computed-readers direct-slot-definitions))
                             :test 'equal))
    (setf (slot-value result '%computed-writers)
          (remove-duplicates (apply #'append (mapcar #'computed-writers direct-slot-definitions))
                             :test 'equal))
    (when (lensep last-definition)
      (let ((destination (destination last-definition)))
        (check-type destination symbol)
        (setf (slot-value result '%destination) (destination last-definition))))
    result))

(defun ensure-view-accessor-for (class accessor-name effective-slot type)
  (let* ((gf (c2mop:ensure-generic-function
              accessor-name :lambda-list
              (ecase type
                (:reader '(object))
                (:writer '(new-value object)))))
         (specializers (ecase type
                         (:reader (list class))
                         (:writer (list (find-class 't) class)))))
    (c2mop:ensure-method
     gf
     (ecase type
       (:reader
        `(lambda (object)
           ,(if (lensep effective-slot)
                `(read (slot-value object ',(c2mop:slot-definition-name effective-slot))
                       (slot-value object ',(destination effective-slot)))
                `(slot-value object ',(c2mop:slot-definition-name effective-slot)))))
       (:writer
        `(lambda (new-value object)
           ,(if (lensep effective-slot)
                `(write (slot-value object ',(c2mop:slot-definition-name effective-slot))
                        new-value
                        (slot-value object ',(destination effective-slot)))
                `(setf (slot-value object ',(c2mop:slot-definition-name effective-slot)) new-value)))))
     :specializers specializers)))

(defun ensure-view-accessors-for (class)
  (loop for effective-slot :in (c2mop:class-slots class)
        do (dolist (reader (computed-readers effective-slot))
             (ensure-view-accessor-for class reader effective-slot :reader))
           (dolist (writer (computed-writers effective-slot))
             (ensure-view-accessor-for class writer effective-slot :writer))))
