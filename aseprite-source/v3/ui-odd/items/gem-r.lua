-- gem-r (ui P3_U1)
local M=dofile("/tmp/claude-0/-home-user-gnome-venture/45d9e48c-f922-5c2c-ab9e-b588918b9162/scratchpad/U1/gemlib.lua")
local c=M.build("gem-r",28,28,function(c)
  local cx,cy,r=13.5,13.5,12.6
  return c:poly{{cx,cy-r},{cx+r,cy},{cx,cy+r},{cx-r,cy}} end,"R",11,10,3,18,19,{{8,8},{9,7},{7,9}})
c:save{aseprite=app.params.out.."gem-r.aseprite", png=app.params.out.."gem-r.png", scale=1}
