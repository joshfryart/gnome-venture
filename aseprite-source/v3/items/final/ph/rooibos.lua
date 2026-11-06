-- rooibos (Sonnet high, single pass). A small hand-tied bundle of red-bush twigs: four thin russet stems fanning out of a
-- twine tie (twisted cord, bow, two tails), the lower ends cut square with pale wood. Needle leaves in hard 1 px strokes
-- sprout along the upper stems in paired tufts, each with a dark underside stroke: green and fresh at the tips, oxidising
-- to russet toward the tie. quirk: one tiny yellow pea-flower has opened on the tip of the right twig.
local NAME = "rooibos"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }

local STEM = { "#2e1822", "#5a2a2a", "#8b4030", "#b85e38", "#dc8650", "#f5b878" }
local GREEN = { "#17402f", "#27603f", "#3d8749", "#62ac56", "#90cc66", "#c4e88c" }
local RUSS = { "#3a2224", "#68382c", "#955a34", "#bf8446", "#e0b15e", "#f6d98a" }
local TWINE = { "#5c3a24", "#8c5c32", "#b98644", "#dcb064", "#f4d896" }
local CUT = { "#8a6044", "#c9a070", "#ecd2a0", "#fbeccc" }
local FLOW = { "#a85f1c", "#e29a1e", "#f9c93a", "#ffe98a" }
local stok, ntok, ttok, ftok = {r={name="stem"}}, {r={name="needle"}}, {r={name="twine"}}, {r={name="flower"}}

local twigs = {
  { { 32, 54 }, { 32, 41 }, { 29, 28 }, { 32, 11 }, w = 0.8 },
  { { 30, 54 }, { 26, 42 }, { 19, 32 }, { 15, 16 }, w = 0.75 },
  { { 34, 54 }, { 38, 42 }, { 46, 33 }, { 50, 18 }, w = 0.75 },
  { { 31, 56 }, { 29, 46 }, { 22, 40 }, { 21, 27 }, w = 0.7 },
}
local all = HP.mask()
local masks = {}
local TIEY0, TIEY1 = 46, 49
for i, tw in ipairs(twigs) do
  local m, n, T = G.tube(tw, function(t) return tw.w * (1 - 0.35 * t) + 0.15 end)
  masks[i] = { m = m, n = n, T = T }
