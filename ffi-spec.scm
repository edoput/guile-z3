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
;;; 
;;; ffi-spec exposes aliases for '* to use in the foreign function
;;; interface. It is intended to extend the bindings from guile's
;;; own (system foreign) foreign types.

;;; Code:

(define-module (ffi-spec)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:export (ast
	    config
	    context
	    func-decl
	    model
	    solver
	    sort
	    string))

(define ast '*)
(define config '*)
(define context '*)
(define func-decl '*)
(define model '*)
(define solver '*)
(define sort '*)
(define string '*)

