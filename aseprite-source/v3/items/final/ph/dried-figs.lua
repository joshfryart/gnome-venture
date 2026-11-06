-- dried-figs (Opus single pass). A market string of three pressed dried figs threaded on twisted twine,
-- hanging from a twine loop with a knot; frayed twine tail below. Vertical and slim.
-- Material: pillow-lit flattened discs on a 6-tone purple-brown ramp, radial wrinkles from the eye (dark crease
-- + lit lip), dusty sugar bloom specks, stalk nub, cream specular, cool reflected light lower-right; twine with
-- a 3-tone twist; ambient shading where the twine enters each fig.
-- quirk: the bottom fig has a bite out of it, showing pink seedy flesh.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, atan, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.atan, math.sqrt, math.max, math.min
local c = A.new("dried-figs")
local FIG   = { "#2a1430", "#46203e", "#663250", "#88485e", "#a8666a", "#c88c7c" }
local BLOOM = "#d6bcb4"
local STALK = { "#4a3a24", "#7a6a3a", "#a8984e" }
local FLESH = { "#7d2c5e", "#f07a8a", "#ffa898", "#ffd0b0" }
local SEED  = "#f2cf72"
local TW    = { "#5e4028", "#8e6a40", "#bf9a62", "#e4c88e" }
local SPEC, BOUNCE = "#fff1cf", "#6a5c8c"

-- twine path (slight sway)
local twp = { { 32, 11 }, { 30, 24 }, { 34, 37 }, { 32, 51 } }
local tm, tn, TT, TS, samp = A.tube(twp, function(t) return 0.95 end)
local LEN = 40
local ttok = { r = { name = "twine" } }
local function twine(m)
  m:each(function(x, y) local k = K(x, y)
    local ph = (TT[k] or 0) * LEN + (TS[k] or 0) * 1.6
    local i = floor(ph % 3)
    c:put(x, y, TW[({ 3, 2, 4 })[i + 1]], ttok)
    if (TS[k] or 0) > 0.4 then c:put(x, y, TW[i == 2 and 2 or 1], ttok) end
  end)
end
-- hanging loop + knot
local loop = HP.mask()
for y = 2, 14 do for x = 24, 40 do
  local q = ((x - 32) / 4.2) ^ 2 + ((y - 7.5) / 4.2) ^ 2
  local q2 = ((x - 32) / 3.0) ^ 2 + ((y - 7.5) / 3.0) ^ 2
  if q <= 1 and q2 > 1 then loop:set(x, y) end
end end
loop:each(function(x, y)
  local a = atan(y - 7.5, x - 32)
  local i = floor((a * 3.2) % 3)
  local lit = (x - 32) + (y - 7.5) < -1
  c:put(x, y, TW[lit and ({ 4, 3, 3 })[i + 1] or ({ 2, 1, 2 })[i + 1]], ttok)
end)
twine(tm)
-- knot under the loop
for _, p in ipairs{ { 31, 11, 3 }, { 32, 11, 4 }, { 33, 11, 2 }, { 31, 12, 2 }, { 32, 12, 3 }, { 33, 12, 1 } } do c:put(p[1], p[2], TW[p[3]], ttok) end
-- frayed tail
for _, p in ipairs{ { 31, 52, 3 }, { 30, 53, 2 }, { 30, 54, 3 }, { 33, 52, 2 }, { 34, 53, 3 }, { 34, 54, 1 } } do c:put(p[1], p[2], TW[p[3]], ttok) end

-- figs
local figs = {
  { 30.5, 19.5, 8.0, 5.7, -0.25, 1 },
  { 33.5, 31.5, 8.4, 5.9,  0.22, 2 },
  { 31.0, 43.5, 7.8, 5.6, -0.12, 3 },
}
local ftok = { r = { name = "fig" } }
local prev
for i, f in ipairs(figs) do
  local m = A.oval(f[1], f[2], f[3], f[4], f[5], 1)
  -- stalk nub on the upper-left
  local ca, sa = cos(f[5]), sin(f[5])
  local nx, ny = f[1] - ca * (f[3] + 0.6), f[2] - sa * (f[3] + 0.6) - 1
  local nub = A.oval(nx + 0.5, ny + 0.4, 2.2, 1.5, f[5] - 0.5, 1)
  m:add(nub)
  -- bite on the last fig
  local bite = HP.mask()
  if i == 3 then
    bite:add(c:ellipse(f[1] + 7, f[2] + 1, 3, 3)):add(c:ellipse(f[1] + 5, f[2] + 4, 3, 2.5))
    m:cut(bite)
  end
  local n, d = X.pillow(m, 3.4)
  local bias = {}
  if prev then X.ao(bias, m, prev, 1, -1) end
  -- radial wrinkles from the eye (slightly below centre)
  local ex, ey = f[1] + 0.5, f[2] + 1
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - ex, y - ey
    local r = sqrt(dx * dx + dy * dy)
    local a = atan(dy, dx)
    if r > 2.2 and (d[k] or 0) > 0.6 then
      local w = cos(a * 6 + r * 0.25 + i * 1.3)
      if w > 0.9 then bias[k] = (bias[k] or 0) - 1
      elseif cos(a * 6 + r * 0.25 + i * 1.3 + 0.55) > 0.93 then bias[k] = (bias[k] or 0) + 1 end
    end
    -- twine entry dimple at top and bottom: AO
    if abs(x - (i == 2 and 32 or 31)) <= 1 and (abs(y - (f[2] - f[4])) <= 1) then bias[k] = (bias[k] or 0) - 2 end
  end)
  local idx = A.tone(c, m, n, FIG, { bias = bias, amb = 0.06, wrap = 0.25 })
  -- sugar bloom specks on mid/lit tones
  m:each(function(x, y) local k = K(x, y)
    if (idx[k] or 0) >= 3 and (idx[k] or 0) <= 5 and X.hash(x, y, 11 + i) > 0.91 then c:put(x, y, BLOOM, ftok) end end)
  -- eye
  c:put(floor(ex), floor(ey), FIG[1], ftok)
  -- stalk nub tip
  c:put(floor(nx), floor(ny), STALK[3], ftok) c:put(floor(nx) + 1, floor(ny), STALK[2], ftok) c:put(floor(nx), floor(ny) + 1, STALK[1], ftok)
  A.bounce(c, m, n, BOUNCE, 0.66, ftok)
  A.glint(c, m, n, SPEC, FIG[6], ftok, 36)
  if i == 3 then
    -- bite face: pink flesh band along the bite edge with gold seeds
    local rim = bite:grow(2):clip(m)
    local inner = bite:grow(1):clip(m)
    rim:each(function(x, y) c:put(x, y, inner:has(x, y) and FLESH[3] or FLESH[2], ftok) end)
    inner:each(function(x, y) if X.hash(x, y, 5) > 0.6 then c:put(x, y, SEED, ftok) end end)
    -- skin lip at the outer edge of the bite face
    rim:edge():each(function(x, y) if not inner:has(x, y) then c:put(x, y, FLESH[1], ftok) end end)
    local hx, hy
    inner:each(function(x, y) if not hx or x + y < hx + hy then hx, hy = x, y end end)
    if hx then c:put(hx, hy, FLESH[4], ftok) end
  end
  prev = m
end
A.done(c, "dried-figs")
