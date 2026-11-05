-- gem-l (ui P3_U1)
local M=dofile("/tmp/claude-0/-home-user-gnome-venture/45d9e48c-f922-5c2c-ab9e-b588918b9162/scratchpad/U1/gemlib.lua")
local c=M.build("gem-l",32,32,function(c)
  local pts={}
  local cx,cy=15.5,17
  for i=0,9 do local a=-math.pi/2+i*math.pi/5; local r=(i%2==0) and 14.3 or 8.2
    pts[#pts+1]={cx+r*math.cos(a),cy+r*math.sin(a)} end
  return c:poly(pts) end,"L",13,13,2,22,23,{{11,8},{12,8},{11,9}})
c:save{aseprite=app.params.out.."gem-l.aseprite", png=app.params.out.."gem-l.png", scale=1}
