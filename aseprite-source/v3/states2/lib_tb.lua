-- shared helpers for tortoise_run / butterfly_bush / fence state sprites (Hearth Pop v3). Own file, not part of the repo.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local L = { HP = HP, P = P }
local floor = math.floor
local c
L.W, L.H = 64, 48

function L.new(w, h) c = HP.canvas{ w = w, h = h, scale = 1, name = "st" } L.c = c L.W, L.H = w, h return c end
function L.px(x, y, hex) c:px(x, y, hex) end
function L.R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
function L.E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local px, R, E = L.px, L.R, L.E

local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function L.lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local lerp = L.lerp
function L.hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
local hsh = L.hsh

L.DUSKSH = "#5a4660"
L.INTERIOR = "#3b2c48"
L.SH, L.SH2 = "#8a84a6", "#6f688f"      -- cool hard cast shadow, darker contact row
L.STRAW = { hi = "#fff0c0", base = "#f0d58c", shade = "#d9b46a", deep = P.gold.shade }
L.LEAFD = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3f3a" }
L.DIRT = { hi = P.wood.hi, base = lerp(P.wood.base, P.wood.hi, .45), shade = P.wood.base, deep = P.wood.shade }
L.ROPE = { hi = "#f3dca0", base = "#d9b46a", shade = "#b8864a", deep = "#864c33" }

local function rampOf(r) if type(r) == "string" then return P[r] end return r end
function L.step(x, y, r, dir)
  r = rampOf(r)
  local v = c:get(x, y); if not v then return end
  local T = { r.hi, r.base, r.shade, r.deep }
  for i = 1, 4 do
    if v == T[i] then
      local n
      if dir > 0 then n = (i == 3) and lerp(r.shade, r.deep, .45) or (i == 4) and nil or T[i + 1]
      else n = (i == 1) and lerp(r.hi, P.cream, .5) or (i == 4) and r.shade or T[i - 1] end
      if n then px(x, y, n) end
      return
    end
  end
end
function L.dk(x, y, r) L.step(x, y, r, 1) end
function L.lt(x, y, r) L.step(x, y, r, -1) end

function L.ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end

-- sphere shading (4 hard tones, lit upper-left, reflected light lower-right)
local LX, LY, LZ = -0.55, -0.62, 0.56
function L.ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  local t1, t2, t3 = o.t1 or .62, o.t2 or .2, o.t3 or -.18
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > t1 and T.hi) or (l > t2 and T.base) or (l > t3 and T.shade) or T.deep)
  end)
  if not o.norefl then
    m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
  end
  if o.spec then local sx, sy = floor(cx - rx * .42 + .5), floor(cy - ry * .5 + .5); if m:has(sx, sy) then px(sx, sy, P.cream) end end
end

-- leaf texture: little lit/dark dashes on a dark-green mass
function L.leaves(m, r, x0, x1, y0, y1, sx, sy)
  local inner = m:shrink(1)
  for gy = y0, y1, sy do
    local row = (gy - y0) // sy
    for gx = x0 + (row % 2) * (sx // 2), x1, sx do
      if inner:has(gx, gy) and inner:has(gx + 2, gy + 1) then
        L.lt(gx, gy, r) L.lt(gx + 1, gy, r) L.dk(gx + 1, gy + 1, r) L.dk(gx + 2, gy + 1, r)
      end
    end
  end
end

-- opaque cool cast shadow (the sprite has no ground to darken)
function L.shadow(m, contact) c:fillMask(m, L.SH) if contact then c:fillMask(contact, L.SH2) end end
function L.ellShadow(cx, cy, rx, ry) local m = E(cx, cy, rx, ry) L.shadow(m, E(cx - 1, cy - 1, math.max(rx - 3, 1), math.max(ry - 1, 1))) return m end

function L.shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, L.DUSKSH, t)) end end) end
function L.spark(x, y)
  px(x, y - 2, P.gold.base) px(x, y + 2, P.gold.base) px(x - 2, y, P.gold.base) px(x + 2, y, P.gold.base)
  px(x, y - 1, P.cream) px(x, y + 1, P.cream) px(x - 1, y, P.cream) px(x + 1, y, P.cream) px(x, y, P.cream)
  px(x - 1, y - 1, P.gold.hi) px(x + 1, y + 1, P.gold.hi)
