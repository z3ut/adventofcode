(load "input.scm")

(import (chicken string))
(import (chicken sort))
(import list-utils)
(import stack)
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define opening-brackets `(#\( #\[ #\{ #\<))

(define closing-brackets (make-hash-table))
(hash-table-set! closing-brackets #\( #\))
(hash-table-set! closing-brackets #\[ #\])
(hash-table-set! closing-brackets #\{ #\})
(hash-table-set! closing-brackets #\< #\>)

(define corrupt-points (make-hash-table))
(hash-table-set! corrupt-points #\) 3)
(hash-table-set! corrupt-points #\] 57)
(hash-table-set! corrupt-points #\} 1197)
(hash-table-set! corrupt-points #\> 25137)

(define incomplete-points (make-hash-table))
(hash-table-set! incomplete-points #\( 1)
(hash-table-set! incomplete-points #\[ 2)
(hash-table-set! incomplete-points #\{ 3)
(hash-table-set! incomplete-points #\< 4)

(define step
  (lambda (line stack)
    (cond
      ((null? line) stack)
      ((member (car line) opening-brackets)
        (stack-push! stack (car line))
        (step (cdr line) stack))
      ((eq? (hash-table-ref closing-brackets (stack-pop! stack)) (car line))
        (step (cdr line) stack))
      (else (hash-table-ref corrupt-points(car line))))))

(define (main args)
  (define input-lines (string-split input "\n"))

  (define res (map (lambda (line) (step (string->list line) (make-stack))) input-lines))

  (display (fold + 0 (filter number? res)))
  (newline)

  (define incomplete-stacks (filter (lambda (l) (not (number? l))) res))

  (define completion-prices
    (map
      (lambda (s)
        (stack-fold s (lambda (el acc)
                        (+ (* acc 5) (hash-table-ref incomplete-points el)))
          0))
      incomplete-stacks))

  (display (list-ref (sort completion-prices <) (/ (- (length completion-prices) 1) 2)))
  (newline)
  0)