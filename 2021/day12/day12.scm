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

(define step
  (lambda (path node routes)
    (if (equal? node "end")
      1
      (let ((possible-next-nodes
              (filter
                (lambda (n) (or (not (char-lower-case? (string-ref n 0))) (not (any (lambda (p) (equal? p n)) path))))
                (hash-table-ref routes node))))
        (cond
          ((null? possible-next-nodes) `())
          (else
            (map (lambda (n) (step (cons n path) n routes)) possible-next-nodes)))))))
    
(define step2
  (lambda (path node routes)
    (if (equal? node "end")
      1
      (let ((possible-next-nodes
              (filter
                (lambda (n)
                  (or
                    (not (char-lower-case? (string-ref n 0)))
                    (not (any (lambda (p) (equal? p n)) path))
                    (and
                      (not (equal? n "start"))
                      (= (count (lambda (p) (equal? p n)) path) 1)
                      (not (any
                            (lambda (p) (= (count (lambda (nn) (equal? p nn)) path) 2))
                            (filter
                              (lambda (nn) (and
                                            (char-lower-case? (string-ref nn 0))
                                            (not (equal? nn "start"))
                                            (not (equal? n nn))))
                              path))))))
            (hash-table-ref routes node))))
        (cond
          ((null? possible-next-nodes) `())
          (else
            (map (lambda (n) (step2 (cons n path) n routes)) possible-next-nodes)))))))

(define (main args)
  (define routes (make-hash-table #:initial `()))

  (define input-lines (map (lambda (l) (string-split l "-")) (string-split test-input "\n")))
  (for-each (lambda (l)
    (hash-table-update! routes (first l) (lambda (a) (cons (second l) a)))
    (hash-table-update! routes (second l) (lambda (a) (cons (first l) a))))
    input-lines)

  (display (length (flatten (step `("start") "start" routes))))
  (newline)
  (display (length (flatten (step2 `("start") "start" routes))))
  (newline)
  0)