forward
global type w_snake from window
end type
type dw_1 from datawindow within w_snake
end type
type st_score from statictext within w_snake
end type
type cb_start from commandbutton within w_snake
end type
type st_info from statictext within w_snake
end type
end forward

global type w_snake from window
integer width = 3301
integer height = 2200
boolean titlebar = true
string title = "Snake"
boolean controlmenu = true
boolean minbox = true
long backcolor = 0
string icon = "AppIcon!"
boolean center = true
dw_1 dw_1
st_score st_score
cb_start cb_start
st_info st_info
end type
global w_snake w_snake

type variables
constant integer GW = 31
constant integer GH = 21
constant integer CELLW = 100
// cell codes inside dw column 'cells': 0=empty 1=body 2=head 9=food
long il_sx[], il_sy[]
long il_len
integer ii_dir  // 1=up 2=right 3=down 4=left
long il_fx, il_fy
long il_score
boolean ib_alive
boolean ib_running
boolean ib_intimer
end variables

forward prototypes
public subroutine wf_init_grid ()
public subroutine wf_reset ()
public subroutine wf_place_food ()
public subroutine wf_set_cell (long ax, long ay, string ac)
end prototypes

public subroutine wf_init_grid ();// create one persistent rectangle per column with visibility/color expressions bound to mid(cells, N, 1)
long i
string ls_cmd, ls_n
dw_1.setredraw(false)
for i = 1 to GW
	ls_n = string(i)
	ls_cmd = 'create rectangle(band=detail ' + &
		'x="' + string((i - 1) * CELLW) + '" y="0" width="' + string(CELLW) + '" height="80" ' + &
		'name=cell_' + ls_n + ' ' + &
		'visible="0~tIf(long(mid(cells,' + ls_n + ',1))>0,1,0)" ' + &
		'brush.hatch="6" ' + &
		'brush.color="65280~tCASE(long(mid(cells,' + ls_n + ',1)) WHEN 2 THEN 65535 WHEN 9 THEN 255 ELSE 65280)" ' + &
		'pen.style="0" pen.width="0" pen.color="0" ' + &
		'background.mode="1" background.color="0")'
	dw_1.modify(ls_cmd)
next
dw_1.setredraw(true)
end subroutine

public subroutine wf_set_cell (long ax, long ay, string ac);string ls_row
ls_row = dw_1.getitemstring(ay, "cells")
ls_row = replace(ls_row, ax, 1, ac)
dw_1.setitem(ay, "cells", ls_row)
end subroutine

public subroutine wf_place_food ();long ll_x, ll_y, i
boolean lb_ok
do
	lb_ok = true
	ll_x = rand(GW)
	ll_y = rand(GH)
	if ll_x = 0 then ll_x = 1
	if ll_y = 0 then ll_y = 1
	for i = 1 to il_len
		if il_sx[i] = ll_x and il_sy[i] = ll_y then
			lb_ok = false
			exit
		end if
	next
loop until lb_ok
il_fx = ll_x
il_fy = ll_y
wf_set_cell(ll_x, ll_y, "9")
end subroutine

public subroutine wf_reset ();long i, r
long ll_empty[]
il_sx = ll_empty
il_sy = ll_empty
dw_1.setredraw(false)
for r = 1 to GH
	dw_1.setitem(r, "cells", fill("0", GW))
next
il_len = 4
for i = 1 to il_len
	il_sx[i] = 16 - i + 1
	il_sy[i] = 11
	if i = 1 then
		wf_set_cell(il_sx[i], il_sy[i], "2")
	else
		wf_set_cell(il_sx[i], il_sy[i], "1")
	end if
next
ii_dir = 2
il_score = 0
ib_alive = true
randomize(0)
wf_place_food()
dw_1.setredraw(true)
st_score.text = "Score: 0"
end subroutine

