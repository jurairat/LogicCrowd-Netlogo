globals[
  count-id 
  end-time buffer-time pk-time wp 
  setup-prob
  total-answer
  total-battery
  total-batteryshow
  link-list
  expect-nodes
  transfer_ratecal
  con-nodes
  count-sendnodes
  All-Power-Mediator
  Mediator-energy
  Tpower
  qid 
  temp-turtle
  Estimatepower 
  ps  
  stp 
  pusage 
  idletime
  listnode
]

breed[sources source]
breed[mediators mediator]
breed[terminals terminal]

sources-own[
  id vid 
  neighbor-list
  parent
  count-ans
  answer
  wp-node
  count-node
  battery
  battery-usage
  batteryenough
  select

  ]
mediators-own[
  id vid 
  neighbor-list
  parent
  count-ans
  answer
  wp-node
  count-node
  battery
  battery-usage
  batteryenough
  ]
terminals-own[
  id vid
  neighbor-list
  parent
  count-ans
  answer
  wp-node
  count-node
  battery
  battery-usage
  batteryenough

  ]

to setup
__clear-all-and-reset-ticks
Estimate
set Degree precision Degree  0
setup-buffer-time
set qid 1
check-required-answers
create-all-nodes
create-all-networks
setup-probability
ask links [ set color white ]
reset-ticks
set temp-turtle 0
end

to Estimate
  let wt (waiting-period * 60) 
 
  if Connection_Mode = "Point-to-point"
  [
     set ps ((3 * package-size) / 100 + 10.24) ; 
     set stp (ps * 0.003) ; runtime
     set pusage Degree * stp 
  
     ifelse background?
     [
      set idletime (wt - (Degree * ps)) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          
                                                                ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%                                                                ;; = (1 * 1 / 31104) =  0.00003% per second
     ]
      [
      set idletime (wt - (Degree * ps)) * 0.002
      ]
      set Estimatepower  (pusage + idletime)
  ]
  
  if Connection_Mode = "Point-to-Multipoint"
  [
   let transfer (transfer_rate * 1024) * 1024 
   set ps (((((Degree * package-size) * 1024) * 8) / transfer) + 1)
   set stp ps * 0.005
   
   ifelse background?
    [
      set idletime (wt - ps) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                  ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          
                                                                  ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%  
                                                                  ;; = (1 * 1 / 31104) =  0.00003% per second
    ]
    [
      set idletime (wt - ps) * 0.002
    ]
     set Estimatepower  (stp + idletime) 
  ]
 

end

to check-required-answers
  let min-nodes 0
  let all-nodes (number-of-sources +  number-of-mediators + number-of-terminals - 1) ;; the number of current nodes that the user set.
  set all-nodes precision (all-nodes * probability-peer-responses) 0 ;; to calculate the number of nodes that is possible to returned answers.
  if required-answers != 0
  [
    if required-answers > all-nodes
    [
      set min-nodes precision (required-answers / probability-peer-responses) 0 ;; the number of minimun nodes that is possible to returned answers as required.
      let expected-terminals precision (min-nodes * 5 / 100) 0 ;; define 10% of terminal nodes from minimum of nodes
      if expected-terminals > number-of-terminals 
      [
        set number-of-terminals number-of-terminals + (expected-terminals - number-of-terminals)
      ] 
      set number-of-mediators min-nodes - number-of-terminals
    ]
    if waiting-period < (required-answers * buffer-time) / 60 ;;check enough time for distributing task
    [
      set waiting-period (required-answers * buffer-time) / 60
    ]
  ]
end

to create-all-nodes
 set count-id 0
 set-default-shape turtles "circle"
 
 create-sources number-of-sources
 [  
   ;narrow
   wide
   set color red
   set vid []
   set neighbor-list []
   set battery 100
   set count-node 0
   set battery-usage 0
   set batteryenough 1
   set select 0
 ]

 create-mediators number-of-mediators
 [   
   ;narrow
   wide
   ;set label who
   set color green
   set vid []
   set neighbor-list []
   set battery 100
   set count-node 0
   set battery-usage 0
   set batteryenough 1
  
 ] 

 create-terminals number-of-terminals
 [   
   wide
   set color yellow
   set vid []
   set neighbor-list []
   set battery 100
   set count-node 0
   set battery-usage 0
   set batteryenough 1
 ]
  
