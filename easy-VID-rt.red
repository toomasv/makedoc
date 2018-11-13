Red [
	Title: "VID Tutorial"
	Author: "Carl Sassenrath"
	Date: 1-Oct-2000
	Redaptor: "Toomas Vooglaid"
	Redate: 12-Nov-2018
	Purpose: {Adaptation of original REBOL easy-VID (http://www.rebol.com/view/reb/easyvid.r) to Red with multi-slot rich text}
]
context [
	Redate: 12-Nov-2018
	unless attempt [rebolized?] [do %rebolize.red]

	content: read %easy-VID-rt.txt

	rt: make face! [type: 'rich-text size: 480x460 line-spacing: 15]
	text-size: func [text][
		rt/text: text
		size-text rt
	]

	rt-ops: [#"*" <b> #"/" <i> #"_" <u>] 
	inside-b?: inside-i?: inside-u?: no 
	special: charset "*_/\{"
	rt-rule: [(inside?: no)
		collect some [
			#"\" keep copy skip
		|	[
				#"*" keep (also either inside-b? [</b>][<b>] inside-b?: not inside-b?) 
			|	#"/" keep (also either inside-i? [</i>][<i>] inside-i?: not inside-i?) 
			|	#"_" keep (also either inside-u? [</u>][<u>] inside-u?: not inside-u?)
			|	"{#}" keep (</bg>)
			|	"{#" copy bg to "#}" keep (<bg>) keep (to-word bg) 2 skip 
			;|	"{}" keep (/f)
			|	#"{" copy clr to #"}" keep (to-word clr) skip
			] 
		|	newline keep (" ")
		|	keep copy x to [special | newline | end]
		] 
	]
	
	page-size: 500x480
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
			append/only layouts layo: copy []
			blk: copy [<font> 16 </font>]
			insert at blk 3 text
			rtb: rtd-layout blk 
			rtb/size/x: 460
			repend layo ['text 10x5 rtb]
			sz: size-text rtb
			pos-y: 5 + sz/y + 10
		) newline
	]
	subsect: [text-line (
		blk: copy [<font> 12 </font>] 
		insert at blk 3 text
		rtb: rtd-layout blk
		rtb/size/x: 460
		repend layo ['text as-pair 10 pos-y rtb]
		sz: size-text rtb
		pos-y: pos-y + sz/y + 10
	)]

	;emit: func ['style data] [repend layo [style data]]

	emit-para: func [data][ 
		remove back tail data
		blk: parse data rt-rule
		if " " = first blk [remove blk]
		rtb: rtd-layout blk
		rtb/size/x: 460
		repend layo ['text as-pair 10 pos-y rtb]
		sz: size-text rtb
		pos-y: pos-y + sz/y + 10
	]

	emit-code: func [code] [
		remove back tail code
		blk: reduce [<b> code </b>] 
		rtb: rtd-layout blk
		rtb/size/x: 480
		append rtb/data reduce [as-pair 1 length? rtb/text "Consolas"]
		sz: size-text rtb
		repend layo ['fill-pen silver 'box pos: as-pair 10 pos-y as-pair 480 pos/y + sz/y + 14 'fill-pen black]
		repend layo ['text as-pair 15 pos-y + 7 rtb]
		pos-y: pos-y + sz/y + 27
	]

	emit-note: func [code] [
		remove back tail code
		blk: parse code rt-rule
		if " " = first blk [remove blk]
		append insert blk [b][/b]
		rtb: rtd-layout blk
		append rtb/data reduce [as-pair 1 length? rtb/text 150.0.0]
		rtb/size/x: 460
		repend layo ['text as-pair 10 pos-y rtb]
		sz: size-text rtb
		pos-y: pos-y + sz/y + 10

	]

	show-example: func [code][
		if xview [xy: xview/offset - 3x26  unview/only xview]
		xcode: load/all code;face/text
		if not block? xcode [xcode: reduce [xcode]] 
		either here: select xcode either 'layout = second xcode ['layout]['view][
			xcode: here
		][
			unless find [title backdrop size] first xcode [insert xcode 'below]
		]
		xview: view/no-wait/options compose xcode [offset: xy]  
	]

	parse detab/size content 3 rules  

	show-page: func [i /local blk][
		i: max 1 min length? sections i
		if blk: pick layouts this-page: i [
			tl/selected: this-page
			f-box/draw: blk ;show f-box
		]
	]

	main: layout compose [
		title "VID: Visual Interface Dialect"
		on-key [
			switch event/key [
				up left [show-page this-page];[show-page this-page - 1]
				down right [show-page this-page];[show-page this-page + 1]
				home [show-page 1]
				end [show-page length? sections]
			] 
		]
		h4 title-line bold return
		tl: text-list 160x480 bold select 1 white black data sections on-change [
			show-page face/selected
		]
		panel page-size [
			origin 0x0
			f-box: rich-text page-size white draw []
			on-down [parse face/draw [some [
				bx: 'box pair! pair! if (within? event/offset bx/2 bx/3 - bx/2) (
					show-example select first find bx object! 'text
				)
			|	skip
			]]]
			at 0x0 page-border: box with [
				size: page-size 
				draw: compose [pen gray box 0x0 (page-size - 1)]
			]
		]
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
]
