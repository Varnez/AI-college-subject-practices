(defpackage :grupo63pareja1031F3004 	; se declara un paquete lisp que usa common-lisp
  (:use :common-lisp :mancala) 		; y mancala, y exporta la funci�n de evaluaci�n
  (:export :heuristica :*alias*)) 	; heur�stica y un alias para el torneo

(in-package grupo63pareja1031F3004)

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
             -1000000
           1000000)
       ;Si no se termina, valoramos si repetimos turno
         ;Si no se pasa turno, valoramos la diferencia de fichas en Kathalas...
         (+ (* (- kalaha-propio kalaha-contrario) 1000)
         ;Y la cantidad de fichas en cada hoyos (cuantos menos semillas, mejor)
         (-
          0
          (* hoyo-0 hoyo-0 )
          (* hoyo-1 hoyo-1 )
          (* hoyo-2 hoyo-2 5)
          (* hoyo-3 hoyo-3 10)
          (* hoyo-4 hoyo-4 20)
          (* hoyo-5 hoyo-5 30)))))))

(defvar *alias* '|Maniae-v2|)