end

to narrow
  setxy (random-xcor * 0.99 ) (random-ycor * 0.99 )
end

to wide
  setxy (random-xcor * 0.99 ) (random-ycor * 0.99)
end

to create-all-networks
  if connectivity-density = "high" 
  [
   create-high-density-network 
  ]
  if connectivity-density = "medium 1"
  [
    create-medium1-density-network
  ]
  if connectivity-density = "medium 2"
  [
    create-medium2-density-network
  ]
  if connectivity-density = "low" 
  [
   create-low-density-network 
  ]
end

to create-high-density-network
  let radius_value Radius
  ask sources
  [
   create-links-with other sources in-radius radius_value
   create-links-with mediators in-radius radius_value
   create-links-with terminals in-radius radius_value
  ]
  ask mediators
  [
   create-links-with other mediators in-radius radius_value
   create-links-with sources in-radius radius_value
   create-links-with terminals in-radius radius_value
  ]
  
end

to setup-layout
  let all-nodes (number-of-sources + number-of-mediators + number-of-terminals)
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt all-nodes)) 1
  ]

end

to create-medium1-density-network
  let radius_value Radius
  ask sources
  [
   ;let choice-list [turtle who] of other turtles in-radius radius with [not link-neighbor? myself]
   ;let #-nodes length choice-list
   let #-nodes count other turtles in-radius radius_value with [not link-neighbor? myself]
   set #-nodes floor (#-nodes / 2)
   ;create-links-with n-of #-nodes other turtles in-radius radius with [not link-neighbor? myself]
   
   if (count turtles with [not link-neighbor? myself] in-radius radius_value > 2)
   [
     create-links-with n-of 2 other turtles in-radius radius_value with [not link-neighbor? myself]
   ]
  
  ]
  ask mediators
  [
   ;let choice-list [turtle who] of other turtles in-radius radius with [not link-neighbor? myself]
   ;let #-nodes length choice-list
   let #-nodes count other turtles in-radius radius_value with [not link-neighbor? myself]
   set #-nodes floor (#-nodes / 2)
   ;create-links-with n-of #-nodes other turtles in-radius radius with [not link-neighbor? myself]
    if (count turtles with [not link-neighbor? myself] in-radius radius_value > 2 )
   [
      
      create-links-with n-of 2 other turtles in-radius radius_value with [not link-neighbor? myself]
   ]
  ]
  ;show count links
  
end

to create-medium2-density-network
  let radius_value Radius
  ask sources
  [  
   let x count other turtles in-radius radius_value with [not link-neighbor? myself]
   if x > 0
   [
     
     
     ifelse x = 1 
     [
       create-links-with n-of 1 other turtles in-radius radius_value with [not link-neighbor? myself]
     ]
     [
       
       if x > 1 and x < 10
       [
       
       create-links-with n-of x other turtles in-radius radius_value with [not link-neighbor? myself]
       ]
       if x >= 10
       [
        create-links-with n-of 10 other turtles in-radius radius_value with [not link-neighbor? myself]
       ]
     
     ]
   ]
  ]
  ask mediators
  [   
   let x count other turtles in-radius radius_value with [not link-neighbor? myself]
   if x > 0
   [

     ifelse x = 1 
     [
       create-links-with n-of 1 other turtles in-radius radius_value with [not link-neighbor? myself]
     ]
     [
       
       if x > 1 and x < 10
       [
       
       create-links-with n-of x other turtles in-radius radius_value with [not link-neighbor? myself]
       ]
           if x >= 10
       [
        create-links-with n-of 10 other turtles in-radius radius_value with [not link-neighbor? myself]
       ]
     
     ]
   ]
   ]
  
