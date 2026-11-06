-- Renders every satchel skin as two transparent 480x270 layers: out/satchel-back-<key>.png (behind the found item) and out/satchel-front-<key>.png (in front).
-- keys: leather (A, default), canvas (B), patchwork (C)
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/gx.lua")
local SAT = dofile(d .. "/satchel3.lua")
for v, key in pairs{ A = "leather", B = "canvas", C = "patchwork" } do
  local b = GX.HP.canvas{ w = 480, h = 270, scale = 1, name = "sb" .. v }
  SAT.back(b, GX, v, nil)
  b:save{ aseprite = d .. "/out/satchel-back-" .. key .. ".aseprite", png = d .. "/out/satchel-back-" .. key .. ".png", scale = 1 }
  local f = GX.HP.canvas{ w = 480, h = 270, scale = 1, name = "sf" .. v }
  SAT.front(f, GX, v)
  f:save{ aseprite = d .. "/out/satchel-front-" .. key .. ".aseprite", png = d .. "/out/satchel-front-" .. key .. ".png", scale = 1 }
end
