-- trek-wall-u-auto: banded clay rock, pale tan, slumped strata and dangling root hairs (84x126 auto-join sheet)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local A = dofile(R .. "trek-pixel/scripts/_fam4-autojoin.lua")
local c = GV.canvas{ w = 84, h = 126, mode = "scene" }

local WL = { gloss = "#e6cf98", rim = "#d9bd84", base = "#c9a96e", bounce = "#b08a55", shade = "#9a6b3f", deep = "#7a4a1f" }
local APRON = "#8a5a30"
local EM4, MOSS6 = "#e0501f", "#4f9a45"
local WAVE = { 0, -1, -1, 0, 1, 1, 0 }   -- by x mod 7 (period 7 divides 21)

local function skel(lx, ly)
  local o = WAVE[lx % 7 + 1]
  if ly == 6 + o or ly == 16 + o then return WL.shade, true end   -- strata crease
  if ly == 5 + o or ly == 15 + o then return WL.gloss end          -- lit lip above it
  if ly == 4 + o or ly == 14 + o then return WL.bounce end         -- bottom row of the band
  return WL.base
end

A.render(c, function(cfg, x, y, lx, ly)
  local k, side = A.classify(cfg, x, y)
  if k == "apron" then return APRON end
  if k == "ol" then return A.UMB[side] end
  local b = A.band(cfg, x, y)
  if b == "rim" then return WL.rim end
  if b == "bounce" then return WL.bounce end
  local col, crease = skel(lx, ly)
  if b == "shade" then return WL.shade end
  return col
end)

local q = function(qx, qy, lx, ly, h) A.q(c, qx, qy, lx, ly, h) end
local function pts(qx, qy, list, h) for _, p in ipairs(list) do q(qx, qy, p[1], p[2], h) end end

-- root hairs hanging from a strata line (one per interior quarter, different lengths)
pts(1, 3, { {4,8},{4,9},{4,10},{5,11},{5,12} }, WL.deep)
pts(2, 3, { {13,7},{13,8},{14,9},{14,10},{14,11} }, WL.deep)
pts(1, 4, { {8,16},{8,17},{8,18},{7,19} }, WL.deep)
pts(2, 4, { {3,17},{3,18},{4,19} }, WL.deep)
-- features
for y = 9, 11 do for x = 15, 17 do q(2, 4, x, y, EM4) end end            -- drip stain
pts(2, 4, { {18,10},{18,11},{18,12},{16,12},{17,12} }, WL.deep)
pts(1, 4, { {14,5},{15,5} }, MOSS6)
pts(1, 3, { {10,2},{17,12} }, WL.deep)
-- edge quarters: one pit each
q(1, 2, 12, 10, WL.deep); q(2, 2, 6, 12, WL.deep)
q(0, 3, 11, 9, WL.deep);  q(0, 4, 9, 11, WL.deep)
q(3, 3, 7, 10, WL.deep);  q(3, 4, 5, 2, WL.deep)
q(1, 5, 10, 9, WL.deep);  q(2, 5, 13, 10, WL.deep)

A.iso(c)
local P = R .. "trek-pixel/"
local t = c:save(P .. "aseprite/trek-wall-u-auto.aseprite", P .. "png/trek-wall-u-auto.png")
print(GV.report(t))