end

to create-low-density-network
    let radius_value Radius
    set link-list []
    ask one-of sources
    [
      set link-list lput source who link-list
      let choice-list sort-on [distance myself] other turtles in-radius radius_value with [not link-neighbor? myself] 
      if choice-list != []
      [
        foreach choice-list
        [
          if not member? ? link-list
          [
            set link-list lput ? link-list
            create-link-with ?
            find-next-link ?
          ]
          
        ] 
      ] 
    ]
end

to find-next-link [node]
    let radius_value Radius
    let nn node
    ask node
    [
      let choice-list sort-on [distance myself] other turtles in-radius radius_value with [not link-neighbor? myself]
      if choice-list != []
      [
        foreach choice-list
        [
          if not member? ? link-list
          [
            set link-list lput ? link-list
            create-link-with ?
            find-next-link ?
            set nn ?
            stop
            
          ]
          
        ] 
      create-low-density-network2 nn
      ]   
    ]
end

to create-low-density-network2 [node]
    let radius_value Radius
    let mm node
    ask one-of mediators in-radius radius_value  with [not link-neighbor? node]
    [
      set link-list lput node link-list
      let choice-list sort-on [distance myself] other turtles in-radius radius_value with [not link-neighbor? myself] 
      if choice-list != []
      [
        foreach choice-list
        [
          if not member? ? link-list
          [
            set link-list lput ? link-list
            create-link-with ?
            find-next-link ?
          ]
          
        ] 
      ] 
    ]
    
end


to setup-probability
  let all-nodes count turtles
  set all-nodes all-nodes   
  let answer-nodes probability-peer-responses * all-nodes 
  ask n-of answer-nodes turtles
  [
    set answer 1
  ]
  set setup-prob probability-peer-responses
end

to clearvalue
  set total-battery 100
  set total-batteryshow 0
  reset-timer
  setup-buffer-time
  set total-answer 0
  set count-id 0
  set count-sendnodes 0
  set temp-turtle 0
  ask turtles [
    set label "" 
    set vid [] 
    set wp-node 0 
    ;set answer 1   
    set neighbor-list []
    set battery 100
    set count-node 0
    set battery-usage 0
    set batteryenough 1
    ] 
  ask sources
  [
   set select 0
  ]
  setup-probability
  clear-all-plots
  clear-output 

end

to resetforaskcrowd
  set total-batteryshow 0
  reset-timer
  create-id
  setup-buffer-time
  set total-answer 0
  set count-sendnodes 0
  ask turtles [set answer 0 set wp-node 0 ] 
  setup-probability 
  if setup-prob != probability-peer-responses
  [
    
    ask turtles [ set answer 0 set wp-node 0]
    setup-probability
  ]
end

to start
  Estimate
  resetforaskcrowd
if temp-turtle = 0
     [
     ask one-of sources
     [
       set temp-turtle source who
       set select 1
     ]
     ]
set listnode []
ask other sources with [select = 0]
[
 set listnode lput source who listnode
]

askcrowd temp-turtle

foreach listnode
[
  resetforaskcrowd
  askcrowd ?
]
  ;tick
  
end

to create-id
  ask sources
  [
   set count-id count-id + 1
   set id count-id
  ]
  set qid qid + 1
end

to setup-buffer-time
  
  if Connection_Mode = "Point-to-point"
  [
  set pk-time ((3 * package-size) / 100 + 10.24) ; time consumed 100 kb = 3 seconds. and 10.24 sec is for bluetooth inquiry and scan
  set buffer-time pk-time  
  ]
  
  if Connection_Mode = "Point-to-Multipoint"
  [
    set transfer_ratecal (transfer_rate * 1024) * 1024 
   
  ]
end

to start-forever
  Estimate
  resetforaskcrowd

  if temp-turtle = 0
     [
     ask one-of sources
     [
       set temp-turtle source who
       set select 1
     ]
     ]
     
