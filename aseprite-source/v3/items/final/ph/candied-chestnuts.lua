-- candied-chestnuts (final pass, Opus). Three marrons glaces heaped in a fluted gold-foil cup: each chestnut is a
-- rounded body drawn up to a short point with a dark tuft, glossy amber syrup glaze (6 tones, sphere+pillow light,
-- cream specular plus a 2x1 hi), faint sugar crust on the crown, cool reflected light on the shade side, AO where they
-- touch. The cup has a rolled lip, vertical flutes and a 2-tone ground shadow.
-- quirk: a bead of syrup has run off the front chestnut, over the lip and down a flute.
local NAME = "candied-chestnuts"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)

local GLZ = { "#3a171c", "#5e2622", "#883b25", "#b2582b", "#d8823a", "#f6b866" }
local COOLR = "#7a4a5a"
local FOIL = { "#7a4420", "#a8642a", "#d08e32", "#eab43e", "#f8d66a", "#fff0b0" }
local SUG = "#f6dcb0"

c:groundShadow(32, 55, 17, 1.4)

-- chestnut mask: round body + short point on top
local function nut(cx, cy, rx, ry)
  local m = HP.ellipse(cx, cy, rx, ry)
  m:add(HP.poly{ { cx - 2.6, cy - ry + 1.5 }, { cx + 2.6, cy - ry + 1.5 }, { cx + 0.5, cy - ry - 2.6 } })
  return m
end
local nuts = {
  { 32, 31, 7.2, 6.4 },
  { 22, 38, 7.0, 6.2 },
  { 42, 38, 7.0, 6.2 },
}
for _, s in ipairs(nuts) do s.m = nut(s[1], s[2], s[3], s[4]) s.n = A.body(s.m, s[1] - 0.3, s[2] + 0.5, s[3] + 0.5, 3, 0.6) end

-- cup geometry (front), used for AO on nuts
local cup = HP.poly{ { 12.5, 42 }, { 52.5, 42 }, { 48.5, 54 }, { 16.5, 54 } }
local lip = HP.rect(12, 41, 52, 43)

for i, s in ipairs(nuts) do
  local tok = { r = { name = "nut" .. i } }
  local b = {}
  for j = i + 1, #nuts do X.ao(b, s.m, nuts[j].m, 1, -1) end
  X.ao(b, s.m, lip, 2, -1)
  local idx = A.shade(c, s.m, s.n, GLZ, { tok = tok, bias = b, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.06, wrap = 0.2 })
  -- cool reflected light on the lower-right rim
  s.m:edge():each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    if dx > 2 and dy > -1 and not b[K(x, y)] then c:put(x, y, COOLR, tok) end
  end)
  -- dark tuft at the point, pale ridge just below it
  local tx, ty = floor(s[1] + 0.5), floor(s[2] - s[4] - 2)
  c:put(tx, ty, GLZ[1], tok) c:put(tx, ty + 1, GLZ[2], tok) c:put(tx - 1, ty + 2, GLZ[5], tok)
  -- sugar crust: a few pale crystals on the lit crown
  for _, o in ipairs{ { -3, -3 }, { -1, -4 }, { -4, -1 }, { 1, -3 } } do
    local x, y = floor(s[1] + o[1] + 0.5), floor(s[2] + o[2] + 0.5)
    if s.m:has(x, y) and (x + y) % 2 == 0 then c:put(x, y, SUG, tok) end
  end
  -- gloss: cream specular + 2x1 hi
  local gx, gy = A.glint(c, s.m, s.n, GLZ[6], 30, tok)
  if gx and s.m:has(gx + 1, gy + 1) then c:put(gx + 1, gy + 1, GLZ[6], tok) end
end
-- vein-like glaze streak on the back nut (stripes of a real chestnut showing through)
for _, p in ipairs{ { 35, 29 }, { 36, 31 }, { 36, 33 } } do c:put(p[1], p[2], GLZ[3]) end

-- cup body: flutes + vertical-axis light
local ftok = { r = { name = "foil" } }
local cn, cb = {}, {}
cup:each(function(x, y)
  local t = max(-0.95, min(0.95, ((x - 12) / 41) * 2 - 1))
  cn[K(x, y)] = { A.norm(t, 0.15, sqrt(1 - t * t)) }
  local f = x % 3
  cb[K(x, y)] = (f == 0) and -1 or (f == 1 and 1 or 0)
  if y >= 52 then cb[K(x, y)] = (cb[K(x, y)] or 0) - 1 end
end)
A.shade(c, cup, cn, FOIL, { tok = ftok, bias = cb, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.35 })
-- rolled lip: bright rounded band, crimped
lip:each(function(x, y)
  local t = (x - 12) / 40
  local col
  if y == 41 then col = t < 0.55 and FOIL[6] or FOIL[4]
  elseif y == 42 then col = t < 0.5 and FOIL[5] or FOIL[3]
  else col = t < 0.6 and FOIL[3] or FOIL[2] end
  if x % 3 == 0 and y ~= 41 then col = FOIL[2] end
  c:put(x, y, col, ftok)
end)
c:put(12, 41, FOIL[4], ftok) c:put(52, 41, FOIL[3], ftok)

-- quirk: syrup drip from the front-left nut over the lip and down a flute
local DR = { GLZ[3], GLZ[4], GLZ[5] }
for y = 41, 47 do c:put(26, y, y < 47 and DR[2] or DR[1]) c:put(25, y, (y < 46) and DR[3] or DR[2]) end
c:put(25, 48, DR[1]) c:put(26, 48, DR[1]) c:put(25, 49, GLZ[2])
c:put(25, 42, A.CREAM)

A.done(c, NAME)
