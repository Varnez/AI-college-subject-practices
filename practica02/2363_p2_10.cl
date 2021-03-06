;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Lab assignment 2: Search
;;    LAB GROUP: 2363
;;    Couple: 10
;;    Author 1: Celia San Gregorio Moreno 
;;    Author 2: �lvaro Mart�nez Morales
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Problem definition
;;
(defstruct problem
  states               ; List of states
  initial-state        ; Initial state
  f-goal-test          ; Reference to a function that determines whether 
                       ; a state fulfills the goal 
  f-h                  ; Reference to a function that evaluates to the 
                       ; value of the heuristic of a state
  f-search-state-equal ; Reference to a predicate that determines whether
                       ; two nodes are equal, in terms of their search state
  operators)           ; list of operators (references to functions) to generate succesors
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Node in search tree
;;
(defstruct node 
  state           ; state label
  parent          ; parent node
  action          ; action that generated the current node from its parent
  (depth 0)       ; depth in the search tree
  (g 0)           ; cost of the path from the initial state to this node
  (h 0)           ; value of the heurstic
  (f 0))          ; g + h 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Actions 
;;
(defstruct action
  name              ; Name of the operator that generated the action
  origin            ; State on which the action is applied
  final             ; State that results from the application of the action
  cost )            ; Cost of the action
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    Search strategies 
;;
(defstruct strategy
  name              ; name of the search strategy
  node-compare-p)   ; boolean comparison
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    END: Define structures
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;    BEGIN: Define galaxy
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *planets* '(Avalon Davion Katril Kentares Mallory Proserpina Sirtis))

(defparameter *white-holes*  
  '((Avalon Mallory 6.4) (Avalon Proserpina 8.6) 
    (Davion Proserpina 5) (Davion Sirtis 6) 
    (Katril Mallory 10) (Katril Davion 9)
    (Kentares Avalon 3) (Kentares Katril 10) (Kentares Proserpina 7)
    (Mallory Katril 10) (Mallory Proserpina 15) 
    (Proserpina Avalon 8.6) (Proserpina Davion 5) (Proserpina Mallory 15) (Proserpina Sirtis 12)
    (Sirtis Proserpina 12) (Sirtis Davion 6)))

(defparameter *worm-holes*  
  '((Avalon Kentares 4) (Avalon Mallory 9)
    (Davion Katril 5) (Davion Sirtis 8)  
    (Katril Mallory 5) (Katril Davion 5) (Katril Sirtis 10)
    (Kentares Avalon 4) (Kentares Proserpina 12)
    (Mallory Avalon 9) (Mallory Katril 5) (Mallory Proserpina 11)
    (Proserpina Kentares 12) (Proserpina Mallory 11) (Proserpina Sirtis 9)
    (Sirtis Proserpina 9) (Sirtis Davion 8) (Sirtis Katril 10)))
 
