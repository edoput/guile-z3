(define-module (solver)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module (context)
  #:use-module (ast)
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
			    #:return-type '*
			    #:arg-types '(*)))

(define z3-solver-assert
  (foreign-library-function z3-lib "Z3_solver_assert"
			    ;; ctx solver ast
			    #:arg-types '(* * *)))

(define z3-solver-check
  (foreign-library-function z3-lib "Z3_solver_check"
			    #:return-type int
			    #:arg-types '(* *)))

(define z3-solver-get-model
  (foreign-library-function z3-lib "Z3_solver_get_model"
			    #:return-type '*
			    #:arg-types '(* *)))

(define z3-solver-reset
  (foreign-library-function z3-lib "Z3_solver_reset"
			    #:arg-types '(* *)))

(define (make-solver ctx)
  (wrap-solver (z3-mk-solver (unwrap-context ctx))))

(define (solver-assert! ctx solver ast)
  (z3-solver-assert (unwrap-context ctx)
		    (unwrap-solver solver)
		    (unwrap-ast ast)))

(define (solver-check ctx solver)
  (z3-solver-check (unwrap-context ctx)
		   (unwrap-solver solver)))

(define (solver-model ctx solver)
  (z3-solver-get-model (unwrap-context ctx)
		       (unwrap-solver solver)))

(define (solver-reset! ctx solver)
  (z3-solver-reset (unwrap-context ctx)
		   (unwrap-solver solver)))
