; extensions[nw]
breed[nodos nodo]
undirected-link-breed[enlaces enlace]

globals[nuevos m  select

  click?
  turtle-head
  arcos-red
  graph-edges
  nodeid
]
turtles-own[my-id grado node-id ]
nodos-own[etiqueta valor grado cerca pagerank eigen clust interm nombre   my-id eigenvector-centrality]


to Geom [N r]
  create-nodos N [
    setxy random-xcor random-ycor
    set color blue
  ]
  ask turtles [
    create-enlaces-with other turtles in-radius r
  ]
end




to cargar-red
  ca

  ask patches [set pcolor 99]
grafos

 if la-red = "geométrica" [ Geom num-nodes el-radio]
 if la-red = "preferencial" [preferential-network ]
  if la-red = "aleatoria" [random-network]
  if la-red = "mundoPequeño" [smallWorld-network]






   ; if la-red = "DisConexo1" [ nw:load "./datasets/disConexo1/DisConexo1.gml" nodos enlaces]
   if la-red = "got" [  set graph-edges arcos-red create-graph graph-edges]
   if la-red = "chris" [  set graph-edges arcos-red create-graph graph-edges]
   if la-red = "legara" [ set graph-edges arcos-red create-graph graph-edges]
  if la-red = "karate" [ set graph-edges arcos-red create-graph graph-edges]
  if la-red = "dolphins" [set graph-edges arcos-red create-graph graph-edges]
  if la-red = "miserables" [ set graph-edges arcos-red create-graph graph-edges]
   if la-red = "moreno" [ set graph-edges arcos-red create-graph graph-edges]
   if la-red = "huelga" [ set graph-edges arcos-red create-graph graph-edges]
    if la-red = "florencia" [ set graph-edges arcos-red create-graph graph-edges]
    if la-red = "polbooks" [  set graph-edges arcos-red create-graph graph-edges]


  ;;; if la-red = "yeast" [ nw:load "./datasets/yeast/yeast.gml" nodos enlaces]

 ; if la-red = "netscience" [ nw:load "./datasets/netscience/netscience.gml" nodos enlaces]

;  if la-red = "adamic" [ nw:load "./datasets/adamic/AdamicBlog.gml" nodos enlaces]




 ;  if la-red = "zukhov" [ nw:load "./datasets/zukhov/zukhov.gml" nodos enlaces]


;  if la-red = "yeast" [nw:load-graphml "./datasets/yeast/yeast.graphml"  ]
;  ask links [set hidden? true]
ask nodos [set etiqueta label set label ""]
 ask nodos [set color blue
    set size 3
    set shape "dot"
    set etiqueta label
    set label ""
    ; set label who
    set label-color black
    set grado count my-links
  ]
  ask links [set thickness .15]
  reset-ticks

end

;to propiedades-red
;  ask nodos [set etiqueta label set label ""]
; ask nodos [set color blue
;    set size 3
;    set shape "dot"
;    set etiqueta label
;    set label ""
;    ; set label who
;    set label-color black
;    set grado count my-links
;  ]
;  ask links [set thickness .15]
;end


;;;;;;;;;;;;;;;;;;;;; redes a mano

to random-network
  ;; Create n nodes randomly positioned
  create-nodos num-nodes [
    set nodeid who
    setxy random-xcor random-ycor
    set color blue
    set size 3
        set shape "dot"
  ]

 ;; For each pair of turtles, create a link with probability p
  ask nodos [
    let pr 4 / ( count turtles - 1)
    let me self
    ask turtles with [self > me] [
      if random-float 1 < pr [
        create-link-with me
      ]
    ]
  ]
  ask turtles [set grado count my-links]
end


to preferential-network

 ;; Create an initial fully connected core of k+1 nodes
  create-nodos (2 + 1) [
    set node-id who
    setxy random-xcor random-ycor

  ]

  ;; Fully connect the initial nodes
  ask nodos [
    ask other nodos [
      if not link-neighbor? myself [
        create-link-with myself
      ]
    ]
  ]

  ;; Add new nodes one at a time
  while [count turtles < num-nodes] [
    let new-node-id count turtles
    create-nodos 1 [
      set node-id new-node-id
      setxy random-xcor random-ycor
    ]
    let new-node turtle new-node-id

    ;; Choose k existing nodes with probability proportional to degree
    let targets []
    while [length targets < 2] [
      let potential one-of turtles with [
        self != new-node and
        not member? self targets and
        not link-neighbor? new-node
      ]
      if potential != nobody [
        let deg sum [count link-neighbors] of turtles
        let prob [count link-neighbors] of potential / deg
        if random-float 1 < prob [
          set targets lput potential targets
        ]
      ]
    ]

    ask new-node [
      foreach targets [ t ->
        create-link-with t
      ]
    ]
  ]

  ask nodos
 [  set color blue
    set size 3
        set shape "dot"
]
  ask nodos [set grado count my-links]
end





















to smallWorld-network
   create-nodos num-nodes [
    set node-id who
    let angle (who * 360 / num-nodes)
    setxy (cos angle) * 10 (sin angle) * 10
  ]
  ask turtles [
    set color blue
    set size 3
    set shape "dot"
  ]
  ;; Build ring lattice: each node connects to k/2 neighbors on each side
  ask nodos [
    let myid node-id
    let half-k k / 2
    let i 1
    while [i <= half-k] [
      let neighbor-id (myid + i) mod num-nodes
      if not link-neighbor? turtle neighbor-id [
        create-link-with turtle neighbor-id
      ]
      let neighbor-id2 (myid - i + num-nodes) mod num-nodes
      if not link-neighbor? turtle neighbor-id2 [
        create-link-with turtle neighbor-id2
      ]
      set i i + 1
    ]
  ]

  ;; Rewire links with probability p
  ask links [
    if random-float 1 < p [
      let from-node end1
      let to-node end2
      let from-id [node-id] of from-node
      let to-id [node-id] of to-node

      ;; Only rewire from-node to a new node (avoid self-loops or duplicates)
      let possible-targets turtles with [
        node-id != from-id and
        not link-neighbor? from-node
      ]

      if any? possible-targets [
        let new-to one-of possible-targets
        ask from-node [ create-link-with new-to ]
        die ;; delete the original link
      ]
    ]
  ]
   ; ask turtles [set grado count my-links]
