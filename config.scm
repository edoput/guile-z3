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

;;; Interface to Z3's configuration.

;;; Code:

(define-module (config)
  #:use-module (ice-9 optargs)
  #:use-module (system foreign)
  #:use-module (system foreign-object)
  #:use-module (system foreign-library)
  #:use-module ((ffi-spec) #:renamer (symbol-prefix-proc 'z3:))
  #:export (make-config
	    unwrap-config
	    config-set-param!))

(define-wrapped-pointer-type <config>
  config?
  wrap-config unwrap-config
  (lambda (cfg p)
    (format p "#<config ~a>" (pointer-address (unwrap-config cfg)))))

(define z3-lib (load-foreign-library "libz3.so.4.13"))

(define z3-mk-config
  (foreign-library-function z3-lib "Z3_mk_config"
			    #:return-type z3:config
			    #:arg-types '()))

(define (make-config)
  (wrap-config (z3-mk-config)))