set listnode []
ask other sources with [select = 0 and batteryenough = 1 ]
[
 set listnode lput source who listnode
]
askcrowd temp-turtle

ifelse listnode !=[]
[
foreach listnode
[
  resetforaskcrowd
  askcrowd ?
  
]
]
[ 
  stop
]

end

to askcrowd [node]
     ask node
     [
     if battery < Estimatepower
     [
       set  batteryenough 0
     ]
     set answer 0
     reset-count-ans
     set shape "circle 2"
     set vid lput qid vid
     set wp (waiting-period * 60)
     set wp-node wp 
     if  wp >= buffer-time and package-size != 0 and battery-usage <= battery-budget / 100 * battery and (battery-usage < battery) and  batteryenough = 1 
     [
       check-visited node qid    
     ]
     set shape "circle"
     set total-answer count-ans
     output-print (word node ": message = " count-sendnodes", battery usage = " precision battery-usage 3)
     ]

     ask temp-turtle
     [
     set total-battery precision battery 3
     ]
     tick
end


to reset-count-ans
  ask sources [set count-ans 0 set count-node 0 set battery-usage 0] 
  ask mediators [set count-ans 0 set count-node 0 set battery-usage 0]
  ask terminals [set count-ans 0 set count-node 0 set battery-usage 0]
end


to check-visited [node send-id]
  ask node
  [    
    let temp-neighbor-list []
    let m count link-neighbors with [ not member? send-id vid ] 
    if m > 0 and m < Degree
    [
    ask n-of m link-neighbors with [ not member? send-id vid ] 
    [
           if Connection_Mode = "Point-to-Multipoint"
          [
             set pk-time (((((m * package-size) * 1024) * 8) / transfer_ratecal ) + 1)
         
             set buffer-time pk-time 
          ]     
        
        
        if(breed = mediators) [if not member? send-id vid 
                              [ set temp-neighbor-list lput mediator who temp-neighbor-list
                                set vid lput send-id vid
                              ]
                              ]
        if(breed = terminals) [if not member? send-id vid 
                                  [ set temp-neighbor-list lput terminal who temp-neighbor-list
                                    set vid lput send-id vid
                                  ]
                                ]
        if(breed = sources) [if not member? send-id vid 
                              [ set temp-neighbor-list lput source who temp-neighbor-list
                                set vid lput send-id vid
                              ]
                            ]
    ]
    ]
    
    if  m >= Degree
    [
    ask n-of Degree link-neighbors with [ not member? send-id vid ] 
    [
        
        if Connection_Mode = "Point-to-Multipoint"
        [
        set pk-time (((((Degree * package-size) * 1024) * 8) / transfer_ratecal ) + 1)
        set buffer-time pk-time 
        ]
        
        if(breed = mediators) [if not member? send-id vid 
                              [ set temp-neighbor-list lput mediator who temp-neighbor-list
                                set vid lput send-id vid
                              ]
                              ]
        if(breed = terminals) [if not member? send-id vid 
                                  [ set temp-neighbor-list lput terminal who temp-neighbor-list
                                    set vid lput send-id vid
                                  ]
                                ]
        if(breed = sources) [if not member? send-id vid 
                              [ set temp-neighbor-list lput source who temp-neighbor-list
                                set vid lput send-id vid
                                
                              ]
                            ]
    ]
    ]
    set neighbor-list temp-neighbor-list
    calbatteryidle node 
    ifelse (breed = sources) and (neighbor-list =[])
    [
    
    ]
    [
      if wp-node >= buffer-time and battery-usage <= battery-budget / 100 * battery and batteryenough = 1 
      [
          send-msg node neighbor-list send-id wp-node  
      ]
    ]
    ]
  
end


