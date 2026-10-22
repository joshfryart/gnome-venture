-- trek-token-gold (family 6, marker, 34x34): cream coin in a stitched gold rim, button at 12 o'clock.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-token-gold", 34, 34

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
local function edge(m) -- pixels of m with a 4-neighbour outside m
  local e = {}
  for k in pairs(m) do
    local x, y = k % W, k // W
    if not (has(m, x + 1, y) and has(m, x - 1, y) and has(m, x, y + 1) and has(m, x, y - 1)) then e[k] = true end
  end
  return e
end
local function save()
  local c = GV.canvas{ w = W, h = H, mode = "scene" }
  for k, h in pairs(P) do c:px(k % W, k // W, h) end
  local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
  print(NAME .. ": " .. GV.report(t))
end

---------------------------------------------------------------- palette (palette.md)
local U1, U2, U3 = "#74462a", "#4a2c1a", "#2a1a10"
local GD = { gloss = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", bounce = "#d0862a", shade = "#b8661a" }
local THREAD, HOLE = "#f5cf6a", "#8a4a1c"
local CREAM, CR_SHADE = "#f4f0e0", "#cfc3a2"

---------------------------------------------------------------- geometry
local cx, cy = 16.5, 16.5
local disc = mdisc(cx, cy, 16)        -- x1..32, y1..32
local outline = edge(disc)
local coin = mdisc(cx, cy, 12)        -- 24 across
local function s(x, y) return (x - cx) + (y - cy) end
local function inCentre(x, y)         -- central 16x16, corners cut 2 px: must stay pure cream
  if x < 9 or x > 24 or y < 9 or y > 24 then return false end
  local ax, ay = math.min(x - 9, 24 - x), math.min(y - 9, 24 - y)
  return ax + ay >= 2
end
-- thread ring: the 1 px layer around the coin (4-adjacent), r ~13
local thread = {}
for k in pairs(disc) do
  local x, y = k % W, k // W
  if not coin[k] and not outline[k] then
    if has(coin, x + 1, y) or has(coin, x - 1, y) or has(coin, x, y + 1) or has(coin, x, y - 1) then thread[k] = true end
  end
end
-- gloss comma on the upper-left arc of the gold ring (x6..10, y7..8 box, kept on the ring)
local GLOSS = { {6, 8}, {7, 7}, {8, 7}, {5, 9} }
local glossSet = {}
for _, p in ipairs(GLOSS) do glossSet[key(p[1], p[2])] = true end
local function nearGloss(x, y) return x >= 5 and x <= 10 and y >= 6 and y <= 9 end

---------------------------------------------------------------- paint
for k in pairs(disc) do
  local x, y = k % W, k // W
  local sv = s(x, y)
  if outline[k] then
    set(x, y, sv < -7 and U1 or (sv > 7 and U3 or U2))
  elseif coin[k] then
    set(x, y, CREAM)
  elseif not thread[k] then -- gold ring, 2 px
    local outer = has(outline, x + 1, y) or has(outline, x - 1, y) or has(outline, x, y + 1) or has(outline, x, y - 1)
    local h
    if outer then
      h = sv < -6 and GD.rim or (sv > 8 and GD.bounce or GD.base)
    else
      h = sv > 6 and GD.shade or GD.base
    end
    set(x, y, h)
  end
end
-- coin crescent: 1 px cr_shade on the lower-right edge only
for k in pairs(edge(coin)) do
  local x, y = k % W, k // W
  if s(x, y) >= 6 and not inCentre(x, y) then set(x, y, CR_SHADE) end
end
-- stitched thread ring (2 on / 1 off) in angle order, starting at 12 o'clock
local tl = {}
for k in pairs(thread) do
  local x, y = k % W, k // W
  tl[#tl + 1] = { x = x, y = y, a = math.atan(x - cx, -(y - cy)) % (2 * math.pi) }
end
table.sort(tl, function(a, b) return a.a < b.a end)
for i, p in ipairs(tl) do
  local on = ((i - 1) % 3) < 2
  local groove = GD.bounce -- the stitch sits in a darker groove so it reads on the gold
  if nearGloss(p.x, p.y) then set(p.x, p.y, GD.base)
  else set(p.x, p.y, on and THREAD or groove) end
end
-- gloss comma
for _, p in ipairs(GLOSS) do set(p[1], p[2], GD.gloss) end
-- button 4x4 at 12 o'clock, x15..18 y1..4, cut corners, holes on the diagonal
for j = 0, 3 do for i = 0, 3 do
  if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then set(15 + i, 1 + j, (i + j >= 4) and GD.base or THREAD) end
end end
set(16, 2, HOLE); set(17, 3, HOLE)
-- umber frame round the button sides (top is the silhouette, bottom meets the coin)
set(14, 2, U1); set(14, 3, U2); set(15, 4, U2)
set(19, 2, U2); set(19, 3, U3); set(18, 4, U3)

save()