on w_snake.create
this.dw_1=create dw_1
this.st_score=create st_score
this.cb_start=create cb_start
this.st_info=create st_info
this.Control[]={this.dw_1,&
this.st_score,&
this.cb_start,&
this.st_info}
end on

on w_snake.destroy
destroy(this.dw_1)
destroy(this.st_score)
destroy(this.cb_start)
destroy(this.st_info)
end on

event open;long r
for r = 1 to GH
	dw_1.insertrow(0)
next
wf_init_grid()
wf_reset()
ib_running = true
timer(0.12)
end event

event timer;long ll_nx, ll_ny, i, ll_tailx, ll_taily
boolean lb_grow

if not ib_alive then return
if not ib_running then return
if ib_intimer then return
ib_intimer = true

ll_nx = il_sx[1]
ll_ny = il_sy[1]
choose case ii_dir
	case 1
		ll_ny = ll_ny - 1
	case 2
		ll_nx = ll_nx + 1
	case 3
		ll_ny = ll_ny + 1
	case 4
		ll_nx = ll_nx - 1
end choose

if ll_nx < 1 then ll_nx = GW
if ll_nx > GW then ll_nx = 1
if ll_ny < 1 then ll_ny = GH
if ll_ny > GH then ll_ny = 1

lb_grow = (ll_nx = il_fx and ll_ny = il_fy)

for i = 1 to il_len
	if i = il_len and not lb_grow then continue
	if il_sx[i] = ll_nx and il_sy[i] = ll_ny then
		ib_alive = false
		timer(0)
		ib_intimer = false
		messagebox("Snake", "You ate yourself. Score: " + string(il_score))
		return
	end if
next

ll_tailx = il_sx[il_len]
ll_taily = il_sy[il_len]

if lb_grow then
	for i = il_len to 1 step -1
		il_sx[i + 1] = il_sx[i]
		il_sy[i + 1] = il_sy[i]
	next
	il_sx[1] = ll_nx
	il_sy[1] = ll_ny
	il_len = il_len + 1
	il_score = il_score + 10
	st_score.text = "Score: " + string(il_score)
else
	for i = il_len to 2 step -1
		il_sx[i] = il_sx[i - 1]
		il_sy[i] = il_sy[i - 1]
	next
	il_sx[1] = ll_nx
	il_sy[1] = ll_ny
end if

dw_1.setredraw(false)
if il_len >= 2 then wf_set_cell(il_sx[2], il_sy[2], "1")
wf_set_cell(ll_nx, ll_ny, "2")
if not lb_grow then wf_set_cell(ll_tailx, ll_taily, "0")
if lb_grow then wf_place_food()
dw_1.setredraw(true)

ib_intimer = false
end event

event key;choose case key
	case keyuparrow!
		if ii_dir <> 3 then ii_dir = 1
	case keyrightarrow!
		if ii_dir <> 4 then ii_dir = 2
	case keydownarrow!
		if ii_dir <> 1 then ii_dir = 3
	case keyleftarrow!
		if ii_dir <> 2 then ii_dir = 4
	case keyspacebar!
		ib_running = not ib_running
end choose
end event

event close;timer(0)
end event

type dw_1 from datawindow within w_snake
integer x = 41
integer y = 40
integer width = 3141
integer height = 1700
string dataobject = "dw_snake"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type st_score from statictext within w_snake
integer x = 41
integer y = 1780
integer width = 1202
integer height = 92
integer textsize = -12
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 0
string text = "Score: 0"
boolean focusrectangle = false
end type

type cb_start from commandbutton within w_snake
integer x = 2779
integer y = 1772
integer width = 402
integer height = 112
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Restart"
end type

event clicked;wf_reset()
ib_running = true
timer(0.12)
parent.setfocus()
end event

type st_info from statictext within w_snake
integer x = 41
integer y = 1900
integer width = 2702
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 12632256
long backcolor = 0
string text = "Arrows = move, Space = pause. Eat the red cell to grow."
boolean focusrectangle = false
end type
