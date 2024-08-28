(define-module (solver)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (context)
  #:use-module (ast)
  #:use-module (model)
  #:export (make-solver
	    solver-assert!
	    solver-check
	    solver-reset!
	    solver-model))

(define-wrapped-pointer-type <solver>
  solver?
  wrap-solver unwrap-solver
  (lambda (sol p)
    (format p "#<solver ~a>" (pointer-address (unwrap-solver sol)))))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-mk-solver
  (foreign-library-function z3-lib "Z3_mk_solver"
			    #:return-type z3:solver
			    #:arg-types (list z3:context)))

(define z3-solver-assert
  (foreign-library-function z3-lib "Z3_solver_assert"
			    #:arg-types (list z3:context z3:solver z3:ast)))

(define z3-solver-check
  (foreign-library-function z3-lib "Z3_solver_check"
			    #:return-type int
			    #:arg-types (list z3:context z3:solver)))

(define z3-solver-get-model
  (foreign-library-function z3-lib "Z3_solver_get_model"
			    #:return-type '*
			    #:arg-types (list z3:context z3:solver)))

(define z3-solver-reset
  (foreign-library-function z3-lib "Z3_solver_reset"
			    #:arg-types (list z3:context z3:solver)))

(define (make-solver)
  (wrap-solver (z3-mk-solver (unwrap-context (current-context)))))

(define (solver-assert! solver ast)
  (z3-solver-assert (unwrap-context (current-context))
		    (unwrap-solver solver)
		    (unwrap-ast ast)))

(define (solver-check solver)
  (z3-solver-check (unwrap-context (current-context))
		   (unwrap-solver solver)))

(define (solver-model solver)
  (wrap-model (z3-solver-get-model (unwrap-context (current-context))
				   (unwrap-solver solver))))

(define (solver-reset! solver)
  (z3-solver-reset (unwrap-context (current-context))
		   (unwrap-solver solver)))
