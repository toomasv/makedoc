Red [

]

rebolized?: true

exists-via?: :exists-thru?

read-via: :read-thru

reform: func [blk][form reduce blk]

confirm: func [
    "Confirms a user choice."
    question [series!] "Prompt to user"
    /with choices [string! block!]
    /local yes no
][
    question: form question
    if with [
        yes: "Yes"
        no: "No"
        if string? choices [yes: choices]
        if all [block? choices not empty? choices] [
            either tail? next choices [yes: choices/1] [set [yes no] choices]
        ]
        question: reduce [question yes no]
    ]
    request/confirm question
]
; print probe 
request: func [
    "Requests an answer to a simple question."
    str [string! block! object! none!]
    /offset xy
    /ok
    /only
    /confirm
    /type icon [word!] {Valid values are: alert, help (default), info, stop}
    /timeout time
    /local lay result msg y n c width f img rtn y-key n-key m
][
    rtn: func [value] [also result: value unview]
    icon: any [icon all [none? icon any [ok timeout] 'info] 'help]
    lay: either all [object? str in str 'type str/type = 'face] [str] [
        if none? str [str: "What is your choice?"]
        set [y n c] ["Yes" "No" "Cancel"]
        if confirm [c: none]
        if ok [y: "OK" n: c: none]
        if only [y: n: c: none]
        if block? str [
            str: reduce str
            set [str y n c] str
			foreach m [str y n c] [
				if all [found? get m not string? get m] [set m form get m]
            ]
        ]
        width: any [all [200 >= length? str 280] to-integer (length? str) - 200 / 50 * 20 + 280]
        img: switch/default :icon [
            info [%info.png]
            alert [%exclamation.png]
            stop [%stop.png]
        ] [%help.png]
        result: compose [
            origin 15x10
            image img
            pad 0x12
            msg: text bold (copy str) (as-pair width 30) return 
            pad 4x12
        ]
		y-key: pick "^My" found? ok
        n-key: pick "^[n" found? confirm
        ;append result pick [
        ;    [#"o" [rtn yes] #" " [rtn yes]]
        ;    [#"n" [rtn no] #"c" [rtn none]]
        ;    ;[key #"o" [rtn yes] key #" " [rtn yes]]
        ;    ;[key #"n" [rtn no] key #"c" [rtn none]]
        ;] found? ok
        if y [append result compose [button 60 (y) [rtn yes]]]
        if n [append result compose [button 60 (n) [rtn no]]]
        if c [append result compose [button 60 (c) [rtn none]]]
        layout result
    ]
    result: none
    either offset [inform/offset lay xy] [inform lay]
    result
]

inform: func [
    {Display an exclusive focus panel for alerts, dialogs, and requestors.}
    panel [object!]
    /offset where [pair!] "Offset of panel"
    /title ttl [string!] "Dialog window title"
][
    panel/text: copy any [ttl "Dialog"]
    panel/offset: either offset [where] [system/view/screens/1/size - panel/size / 2] 
    view/flags panel 'popup 
]

found?: func [
    "Returns TRUE if value is not NONE."
    value [any-type!]
][
    not none? :value
]

join: func [
    "Concatenates values."
    value [any-type!] "Base value"
    rest [any-type!] "Value or block of values"
][
    value: either series? :value [copy value] [form :value]
    repend value :rest
]

detab: function [
	{Converts tabs in a string to spaces. (tab size 4)}
	str [string!] 
	/size sz [integer!]
][
	sz: max 1 any [sz 2]
	buf: append/dup clear "    " #" " sz
	replace/all str #"^-" copy buf
]

forskip: func [
    "Evaluates a block for periodic values in a series."
    ;[throw catch]
    'word [word!] {Word set to each position in series and changed as a result}
    skip-num [integer!] "Number of values to skip each time"
    body [block!] "Block to evaluate each time"
    /local orig result
][
    if not positive? skip-num [throw make error! join [script invalid-arg] skip-num]
    if not any [
        series? get word
        ;port? get word
    ] [throw make error! {forskip/forall expected word argument to refer to a series or port!}]
    orig: get word
    while [any [not tail? get word (set word orig false)]] [
        set/any 'result do body
        set word skip get word skip-num
        get/any 'result
    ]
]