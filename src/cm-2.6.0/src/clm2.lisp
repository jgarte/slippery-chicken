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

;;; generated by scheme->cltl from clm2.scm on 23-Mar-2005 12:21:23

(in-package :cm)

(defmethod open-io ((io clm-audio-stream) dir &rest args)
  args
  (if (eq dir ':output)
      (let ((inits (io-handler-args io))
            (ftype (filename-type (object-name io)))
            (autype nil)
            (fmat nil))
        (cond ((string-equal ftype "snd")
               (setf autype mus-next)
               (setf fmat mus-bshort))
              ((string-equal ftype "aiff")
               (setf autype mus-aifc)
               (setf fmat mus-bshort))
              ((string-equal ftype "wav")
               (setf autype mus-riff)
               (setf fmat mus-lshort)))
        (unless (getf inits ':type)
          (push autype inits)
          (push ':type inits))
        (unless (getf inits ':data-format)
          (push fmat inits)
          (push ':data-format inits))
        (setf (io-open io)
              (apply #'init-with-sound
                     ':output
                     (file-output-filename io)
                     inits))
        (unless (null (audio-file-output-trace io))
          (apply #'tell-snd (file-output-filename io) inits))
        io)
      (call-next-method)))

(defmethod close-io ((io clm-audio-stream) &rest mode)
  (let ((wsd (io-open io)) (old *clm-with-sound-depth*))
    (setf *clm-with-sound-depth* 1)
    (when (eq (slot-value io 'output-trace) t) (format t "Done!~&"))
    (when (and (consp mode) (car mode)) (setf (wsdat-play wsd) nil))
    (finish-with-sound wsd)
    (setf (io-open io) nil)
    (setf *clm-with-sound-depth* old)))

(defun tell-snd (file &key reverb decay-time reverb-data
                 (channels *clm-channels*) (srate *clm-srate*)
                 &allow-other-keys)
  (format t "~%; File: ~s" file)
  (format t "~%; Channels: ~s" channels)
  (format t "~%; Srate: ~s" srate)
  (format t "~%; Reverb: ~a~%" (or reverb "None"))
  (if decay-time (format t "decay time: ~s%" decay-time))
  (if reverb-data (format t "reverb data: ~s~%" reverb-data))
  (values))

(defun definstrument-hook (name args)
  (let* ((opts (if (consp name) (cdr name) (list)))
         (tpar (getf opts ':time-parameter)))
    (formals->defobject
     (list* (if (consp opts) (first name) name) args) tpar)))

(defparameter *definstrument-hook* (function definstrument-hook))
