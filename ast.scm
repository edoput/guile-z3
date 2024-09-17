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

;;; Interface to Z3's syntax tree.

;;; Code:

(define-module (ast)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (context)
  #:export (wrap-sort
	    unwrap-sort
	    wrap-fun
	    unwrap-fun
	    ;; 
	    sort->string
	    unwrap-ast
	    ast->string
	    ;; 
	    make-sort
	    make-int-sort
	    make-string-symbol
	    make-const
	    make-int
	    make-divides))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define-wrapped-pointer-type <sort>
  sort?
  wrap-sort unwrap-sort
  (lambda (s p)
    (format p "#<sort ~a>" (pointer-address (unwrap-sort s)))))

(define z3-sort-to-string
  (foreign-library-function z3-lib "Z3_sort_to_string"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:sort)))

(define (sort->string ctx sort)
  (pointer->string
   (z3-sort-to-string (unwrap-context ctx)
		      (unwrap-sort sort))))

;;; AST 
(define-wrapped-pointer-type <ast>
  ast?
  wrap-ast unwrap-ast
  (lambda (s p)
    (format p "#<ast ~a>" (pointer-address (unwrap-ast s)))))

(define z3-ast-to-string
  (foreign-library-function z3-lib "Z3_ast_to_string"
			    #:return-type z3:string
			    #:arg-types (list z3:context z3:ast)))

(define (ast->string ctx ast)
  "NOTE: string bytes are owned by context!"
  (pointer->string (z3-ast-to-string (unwrap-context ctx) (unwrap-ast ast))))

;;; fundecl

(define-wrapped-pointer-type <fun>
  fun?
  wrap-fun unwrap-fun
  (lambda (fun p)
    (format p "#<fun ~a>" (pointer-address (unwrap-fun fun)))))


(define z3-mk-int-sort
  (foreign-library-function z3-lib "Z3_mk_int_sort"
			    #:return-type z3:sort
			    #:arg-types (list z3:context)))
(define z3-mk-bool-sort
  (foreign-library-function z3-lib "Z3_mk_bool_sort"
			    #:return-type z3:sort
			    #:arg-types (list z3:context)))


(define z3-get-sort-kind
  (foreign-library-function z3-lib "Z3_get_sort_kind"
			    #:return-type int
			    ;; ctx sort
			    #:arg-types (list z3:context z3:sort)))

(define z3-mk-int-symbol
  (foreign-library-function z3-lib "Z3_mk_int_symbol"
			    #:return-type z3:ast
			    #:arg-types (list z3:context int)))


(define z3-mk-string-symbol
  (foreign-library-function z3-lib "Z3_mk_string_symbol"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:string)))

(define z3-mk-const
  (foreign-library-function z3-lib "Z3_mk_const"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:ast z3:sort)))

(define z3-mk-int
  (foreign-library-function z3-lib "Z3_mk_int"
			    #:return-type z3:ast
			    #:arg-types (list z3:context int z3:sort)))

(define z3-mk-divides
  (foreign-library-function z3-lib "Z3_mk_divides"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:ast z3:ast)))

(define z3-get-sort
  (foreign-library-function z3-lib "Z3_get_sort"
			    #:return-type z3:sort
			    ;; ctx ast
			    #:arg-types (list z3:context z3:ast)))

(define (ast-sort ctx ast)
  (wrap-sort (z3-get-sort (unwrap-context ctx) (unwrap-ast ast))))


(define z3-get-sort-name
  (foreign-library-function z3-lib "Z3_get_sort_name"
			    #:return-type z3:string
			    ;; ctx sort
			    #:arg-types (list z3:context z3:sort)))

;;;  exported
;;;  this is the procedural layer to interact with Z3


(define (make-int-sort)
  (wrap-sort (z3-mk-int-sort (unwrap-context (current-context)))))

(define (make-int-symbol i)
  (wrap-ast
   (z3-mk-int-symbol (unwrap-context (current-context)) i)))

(define (make-string-symbol name)
  (wrap-ast
   (z3-mk-string-symbol (unwrap-context (current-context))
			(scm->pointer name))))

(define (make-const symbol sort)
  (wrap-ast
   (z3-mk-const (unwrap-context (current-context))
		(unwrap-ast symbol)
		(unwrap-sort sort))))

(define (make-int n sort)
  (wrap-ast
   (z3-mk-int (unwrap-context (current-context))
	      n
	      (unwrap-sort sort))))

(define (make-divides t1 t2)
  (wrap-ast
   (z3-mk-divides (unwrap-context (current-context))
		  (unwrap-ast t1)
		  (unwrap-ast t2))))

(define (sort-kind sort)
  (pointer->string
   (z3-get-sort-kind (unwrap-context (current-context))
		     (unwrap-sort sort))))

(define (sort-name ctx sort)
  (pointer->string 
   (z3-get-sort-name (unwrap-context (current-context))
		     (unwrap-sort sort))))

