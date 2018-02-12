;;;;;;;;;;;;;;;;;
;; Ejercicio 2 ;;
;;;;;;;;;;;;;;;;;

;; 2.1
(defun bisect (f a b tol)
	;Genera f(x) en en �mbito de la ejecuci�n actual de la funci�n de bisectriz
	(let ((fx (/ (+ a b) 2)))
	(if (> (* (funcall f a) (funcall f b)) 0)
		;Si f(a) y f(b) son ambas positivas o neativas, devuelve NILL
		nil
		(if (< (- (funcall f b) (funcall f a)) tol)
			;Si f(b) - f(a) < tol, la funci�n devuelve f(x) como resultado
			fx
			(if (> fx 0)
				;Si no, reposicionamos uno de los puntos como f(x) y continuamos.
				(bisect f a fx tol)
				(bisect f fx b tol))))))

;;2.2
(defun allroot (f lst tol)
	(if (null (rest lst))
		;Si no quedan, al menos, dos n�meros en la lista, la recursividad termina
		nil
		;Calcula la bisectriz de los dos primeros elementos de la lista y pasa a 
		;llamada recursiva la lista quitando el primer elemento 
		(cons (bisect f (first lst) (rest lst) tol) (allroot f (rest lst) tol))))



;;;;;;;;;;;;;;;;;
;; Ejercicio 3 ;;
;;;;;;;;;;;;;;;;;

;; 3.1
(defun combine-elt-list (elt lst)
	(if (null lst)
		nil
		(cons (list elt (first lst)) (combine-elt-list elt (rest lst)))))

;; 3.2
(defun combine-lst-lst (lst1 lst2)
	(unless (or (null lst1) (null lst2))
		nil
	(append (combine-elt-list (first lst1) lst2) (combine-lst-lst (rest lst1) lst2))))

;; 3.3
(defun combine-list-of-lsts (lstolsts)
	(if (null (rest lstolsts))
		(first lstolsts)
		(combine-lst-lst (first lstolsts) (combine-list-of-lsts (rest lstolsts)))))