(load "input.scm")

(import (chicken string))
(require-extension srfi-1)
(require-extension srfi-69)

(define straight-line?
  (lambda (x1 y1 x2 y2)
    (or (= x1 x2) (= y1 y2))))

(define apply-input
  (lambda (lines table)
    (cond
      ((null? lines) table)
      (else
        (apply add-line (append (car lines) (list table)))
        (apply-input (cdr lines) table)))))

(define add-line
  (lambda (x1 y1 x2 y2 table)
    (hash-table-update! table (list x1 y1) add1 (lambda () 0))
    (cond
      ((and (= x1 x2) (= y1 y2)) #t)
      (else (add-line
        (if (= x1 x2) x1 ((if (> x1 x2) - +) x1 1))
        (if (= y1 y2) y1 ((if (> y1 y2) - +) y1 1))
        x2
        y2
        table)))))

(define (main args)
  (define table-straight (make-hash-table))
  (define table-all (make-hash-table))

  (define lines
    (map
      (lambda (line)
        (map string->number (string-split line " ->,")))
      (string-split input "\n")))

  (define straight-lines (filter (lambda (l) (apply straight-line? l)) lines))

  (apply-input straight-lines table-straight)
  (display (count (lambda (el) (> el 1)) (hash-table-values table-straight)))
  (newline)

  (apply-input lines table-all)
  (display (count (lambda (el) (> el 1)) (hash-table-values table-all)))
  (newline)
  0)