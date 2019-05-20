* Lense
Racket style lenses for the Common Lisp. Portable, extendable, simple.

* Quick explanation
Lenses objects acting as a first-class accessors build around SETFable places. They are composable by default, which greatly simplifies building nested representations.

* Demonstration
This package exports just few symbols. You can use READ, WRITE (or ACCESS if you prefer to do so) as well as TRANSFORM to interact with lenses. To create a new lense use FOR macro and COMPOSE function.

#+BEGIN_SRC common-lisp
(defparameter *data* (list 1 2 3))
(defparameter *lense* (lense:for (elt :_ 0)))
(print (lense:read *lense* *data*)) ; => 1
(lense:write *lense* 10 *data*)
(print (lense:read *lense* *data*)) ; => 10
(defparameter *nested-data* (list *data*))
(defparameter *nested-lense* (lense:compose *lense* *lense*))
(print (lense:read *nested-lense* *nested-data*)) ; => 10
(lense:write *nested-lense* 1 *nested-data*)
(print (lense:read *nested-lense* *nested-data*)) ; => 1
(lense:transform *nested-lense* #'1+ *nested-data*)
(print (lense:read *nested-lense* *nested-data*)) ; => 2
(setf (lense:access *nested-lense* *nested-data*) 1)
(print (lense:access *nested-lense* *nested-data*)) ; => 1
#+END_SRC

* Notes
Code generated by FOR macro will evaluate arguments to the place only once, regardless of any further calls to READ and WRITE. It will not perform full code walk in search of :_, it MUST occur on the first level. This will probabbly not change because any more complicated behavior would destroy equality between SETFable place and lense.
