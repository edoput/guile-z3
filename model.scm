(define-module (model)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module (context)
  #:export (make-model
	    unwrap-model))

;;; TODO z3 types syntax
;;; I just need to expand (list ctx) to (list '*)

;; TODO reference counting
(define-wrapped-pointer-type <model>
  model?
  wrap-model unwrap-model
  (lambda (mod p)
    (format p "#<model ~a>" (pointer-address (unwrap-model mod)))))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-mk-model
  (foreign-library-function z3-lib "Z3_mk_model"
			    #:return-type '*
			    #:arg-types '(*)))

(define z3-model-inc-ref
  (foreign-library-function z3-lib "Z3_model_inc_ref"
			    #:arg-types '(* *)))

(define z3-model-dec-ref
  (foreign-library-function z3-lib "Z3_model_dec_ref"
			    #:arg-types '(* *)))

(define z3-model-eval
  (foreign-library-function z3-lib "Z3_model_eval"
			    #:return-type int
			    ; ctx model ast bool ast
			    #:arg-types (list '* '* '* int '*)))

(define z3-model-translate
  (foreign-library-function z3-lib "Z3_model_translate"
			    #:return-type '*
			    ;; ctx model model
			    #:arg-types '(* * *)))

(define (make-model ctx)
  (wrap-model (z3-mk-model (unwrap-context ctx))))

(define (model-inc-ref ctx model)
  (z3-model-inc-ref (unwrap-context ctx) (unwrap-model model)))
  
(define (model-dec-ref ctx model)
  (z3-model-dec-ref (unwrap-context ctx) (unwrap-model model)))

;; TODO outparam
;;(define (model-eval ctx mode ast complete)
;;  (let ((result-ast (make-ast)))

;;; model introspection

