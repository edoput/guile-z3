(set-car! %load-path (getcwd))
%load-path
(set-car! %load-path "/home/edoput/repo/guile/z3")

(use-modules (z3))

(define cfg (make-config))
(define ctx (make-context cfg))
(define solver (make-solver ctx))

;;; everything prefixed by % is a concept from Z3 such as _sorts_, _variables_, _number literals_
(define %int (make-int-sort ctx))

;;; 10 divides 5? Let's find out
(define %n (make-int ctx 10 %int))
(define %m (make-int ctx 5 %int))

(solver-assert! ctx solver (make-divides ctx %n %m))
(solver-check ctx solver)

;;; define SAT variables by name
(define %A (make-string-symbol ctx "A" %int))

(define ?x (make-const ctx %A %int))

;(make-divides ctx %n ?x)


