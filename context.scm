(define-module (context)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module (config)
  #:export (make-context
	    unwrap-context))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define-wrapped-pointer-type <context>
  context?
  wrap-context unwrap-context
  (lambda (ctx p)
    (format p "#<context ~a>" (pointer-address (unwrap-context ctx)))))

(define z3-mk-context
  (foreign-library-function z3-lib "Z3_mk_context"
			    #:return-type '*
			    #:arg-types '(*)))

(define (make-context cfg)
  (wrap-context (z3-mk-context (unwrap-config cfg))))

