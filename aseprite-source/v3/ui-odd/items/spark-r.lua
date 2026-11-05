-- spark-r (ui P3_U2)
local out = app.params["out"] or "./"
local spr = Sprite(128,32,ColorMode.RGB)
local img = Image(128,32,ColorMode.RGB)
local function hx(s) return app.pixelColor.rgba(tonumber(s:sub(2,3),16),tonumber(s:sub(4,5),16),tonumber(s:sub(6,7),16),255) end
local C={"#4f8fc4","#8cc8e6","#b9e2f2","#e8f7fb"}
for i,v in ipairs(C) do C[i]=hx(v) end -- 1 tip,2 arm,3 halo,4 core
local function P(x,y,c) if x>=0 and x<128 and y>=0 and y<32 then img:putPixel(x,y,c) end end
local MIR=true
-- star(cx,cy,arm,halo,diag)
local function star(cx,cy,arm,halo,diag)
  if MIR then cx=127-cx end
  if diag then
    for i=1,arm do P(cx+i,cy+i,C[2]);P(cx-i,cy+i,C[2]);P(cx+i,cy-i,C[2]);P(cx-i,cy-i,C[2]) end
    P(cx+arm,cy+arm,C[1]);P(cx-arm,cy+arm,C[1]);P(cx+arm,cy-arm,C[1]);P(cx-arm,cy-arm,C[1])
    for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do P(cx+d[1],cy+d[2],C[3]) end
    P(cx,cy,C[4]); return
  end
  for i=1,arm do P(cx+i,cy,C[2]);P(cx-i,cy,C[2]);P(cx,cy+i,C[2]);P(cx,cy-i,C[2]) end
  P(cx+arm,cy,C[1]);P(cx-arm,cy,C[1]);P(cx,cy+arm,C[1]);P(cx,cy-arm,C[1])
  if halo then for dx=-1,1 do for dy=-1,1 do P(cx+dx,cy+dy,C[3]) end end end
  P(cx,cy,C[4])
end
star(9,11,2,false); star(41,11,3,true); star(73,11,4,true); star(105,11,3,false,true)
star(23,22,4,true); star(55,22,3,true); star(87,22,2,false)
P(MIR and 127-89 or 89,5,C[4]); P(MIR and 127-60 or 60,27,C[3]); P(MIR and 127-118 or 118,26,C[3])
spr.cels[1].image:drawImage(img)
spr:saveAs(out.."spark-r.aseprite")
spr:saveCopyAs(out.."spark-r.png")
