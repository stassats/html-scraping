(in-package :html-scraping)

(defun parse-html (page)
  (chtml:parse page (stp:make-builder)))

(defun parse-xml (page)
  (cxml:parse page (stp:make-builder)))

(defun elementp (x)
  (typep x 'stp:element))

(defun textp (x)
  (typep x 'stp:text))

(defun local-name (x)
  (and (elementp x)
       (stp:local-name x)))

(defun find-element-if (function document &key (type 'stp:element))
  (stp:do-recursively (node document)
    (when (and (typep node type)
               (funcall function node))
      (return node))))

(defun find-child (local-name xml)
  (stp:find-child local-name xml
                  :key #'local-name
                  :test #'equal))

(defun find-child-value (local-name xml)
  (let ((child (find-child local-name xml)))
    (when child
      (stp:string-value child))))

(defun find-children (local-name xml)
  (stp:filter-children (lambda (child)
                         (equal (local-name child)
                                local-name)) xml))

(defun find-child-path (xml &rest local-names)
  (loop with (name . rest) = local-names
        for child in (find-children name xml)
        thereis (if rest
                    (apply #'find-child-path child rest)
                    (and (equal (local-name child) name)
                         child))))

(defun test-string (tester string)
  (etypecase tester
    (null t)
    (string (string= string tester))
    (function
     (ppcre:scan-to-strings tester string))))

(defun find-attributes (name value document)
  (stp:filter-recursively
   (lambda (node)
     (and (elementp node)
          (stp:with-attributes ((attr name)) node
            (and attr
                 (test-string value attr)))))
   document))

(defun find-attribute (name value document)
  (find-element-if
   (lambda (node)
     (stp:with-attributes ((attr name)) node
            (and attr
                 (test-string value attr))))
   document))

(defun find-string-value (local-name string-value document
                          &key (type 'stp:element))
  (find-element-if
   (lambda (node)
     (and (or (not local-name)
              (equal (stp:local-name node) local-name))
          (test-string string-value (stp:string-value node))))
   document
   :type type))

(defun find-string-values (local-name test document)
  (stp:filter-recursively
   (lambda (node)
     (and (elementp node)
          (equal (stp:local-name node) local-name)
          (test-string test (stp:string-value node))))
   document))

(defun nth-parent (n document)
  (loop repeat n
        for parent = (stp:parent document) then (stp:parent parent)
        finally (return parent)))

(defun nth-next-sibling (n document)
  (loop repeat n
        for sibling = (stp:next-sibling document)
        then (stp:next-sibling sibling)
        finally (return sibling)))

(defun nth-previous-sibling (n document)
  (loop repeat n
        for sibling = (stp:previous-sibling document)
        then (stp:previous-sibling sibling)
        finally (return sibling)))

(defun find-element (xml class &optional regex)
  (let ((regex (and regex
                    (ppcre:create-scanner regex))))
    (stp:find-recursively-if
     (lambda (child)
       (and (elementp child)
            (equal (stp:attribute-value child "class")
                   class)
            (or (not regex)
                (ppcre:scan regex (stp:string-value child)))))
     xml)))

(defun find-next-sibling (xml class)
  (loop for sibling = (stp:next-sibling xml)
        then (stp:next-sibling sibling)
        when (and (elementp sibling)
                  (equal (stp:attribute-value sibling "class")
                         class))
        return sibling))

(defun string-value (document)
  (and (typep document 'stp:node)
       (stp:string-value document)))
