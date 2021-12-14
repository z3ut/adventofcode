(load "input.scm")

(import (chicken string))
(import (chicken sort))
(import list-utils)
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define get-key
  (lambda (i j)
    (conc i "-" j)))

(define low-point?
  (lambda (heightmap i j)
    (and
      (or ; top
        (= i 0)
        (> (hash-table-ref heightmap (get-key (- i 1) j))
        (hash-table-ref heightmap (get-key i j))))
      (or ; left
        (= j 0)
        (> (hash-table-ref heightmap (get-key i (- j 1)))
        (hash-table-ref heightmap (get-key i j))))
      (or ; right
        (not (hash-table-exists? heightmap (get-key i (+ j 1))))
        (> (hash-table-ref heightmap (get-key i (+ j 1)))
        (hash-table-ref heightmap (get-key i j))))
      (or ; bottom
        (not (hash-table-exists? heightmap (get-key (+ i 1) j)))
        (> (hash-table-ref heightmap (get-key (+ i 1) j))
        (hash-table-ref heightmap (get-key i j)))))))

(define mark-basin
  (lambda (heightmap basins i j num)
    (cond
      ((not (hash-table-exists? heightmap (get-key i j))) 0)
      ((= (hash-table-ref heightmap (get-key i j)) 9) 0)
      ((hash-table-exists? basins (get-key i j)) 0)
      (else
        (hash-table-set! basins (get-key i j) num)
        (mark-basin heightmap basins (- i 1) j num)
        (mark-basin heightmap basins (+ i 1) j num)
        (mark-basin heightmap basins i (- j 1) num)
        (mark-basin heightmap basins i (+ j 1) num)))))

(define loop-lines
  (lambda (lines fun)
    (let loop-i ((i 0) (limit-i (length lines)))
      (when (< i limit-i)
        (let loop-j ((j 0) (limit-j (string-length (car lines))))
          (when (< j limit-j)
            (fun i j)
            (loop-j (add1 j) limit-j)))
        (loop-i (add1 i) limit-i)))))

(define (main args)
  (define input-lines (string-split input "\n"))
  (define heightmap (make-hash-table))
  (define answer 0)

  (loop-lines input-lines
    (lambda (i j)
      (hash-table-set! heightmap (get-key i j) (string->number (->string (string-ref (list-ref input-lines i) j))))))

  (loop-lines input-lines
    (lambda (i j)
      (when (low-point? heightmap i j)
        (set! answer (+ answer (hash-table-ref heightmap (get-key i j)) 1)))))
 
  (display answer)
  (newline)


  (define basins (make-hash-table))
  (define basin-num 0)

  (loop-lines input-lines
    (lambda (i j)
      (unless (hash-table-exists? basins (get-key i j))
        (mark-basin heightmap basins i j basin-num)
        (set! basin-num (+ basin-num 1)))))

  (define basin-nums (list-unique (sort (hash-table-values basins) <)))
  (define basin-sizes
    (sort
      (map (lambda (num)
              (count (lambda (n) (= n num)) (hash-table-values basins)))
        basin-nums)
      >))

  (display (* (list-ref basin-sizes 0) (list-ref basin-sizes 1) (list-ref basin-sizes 2)))
  (newline)
  0)