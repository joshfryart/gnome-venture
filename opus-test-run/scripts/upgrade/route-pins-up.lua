-- Route ribbon sprites, upgrade pass (Stitched Toy, Part D). Lantern light from upper left.
-- run: aseprite -b --script-param lib=<route-lib.lua> --script-param src=.. --script-param out=.. --script <this>
local L = dofile(app.params["lib"])
local function mk(w,h,rows,leg,ox,oy,name,extra)
  local spr,img=L.new(w,h); L.rows(img,ox or 1,oy or 1,rows,leg); if extra then extra(img) end
  L.border(img); spr.cels[1].image=img; L.save(spr,name)
end
-- gnome token 19x24, facing right
mk(19,24,{
"..........k......",
".........kRk.....",
"........khRk.....",
".......khRRrk....",
".......khRRrk....",
"......khRRRrrk...",
".....khhRRRRrk...",
".....khRRRRRrrk..",
"....kkkkkkkkkkkk.",
"....kSSSSSSESSnk.",
"....kSSSSSSSSnnnk",
"....kWWWWSSWWWWk.",
"...kWWWWWWWWWWwk.",
"...kBWWWWWWWWwwk.",
"..kBBWWWWWWWwwBk.",
"..kBBBWWWWWwwBbk.",
"..kBBBBWWWwwBBbk.",
"..kBBBBBWwwBBbbk.",
"..kkBBBBBBBBBbkk.",
"...kDDkkkkkDDDk..",
"..ookDDooooDDDko.",
"...ooooooooooo...",
},{k="#2a1a10",R="#d6322b",r="#a8241f",h="#f08a24",S="#c9a96e",E="#2a1a10",n="#e46a9b",
 W="#f1ece0",w="#c9c5bc",B="#3f8fb0",b="#25637d",D="#3d2a1c",o="#3d2a1c"},1,1,"gnome-token")
-- danger markers 13x13
local face={
".d.......d.",
".dR.....Rd.",
".dRRdddRRd.",
"dRhRRRRRRdd",
"dRYYRRRYYdd",
"dRYoRRRoYdd",
"dRRRRRRRRdd",
"ddkkkkkkkdd",
".dkFkkkFkd.",
"..dFdddFd..",
"...ddddd..."}
mk(13,13,face,{d="#6b1b2c",R="#d6322b",h="#ff9158",Y="#f5cf6a",o="#f08a24",k="#2a1a10",F="#f1ece0"},1,1,"danger-on")
mk(13,13,face,{d="#3e3a52",R="#5b6470",h="#8b8f96",Y="#8b8f96",o="#8b8f96",k="#3e3a52",F="#8b8f96"},1,1,"danger-off")
-- pins 14x22
local pin={
"...dddddd...",
"..dgoiBBBd..",
".dgoiBBBBsd.",
".diBBBBBBsd.",
".dBBBBBBBsd.",
".dBBBBBBssd.",
".dBBBBBsssd.",
"..dssssssd..",
"...dddddd...",
".....ab.....",".....ab.....",".....ab.....",".....ab.....",".....ab.....",
".....ab.....",".....ab.....",".....ab.....",".....ab.....",".....ab.....",
"......b....."}
local function ramp(g,o,i,B,s,d) return {g=g,o=o,i=i,B=B,s=s,d=d,a="#c9c5bc",b="#5b6470"} end
mk(14,22,pin,ramp("#fff1c8","#ffffff","#f5cf6a","#e8a317","#b8661a","#7a3a14"),1,1,"a-pin-done",function(img)
  for _,p in ipairs({{4,5},{5,6},{6,7},{7,6},{9,4}}) do L.px(img,p[1],p[2],"#7a3a14") end
  L.px(img,8,5,"#7a3a14") end)
mk(14,22,pin,ramp("#f1ece0","#ffffff","#c9c5bc","#8b8f96","#5b6470","#3e3a52"),1,1,"a-pin-todo")
mk(14,22,pin,ramp("#ff9158","#ffc27a","#f2793a","#d6322b","#a8241f","#6b1b2c"),1,1,"a-pin-stop",function(img)
  L.rect(img,6,4,3,3,"#a8241f"); L.px(img,6,4,"#f2793a"); L.px(img,6,5,"#6b1b2c"); L.px(img,8,5,"#6b1b2c") end)
mk(14,22,pin,ramp("#c3b2ea","#ffffff","#a48ad8","#7a5cc0","#4e3a8a","#2e2257"),1,1,"a-pin-danger",function(img)
  L.px(img,6,6,"#f08a24"); L.px(img,8,6,"#f08a24") end)
-- goal flag 20x26
do
  local spr,img=L.new(20,26)
  L.rect(img,3,3,2,20,"#b07a10"); L.rect(img,3,3,1,20,"#f5cf6a")
  L.rect(img,2,1,3,3,"#e8a317"); L.px(img,2,1,"#fff1c8"); L.px(img,4,3,"#b07a10")
  for y=4,15 do local t=math.abs(y-9.5); local x1=18-math.floor(t*1.6)
    for x=5,x1 do local c="#d6322b"; if y<=6 then c="#f08a24" end; if y>=13 or x>=x1-1 and y>9 then c="#a8241f" end; L.px(img,x,y,c) end end
  for x=6,15 do if (x%3)~=2 then L.px(img,x,8,"#f5cf6a") end end
  L.px(img,6,5,"#ffc27a"); L.px(img,7,5,"#ff9158")
  L.rect(img,1,22,6,2,"#7a4a1f"); L.rect(img,1,22,6,1,"#9a6b3f")
  L.border(img); L.save(spr,"goal-flag")
end
