;; -*- lisp -*-

(in-package :ucw-standard)

;;;; redirect-component has mostly been obsoleted by the :through-redirect t parameter of register-action:
;;;;
;;;; (<ucw:submit :action (register-action (:through-redirect t :with-call/cc t)
;;;;                        (ok reader (number-string reader)))
;;;;              :value "Ok")

;;;; ** Redirect

(defclass redirect-component ()
  ((target :accessor target :initarg :target))
  (:metaclass standard-component-class)
  (:documentation "Send a client redirect.

This component, which must be used as a window-component,
redirects the client to the url specified in the target slot. A
302 (as opposed to 303) response code is sent to ensure
compatability with older browsers.

The redirect component never answers."))

(defmethod render ((redirect redirect-component))
  (unless (eq redirect (context.window-component *context*))
    (error "Redirect component can only be used as a root component."))
  (ucw-core::send-redirect (target redirect) (context.response *context*)))

;; Copyright (c) 2003-2005 Edward Marco Baringer
;; All rights reserved. 
;; 
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;; 
;;  - Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 
;;  - Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;; 
;;  - Neither the name of Edward Marco Baringer, nor BESE, nor the names
;;    of its contributors may be used to endorse or promote products
;;    derived from this software without specific prior written permission.
;; 
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
