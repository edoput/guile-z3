(define-module (reflect)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module (context)
  #:use-module (model)
  #:use-module (ast)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:export (model-num-consts
	    model-num-funcs
	    model-num-sorts
	    model-const-decl-ref
	    model-func-decl-ref
	    model-has-interpretation?
	    model-sort-ref
	    model-sort-universe))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-model-get-num-consts
  (foreign-library-function z3-lib "Z3_model_get_num_consts"
			    #:return-type unsigned-int
			    #:arg-types (list z3:context z3:model)))

(define z3-model-get-num-funcs
  (foreign-library-function z3-lib "Z3_model_get_num_funcs"
			    #:return-type unsigned-int
			    #:arg-types (list z3:context z3:model)))

(define z3-model-get-num-sorts
  (foreign-library-function z3-lib "Z3_model_get_num_sorts"
			    #:return-type unsigned-int
			    #:arg-types (list z3:context z3:model)))

(define (model-num-consts ctx model)
  (z3-model-get-num-consts (unwrap-context ctx) (unwrap-model model)))

(define (model-num-funcs ctx model)
  (z3-model-get-num-funcs (unwrap-context ctx) (unwrap-model model)))

(define (model-num-sorts ctx model)
  (z3-model-get-num-sorts (unwrap-context ctx) (unwrap-model model)))

;;; declarations
(define z3-model-get-const-decl
  (foreign-library-function z3-lib "Z3_model_get_const_decl"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model unsigned-int)))


(define z3-model-get-func-decl
  (foreign-library-function z3-lib "Z3_model_get_func_decl"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model unsigned-int)))

(define (model-const-decl-ref ctx model i)
  (wrap-fun (z3-model-get-const-decl (unwrap-context ctx) (unwrap-model model) i)))

(define (model-func-decl-ref ctx model i)
  (wrap-fun (z3-model-get-func-decl (unwrap-context ctx) (unwrap-model model) i)))

;;; interpretation

(define z3-model-get-const-interp
  (foreign-library-function z3-lib "Z3_model_get_const_interp"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model z3:func-decl)))

(define z3-model-has-interp
  (foreign-library-function z3-lib "Z3_model_has_interp"
			    #:return-type int
			    #:arg-types (list z3:context z3:model z3:func-decl)))

(define z3-model-get-func-interp
  (foreign-library-function z3-lib "Z3_model_get_func_interp"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model z3:func-decl)))


(define (model-has-interpretation? ctx model func)
  (= 1 (z3-model-has-interp (unwrap-context ctx) (unwrap-model model) (unwrap-fun func))))

;;; sorts

(define z3-model-get-sort
  (foreign-library-function z3-lib "Z3_model_get_sort"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model unsigned-int)))

(define z3-model-get-sort-universe
  (foreign-library-function z3-lib "Z3_model_get_sort_universe"
			    #:return-type '*
			    #:arg-types (list z3:context z3:model z3:sort)))

(define (model-sort-ref ctx model i)
  (wrap-sort (z3-model-get-sort (unwrap-context ctx) (unwrap-model model) i)))

(define (model-sort-universe ctx model sort)
  ;; TODO(edoput) z3_ast_vector
  (z3-model-get-sort-universe (unwrap-context ctx)
			      (unwrap-model model)
			      (unwrap-sort sort)))
