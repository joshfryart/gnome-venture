-- badge-use (ui P3_U0)
local W,H=30,30
local out=app.params.out or "./"
local spr=Sprite(W,H,ColorMode.RGB)
local img=spr.cels[1].image
local function hex(s) return Color{r=tonumber(s:sub(2,3),16),g=tonumber(s:sub(4,5),16),b=tonumber(s:sub(6,7),16),a=255} end
local function P(x,y,c) if x>=0 and y>=0 and x<W and y<H then img:putPixel(x,y,hex(c)) end end
local function R(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do P(x,y,c) end end end
local INK="#2b1c26"
R(2,2,27,26,INK) R(3,27,26,28,INK)
R(3,3,26,25,"#f2c744")
R(3,3,26,4,"#fff0a0") R(3,3,4,25,"#fff0a0")
R(25,5,26,25,"#c9a026") R(5,24,26,25,"#c9a026")
R(3,26,26,27,"#8a6a10")
P(3,26,INK) P(26,26,INK)
-- inner recessed panel
R(7,8,22,20,INK) R(8,9,21,19,"#b8861c") R(8,9,21,10,"#8a6010") R(8,9,9,19,"#8a6010")
-- arrow pointing right (use)
R(10,13,16,15,"#fff6c8")
R(15,11,15,17,"#fff6c8") R(16,12,16,16,"#fff6c8") R(17,13,17,15,"#fff6c8") R(18,14,18,14,"#fff6c8")
R(10,16,17,16,"#d9a830")
-- rivets (quirk: one missing, replaced by scratch)
P(5,5,"#8a6a10") P(24,5,"#8a6a10") P(5,22,"#8a6a10")
P(24,22,"#fff0a0") P(23,23,"#c9a026")
spr:saveAs(out.."badge-use.aseprite")
spr:saveCopyAs(out.."badge-use.png")
