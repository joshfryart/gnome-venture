-- stone-wall-gate (lean P1b_O14)
local NAME = "stone-wall-gate"

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

c:groundShadow(32, 52, 27, 3)
-- wall body
face(6, 22, 57, 49, 71)
-- arch opening with door
local cx, cy, rr = 32, 36, 11
local function inarch(x, y) return y >= 49 or ((x-cx)^2 + (y-cy)^2 <= rr*rr and true) or (y > cy and x >= cx-rr and x <= cx+rr) end
for y = 24, 49 do for x = 21, 43 do
  if (y >= cy and x >= cx - rr and x <= cx + rr) or ((x-cx)^2 + (y-cy)^2 <= rr*rr) then
    c:put(x, y, "#2a2034")
  end
end end
-- wooden leaves
local WD = { "#3e2418", "#5e3a22", "#7e5230", "#a06a3c", "#c48a50" }
for y = 28, 49 do for x = 22, 42 do
  if (y >= cy and x >= cx - rr + 1 and x <= cx + rr - 1) or ((x-cx)^2 + (y-cy)^2 <= (rr-1)^2) then
    local k = (x - 22) % 5
    local i = (k == 0) and 1 or ((k == 1) and 4 or ((k == 4) and 2 or 3))
    if H(x, y, 3) > 0.92 then i = max(1, i - 1) end
    c:put(x, y, WD[i])
  end
end end
for y = 28, 49 do c:put(32, y, WD[1]) c:put(31, y, WD[1]) end
for x = 22, 42 do c:put(x, 38, "#38303f") c:put(x, 44, "#38303f") end
c:put(29, 41, "#ffd45a") c:put(34, 41, "#ffd45a") c:put(29, 42, "#c98a22") c:put(34, 42, "#c98a22")
-- arch voussoirs ring (light stones)
for a = 0, 180, 15 do
  local rad = math.rad(a)
  for t = 0, 1, 0.5 do
    local r2 = rr + 1 + t * 3
    local x, y = floor(cx - math.cos(rad) * r2 + 0.5), floor(cy - math.sin(rad) * r2 + 0.5)
    c:put(x, y, (floor(a / 15) % 2 == 0) and R[5] or R[4])
  end
end
for a = 0, 180, 3 do
  local rad = math.rad(a)
  for r2 = rr + 1, rr + 3 do
    local x, y = floor(cx - math.cos(rad) * r2 + 0.5), floor(cy - math.sin(rad) * r2 + 0.5)
    local seg = floor(a / 20) % 2
    local j = (r2 == rr + 1) and 6 or (seg == 0 and 5 or 4)
    if a % 20 < 3 then j = 2 end
    c:put(x, y, R[j])
  end
end
-- keystone
c:fillMask(c:rect(30, 20, 34, 25), R[6]) c:fillMask(c:rect(30, 24, 34, 25), R[4]) c:put(29, 20, R[3]) c:put(35, 20, R[3])
-- tall pillars with flat caps
face(6, 12, 19, 49, 73)
face(45, 12, 57, 49, 74)
for _, p in ipairs{{4, 21}, {43, 59}} do
  for y = 6, 12 do for x = p[1], p[2] do
    local j = (y == 6) and 6 or ((y == 12) and 3 or 5)
    if x == p[1] then j = min(6, j+1) elseif x >= p[2] - 1 then j = j - 1 end
    c:put(x, y, R[cl(j)])
  end end
end
-- wall top between pillars
cap(20, 16, 44, 22, 75)
moss(6, 6, 6, 31) moss(46, 6, 4, 32) moss(24, 16, 4, 33) moss(8, 49, 5, 34) moss(48, 49, 6, 35)
drip(12, 13, 3) drip(52, 13, 3)

G.save(c, NAME)