to send-msg [forward-node friends-list sent-id wptime]
  if Connection_Mode = "Point-to-point"
  [ 
  if friends-list !=[]
  [ 
    foreach friends-list
    [ 
      ask ?
      [
        
        if answer = 1 
        [
          set answer 0 
          count-send-node forward-node   
          set count-sendnodes count-sendnodes + 1 
          set wp wp - buffer-time
          set wptime wptime - buffer-time
          set wp-node wptime
     
          if wp-node >= 0
          [
          set-color ?
          battery-estimation forward-node "send"
          battery-estimation ? "get"
          set parent forward-node 
          calbatteryidle ? 
          ] 
          if (forward?) and (wp-node >= buffer-time) and (breed != terminals) and (battery-usage <= battery-budget / 100 * battery) and batteryenough = 1 
          [
            check-visited ? sent-id
          ]   
        ]    
      
           
      ]
    ]
  ]
  
  return-all-answer forward-node
  battery-idletime forward-node
  ]
  
  if Connection_Mode = "Point-to-Multipoint"
  [
  if friends-list !=[]
  [ 
    foreach friends-list
    [
      ask ?
      [
       set wp-node wptime - (buffer-time + 10)
      ]
    ]
    battery-estimation forward-node "send"
    foreach friends-list
    [
      ask ?
      [
        if answer = 1 
        [
          count-send-node forward-node
          set count-sendnodes count-sendnodes + 1
          set-color ?
          battery-estimation ? "get"
          set parent forward-node 
          calbatteryidle ?
          if (forward?) and (wp-node >= buffer-time) and (breed != terminals) and (battery-usage <= battery-budget / 100 * battery) and batteryenough = 1 
          [    
            check-visited ? sent-id
          ]   
        ]    
      ]
    ]
  ]
  return-all-answer forward-node
  battery-idletime forward-node
  ]
end


to count-send-node[node]
 
  ask node
  [
    set count-node count-node + 1
  ]
end


to battery-idletime [node]
  
  ask node
  [
    let idle-time 0
    
    if Connection_Mode = "Point-to-point"
    [
    
    ifelse background?
    [
      set idle-time (wp-node - (count-node * pk-time)) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                  ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%                                                                ;; = (1 * 1 / 31104) =  0.00003% per second
    ]
    [
      set idle-time (wp-node - (count-node * pk-time)) * 0.002
    ]
    ]
    if Connection_Mode = "Point-to-Multipoint"
    [    
    ifelse background?
    [
      set idle-time (wp-node - pk-time) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                  ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%  
                                                                  ;; = (1 * 1 / 31104) =  0.00003% per second
    ]
    [
      set idle-time (wp-node - pk-time) * 0.002
    ]
    ]
    set battery-usage battery-usage + idle-time
    set battery battery - idle-time 
    if battery <= 0
    [
     set battery 0 
     ]
    if node = temp-turtle 
    [
      set total-batteryshow battery-usage
    ]
    set label precision battery 3
    
  ]
end

to battery-estimation [node state]
  
  ask node
  [
    let idle-time 0
    let run-time 0  
    if state = "send"
    [
     if Connection_Mode = "Point-to-point"
     [
      set run-time pk-time * 0.003 ;; 5 minutes (300 seconds) consumes 1% of battery level
     ]
     if Connection_Mode = "Point-to-Multipoint"
     [
      set run-time pk-time * 0.005 ;;  minutes (210 seconds) consumes 1% of battery level
     ]
    
    ]
    if state = "get"
    [
       if Connection_Mode = "Point-to-point"
     [
       set run-time pk-time * 0.004 ;; 4 minutes (300 seconds) consumes 1% of battery level
     ]
   if Connection_Mode = "Point-to-Multipoint"
     [
       set run-time pk-time * 0.005 ;; 4 minutes (300 seconds) consumes 1% of battery level
     ]
   
    ]   
    if battery > run-time and state = "get"
    [
    get-answers node
    set battery-usage battery-usage + run-time 
    set battery battery - run-time
    ]
    if battery > run-time and state = "send"
    [
    set battery-usage battery-usage + run-time 
    set battery battery - run-time
   
    ]
    set label precision battery 3
    if node = temp-turtle 
    [
      set total-batteryshow battery-usage
    ]
 
  ]
