(define get-operator
  (lambda (operator)
    (cond
      ((equal? operator '+) +)
      ((equal? operator '*) *)
      ((equal? operator '-) -)
      ((equal? operator '/) /)
      (else #f)
    )
  )
)

(define is-operator?
  (lambda (operator)
    (cond
      ((eq? operator '+) #t)
      ((eq? operator '*) #t)
      ((eq? operator '-) #t)
      ((eq? operator '/) #t)
      (else #f)
    )
  )
)

(define member?
  (lambda (inSym inSeq)
    (cond
      ((null? inSeq) #f)
      ((eq? (car inSeq) inSym) #t)
      (else (member? inSym (cdr inSeq)))
    )
  )
)

(define search
  (lambda (lst lst2)
    (cond
      ((null? lst) #t)
      ((member? (caar lst) lst2) #f)
      (else (search (cdr lst) (cons (caar lst) lst2)))
    )
  )
)

(define let?
  (lambda (e)
    (and (list? e) (>= (length e) 3) (eq? (car e) 'let) (list? (cadr e)) (let-list? (cadr e)) (search (cadr e) '()))
  )
)


(define let-list?
  (lambda (e)
    (cond
      ((null? e) #t)
      ((or (not (list? (car e))) (not (equal? (length (car e)) 2))) #f)
      ((not (symbol? (caar e))) #f)
      (else (let-list? (cdr e)))
    )
  )
)

(define extend-env
  (lambda (name value oldEnvironment)
    (cons (cons name value) oldEnvironment)
))

(define define-stmt?
  (lambda (expr)
    (and (list? expr)
         (= (length expr) 3)
         (equal? 'define (car expr))
         (symbol? (cadr expr))
         (or (number? (caddr expr))
             (list? (caddr expr)))))
)

(define get-functional-value ; if such funtion exists returns its definition with lambda otherwise returns "ERROR"
    (lambda (name environment)
        (cond
            ((null? environment) "ERROR")
            ((equal? (caar environment) name) (if (lambda-stmt? (cdr(car environment))) 
                (cdr(car environment))
                (get-functional-value name (cdr environment))
            ) 
            
            )
            (else (get-functional-value name (cdr environment)))
        )
    )
)


(define get-value
  (lambda (name environment1 environment2)
    (cond
      ((null? environment1)
        (let* 
       ((dummyx (display "cs305: ERROR\n\n")))
       (internal-cs305 environment2)
        )
       )
        ((equal? name (caar environment1))
            (if (lambda-stmt? (cdr (car environment1)))
                (let 
                    ((dummy (display "cs305: [PROCEDURE]\n\n")))
                    (internal-cs305 environment2)
                )
                (cdr (car environment1))
            )
            
        )
      (else (get-value name (cdr environment1) environment2)))
  )
)



(define lambda-stmt?
    (lambda (expr)
        (and (list? expr) (equal? (car expr) 'lambda) (list? (cadr expr)) (= (length expr) 3))
    )   
)

(define arithmetic?
  (lambda (expr)
    (and
      (list? expr)
      (>= (length expr) 2)
      (let ((op (car expr)))
        (and
          (or (equal? op '+)
              (equal? op '-)
              (equal? op '*)
              (equal? op '/))
          (all-valid-operands? (cdr expr)))))
  )
)


(define all-valid-operands?
  (lambda (lst)
    (cond
      ((null? lst) #t)
      ((or (number? (car lst))
           (symbol? (car lst))
           (arithmetic? (car lst)))
       (all-valid-operands? (cdr lst)))
      (else #f)))
)

(define interpreter
  (lambda (expr environment)
    (cond
        ((number? expr) expr)
        ((symbol? expr) (get-value expr environment environment))
        ((not (list? expr)) "ERROR")
        ((lambda-stmt? expr)
            expr
        )
        ;; anonymous procedure call
        ((lambda-stmt? (car expr))
            (let*
                (   
                    
                    (lambda-expr (car expr))
                    (params (cadr lambda-expr))
                    (body (caddr lambda-expr))
                    (args (cdr expr))
                    (evaluated-args (map (lambda (e) (interpreter e environment)) args))

                )
                (if (= (length params) (length evaluated-args))
                    (let ((temp-env (append (map cons params evaluated-args) environment)))
                        (interpreter body temp-env); must work 
                    )
                    "ERROR"
                )
            )
        )
        
        ((arithmetic? expr);; üstte olması lazım, * - / + symbol olduğundan öncesiyle eşleşiyordu
        (let* ((op (get-operator (car expr)))
                (args (cdr expr))
                (evaluated-args (map (lambda (param) (interpreter param environment)) args)))
            (apply op evaluated-args))
        )

        ((let? expr)
            (let*
                            
                ((valueList (map interpreter (map cadr (cadr expr)) (make-list (length (map cadr (cadr expr))) environment)))
                (newEnvironment (append (map cons (map car (cadr expr)) valueList) environment)))
                (interpreter (caddr expr) newEnvironment)
            )
        )

        ;;named procedure call => much more complex but close logic just need to extract the procedure from environment
        ((symbol? (car expr)) 
            (if (equal? (get-functional-value (car expr) environment) "ERROR")
                "ERROR"
                (let* 
                    (
                        
                        (lambda-expr (get-functional-value (car expr) environment))
                        
                        (params (cadr lambda-expr))
                        
                        (body (caddr lambda-expr))
                        
                        (args (cdr expr))
                        (evaluated-args (map (lambda (e) (interpreter e environment)) args))
                        
                        (param-length (length params))
                        (eval-length (length evaluated-args))
                    )
                    (if (= (length params) (length evaluated-args))
                        (let ((temp-env (append (map cons params evaluated-args) environment)))
                         (interpreter body temp-env)   
                        )
                        "ERROR"
                    )
                )
            )
        )

        
        

        (else "ERROR")))
)

;; TODO => now check anonymous function calls, and named function calls


(define internal-cs305
  (lambda (environment)
    (let* ((dummy1 (display "cs305> "))
           (usr-input (read))
           (newEnvironment 
                (if (define-stmt? usr-input)
                    (extend-env (cadr usr-input)
                                (interpreter (caddr usr-input) environment)
                                environment)
                    environment
                    )
            )
         
           (print-val
                (if (define-stmt? usr-input)
                    (cadr usr-input)
                    (interpreter usr-input environment)))
           (dummy2 (display "cs305: ")) ; CS are uppercase due to debugging reasons do no forget to make them lowercase
           (dummy3 (display print-val))
           (dummy4 (newline))
           (dummy5 (newline)))
      (internal-cs305 newEnvironment)))
)

(define cs305
    (lambda ()
        (internal-cs305 '())
    )
)


