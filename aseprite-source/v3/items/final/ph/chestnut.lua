-- chestnut (final, Opus single pass, aB1r2_0). A glossy sweet chestnut, slim pointed teardrop leaning a touch right,
-- sitting in its split spiny burr: a cupped green husk with two lobes peeled outward showing the pale felt lining.
-- Material: per-pixel lit mahogany nut (6 tones, cool-violet shade), fine longitudinal grain stripes, glossy specular
-- streak + cream glint on the lit shoulder, cool reflected light lower-right, a straw-coloured silky tuft on the tip.
-- Husk: 6-tone olive skin, spine stars on the surface, spikes on the silhouette, felt lining with AO and the nut's
-- cast shadow; dark ambient row where the nut sinks into the cup.
-- quirk: a tiny grub peeks out of a wormhole on the nut's shade side.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2("chestnut")

local NUT   = { "#2e1420", "#58221f", "#803422", "#a8502a", "#cc7a3c", "#eeaa62" }
local SKIN  = { "#22361f", "#365229", "#527030", "#76923a", "#9db44c", "#c8d872" }
local LINE  = { "#7a6448", "#a08a62", "#c2ad80", "#dccb9e", "#efe2bc", "#fff4d6" }
local SPINE = { "#6f7a34", "#a9b052", "#d6d888" }
local SPEC, BOUNCE = "#fff4d6", "#7a4a6a"
local ntok, stok, ltok = { r = { name = "nut" } }, { r = { name = "skin" } }, { r = { name = "lining" } }

-- geometry ------------------------------------------------------------
local TIPY, BOTY = 10, 48
local function cxAt(y) return 32.5 + (30 - y) * 0.14 end
local function hwAt(t)
  local w = 11 * sin(pi / 2 * min(1, t / 0.68)) ^ 1.35
  if t > 0.8 then w = w * sqrt(max(0, 1 - ((t - 0.8) / 0.2) ^ 2 * 0.55)) end
  return w
end
local nut, NS, NT = HP.mask(), {}, {}
for y = TIPY, BOTY do
  local t = (y - TIPY) / (BOTY - TIPY)
  local w, cx = hwAt(t), cxAt(y)
  for x = floor(cx - w - 1), floor(cx + w + 1) do
    local s = (x + 0.5 - cx - 0.5) / max(w, 0.6)
    if abs(x - cx) <= w then nut:set(x, y) NS[K(x, y)] = max(-1, min(1, s)) NT[K(x, y)] = t end
  end
end
-- lining (inside of the cup, seen behind the nut)
local RIMY, RIMX = 41, 32
local lining = c:ellipse(RIMX, RIMY, 17, 5)
-- front bowl: below the near rim curve
local function rim(x) return RIMY + 4.6 * sqrt(max(0, 1 - ((x - RIMX) / 17) ^ 2)) end
local bowl = HP.mask()
c:ellipse(RIMX, 44, 18, 9):each(function(x, y) if y >= rim(x) then bowl:set(x, y) end end)
-- two lobes peeled outward
local function lobe(cx, cy, ux, uy, ra, rb) local l = sqrt(ux*ux + uy*uy) return A.rell(cx, cy, ux / l, uy / l, ra, rb) end
local lobeL = lobe(15, 39, -0.75, -0.62, 8.5, 3.6)
local lobeR = lobe(49.5, 38.5, 0.78, -0.6, 8.5, 3.6)
-- lining faces of the lobes: the inner-upper side
local linL = lobe(15.8, 37.6, -0.75, -0.62, 7.2, 2.2):clip(lobeL)
local linR = lobe(48.6, 37.2, 0.78, -0.6, 7.2, 2.2):clip(lobeR)
local skin = HP.mask():add(bowl):add(lobeL):add(lobeR)
skin:cut(linL):cut(linR)
-- keep the cup lining only where not covered by skin
local lin = lining:copy():cut(bowl)

