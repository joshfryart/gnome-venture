-- tortoise-scute (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "tortoise-scute"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local AMB = { "#3e2216", "#76421e", "#a8652a", "#d38c34", "#f2bb4c", "#fee493" }
local BR  = { "#2a1820", "#442630", "#6a3a30", "#8f5236" }
local tT, tS = { r = { name = "top" } }, { r = { name = "slab" } }
local cx, cy, R, ys = 32, 26, 24, 0.82
local function hd(x, y) local dx, dy = abs(x - cx), abs(y - cy) / ys return max(dy / 0.866, dx + dy * 0.577) end
local top = HP.mask()
for y = 0, 63 do for x = 0, 63 do if hd(x, y) <= R - 0.5 then top:set(x, y) end end end
c:groundShadow(33, 52, 22, 4)
-- thick slab edge: amber lip, pale bone layer, dark underside
for d = 1, 7 do
  top:shift(0, d):each(function(x, y)
    if not top:has(x, y) then
      local dd = 1
      while not top:has(x, y - dd) do dd = dd + 1 end
      local u = (x - 8) / 48
      local col
      if dd <= 3 then col = AMB[(u < 0.4 and 3 or 2) - (dd == 3 and 1 or 0)]
      elseif dd == 4 then col = u < 0.5 and "#f0e2b0" or "#d8c58e"
      elseif dd == 5 then col = u < 0.5 and "#c4aa78" or "#a88e60"
      else col = BR[(u < 0.5) and 2 or 1] end
      c:put(x, y, col, tS)
    end
  end)
end
local v = X.light(X.pillow(top, 9), { amb = 0.1, wrap = 0.3 })
local base = { 2, 3, 2, 3, 4, 5 }
top:each(function(x, y)
  local d = hd(x, y)
  local i = floor((R - d) / 4.2)
  local f = (R - d) / 4.2 - i
  local col
  if i > 0 and f < 0.24 then
    col = ((x - cx) + (y - cy) < 0) and AMB[6] or AMB[1]
  else
    local b = base[cl(i + 1, 6)]
    local lv = v[K(x, y)] or 0.5
    if lv > 0.72 then b = b + 1 elseif lv < 0.3 then b = b - 1 end
    if X.hash(x, y, 5) > 0.93 then b = b - 1 end
    col = AMB[cl(b, 6)]
  end
  c:put(x, y, col, tT)
end)
-- centre pit
c:fillMask(c:rect(cx - 1, cy - 1, cx, cy), AMB[1])
c:px(cx - 2, cy - 2, AMB[2]) c:px(cx + 1, cy + 1, AMB[5])
-- quirk: chipped corner showing bone + crack
for y = 8, 26 do for x = 40, 58 do
  local dd = abs(x - 50) + abs(y - 15)
  if top:has(x, y) and hd(x, y) > R - 7 then
    if dd <= 3 then c:put(x, y, (x + y < 66) and "#f0e2b0" or "#c4aa78", tT)
    elseif dd == 4 then c:put(x, y, AMB[1], tT) end
  end
end end
for _, p in ipairs{ {48, 18}, {47, 20}, {47, 21}, {46, 23}, {45, 24} } do c:px(p[1], p[2], AMB[1]) end
-- glint
c:px(19, 14, "#fff6d0") c:px(20, 14, "#fff6d0") c:px(19, 15, "#fff6d0") c:px(18, 13, AMB[6]) c:px(21, 15, AMB[6])
G.save(c, NAME)
