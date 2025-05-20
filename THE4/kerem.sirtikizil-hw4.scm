(define check-all
  (lambda (bools)
    (if (null? bools)
        #t
        (if (car bools)
            (check-all (cdr bools))
            #f)
    )
  )
) ; helper function that recursively checks if all elements are #t

;first procedure
(define sequence?
  (lambda (inSeq)
    (if (list? inSeq) ; must be a list
        (check-all
         (map (lambda (item)
                (and (symbol? item) ; must be a symbol 
                     (= (string-length (symbol->string item)) 1)
                )
              ) ; all length must be 1 -> creates a list of bool values
              inSeq
              )
        )
        #f
    )
  )
)

;second procedure
(define same-sequence? 
  (lambda (inSeq1 inSeq2)
    (if (and (sequence? inSeq1) (sequence? inSeq2))
        (equal? inSeq1 inSeq2)
        (display "ERROR305: One or both inputs are not valid sequences")
    )
  )
)



;helper for third procedure
(define reverser 
  (lambda (1st)
    (if (null? 1st) ;-> recursion terminate condition 
      '(); then expr -> recursion terminator / null value
      (append (reverser (cdr 1st)) (list (car 1st))); else expr, reverse the rest of the list and append the first element to the end
    )
  )
)
;third procedure;
(define reverse-sequence
  (lambda (inSeq)
    (if (sequence? inSeq)
    (reverser inSeq); then expr
    (display "ERROR305: Input is not a valid sequence"); else expr;
    )
  )
)

;fourth procedure
(define palindrome?
  (lambda (inSeq)
    (if (sequence? inSeq)
    (same-sequence? inSeq (reverse-sequence inSeq))
    (display "ERROR305: Input is not a valid sequence");else expr
    )
  )
)

;fifth procedure
;helper
(define contains? 
  (lambda (Sym Seq)
    (if (null? Seq)
      #f
      (if (eq? Sym (car Seq))
        #t
        (contains? Sym  (cdr Seq))
      )
    )
  )
)

(define member? 
  (lambda (inSym inSeq)
    (cond 
      ((not(symbol? inSym)) (display "ERROR305: First input is not a symbol"))
      ((not (= (string-length (symbol->string inSym)) 1)) (display "ERROR305: Symbol must be of length 1"))
      ((not (sequence? inSeq)) (display "ERROR305: Second input is not a valid sequence"))
      (else (contains? inSym inSeq))
    )
  )
)

;sixth procedure

;helper
; b (a b c d) we know that inSym %100 exists in the inSeq, once we call remover from remove-member
(define remover 
  (lambda (inSym inSeq)
    (if (null? inSeq)
      '()
      (if (eq? inSym (car inSeq))
        (cdr inSeq)
        (cons (car inSeq) (remover inSym (cdr inSeq)))
      )
    )
  )
)
; this one will work I hope

(define remove-member 
  (lambda (inSym inSeq)
    (cond
      ((not(symbol? inSym)) (display "ERROR305: First input is not a symbol"))
      ((not (= (string-length (symbol->string inSym)) 1)) (display "ERROR305: Symbol must be of length 1"))
      ((not (sequence? inSeq)) (display "ERROR305: Second input is not a valid sequence"))
      ((not (contains? inSym inSeq)) (display "ERROR305: Symbol not found in sequence"))
      (else (remover inSym inSeq))
    )
  )
)


;7th procedure
(define anagram?
  (lambda (inSeq1 inSeq2)
    (if (and (sequence? inSeq1) (sequence? inSeq2))
      (anagram-checker inSeq1 inSeq2); both valid
      (display "ERROR305: One or both inputs are not valid sequences"); error
    )
  )
)
;helper of 7th 
(define anagram-checker
  (lambda (inSeq1 inSeq2)
    (cond
      ((and (null? inSeq1) (null? inSeq2)) #t) ; both empty true
      ((or (null? inSeq1) (null? inSeq2)) #f) ; one empty, other not, false
      ((contains? (car inSeq1) inSeq2)
        (anagram-checker (cdr inSeq1) (remover (car inSeq1) inSeq2)))
      (else #f)
    )
  )
)

;8th procedure
(define unique-symbols
  (lambda (inSeq)
    (if (sequence? inSeq)
      (unique-finder inSeq '()); here the helper
      (display "ERROR305: Input is not a valid sequence"); error
    )
  )
)
;helper 
(define unique-finder
  (lambda (inSeq1 inSeq2) ; in Seq 2 is '() initially
    (if (null? inSeq1) ; terminator
      inSeq2
      (if (contains? (car inSeq1) inSeq2)
        (unique-finder (cdr inSeq1) inSeq2)
        (unique-finder (cdr inSeq1) (append inSeq2 (list (car inSeq1))))
      )
    )
  )
)

;9th procedure

(define count-occurrences
  (lambda (inSym inSeq)
    (if (symbol? inSym)
      (if (sequence? inSeq)
        (counter-helper inSym inSeq 0); go w/ helper
        (display "ERROR305: Second input is not a valid sequence")
      )
      (display "ERROR305: First input is not a symbol")
    )
  )
)

(define counter-helper
  (lambda (inSym inSeq count); count initially 0 passed
    (if (not (null? inSeq))
      (if (eq? inSym (car inSeq))
        (counter-helper inSym (cdr inSeq) (+ count 1)); go to deep by count++
        (counter-helper inSym (cdr inSeq) count); go to deep by count same
      )
      count
    )
  )
)

;last procedure - <><><><><><><><><><><><>
; if there is a symbol occurs odd number of times, there should not be any other symbol that occurs odd number of times, other than that
; on the other hand all symbols can occur even number of times. -> so that we can make sure
; the sequence is an anagram of polindrome

; i will keep a list of numbers that keeps the counts of unique elements in the list, then I will check that 
; list and I will return true if there is no odd occurence or only one odd occurence
; if input is not a sequence we will produce an error

(define odd?
  (lambda (n)
    (odd-helper n)
  )
)

(define odd-helper
  (lambda (n)
    (cond
      ((= n 0) #f)  ; Even
      ((= n 1) #t)  ; Odd
      (else (odd-helper (- n 2))) ; substracting until hitting 0, not efficient best I could write
    )
  )
)

(define unique-counts-helper
  (lambda (uniqueSyms acc original)
    (if (null? uniqueSyms) ; base case: done checking all unique symbols
      acc
       ; continue with the rest
      (unique-counts-helper (cdr uniqueSyms) (append acc (list (count-occurrences (car uniqueSyms) original))) original)
    )
  )
)

(define at-most-one-odd? 
  (lambda (LIST)
    (check-odd LIST 0)
  )
)

(define check-odd ; output comes from this function
  (lambda (lst odd-count)
    (cond
      ((> odd-count 1) #f) ; base case and final decision, if more than 1 odd we fail to create a polindrome
      ((null? lst) #t)
      ((odd? (car lst)) (check-odd (cdr lst) (+ odd-count 1))); recursing by increasing odd count here
      (else (check-odd (cdr lst) odd-count))))) ; or not increasing, 

(define anapoli? 
  (lambda (inSeq)
    (if (sequence? inSeq)
        (at-most-one-odd?
         (unique-counts-helper (unique-symbols inSeq) '() inSeq))
        (display "ERROR305: Input is not a valid sequence"))))

  