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

;;; Interface to Z3's goal.

;;; Code:

(define-module (goal)
  #:use-module (ice-9 optargs)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:use-module (context)
  #:export (make-goal
	    goal-assert!
	    goal-reset!
	    goal-inconsistent?
	    goal-is-decided-sat?
	    goal-is-decided-unsat?))

(define-wrapped-pointer-type <goal>
  goal?
  wrap-goal unwrap-goal
  (lambda goal
    (format p "#<goal ~a>" (pointer-address (unwrap-goal goal)))))

(define z3-lib (load-foreign-library "libz3.so"))

(define z3-mk-goal
  (foreign-library-function z3-lib "Z3_mk_goal"
			    #:return-type z3:goal
			    #:arg-types (list z3:context integer integer integer)))

(define z3-goal-inc-ref
  (foreign-library-function z3-lib "Z3_goal_inc_ref"
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-dec-ref
  (foreign-library-function z3-lib "Z3_goal_dec_ref"
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-assert
  (foreign-library-function z3-lib "Z3_goal_assert"
			    #:arg-types (list z3:context z3:goal z3:ast)))

(define z3-goal-inconsistent
  (foreign-library-function z3-lib "Z3_goal_inconsistent"
			    #:return-type integer
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-depth
  (foreign-library-function z3-lib "Z3_goal_depth"
			    #:return-type unsigned
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-reset
  (foreign-library-function z3-lib "Z3_goal_reset"
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-size
  (foreign-library-function z3-lib "Z3_goal_size"
			    #:return-type unsigned
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-formula
  (foreign-library-function z3-lib "Z3_goal_formula"
			    #:return-type z3:ast
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-num-exprs
  (foreign-library-function z3-lib "Z3_goal_num_exprs"
			    #:return-type unsigned
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-is-decided-sat
  (foreign-library-function z3-lib "Z3_goal_is_decided_sat"
			    #:return-type integer
			    #:arg-types (list z3:context z3:goal)))

(define z3-goal-is-decided-unsat
  (foreign-library-function z3-lib "Z3_goal_is_decided_unsat"
			    #:arg-types (list z3:context z3:goal)))

(define* (make-goal #:optional (models true) (unsat-cores true) (proofs true))
  ""
  (let ((g (z3-make-goal (unwrap-context (current-context))
			 models unsat-cores proofs)))
    (begin
      (z3-goal-inc-ref (unwrap-context (current-context)) g)
      (wrap-goal g))))

(define (goal-assert! goal constraint)
  "Add constraint to goal."
  (z3-goal-assert (unwrap-context (current-context))
		  (unwrap-goal goal)
		  (unwrap-ast constraint)))

(define (goal-reset! goal)
  "Erases all constraints from goal."
  (z3-goal-reset (unwrap-context (current-context))
		 (unwrap-goal goal)))

(define (goal-inconsistent? goal)
  "The current goal contains the formula `false."
  (= 1 (z3-goal-inconsistent (unwrap-context (current-context))
			     (unwrap-goal goal))))

(define (goal-is-decided-sat? goal)
  (= 1 (z3-goal-is-decided-sat (unwrap-context (current-context))
			       (unwrap-goal goal))))

(define (goal-is-decided-unsat? goal)
  (= 1 (z3-goal-is-decided-unsat (unwrap-context (current-context))
				 (unwrap-goal goal))))
