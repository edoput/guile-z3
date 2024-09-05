;;; Copyright (C) 2024 Edoardo Putti
;;;
;;; This file is part of guile-z3.
;;; 
;;; Guile-z3 is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;; 
;;; Guile-z3 is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with guile-z3. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Interface to Z3's context.

;;; Code:

(define-module (context)
  #:use-module (rnrs condition (6))
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (config)
  #:export (current-context
	    make-context
	    unwrap-context
	    error-code
	    error-message
	    set-context-print-mode!
	    set-context-error-handler!))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define-wrapped-pointer-type <context>
  context?
  wrap-context unwrap-context
  (lambda (ctx p)
    (format p "#<context ~a>" (pointer-address (unwrap-context ctx)))))


(define current-context
  (make-parameter (wrap-context %null-pointer)
		  (lambda (ctx)
		    (if (not (context? ctx))
			(raise-exception
			 (make-exception
			  (make-exception-with-irritants ctx)
			  (make-exception-with-origin 'current-context)
			  (make-programming-error)))
			ctx))))

(define z3-mk-context
  (foreign-library-function z3-lib "Z3_mk_context"
			    #:return-type z3:context
			    #:arg-types (list z3:config)))

;;; TODO(edoput) 5.5.5 Foreign objects and scheme
(define z3-del-context
  (foreign-library-function z3-lib "Z3_del_context"
			    #:arg-types (list z3:context)))

(define z3-get-error-code
  (foreign-library-function z3-lib "Z3_get_error_code"
			    #:return-type int
			    #:arg-types (list z3:context)))

(define z3-get-error-message
  (foreign-library-function z3-lib "Z3_get_error_msg"
			    #:return-type '*
			    #:arg-types (list z3:context int)))

(define z3-set-ast-print-mode
  (foreign-library-function z3-lib "Z3_set_ast_print_mode"
			    #:arg-types (list z3:context int)))

(define z3-set-error-handler
  (foreign-library-function z3-lib "Z3_set_error_handler"
			    #:arg-types (list z3:context '*)))

(define (make-context cfg)
  (wrap-context (z3-mk-context (unwrap-config cfg))))

;;; TODO(edoput) make conditions for error codes?
;;; Z3_OK
;;; Z3_SORT_ERROR: user tried to build an invalid (type incorrect) AST
;;; Z3_IOB: index out of bounds
;;; Z3_INVALID_ARG: invalid argument was provided
;;; Z3_PARSER_ERROR: an error occurred when parsing a string or file
;;; Z3_NO_PARSER: parser output is not available
;;; Z3_INVALID_PATTERN: invalid pattern was used to build a quantifier
;;; Z3_MEMOUT_FAIL: memory allocation error
;;; Z3_FILE_ACCESS_ERROR
;;; Z3_INVALID_USAGE: call is invalid in current state
;;; Z3_INTERNAL_FATAL
;;; Z3_DEC_REF_ERROR:
;;; Z3_EXCEPTION: go take a look at z3_get_error_msg
(define (error-code)
  (z3-get-error-code (unwrap-context (current-context))))

(define (error-message error-code)
  (pointer->string (z3-get-error-message (unwrap-context (current-context)) error-code)))

(define-values
    (*SMT-LIB-FULL* *SMT-LOW-LEVEL* *SMT-LIB2*)
  (values 0 1 2))

(define (set-context-print-mode! mode)
  (z3-set-ast-print-mode (unwrap-context (current-context)) mode))

;;; TODO(edoput) unsure; maybe raise condition or remove this
;;; and go full procedural.
(define (set-context-error-handler! handler)
  (z3-set-error-handler (unwrap-context (current-context))
			(procedure->pointer
			 void ;; return type
			 handler 	;; procedure
			 (list z3:context int))))
