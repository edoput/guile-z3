;;; ffi-spec exposes aliases for '* to use in the foreign function
;;; interface. It is intended to extend the bindings from guile's
;;; own (system foreign) foreign types.
(define-module (ffi-spec)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:export (ast
	    config
	    context
	    func-decl
	    model
	    sort))

(define ast '*)
(define config '*)
(define context '*)
(define func-decl '*)
(define model '*)
(define sort '*)

