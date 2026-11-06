-- _aC33_2.lua: private helpers for perilla-seed, periwinkle-seed, persian-buttercup-seed, persimmon (C33 slot 2).
-- Read-only wrap of batch2/_b2g2.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua); adds a few local tools.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g2.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs, cos, sin, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi
G.OUT = app.params.out or (DIR .. "/../ph/")

function G.new3(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a, b = dx*ux + dy*uy, -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
function G.rot(ux, uy, a) local c, s = cos(a), sin(a) return ux*c - uy*s, ux*s + uy*c end

-- ovate leaf along quadratic A-C-B with max half width W; o.serr = tooth depth (px), o.per = tooth spacing (px)
function G.leafo(ax, ay, cx, cy, bx, by, W, o)
  o = o or {}
  local L = sqrt((cx-ax)^2 + (cy-ay)^2) + sqrt((bx-cx)^2 + (by-cy)^2)
  local per, sd, sk = o.per or 3.2, o.serr or 0, o.skew or 0.38
  return G.blade(ax, ay, cx, cy, bx, by, function(t)  -- returns m, n, T, S, len
    if t > 0.99 then return -1 end
    local base = W * sin(pi * min(1, t ^ (o.pw or 0.75))) ^ (o.round or 0.7)
    if t < 0.05 and o.stalk then base = max(base, 0.6) end
    local ph = (t * L / per) % 1
    local tooth = sd * ((ph < 0.7) and (ph / 0.7) or ((1 - ph) / 0.3))
    if t < 0.15 or t > 0.93 then tooth = tooth * 0.3 end
    return max(0.3, base - tooth)
  end, { fold = o.fold or 0.45 })
end

-- remove pixels beyond a ragged tear line through (x0,y0)-(x1,y1); keeps the side where cross >= 0
function G.tear(m, x0, y0, x1, y1, amp, seed)
  local dx, dy = x1 - x0, y1 - y0
  local l = sqrt(dx*dx + dy*dy)
  local cut = {}
  m:each(function(x, y)
    local along = ((x - x0) * dx + (y - y0) * dy) / l
    local cr = ((x - x0) * dy - (y - y0) * dx) / l
    local j = (X.hash(floor(along / 2), 7, seed or 1) - 0.5) * 2 * (amp or 1.5) + sin(along * 0.9) * 0.6
    if cr > j then cut[#cut + 1] = { x, y } end
  end)
  for _, p in ipairs(cut) do m.s[K(p[1], p[2])] = nil end
  return m
end

function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  G.shift(c, dx, dy)
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function G.done(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.OUT .. name .. ".aseprite", png = G.OUT .. name .. ".png", scale = 1 }
end
return G