(defparameter *sensors* 
  '((Avalon 15) (Mallory 12) (Kentares 14) (Davion 5) (Proserpina 7) (Katril 9) (Sirtis 0)))

(defparameter *planet-origin* 'Mallory)
(defparameter *planets-destination* '(Sirtis))
(defparameter *planets-forbidden*   '(Avalon))
(defparameter *planets-mandatory*   '(Katril Proserpina))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; BEGIN: Exercise 1 -- Evaluation of the heuristic
;;
;; Returns the value of the heuristics for a given state
;;
;;  Input:
;;    state: the current state (vis. the planet we are on)
;;    sensors: a sensor list, that is a list of pairs
;;                (state cost)
;;             where the first element is the name of a state and the second
;;             a number estimating the cost to reach the goal
;;
;;  Returns:
;;    The cost (a number) or NIL if the state is not in the sensor list
;;
(defun f-h-galaxy (state sensors)
  (second (assoc state sensors)))

;;;
;;; EJEMPLOS
;;;
(f-h-galaxy 'Sirtis *sensors*) ;-> 0
(f-h-galaxy 'Avalon *sensors*) ;-> 15
(f-h-galaxy 'Earth  *sensors*) ;-> NIL

;;
;; END: Exercise 1 -- Evaluation of the heuristic
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 2 -- Navigation operators
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Crea una lista de tripletes con state como planeta de origen
;; y cada uno de los planetas en el agujero blanco o de gusano
;; a los que se puede acceder desde state.
;;
;;  Input:
;;    state: el estado actual (el planeta donde estamos)
;;    hole-map: lista de tripletes correspondiente a los grafos
;;              de la galaxia (en este caso, agujeros blancos
;;              o de gusano).
;;
;;  Returns:
;;    Lista de tripletes de tipo (<state> <planeta-destino> <coste>).
(defun make-colindant-list (state hole-map)
  ;Si hemos llegado al final de la lista
  ;asociativa, la funci�n termina.
  (if (null hole-map)
      nil
    ;Si no, comprueba si el planeta de origen (state)
    ;coincide con el planeta de origen del primer triplete.
    (if (equal state (first (first hole-map)))
        ;Si coincide, crea una lista de tripletes.
        (cons (first hole-map) 
              (make-colindant-list state (rest hole-map)))
      ;Sino, avanza en la lista asociativa hole-map.
      (make-colindant-list state (rest hole-map)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Operador gen�rico que devuelve una lista de acciones que se
;; pueden hacer a partir del estado state, sobre un
;; grafo cualquiera, con posibildad de exclusi�n.
;;
;;  Input:
;;    state: estado de b�squeda que representa al planeta de origen.
;;    hole-map: lista de tripletes correspondiente al grafo cualquiera.
;;    forbidden: planetas que no permitir como destino. De no haberlos, debe ser nil
;;    action-name: nombre que asignar a la acci�n.
;;
;;  Returns:
;;    Lista de acciones de la acci�n definida del planeta de origen al de destino.
(defun navigate (state hole-map forbidden action-name)
  ;Genera una lista de acciones con los resultados de
  ;la funci�n 'make-colindant-list' no presentes en forbidden.
  (mapcan #'(lambda (dest)
              (if (member (second dest) forbidden)
                  nil
                (list (make-action
                       :name action-name
                       :origin state
                       :final (second dest)
                       :cost (third dest))))) 
              (make-colindant-list state hole-map)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Operador que devuelve una lista de acciones que se
;; pueden hacer a partir del estado state, sobre un
;; grafo con agujeros blancos.
;;
;;  Input:
;;    state: estado de b�squeda que representa al planeta de origen.
;;    white-holes: lista de tripletes correspondiente al grafo de
;;                 agujeros blancos de la galaxia.
;;
;;  Returns:
;;    Lista de acciones del planeta de origen al de destino, a
;;    trav�s de los agujeros blancos.
(defun navigate-white-hole (state white-holes)
  (navigate state white-holes nil 'navigate-white-hole))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Operador que devuelve una lista de acciones que se
;; pueden hacer a partir del estado state, sobre un
;; grafo con agujeros de gusano.
;;
;;  Input:
;;    state: estado de b�squeda que representa al planeta de origen.
;;    white-holes: lista de tripletes correspondiente al grafo de
;;                 agujeros de gusano de la galaxia.
;;
;;  Returns:
;;    Lista de acciones del planeta de origen al de destino, a
;;    trav�s de los agujeros de gusano.
(defun navigate-worm-hole (state worm-holes planets-forbidden)
  (navigate state worm-holes planets-forbidden 'navigate-worm-hole))


;;;
;;; EJEMPLOS
;;;
(navigate-worm-hole 'Mallory *worm-holes* *planets-forbidden*)  ;-> 
;;;(#S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL KATRIL :COST 5)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL PROSERPINA :COST 11))

(navigate-worm-hole 'Mallory *worm-holes* NIL)  ;-> 
;;;(#S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL AVALON :COST 9)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL KATRIL :COST 5)
;;; #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN MALLORY :FINAL PROSERPINA :COST 11))

(navigate-white-hole 'Kentares *white-holes*) ;->
;;;(#S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL AVALON :COST 3)
;;; #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL KATRIL :COST 10)
;;; #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN KENTARES :FINAL PROSERPINA :COST 7))

(navigate-worm-hole 'Uranus *worm-holes* *planets-forbidden*)  ;-> NIL

;;
;; END: Exercise 2 -- Navigation operators
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 3A -- Goal test
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Comprueba si el nodo pasado como argumento es un estado objetivo.
;;
;;  Input:
;;    nodo: nodo que representa un estado de b�squeda (el planeta actual).
;;    planets-destination: lista de nombres de los planetas destino.
;;    planets-mandatory: lista de nombres de los planetas obligatorios.
;;
;;  Returns:
;;    T si el nodo es un estado objetivo, NIL si no.
(defun f-goal-test-galaxy (node planets-destination planets-mandatory)
  ;Si el nodo est� entre la lista de planetas destino,
  ;comprueba que los nodos antecesores hayan pasado por
  ;los planetas obligatorios.
  (if (member (node-state node) planets-destination)
      ;(f-mandatory-test node planets-mandatory)
      (f-mandatory-test (node-parent node) planets-mandatory) ;Comprueba si los nodos padre corresponden
    nil))                                                     ;a planetas obligatorios visitados.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Devuelve una lista de planetas obligatorios a�n no visitados.
;;
;;  Input:
;;    node: nodo que representa un estado de b�squeda (el planeta actual).
;;    planets-mandatory: lista de nombres de los planetas obligatorios.
;;
;;  Returns:
;;    Lista con los nombres de los planetas obligatorios que a�n 
;;    queden por visitar, o NIL si se han visitado todos.
(defun get-mandatory-planets-not-visited (node planets-mandatory)
  ;Si llegamos al nodo ra�z, devolvemos
  ;la lista de planetas que quedan por visitar.
  (if (null node)
      planets-mandatory
    ;Si a�n no hemos llegado al nodo ra�z, comprueba si el nodo actual
    ;es un planeta obligatorio.
    (if (member (node-state node) planets-mandatory :test #'equal)
        ;Si es un planeta obligatorio, lo elimina de la lista y pasa a comprobar el nodo padre.
        (get-mandatory-planets-not-visited (node-parent node) (remove (node-state node) planets-mandatory))
      ;Si no es obligatorio, pasa a comprobar el nodo padre directamente.
      (get-mandatory-planets-not-visited (node-parent node) planets-mandatory))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Comprueba si en el camino del nodo ra�z al nodo actual
;; se ha pasado por los planetas obligatorios.
;;
;;  Input:
;;    nodo: nodo que representa un estado de b�squeda (el planeta actual).
;;    planets-mandatory: lista de nombres de los planetas obligatorios.
;;
;;  Returns:
;;    T si se ha pasado por todos los nodos obligatorios, NIL si no.
(defun f-mandatory-test (node planets-mandatory)
  ;Y la lista de planetas obligatorios est� vac�a,
  ;hemos pasado por todos los planetas obligatorios.
  (if (null (get-mandatory-planets-not-visited node planets-mandatory))
      T
    nil))

;;;
;;; EJEMPLOS
;;;
(defparameter node-01
   (make-node :state 'Avalon))
(defparameter node-02
   (make-node :state 'Kentares :parent node-01))
(defparameter node-03
   (make-node :state 'Katril :parent node-02))
(defparameter node-04
   (make-node :state 'Kentares :parent node-03))

(f-goal-test-galaxy node-01 '(Kentares Uranus) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-02 '(Kentares Uranus) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-03 '(Kentares Uranus) '(Avalon Katril)); -> NIL
(f-goal-test-galaxy node-04 '(Kentares Uranus) '(Avalon Katril)); -> T


;;
;; END: Exercise 3A -- Goal test
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 3B -- Node equality
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Comprueba si dos nodos son iguales mediante estos criterios:
;;
;;  - Mismo estado de b�squeda (nombre de planeta), si no se
;;    especifican planetas obligatorios como par�metro.
;;  - Mismo estado de b�squeda y lista de planetas obligatorios
;;    por visitar, si se especifican planetas obligatorios.
;;
;;  Input:
;;    node-1: nodo que representa un estado de b�squeda (un planeta).
;;    node-2: nodo que representa otro estado de b�squeda.
;;    planets-mandatory: lista de nombres de los planetas obligatorios.
;;
;;  Returns:
;;    T si los nodos son iguales, NIL si no.
(defun f-search-state-equal-galaxy (node-1 node-2 &optional planets-mandatory)
  ;Si alguno de los nodos pasados como par�metro es NIL,
  ;la funci�n termina.
  (if (or (null node-1) (null node-2))
      nil
    (let ((planet-1 (node-state node-1))
          (planet-2 (node-state node-2)))
      ;Si no se han especificado planetas obligatorios,
      ;se comprueba si el nombre de los planetas es igual.
      (if (null planets-mandatory)
          (equal planet-1 planet-2)
        ;En caso contrario, comprueba si el nombre de los planetas
        ;y la lista de planetas por visitar coinciden.
        (let ((planets-not-visited-node-1 (get-mandatory-planets-not-visited (node-parent node-1) planets-mandatory))
              (planets-not-visited-node-2 (get-mandatory-planets-not-visited (node-parent node-2) planets-mandatory)))
          (and (equal planet-1 planet-2)
               (equal planets-not-visited-node-1 planets-not-visited-node-2)))))))


;;;
;;; EJEMPLOS
;;;
(f-search-state-equal-galaxy node-01 node-01) ;-> T
(f-search-state-equal-galaxy node-01 node-02) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04) ;-> T

(f-search-state-equal-galaxy node-01 node-01 '(Avalon)) ;-> T
(f-search-state-equal-galaxy node-01 node-02 '(Avalon)) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04 '(Avalon)) ;-> T

(f-search-state-equal-galaxy node-01 node-01 '(Avalon Katril)) ;-> T
(f-search-state-equal-galaxy node-01 node-02 '(Avalon Katril)) ;-> NIL
(f-search-state-equal-galaxy node-02 node-04 '(Avalon Katril)) ;-> NIL

;;
;; END: Exercise 3B -- Node equality
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  BEGIN: Exercise 4 -- Define the galaxy structure
;;
;;
(defparameter *galaxy-M35* 
  (make-problem 
   :states            *planets*          
   :initial-state     *planet-origin*
   :f-goal-test       #'(lambda (node) 
                          (f-goal-test-galaxy node *planets-destination*
                                              *planets-mandatory*))
   :f-h               #'(lambda (state)
                          (f-h-galaxy state *sensors*))
   :f-search-state-equal #'(lambda (node-1 node-2) 
                             (f-search-state-equal-galaxy node-1 node-2))
   :operators         (list #'(lambda (node)
                                (navigate-white-hole (node-state node) *white-holes*))
                            #'(lambda (node)
                                (navigate-worm-hole (node-state node) *worm-holes* *planets-forbidden*))))) 

;;
;;  END: Exercise 4 -- Define the galaxy structure
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN Exercise 5: Expand node
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene la lista de nodos a los que se puede acceder
;; desde el nodo actual, utilizando todos los operadores
;; (agujeros blancos y de gusano).
;;
;;  Input:
;;    node: nodo que representa un estado de b�squeda (el planeta actual).
;;    problem: problema de b�squeda.
;;
;;  Returns:
;;    Lista de nodos directamente accesibles desde el nodo actual,
;;    teniendo en cuenta todos los operadores del problema.
(defun expand-node (node problem)
  (expand-node-aux node (problem-operators problem) problem))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de nodos a los que se puede acceder
;; desde el nodo actual, de forma recursiva y teniendo
;; en cuenta todos los operadores del problema.
;;
;;  Input:
;;    node: nodo que representa un estado de b�squeda (el planeta actual).
;;    op-list: lista de operadores del problema (en este caso, agujeros 
;;             blancos y de gusano).
;;    problem: problema de b�squeda.
;;
;;  Returns:
;;    Lista de nodos directamente accesibles desde el nodo actual,
;;    teniendo en cuenta todos los operadores del problema.
(defun expand-node-aux (node op-list problem)
  ;Si llega al final de la lista de operadores, termina.
  (if (null op-list)
      nil
    ;Sino, crea una lista con cada uno de los nodos
    ;obtenidos a partir de la informaci�n de las acciones desde el nodo actual.
    (append (create-node-list-from-action-list (funcall (first op-list) node) node problem) 
            (expand-node-aux node (rest op-list) problem))))
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Crea una lista de nodos a partir de una lista de acciones.
;;
;;  Input:
;;    a-list: lista de acciones que se pueden hacer desde el nodo actual.
;;    node: nodo que representa el estado de b�squeda actual.
;;    problem: problema de b�squeda.
;;
;;  Returns:
;;    Lista de nodos directamente accesibles desde el nodo actual.
(defun create-node-list-from-action-list (a-list parent-node problem)
  ;Fin de la lista de acciones: termina.
  (if (null a-list)
      nil
    ;Crea una lista de nodos a partir de la informaci�n
    ;de cada acci�n.
    (cons (let* ((nstate (action-final (first a-list)))
                 ;(ng (action-cost (first a-list)))
                 (ng (+ (action-cost (first a-list)) (node-g parent-node))) ;Coste desde la ra�z hasta el nodo actual.
                 (nh (funcall (problem-f-h problem) nstate)))
            (make-node 
             :state nstate
             :parent parent-node
             :action (first a-list)
             :depth (+ 1 (node-depth parent-node))
             :g ng
             :h nh
             :f (+ ng nh)))
          (create-node-list-from-action-list (rest a-list) parent-node problem))))
           
;;;
;;; EJEMPLOS
;;;
(expand-node (make-node :state 'Kentares :depth 0 :g 0 :f 0) *galaxy-M35*)
;;;(#S(NODE :STATE AVALON
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL AVALON
;;;                           :COST 3)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE KATRIL
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL KATRIL
;;;                           :COST 10)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE PROSERPINA
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL PROSERPINA
;;;                           :COST 7)
;;;         :DEPTH 1
;;;         :G ...)
;;; #S(NODE :STATE PROSERPINA
;;;         :PARENT #S(NODE :STATE KENTARES
;;;                         :PARENT NIL
;;;                         :ACTION NIL
;;;                         :DEPTH 0
;;;                         :G ...)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE
;;;                           :ORIGIN KENTARES
;;;                           :FINAL PROSERPINA
;;;                           :COST 12)
;;;         :DEPTH 1
;;;         :G ...))

(expand-node (make-node :state 'Proserpina :depth 12 :g 10 :f 20) *galaxy-M35*)
;;;(#S(NODE
;;;    :STATE AVALON
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G 10
;;;               :H 0
;;;               :F 20)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WHITE-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL AVALON
;;;               :COST 8.6)
;;;    :DEPTH 13
;;;    :G 18.6
;;;    :H 15
;;;    :F 33.6)
;;; #S(NODE
;;;    :STATE DAVION
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G ...)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WHITE-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL DAVION
;;;               :COST 5)
;;;    :DEPTH 13
;;;    :G 15
;;;    :H 5
;;;    :F 20)
;;; #S(NODE
;;;    :STATE MALLORY
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G ...)
;;;   :ACTION #S(ACTION
;;;              :NAME NAVIGATE-WHITE-HOLE
;;;              :ORIGIN PROSERPINA
;;;              :FINAL MALLORY
;;;              :COST 15)
;;;   :DEPTH 13
;;;   :G 25
;;;   :H 12
;;;   :F 37)
;;; #S(NODE
;;;   :STATE SIRTIS
;;;   :PARENT #S(NODE
;;;              :STATE PROSERPINA
;;;              :PARENT NIL
;;;              :ACTION NIL
;;;              :DEPTH 12
;;;              :G ...)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WHITE-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL SIRTIS
;;;               :COST 12)
;;;    :DEPTH 13
;;;    :G 22
;;;    :H 0
;;;    :F 22)
;;; #S(NODE
;;;    :STATE KENTARES
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G ...)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WORM-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL KENTARES
;;;               :COST 12)
;;;    :DEPTH 13
;;;    :G 22
;;;    :H 14
;;;    :F 36)
;;; #S(NODE
;;;    :STATE MALLORY
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G ...)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WORM-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL MALLORY
;;;               :COST 11)
;;;    :DEPTH 13
;;;    :G 21
;;;    :H 12
;;;    :F 33)
;;; #S(NODE
;;;    :STATE SIRTIS
;;;    :PARENT #S(NODE
;;;               :STATE PROSERPINA
;;;               :PARENT NIL
;;;               :ACTION NIL
;;;               :DEPTH 12
;;;               :G ...)
;;;    :ACTION #S(ACTION
;;;               :NAME NAVIGATE-WORM-HOLE
;;;               :ORIGIN PROSERPINA
;;;               :FINAL SIRTIS
;;;               :COST 9)
;;;    :DEPTH 13
;;;    :G 19
;;;    :H 0
;;;    :F 19))

;;
;; END Exercise 5: Expand node
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  BEGIN Exercise 6 -- Node list management
;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de nodos ordenada seg�n el criterio
;; de comparaci�n especificado en la estrategia strategy.
;;
;;  Input:
;;    nodes: lista de nodos sin ordenar.
;;    lst-nodes: lista de nodos ordenada seg�n la funci�n de 
;;               comparaci�n de strategy.
;;    strategy: estrategia de b�squeda.
;;
;;  Returns:
;;    Lista de nodos a la que se ha a�adido cada nodo de nodes,
;;    todos ellos ordenados seg�n el criterio de strategy.
(defun insert-nodes-strategy (nodes lst-nodes strategy)
  ;Si la lista de nodos est� vac�a, termina.
  (if (null nodes)
      lst-nodes
    ;Sino, va a�adiendo cada nodo de nodes a la lista ordenada 
    ;lst-nodes mediante sucesivas llamadas a insert-node-strategy.
    (insert-nodes-strategy (rest nodes)
                           (insert-node-strategy (first nodes)
                                                 lst-nodes
                                                 strategy)
                           strategy)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Inserta un nodo en la lista ordenada de nodos de acuerdo
;; al criterio de comparaci�n indicado por strategy.
;;
;;  Input:
;;    node: nodo que se va a insertar en la lista.
;;    lst-nodes: lista de nodos ordenada seg�n la funci�n de 
;;               comparaci�n de strategy.
;;    strategy: estrategia de b�squeda.
;;
;;  Returns:
;;    Lista de nodos a la que se ha a�adido el nodo,
;;    ordenada seg�n el criterio de strategy.
(defun insert-node-strategy (node lst-nodes strategy)
  ;Si la lista de nodos ordenada por g est� vac�a, termina.
  (if (null lst-nodes)
      (list node)
    ;Si la funci�n de comparaci�n de strategy indica que el
    ;par�metro a comparar de node es menor que el primer
    ;elemento de lst-nodes...
    (if (funcall (strategy-node-compare-p strategy) 
                 node 
                 (first lst-nodes))
        ;Node pasa a ser el primer elemento de la lista ordenada.
        (cons node lst-nodes)
      ;Sino, sigue mirando en qu� posici�n insertar el nodo de acuerdo al orden.
      (cons (first lst-nodes) (insert-node-strategy node (rest lst-nodes) strategy)))))

;;
;; Funci�n de coste uniforme
;;
(defun node-g-<= (node-1 node-2)
  (<= (node-g node-1)
      (node-g node-2)))

;;
;; Estrategia de coste uniforme
;;
(defparameter *uniform-cost*
  (make-strategy
   :name 'uniform-cost
   :node-compare-p #'node-g-<=))

;;;
;;; EJEMPLOS
;;;
(defparameter node-00
  (make-node :state 'Proserpina :depth 12 :g 10 :f 20) )
(defparameter node-01
  (make-node :state 'Avalon :depth 0 :g 0 :f 0) )
(defparameter node-02
  (make-node :state 'Kentares :depth 2 :g 50 :f 50) )

(defparameter lst-nodes-00 (expand-node node-00 *galaxy-M35*))

(print (insert-nodes-strategy (list node-00 node-01 node-02) 
                              lst-nodes-00 
                              *uniform-cost*));->
;;;
;;;(#S(NODE :STATE AVALON 
;;;         :PARENT NIL 
;;;         :ACTION NIL 
;;;         :DEPTH 0 :G 0 :H 0 :F 0)
;;; #S(NODE :STATE PROSERPINA 
;;;         :PARENT NIL 
;;;         :ACTION NIL 
;;;         :DEPTH 12 :G 10 :H 0 :F 20)
;;; #S(NODE :STATE AVALON
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL AVALON :COST 8.6)
;;;         :DEPTH 13 :G 18.6 :H 15	:F 33.6)
;;; #S(NODE :STATE DAVION
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)        
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL DAVION :COST 5)
;;;         :DEPTH 13 :G 15 :H 5 :F 20)
;;; #S(NODE :STATE MALLORY 
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)                
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 15)      
;;;         :DEPTH 13 :G 25 :H 12 :F 37)     
;;; #S(NODE :STATE SIRTIS    
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)          
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 12)      
;;;         :DEPTH 13 :G 22 :H 0 :F 22)
;;; #S(NODE :STATE KENTARES   
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0  :F 20)      
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL KENTARES :COST 12)          
;;;         :DEPTH 13 :G 22 :H 14 :F 36)
;;; #S(NODE :STATE MALLORY
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 11)    
;;;         :DEPTH 13 :G 21 :H 12 :F 33)  
;;; #S(NODE :STATE SIRTIS
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)        
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 9)       
;;;         :DEPTH 13 :G 19 :H 0 :F 19)
;;; #S(NODE :STATE KENTARES :PARENT NIL :ACTION NIL :DEPTH 2 :G 50 :H 0 :F 50))


