(load "input.scm")

(define scan
  (lambda (mes sum window)
    (cond
      ((or (null? mes) (<= (length mes) window)) sum)
      (else
        (scan
          (cdr mes)
          (if (< (car mes) (list-ref mes window)) (+ sum 1) sum)
          window)))))

(define (main args)
  (display (scan input 0 1))
  (newline)
  (display (scan input 0 3))
  (newline)
  0)