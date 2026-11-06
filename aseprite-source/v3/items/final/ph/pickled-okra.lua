-- pickled-okra (C34, Opus artist pass). Tall slim straight-walled jar, gingham cloth cap pinched by a twisted twine tie
-- with a knot and loose ends; inside, ridged okra pods packed head-to-tail in pale lime brine (6-tone tube light,
-- ridge grooves with lit lips, ruffled calyx caps, stem stubs), a dill sprig behind, garlic cloves and mustard seeds on
-- the thick glass foot. Glass: lit left wall, broken specular streak, cool bounce on the right, meniscus line.
-- quirk: a little garden snail is gliding up the outside of the glass (okra is slimy too).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("pickled-okra")

local POD  = { "#163c34", "#225638", "#33743f", "#4c9546", "#74b655", "#a6d473" }
local POD2 = { "#123029", "#1b4532", "#295f39", "#3c7c40", "#5c9a4c", "#86b862" } -- back pods, a touch duller
local CAL  = { "#3a4228", "#5a6a32", "#80923c", "#a8b84e", "#cad66e", "#e8f0a0" }
local STEM = { "#3a3226", "#5a4a30", "#7c6a3a", "#9c8a48", "#bcae62", "#d8cc84" }
local BRINE = { "#567f68", "#7ea684", "#a6c99a", "#c8e0b2", "#e0f0cc", "#f4fbe4" }
local DILL = { "#1c4a3a", "#2e6a44", "#4a8c4c", "#6aac58", "#90c86a", "#b8e08a" }
local GARL = { "#7a6a7a", "#a898a2", "#cfc2bf", "#e8ddd2", "#f6efe2", "#fffaf0" }
local MUST = { "#6e4a1f", "#a0702a", "#c89a34", "#e2bc4a", "#f4d872", "#fff0a8" }

A.shadow(32, 55, 13, 1.5)
local J = A.jar{ pts = { { 12, 8 }, { 15, 8 }, { 19, 10 }, { 50, 10 }, { 53, 9 } }, level = 20, brine = BRINE }
local IN = J.inside

-- dill sprig behind everything: wavy stalk with thread-like fronds
do
  local stalk = { { 28, 47 }, { 28, 42 }, { 29, 36 }, { 28, 30 }, { 29, 24 } }
  for i = 1, #stalk - 1 do A.ln(stalk[i][1], stalk[i][2], stalk[i + 1][1], stalk[i + 1][2], DILL[3], IN) end
  for _, f in ipairs{ { 28, 42, -2, -2 }, { 29, 36, 2, -3 }, { 28, 30, -2, -3 }, { 29, 24, 2, -2 }, { 29, 24, -2, -2 }, { 29, 36, -2, -3 } } do
    A.ln(f[1], f[2], f[1] + f[3], f[2] + f[4], DILL[5], IN)
    c:put(f[1] + f[3], f[2] + f[4], DILL[6])
  end
end

-- okra pod: cap at (ax,ay), tip at (bx,by); bend = sideways offset of the middle
local function pod(ax, ay, bx, by, bend, ramp)
  local mx, my = (ax + bx) / 2 + bend, (ay + by) / 2
  local p = { { ax, ay }, { ax + (mx - ax) * 0.7, ay + (my - ay) * 0.7 }, { bx + (mx - bx) * 0.7, by + (my - by) * 0.7 }, { bx, by } }
  local wf = function(t)
    if t < 0.05 then return 1.1 end
    if t < 0.15 then return 2.6 end
    return 2.25 * ((1 - t) / 0.85) ^ 0.65 + 0.3
  end
  local m, n, T, S = G.tube(p, wf)
  m:clip(IN)
  local stem, cal, body = HP.mask(), HP.mask(), HP.mask()
  m:each(function(x, y) local t = T[K(x, y)]
    if t < 0.05 then stem:set(x, y) elseif t < 0.16 then cal:set(x, y) else body:set(x, y) end end)
  local _, idx = A.part(body, n, ramp, { amb = 0.1, wrap = 0.3, edge = 2 })
  -- five-sided pod: grooves at |s|~0.5 and on the centre-shade side, lit lips beside them
  body:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t > 0.2 and t < 0.93 then
      if abs(s + 0.5) < 0.17 or abs(s - 0.42) < 0.15 then A.darken(x, y, 1)
      elseif abs(s + 0.2) < 0.12 then A.set(x, y, (A.info[k].i or 3) + 1) end
    end
  end)
  -- fuzz-free waxy glint on the lit lip
  local gx, gy = G.bez(p, 0.32)
  if IN:has(floor(gx - 1), floor(gy)) then c:put(floor(gx - 1), floor(gy), "#d8f0a0") end
  -- calyx: ruffled collar, darker where it meets the pod
  A.part(cal, n, CAL, { amb = 0.15, wrap = 0.3 })
  cal:each(function(x, y) local t = T[K(x, y)]
    if t > 0.135 then A.set(x, y, 1) elseif (x + y) % 3 == 0 then A.darken(x, y, 1) end end)
  A.part(stem, n, STEM, { amb = 0.2, wrap = 0.3 })
