-- trek-token-ember (family 6, marker, 34x34): danger token. Cream coin in an ember-red ring with four
-- short spikes (silhouette differs from the gold token), stitched join, three ember glints. No button.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-token-ember", 34, 34

---------------------------------------------------------------- tiny pixel helpers
local P = {}
local function key(x, y) return y * W + x end
local function set(x, y, h) if x >= 0 and y >= 0 and x < W and y < H then P[key(x, y)] = h end end
local function has(m, x, y) return x >= 0 and y >= 0 and x < W and y < H and m[key(x, y)] end
local function mdisc(cx, cy, r)
  local m = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local dx, dy = x - cx, y - cy
    if dx * dx + dy * dy <= r * r then m[key(x, y)] = true end
  end end
  return m
end
local function edge(m)
  local e = {}
  for k in pairs(m) do
    local x, y = k % W, k // W
    if not (has(m, x + 1, y) and has(m, x - 1, y) and has(m, x, y + 1) and has(m, x, y - 1)) then e[k] = true end
  end
  return e
end
local function adj4(m, x, y) return has(m, x + 1, y) or has(m, x - 1, y) or has(m, x, y + 1) or has(m, x, y - 1) end
local function save()
  local c = GV.canvas{ w = W, h = H, mode = "scene" }
  for k, h in pairs(P) do c:px(k % W, k // W, h) end
  local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
  print(NAME .. ": " .. GV.report(t))
end

---------------------------------------------------------------- palette (palette.md)
local U1, U2, U3 = "#74462a", "#4a2c1a", "#2a1a10"
local RD = { gloss = "#ff9158", rim = "#f2793a", base = "#dd3a2a", bounce = "#b8452f", shade = "#ae2a2a", deep = "#6b1b2c" }
local EMBER300, THREAD = "#f08a24", "#f5cf6a"
local CREAM, CR_SHADE = "#f4f0e0", "#cfc3a2"

---------------------------------------------------------------- geometry
local cx, cy = 16.5, 16.5
local function s(x, y) return (x - cx) + (y - cy) end
local core = mdisc(cx, cy, 14)        -- x3..30
local shape = {}
for k in pairs(core) do shape[k] = true end
-- four spikes, 2 rows tall, stepped 6 / 4 px wide
local spike = {}
local function sp(x, y, dir) shape[key(x, y)] = true; spike[key(x, y)] = dir end
for x = 14, 19 do sp(x, 2, "n"); sp(x, 31, "s") end
for x = 15, 18 do sp(x, 1, "n"); sp(x, 32, "s") end
for y = 14, 19 do sp(2, y, "w"); sp(31, y, "e") end
for y = 15, 18 do sp(1, y, "w"); sp(32, y, "e") end
local outline = edge(shape)
local coin = mdisc(cx, cy, 10)        -- 20 across
local thread = {}
for k in pairs(core) do
  local x, y = k % W, k // W
  if not coin[k] and not outline[k] and adj4(coin, x, y) then thread[k] = true end
end
local function inCentre(x, y)         -- central 16x16, 3 px cut corners: pure cream
  if x < 9 or x > 24 or y < 9 or y > 24 then return false end
  local ax, ay = math.min(x - 9, 24 - x), math.min(y - 9, 24 - y)
  return ax + ay >= 3
end
local GLOSS = { {7, 8}, {8, 8}, {9, 8}, {10, 8} }
local function nearGloss(x, y) return y >= 7 and y <= 9 and x >= 6 and x <= 11 end

---------------------------------------------------------------- paint
for k in pairs(shape) do
  local x, y = k % W, k // W
  local sv = s(x, y)
  if outline[k] then
    set(x, y, sv < -7 and U1 or (sv > 7 and U3 or U2))
  elseif coin[k] then
    set(x, y, CREAM)
  elseif spike[k] then
    set(x, y, RD.base)
  elseif not thread[k] then -- ember ring, 2 px
    local h
    if adj4(outline, x, y) or adj4(spike, x, y) then
      h = sv < -6 and RD.rim or (sv >= 17.5 and RD.deep or (sv > 6 and RD.bounce or RD.base))
    else
      h = sv > 6 and RD.shade or RD.base
    end
    set(x, y, h)
  end
end
-- spike lit / shaded edge pixel: rim on north and west, shade on south and east
set(15, 2, RD.rim); set(2, 15, RD.rim)
set(18, 31, RD.shade); set(31, 18, RD.shade)
-- coin crescent
for k in pairs(edge(coin)) do
  local x, y = k % W, k // W
  if s(x, y) >= 6 and not inCentre(x, y) then set(x, y, CR_SHADE) end
end
-- stitched join ring (2 on / 1 off) over rd_shade, skipping the gloss comma
local tl = {}
for k in pairs(thread) do
  local x, y = k % W, k // W
  tl[#tl + 1] = { x = x, y = y, a = math.atan(x - cx, -(y - cy)) % (2 * math.pi) }
end
table.sort(tl, function(a, b) return a.a < b.a end)
for i, p in ipairs(tl) do
  local on = ((i - 1) % 3) < 2
  if nearGloss(p.x, p.y) then set(p.x, p.y, RD.base)
  else set(p.x, p.y, on and THREAD or RD.shade) end
end
-- gloss comma and the three 45-degree ember glints
for _, p in ipairs(GLOSS) do set(p[1], p[2], RD.gloss) end
set(25, 8, EMBER300); set(8, 25, EMBER300); set(25, 25, EMBER300)

save()