(print 
 (insert-nodes-strategy (list node-00 node-01 node-02) 
                        (sort (copy-list lst-nodes-00) #'<= :key #'node-g) 
                        *uniform-cost*));->
;;;
;;;(#S(NODE :STATE AVALON
;;;         :PARENT NIL
;;;         :ACTION NIL
;;;         :DEPTH 0 :G 0 :H 0 :F 0)
;;; #S(NODE :STATE PROSERPINA
;;;         :PARENT NIL
;;;         :ACTION NIL
;;;         :DEPTH 12 :G 10 :H 0 :F 20)
;;; #S(NODE :STATE DAVION
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL DAVION :COST 5)
;;;         :DEPTH 13 :G 15 :H 5 :F 20)
;;; #S(NODE :STATE AVALON
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL AVALON :COST 8.6)
;;;         :DEPTH 13 :G 18.6 :H 15 :F 33.6)
;;; #S(NODE :STATE SIRTIS
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 9)
;;;         :DEPTH 13 :G 19 :H 0 :F 19)
;;; #S(NODE :STATE MALLORY
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 11)
;;;         :DEPTH 13 :G 21 :H 12 :F 33)
;;; #S(NODE :STATE KENTARES
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WORM-HOLE :ORIGIN PROSERPINA :FINAL KENTARES :COST 12)
;;;         :DEPTH 13 :G 22 :H 14 :F 36)
;;; #S(NODE :STATE SIRTIS
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL SIRTIS :COST 12)
;;;         :DEPTH 13 :G 22 :H 0 :F 22)
;;; #S(NODE :STATE MALLORY
;;;         :PARENT #S(NODE :STATE PROSERPINA :PARENT NIL :ACTION NIL :DEPTH 12 :G 10 :H 0 :F 20)
;;;         :ACTION #S(ACTION :NAME NAVIGATE-WHITE-HOLE :ORIGIN PROSERPINA :FINAL MALLORY :COST 15)
;;;         :DEPTH 13 :G 25 :H 12 :F 37)
;;; #S(NODE :STATE KENTARES
;;;         :PARENT NIL
;;;         :ACTION NIL
;;;         :DEPTH 2 :G 50 :H 0 :F 50))