end
to calbatteryidle [node]
  
  ask node
  [
    let idle-time 0
    
    if Connection_Mode = "Point-to-point"
    [
    
    ifelse background?
    [
      set idle-time (wp-node - (count-node * pk-time)) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                  ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%                                                                ;; = (1 * 1 / 31104) =  0.00003% per second
    ]
    [
      set idle-time (wp-node - (count-node * pk-time)) * 0.002
    ]
    ]
    if Connection_Mode = "Point-to-Multipoint"
    [    
    ifelse background?
    [
      set idle-time (wp-node - pk-time) * 0.00003  ;; stand-by time of battery is in 864 Hours so it will decrease every 8.64 hours for 1 %  
                                                                  ;; 8.64 hrs = 8.64 * 3600 = 31104 seconds                                                          ;; to calculate the percentage of battery usage for a second = 31104 sec consumed 1%  
                                                                  ;; = (1 * 1 / 31104) =  0.00003% per second
    ]
    [
      set idle-time (wp-node - pk-time) * 0.002
    ]
    ]
    
    if idle-time > battery 
    [
     set batteryenough 0
    ]
 
  ]
end

to set-color [node]
  ask node
  [
      if (breed = sources) 
      [
        set color white
        wait 0.01 
        set color red
        if shape != "circle 2"
        [set shape "circle"]
      ]
      if (breed = mediators)
      [
        set color white
        wait 0.01
        set color green
      ]
      if (breed = terminals)
       [
        set color white
        wait 0.01 
        set color yellow
      ]
  ]
 
end

to get-answers [own]
  
    if own != 0
    [
      ask own
      [
        if parent != 0
        [
          ask parent
          [    
              set count-ans count-ans + 1
              set total-answer count-ans
              
          ]
        ]
      ]
    ]
    
  
end

to return-all-answer [node]
  
    if node != 0
    [
      ask node
      [
        let ans count-ans
        if parent != 0
        [
          ask parent
          [
            set count-ans count-ans + ans
            set total-answer count-ans
           
          ]
        ]
      ]
    ]
end


to-report session-time  ;by Interface Monitor -- string hh:mm:ss of timer 
  let $t timer  ; assumes < 100 hours 
  report (word pad($t / 3600) ":" 
               pad( ($t mod 3600)/ 60 ) ":" 
               pad($t mod 60) 
         ) 