-- spikes on the silhouette (drawn first so everything paints over the roots)
local husk = HP.mask():add(skin):add(linL):add(linR)
do
  local cnt = 0
  local pts = {}
  husk:edge():each(function(x, y) pts[#pts + 1] = { x, y } end)
  table.sort(pts, function(a, b) return math.atan(a[2] - 40, a[1] - 32) < math.atan(b[2] - 40, b[1] - 32) end)
  local lastA = -99
  for _, p in ipairs(pts) do
    local x, y = p[1], p[2]
    local dx, dy = x - 32, y - 41
    local a = math.atan(dy, dx)
    local l = sqrt(dx*dx + dy*dy)
    local outside = not husk:has(x + (dx > 0 and 1 or -1), y) or not husk:has(x, y + 1)
    if skin:has(x, y) and outside and l > 9 and (a - lastA) > 0.2 and not (y < RIMY and abs(dx) < 13) then
      lastA = a
      local ux, uy = dx / l, dy / l
      local L = 2 + (X.hash(x, y, 3) > 0.5 and 1 or 0)
      for i = 1, L do
        local sx, sy = floor(x + ux * i + .5), floor(y + uy * i + .5)
        if not husk:has(sx, sy) then c:put(sx, sy, i == L and SPINE[1] or SPINE[2], stok) end
      end
    end
  end
end

-- lining (cup back) ---------------------------------------------------
do
  local n = X.pillow(lin, 2)
  for k, v in pairs(n) do n[k] = { -v[1] * 0.6, -v[2] * 0.6, v[3] } end -- concave
  local bias = {}
  X.ao(bias, lin, nut, 2, -1)
  A.cast(bias, lin, nut, 2, 1, -1)
  lin:each(function(x, y) if y <= RIMY - 4 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
  A.toneN(c, lin, n, LINE, { tok = ltok, bias = bias, cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
end

-- nut -----------------------------------------------------------------
local nn = {}
nut:each(function(x, y)
  local k = K(x, y)
  local s, t = NS[k], NT[k]
  local ny = (t < 0.5) and -0.55 * (1 - t / 0.5) or 0.5 * ((t - 0.5) / 0.5) ^ 1.5
  nn[k] = { A.norm(s * 0.95, ny, sqrt(max(0.05, 1 - s * s))) }
end)
do
  local bias = {}
  X.ao(bias, nut, bowl, 2, -1)
  local v = X.light(nn, { amb = 0.05, wrap = 0.2 })
  local idx = X.tone(c, nut, v, NUT, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = bias, tok = ntok })
  -- longitudinal grain stripes (one tone darker, broken)
  for _, gs in ipairs({ -0.62, -0.22, 0.2, 0.58 }) do
    nut:each(function(x, y) local k = K(x, y)
      local t = NT[k]
      local w = hwAt(t)
      if t > 0.18 and t < 0.92 and abs((NS[k] - gs) * w) < 0.5 and X.hash(x, y, 7) > 0.22 then
        c:put(x, y, NUT[max(1, idx[k] - 1)], ntok) end end)
  end
  -- cool reflected light on the lower-right rim
  local r = X.rim(nn)
  nut:edge():each(function(x, y) local k = K(x, y)
    if NS[k] > 0.75 and NT[k] > 0.4 and NT[k] < 0.82 and not bowl:has(x, y) then c:put(x, y, BOUNCE, ntok) end end)
  -- glossy specular streak on the lit shoulder
  for y = 19, 25 do
    local t = (y - TIPY) / (BOTY - TIPY)
    local x = floor(cxAt(y) - hwAt(t) * 0.5 + .5)
    c:put(x, y, NUT[6], ntok)
  end
  c:put(floor(cxAt(21) - hwAt((21 - TIPY) / (BOTY - TIPY)) * 0.5 + .5), 21, SPEC, ntok)
  c:put(floor(cxAt(22) - hwAt((22 - TIPY) / (BOTY - TIPY)) * 0.5 + .5), 22, SPEC, ntok)
  -- pale band where the polished shell turns matte at the top
  -- silky tuft on the tip
  local tx = floor(cxAt(TIPY) + .5)
  c:put(tx, TIPY - 1, "#d8c28a", ntok) c:put(tx, TIPY - 2, "#efe0b0", ntok)
  c:put(tx + 1, TIPY - 3, "#d8c28a", ntok) c:put(tx - 1, TIPY - 3, "#efe0b0", ntok)
  c:put(tx, TIPY, "#a08458", ntok)
  -- quirk: wormhole + grub on the shade side
  local hx, hy = 38, 33
  c:put(hx, hy, "#2b1c26", ntok) c:put(hx + 1, hy, "#2b1c26", ntok) c:put(hx, hy + 1, "#3a1a26", ntok) c:put(hx + 1, hy + 1, NUT[1], ntok)
  c:put(hx, hy - 1, "#f4e6c0", ntok) c:put(hx + 1, hy - 1, "#e2cc9a", ntok)
  c:put(hx, hy - 2, "#fff4d6", ntok) c:put(hx + 1, hy - 2, "#2b1c26", ntok) -- head with an eye
end

-- husk skin -----------------------------------------------------------
do
  local n = X.pillow(skin, 3)
  local bias = {}
  -- shade under the lobes where they meet the bowl
  skin:each(function(x, y) local k = K(x, y)
    if bowl:has(x, y) and (lobeL:has(x - 1, y - 1) or lobeR:has(x + 1, y - 1)) and not (lobeL:has(x, y) or lobeR:has(x, y)) then bias[k] = -1 end end)
  local idx = A.toneN(c, skin, n, SKIN, { tok = stok, bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
  -- near rim lip: bright row
  bowl:each(function(x, y) if not bowl:has(x, y - 1) and not lobeL:has(x, y) and not lobeR:has(x, y) and abs(x - RIMX) < 15 then
    c:put(x, y, SKIN[min(6, (idx[K(x, y)] or 4) + 1)], stok) end end)
  -- spine stars on the surface
  skin:shrink(1):each(function(x, y)
    if (x * 3 + y * 5) % 7 == 0 and y % 2 == 0 and X.hash(x, y, 11) > 0.35 then
      local i = idx[K(x, y)] or 3
      c:put(x, y, SPINE[i >= 4 and 3 or 2], stok)
      if skin:has(x + 1, y + 1) then c:put(x + 1, y + 1, SKIN[max(1, i - 2)], stok) end
    end
  end)
end
-- lobe linings (felt)
for _, lm in ipairs({ linL, linR }) do
  local n = X.pillow(lm, 1.5)
  A.toneN(c, lm, n, LINE, { tok = ltok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
  -- dark seam where felt meets skin
  lm:each(function(x, y) if skin:has(x, y + 1) then c:put(x, y, LINE[2], ltok) end end)
end
A.saveTo(c, "ph", "chestnut")
