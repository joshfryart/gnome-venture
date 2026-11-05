-- badge-basket (ui P3_U0)
local W,H=30,30
local out=app.params.out or "./"
local spr=Sprite(W,H,ColorMode.RGB)
local img=spr.cels[1].image
local function hex(s) return Color{r=tonumber(s:sub(2,3),16),g=tonumber(s:sub(4,5),16),b=tonumber(s:sub(6,7),16),a=255} end
local function P(x,y,c) if x>=0 and y>=0 and x<W and y<H then img:putPixel(x,y,hex(c)) end end
local function R(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do P(x,y,c) end end end
local INK="#2b1c26"
local o={"#2b1c26"}
-- handle arc (ink then wood)
for _,p in ipairs{{9,12},{8,10},{8,8},{9,6},{11,4},{13,3},{16,3},{18,4},{20,6},{21,8},{21,10},{20,12}} do R(p[1]-1,p[2]-1,p[1]+1,p[2]+1,INK) end
for _,p in ipairs{{9,12},{8,10},{8,8},{9,6},{11,4},{13,3},{16,3},{18,4},{20,6},{21,8},{21,10},{20,12}} do P(p[1],p[2],"#a8743c") end
for _,p in ipairs{{9,6},{11,4},{13,3}} do P(p[1],p[2],"#d9a860") end
-- body
R(3,12,26,13,INK) R(2,13,27,14,INK)
for y=14,26 do local i=y-14 local x0=3+math.floor(i/4) local x1=26-math.floor(i/4) R(x0-1,y,x1+1,y,INK) end
R(7,27,22,27,INK)
local ramp={"#e2b878","#c48c50","#a86e3a","#8a5530"}
for y=13,26 do local i=y-14 if y<14 then i=0 end local x0=3+math.floor(i/4) local x1=26-math.floor(i/4)
 local row=((y-13)//3)%2
 for x=x0,x1 do local c=ramp[2] if row==1 then c=ramp[3] end
  if (x+y)%6==0 then c=ramp[4] end
  if x<=x0+1 then c=ramp[1] end
  if x>=x1-1 then c=ramp[4] end
  P(x,y,c) end end
R(3,13,26,13,"#f0d08c") R(4,13,8,13,"#fff0b8")
R(7,26,22,26,"#6c4226")
-- quirk: a red berry peeking
R(12,9,15,12,INK) R(13,10,14,11,"#d8404a") P(13,10,"#ff8a8a")
-- fix rim over berry
R(9,13,20,13,"#f0d08c")
spr:saveAs(out.."badge-basket.aseprite")
spr:saveCopyAs(out.."badge-basket.png")
