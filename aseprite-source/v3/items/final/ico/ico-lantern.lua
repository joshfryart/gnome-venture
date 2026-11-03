-- ico-lantern (final pass, Opus). A slim brass hurricane lantern: ring handle, conical cap with a vent band,
-- glass chamber between two corner posts, a short candle with a teardrop flame, rimmed base on a 2-tone ground
-- shadow. Material: brass as per-pixel vertical cylinders (6 tones, bevelled rims with a bright top edge, a specular
-- streak on each post, dark rivets and vent holes), glass glowing warm from the flame outward with a bright rim
-- streak and pale core, cream wax with a drip, AO under the cap and above the base.
-- quirk: a small moth has landed on the handle, drawn to the light.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("ico-lantern")
local BR   = { "#4a2a20", "#7a4622", "#ac6a2a", "#d6973a", "#f0c25c", "#ffe49a" }
local GLOW = { "#c8612c", "#e88a32", "#f7b544", "#ffd76a", "#ffeea6" }
local WAX  = { "#c99a7a", "#ead2b0", "#fff1d4" }
local FL   = { "#e8493b", "#ff8a3c", "#ffd25a", "#fff4c8" }
local CR = "#fff4d6"
local GR   = { "#13292c", "#1d4140", "#2a5f4e", "#3e805a", "#62a46a", "#a2d08a" }
local mtok = { r = { name = "brass" } }

-- x-only cylinder light between x0..x1
local function vc(m, x0, x1, o)
  o = o or {}
  local R = o.ramp or GR
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, o.ny or 0, sqrt(1 - t * t) }
  end)
  return A.shade(c, m, n, R, { amb = 0, wrap = 0.15, bias = o.bias, tok = o.tok or mtok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
end

c:groundShadow(32, 52, 14, 1)

-- glass chamber with the glow (painted first; posts and rims overlap it)
local GX0, GX1, GY0, GY1 = 22, 42, 25, 44
local gm = c:rect(GX0, GY0, GX1, GY1)
local FX, FY = 32, 32
gm:each(function(x, y)
  local d = sqrt(((x - FX) / 1.1) ^ 2 + ((y - FY) / 1.4) ^ 2)
  local i = d < 4 and 5 or (d < 7 and 4 or (d < 10 and 3 or (d < 12.5 and 2 or 1)))
  if y <= GY0 + 1 then i = max(1, i - 1) end          -- AO under the cap
  c:put(x, y, GLOW[i])
end)
-- glass rim streaks (bright left edge of each pane) + reflection tick
for y = GY0 + 3, GY1 - 3 do c:put(GX0 + 4, y, y % 6 == 0 and GLOW[4] or GLOW[5]) end
for y = GY0 + 4, GY0 + 10 do c:put(GX1 - 5, y, GLOW[4]) end
c:put(GX0 + 4, GY0 + 3, CR) c:put(GX0 + 4, GY0 + 4, CR)

-- candle
local cm = c:rect(29, 37, 35, GY1)
cm:each(function(x, y)
  local i = x <= 30 and 3 or (x <= 33 and 2 or 1)
  if y == 37 then i = min(3, i + 1) end
  c:put(x, y, WAX[i])
end)
c:put(30, 38, WAX[3]) c:put(30, 39, WAX[3]) c:put(30, 40, WAX[3])   -- drip down the lit side
c:put(31, 37, WAX[1])                                              -- wick hollow
c:put(32, 36, "#2b1c26") c:put(32, 35, "#4a2a20")                  -- wick
-- flame teardrop
local flame = {
  "...a...",
  "..aba..",
  "..bcb..",
  ".abcba.",
  ".bcdcb.",
  ".bcdcb.",
  "..bcb..",
}
A.map(c, flame, 29, 27, { a = FL[1], b = FL[2], c = FL[3], d = FL[4] })

-- corner posts (3 px) left and right, with a specular streak
local function post(x0)
  local m = c:rect(x0, GY0, x0 + 2, GY1)
  local idx = vc(m, x0, x0 + 2)
  for y = GY0 + 2, GY1 - 2 do if y % 7 < 4 then c:put(x0, y, GR[6], mtok) end end
  return m
end
post(GX0 - 1) post(GX1 - 1)

-- cap: cone 25 -> 9 px wide over y 15..22, then vent band and rim
local capm = c:poly{ { 27, 16 }, { 37, 16 }, { 44, 22 }, { 20, 22 } }
vc(capm, 20, 44, { ny = -0.2 })
for y = 16, 22 do local x = floor(27 - (y - 16) * 7 / 6 + 0.5) if capm:has(x + 1, y) then c:put(x + 1, y, GR[6], mtok) end end
for _, x in ipairs{ 26, 30, 34, 38 } do c:put(x, 20, GR[1], mtok) c:put(x + 1, 20, GR[1], mtok) c:put(x, 21, GR[3], mtok) end  -- vent holes
local rim1 = c:rect(19, 23, 45, 25)
local i1 = vc(rim1, 19, 45, { ramp = BR })
for x = 20, 44 do c:put(x, 23, BR[x < 32 and 6 or 5], mtok) end
for x = 19, 45 do c:put(x, 25, BR[2], mtok) end
for _, x in ipairs{ 22, 32, 42 } do c:put(x, 24, BR[1], mtok) end  -- rivets
c:put(23, 24, BR[6], mtok)
-- cap top knob
local knob = c:rect(29, 14, 35, 15)
vc(knob, 29, 35, { ramp = BR })
for x = 29, 32 do c:put(x, 14, BR[6], mtok) end

-- handle ring
local ring = A.ell(32, 9.5, 5.5, 4.5):cut(A.ell(32, 10, 2.5, 1.5))
local rn = X.pillow(ring, 1.6)
local ridx = A.shade(c, ring, rn, BR, { amb = 0, wrap = 0.15, tok = mtok, cuts = { 0.3, 0.46, 0.6, 0.74, 0.9 } })
c:put(28, 6, BR[6], mtok) c:put(29, 6, BR[6], mtok)
c:fillMask(c:rect(31, 13, 33, 13), BR[2])

-- base: rim then foot
local rim2 = c:rect(19, 45, 45, 47)
local b2 = {}
rim2:each(function(x, y) if y == 47 then b2[K(x, y)] = -1 end end)
vc(rim2, 19, 45, { bias = b2, ramp = BR })
for x = 20, 44 do c:put(x, 45, BR[x < 32 and 6 or 5], mtok) end
for _, x in ipairs{ 22, 32, 42 } do c:put(x, 46, BR[1], mtok) end
local foot = c:rect(21, 48, 43, 50)
local b3 = {}
foot:each(function(x, y) if y == 48 then b3[K(x, y)] = -2 end end)
vc(foot, 21, 43, { bias = b3 })

-- quirk: moth resting on the right of the handle ring
local moth = {
  ".ab..",
  "abbcb",
  "kbbcc",
  ".acc.",
}
A.map(c, moth, 37, 6, { a = "#e8dcc8", b = "#c9b2a0", c = "#94788a", k = "#2b1c26" })
c:put(37, 5, "#5a459e")  -- antenna

A.save(c, "ico-lantern")
