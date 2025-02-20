;;; **********************************************************************
;;; Copyright (C) 2003 Heinrich Taube (taube@uiuc.edu) 
;;; This program is free software; you can redistribute it and
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;; **********************************************************************

;;; generated by scheme->cltl from player.scm on 14-Jan-2014 12:09:01

(in-package :cm)

(progn
 (defclass player-stream (midishare-stream)
           ((seq :accessor player-stream-seq)
            (track :initform nil :accessor player-stream-track)
            (mode :initform :replace :accessor player-stream-mode
             :initarg :seq-mode)
            (play :initform t :accessor player-stream-play :initarg
                  :play)
            (tempo :initform 60.0 :accessor player-stream-tempo
             :initarg :tempo))
           #+metaclasses  (:metaclass io-class))
 (defparameter <player-stream> (find-class 'player-stream))
 (finalize-class <player-stream>)
 (setf (io-class-mime-type <player-stream>) "audio/x-player")
 (setf (io-class-file-types <player-stream>) '("*.mp"))
 (values))

(defmethod open-midishare-client ((obj player-stream) name)
  (midishare:openplayer name))

(defmethod close-midishare-client ((obj player-stream))
  (midishare:closeplayer (midishare-stream-refnum obj)))

(defun player-stream-current-track (obj)
  (fourth (event-stream-stream obj)))

(defun player-stream-current-track-set! (obj track)
  (setf (elt (event-stream-stream obj) 3) track))

(defmethod initialize-io ((obj player-stream))
  (channel-tuning-init obj)
  (let ((trk (or (player-stream-track obj) 1)))
    (case (player-stream-mode obj)
      ((:replace replace) (player-stream-current-track-set! obj trk))
      ((:add add)
       (unless (player-stream-current-track obj)
         (player-stream-current-track-set! obj trk)))
      (t
       (error "Player mode ~s not ~S, :replace, or :add." false
              (player-stream-mode obj))))
    (setf (player-stream-seq obj) (midinewseq))
    obj))

(defmethod deinitialize-io :after ((obj player-stream))
  (let ((refn (midishare-stream-refnum obj))
        (mode (player-stream-mode obj))
        (trkn (player-stream-current-track obj))
        (data (player-stream-seq obj))
        (play (player-stream-play obj)))
    (case mode
      ((:replace replace)
       (midishare:setalltrackplayer refn data 500))
      ((:add add)
       (midishare:settrackplayer refn trkn data)
       (player-stream-current-track-set! obj (+ trkn 1)))
      ((nil) (setf play nil))
      (t (error "Player mode ~s not :replace or :add." mode)))
    (when play (player-play obj))
    obj))

(defmethod write-event ((obj midi) (stream player-stream) scoretime)
  (let* ((seq (player-stream-seq stream))
         (trk (player-stream-current-track stream))
         (beg (floor (* scoretime 1000)))
         (dur (floor (* (midi-duration obj) 1000)))
         (key (midi-keynum obj))
         (amp (midi-amplitude obj))
         (loc
          (logical-channel (midi-channel obj)
           (midi-stream-channel-map stream)))
         (prt (car loc))
         (chn (cadr loc))
         (evt nil))
    (cond ((and (integerp amp) (<= 0 amp 127)) nil)
          ((and (floatp amp) (<= 0.0 amp 1.0))
           (setf amp (floor (* amp 127))))
          (t
           (error "Can't convert amplitude ~s to midi velocity."
                  amp)))
    (ensure-microtuning key chn stream)
    (setf evt
            (midishare:new typenote :port prt :chan chn :pitch key
                           :vel amp :dur dur))
    (midishare:ref evt trk)
    (midishare:date evt beg)
    (midishare:midiaddseq seq evt)
    (values)))

(defmethod player-play ((obj player-stream))
  (player-set-sync obj kexternalsync)
  (player-set-tempo obj (player-stream-tempo obj))
  (player-start obj)
  obj)

(defmethod player-set-sync ((obj player-stream) sync)
  (if (or (eq sync kinternalsync) (eq sync kclocksync)
          (eq sync ksmptesync) (eq sync kexternalsync))
      (let ((ref (midishare-stream-refnum obj)))
        (midishare:setsynchroinplayer ref kexternalsync))
      (error "~s not a player sync value." sync))
  (values))

(defun bpm->usec (bpm) (floor (* (/ 60 bpm) 1000000)))

(defmethod player-set-tempo ((obj player-stream) bpm)
  (let ((ref (midishare-stream-refnum obj)))
    (if ref
        (let ((usec (bpm->usec bpm)))
          (setf (player-stream-tempo obj) bpm)
          (midishare:settempoplayer ref usec))
        (error "~s not open." obj))
    obj))

(defmethod player-start ((obj player-stream))
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:startplayer ref)
    (midishare:settempoplayer ref
                              (bpm->usec (player-stream-tempo obj)))
    obj))

(defmethod player-stop ((obj player-stream))
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:stopplayer ref)
    obj))

(defmethod player-pause ((obj player-stream))
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:pauseplayer ref)
    obj))

(defmethod player-cont ((obj player-stream))
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:contplayer ref)
    (midishare:settempoplayer ref
                              (bpm->usec (player-stream-tempo obj)))
    obj))

(defmethod player-mute ((obj player-stream) track)
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:setparamplayer ref track kmute kmuteon)
    obj))

(defmethod player-unmute ((obj player-stream) track)
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:setparamplayer ref track kmute kmuteoff)
    obj))

(defmethod player-solo ((obj player-stream) track)
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:setparamplayer ref track ksolo ksoloon)
    obj))

(defmethod player-unsolo ((obj player-stream) track)
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (midishare:setparamplayer ref track ksolo ksolooff)
    obj))

(defmethod player-load-midifile ((obj player-stream) file)
  (let ((seq (midinewseq)) (info (midinewmidifileinfos)))
    (midishare:midifileload file seq info)
    (setf (player-stream-seq obj) seq)
    obj))

(defmethod player-save-midifile ((obj player-stream) file)
  (let ((ref (midishare-stream-refnum obj)))
    (unless ref (error "~s not open." obj))
    (let* ((info (midishare:midinewmidifileinfos))
           (seq (midishare:getalltrackplayer ref)))
      (midishare:mf-format info 1)
      (midishare:mf-timedef info ticksperquarternote)
      (midishare:mf-clicks info 500)
      (midishare:midifilesave file seq info)
      (midishare:midifreeseq seq)
      (midishare:midifreemidifileinfos info)
      obj)))