;;
;;    END: Exercise 6 -- Node list management
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BEGIN: Exercise 7 -- Definition of the A* strategy
;;
;; A strategy is, basically, a comparison function between nodes to tell 
;; us which nodes should be analyzed first. In the A* strategy, the first 
;; node to be analyzed is the one with the smallest value of g+h
;;
(defun lower-g+h (node1 node2)
  (<= (node-f node1)
      (node-f node2)))

(defparameter *A-star*
  (make-strategy
   :name 'A-star
   :node-compare-p #'lower-g+h))

;;
;; END: Exercise 7 -- Definition of the A* strategy
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 8: Search algorithm
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; A partir de un problema de b�squeda, busca la soluci�n 
;; �ptima (camino m�s corto) desde el planeta de origen
;; hasta el planeta de destino, siguiendo una estrategia
;; definida.
;;
;;  Input:
;;    problem: problema de b�squeda.
;;    strategy: estrategia de b�squeda.
;;
;;  Returns:
;;    Camino desde el nodo ra�z hasta el nodo objetivo.
(defun graph-search (problem strategy)
  ;Inicializa el nodo ra�z de la b�squeda,
  ;la lista abierta y la lista cerrada.
  (let* ((initial-planet (problem-initial-state problem))    ;Nombre del planeta inicial.
         (nh (funcall (problem-f-h problem) initial-planet)));Valor de h del nodo ra�z.
    (graph-search-rec 
     (list (make-node :state initial-planet         ;Nodo ra�z del problema con el planeta inicial.
                      :parent nil
                      :action nil
                      :depth 0
                      :g 0
                      :h nh
                      :f (+ 0 nh)))
     nil problem strategy)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; A partir de un problema de b�squeda, busca la soluci�n 
;; �ptima (camino m�s corto), de forma recursiva, desde el planeta 
;; de origen hasta el planeta de destino, siguiendo una estrategia
;; definida.
;;
;;  Input:
;;    open-nodes: lista abierta que contiene los nodos generados,
;;                pero no expandidos.
;;    closed-nodes: lista cerrada que contiene los nodos generados
;;                  y expandidos previamente.
;;    problem: problema de b�squeda.
;;    strategy: estrategia de b�squeda.
;;
;;  Returns:
;;    Camino desde el nodo ra�z hasta el nodo objetivo.
(defun graph-search-rec (open-nodes closed-nodes problem strategy)
  (if (null open-nodes)
      nil
    (let ((current-node (first open-nodes)))
      ;Comprueba si el nodo a expandir es el objetivo.
      (if (f-goal-test-galaxy current-node *planets-destination* *planets-mandatory*)
          ;Si lo es, lo devuelve como soluci�n.
          current-node
        ;En caso contrario, comprueba si el nodo no est� en la lista cerrada o,
        ;si est� en ella, si tiene un valor de g inferior al primer nodo de closed-nodes.
        (if (not-in-closed-nodes current-node closed-nodes)
            ;Expande el nodo actual e inserta los hijos en open-nodes, ordenados de
            ;acuerdo al criterio de comparaci�n de strategy.
            ;Tambi�n inserta el nodo actual en la lista cerrada closed-nodes.
            (let ((new-open-nodes (insert-nodes-strategy (expand-node current-node problem) open-nodes strategy))
                  (new-closed-nodes (append (list current-node) closed-nodes)))
              ;Contin�a la b�squeda eliminando el nodo expandido actual
              ;de la lista abierta.
              (graph-search-rec (remove current-node new-open-nodes) new-closed-nodes problem strategy))
          ;Si el nodo a expandir no cumple las condiciones, se elimina directamente
          ;de la lista abierta.
          (graph-search-rec (remove current-node open-nodes) closed-nodes problem strategy))))))
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Funci�n que comprueba si el nodo no est� en la lista cerrada,
;; o si est�, que su valor de g sea menor que el nodo hom�logo.
;;
;;  Input:
;;    node: nodo cuya presencia y g comprobar.
;;    node-list: lista de nodos donde comprobar la presencia y el g.
;;
;;  Returns:
;;    T o nil, seg�n se cumpla la condici�n o no. 		
(defun not-in-closed-nodes (node node-list)
  (if (null node-list)
      T
    (if (and (f-search-state-equal-galaxy node (first node-list) *planets-mandatory*)
         (> (node-g node) (node-g (first node-list))))
        nil
      (not-in-closed-nodes node (rest node-list)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Resuelve un problema de b�squeda utilizando la estrategia A*.
;;
;;  Input:
;;    problem: problema de b�squeda.
;;
;;  Returns:
;;    Camino desde el nodo ra�z hasta el nodo objetivo.
(defun a-star-search (problem)
  (graph-search problem *A-star*))

;;;
;;; EJEMPLOS
;;;
(graph-search *galaxy-M35* *A-star*);->
;;;#S(NODE :STATE ...
;;;        :PARENT #S(NODE :STATE ...
;;;                        :PARENT #S(NODE :STATE ...)) 


(print (a-star-search *galaxy-M35*));->
;;;#S(NODE :STATE ...
;;;        :PARENT #S(NODE :STATE ...
;;;                        :PARENT #S(NODE :STATE ...)) 


;;; 
;;;    END Exercise 8: Search algorithm
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 9: Solution path / action sequence
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de estados (nombres de planetas) desde
;; el nodo ra�z hasta el nodo objetivo.
;;
;;  Input:
;;    node: nodo objetivo.
;;
;;  Returns:
;;    Lista de nombres que representa el camino desde 
;;    el nodo ra�z hasta el nodo objetivo.
(defun solution-path (node)
  (reverse (get-solution-path node)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de estados (nombres de planetas) desde
;; el nodo objetivo hasta el nodo ra�z.
;;
;;  Input:
;;    node: nodo objetivo.
;;
;;  Returns:
;;    Lista de nombres que representa el camino desde 
;;    el nodo objetivo hasta el nodo ra�z.
(defun get-solution-path (node)
  (if (null node)
      nil
    (cons (node-state node) (get-solution-path (node-parent node)))))

;;;
;;; EJEMPLOS
;;;
(solution-path nil) ;;; -> NIL 
(solution-path (a-star-search *galaxy-M35*))  ;;;-> (MALLORY ...)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de acciones desde el nodo ra�z hasta el nodo objetivo.
;;
;;  Input:
;;    node: nodo objetivo.
;;
;;  Returns:
;;    Lista de nombres que representa las acciones desde 
;;    el nodo ra�z hasta el nodo objetivo.
(defun action-sequence (node)
  (reverse (get-action-sequence node)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Obtiene una lista de acciones desde el nodo objetivo hasta el nodo ra�z.
;;
;;  Input:
;;    node: nodo objetivo.
;;
;;  Returns:
;;    Lista de nombres que representa las acciones desde 
;;    el nodo objetivo hasta el nodo ra�z.
(defun get-action-sequence (node)
  (if (null node)
      nil
    (if (null (node-parent node))
        (node-action node)
      (cons (node-action node) (get-action-sequence (node-parent node))))))

;;;
;;; EJEMPLOS
;;;
(action-sequence nil) ;;; -> NIL
(action-sequence (a-star-search *galaxy-M35*)) ;;; -> (#S(ACTION :NAME ...)) 

;;; 
;;;    END Exercise 9: Solution path / action sequence
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;;    BEGIN Exercise 10: depth-first / breadth-first
;;;

;;
;; Funci�n de b�squeda en profundidad
;;
;; Comprueba si la profundidad de node-1 es 
;; mayor o igual que la de node-2.
;;
(defun depth-first-node-compare-p (node-1 node-2)
  t)
;;
;; Estrategia de b�squeda en profundidad
;;
(defparameter *depth-first*
  (make-strategy
   :name 'depth-first
   :node-compare-p #'depth-first-node-compare-p))

;;;
;;; EJEMPLOS
;;;
(solution-path (graph-search *galaxy-M35* *depth-first*))
(action-sequence (graph-search *galaxy-M35* *depth-first*))
;;; -> (MALLORY ... )

;;
;; Funci�n de b�squeda en anchura
;;
;; Comprueba si la profundidad de node-1 es 
;; menor o igual que la de node-2.
;;
(defun breadth-first-node-compare-p (node-1 node-2)
  nil)
;;
;; Estrategia de b�squeda en anchura
;;
(defparameter *breadth-first*
  (make-strategy
   :name 'breadth-first
   :node-compare-p #'breadth-first-node-compare-p))

;;;
;;; EJEMPLOS
;;;
(solution-path (graph-search *galaxy-M35* *breadth-first*))
(action-sequence (graph-search *galaxy-M35* *breadth-first*))
;; -> (MALLORY ... )

;;; 
;;;    END Exercise 10: depth-first / breadth-first
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

