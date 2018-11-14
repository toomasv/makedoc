;; =================================================
;; Script: texthtml.r
;; downloaded from: www.REBOL.org
;; on: 7-Nov-2018
;; at: 19:42:26.516108 UTC
;; owner: carl [script library member who can update
;; this script]
;; =================================================
Red [
    Title: "Text to HTML Converter"
    Date: 29-Feb-2000
	Red-version: 7-Nov-2018
    File: %text2html.red
    Author: "Carl Sassenrath"
	Reditor: "Toomas Vooglaid"
    Usage: {
        The first line of the text file is the title of the
        document.  All lines that are flush left will be
        treated as paragraphs.  A blank line will separate
        paragraphs. Indented lines are examples. They are
        indented and printed in monospaced bold font.
        Sections and sub-sections of a document are separated
        with a line that begins with === or --- and the text
        that follows them is shown in a special font.
    }
    Purpose: {A useful doc formatting language. Converts text to HTML with titles, sections, sub-sections, and code. Is used to create all REBOL How-to documents.}
    History: [orig 12-Oct-1999 to-red 7-Nov-2018]
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [markup text-processing file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]
;;; added by toomasv 7-Nov-2018 

detab: func [
	{Converts tabs in a string to spaces. (tab size 4)}
	str [string!] 
	/size number [integer!]
][
	number: any [number 4] 
	replace/all str #"^-" append/dup "" #" " number
]

;;;;;;;;;;;;;;

text2html: make object! [
    html: make string! 10000
    emit: func [data] [append html reduce data]

    space: charset " ^-"
    chars: complement charset " ^-^/"

    font: <font face="arial,helvetica">

    escape-html: func [
        "Format a code example" code
    ][
        replace/all code "&" "&amp;"
        replace/all code "<" "&lt;"
        replace/all code ">" "&gt;"
        insert code [<b><pre>]
        append code reduce [</pre></b> newline]
    ]

    ;--- Text Format Language:
    rules: [title some parts done]
    title: [text-line 
        (emit [<html><meta charset="UTF-8"><title>text</title><body>font<h2>text</h2></font><p>])]
    parts: [newline | "===" section | "---" subsect | "###" to end |
         example | paragraph]
    section: [text-line
        (emit [<p>font<h3>trim text</h3></font><p>]) newline]
    subsect: [text-line
        (emit [<p>font<i><h4>trim text</h4></i></font><p>]) newline]
    example: [copy code some [indented | some newline indented]
        (emit escape-html code)]
    paragraph: [copy para some [chars thru newline] (emit [para<p>])]
    done: [(emit [</body></html>])]
    text-line: [copy text thru newline]
    indented: [some space thru newline]
    convert: func [data] [parse detab data rules  html]  ; 7-Nov-2018 toomasv removed /all
]

file: to-file ask "Filename? "
if not find file "." [append file ".txt"]
data: text2html/convert read file
write head change/part find file "." ".html" tail file data  ; toomasv added /part to change
;quit
