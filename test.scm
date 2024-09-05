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

;;; Code:
(use-modules (z3)
	     (srfi srfi-64))

(define (describe-model ctx sat-model)
  (let ((count (model-num-sorts ctx sat-model)))
    (format #t "model contains ~d sorts\n" count)
    (do ((i 0 (1+ i))) (= i count)
      (let ((sort (model-sort-ref ctx sat-model i)))
	(format #t "~a: sort ~a" i sort))))
  (let ((count (model-num-consts ctx sat-model)))
    (format #t "model contains ~d constants\n" count)
    (do ((i 0 (1+ i))) (= i count)
      (let ((decl (model-const-decl-ref ctx sat-model i)))
	(format #t "~a: const declaration ~a" i decl))))
  (let ((count (model-num-funcs ctx sat-model)))
    (format #t "model contains ~d functions\n" count)
    (do ((i 0 (1+ i))) (= i count)
      (let ((func (model-func-decl-ref ctx sat-model i)))
	(format #t "~a: func declaration ~a" i func)))))

(define cfg (make-config))
(define ctx (make-context cfg))

(parameterize ((current-context ctx))
  (define solver (make-solver))
  ;;; everything prefixed by % is a concept from Z3 such as _sorts_, _variables_, _number literals_
  (define %int (make-int-sort))
  (define %n (make-int 10 %int))
  (define %m (make-int 5 %int))

  (case (solver-check solver)
    ((-1) (format #t "UNSAT\n"))
    ((0) (format #t "UNDEFINED\n"))
    ((1) (format #t "SAT!\n")))

  (define sat-clause (make-divides %m %n))
  (solver-assert! solver sat-clause)

  (case (solver-check solver)
    ((-1) (format #t "UNSAT\n"))
    ((0) (format #t "UNDEFINED\n"))
    ((1) (format #t "SAT!\n")))

					;(solver-reset! ctx solver)
  (define unsat-clause (make-divides  %n %m))

  (solver-assert! solver unsat-clause)

  (case (solver-check solver)
    ((-1) (format #t "UNSAT\n"))
    ((0) (format #t "UNDEFINED\n"))
    ((1) (format #t "SAT!\n")))

					;(solver-reset! ctx solver)
;;; define SAT variables by name
  (define %A (make-string-symbol "A"))

  (define ?x (make-const %A %int))

;;; TODO(edoput) error happesn in make-divides no idea why

  (solver-assert! solver (make-divides ?x %n))

  (case (solver-check solver)
    ((-1) (format #t "UNSAT\n"))
    ((0) (format #t "UNDEFINED\n"))
    ((1) (format #t "SAT!\n")))

  (describe-model (current-context) (solver-model solver))
					;(solver-reset! ctx solver)
  )
