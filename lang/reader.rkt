#lang racket/base

(require syntax/module-reader
         (only-in "lispi.rkt" make-lispi-readtable))

(provide (rename-out [lispi-read read]
                     [lispi-read-syntax read-syntax]
                     [lispi-get-info get-info]))

(define (wrap-reader p)
  (lambda args
    (parameterize ([current-readtable (make-lispi-readtable)])
      (apply p args))))

(define (lispi-info default-proc)
  default-proc)

(define-values (lispi-read lispi-read-syntax lispi-get-info)
  (make-meta-reader
    'lispi
    "language path"
     (lambda (bstr)
       (let* ([str (bytes->string/latin-1 bstr)]
              [sym (string->symbol str)])
         (and (module-path? sym)
              (vector
               ;; try submod first:
               `(submod ,sym reader)
               ;; fall back to /lang/reader:
               (string->symbol (string-append str "/lang/reader"))))))
    wrap-reader
    wrap-reader
    lispi-info))
