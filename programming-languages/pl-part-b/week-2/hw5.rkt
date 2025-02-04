;; Programming Languages, Homework 5

#lang racket
(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0

;; a closure is not in "source" programs but /is/ a MUPL value; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

;; Problem 1
;; CHANGE (put your solutions here)


;; Racketlist -> Mupllist
;; produce an analogous MUPL list from the given racket list
(define (racketlist->mupllist xs)
  (cond [(null? xs) (aunit)]
        [else (apair (car xs) (racketlist->mupllist (cdr xs)))]))


;; Mupllist-> Racketlist
;; produce an analogous racket list from the given MUPL list
(define (mupllist->racketlist xs)
  (cond [(aunit? xs) null]
        [else (cons (apair-e1 xs) (mupllist->racketlist (apair-e2 xs)))]))



;; Problem 2

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        [(int? e) e]
        [(closure? e) e]
        [(aunit? e) e]
        [(fun? e)
          (let ([fn-name (fun-nameopt e)] [fn-arg-name (fun-formal e)])
            (cond [(and (or (string? fn-name) (false? fn-name)) (string? fn-arg-name)) 
                    (closure env e)]
                  [(string? fn-arg-name) (error "first argument must be a string or #f")]
                  [else (error "second argument must be a string")]))]
        [(ifgreater? e)
         (let* ([v1 (eval-under-env (ifgreater-e1 e) env)]
                [v2 (eval-under-env (ifgreater-e2 e) env)]
                [conform (and (int? v1) (int? v2))])
            (cond [conform (if (> (int-num v1) (int-num v2)) 
                               (eval-under-env (ifgreater-e3 e) env)
                               (eval-under-env (ifgreater-e4 e) env))]
                  [(int? v1) (error "second expression must be an int")]
                  [else (error "first expression must be an int")]))]
        [(mlet? e)
         (cond [(string? (mlet-var e)) 
                  (let ([var-val (eval-under-env (mlet-e e) env)])
                    (eval-under-env (mlet-body e) (cons (cons (mlet-var e) var-val) env)))]
               [else (error "variable name should be a string")])]
        [(call? e)
          (let ([clsr (eval-under-env (call-funexp e) env)]
                [actual (eval-under-env (call-actual e) env)])
          (cond [(closure? clsr) 
                 (let ([clsr-fn-name (fun-nameopt (closure-fun clsr))]
                       [clsr-arg-name (fun-formal (closure-fun clsr))])
                  (if clsr-fn-name
                      (eval-under-env (fun-body (closure-fun clsr)) 
                                      (cons (cons clsr-fn-name clsr) 
                                            (cons (cons clsr-arg-name actual) (closure-env clsr))))
                      (eval-under-env (fun-body (closure-fun clsr)) 
                                      (cons (cons clsr-arg-name actual) (closure-env clsr)))))]   
                [else (error "first expression must be a closure")]))]
        [(apair? e) (apair (eval-under-env (apair-e1 e) env) (eval-under-env (apair-e2 e) env))]
        [(fst? e) (let ([apr (eval-under-env (fst-e e) env)])
                    (if (apair? apr)
                        (apair-e1 apr)
                        (error "fst must be given apair")))]
        [(snd? e) (let ([apr (eval-under-env (snd-e e) env)])
                    (if (apair? apr)
                        (apair-e2 apr)
                        (error "snd must be given apair")))]
        [(isaunit? e) (if (aunit? (eval-under-env (isaunit-e e) env)) (int 1) (int 0))]
        ;; CHANGE add more cases here
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3

(define (ifaunit e1 e2 e3) (ifgreater (isaunit e1) (int 0) e2 e3))


(define (mlet* lst e2)
  (if (null? lst)
      e2
      (mlet (caar lst) (cdar lst) (mlet* (cdr lst) e2))))
  

(define (ifeq e1 e2 e3 e4) 
  (mlet* (list (cons "v1" e1) (cons "v2" e2))
    (ifgreater (var "v1") (var "v2") e4
                  (ifgreater (var "v2") (var "v1") e4 e3))))


;; Problem 4

(define mupl-map 
  (fun #f "fn"
    (fun "fn2" "mes"
      (ifaunit (var "mes")
               (aunit)
               (apair (call (var "fn") (fst (var "mes"))) (call (var "fn2") (snd (var "mes"))))))))


(define mupl-mapAddN 
  (mlet "map" mupl-map
        (fun #f "i" 
          (fun #f "mis"
            (call (call (var "map") (fun #f "int" (add (var "i") (var "int")))) (var "mis"))))))

;; Challenge Problem

(struct fun-challenge (nameopt formal body freevars) #:transparent) ;; a recursive(?) 1-argument function

;; We will test this function directly, so it must do
;; as described in the assignment
(define (compute-free-vars e) "CHANGE")

;; Do NOT share code with eval-under-env because that will make
;; auto-grading and peer assessment more difficult, so
;; copy most of your interpreter here and make minor changes
(define (eval-under-env-c e env) "CHANGE")

;; Do NOT change this
(define (eval-exp-c e)
  (eval-under-env-c (compute-free-vars e) null))
