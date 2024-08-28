(define-module (model)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (context)
  #:export (make-model
	    wrap-model
	    unwrap-model))

;; TODO reference counting
(define-wrapped-pointer-type <model>
  model?
  wrap-model unwrap-model
  (lambda (mod p)
    (format p "#<model ~a>" (pointer-address (unwrap-model mod)))))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-mk-model
  (foreign-library-function z3-lib "Z3_mk_model"
			    #:return-type z3:model
			    #:arg-types (list z3:context)))

(define z3-model-inc-ref
  (foreign-library-function z3-lib "Z3_model_inc_ref"
			    #:arg-types (list z3:context z3:model)))

(define z3-model-dec-ref
  (foreign-library-function z3-lib "Z3_model_dec_ref"
			    #:arg-types (list z3:context z3:model)))

(define z3-model-eval
  (foreign-library-function z3-lib "Z3_model_eval"
			    #:return-type int
			    #:arg-types (list z3:context z3:model z3:ast int z3:ast)))

(define z3-model-translate
  (foreign-library-function z3-lib "Z3_model_translate"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model z3:model)))

(define (make-model)
  (wrap-model (z3-mk-model (unwrap-context (current-context)))))

(define (model-inc-ref model)
  (z3-model-inc-ref (unwrap-context (current-context)) (unwrap-model model)))
  
(define (model-dec-ref model)
  (z3-model-dec-ref (unwrap-context (current-context)) (unwrap-model model)))

;; TODO outparam
;;(define (model-eval ctx mode ast complete)
;;  (let ((result-ast (make-ast)))

;;; model introspection

