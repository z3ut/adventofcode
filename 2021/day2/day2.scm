(load "input.scm")

(define step1
  (lambda (lat depth x)
    (cond
      ((null? lat) (* depth x))
      (else
        (let ((cmd (car lat)))
          (let ((val (car (cdr lat))))
            (step1
              (cdr (cdr lat))
              (cond
                ((eq? cmd `down) (+ depth val))
                ((eq? cmd `up) (- depth val))
                (else depth))
              (if (eq? cmd `forward) (+ x val) x))))))))

(define step2
  (lambda (lat aim depth x)
    (cond
      ((null? lat) (* depth x))
      (else
        (let ((cmd (car lat)))
          (let ((val (car (cdr lat))))
            (step2
              (cdr (cdr lat))
              (cond
                ((eq? cmd `down) (+ aim val))
                ((eq? cmd `up) (- aim val))
                (else aim))
              (if (eq? cmd `forward) (+ depth (* aim val)) depth)
              (if (eq? cmd `forward) (+ x val) x))))))))

(define (main args)
  (display (step1 input 0 0))
  (newline)
  (display (step2 input 0 0 0))
  (newline)
  0)