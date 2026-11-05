-- felt-r (ui P3_U0)
local W,H=36,36
local out=app.params.out or "./"
local spr=Sprite(W,H,ColorMode.RGB)
local img=spr.cels[1].image
local function hex(s) return Color{r=tonumber(s:sub(2,3),16),g=tonumber(s:sub(4,5),16),b=tonumber(s:sub(6,7),16),a=255} end
local function P(x,y,c) if x>=0 and y>=0 and x<W and y<H then img:putPixel(x,y,hex(c)) end end
local function R(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do P(x,y,c) end end end
local INK="#2b1c26"
local base,lt,dk,edge,st,fl="#a9c6d0","#d6ecf0","#7da0ac","#8fb2be","#3f6a7c","#86aab6"
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
-- quirk: cross stitch x
P(24,17,"#3f6a7c") P(26,17,"#3f6a7c") P(25,18,"#3f6a7c") P(24,19,"#3f6a7c") P(26,19,"#3f6a7c")
spr:saveAs(out.."felt-r.aseprite")
spr:saveCopyAs(out.."felt-r.png")
