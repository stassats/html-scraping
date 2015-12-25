(asdf:defsystem #:html-scraping
  :name "html-scraping"
  :serial t
  :depends-on (cl-ppcre cxml-stp closure-html)
  :components ((:file "packages")
               (:file "html-scraping")))
