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

;;; Z3 module for Guile.

;;; Code:

(define-module (z3)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module (config)
  #:use-module (context)
  #:use-module (solver)
  #:use-module (model)
  #:use-module (ast)
  #:use-module (reflect)
  #:re-export (
	       ;; config
	       make-config
	       config-set-param!
	       ;; context
	       current-context
	       make-context
	       error-code
	       error-message
	       ;; solver
	       make-solver
	       solver-assert!
	       solver-check
	       solver-model
	       solver-pop-scopes!
	       solver-push-scope!
	       solver-reset!
	       solver-scopes
	       ;; model
	       make-model
	       ;; ast
	       make-int-sort
	       make-string-symbol
	       make-const
	       make-int
	       make-divides
	       sort->string
	       ast->string
	       ;; reflect
	       model-num-consts
	       model-num-funcs
	       model-num-sorts
	       model-const-decl-ref
	       model-func-decl-ref
	       model-has-interpretation?
	       model-sort-ref
	       model-sort-universe))
