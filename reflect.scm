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

;;; Interface to Z3's reflection.

;;; Code:

(define-module (reflect)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (context)
  #:use-module (model)
  #:use-module (ast)
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

(define (model-num-consts model)
  (z3-model-get-num-consts (unwrap-context (current-context)) (unwrap-model model)))

(define (model-num-funcs model)
  (z3-model-get-num-funcs (unwrap-context (current-context)) (unwrap-model model)))

(define (model-num-sorts model)
  (z3-model-get-num-sorts (unwrap-context (current-context)) (unwrap-model model)))

;;; declarations
(define z3-model-get-const-decl
  (foreign-library-function z3-lib "Z3_model_get_const_decl"
			    #:return-type z3:func-decl
			    #:arg-types (list z3:context z3:model unsigned-int)))


(define z3-model-get-func-decl
  (foreign-library-function z3-lib "Z3_model_get_func_decl"
			    #:return-type z3:func-decl
			    #:arg-types (list z3:context z3:model unsigned-int)))

(define (model-const-decl-ref model i)
  (wrap-fun (z3-model-get-const-decl (unwrap-context (current-context)) (unwrap-model model) i)))

(define (model-func-decl-ref ctx model i)
  (wrap-fun (z3-model-get-func-decl (unwrap-context (current-context)) (unwrap-model model) i)))

;;; interpretation

(define z3-model-get-const-interp
  (foreign-library-function z3-lib "Z3_model_get_const_interp"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:model z3:func-decl)))

(define z3-model-has-interp
  (foreign-library-function z3-lib "Z3_model_has_interp"
			    #:return-type int
			    #:arg-types (list z3:context z3:model z3:func-decl)))

(define z3-model-get-func-interp
  (foreign-library-function z3-lib "Z3_model_get_func_interp"
			    #:return-type z3:func-interp
			    #:arg-types (list z3:context z3:model z3:func-decl)))


(define (model-has-interpretation?  model func)
  (= 1 (z3-model-has-interp (unwrap-context (current-context)) (unwrap-model model) (unwrap-fun func))))

;;; sorts

(define z3-model-get-sort
  (foreign-library-function z3-lib "Z3_model_get_sort"
			    #:return-type z3:sort
			    #:arg-types (list z3:context z3:model unsigned-int)))

(define z3-model-get-sort-universe
  (foreign-library-function z3-lib "Z3_model_get_sort_universe"
			    #:return-type '* ; ast-vector
			    #:arg-types (list z3:context z3:model z3:sort)))

(define (model-sort-ref model i)
  (wrap-sort (z3-model-get-sort (unwrap-context (current-context)) (unwrap-model model) i)))

(define (model-sort-universe model sort)
  ;; TODO(edoput) z3_ast_vector
  (z3-model-get-sort-universe (unwrap-context (current-context))
			      (unwrap-model model)
			      (unwrap-sort sort)))
