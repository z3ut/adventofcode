(load "input.scm")

(import (chicken string))
(require-extension srfi-1) 

(define get-distr
  (lambda (val freq)
    (cond
      ((null? val) freq)
      (else
        (let ((v (car val)))
          (let loop ((i 0))
            (when (< i (string-length v))
              (set! (list-ref freq i) (+ (list-ref freq i) (if (eq? (string-ref v i) #\1) 1 -1)))
              (loop (add1 i))))
          (get-distr (cdr val) freq))))))

(define step
  (lambda (values i more less eq)
    (let ((dist (get-distr values `(0 0 0 0 0 0 0 0 0 0 0 0))))
      (cond
        ((<= (length values) 1) (car values))
        (else
          (step
            (filter (lambda (v)
              (cond
                ((> (list-ref dist i) 0) (eq? (string-ref v i) more))
                ((< (list-ref dist i) 0) (eq? (string-ref v i) less))
                ((= (list-ref dist i) 0) (eq? (string-ref v i) eq))))
              values)
            (add1 i) more less eq))))))

(define (main args)
  (define values (string-split input "\n"))

  ; create binary values from distribution and multiply them
  (define distribution (get-distr values `(0 0 0 0 0 0 0 0 0 0 0 0)))
  (display distribution)
  (newline)

  (display (step values 0 #\1 #\0 #\1))
  (newline)
  (display (step values 0 #\0 #\1 #\0))
  (newline)
  0)
