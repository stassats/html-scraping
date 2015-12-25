(defpackage :html-scraping
  (:use :cl)
  (:export
   #:parse-html
   #:elementp
   #:find-element-if
   #:string-value
   #:nth-previous-sibling
   #:nth-next-sibling
   #:nth-parent
   #:find-string-values
   #:find-string-value
   #:find-attribute
   #:find-attributes
   #:textp
   #:local-name
   #:find-child
   #:find-child-value
   #:find-span
   #:find-next-sibling
   #:parse-xml
   #:find-element
   #:find-children
   #:find-child-path))
