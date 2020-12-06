(cl:in-package #:lense)


(docs:define-docs
  :formatter docs.ext:rich-aggregating-formatter

  (type basic-lense
    (:description "Elementary lense, acts as a wrapper around an setfable place. Constructed by expansion of LENS:FOR macro."))

  (type fundamental-lense
    (:description "Fundamental class of all lenses. All subclasses of this class should support following generic functions: READ, WRITE. TRANSFORM and GATHER have potentially usefull default methods (TRANSFORM simply calls READ and WRITE in a succession which may or may not be efficient, GATHER simply puts the lense into the result vector)."))

  (type composed-lense
    (:description "COMPOSED-LENSE pipes all READ, WRITE and COMPOSE calls trough the lenses used to construct the result (from left to right, in the opposite order to the ALEXANDRIA:COMPOSE)."))

  (function compose
    (:description "Stacks lenses on each other to build a COMPOSED-LENS."
     :exceptional-situations "Every argument must be a lense supporting GATHER function."
     :returns "Instance of COMPOSED-LENSE."))

  (function read
    (:description "Read trough the lens. Use the LENS to retrieve value from the OBJECT."
     :arguments ((lense "LENS used to read the OBJECT.")
                 (object "OBJECT that is being read."))
     :returns "Value obtained."
     :notes "Instead of calling this function, one may funcall LENSE object directly on data."
     :see-also (access write)))

  (function write
    (:description "Write trough the lens. Use the LENS to deposit value into the OBJECT."
     :arguments ((lense "LENS used to read the OBJECT.")
                 (value "VALUE deposited into the OBJECT.")
                 (object "OBJECT that is being read."))
     :see-also (access read)))

  (function access
    (:description "SETFable alternative to the READ function."
     :see-also (read write)))

  (function transform
    (:description "READ value from the lens. FUNCALL passed transformation on the value. WRITE value back, using the same lense."
     :exceptional-situations (("Will signal CL:TYPE-ERROR (with restart) if TRANSFORMATION is not a function."))
     :arguments-and-values ((lense "LENS used for the transformation.")
                            (transformation "Function used to transform value of the OBJECT.")
                            (object "Object being transformed."))
     :notes "Specialization of this generic function for the COMPOSED-LENSE will not pipe object via the sublenses twice."))

  (function for
    (:description "Macro. Expands to construction of BASIC-LENS for designated SETFable place."
     :exceptional-situations "Use of this macro should include one symbol :_ in the arguments designating position in the lambda list where OBJECT should be placed. If there is either more than one such symbol in the ARGUMETS or there is none, the CL:PROGRAM-ERROR will be raised."))

  (function gather
    (:exceptional-situations "Will signal CL:TYPE-ERROR (with interactive restart) if DESTINATION-VECTOR is not (AND (VECTOR T) (SATISFIES ADJUSTABLE-ARRAY-P))"
     :DESCRIPTION "This function gathers all elementary lenses from the input lense into the DESTINATION-VECTOR. This is required for the simplicity and efficiency of the COMPOSE function. Constructed COMPOSED-LENSE has flat internal lenses structure which eleminates pointless recursive calls that can potentially occur otherwise."
     :arguments-and-values ((lense "LENS being scaned.")
                            (destination-vector "Vector. Function will call CL:VECTOR-PUSH-EXTEND to insert relevant content into it."))
     :returns "DESTINATION-VECTOR")))
