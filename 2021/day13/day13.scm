(load "input.scm")

(import (chicken string))
(import (chicken sort))
(import list-utils)
(import stack)
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define fold-y
  (lambda (points y)
    (delete-duplicates
      (map
        (lambda (p) (list (first p) (if (< (second p) y) (second p) (- (* 2 y) (second p)))))
        (filter (lambda (p) (not (= y (second p)))) points)))))

(define fold-x
  (lambda (points x)
    (delete-duplicates
      (map
        (lambda (p) (list (if (< (first p) x) (first p) (- (* 2 x) (first p))) (second p)))
        (filter (lambda (p) (not (= x (first p)))) points)))))

(define display-paper
  (lambda (points)
    (define line "")
    (let loop-y ((y 0) (limit-y 6))
        (when (< y limit-y)
          (let loop-x ((x 0) (limit-x 40))
            (when (< x limit-x)
              (set! line (string-append line (if (any (lambda (p) (and (= (first p) x) (= (second p) y))) points) "#" " ")))
              (loop-x (add1 x) limit-x)))
          (display line)
          (newline)
          (set! line "")
          (loop-y (add1 y) limit-y)))))

(define (main args)
  (define points (map (lambda (l) (map string->number (string-split l ","))) (string-split input "\n")))

  (set! points (fold-x points 655))

  (display (length points))
  (newline)

  (set! points (fold-y points 447))
  (set! points (fold-x points 327))
  (set! points (fold-y points 223))
  (set! points (fold-x points 163))
  (set! points (fold-y points 111))
  (set! points (fold-x points 81))
  (set! points (fold-y points 55))
  (set! points (fold-x points 40))
  (set! points (fold-y points 27))
  (set! points (fold-y points 13))
  (set! points (fold-y points 6))

  (display-paper points)
  0)
