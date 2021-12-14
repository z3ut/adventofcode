(load "input.scm")

(import (chicken string))
(import (chicken sort))
(require-extension srfi-1)
(require-extension srfi-69)

(define list-sum
  (lambda (lat)
    (cond
      ((null? (cdr lat)) (car lat))
      (else
        (+ (car lat) (list-sum (cdr lat)))))))

(define calculate-fuel
  (lambda (positions point)
    (list-sum (map (lambda (x) (abs (- point x))) positions))))

(define calculate-fuel2
  (lambda (positions point costs2)
    (list-sum (map (lambda (x) (hash-table-ref costs2 (abs (- point x)))) positions))))

(define (main args)
  (define positions (map string->number (string-split input ",")))
  (define min-position (car (sort positions <)))
  (define max-position (car (sort positions >)))
  (define answer1 -1)
  
  (let loop ((i min-position) (limit max-position))
    (when (<= i limit)
      (let ((fuel (calculate-fuel positions i)))
        (when (or (= answer1 -1) (< fuel answer1))
          (set! answer1 fuel)))
      (loop (add1 i) limit)))  

  (display answer1)
  (newline)


  (define answer2 -1)
  (define costs2 (make-hash-table))
  (hash-table-set! costs2 0 0)

  (let loop ((i 1) (limit (- max-position min-position)))
      (when (<= i limit)
        (hash-table-set! costs2 i (+ (hash-table-ref costs2 (- i 1)) i))
        (loop (add1 i) limit)))  

  (let loop ((i min-position) (limit max-position))
    (when (<= i limit)
      (let ((fuel (calculate-fuel2 positions i costs2)))
        (when (or (= answer2 -1) (< fuel answer2))
          (set! answer2 fuel)))
      (loop (add1 i) limit)))  

  (display answer2)
  (newline)
  0)