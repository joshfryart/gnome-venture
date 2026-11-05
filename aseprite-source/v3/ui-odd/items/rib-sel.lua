-- rib-sel (ui P3_U2)
local out = app.params["out"] or "./"
local spr = Sprite(20,24,ColorMode.RGB)
local img = Image(20,24,ColorMode.RGB)
local function hx(s) return app.pixelColor.rgba(tonumber(s:sub(2,3),16),tonumber(s:sub(4,5),16),tonumber(s:sub(6,7),16),255) end
local INK=hx("#2b1c26")
local W={hx("#4a2c1c"),hx("#6e4228"),hx("#92603a"),hx("#b98557")}
local R={"#8a5516","#b87a1f","#dba03a","#f0c456","#fbe69a"}
for i,v in ipairs(R) do R[i]=hx(v) end
local fill={}
local function P(x,y,c) if x>=0 and x<20 and y>=0 and y<24 then fill[y*20+x]=c end end
local function rect(x0,y0,x1,y1,c) for y=y0,y1 do for x=x0,x1 do P(x,y,c) end end end
rect(2,1,17,3,W[3]); rect(2,3,17,3,W[2]); rect(2,1,17,1,W[4]); rect(3,2,5,2,W[4]); rect(16,2,17,3,W[1])
rect(1,20,18,22,W[2]); rect(1,20,18,20,W[3]); rect(3,20,6,20,W[4]); rect(1,22,18,22,W[1]); rect(15,21,18,21,W[1])
rect(4,4,14,19,R[3])
rect(4,4,5,19,R[4]); rect(4,4,4,19,R[5])
rect(12,4,14,19,R[2]); rect(14,4,14,19,R[1])
for _,y in ipairs{6,10,14,18} do rect(5,y,13,y,R[2]); rect(4,y,4,y,R[3]) end
for _,y in ipairs{5,9,13,17} do P(6,y,R[5]); P(7,y,R[4]) end
rect(4,4,14,4,R[1]); rect(4,19,14,19,R[1])
rect(15,9,16,16,R[3]); rect(16,9,16,16,R[2]); rect(15,9,15,12,R[4])
P(15,17,R[3]); P(16,17,R[2]); P(15,18,R[2]); P(16,18,R[1]); P(16,19,R[1])
for y=0,23 do for x=0,19 do
  local c=fill[y*20+x]
  if c then img:putPixel(x,y,c)
  else
    local o=false
    for _,d in ipairs{{1,0},{-1,0},{0,1},{0,-1}} do local nx,ny=x+d[1],y+d[2]
      if nx>=0 and nx<20 and ny>=0 and ny<24 and fill[ny*20+nx] then o=true end end
    if o then img:putPixel(x,y,INK) end
  end
end end
spr.cels[1].image:drawImage(img)
spr:saveAs(out.."rib-sel.aseprite")
spr:saveCopyAs(out.."rib-sel.png")
