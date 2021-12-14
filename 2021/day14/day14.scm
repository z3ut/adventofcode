(load "input.scm")

(import (chicken string))
(import (chicken sort))
(import list-utils)
(import stack)
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define fill
  (lambda (polymer pairs)
    (when (> (length polymer) 1)
      (hash-table-update! pairs (key (first polymer) (second polymer)) add1)
      (fill (cdr polymer) pairs))))

(define step
  (lambda (pairs rules)
    (define new-pairs (hash-table-copy pairs))
    (hash-table-for-each pairs
      (lambda (pair count)
        (when (hash-table-exists? rules pair)
          (hash-table-update! new-pairs pair (lambda (v) (- v count)))
          (hash-table-update! new-pairs (first (hash-table-ref rules pair)) (lambda (v) (+ v count)))
          (hash-table-update! new-pairs (second (hash-table-ref rules pair)) (lambda (v) (+ v count))))))
    new-pairs))

(define key
  (lambda (p1 p2)
    (string-append (->string p1) (->string p2))))

(define simulate
  (lambda (polymer rules count)
    (define pairs (make-hash-table #:initial 0))
    (fill polymer pairs)

    (let loop-i ((i 0) (limit-i count))
      (when (< i limit-i)
        (set! pairs (step pairs rules))
        (loop-i(add1 i) limit-i)))

    (define letters (make-hash-table #:initial 0))

    (hash-table-for-each pairs
      (lambda (key val)
        (hash-table-update! letters (string-ref key 0) (lambda (v) (+ (/ val 2) v)))
        (hash-table-update! letters (string-ref key 1) (lambda (v) (+ (/ val 2) v)))))

    (hash-table-update! letters (first (string->list template)) (lambda (v) (+ v (/ 1 2))))
    (hash-table-update! letters (last (string->list template)) (lambda (v) (+ v (/ 1 2))))
    
    (define counts (sort (hash-table-values letters) <))
    (- (last counts) (first counts))))

(define (main args)
  (define polymer (map ->string (string->list template)))

  (define rules (make-hash-table))
  (for-each (lambda (v)
              (hash-table-set! rules (first v)
                (list (key (string-ref (first v) 0) (second v))
                  (key (second v) (string-ref (first v) 1)))))
    (map (lambda (l) (string-split l " ->")) (string-split rules-input "\n")))

  (display (simulate polymer rules 10))
  (newline)
  (display (simulate polymer rules 40))
  (newline)
  0)
