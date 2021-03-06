(defpackage :grupo63pareja1031F1804 	; se declara un paquete lisp que usa common-lisp
  (:use :common-lisp :mancala) 		; y mancala, y exporta la funci�n de evaluaci�n
  (:export :heuristica :*alias*)) 	; heur�stica y un alias para el torneo

(in-package grupo63pareja1031F1804)

(defun heuristica (estado) ;Preparamos la informaci�n del tablero  
  (let ((puntuacion-propia (suma-fila (estado-tablero estado) (estado-lado-sgte-jugador estado)))
        (puntuacion-contrario (suma-fila (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado))))
        (kalaha-propio (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 6))
        (kalaha-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 6))
        (hoyo-0 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 0))
        (hoyo-1 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 1))
        (hoyo-2 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 2))
        (hoyo-3 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 3))
        (hoyo-4 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 4))
        (hoyo-5 (get-fichas (estado-tablero estado) (estado-lado-sgte-jugador estado) 5))
        (hoyo-0-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 0))
        (hoyo-1-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 1))
        (hoyo-2-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 2))
        (hoyo-3-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 3))
        (hoyo-4-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 4))
        (hoyo-5-contrario (get-fichas (estado-tablero estado) (lado-contrario (estado-lado-sgte-jugador estado)) 5)))
    
    (+
     ;Valoramos si se termina el juego
     (if (juego-terminado-p estado)
         (if (< puntuacion-propia puntuacion-contrario)
             -10000
           10000)
       ;Si no se termina, valoramos si repetimos turno
       (if (estado-debe-pasar-turno estado)
           9000 
         ;Si no se pasa turno, valoramos la diferencia de fichas en Kalahas
         (+ (* (- kalaha-propio kalaha-contrario) 500)
            ;Tambi�n miramos si el hoyo contrario tiene 0 fichas (en caso
            ;de tenerlas, ponderar� muy negativamente ya que existe posibilidad
            ;de captura por parte del contrario).
            (-
             0
             (if (= hoyo-0-contrario 0)
                 500
               (- (* hoyo-5 hoyo-5) (* (+ hoyo-0-contrario 1) 10)))
             (if (= hoyo-1-contrario 0)
                 500
               (- (* hoyo-4 hoyo-4) (* (+ hoyo-1-contrario 1) 10)))
             (if (= hoyo-2-contrario 0)
                 500
               (- (* hoyo-3 hoyo-3) (* (+ hoyo-2-contrario 1) 10)))
             (if (= hoyo-3-contrario 0)
                 500
               (- (* hoyo-2 hoyo-2) (* (+ hoyo-3-contrario 1) 10)))
             (if (= hoyo-4-contrario 0)
                 500
               (- (* hoyo-1 hoyo-1) (* (+ hoyo-4-contrario 1) 10)))
             (if (= hoyo-5-contrario 0)
                 500
               (- (* hoyo-0 hoyo-0) (* (+ hoyo-5-contrario 1) 10))))))))))

(defvar *alias* '|Send_Nodes_1.1|)