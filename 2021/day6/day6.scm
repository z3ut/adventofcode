(load "input.scm")

(import (chicken string))
(require-extension srfi-1)
(require-extension srfi-69)

(define step
  (lambda (state day)
    (cond
      ((= day 0) state)
      (else
        (let ((zero (hash-table-ref/default state 0 0)))
        (let loop ((i 0) (limit 8))
          (when (< i limit)
            (hash-table-set! state i (hash-table-ref/default state (add1 i) 0))
            (loop (add1 i) limit)))
        (hash-table-update! state 6 (lambda (v) (+ v zero)))
        (hash-table-set! state 8 zero))
        (step state (- day 1))))))

(define simulate
  (lambda (input days)
    (define state (make-hash-table #:initial 0))
    (define input-values (map string->number (string-split input ",")))
    (for-each (lambda (d) (hash-table-update! state d add1)) input-values)
    (step state days)
    (fold + 0 (hash-table-values state))))

(define (main args)
  (display (simulate input 80))
  (newline)
  (display (simulate input 256))
  (newline)
  0)