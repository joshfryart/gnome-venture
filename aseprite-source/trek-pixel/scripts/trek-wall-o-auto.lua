-- trek-wall-o-auto: coursed fieldstone wall, grey stone, mossy and a little thorny (84x126 auto-join sheet)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local A = dofile(R .. "trek-pixel/scripts/_fam4-autojoin.lua")
local c = GV.canvas{ w = 84, h = 126, mode = "scene" }

local SN = { gloss = "#c9c5bc", rim = "#b3b2b0", base = "#8b8f96", bounce = "#7a7f8a", shade = "#5b6470", deep = "#3c4252" }
local APRON = "#9a6b3f"
local INK, MOSS8, MOB, MOSS6 = "#2b2b2b", "#2f5a2a", "#7ab55c", "#4f9a45"
local EM4, EM7 = "#e0501f", "#a8241f"

-- skeleton (quarter coords). Mortar rows 0,10 and 20 (row 20 + next row 0 = the quarter-line mortar),
-- course A rows 1-9 joints 0,10,20; course B rows 11-19 joints 5,15.
local function mortar(lx, ly)
  if ly == 0 or ly == 10 or ly == 20 then return true end
  if ly <= 9 then return lx == 0 or lx == 10 or lx == 20 end
  return lx == 5 or lx == 15
end
local function skel(lx, ly)
  if mortar(lx, ly) then return SN.shade end
  if ly == 1 then return (lx == 1) and SN.gloss or SN.rim end        -- course A top rows; gloss on stone A1
  if ly == 11 then return (lx == 6) and SN.gloss or SN.rim end       -- course B top rows; gloss on stone B1
  if ly == 9 or ly == 19 then return SN.bounce end
  return SN.base
end

A.render(c, function(cfg, x, y, lx, ly)
  local k, side = A.classify(cfg, x, y)
  if k == "apron" then return APRON end
  if k == "ol" then return A.UMB[side] end
  local b = A.band(cfg, x, y)
  if b == "rim" then return SN.rim end
  if b == "bounce" then return SN.bounce end
  if b == "shade" then return mortar(lx, ly) and SN.deep or SN.shade end
  return skel(lx, ly)
end)

local q = function(qx, qy, lx, ly, h) A.q(c, qx, qy, lx, ly, h) end
local function box(qx, qy, x0, y0, x1, y1, h) for y = y0, y1 do for x = x0, x1 do q(qx, qy, x, y, h) end end end

-- interior quarters
box(1, 3, 6, 3, 9, 5, MOSS8); q(1, 3, 6, 3, MOB); q(1, 3, 7, 3, MOB)                -- moss patch on stone A1
for _, p in ipairs({ {8,13},{9,14},{9,15},{10,16},{10,17} }) do q(2, 3, p[1], p[2], INK) end  -- crack
box(1, 4, 12, 4, 14, 6, EM4); q(1, 4, 14, 6, EM7); q(1, 4, 13, 6, EM7); q(1, 4, 14, 5, EM7) -- thorn dot
for _, p in ipairs({ {9,13},{10,12},{11,11} }) do q(1, 4, p[1], p[2], EM7) end           -- thorn stroke
for _, p in ipairs({ {4,5},{14,13},{18,2} }) do q(2, 4, p[1], p[2], SN.deep) end         -- specks

-- edge quarters: one feature each, away from the apron
q(1, 2, 14, 8, MOSS6); q(1, 2, 15, 8, MOB); q(1, 2, 16, 8, MOSS6); q(1, 2, 15, 7, MOSS6) -- moss tuft
q(2, 2, 6, 11, SN.deep); q(2, 2, 15, 15, SN.deep)
for _, p in ipairs({ {4,10},{4,11},{5,12},{5,13} }) do q(0, 3, p[1], p[2], INK) end
box(0, 4, 7, 14, 9, 16, MOSS8); q(0, 4, 7, 14, MOB)
box(3, 3, 6, 12, 8, 14, EM4); q(3, 3, 8, 14, EM7); q(3, 3, 7, 14, EM7); q(3, 3, 8, 13, EM7)
for _, p in ipairs({ {11,5},{11,6},{12,7},{12,8} }) do q(3, 4, p[1], p[2], INK) end
q(1, 5, 7, 5, SN.deep); q(1, 5, 15, 8, SN.deep)
q(2, 5, 3, 7, SN.deep); q(2, 5, 12, 3, SN.deep)

A.iso(c)
local P = R .. "trek-pixel/"
local t = c:save(P .. "aseprite/trek-wall-o-auto.aseprite", P .. "png/trek-wall-o-auto.png")
print(GV.report(t))