end
-- 3x5 pixel font: BUILD, 19 px wide
local G = {
  B = { "110", "101", "110", "101", "110" },
  U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" },
  L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
function L.build(x, y, col)
  col = col or P.ink
  local cx = x
  for ch in ("BUILD"):gmatch(".") do
    for ry, row in ipairs(G[ch]) do for rx = 1, 3 do if row:sub(rx, rx) == "1" then px(cx + rx - 1, y + ry - 1, col) end end end
    cx = cx + 4
  end
end

-- gold "!" badge in the top-right corner; dy = bob
function L.badge(dy)
  local W = L.W
  local cx, cy = W - 6.5, 6.5 + dy
  local disc = E(cx, cy, 4.5, 4.5)
  c:rim(disc, P.ink)
  c:part(disc, "gold", { band = 2, nopop = true })
  local bx = floor(cx - 0.5)
  local y0 = floor(cy - 4.5)
  R(bx, y0 + 2, bx + 1, y0 + 5, P.cream)       -- bar
  R(bx, y0 + 7, bx + 1, y0 + 7, P.cream)       -- dot
  R(bx + 2, y0 + 3, bx + 2, y0 + 5, P.gold.deep)   -- tiny right-hand shadow under the bar
  px(bx - 2, y0 + 2, P.gold.hi) px(bx - 3, y0 + 3, P.gold.hi)
end

function L.stake(x, y0, y1, ramp)
  local m = c:rect(x, y0, x + 1, y1)
  L.ink(m)
  c:fillMask(m, P.wood.base) R(x, y0, x, y1, P.wood.hi) R(x + 1, y0 + 1, x + 1, y1, P.wood.shade) px(x + 1, y0, P.wood.base)
  return m
end
function L.flower(x, y, col, stem)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local st = c:rect(x, y + 2, x, y + 3 + (stem or 0))
  c:rim(HP.mask():add(head):add(st), P.ink)
  c:fillMask(st, P.moss.base)
  c:fillMask(head, col or P.petal.base)
  px(x, y, P.gold.hi)
end
function L.stone(x, y, w, h)    -- (x,y) top-left
  local m = c:rrect(x, y, x + w - 1, y + h - 1, 1)
  c:rim(m, P.ink)
  c:part(m, "stone", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
  return m
end
function L.leaf(x, y, flip)     -- small blowing leaf, 4x2
  local m = HP.mask():set(x, y):set(x + 1, y):set(x + 2, y):set(x + 1, y + 1):set(x + 2, y + 1):set(x + 3, y + 1)
  if flip then m = HP.mask():set(x + 1, y):set(x + 2, y):set(x + 3, y):set(x, y + 1):set(x + 1, y + 1):set(x + 2, y + 1) end
  c:rim(m, P.ink)
  c:fillMask(m, P.moss.base)
  px(x + (flip and 1 or 0), y + (flip and 0 or 0), P.moss.hi)
  px(x + (flip and 2 or 1), y + 1, P.moss.shade)
end
-- the plot: an outlined cleared patch of earth, with specks
function L.plot(x0, y0, x1, y1, r)
  local m = c:rrect(x0, y0, x1, y1, r or 4)
  c:rim(m, P.ink)
  c:fillMask(m, L.DIRT.base)
  -- lit upper-left lip, shaded lower-right lip
  m:each(function(x, y)
    if not m:has(x, y - 1) or not m:has(x - 1, y) then px(x, y, L.DIRT.hi) end
  end)
  m:each(function(x, y)
    if (not m:has(x, y + 1) or not m:has(x + 1, y)) and (m:has(x, y - 1) and m:has(x - 1, y)) then px(x, y, L.DIRT.shade) end
  end)
  m:each(function(x, y)
    if c:get(x, y) == L.DIRT.base then
      local h = hsh(x * 3 + 5, y * 7 + 1)
      if h < 6 then px(x, y, L.DIRT.shade) elseif h > 94 then px(x, y, L.DIRT.hi) end
    end
  end)
  return m
end
function L.string(pts, dark)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    if dark then c:fillMask(c:line({ { a[1], a[2] + 1 }, { b[1], b[2] + 1 } }, 1), P.wood.shade) end
  end
  for i = 1, #pts - 1 do
    c:fillMask(c:line({ pts[i], pts[i + 1] }, 1), P.cream)
  end
end

-- output --------------------------------------------------------------------
function L.report(cv) HP.assertClean(cv) end
function L.saveAll(name, out, W, H, empties, l1, l2, l3, readies)
  local function one(cv, n) HP.assertClean(cv) cv:save{ aseprite = out .. name .. "-" .. n .. ".aseprite", png = out .. name .. "-" .. n .. ".png", scale = 1 } end
  if empties then
    for _, f in ipairs(empties) do HP.assertClean(f) end
    HP.sheet{ cellw = W, cellh = H, frames = empties, tags = { { name = "empty", from = 1, to = 4 } } }
      :save{ aseprite = out .. name .. "-empty.aseprite", png = out .. name .. "-empty.png", scale = 1 }
    one(l1, "l1") one(l2, "l2") one(l3, "l3")
  end
  for _, f in ipairs(readies) do HP.assertClean(f) end
  HP.sheet{ cellw = W, cellh = H, frames = readies, tags = { { name = "ready", from = 1, to = 4 } } }
    :save{ aseprite = out .. name .. "-ready.aseprite", png = out .. name .. "-ready.png", scale = 1 }
end
return L
