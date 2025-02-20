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

;;; generated by scheme->cltl from io.scm on 23-Mar-2005 12:21:21

(in-package :cm)

(progn (defclass event-stream (container)
         ((time :accessor object-time)
          (open :initform nil :accessor io-open)
          (stream :initform nil :initarg :stream :accessor
           event-stream-stream)
          (direction :initform nil :accessor io-direction)
          (version :initform 0 :accessor file-version :initarg
           :version)
          (elt-type :initform :char :accessor file-elt-type :initarg
           :elt-type)))
       (defparameter <event-stream> (find-class 'event-stream))
       (finalize-class <event-stream>)
       (values))

(defun io-classes () (class-subclasses <event-stream>))

(defun io-filename (io) (object-name io))

(defun file-versions? (stream)
  (io-class-file-versions (class-of stream)))

(defun io-stream-classes ()
  (do ((l (io-classes) (cdr l)) (r '()))
      ((null l) (reverse r))
    (let ((h (io-class-file-types (car l))))
      (if h (push (car l) r)))))

(defun filename->io-class (path)
  (let ((name (filename-name path)) (type (filename-type path)))
    (if type
        (flet ((matchone (key name type)
                 (let ((nam (filename-name key))
                       (ext (filename-type key)))
                   (when (or (eq nam :wild) (string= nam "*"))
                     (setf nam nil))
                   (if nam
                       (if (string= nam name)
                           (if (string= ext type) t nil)
                           nil)
                       (if (string= ext type) t nil)))))
          (do ((l (io-stream-classes) (cdr l)) (c nil))
              ((or (null l) c)
               (or c (error "No file or port class for ~s." path)))
            (do ((x (io-class-file-types (car l)) (cdr x)))
                ((or (null x) c) c)
              (if (matchone (car x) name type) (setf c (car l))))))
        (error "Missing .ext in file or port specification: ~s"
               path))))

(defmethod io-handler-args? ((io event-stream)) io nil)

(defmethod set-io-handler-args! ((io event-stream) args) args nil)

(defmethod io-handler-args ((io event-stream)) io nil)

(defmethod init-io (io &rest inits) inits io)

(defmethod init-io ((string string) &rest inits)
  (let ((io (find-object string)))
    (if io
        (apply #'init-io io inits)
        (let ((class (filename->io-class string)))
          (if class
              (multiple-value-bind (init args)
                  (expand-inits class inits t t)
                (let ((n
                       (apply #'make-instance
                              class
                              ':name
                              string
                              init)))
                  (if (not (null args))
                      (if (io-handler-args? n)
                          (set-io-handler-args! n args)
                          (error "Not initializations for ~s: ~s."
                                 (class-name class)
                                 args)))
                  n))
              (error "~s is not a valid port or file name."
                     string))))))

(defmethod init-io ((io event-stream) &rest inits)
  (unless (null inits)
    (multiple-value-bind (init args)
        (expand-inits (class-of io) inits nil t)
      (dopairs (s v init) (setf (slot-value io s) v))
      (if (not (null args))
          (if (io-handler-args? io)
              (set-io-handler-args! io args)
              (error "Not initializations for ~s: ~s."
                     (class-name (class-of io))
                     args)))))
  io)

(defun file-output-filename (file)
  (let ((v (if (file-versions? file) (file-version file) nil))
        (n (object-name file)))
    (if (integerp v)
        (concatenate 'string
                     (or (filename-directory n) "")
                     (filename-name n)
                     "-"
                     (prin1-to-string v)
                     "."
                     (filename-type n))
        n)))

(defmethod open-io ((obj string) dir &rest args)
  (let ((io (apply #'init-io obj args)))
    (apply #'open-io io dir args)))

(defmethod open-io ((obj event-stream) dir &rest args)
  args
  (let ((file nil) (name nil))
    (if (eq dir :output)
        (if (event-stream-stream obj)
            (setf file (event-stream-stream obj))
            (let ((v
                   (if (file-versions? obj) (file-version obj) nil)))
              (if v
                  (setf (file-version obj)
                        (if (integerp v) (+ v 1) 1)))
              (setf name (file-output-filename obj))
              (if (probe-file name) (delete-file name))
              (setf file (open-file name dir (file-elt-type obj)))))
        (if (eq dir :input)
            (if (event-stream-stream obj)
                (setf file (event-stream-stream obj))
                (setf file
                      (open-file (object-name obj) dir
                       (file-elt-type obj))))
            (error "Direction not :input or :output: ~s" dir)))
    (setf (io-direction obj) dir)
    (setf (io-open obj) file)
    obj))

(defmethod open-io ((obj seq) dir &rest args)
  dir
  args
  (remove-subobjects obj)
  obj)

(defmethod close-io (io &rest mode) mode io)

(defmethod close-io ((io event-stream) &rest mode)
  mode
  (when (io-open io)
    (unless (event-stream-stream io)
      (close-file (io-open io) (io-direction io)))
    (setf (io-open io) nil))
  io)

(defmethod initialize-io (obj) obj)

(defmethod deinitialize-io (obj) obj)

(defun io-open? (io) (io-open io))

(defmacro with-open-io (args &body body)
  (let ((io (pop args))
        (path (pop args))
        (dir (pop args))
        (err? (gensym))
        (val (gensym)))
    `(let ((,io nil) (,err? ':error))
       (unwind-protect
           (progn (let ((,val nil))
                    (setf ,io (open-io ,path ,dir ,@args))
                    (initialize-io ,io)
                    (setf ,val (progn ,@body))
                    (setf ,err? nil)
                    (if ,err? nil ,val)))
         (when ,io (deinitialize-io ,io) (close-io ,io ,err?))))))

(defparameter *in* ())

(defparameter *out* ())

(defparameter *last-output-file* ())

(defun events (object to &rest args)
  (let ((ahead
         (if (and (consp args)
                  (or (consp (car args)) (numberp (car args))))
             (pop args)
             0))
        (err? ':error))
    (setf *out* nil)
    (when (oddp (length args))
      (error "Uneven initialization list: ~s." args))
    (unwind-protect
        (progn (flet ((getobj (x)
                        (if (not (null x))
                            (if (or (stringp x) (and x (symbolp x)))
                                (find-object x)
                                x)
                            (error "Not an object specification: ~s."
                                   x))))
                 (when to
                   (setf *out*
                         (open-io (apply #'init-io to args)
                          ':output))
                   (initialize-io *out*))
                 (schedule-events
                  (lambda (e s) (write-event e *out* s))
                  (if (consp object)
                      (mapcar #'getobj object)
                      (getobj object))
                  ahead)
                 (setf err? nil)))
      (when *out* (deinitialize-io *out*) (close-io *out* err?)))
    (if (or err? (not *out*))
        nil
        (if (typep *out* <event-stream>)
            (let ((path (file-output-filename *out*))
                  (args
                   (if (io-handler-args? *out*)
                       (io-handler-args *out*)
                       '()))
                  (hook (io-class-output-hook (class-of *out*))))
              (when hook (apply hook path args))
              path)
            *out*))))

(defmethod write-event (obj io time) obj io time)

(defmethod write-event (obj (io seq) time)
  (setf (object-time obj) time)
  (insert-object obj io))

(defmethod import-events ((file string) &rest args)
  (let ((io (init-io file))) (apply #'import-events io args)))