end
-- needles layer (under the stems' top, over lower twigs): draw per twig after its stem
local function needles(tw, m, seed)
  local dark, lit = {}, {}
  local N = 16
  local t0 = 0.3
  for i = 0, N do
    local t = t0 + (0.99 - t0) * i / N
    local x, y = G.bez(tw, t)
    local x1, y1 = G.bez(tw, min(1, t + 0.02))
    local x0, y0 = G.bez(tw, max(0, t - 0.02))
    local dx, dy = x1 - x0, y1 - y0
    local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    local L = (7.4 - 3.6 * (t - t0) / (1 - t0)) * (0.8 + 0.4 * X.hash(i, seed, 3))
    for _, side in ipairs{ -1, 1 } do
      local a = side * (0.5 + 0.3 * X.hash(i, seed + side, 5))
      if true then
        local ux, uy = dx * cos(a) - dy * sin(a), dx * sin(a) + dy * cos(a)
        local ex, ey = x + ux * L, y + uy * L
        -- tone: facing up-left = lit; base portion oxidised russet
        local face = (-ux * 0.6 - uy * 0.8)
        local ramp = (t < 0.5 + 0.1 * X.hash(i, seed, 8)) and RUSS or GREEN
        lit[#lit + 1] = { x, y, ex, ey, ramp, face }
      end
    end
  end
  -- terminal tuft
  local tx, ty = G.bez(tw, 1)
  for _, a in ipairs{ -0.5, 0, 0.5 } do
    local x1, y1 = G.bez(tw, 0.97)
    local dx, dy = tx - x1, ty - y1
    local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    local ux, uy = dx * cos(a) - dy * sin(a), dx * sin(a) + dy * cos(a)
    lit[#lit + 1] = { tx, ty, tx + ux * 4.2, ty + uy * 4.2, GREEN, -ux * 0.6 - uy * 0.8 }
  end
  -- shadow strokes first (offset down-right), then lit strokes
  for _, s in ipairs(lit) do
    G.bres(c, s[1] + 1, s[2] + 1, s[3] + 1, s[4] + 1, function(x, y, k, n)
      if m:has(x, y) then return nil end
      return s[5][1 + (k > n * 0.5 and 1 or 0)] end, ntok)
  end
  for _, s in ipairs(lit) do
    G.bres(c, s[1], s[2], s[3], s[4], function(x, y, k, n)
      if m:has(x, y) then return nil end
      local base = s[6] > 0.15 and 4 or (s[6] > -0.3 and 3 or 2)
      local ti = base + (k > n * 0.6 and 1 or 0)
      if k == n then ti = min(6, ti + 1) end
      return s[5][max(1, min(6, ti))] end, ntok)
  end
end

local order = { 1, 2, 3, 4 }
for _, i in ipairs(order) do
  local tw, M = twigs[i], masks[i]
  local bias = {}
  for j = 1, i - 1 do X.ao(bias, M.m, masks[j].m, 1, -1) end
  G.toneN(c, M.m, M.n, STEM, { bias = bias, tok = stok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.12, wrap = 0.3 })
  -- cut end at the bottom: pale square wood
  local cx, cy = G.bez(tw, 0)
  local ce = G.oval(cx, cy + 0.2, 1.7, 1.2, 0, 1)
  ce:each(function(x, y) c:put(x, y, (x == floor(cx) and y == floor(cy)) and CUT[1] or ((x + y) % 2 == 0 and CUT[3] or CUT[4]), stok) end)
  c:put(floor(cx), floor(cy + 1), CUT[2], stok)
  needles(tw, M.m, i * 7)
end
-- the twigs' stem mask for needle-overlap is local; draw all stems' top highlight line again lightly
for i, M in ipairs(masks) do
  M.m:each(function(x, y) local k = K(x, y)
    if M.T[k] > 0.3 and M.T[k] < 0.95 and (M.n[k][1] < -0.45) and (x + y) % 3 ~= 0 then c:put(x, y, STEM[5], stok) end end)
end

-- tie: twisted twine band around the bundle with AO above/below
local band = HP.mask()
for _, M in ipairs(masks) do M.m:each(function(x, y) if y >= TIEY0 and y <= TIEY1 then band:set(x, y) end end) end
local bm = band:copy():grow(1):clip(c:rect(0, TIEY0, 63, TIEY1))
bm:each(function(x, y)
  local ph = (x + y * 2) % 4
  c:put(x, y, ph == 0 and TWINE[4] or (ph == 1 and TWINE[3] or (ph == 2 and TWINE[2] or TWINE[3])), ttok)
end)
bm:each(function(x, y)
  if y == TIEY1 then c:put(x, y, TWINE[1], ttok) end
  if y == TIEY0 then c:put(x, y, (x % 2 == 0) and TWINE[5] or TWINE[4], ttok) end
end)
-- ao rows just above and below the tie on the stems
for _, M in ipairs(masks) do M.m:each(function(x, y)
  if (y == TIEY0 - 1 or y == TIEY1 + 1) and not bm:has(x, y) then c:put(x, y, STEM[1], stok) end end) end
-- bow on the right: two loops + two tails
local bx, by = 38, 47
local function ring(cx, cy, rx, ry, ang)
  local m = G.oval(cx, cy, rx, ry, ang, 1)
  local inner = m:copy():shrink(1)
  m:each(function(x, y)
    if not inner:has(x, y) then c:put(x, y, (x + y) % 2 == 0 and TWINE[3] or TWINE[4], ttok)
    elseif true then end
  end)
  -- shadow on the lower-right of the ring
  m:each(function(x, y) if not inner:has(x, y) and x > cx and y > cy then c:put(x, y, TWINE[2], ttok) end end)
end
ring(bx + 3, by - 2, 3.0, 2.0, -0.7)
ring(bx + 3, by + 2, 3.0, 2.0, 0.7)
local t1 = G.tube({ { bx, by }, { bx + 1, by + 3 }, { bx + 2, by + 5 }, { bx + 1, by + 8 } }, function(t) return 0.8 end)
local t2 = G.tube({ { bx, by }, { bx + 3, by + 4 }, { bx + 5, by + 6 }, { bx + 6, by + 8 } }, function(t) return 0.8 end)
for _, tm in ipairs{ t1, t2 } do tm:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and TWINE[3] or TWINE[2], ttok) end) end
-- knot
c:fillMask(c:rect(bx - 1, by - 1, bx + 1, by + 1), TWINE[3])
c:put(bx - 1, by - 1, TWINE[5], ttok) c:put(bx + 1, by + 1, TWINE[1], ttok) c:put(bx, by, TWINE[2], ttok)

-- quirk: yellow pea-flower on the right twig tip
local fx, fy = G.bez(twigs[3], 1)
fx, fy = floor(fx + 0.5), floor(fy + 0.5)
c:fillMask(c:rect(fx - 1, fy - 2, fx + 1, fy), FLOW[3])
c:put(fx - 2, fy - 1, FLOW[3], ftok) c:put(fx + 2, fy - 1, FLOW[2], ftok)
c:put(fx - 1, fy - 2, FLOW[4], ftok) c:put(fx, fy - 2, FLOW[4], ftok)
c:put(fx, fy - 1, FLOW[2], ftok) c:put(fx + 1, fy, FLOW[1], ftok) c:put(fx - 1, fy, FLOW[2], ftok) c:put(fx, fy + 1, FLOW[1], ftok)

G.save(c, NAME)
