(cl:in-package #:lense)


(defmacro for ((symbol &rest arguments))
  (let* ((!_ (gensym))
         (proto-bindings (mapcar (lambda (x)
                                   (if (eq x :_)
                                       !_
                                       (list (gensym) x)))
                                 arguments))
         (!bindings (remove-if #'symbolp proto-bindings))
         (!lambda-values (mapcar (lambda (x)
                                   (if (listp x)
                                       (first x)
                                       x))
                                 proto-bindings))
         (_count (count :_ arguments :test #'eq)))
    (unless (= _count 1)
      (error 'program-error "ARGUMENTS should include exactly one :_."))
    `(let (,@!bindings)
       (make-instance
        'basic-lense
        :read-callback (lambda (,!_)
                         (,symbol ,@!lambda-values))
        :write-callback (lambda (,!_ value)
                          (setf (,symbol ,@!lambda-values) value))))))
