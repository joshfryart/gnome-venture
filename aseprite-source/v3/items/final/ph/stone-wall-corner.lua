-- stone-wall-corner (lean P1b_O14)
local NAME = "stone-wall-corner"

local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, max, min = math.floor, math.max, math.min
local R = { "#3a3046", "#5a4e68", "#7b6e88", "#9c8f9e", "#c0b3b4", "#e2d6cc" }
local W = { "#46393f", "#6a5757", "#8d7a72", "#ab967f", "#c7b498", "#e0d2b2" }
local M = { "#2b4730", "#4a7636", "#78a844", "#aed25e" }
local MORT = "#46394f"
local function cl(i) return max(1, min(6, i)) end
local function H(x, y, s) return X.hash(x, y, s) end
-- chunky mortared blocks in region; pred(x,y) limits shape
local function face(x0, y0, x1, y1, seed, pred, ch)
  ch = ch or 6
  local edges = {}
  for r = 0, floor((y1 - y0) / ch) + 1 do
    local e, x = {}, x0 - floor(H(r, 3, seed) * 9) - ((r % 2) * 4)
    while x <= x1 + 12 do e[#e + 1] = x; x = x + 8 + floor(H(x, r, seed + 5) * 6) end
    edges[r] = e
  end
  for y = y0, y1 do
    local r = floor((y - y0) / ch); local v = (y - y0) % ch
    local e = edges[r]
    for x = x0, x1 do
      if not pred or pred(x, y) then
        local bi = 1
        while e[bi + 1] and e[bi + 1] <= x do bi = bi + 1 end
        local bs, be = e[bi], e[bi + 1] or (e[bi] + 10)
        local u = x - bs
        if v == ch - 1 or u == be - bs - 1 then c:put(x, y, MORT)
        else
          local hb = H(bi, r, seed + 9)
          local pal, base = R, 3 + (hb > 0.5 and 1 or 0)
          if hb > 0.9 then pal, base = W, 3 end
          if hb < 0.1 then base = 2 end
          local i = base
          if v == 0 then i = i + 2 elseif v == 1 then i = i + 1 end
          if u == 0 then i = i + 1 end
          if v == ch - 2 then i = i - 1 end
          if u == be - bs - 2 then i = i - 1 end
          if x >= x1 - 2 then i = i - 1 end
          if x <= x0 + 1 then i = i + 1 end
          local s = H(x, y, seed + 21)
          if s > 0.93 then i = i - 1 elseif s < 0.05 then i = i + 1 end
          c:put(x, y, pal[cl(i)])
        end
      end
    end
  end
end
-- light cap slab: bright top, lip underneath, slab joints
local function cap(x0, y0, x1, y1, seed)
  local jx = x0 + 6 + floor(H(1, 1, seed) * 5)
  for y = y0, y1 do
    local row = y - y0
    local i = (row == 0) and 6 or ((y == y1) and 3 or ((y == y1 - 1) and 4 or 5))
    for x = x0, x1 do
      local j = i
      if x == x0 then j = min(6, j + 1) elseif x >= x1 - 1 then j = j - 1 end
      c:put(x, y, R[cl(j)])
    end
  end
  local x = jx
  while x < x1 - 3 do
    for y = y0 + 1, y1 - 1 do c:put(x, y, R[3]) end
    x = x + 9 + floor(H(x, 2, seed) * 5)
  end
  for x = x0 + 2, x1 - 2 do if H(x, y0, seed + 4) > 0.8 then c:put(x, y0 + 1, R[4]) end end
end
local function moss(x, y, w, seed)
  for i = 0, w - 1 do
    local h = 1 + floor(H(x + i, y, seed) * 3)
    if i == 0 or i == w - 1 then h = max(1, h - 1) end
    for k = 0, h - 1 do c:put(x + i, y - k, k == h - 1 and M[3 + (H(i, k, seed) > 0.5 and 1 or 0) - (h == 1 and 1 or 0)] or M[2]) end
    c:put(x + i, y + 1, M[1])
  end
end
local function drip(x, y, n) for k = 0, n - 1 do c:put(x, y + k, k == n - 1 and M[2] or M[3]) end end
local function ao(x0, x1, y) for x = x0, x1 do c:put(x, y, R[1]) end end

c:groundShadow(32, 54, 27, 3)
-- arm to the right (lower) and front-facing pillar on the left (tall)
face(26, 30, 57, 48, 51)
cap(25, 22, 58, 30, 51)
ao(27, 57, 30)
face(8, 18, 31, 52, 53)
-- overhanging capstone slab: wide, square, light
for y = 7, 18 do for x = 5, 34 do
  local j = (y == 7) and 6 or ((y == 18) and 3 or ((y >= 16) and 4 or 5))
  if y == 18 or y == 17 then j = (y == 18) and 2 or 4 end
  if x == 5 then j = min(6, j + 1) elseif x >= 33 then j = j - 1 end
  c:put(x, y, R[cl(j)])
end end
for y = 8, 16 do c:put(19, y, R[3]) end
for x = 6, 33 do if H(x, 9, 5) > 0.85 then c:put(x, 8, R[4]) end end
ao(9, 31, 19)
moss(10, 7, 8, 12) moss(24, 7, 4, 13) moss(40, 22, 5, 14) moss(10, 52, 6, 15)
drip(14, 19, 4) drip(27, 19, 3)
-- tiny flower at the foot
c:put(44, 50, M[2]) c:put(44, 51, M[1]) c:put(43, 49, "#f4b3c8") c:put(45, 49, "#f4b3c8") c:put(44, 48, "#f4b3c8") c:put(44, 49, "#ffe27a")

G.save(c, NAME)
