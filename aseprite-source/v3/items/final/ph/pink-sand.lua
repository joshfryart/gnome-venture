-- pink-sand (aC35_1, Opus single pass). A conical heap of rose-pink sand, peak left of centre, a second shoulder
-- slumping right. Per-pixel cone lighting (lit upper-left face, cool shade face lower right), curved wind ripples,
-- grain speckle (darker grains + a few pale quartz glints), a flat footprint with a dark ambient row at the base,
-- and a few loose grains rolled off to the right.
-- quirk: a tiny cream spiral seashell half-buried in the slope.
local NAME = "pink-sand"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SAND = { "#5e2648", "#8e3e64", "#bd5d80", "#e0849c", "#f4aab5", "#ffd3d0" }
local COOL = "#9a6aa8"
local QTZ = "#fff4d6"

local CX, BASE, HW = 30, 47, 23
-- top profile: main peak at CX, shoulder to the right
local function top(x)
  local d = (x - CX) / HW
  if abs(d) > 1 then return nil end
  local p = (1 - abs(d) ^ 1.5) ^ 1.5
  local sh = 0.32 * math.exp(-((x - 43) / 5.5) ^ 2)
  return BASE - 27 * p - 9 * sh + 0.8 * sin(x * 0.9)
end
local function bot(x) local d = (x - CX) / HW return BASE + 3.2 * sqrt(max(0, 1 - d * d)) end

local m, n, TT = HP.mask(), {}, {}
for x = CX - HW, CX + HW do
  local ty = top(x)
  if ty then
    local by = bot(x)
    for y = floor(ty + 0.5), floor(by + 0.5) do
      m:set(x, y)
      local t = (y - ty) / max(1, by - ty)       -- 0 at crest, 1 at footprint
      local u = (x - CX) / HW
      -- cone normal: faces out sideways, tilted up near the crest, toward viewer lower down
      local nx = u * 0.9
      local ny = -0.75 * (1 - t) - 0.1
      local nz = 0.35 + 0.65 * t
      n[K(x, y)] = { G.norm(nx, ny, nz) }
      TT[K(x, y)] = t
    end
  end
end

local bias = {}
-- dark ambient rows along the footprint
m:each(function(x, y) if not m:has(x, y + 1) then bias[K(x, y)] = -2 elseif not m:has(x, y + 2) then bias[K(x, y)] = -1 end end)

-- quirk shell mask (so the sand around it gets AO)
local shell = HP.mask()
for _, q in ipairs{ {39,37},{40,37},{41,37},{38,38},{39,38},{40,38},{41,38},{42,38},{38,39},{39,39},{40,39},{41,39},{42,39},{39,40},{40,40},{41,40} } do shell:set(q[1], q[2]) end
X.ao(bias, m, shell, 1, -1)
G.cast(bias, m, shell, 1, 1, -1)

local tok = { r = { name = "sand" } }
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local idx = X.tone(c, m, v, SAND, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })

-- wind ripples: curved bands across the slope, dark trough under a lit lip
m:each(function(x, y) local k = K(x, y)
  local t = TT[k]
  if t < 0.18 or t > 0.82 or bias[k] then return end
  local ph = t * 5.2 + 0.12 * sin((x - CX) * 0.35)
  local f = ph - floor(ph)
  local i = idx[k]
  if f < 0.12 and X.hash(x, y, 3) < 0.85 then c:put(x, y, SAND[max(1, i - 1)], tok)
  elseif f >= 0.12 and f < 0.24 and x < CX + 6 and X.hash(x, y, 4) < 0.7 then c:put(x, y, SAND[min(6, i + 1)], tok) end
end)
-- grain speckle
local glints = 0
m:each(function(x, y) local k = K(x, y)
  if bias[k] and bias[k] <= -2 then return end
  local h = X.hash(x, y, 11)
  local i = idx[k]
  if h < 0.09 then c:put(x, y, SAND[max(1, i - 1)], tok)
  elseif h > 0.95 and i >= 3 then c:put(x, y, SAND[min(6, i + 1)], tok) end
end)
for _, q in ipairs{ {22, 27}, {17, 38}, {27, 33}, {33, 25} } do if m:has(q[1], q[2]) then c:put(q[1], q[2], QTZ, tok) end end
-- cool reflected light along the shade-side edge
m:edge():each(function(x, y) local k = K(x, y)
  if x > CX + 6 and TT[k] > 0.35 and TT[k] < 0.85 and not bias[k] then c:put(x, y, COOL, tok) end end)

-- quirk: half-buried spiral seashell (cream conch, coil rings, pink aperture)
local stok = { r = { name = "shell" } }
local SH = { "#8f5a5e", "#c99a8e", "#ecd2b8", "#fff4d6" }
local rows = {
  "  433 ",
  " 44322",
  " 43212",
  "  3221",
}
for j, r in ipairs(rows) do for i = 1, #r do local ch = r:sub(i, i)
  if ch ~= " " then c:put(37 + i, 36 + j, SH[tonumber(ch)], stok) end end end
c:put(40, 39, "#e0849c", stok) -- aperture blush

-- loose grains rolled off the right foot
local gtok = { r = { name = "grains" } }
for _, q in ipairs{ {55, 47, 4}, {56, 47, 3}, {58, 49, 3}, {58, 50, 2}, {52, 50, 4}, {53, 50, 3} } do c:put(q[1], q[2], SAND[q[3]], gtok) end

G.save2(c, NAME)