end
-- back row (head down), then front row (alternating)
pod(34, 50, 35, 26, 0.8, POD2)
pod(25, 22, 26, 47, -1.2, POD)
pod(31, 49, 30, 25, 1.0, POD)
pod(38, 23, 37, 46, 1.2, POD)

-- garlic cloves resting on the foot
for _, g in ipairs{ { 27, 48, 2.6, 2.0, -0.3 }, { 36, 48.5, 2.3, 1.8, 0.4 } } do
  local m = A.ell(g[1], g[2], g[3], g[4], g[5])
  local mm = A.part(m, A.ellN(m, g[1] - .3, g[2] - .3, g[3], g[4], g[5]), GARL, { clip = IN, amb = 0.15, wrap = 0.3 })
  c:put(floor(g[1]), floor(g[2] - g[4]) , GARL[3])
  c:put(floor(g[1] - 1), floor(g[2] - 1), GARL[6])
end
-- mustard seeds
for _, s in ipairs{ { 30, 49 }, { 33, 49 }, { 24, 49 }, { 39, 48 }, { 32, 47 } } do
  if IN:has(s[1], s[2]) then c:put(s[1], s[2], MUST[4]) c:put(s[1] + 1, s[2], MUST[2]) end
end

A.glassFront(J, { top = 7, gaps = { { 30, 32 }, { 41, 42 } }, wide = 9 })

-- cloth cap: gingham dome over the mouth, pinched by twine, flared skirt with folds and a pinked hem
local cap = HP.mask()
local function capW(y)
  if y <= 9 then return 7 + (y - 6) * 0.9 end
  if y <= 12 then return 9.8 end
  if y <= 14 then return 9.0 end   -- pinch under the twine
  return 9.6 + (y - 14) * 0.7
end
for y = 6, 18 do local w = capW(y) for x = floor(32 - w + .5), floor(31 + w + .5) do
  local hem = (y == 18 and (x % 3 == 1)) or (y == 17 and x == floor(32 - w + .5))
  if not (y == 18 and x % 3 ~= 1 and false) then cap:set(x, y) end
end end
-- pinked hem: drop alternating pixels on the bottom row
for x = 0, 63 do if x % 2 == 0 then cap.s[K(x, 18)] = nil end end
local RED   = { "#5c1830", "#8e2236", "#b8303a", "#d84a40", "#ee7458", "#ffa080" }
local PINK  = { "#7a3a4a", "#b05a62", "#d07a78", "#e89a90", "#f6bca8", "#ffd8c4" }
local CRM   = { "#8a7068", "#bca890", "#dccaa8", "#f0e2c0", "#fbf0d6", "#fff8e8" }
local capN = {}
cap:each(function(x, y)
  local t = max(-.95, min(.95, (x + .5 - 32) / (capW(y) + .5)))
  local ny = (y <= 8) and -0.55 or ((y >= 15) and 0.2 or 0)
  local l = sqrt(t * t + ny * ny + max(0.05, 1 - t * t))
  capN[K(x, y)] = { t / l, ny / l, sqrt(max(0.05, 1 - t * t)) / l }
end)
local _, cidx = A.part(cap, capN, RED, { amb = 0.12, wrap = 0.3, nocontact = true })
cap:each(function(x, y)
  local k = K(x, y)
  local i = cidx[k]
  -- folds on the skirt: alternating lit/shade strips
  if y >= 15 then local f = (x - 22) % 4 if f == 0 then i = i - 1 elseif f == 1 then i = i + 1 end end
  i = max(1, min(6, i))
  local a, b = floor(x / 2) % 2 == 0, floor(y / 2) % 2 == 0
  local rp = (a and b) and RED or ((a or b) and PINK or CRM)
  A.info[k] = { ramp = rp, i = i }
  c:put(x, y, rp[i])
end)
-- twine: twisted cord across the pinch (rows 13-14) with a knot on the left and two loose ends
local TW = { "#5c3a2c", "#8a5e3c", "#b88a54", "#d9b070", "#efd29a" }
for x = 22, 41 do
  c:put(x, 13, (x % 2 == 0) and TW[4] or TW[2])
  c:put(x, 14, (x % 2 == 1) and TW[3] or TW[1])
end
c:put(23, 13, TW[5])
A.map({ ".ab", "acd", ".bd", }, 20, 12, { a = TW[4], b = TW[2], c = TW[5], d = TW[1] })
A.ln(21, 15, 20, 19, TW[4]) A.ln(22, 15, 22, 18, TW[2]) c:put(20, 20, TW[3]) c:put(22, 19, TW[1])
-- gold stitch along the hem
c:stitch({ { 22, 16 }, { 41, 16 } })
-- top sparkle on the dome
c:put(28, 7, "#fff8e8") c:put(29, 7, "#fff8e8")

-- quirk: snail gliding up the glass, right wall (shell swirl, eye stalks)
local SN = { k = "#2b1c26", a = "#e8b982", b = "#b97a4a", d = "#864c33", e = "#51302b", h = "#ffe0a8",
  s = "#c8b4c8", t = "#9c86a2", u = "#ecdcec" }
A.map({
  "k.k....",
  "u.u....",
  "uu.bbd.",
  "sabaabd",
  "uahbdbd",
  "sabeedd",
  "tbbdddd",
  "tt.....",
}, 42, 31, SN)
A.fin()
