(define-module (config)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:export (make-config
	    unwrap-config))

(define-wrapped-pointer-type <config>
  config?
  wrap-config unwrap-config
  (lambda (cfg p)
    (format p "#<config ~a>" (pointer-address (unwrap-config cfg)))))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-mk-config
  (foreign-library-function z3-lib "Z3_mk_config"
			    #:return-type '*
			    #:arg-types '()))

(define (make-config)
  (wrap-config (z3-mk-config)))
