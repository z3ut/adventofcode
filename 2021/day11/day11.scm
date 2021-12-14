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

(define neighbours (list `(-1 -1) `(0 -1) `(1 -1) `(-1 0) `(1 0) `(-1 1) `(0 1) `(1 1)))

(define flash
  (lambda (levels)
    (define count 0)
    (define flashed? #t)
    (while flashed?
      (set! flashed? #f)
      (for-each
        (lambda (k)
          (when (> (hash-table-ref levels k) 9)
            (for-each
              (lambda (n)
                (let ((ni (list (+ (first k) (first n)) (+ (second k) (second n)))))
                  (when (and
                          (hash-table-exists? levels ni)
                          (> (hash-table-ref levels ni) 0))
                    (hash-table-update! levels ni add1))))
              neighbours)
            (hash-table-set! levels k 0)
            (set! count (+ count 1))
            (set! flashed? #t)))
          (hash-table-keys levels)))
    count))


(define step
  (lambda (levels current-step flashes)
    (cond
      ((= current-step 0) flashes)
      (else
        (for-each (lambda (k) (hash-table-update! levels k add1))
          (hash-table-keys levels))
        (step levels (- current-step 1) (+ flashes (flash levels)))))))

(define step-all-flash
  (lambda (levels current-step)
    (for-each (lambda (k) (hash-table-update! levels k add1))
      (hash-table-keys levels))
    (if (= (flash levels) 100)
      current-step
      (step-all-flash levels (add1 current-step)))))

(define (main args)
  (define input-lines (string-split input "\n"))

  (define levels (make-hash-table))

  (let loop-i ((i 0) (limit-i (length input-lines)))
    (when (< i limit-i)
      (let loop-j ((j 0) (limit-j (string-length (car input-lines))))
        (when (< j limit-j)
          (hash-table-set! levels (list i j) (string->number (->string (string-ref (list-ref input-lines i) j))))
          (loop-j (add1 j) limit-j)))
      (loop-i (add1 i) limit-i)))

  (define levels2 (hash-table-copy levels))

  (display (step levels 100 0))
  (newline)

  (display (step-all-flash levels2 1))
  (newline)
  0)