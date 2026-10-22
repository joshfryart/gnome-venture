-- trek-water-auto: flat teal pool with a soft wet-bank shoreline, glints inside (84x126 auto-join sheet)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local A = dofile(R .. "trek-pixel/scripts/_fam4-autojoin.lua")
local c = GV.canvas{ w = 84, h = 126, mode = "scene" }

local WA = { gloss = "#c8ecdc", rim = "#a9d6ea", base = "#3f8fb0", shade = "#25637d" }
local APRON, BANK = "#7a4a1f", "#5c3520"   -- mud_base apron, mud_shade bank line (no umber on water)

-- 6 on / 4 off glint dash along N and W edges at d 6 (quarter-local, 5 off across the quarter line)
local function dash(t) return (t >= 2 and t <= 7) or (t >= 12 and t <= 17) end
local function inCornerBox(cfg, x, y)
  return (cfg.N and cfg.W and x <= 9 and y <= 9) or (cfg.N and cfg.E and x >= 32 and y <= 9)
      or (cfg.S and cfg.W and x <= 9 and y >= 32) or (cfg.S and cfg.E and x >= 32 and y >= 32)
end

A.render(c, function(cfg, x, y, lx, ly)
  local k = A.classify(cfg, x, y)
  if k == "apron" then return APRON end
  if k == "ol" then return BANK end
  if A.touch(cfg, x, y) then return WA.shade end
  if not inCornerBox(cfg, x, y) then
    if cfg.N and y == 6 and dash(lx) and not (cfg.W and x < 7) and not (cfg.E and x > 34) then return WA.rim end
    if cfg.W and x == 6 and dash(ly) and not (cfg.N and y < 7) and not (cfg.S and y > 34) then return WA.rim end
  end
  return WA.base
end)

local q = function(qx, qy, lx, ly, h) A.q(c, qx, qy, lx, ly, h) end
local function run(qx, qy, x0, x1, y, h) for x = x0, x1 do q(qx, qy, x, y, h) end end

-- interior quarters (every glint >= 2 px from the quarter borders)
run(1, 3, 5, 7, 6, WA.rim);   run(1, 3, 6, 7, 7, WA.shade);  run(1, 3, 12, 13, 14, WA.rim)
run(2, 3, 8, 11, 11, WA.rim); run(2, 3, 9, 11, 12, WA.shade)
run(1, 4, 4, 6, 13, WA.rim);  run(1, 4, 5, 6, 14, WA.shade); q(1, 4, 14, 5, WA.gloss)
run(2, 4, 10, 12, 8, WA.rim); run(2, 4, 11, 12, 9, WA.shade); q(2, 4, 4, 16, WA.gloss)
-- edge quarters: one 2 px glint each, >= 3 px from the apron rows, never the same spot
run(1, 2, 9, 10, 13, WA.rim)
run(2, 2, 13, 14, 10, WA.rim)
run(0, 3, 12, 13, 15, WA.rim)
run(0, 4, 10, 11, 7, WA.rim)
run(3, 3, 5, 6, 9, WA.rim)
run(3, 4, 8, 9, 13, WA.rim)
run(1, 5, 12, 13, 6, WA.rim)
run(2, 5, 4, 5, 9, WA.rim)

A.iso(c)
local P = R .. "trek-pixel/"
local t = c:save(P .. "aseprite/trek-water-auto.aseprite", P .. "png/trek-water-auto.png")
print(GV.report(t))
