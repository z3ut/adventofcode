(load "input.scm")

(import (chicken string))
(require-extension srfi-1) 

(define create-deck-nums
  (lambda (deck)
    (map
      (lambda (l) (map string->number (string-split l " ")))
      (string-split deck "\n"))))

(define win-horizontal?
  (lambda (deck order)
    (cond
      ((null? deck) #f)
      ((every (lambda (el) (member el order)) (car deck)) #t)
      (else (win-horizontal? (cdr deck) order)))))

(define win-vertical?
  (lambda (deck order)
    (cond
      ((or (null? deck) (null? (car deck))) #f)
      ((every (lambda (row) (member (car row) order)) deck) #t)
      (else (win-vertical? (map cdr deck) order)))))

(define win?
  (lambda (deck order)
    (or (win-horizontal? deck order) (win-vertical? deck order))))

(define step-win
  (lambda (decks cur left)
    (let ((res (find (lambda (d) (win? d cur)) decks)))
      (cond
        ((eq? res #f) (step-win decks (append cur (list (car left))) (cdr left)))
        (else (* (fold + 0 (filter (lambda (el) (not (member el cur))) (flatten res))) (car (reverse cur))))))))

(define step-lose
  (lambda (decks cur left)
    (let ((res (find (lambda (d) (win? d cur)) decks)))
      (cond
        ((eq? res #f) (step-lose decks (append cur (list (car left))) (cdr left)))
        ((and (not (eq? res #f)) (> (length decks) 1)) (step-lose (delete res decks) cur left))
        (else (* (fold + 0 (filter (lambda (el) (not (member el cur))) (flatten res))) (car (reverse cur))))))))

(define (main args)
  (define order
    (map string->number (string-split input-order ",")))

  (define decks
    (map create-deck-nums (string-split input-boards "*")))

  (display (step-win decks `() order))
  (newline)

  (display (step-lose decks `() order))
  (newline)
  0)