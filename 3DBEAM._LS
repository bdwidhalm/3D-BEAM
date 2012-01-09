;;*************************3DBEAM.LSP***************************;;
;;								;;
;;		DRAW BEAMS IN 3D				;;
;;								;;
;;		by: Brian D. Widhalm				;;
;;			August 22, 2008				;;
;;								;;
;;								;;
;;								;;
;;	This program will draw W-shape beams in 3D.  User will	;;
;; select beam size from dialog box, then choose two points(X,Y);;
;; and give elevations(Z).  					;;
;;								;;
;;								;;
;;								;;
;;								;;
;;								;;
;;**************************************************************;;

(defun C:3DBEAM ()

  (if (= elev nil)
    (setq elev 0.0)
    )
  (setq osnapback (getvar "osmode"))
  (setq layerback (getvar "clayer"))
  (setq dimstback (getvar "dimstyle"))
  (command "plinewid" 0 "")
  (setq lineadd "Choose Beam")
  (setq poplist "")
  (setq linenumber 0)
  (setq beamfile (open "c:/programing/BEAMFILE.txt" "r"))
  (setq stopnumber (atoi (read-line beamfile)))
  (setq ang0 0.00)		;; 0 degree radians
  (setq ang45 (* pi 0.25))	;; 45 degree radians
  (setq ang90 (* pi 0.50))	;; 90 degree radians
  (setq ang135 (* pi 0.75))	;; 135 degree radians
  (setq ang180 (* pi 1.00))	;; 180 degree radians
  (setq ang270 (* pi 1.50))	;; 270 degree radians
  (setq ang315 (* pi 1.75))	;; 315 degree radians



  (setq dcl_id (load_dialog "C:/programing/3DBEAM.DCL"))
  	 (if (not (new_dialog "D3BEAM" dcl_id))
    	     (exit)
    	     )

  (action_tile "sloped" "(mode_tile \"reference\" (atoi $value))")  ;;Turns reference off when sloped selected
  (action_tile "flat" "(mode_tile \"reference\" (- (atoi $value) 1))")  ;;Turns reference on when flat selected
  (setq elevstr (rtos elev 4 4))
  (set_tile "elev" elevstr)
  
  
  	 (action_tile "accept"
    	   (strcat "(progn (setq beam (atof (get_tile \"beam\")))"
		   "(setq elevstr (get_tile\"elev\"))"
		   "(setq bos (atof (get_tile\"BOS\")))"
		   "(setq tos (atof (get_tile\"TOS\")))"
		   "(setq flat (atof (get_tile\"flat\")))"
		   "(setq sloped (atof (get_tile\"sloped\")))"
	      	   "(done_dialog))"
      	     )
    	   )

  (action_tile "cancel"
    (strcat "(progn (done_dialog 0)"
	    "(exit))"
    )
  )
  
  (start_list "beam")
  (while (< linenumber stopnumber)
    (add_list lineadd)
    (setq lineadd (read-line beamfile))
    (setq linenumber (1+ linenumber))
    )
  (end_list)
  (start_dialog)  
  (unload_dialog dcl_id)
  (close beamfile)
  (setq beamdetail (open "c:/programing/BEAMDETAIL.txt" "r"))
  (setq count 0)
    (while (< count beam)
    (setq detailstring (read-line beamdetail))
    (setq count (1+ count))
    )
  (close beamdetail)
  (setq detailstringx (vl-string-subst "X" "\t" detailstring))
  (setq detailstringxy (vl-string-subst "Y" "\t" detailstringx))
  (setq detailstringxyz (vl-string-subst "Z" "\t" detailstringxy))
  
  (setq depthend (vl-string-search "X" detailstringxyz))
  (setq depthstring (substr detailstringxyz 1 depthend))
  
  (setq detailstringyz (vl-string-left-trim depthstring detailstringxyz))
  (setq detailstringyz (vl-string-left-trim "X" detailstringyz))
  (setq flwidthend (vl-string-search "Y" detailstringyz))
  (setq flwidthstring (substr detailstringyz 1 flwidthend))
  (setq trim (strcat flwidthstring "Y"))
  
  (setq detailstringz (vl-string-left-trim flwidthstring detailstringyz))
  (setq detailstringz (vl-string-left-trim "Y" detailstringz))
  (setq flthickend (vl-string-search "Z" detailstringz))
  (setq flthickstring (substr detailstringz 1 flthickend))
  (setq trim (strcat flthickstring "Z"))
  
  (setq webthickstring (vl-string-left-trim flthickstring detailstringz))
  (setq webthickstring (vl-string-left-trim "Z" webthickstring))

  (setq feetloc (vl-string-search "'" elevstr))
  (setq feetstring (substr elevstr 1 feetloc))
  (setq inchelevstr (vl-string-left-trim feetstring elevstr))
  (setq inchelevstr (vl-string-left-trim "'" inchelevstr))
  (setq inchloc (vl-string-search "\"" inchelevstr))
  (setq inchstring (substr inchelevstr 1 inchloc))

  (setq feet (atof feetstring))
  (setq inch (atof inchstring))
  (setq elev (+ (* feet 12) inch))

  (setq depth (atof depthstring))
  (setq flwidth (atof flwidthstring))
  (setq flthick (atof flthickstring))
  (setq webthick (atof webthickstring))
  (setq offsetdist (/ flwidth 2))
  (setq underfldist (/ (- flwidth webthick) 2))
  (setq webindist (- depth (* flthick 2)))

  (if (= tos 1)
    (setq boselev1 (- elev depth))	;;Adjusts elev to B.O.S. which is what the program draws from
    )
  (if (= tos 1)
    (setq boselev2 (- elev depth))	;;Adjusts elev to B.O.S. which is what the program draws from
    )
  

  (setq loop 0)
  (while (= loop 0)
    
  (setq insertpt1 (getpoint "\n\nSelect Start Point for the Beam (@ center-line):"))
  (if (= sloped 1)
    (setq elev1 (getdist "\n\nEnter Elevation:"))
    )
  (if (= sloped 1)
    (progn
      (setq tos 0)
      (setq bos 0)
      (initget 1 "TOS BOS")
      (setq ref (getkword "Top or Bottom of steel (T or B)?"))
      (if (= ref "TOS")
	(setq tos 1)
	)
      (if (= ref "BOS")
	(setq bos 1)
	)
      )
    )
  (setq insertpt2 (getpoint insertpt1 "\n\nSelect Second Point for the Beam (@ center-line):"))
  (if (= tos 1)
    (setq promp2 "\n\nEnter Top of Steel Elevation:")
    )
  (if (= bos 1)
    (setq promp2 "\n\nEnter Bottom of Steel Elevation:")
    )
  (if (= sloped 1)
    (setq elev2 (getdist promp2))
    )
  (setq slpdeg (angle insertpt1 insertpt2))

  (if (= sloped 1)
    (progn
      (if (= tos 1)
	(progn
	  (setq boselev1 (- elev1 depth))
	  (setq boselev2 (- elev2 depth))
	  )
	)
      (if (= bos 1)
	(progn
	  (setq boselev1 elev1)
	  (setq boselev2 elev2)
	  )
	)
      )
    )

  (setq insertpt1z (list (car insertpt1) (cadr insertpt1) boselev1))
  (setq insertpt2z (list (car insertpt2) (cadr insertpt2) boselev2))
  
  ;;Redifing angles if beam at angle
  (setq slpd0 (+ ang0 slpdeg))
  (setq slpd90 (+ ang90 slpdeg))
  (setq slpd180 (+ ang180 slpdeg))
  (setq slpd270 (+ ang270 slpdeg))
  (setq startpt (polar insertpt1z slpd90 offsetdist))
  (setq pt12 (polar startpt slpd270 flwidth))
  (setq pt2 (list (car startpt) (cadr startpt) (+ boselev1 flthick)))
  (setq pt3 (polar pt2 slpd270 underfldist))
  (setq pt10 (polar pt2 slpd270 (+ underfldist webthick)))
  (setq pt11 (polar pt2 slpd270 flwidth))
  
  (setq pt5 (list (car startpt) (cadr startpt) (+ boselev1 (+ flthick webindist))))
  (setq pt4 (polar pt5 slpd270 underfldist))
  (setq pt9 (polar pt5 slpd270 (+ underfldist webthick)))
  (setq pt8 (polar pt5 slpd270 flwidth))
  
  (setq pt6 (list (car startpt) (cadr startpt) (+ boselev1 depth)))
  (setq pt7 (polar pt6 slpd270 flwidth))

  (setq midpt (polar insertpt1z slpd0 (/ (distance insertpt1z insertpt2z) 2)))
  
  (setq dist (distance insertpt1z insertpt2z))
    (setq pathpt (polar insertpt1z slpd0 6))

  (setq zoom1 (polar startpt ang135 12))
  (setq zoom2 (polar startpt ang315 12))
  

    (setvar "osmode" 16639)
    (command "3dpoly" startpt pt2 pt3 pt4 pt5 pt6 pt7 pt8 pt9 pt10 pt11 pt12 "c" "")
    (command "zoom" "w" zoom1 zoom2)
    (command "line" insertpt1z insertpt2z "")
    (command "extrude" startpt "" "P" pathpt)
    (command "zoom" "p")
    (setvar "osmode" osnapback)
    )
  

  )