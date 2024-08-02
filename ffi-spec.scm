(define-module (ffi-spec)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:export (z3:ffi
	    ast
	    config
	    context
	    func-decl
	    model))

;;; this module defined syntax for writing down FFI spec for
;;; Z3. This means you can write (z3:ffi ctx model) in place
;;; of (list '* '*) whenever you are binding a foreign function.

;;; As of now we also evaluated the ref-spec macro but this can
;;; be bypassed with identifier-syntax so that other foreign types
;;; can be used in the spec.

(define-syntax z3:ffi
  (syntax-rules (ctx model)
    ((_ ref-spec ...)
     (list (ref-spec) ...))))

(define-syntax-rule (ast) "Z3 ast reference type" '*)
(define-syntax-rule (config) "Z3 config reference type" '*)
(define-syntax-rule (context) "Z3 context reference type" '*)
(define-syntax-rule (func-decl) "Z3 function declaration reference type" '*)
(define-syntax-rule (model) "Z3 model reference type" '*)


