-- felt-l (ui P3_U0)
local W,H=36,36
local out=app.params.out or "./"
local spr=Sprite(W,H,ColorMode.RGB)
local img=spr.cels[1].image
local function hex(s) return Color{r=tonumber(s:sub(2,3),16),g=tonumber(s:sub(4,5),16),b=tonumber(s:sub(6,7),16),a=255} end
local function P(x,y,c) if x>=0 and y>=0 and x<W and y<H then img:putPixel(x,y,hex(c)) end end
local function R(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do P(x,y,c) end end end
local INK="#2b1c26"
local base,lt,dk,edge,st,fl="#e0c060","#ffe58a","#b08a28","#c9a038","#8a5a0c","#c29a30"
R(0,0,35,35,base)
R(0,0,35,1,lt) R(0,0,1,35,lt)
R(0,34,35,35,dk) R(34,0,35,35,dk)
R(34,0,35,1,edge) R(0,34,1,35,edge)
R(2,2,33,2,edge) R(2,2,2,33,edge) R(2,33,33,33,dk) R(33,2,33,33,dk)
P(2,2,lt) P(33,33,dk)
-- stitched border dashes
for _,x in ipairs{5,11,17,23,29} do R(x,5,x+2,5,st) R(x,30,x+2,30,st) end
for _,y in ipairs{9,15,21,26} do R(5,y,5,y+2,st) R(30,y,30,y+2,st) end
-- flecks
for _,p in ipairs{{12,13},{22,11},{17,18},{9,22},{25,24},{14,26},{27,16}} do P(p[1],p[2],fl) end
-- quirk: tiny sewn star
P(12,17,"#8a5a0c") P(11,16,"#8a5a0c") P(13,16,"#8a5a0c") P(12,15,"#8a5a0c") P(12,16,"#ffe58a")
spr:saveAs(out.."felt-l.aseprite")
spr:saveCopyAs(out.."felt-l.png")
