(load "input.scm")

(import (chicken string))
(import (chicken sort))
(import list-utils)
(import stack)
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define-syntax while
  (syntax-rules ()
                ((while cond body ...)
                 (let loop ()
                   (when cond
                     body ...
                     (loop))))))

(define dijkstra
  (lambda (risks)
    (define nodes (make-hash-table))
    (hash-table-for-each risks (lambda (k v) (hash-table-set! nodes k 999999999)))
    (hash-table-set! nodes `(0 0) 0)

    (define visited (make-hash-table))

    (define current-neighbors (make-hash-table))
    (hash-table-set! current-neighbors `(0 0) 0)

    (while (not (null? (hash-table-keys current-neighbors)))
      (display (length (hash-table-keys nodes)))
      (newline)
      
      (set! minimum
        (hash-table-fold current-neighbors
          (lambda (k v f) (if (< v (second f)) (list k v) f))
          (list #f 999999999)))
      (set! node (first minimum))
      (set! price (second minimum))

      (for-each
        (lambda (nn)
          (define n (map + node nn))
          (when (hash-table-exists? nodes n)
            (hash-table-update! nodes n (lambda (v) (min (+ price (hash-table-ref risks n)) v)))
            (when (not (hash-table-exists? visited n))
              (hash-table-set! current-neighbors n (hash-table-ref nodes n)))))
        (list (list 0 -1) (list 1 0) (list 0 1) (list -1 0) ))

      (hash-table-set! visited node (hash-table-ref nodes node))
      (hash-table-delete! nodes node)
      (hash-table-delete! current-neighbors node))
        
    visited))

(define (main args)
  (define lines (string-split input "\n"))
  (define size-x (string-length (car lines)))
  (define size-y (length lines))
  (define risks (make-hash-table))
  
  (let loop-y ((y 0) (limit-y size-y))
    (when (< y limit-y)
      (let loop-x ((x 0) (limit-x size-x))
        (when (< x limit-x)
          (hash-table-set! risks (list x y)
            (string->number (->string (string-ref (list-ref lines y) x))))
          (loop-x(add1 x) limit-x)))
      (loop-y(add1 y) limit-y)))

  (define a (dijkstra risks))

  (display (hash-table-ref a `(99 99)))
  (newline)
  0)
