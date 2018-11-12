Red [
	Title: "VID Tutorial"
	Author: "Carl Sassenrath"
	Date: 1-Oct-2000
	Redaptor: "Toomas Vooglaid"
	Redate: 10-Nov-2018
	Purpose: {Adaption of original REBOL easy-VID (http://www.rebol.com/view/reb/easyvid.r) to Red}
]

Redate: 10-Nov-2018
unless attempt [rebolized?] [do %rebolize.red]

content: read %easy-VID.txt

rt: make face! [type: 'rich-text size: 480x460 line-spacing: 15]
text-size: func [text][
	rt/text: text
	size-text rt
]

ferns: do load-thru http://www.rebol.com/view/reb/ferns.jpg
unless exists? %ferns.jpg [save %ferns.jpg ferns]

code: text: layo: xview: none
sections: make block! 50
layouts: make block! 50
space: charset " ^-"
chars: complement charset " ^-^/"

rules: [title some parts]

title: [text-line (title-line: text)]

parts: [
	  newline
	| "===" section
	| "---" subsect
	| "!" note
	| example
	| paragraph
]

text-line: [copy text to newline newline]
indented:  [some space thru newline]
paragraph: [copy para some [chars thru newline] (emit-para para)]
note: [copy para some [chars thru newline] (emit-note para)]
example: [
	copy code some [indented | some newline indented]
	(emit-code code)
]
section: [
	text-line (
		append sections text
		append/only layouts layo: copy page-template
		emit _h4 text 
	) newline
]
subsect: [text-line (emit _h5 text)] 

emit: func ['style data] [repend layo [style data]]

emit-para: func [data][ 
	remove back tail data
	clear rt/data
	rt/line-spacing: 15
	sz: text-size data
	sz/x: 400
	repend layo ['par sz data]
]

emit-code: func [code] [
	remove back tail code
	rt/data: reduce [as-pair 0 length? code 'bold system/view/fonts/fixed]
	rt/line-spacing: 15
	sz: text-size code
	sz/x: 480
	repend layo ['panel silver sz + 0x10 compose [origin 0x5 code (sz) (code) show-example]] 
]

emit-note: func [code] [
	remove back tail code
	rt/data: reduce [as-pair 0 length? code 'bold]
	rt/line-spacing: 15
	sz: 20x0 + text-size code
	repend layo ['tnt sz code]   
]

show-example: [
	if xview [xy: xview/offset  unview/only xview]
	xcode: load/all face/text
	if not block? xcode [xcode: reduce [xcode]] 
	either here: select xcode either 'layout = second xcode ['layout]['view][
		xcode: here
	][
		unless find [title backdrop size] first xcode [insert xcode 'below]
	]
	xview: view/no-wait/options compose xcode [offset: xy]  
]

page-template: [
	size 500x480
	backdrop white
	origin 8x8
	style code: text silver font-name font-fixed bold 
	style tnt: text white font [color: maroon] bold 
	style par: text white
	style _h4: h4 white
	style _h5: h5 white
	below
]

parse detab/size content 3 rules  

show-page: func [i /local blk][
	i: max 1 min length? sections i
	if blk: pick layouts this-page: i [
		tl/selected: this-page
		f-box/pane: layout/only/options blk [offset: 0x0] show f-box
	]
]

main: layout compose [
	title "VID: Visual Interface Dialect"
	on-key [switch event/key [
		up left [show-page this-page - 1]
		down right [show-page this-page + 1]
		home [show-page 1]
		end [show-page length? sections]
	] show tl]
	h4 title-line bold return
	tl: text-list 160x480 bold select 1 white black data sections on-change [
		show-page face/selected
	]
	f-box: panel 500x480 white
	pad -51x-30
	space 4x10
	button 20 "<" [show-page this-page - 1]
	button 20 ">" [show-page this-page + 1]
	pad -140x5
	text (form Redate)
	do [f-box/draw: compose [pen gray box 0x0 (f-box/size - 1)]]
]
view/no-wait main
show-page 1
xy: main/offset + either system/view/screens/1/size/x > 900 [
	main/size * 1x0 + 8x0][300x300]
do-events