end






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Medidas Globales ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report densidad
  let n count nodos
  let lmax  n * (n - 1) / 2
  let l count links
  report l / lmax
end





to-report radio
  report min [eccentricity] of nodos

end

to-report diametro
  report max [eccentricity] of nodos
end



to-report max-grado
  report max [grado] of turtles
end



to k-core [n]
  ask nodos with [count my-links < n] [die]
end





to-report core
  report nodos with [ eccentricity = radio]
end

to-report periferia
  report nodos with [ eccentricity = diametro]
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mover Nodos ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to mover-nodos
  ifelse mouse-down? [
    ; if the mouse is down then handle selecting and dragging
    handle-select-and-drag
  ][
    ; otherwise, make sure the previous selection is deselected
   set select nobody
    reset-perspective
  ]
  display ; update the display
end

to handle-select-and-drag
  ; if no turtle is selected
  ifelse select = nobody  [
    ; pick the closet turtle
    set select min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    ; check whether or not it's close enough
    ifelse [distancexy mouse-xcor mouse-ycor] of select > 1 [
      set select nobody ; if not, don't select it
    ][
      watch select ; if it is, go ahead and `watch` it
    ]
  ][
    ; if a turtle is selected, move it to the mouse
    ask select [ setxy mouse-xcor mouse-ycor ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;; ataque con mouse ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to ataque-con-mouse
  ifelse mouse-down? [
    ; if the mouse is down then handle selecting and dragging
    handle-select-and-drag-ataque
  ][
    ; otherwise, make sure the previous selection is deselected
   set select nobody
    reset-perspective
  ]
  display ; update the display
end

to handle-select-and-drag-ataque
  ; if no turtle is selected
  ifelse select = nobody  [
    ; pick the closet turtle
    set select min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    ; check whether or not it's close enough
    ifelse [distancexy mouse-xcor mouse-ycor] of select > 1 [
      set select nobody ; if not, don't select it
    ][
      watch select ; if it is, go ahead and `watch` it
    ]
  ][
    ; if a turtle is selected, move it to the mouse
    ask select [ die ]
  ]
end




















;;;;;;;;;;;;;;;;;;; Centralidad grado ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to ver-grados
  ask nodos [
    set grado count my-links
  ; set size  d * grado
   set color scale-color green grado maxi-grado mini-grado
    set label-color black
    set label grado
  ]
end

to-report maxi-grado
  report max [grado] of nodos
end

to-report mini-grado
  report min [grado] of nodos
end

;;;;;;;;;;;;;;;;;;;;;;;;;;; Centralidad Intermediación

to ver-between
  ask nodos [
    set interm approx-betweenness-centrality 10
;  set size  d * 0.01 * interm

   set color scale-color green interm maxi-between mini-between
        set label-color black
    set label precision interm 2
  ]
end

to-report maxi-between
  report max [interm] of nodos
end

to-report mini-between
  report min [interm] of nodos
end

;;;;;;;;;;;;;;;;;;;;;;;; Centralidad Cercanía ;;;;;;;;;;;;;;;;;;;;;

to ver-cercanía

  ask nodos [
     set cerca  closeness-centrality
  ;  set size d *  cerca
    set label precision cerca 1
    set color scale-color green cerca maxi-cerca mini-cerca
        set label-color black
    set label precision cerca 2
  ]
end

to-report maxi-cerca
  report max [cerca] of nodos
end

to-report mini-cerca
  report min [cerca] of nodos
end





;;;;;;;;;;;;;;;;;;;;;;;;; Centralidad eigen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to ver-eigen
    compute-eigenvector-centralities 100 0.0001
  ask nodos [
    set eigen eigenvector-centrality
  ;  set size  d * eigen
    set color scale-color green eigen maxi-eigen mini-eigen
        set label-color black
    set label precision eigen 2
  ]
end

to-report maxi-eigen
  report max [eigen] of nodos
end

to-report mini-eigen
  report min [eigen] of nodos
end










;;;;;;;;;;;;;;;;;;;;;;;;;;;; edicion nodos ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to borrar
  ca
  ask patches [set pcolor 77]
  set click? false
  ask nodos [set label-color black]
set turtle-head nobody
end


to editar-nodos
   ifelse mouse-down?
  [
    if not click?
    [
      set click? true
     set num-nodes count turtles
     ; set num-nodes 5
      ifelse Crear-Eliminar = "Crear" [
        create-nodos 1 [
          setxy (mouse-xcor) (mouse-ycor)
          set num-nodes num-nodes + 1
          set size 4
          set shape "dot"
          set color blue
        ]
      ] [
        if (num-nodes > 0) [
          ask min-one-of nodos [distancexy mouse-xcor mouse-ycor] [ die ]
          set num-nodes num-nodes - 1
        ]
      ]

    ]
  ]
  [
    if click?
    [
      set click? false
    ]
  ]
end

to editar-enlaces
  if (count turtles > 0) [
    ifelse mouse-down?
    [
      if not click?
      [
        set click? true
        let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
        ifelse turtle-head = nobody [
          set turtle-head candidate
          ask candidate [set color white]
        ] [
          ifelse Crear-Eliminar = "Crear" [
            ask turtle-head [create-link-with candidate [set thickness .2] ]
          ] [
            ask turtle-head [if link-neighbor? candidate [ ask link-with candidate [ die ] ] ]
          ]

          set turtle-head nobody

        ]
      ]
    ] [
      if click?
      [
        set click? false
      ]
    ]
    display
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; grafoa a mano ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to grafos

  if la-red = "got" [
    set arcos-red [ [0 51] [0 53] [0 116] [1 2] [1 62] [2 75] [2 93] [2 90] [2 38] [2 87] [2 8] [2 16] [2 48] [2 62] [2 86] [2 101] [2 102] [3 45] [3 100] [3 81] [3 41] [3 27] [3 85] [3 78] [3 62] [4 75] [4 101] [4 109] [4 44] [4 45] [4 125] [4 102] [4 93] [4 17] [4 16] [4 25] [4 32] [4 49] [4 105] [4 119] [4 92] [4 6] [4 13] [4 31] [4 55] [4 68] [4 73] [4 35] [4 38] [4 80] [4 34] [4 56] [4 114] [5 16] [5 13] [5 92] [6 75] [6 125] [6 35] [6 17] [6 32] [6 44] [6 80] [6 101] [7 110] [7 114] [8 75] [8 93] [8 17] [8 119] [8 44] [8 38] [8 55] [8 80] [8 52] [8 86] [9 45] [9 114] [9 75] [9 92] [9 125] [9 16] [9 17] [9 41] [9 93] [10 75] [10 93] [11 20] [11 81] [12 20] [12 81] [13 63] [13 92] [13 75] [13 77] [13 16] [13 110] [13 45] [13 114] [13 91] [13 29] [13 38] [13 76] [13 93] [13 95] [13 17] [13 123] [13 14] [13 32] [14 75] [14 16] [14 45] [14 90] [15 114] [15 103] [15 16] [15 95] [15 60] [15 104] [15 116] [15 117] [15 71] [15 94] [15 51] [15 65] [16 92] [16 75] [16 114] [16 121] [16 60] [16 38] [16 95] [16 55] [16 63] [16 17] [16 110] [16 93] [16 45] [16 101] [16 117] [16 26] [16 119] [16 94] [16 71] [16 46] [16 65] [16 116] [16 30] [16 44] [16 66] [16 125] [16 19] [16 32] [16 108] [17 75] [17 93] [17 44] [17 38] [17 101] [17 114] [17 119] [17 80] [17 55] [17 92] [17 32] [17 35] [17 45] [17 46] [17 52] [17 86] [17 116] [17 41] [17 59] [17 68] [17 97] [17 106] [17 125] [18 22] [19 48] [19 22] [19 120] [19 70] [19 21] [19 37] [19 82] [19 124] [19 83] [19 88] [19 34] [19 64] [19 93] [19 119] [19 75] [19 42] [19 101] [20 81] [20 45] [20 100] [20 27] [20 41] [20 58] [20 62] [20 85] [21 120] [21 37] [21 22] [21 124] [21 36] [21 42] [21 48] [22 120] [22 48] [22 64] [22 70] [22 34] [22 82] [22 88] [22 83] [22 37] [22 93] [23 26] [23 47] [23 92] [24 98] [24 123] [25 75] [25 111] [25 31] [25 119] [25 125] [26 92] [26 110] [26 95] [26 38] [26 116] [26 75] [26 86] [26 89] [26 106] [26 121] [27 81] [27 45] [27 100] [27 85] [27 114] [27 41] [28 75] [29 92] [29 110] [29 114] [29 77] [30 121] [31 56] [32 101] [32 44] [32 75] [32 114] [32 68] [32 93] [32 55] [32 72] [32 57] [32 35] [32 38] [32 92] [32 125] [33 49] [33 75] [33 55] [33 46] [33 72] [33 101] [34 120] [34 119] [34 48] [35 44] [35 75] [35 101] [35 125] [35 68] [35 119] [37 83] [37 48] [37 42] [37 120] [38 75] [38 114] [38 116] [38 49] [38 93] [38 45] [38 92] [38 44] [38 51] [38 55] [38 97] [38 110] [38 46] [38 90] [38 101] [38 115] [39 75] [39 119] [39 86] [39 55] [39 80] [40 41] [40 78] [40 81] [41 45] [41 100] [41 114] [41 81] [41 62] [41 78] [41 79] [41 75] [41 93] [41 44] [43 114] [44 101] [44 75] [44 93] [44 114] [44 119] [44 65] [44 80] [44 55] [44 68] [44 92] [44 73] [44 102] [44 86] [44 116] [44 125] [44 45] [44 113] [44 123] [45 100] [45 114] [45 81] [45 75] [45 62] [45 92] [45 85] [45 110] [45 78] [45 79] [45 93] [45 123] [45 95] [45 97] [46 75] [46 93] [46 55] [46 60] [46 80] [46 94] [46 119] [47 92] [48 120] [48 83] [48 124] [48 70] [48 82] [48 88] [48 54] [48 75] [48 119] [49 75] [49 55] [49 93] [49 69] [49 110] [50 121] [51 114] [51 116] [51 53] [51 104] [52 93] [52 75] [52 86] [53 114] [55 75] [55 119] [55 101] [55 80] [55 97] [55 86] [55 93] [55 72] [55 114] [55 102] [55 116] [55 106] [55 57] [55 69] [55 125] [57 86] [57 72] [57 75] [57 101] [57 93] [57 61] [58 81] [59 75] [59 93] [60 94] [60 114] [60 117] [60 71] [62 114] [62 81] [62 100] [63 92] [63 110] [63 77] [63 114] [63 75] [63 93] [63 95] [63 101] [65 95] [65 114] [65 68] [65 125] [66 114] [67 100] [68 109] [68 101] [68 75] [69 75] [70 82] [70 83] [71 114] [71 94] [71 117] [71 95] [72 75] [72 93] [72 101] [73 101] [73 75] [74 114] [75 93] [75 119] [75 80] [75 101] [75 86] [75 92] [75 125] [75 110] [75 114] [75 116] [75 95] [75 106] [75 111] [75 102] [75 109] [75 112] [75 90] [75 81] [75 123] [75 96] [75 97] [75 107] [75 118] [76 92] [76 110] [77 110] [77 92] [77 91] [78 100] [78 81] [79 81] [79 100] [80 119] [80 101] [80 93] [80 97] [80 86] [80 116] [80 125] [81 100] [81 85] [81 114] [82 83] [83 120] [83 124] [84 100] [85 100] [85 114] [86 93] [86 106] [86 119] [86 101] [86 92] [86 112] [87 93] [88 120] [89 92] [89 110] [91 92] [92 110] [92 114] [92 95] [92 101] [92 93] [92 116] [92 121] [92 106] [92 119] [93 101] [93 119] [93 116] [93 114] [93 120] [93 106] [93 97] [93 113] [94 114] [94 117] [95 114] [95 110] [95 116] [97 110] [97 114] [98 123] [99 121] [101 102] [101 119] [101 125] [101 106] [103 114] [103 116] [104 114] [104 116] [106 112] [108 121] [110 114] [110 121] [110 123] [114 116] [114 125] [114 115] [114 119] [114 117] [119 125] [122 123] ]
  ]



  if la-red = "polbooks" [
    set arcos-red [ [0 1] [0 2] [0 3] [0 4] [0 5] [0 6] [1 3] [1 5] [1 6] [2 4] [2 5] [2 7] [3 5] [3 8] [3 9] [3 10] [3 11] [3 12] [3 13] [3 14] [3 15] [3 16] [3 17] [3 18] [3 19] [3 20] [3 21] [3 22] [3 23] [3 24] [3 25] [3 26] [3 27] [4 5] [4 6] [4 28] [4 29] [4 30] [4 31] [5 6] [5 7] [6 7] [6 10] [6 12] [6 18] [6 22] [6 25] [6 29] [7 14] [7 30] [7 58] [7 71] [7 85] [8 9] [8 10] [8 11] [8 12] [8 13] [8 14] [8 20] [8 21] [8 22] [8 23] [8 24] [8 26] [8 27] [8 32] [8 33] [8 35] [8 37] [8 40] [8 41] [8 42] [8 43] [8 44] [8 45] [8 46] [9 11] [9 12] [9 14] [9 20] [9 24] [9 27] [9 41] [9 45] [9 47] [9 48] [9 49] [9 50] [9 51] [9 52] [10 11] [10 12] [10 15] [10 16] [10 19] [10 21] [10 33] [10 35] [10 37] [10 38] [10 39] [10 55] [11 12] [11 13] [11 14] [11 17] [11 20] [11 21] [11 22] [11 26] [11 27] [11 29] [11 45] [11 47] [11 50] [11 56] [12 13] [12 14] [12 15] [12 17] [12 18] [12 23] [12 24] [12 32] [12 33] [12 36] [12 38] [12 39] [12 40] [12 41] [12 44] [12 46] [12 47] [12 54] [12 55] [13 17] [13 29] [13 32] [13 40] [13 42] [13 43] [13 44] [13 47] [13 57] [14 25] [14 26] [14 58] [15 16] [15 55] [17 47] [19 55] [19 56] [19 77] [20 24] [20 40] [20 48] [20 49] [20 53] [20 57] [21 23] [22 25] [22 40] [22 52] [23 27] [23 32] [23 33] [23 47] [23 54] [24 26] [24 40] [24 47] [24 53] [25 40] [26 40] [26 45] [26 47] [26 53] [27 40] [27 41] [27 47] [27 54] [28 66] [28 72] [30 31] [30 58] [30 66] [30 67] [30 70] [30 73] [30 74] [30 75] [30 76] [30 77] [30 79] [30 80] [30 82] [30 83] [30 84] [30 86] [30 93] [30 99] [31 49] [31 73] [31 74] [31 75] [31 76] [31 77] [31 78] [31 82] [31 91] [32 33] [33 37] [33 38] [33 39] [33 47] [34 35] [34 36] [34 37] [34 38] [34 39] [35 36] [35 37] [35 38] [35 39] [35 40] [35 43] [35 44] [36 41] [36 47] [37 38] [37 47] [38 39] [39 40] [39 42] [40 41] [40 42] [40 44] [40 45] [40 47] [40 53] [40 54] [41 47] [41 54] [42 43] [42 47] [43 56] [45 47] [46 47] [46 102] [47 54] [48 49] [48 57] [49 57] [49 58] [49 72] [49 76] [50 58] [51 52] [51 58] [51 64] [51 65] [51 69] [52 58] [52 64] [53 76] [56 57] [58 64] [58 65] [58 68] [58 69] [58 77] [58 85] [59 60] [59 61] [59 62] [59 63] [59 99] [60 62] [60 63] [60 84] [60 86] [60 99] [61 86] [61 95] [61 101] [62 63] [62 84] [62 99] [62 100] [63 99] [64 65] [64 66] [64 67] [64 68] [64 69] [64 70] [65 67] [65 68] [65 69] [65 85] [66 67] [66 70] [66 72] [66 73] [66 74] [66 76] [66 80] [66 84] [66 85] [66 86] [66 88] [66 89] [66 90] [66 93] [66 96] [66 97] [66 99] [66 100] [67 103] [67 104] [68 71] [69 104] [70 71] [70 72] [70 75] [70 90] [71 72] [71 73] [71 74] [71 75] [71 76] [71 77] [71 78] [71 79] [71 80] [71 81] [71 82] [71 83] [72 73] [72 74] [72 75] [72 76] [72 78] [72 79] [72 80] [72 82] [72 84] [72 85] [72 86] [72 87] [72 88] [72 89] [72 90] [72 91] [72 92] [73 74] [73 75] [73 82] [73 83] [73 84] [73 86] [73 89] [73 92] [73 93] [73 94] [73 95] [73 96] [73 97] [73 98] [73 99] [73 100] [74 75] [74 78] [74 79] [74 82] [74 84] [74 87] [74 88] [74 91] [74 98] [74 99] [75 76] [75 77] [75 78] [75 79] [75 82] [75 83] [75 84] [75 91] [75 92] [76 77] [76 82] [76 83] [76 84] [76 86] [79 84] [79 91] [79 100] [81 84] [81 86] [81 97] [82 84] [83 84] [83 87] [83 100] [84 86] [84 87] [84 88] [84 89] [84 94] [84 96] [84 97] [84 99] [84 100] [84 101] [86 89] [86 93] [86 97] [86 100] [86 101] [87 98] [88 89] [90 91] [90 99] [91 98] [91 100] [93 94] [93 99] [93 102] [94 95] [94 96] [94 101] [94 102] [95 102] [96 97] [96 100] [98 100] [99 100] [100 101] [103 104] ]
  ]

  if la-red = "karate" [

  set arcos-red [ [1 2] [1 3] [1 4] [1 5] [1 6] [1 7] [1 8] [1 9] [1 11] [1 12] [1 13] [1 14] [1 18] [1 20] [1 22]
    [1 32] [2 3] [2 4] [2 8] [2 14] [2 18] [2 20] [2 22] [2 31] [3 4] [3 8] [3 9] [3 10] [3 14] [3 28] [3 29] [3 33] [4 8]
    [4 13] [4 14] [5 7] [5 11] [6 7] [6 11] [6 17] [7 17] [9 31] [9 33] [9 34] [10 34] [14 34] [15 33] [15 34] [16 33]
    [16 34] [19 33] [19 34] [20 34] [21 33] [21 34] [23 33]
    [23 34] [24 26] [24 28] [24 30] [24 33] [24 34] [25 26] [25 28] [25 32] [26 32] [27 30] [27 34] [28 34] [29 32]
    [29 34] [30 33] [30 34] [31 33] [31 34] [32 33] [32 34] [33 34] ]

  ]

  if la-red = "dolphins" [

 set arcos-red [ [0 10] [0 14] [0 15] [0 40] [0 42] [0 47] [1 17] [1 19] [1 26] [1 27] [1 28] [1 36] [1 41] [1 54] [2 10] [2 42] [2 44] [2 61] [3 8] [3 14] [3 59] [4 51] [5 9] [5 13]
    [5 56] [5 57] [6 9] [6 13] [6 17] [6 54] [6 56] [6 57] [7 19] [7 27] [7 30] [7 40] [7 54] [8 20] [8 28] [8 37] [8 45] [8 59] [9 13] [9 17] [9 32] [9 41] [9 57] [10 29]
    [10 42] [10 47] [11 51] [12 33] [13 17] [13 32] [13 41] [13 54] [13 57] [14 16] [14 24] [14 33] [14 34] [14 37] [14 38] [14 40] [14 43] [14 50] [14 52] [15 18] [15 24] [15 40]
    [15 45] [15 55] [15 59] [16 20] [16 33] [16 37] [16 38] [16 50] [17 22] [17 25] [17 27] [17 31] [17 57] [18 20] [18 21] [18 24] [18 29] [18 45] [18 51] [19 30] [19 54] [20 28]
    [20 36] [20 38] [20 44] [20 47] [20 50] [21 29] [21 33] [21 37] [21 45] [21 51] [23 36] [23 45] [23 51] [24 29] [24 45] [24 51] [25 26] [25 27] [26 27] [28 30] [28 47] [29 35]
    [29 43] [29 45] [29 51] [29 52] [30 42] [30 47] [32 60] [33 34] [33 37] [33 38] [33 40] [33 43] [33 50] [34 37] [34 44] [34 49] [36 37] [36 39] [36 40] [36 59] [37 40] [37 43]
    [37 45] [37 61]
    [38 43] [38 44] [38 52] [38 58] [39 57] [40 52] [41 54] [41 57] [42 47] [42 50] [43 46] [43 53] [45 50] [45 51] [45 59] [46 49] [48 57] [50 51] [51 55] [53 61] [54 57] ]

  ]


  if la-red = "huelga" [

    set arcos-red [ [0 1] [0 2] [0 3] [1 3] [2 1] [2 3] [4 3] [4 5] [4 6] [4 7] [4 8] [4 9]
      [4 10] [5 6] [6 4] [7 8] [8 11] [8 12] [10 13] [10 14] [10 15] [10 16] [10 17] [11 8] [12 9] [12 13] [14 18]
      [15 17] [17 21] [18 19] [18 15] [19 20] [20 16] [21 22] [22 17] ]
  ]


  if la-red = "florencia" [
    print "10"
    set arcos-red [ [0 1] [1 5] [1 6] [1 7] [1 8] [1 9] [2 3] [2 4] [2 5] [3 4] [3 11] [4 6] [4 11] [6 7] [7 12] [8 13] [8 12] [9 10] [11 12] [12 14] ]
  ]

  if la-red = "legara" [
  set arcos-red  [ [0 1] [0 2] [0 3] [1 4] [1 5] [1 2] [2 6] [2 7] [2 8] [2 9] [4 10] [8 19] [8 23] [8 24] [10 11] [10 12] [12 13] [12 14] [12 15] [13 16] [16 17] [16 18] [19 20] [19 21] [19 22] [23 24] ]
 ]



  if la-red = "miserables" [
 set arcos-red [ [0 1] [0 2] [0 3] [0 4] [0 5] [0 6] [0 7] [0 8] [0 9] [0 11] [2 3] [2 11] [3 11] [10 11] [11 12] [11 13] [11 14] [11 15] [11 23] [11 24] [11 25] [11 26] [11 27] [11 28]
      [11 29] [11 31] [11 32] [11 33] [11 34] [11 35] [11 36] [11 37] [11 38] [11 43] [11 44] [11 48] [11 49] [11 51] [11 55] [11 58] [11 64] [11 68] [11 69] [11 70]
      [11 71] [11 72] [12 23] [16 17] [16 18] [16 19] [16 20] [16 21] [16 22] [16 23] [16 26] [16 55] [17 18] [17 19] [17 20] [17 21] [17 22] [17 23] [18 19] [18 20] [18 21]
      [18 22] [18 23] [19 20] [19 21] [19 22] [19 23] [20 21] [20 22] [20 23] [21 22] [21 23] [22 23] [23 24] [23 25] [23 27] [23 29] [23 30] [23 31] [24 25] [24 26] [24 27]
      [24 41] [24 42] [24 50] [24 68] [24 69] [24 70] [25 26] [25 27] [25 39] [25 40] [25 41] [25 42] [25 48] [25 55] [25 68] [25 69] [25 70] [25 71] [25 75] [26 27] [26 43]
      [26 49] [26 51] [26 54] [26 55] [26 72] [27 28] [27 29] [27 31] [27 33] [27 43] [27 48] [27 58] [27 68] [27 69] [27 70] [27 71] [27 72] [28 44] [28 45] [29 34] [29 35]
      [29 36] [29 37] [29 38] [30 31] [34 35] [34 36] [34 37] [34 38] [35 36] [35 37] [35 38] [36 37] [36 38] [37 38] [39 52] [39 55] [41 42] [41 55] [41 57] [41 62] [41 68]
      [41 69] [41 70] [41 71] [41 75] [46 47] [47 48] [48 55] [48 57] [48 58] [48 59] [48 60] [48 61] [48 62] [48 63] [48 64] [48 65] [48 66] [48 68] [48 69] [48 71] [48 73]
      [48 74] [48 75] [48 76] [49 50] [49 51] [49 54] [49 55] [49 56] [51 52] [51 53] [51 54] [51 55] [54 55] [55 56] [55 57] [55 58] [55 59] [55 61] [55 62] [55 63] [55 64]
      [55 65] [57 58] [57 59] [57 61] [57 62] [57 63] [57 64] [57 65] [57 67] [58 59] [58 60] [58 61] [58 62] [58 63] [58 64] [58 65] [58 66] [58 70] [58 76] [59 60] [59 61]
      [59 62] [59 63] [59 64] [59 65] [59 66] [60 61] [60 62] [60 63] [60 64] [60 65] [60 66] [61 62] [61 63] [61 64] [61 65] [61 66] [62 63] [62 64] [62 65] [62 66]
      [62 76]
      [63 64] [63 65] [63 66] [63 76] [64 65] [64 66] [64 76] [65 66] [65 76] [66 76] [68 69] [68 70] [68 71] [68 75] [69 70] [69 71] [69 75] [70 71] [70 75] [71 75] [73 74] ]

  ]

  if la-red = "moreno" [
    set arcos-red [ [0 1] [0 4] [0 17] [0 5] [0 15] [1 2] [2 3] [2 6] [2 15] [3 6] [3 7] [4 5] [4 10] [6 7] [6 8] [8 9] [8 10] [8 16] [9 14] [10 16] [11 14] [11 12]
      [11 13] [12 14] [13 14] [17 29] [17 28] [17 18] [17 19] [18 19] [19 23] [19 24] [20 30] [20 25] [20 22] [20 21] [21 22] [23 28] [24 25] [25 29] [26 27]
      [26 28] [27 28] [28 29] [28 30] [31 32] ]
  ]

 if la-red = "chris" [
    set arcos-red [ [0 1] [1 2] [1 3] [1 4] [1 5] [1 24] [2 3] [2 4] [3 4] [4 5] [5 6] [5 7] [6 7] [6 8] [6 9] [6 15] [6 16] [6 17] [6 13] [6 18] [6 19] [7 8] [7 9] [7 10] [7 14] [7 17]
      [7 18] [7 16] [7 19] [7 20] [8 18] [9 16] [9 18] [10 11] [11 12] [11 13] [11 43] [13 14] [14 20] [16 19] [16 18] [16 20] [16 67]
      [17 18] [18 19] [18 22] [18 49] [18 28] [19 20] [20 21] [20 23] [20 24] [20 25] [20 26] [20 27] [20 37] [22 28] [23 29] [24 30] [24 31] [25 29] [25 32] [25 33]
      [25 34] [25 35] [25 36] [26 28] [26 53] [27 29] [27 48] [27 39] [27 38] [27 44] [27 64] [28 29] [28 50] [28 51] [28 52] [29 35] [29 36] [29 49] [30 36] [30 31] [30 53] [31 35]
      [31 36] [31 53] [34 37] [34 38] [34 39] [34 40] [36 54] [37 41] [37 42] [37 43] [37 44] [37 45] [37 46] [37 38] [37 64] [37 40] [38 64] [38 39] [38 67] [39 45] [39 40] [39 64] [39 67]
      [39 46] [39 44] [39 87] [40 52] [40 48] [40 46] [40 67] [40 77] [43 45] [43 67] [45 47] [45 67] [48 66] [48 67] [48 80] [49 66] [49 63] [49 77] [50 52] [50 63] [50 62] [50 66] [51 61]
      [51 52] [51 65] [51 66] [51 63] [51 60] [52 63] [52 66] [53 55] [53 56] [53 57] [53 58] [53 59] [53 60] [53 61] [56 75] [56 57] [56 76] [56 59] [57 78] [58 79] [59 60] [60 64] [60 67]
      [60 66] [60 75] [60 63] [61 62] [61 63] [61 64] [62 67] [63 67] [63 66] [63 75] [63 64] [63 65] [64 68] [64 67] [64 80] [64 75] [64 72] [65 66] [65 75] [65 73] [65 72] [66 67] [66 75]
      [66 72] [67 68] [67 69] [67 70] [67 71] [67 72] [67 73] [67 84] [67 85] [67 87] [67 82] [70 74] [72 83] [73 84] [74 87] [75 82] [75 78] [77 81] [77 79] [77 82] [78 82] [79 82] [79 89]
      [79 90] [79 86] [80 81] [81 86] [82 89] [82 90] [82 84] [83 87] [83 89] [83 86] [83 91] [83 90] [84 94] [85 86] [85 87]
      [86 89] [86 90] [86 94] [86 91] [86 97] [86 93] [86 98] [86 92] [87 88] [89 92] [89 93] [90 94] [90 95] [90 96] [90 91] [90 93] [91 93] [92 99] [92 100] [92 101] [92 98] ]
  ]

end

to create-graph [edge-list]
  let all-nodes []

  ;; Extract all node ids from the edge list
  foreach edge-list [ pair ->
    let src first pair
    let tgt last pair
    set all-nodes lput src all-nodes
    set all-nodes lput tgt all-nodes
  ]

  ;; Remove duplicates
  set all-nodes remove-duplicates all-nodes

  ;; Create turtles with labels
  foreach all-nodes [ node ->
    create-nodos 1 [
      setxy random-xcor random-ycor
      set shape "circle"
      set label node
      set size 2
      set color blue
      set my-id node
    ]
  ]

  ;; Create links
  foreach edge-list [ pair ->
    let src first pair
    let tgt last pair
    ask one-of nodos with [my-id = src] [
      create-enlace-with one-of nodos with [my-id = tgt]
    ]
  ]
end

to-report eccentricity
  let distances []
  let visited (list self)
  let queue (list (list self 0))

  while [not empty? queue] [
    let current first queue
    set queue but-first queue

    let node item 0 current
    let dist item 1 current
    set distances lput dist distances

    let neighbo sort [link-neighbors] of node
    foreach neighbo [
      [nbr] ->
      if not member? nbr visited [
        set visited lput nbr visited
        set queue lput (list nbr (dist + 1)) queue
      ]
    ]
  ]

  report max distances
end






;;;;;;;;;;;;;; cnetralidades a ma no ;;;;;;;;;;;;;;;;;;;;;;











;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; closeness centrality ;;;;;;;;;;;;;;;;;;;;;;;


to-report closeness-centrality
  ; report the closeness centrality of the calling turtle
  ; assumes an undirected, connected network
  let total-distance 0
  let reachable-nodes other turtles with [distance myself != false]

  if any? reachable-nodes [
    set total-distance sum [distance myself] of reachable-nodes
    if total-distance > 0 [
      report (count reachable-nodes) / total-distance
    ]
  ]
  report 0 ; if unreachable or isolated
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; betweeness centrality ;;;;;;;;;;;;;;;;;;;;;;;




to-report approx-betweenness-centrality [num-samples]
  let btwn 0
  let others other turtles
  let samples []

  ;; Randomly sample pairs of nodes (excluding self)
  while [length samples < num-samples] [
    let s one-of others
    let t one-of others
    if s != t and s != self and t != self [
      set samples lput (list s t) samples
    ]
  ]

  ;; Check shortest paths for each sampled pair
  foreach samples [ pair ->
    let s first pair
    let t last pair
    let paths all-shortest-paths s t
    let through-me 0

    foreach paths [ path ->
      if member? self path [
        set through-me through-me + 1
      ]
    ]

    if length paths > 0 [
      set btwn btwn + (through-me / length paths)
    ]
  ]

  report btwn
end

to-report betweenness-centrality
  let btwn 0
  let others other turtles

  ; loop over all pairs of turtles excluding self
  foreach sort others [ s ->
    foreach sort others [ t ->
      if s != t and s != self and t != self [
        let paths all-shortest-paths s t
        let through-me 0

        foreach paths [ path ->
          if member? self path [
            set through-me through-me + 1
          ]
        ]

        if length paths > 0 [
          set btwn btwn + (through-me / length paths)
        ]
      ]
    ]
  ]

  report btwn
end

to-report all-shortest-paths [start fin]
  ;; Each path is a list of turtles
  let paths (list (list start))
  let finished-paths []
  let shortest-length 0

  while [length paths > 0] [
    let new-paths []

    let i 0
    while [i < length paths] [
      let path item i paths
      let last-node last path

      if last-node = fin [
        if shortest-length = 0 [
          set shortest-length length path
        ]
        if length path = shortest-length [
          set finished-paths lput path finished-paths
        ]
      ]

      if shortest-length = 0 or length path < shortest-length [
        let nbrs [link-neighbors] of last-node
        let j 0
        while [j < length sort nbrs] [
          let ene item j sort nbrs
          if not member? ene path [
            let new-path lput ene path
            set new-paths lput new-path new-paths
          ]
          set j j + 1
        ]
      ]

      set i i + 1
    ]

    set paths new-paths
  ]

  report finished-paths
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; eigenvector centrality ;;;;;;;;;;;;;;;;;;;;;;;

to compute-eigenvector-centralities [max-iterations tolerance]
  ;; initialize centralities
  let centralities n-values count turtles [1]
  let new-centralities n-values count turtles [0]
  let delta tolerance + 1
  let iter 0

  while [iter < max-iterations and delta > tolerance] [
    ;; update scores
    (foreach sort turtles centralities [
      [t score] ->
      let s 0
      let neighb [link-neighbors] of t
      ask neighb [
        let idx position self sort turtles
        set s s + item idx centralities
      ]
      let idx-self position t sort turtles
      set new-centralities replace-item idx-self new-centralities s
    ])

    ;; normalize vector
    let norm sqrt sum map [x -> x * x] new-centralities
    set new-centralities map [x -> x / norm] new-centralities

    ;; compute difference for convergence
    set delta 0
    let i 0
    while [i < count turtles] [
      set delta delta + abs (item i new-centralities - item i centralities)
      set i i + 1
    ]

    set centralities new-centralities
    set iter iter + 1
  ]

  ;; assign result to each turtle
  (foreach sort turtles centralities [
    [t score] -> ask t [ set eigenvector-centrality score ]
  ])
end

to-report eigenvector-score
  report eigenvector-centrality
end




;;;;;;;;;;;;;; giant comp a mano ;,



to-report giant-component
  let all-components []
  let unchecked turtles

  while [any? unchecked] [
    let node one-of unchecked
    let component bfs-component node
    set all-components lput component all-components
    ; eliminar los nodos ya procesados de unchecked
    set unchecked turtles with [not member? self component]
  ]

  ; encontrar el componente más grande manualmente
  let largest []
  let largest-size 0

  foreach all-components [
    [comp] ->
      if length comp > largest-size [
        set largest comp
        set largest-size length comp
      ]
  ]

  report turtle-set largest
end


to-report bfs-component [start-node]
  let visited (list start-node)
  let queue (list start-node)

  while [not empty? queue] [
    let current first queue
    set queue but-first queue

    let neighbo sort [link-neighbors] of current
    foreach neighbo [
      [neighbor] ->
        if not member? neighbor visited [
          set visited lput neighbor visited
          set queue lput neighbor queue
        ]
    ]
  ]

  report visited
end











;;;;;;;;;;;;;;;;;;;;;;;; apl a mano




to-report average-path-length
  let total-distance 0
  let coun 0

  ; loop over all unique pairs of turtles
  foreach sort turtles [
    [t1] ->
      foreach sort turtles [
        [t2] ->
          if t1 != t2 [
            let de shortest-path-length t1 t2
            if de != false [
              set total-distance total-distance + de
              set coun coun + 1
            ]
          ]
      ]
  ]

  if coun = 0 [ report 0 ]
  report total-distance / coun
end



to-report shortest-path-length [ start-node end-node ]
  if start-node = end-node [ report 0 ]
  let visited (list start-node)
  let frontier (list (list start-node 0)) ; list of (node, distance)

  while [not empty? frontier] [
    let current-pair first frontier
    set frontier but-first frontier
    let current-node item 0 current-pair
    let dist item 1 current-pair

    if current-node = end-node [ report dist ]

    let neighbo sort [link-neighbors] of current-node
    foreach neighbo [
      [ene] ->
        if not member? ene visited [
          set visited lput ene visited
          set frontier lput (list ene (dist + 1)) frontier
        ]
    ]
  ]

  report false ; no path found
end

;;;;;;;;;;;; global clust a mano

to-report global-clustering
  let triangle-count 0
  let triple-count 0

  ask turtles [
    let neighbo link-neighbors
    let neighbor-list sort neighbo
    let ene length  neighbor-list

    ; contar triples centrados en este nodo
    if ene >= 2 [
      set triple-count triple-count + (ene * (ene - 1)) / 2
    ]

    ; contar triángulos entre vecinos
    ; (solo si los vecinos están conectados entre sí)
    ; evitamos dobles conteos comparando solo pares ordenados
    let i 0
    while [i < length neighbor-list] [
      let ni item i neighbor-list
      let j (i + 1)
      while [j < length neighbor-list] [
        let nj item j neighbor-list
        if member? nj ([link-neighbors] of ni) [
          set triangle-count triangle-count + 1
        ]
        set j j + 1
      ]
      set i i + 1
    ]
  ]

  if triple-count = 0 [ report 0 ]
  report triangle-count / triple-count
end

;to-report transitivity
;  let closed-triplets sum [ global-clustering * count my-links * (count my-links - 1) ] of turtles
;  let triplets sum [ count my-links * (count my-links - 1) ] of turtles
;  report closed-triplets / triplets
;end
@#$#@#$#@
GRAPHICS-WINDOW
615
32
1301
463
-1
-1
12.8
1
10
1
1
1
0
0
0
1
-26
26
-16
16
0
0
1
ticks
30.0

CHOOSER
130
10
296
55
la-red
la-red
"-----Artificial Netwotks------------" "geométrica" "preferencial" "mundoPequeño" "aleatoria" "--------------- Natural Networks----------" "---------------------------------------" "got" "chris" "legara" "dolphins" "miserables" "florencia" "karate" "moreno" "huelga" "polbooks"
13

BUTTON
5
10
109
43
load-network
cargar-red
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
3
83
87
116
spring
layout-spring turtles links .2 5 c
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
194
54
286
87
c
c
0
10
8.831
.001
1
NIL
HORIZONTAL

MONITOR
357
12
420
57
diameter
diametro
17
1
11

MONITOR
5
330
88
375
av-path-length
precision average-path-length 3
17
1
11

PLOT
87
328
470
549
Degree Distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "set-plot-x-range 0 (max-grado + 3)"
PENS
"default" 1.0 1 -16777216 true "" "histogram [grado] of nodos"

MONITOR
359
56
422
101
density
precision densidad 3
17
1
11

MONITOR
474
44
531
89
nodes
count nodos
17
1
11

MONITOR
530
44
587
89
links
count links
17
1
11

MONITOR
287
57
360
102
max-degree
max-grado
17
1
11

MONITOR
524
148
600
193
num-comp
num-componentes
17
1
11

MONITOR
523
190
600
235
size-gig
count componente-gigante
17
1
11

MONITOR
296
12
358
57
radius
radio
17
1
11

SLIDER
4
116
96
149
num-nodes
num-nodes
0
300
26.0
1
1
NIL
HORIZONTAL

SLIDER
94
116
186
149
el-radio
el-radio
0
30
6.0
1
1
NIL
HORIZONTAL

MONITOR
469
342
563
387
global-clustering
precision global-clustering 3
17
1
11

BUTTON
265
103
328
136
core
ask core [set color yellow set size 4]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
327
103
412
136
periphery
ask periferia[ set color red set size 4]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
473
10
586
43
move-nodes
mover-nodos
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
274
556
516
605
Small World,Geometric: High Clustering Preferential, Random : Low Clustering 
14
0.0
1

BUTTON
86
83
157
116
circular
layout-circle nodos 16
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
23
205
95
238
labels+
ask nodos [set label who]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
425
156
518
189
giant-comp
ask giant-component\n[ set color red\nset size 4]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
448
239
514
272
k-core
k-core num
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
513
239
605
272
num
num
0
15
8.0
1
1
NIL
HORIZONTAL

TEXTBOX
80
569
230
603
Pendiente: Cortes Mínimos
14
0.0
1

BUTTON
291
136
386
169
eccentricity
ask nodos [set label eccentricity]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
23
237
94
270
labels-
ask nodos [set label \"\"]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
94
205
158
238
links+
ask links [set hidden? false]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
93
237
158
270
links-
ask links [set hidden? true]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
474
88
588
133
nodes-complete
(count nodos) * (count nodos - 1) / 2
17
1
11

TEXTBOX
424
109
481
143
n(n-1)/2
12
0.0
1

SLIDER
4
147
96
180
p
p
0
1
0.155
.001
1
NIL
HORIZONTAL

SLIDER
495
462
587
495
d
d
0
100
8.0
1
1
NIL
HORIZONTAL

BUTTON
474
393
539
427
grado
ver-grados
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
539
393
603
427
close
ver-cercanía
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
475
427
539
461
bet
ver-between
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
539
428
603
462
eigen
ver-eigen
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
260
172
398
217
Crear-Eliminar
Crear-Eliminar
"Crear" "Eliminar"
0

BUTTON
290
250
361
283
all-blue
ask nodos[set color blue]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
259
217
325
250
Nodos
editar-nodos
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
325
217
398
250
Enlaces
editar-enlaces
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
229
250
292
283
erase
borrar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
265
295
415
323
!!Ojo!!! !!!!Oprimir erase antes de construir la red!!!!!!
11
0.0
1

BUTTON
424
188
519
221
dejar-solo-giant
ask nodos with [color != red] [die]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
189
120
274
138
<-- Geométrica
11
0.0
1

BUTTON
360
250
433
283
igual-tamaño
ask nodos [set size 3]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
95
149
187
182
k
k
0
6
4.0
1
1
NIL
HORIZONTAL

BUTTON
50
52
115
85
spring
repeat 100 [\nlayout-spring turtles links .2 5 10\n\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
