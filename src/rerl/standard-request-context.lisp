;;;; -*- lisp -*-

(in-package :it.bese.ucw.core)

;;;; ** STANDARD-REQUEST-CONTEXT

(defmethod context.window-component ((context request-context))
  (frame.window-component (context.current-frame context)))

(defmethod (setf context.window-component) ((component component) (context request-context))
  (setf (frame.window-component (context.current-frame context))
        component))

(defmethod action-request-p ((context standard-request-context))
  (let ((action-id (find-action-id context)))
    (values (not (null action-id)) action-id)))

(defmethod find-session-id ((context standard-request-context))
  "Returns the value of the GET or POST parameter named +session-parameter-name+"
  (get-parameter (context.request context) +session-parameter-name+))

(defmethod find-frame-id ((context standard-request-context))
  (get-parameter (context.request context) +frame-parameter-name+))

(defmethod find-action-id ((context standard-request-context))
  (get-parameter (context.request context) +action-parameter-name+))

(defmethod find-action-invocation-id ((context standard-request-context))
  (get-parameter (context.request context) +action-invocation-parameter-name+))

(defmethod clear-context ((context standard-request-context))
  "Undos (as much as possible) everything that's happened to CONTEXT."
  (clear-response (context.response context))
  context)

(defun query-path-sans-prefix (context)
  "Returns the part of the context's request's query-path after
  the context's application's url-prefix. NB: The returned value
  shares structure with the query-path. NB: We assume the proper
  application has already been placed in CONTEXT."
  (make-displaced-array (query-path (context.request context))
                        (length (application.url-prefix (context.application context)))))

(defmethod send-response :around ((response response))
  (when (response-managed-p response)
    (call-next-method)))

;;;; *** DUMMY-REQUEST-CONTEXT

;;;; This context serves as a testing/debugging aid. It allows you to
;;;; create and call components from the repl.

(defclass dummy-request-context (standard-request-context)
  ())

(defclass dummy-request (httpd-request)
  ((query-path :initform "/DUMMY/index.ucw" :initarg :query-path)))

(defclass dummy-response (httpd-response)
  ((network-stream :accessor network-stream :initarg :network-stream))
  (:default-initargs :network-stream *trace-output*))

(defun make-dummy-context (&optional (application  *default-application*))
  (with-lock-held-on-application application
    (let* ((*context* (make-request-context application
					    (make-instance 'dummy-request)
					    (make-instance 'dummy-response)))
	   (session (make-new-session application))
	   (frame (make-new-frame nil session)))
      (setf (session.current-frame session) frame
	    (context.session *context*) session)
      *context*)))

(defcomponent dummy-root-component (window-component)
  ())

(defmethod render ((comp dummy-root-component))
  (<:as-html "DUMMY COMPONENT"))

(defmacro with-dummy-context ((&key (render t)
                                    (action t)
                                    application)
                              &body body)
  `(let* ((*context* (make-dummy-context (or ,application
                                             *default-application*
                                             (make-instance 'standard-application
                                                            :url-prefix "/DUMMY/"))))
          (self (make-instance 'dummy-root-component
                               :place (make-place
                                       (context.window-component *context*)))))
     (setf (context.window-component *context*) self)
     (multiple-value-prog1
         ,(if action
              `(with-call/cc ,@body)
              `(progn ,@body))
       (when ,render
         (render (context.window-component *context*))
         (close-request (context.request *context*))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Copyright (c) 2003-2005 Edward Marco Baringer
;;; All rights reserved. 
;;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are
;;; met:
;;; 
;;;  - Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 
;;;  - Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;; 
;;;  - Neither the name of Edward Marco Baringer, nor BESE, nor the names
;;;    of its contributors may be used to endorse or promote products
;;;    derived from this software without specific prior written permission.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;; A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
;;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