end 
to-report pad [ #number ]  ; for number < 100, two-digit string format 
report substring (word (100 + int #number)) 1 3 
end 
to-report batteryshow
 report  total-batteryshow
 
end


  
@#$#@#$#@
GRAPHICS-WINDOW
468
12
1239
741
24
22
15.561
1
10
1
1
1
0
0
0
1
-24
24
-22
22
0
0
1
ticks
30.0

BUTTON
377
11
459
52
SETUP
setup
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
9
50
206
83
number-of-mediators
number-of-mediators
0
2000
198
1
1
nodes
HORIZONTAL

SLIDER
9
92
205
125
number-of-terminals
number-of-terminals
0
100
5
1
1
nodes
HORIZONTAL

BUTTON
376
62
459
103
GO
start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
8
169
125
202
forward?
forward?
0
1
-1000

CHOOSER
209
120
370
165
connectivity-density
connectivity-density
"high" "medium 1" "medium 2" "low"
0

SLIDER
209
83
369
116
battery-budget
battery-budget
0
100
100
25
1
%
HORIZONTAL

SLIDER
210
10
369
43
waiting-period
waiting-period
10
60
25
5
1
minutes
HORIZONTAL

SLIDER
210
47
369
80
package-size
package-size
0
3000
1000
100
1
kb
HORIZONTAL

SLIDER
8
131
204
164
probability-peer-responses
probability-peer-responses
0
1
1
0.25
1
NIL
HORIZONTAL

SLIDER
9
10
206
43
number-of-sources
number-of-sources
1
1000
3
1
1
nodes
HORIZONTAL

SWITCH
129
169
249
202
background?
background?
1
1
-1000

INPUTBOX
8
206
103
266
required-answers
0
1
0
Number

PLOT
5
433
413
582
The remaining of battery level for a source (%)
Time
Battery Level
0.0
10.0
0.0
100.0
true
false
"set total-battery 100" ""
PENS
"default" 1.0 0 -13345367 true "" "plot total-battery"

CHOOSER
252
169
371
214
Radius
Radius
5 10 15 20
0

CHOOSER
251
218
372
263
Connection_Mode
Connection_Mode
"Point-to-point" "Point-to-Multipoint"
0

INPUTBOX
168
206
246
266
transfer_rate
20.8
1
0
Number

INPUTBOX
106
206
164
266
Degree
7
1
0
Number

BUTTON
376
112
460
154
GO FOREVER
start-forever
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
7
273
413
423
The number of returned messages for a source
NIL
Messages
0.0
60.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count-sendnodes"

BUTTON
376
164
460
205
CLEAR
clearvalue
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
4
605
412
750
11

TEXTBOX
7
585
61
603
Output:
14
0.0
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

computer server
false
0
Rectangle -7500403 true true 75 30 225 270
Line -16777216 false 210 30 210 195
Line -16777216 false 90 30 90 195
Line -16777216 false 90 195 210 195
Rectangle -10899396 true false 184 34 200 40
Rectangle -10899396 true false 184 47 200 53
Rectangle -10899396 true false 184 63 200 69
Line -16777216 false 90 210 90 255
Line -16777216 false 105 210 105 255
Line -16777216 false 120 210 120 255
Line -16777216 false 135 210 135 255
Line -16777216 false 165 210 165 255
Line -16777216 false 180 210 180 255
Line -16777216 false 195 210 195 255
Line -16777216 false 210 210 210 255
Rectangle -7500403 true true 84 232 219 236
Rectangle -16777216 false false 101 172 112 184

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

mobile
true
14
Rectangle -7500403 true false 60 30 225 270
Rectangle -16777216 true true 90 45 195 165
Rectangle -16777216 true true 90 180 120 195
Rectangle -16777216 true true 135 180 165 195
Rectangle -16777216 true true 180 180 210 195
Rectangle -16777216 true true 90 210 120 225
Rectangle -16777216 true true 90 240 120 255
Rectangle -16777216 true true 135 210 165 225
Rectangle -16777216 true true 135 240 165 255
Rectangle -16777216 true true 180 210 210 225
Rectangle -16777216 true true 180 240 210 255

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

telephone
false
0
Polygon -7500403 true true 75 273 60 255 60 195 84 165 75 165 45 150 45 120 60 90 105 75 195 75 240 90 255 120 255 150 223 165 215 165 240 195 240 255 226 274
Polygon -16777216 false false 75 273 60 255 60 195 105 135 105 120 105 105 120 105 120 120 180 120 180 105 195 105 195 135 240 195 240 255 225 273
Polygon -16777216 false false 81 165 74 165 44 150 44 120 59 90 104 75 194 75 239 90 254 120 254 150 218 167 194 135 194 105 179 105 179 120 119 120 119 105 104 105 104 135 81 166 78 165
Rectangle -16777216 false false 120 165 135 180
Rectangle -16777216 false false 165 165 180 180
Rectangle -16777216 false false 142 165 157 180
Rectangle -16777216 false false 165 188 180 203
Rectangle -16777216 false false 142 188 157 203
Rectangle -16777216 false false 120 188 135 203
Rectangle -16777216 false false 120 210 135 225
Rectangle -16777216 false false 142 210 157 225
Rectangle -16777216 false false 165 210 180 225
Rectangle -16777216 false false 120 233 135 248
Rectangle -16777216 false false 142 233 157 248
Rectangle -16777216 false false 165 233 180 248

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
NetLogo 5.2.0
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
