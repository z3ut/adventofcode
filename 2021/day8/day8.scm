(load "input.scm")

(import (chicken string))
(import (chicken sort))
(require-extension srfi-1)
(require-extension srfi-13)
(require-extension srfi-14)
(require-extension srfi-69)

(define parse-key
  (lambda (k)
    (sort (map char->integer (string->list k)) <)))

(define parse
  (lambda (values)
    (define table (make-hash-table))
    (hash-table-set! table 1 (find (lambda (v) (= (string-length v) 2)) values))
    (hash-table-set! table 4 (find (lambda (v) (= (string-length v) 4)) values))
    (hash-table-set! table 7 (find (lambda (v) (= (string-length v) 3)) values))
    (hash-table-set! table 8 (find (lambda (v) (= (string-length v) 7)) values))
    (hash-table-set! table 3 (find (lambda (v) (and (= (string-length v) 5) (string-every (string->char-set v) (hash-table-ref table 1)))) values))
    (hash-table-set! table 9 (find (lambda (v) (and (= (string-length v) 6) (string-every (string->char-set v) (hash-table-ref table 3)))) values))
    (hash-table-set! table 6 (find (lambda (v) (and (= (string-length v) 6) (not (string-every (string->char-set v) (hash-table-ref table 1))))) values))
    (hash-table-set! table 0 (find (lambda (v) (and (= (string-length v) 6) (not (eq? v (hash-table-ref table 6))) (not (eq? v (hash-table-ref table 9))))) values))
    (hash-table-set! table 5 (find (lambda (v) (and (= (string-length v) 5) (not (eq? v (hash-table-ref table 3))) (string-every (string->char-set (hash-table-ref table 9)) v))) values))
    (hash-table-set! table 2 (find (lambda (v) (and (= (string-length v) 5) (not (eq? v (hash-table-ref table 3))) (not (eq? v (hash-table-ref table 5))))) values))
    (let loop ((i 0) (limit 9))
      (when (<= i limit)
        (hash-table-set! table (parse-key (hash-table-ref table i)) i)
        (loop (add1 i) limit)))
    table))

(define (main args)
  (define values
    (map (lambda (line) (map string-split (string-split line "|"))) (string-split input "\n")))

  (display (count
    (lambda (x) (or (= x 2) (= x 3) (= x 4) (= x 7)))
    (flatten (map (lambda (arr) (map string-length (list-ref arr 1))) values))))
  (newline)

  (define numbers (map
    (lambda (line)
      (let ((table (parse (car line))))
        (map (lambda (v) (hash-table-ref table (parse-key v))) (list-ref line 1))))
    values))

  (display (fold + 0 (map (lambda (v) (string->number (apply conc v))) numbers)))
  (newline)
  0)