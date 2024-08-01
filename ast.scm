(define-module (ast)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
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

(define (sort->string ctx sort)
  (z3-sort-to-string (unwrap-context ctx)
		     (unwrap-sort sort)))

(define z3-sort-to-string
  (foreign-library-function z3-lib "Z3_sort_to_string"
			    #:return-type '*
			    ;; ctx sort
			    #:arg-types '(* *)))

;;; AST 
(define-wrapped-pointer-type <ast>
  ast?
  wrap-ast unwrap-ast
  (lambda (s p)
    (format p "#<ast ~a>" (pointer-address (unwrap-ast s)))))

(define z3-ast-to-string
  (foreign-library-function z3-lib "Z3_ast_to_string"
			    #:return-type '*
			    ;; ctx ast
			    #:arg-types '(* *)))

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
			    #:return-type '*
			    #:arg-types '(*)))
(define z3-mk-bool-sort
  (foreign-library-function z3-lib "Z3_mk_bool_sort"
			    #:return-type '*
			    #:arg-types '(*)))


(define z3-get-sort-kind
  (foreign-library-function z3-lib "Z3_get_sort_kind"
			    #:return-type int
			    ;; ctx sort
			    #:arg-types '(* *)))
;;; sort



(define z3-mk-string-symbol
  (foreign-library-function z3-lib "Z3_mk_string_symbol"
			    #:return-type '*
			    ;; ctx name sort
			    #:arg-types '(* * *)))

(define z3-mk-const
  (foreign-library-function z3-lib "Z3_mk_const"
			    #:return-type '*
			    ;; ctx symbol sort
			    #:arg-types '(* * *)))

(define z3-mk-int
  (foreign-library-function z3-lib "Z3_mk_int"
			    #:return-type '*
			    ;; ctx n sort
			    #:arg-types (list '* int '*)))

(define z3-mk-divides
  (foreign-library-function z3-lib "Z3_mk_divides"
			    #:return-type '*
			    ;;  ctx ast ast
			    #:arg-types (list '* '* '*)))

(define z3-get-sort
  (foreign-library-function z3-lib "Z3_get_sort"
			    #:return-type '*
			    ;; ctx ast
			    #:arg-types '(* *)))


(define (ast-sort ctx ast)
  (wrap-sort (z3-get-sort (unwrap-context ctx) (unwrap-ast ast))))


(define z3-get-sort-name
  (foreign-library-function z3-lib "Z3_get_sort_name"
			    #:return-type '*
			    ;; ctx sort
			    #:arg-types '(* *)))

;;;  exported
;;;  this is the procedural layer to interact with Z3


(define (make-int-sort ctx)
  (wrap-sort (z3-mk-int-sort (unwrap-context ctx))))

(define (make-string-symbol ctx name sort)
  (wrap-ast
   (z3-mk-string-symbol (unwrap-context ctx)
			(scm->pointer name)
			(unwrap-sort sort))))

(define (make-const ctx symbol sort)
  (wrap-ast
   (z3-mk-const (unwrap-context ctx)
		(unwrap-ast symbol)
		(unwrap-sort sort))))

(define (make-int ctx n sort)
  (wrap-ast
   (z3-mk-int (unwrap-context ctx)
	      n
	      (unwrap-sort sort))))

(define (make-divides ctx t1 t2)
  (wrap-ast
   (z3-mk-divides (unwrap-context ctx)
		  (unwrap-ast t1)
		  (unwrap-ast t2))))

(define (sort-kind ctx sort)
  (pointer->string
   (z3-get-sort-kind (unwrap-context ctx)
		     (unwrap-sort sort))))

(define (sort-name ctx sort)
  (pointer->string 
   (z3-get-sort-name (unwrap-context ctx)
		     (unwrap-sort sort))))

