-- gem-u (ui P3_U1)
local M=dofile("/tmp/claude-0/-home-user-gnome-venture/45d9e48c-f922-5c2c-ab9e-b588918b9162/scratchpad/U1/gemlib.lua")
local c=M.build("gem-u",26,28,function(c)
  return c:poly{{1,1},{23.9,1},{23.9,15},{12.5,26.5},{1,15}} end,"U",10,8,3,20,18,{{5,5},{6,5},{5,6}})
c:save{aseprite=app.params.out.."gem-u.aseprite", png=app.params.out.."gem-u.png", scale=1}
