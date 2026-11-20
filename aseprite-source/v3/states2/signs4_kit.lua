-- Shared helpers for the BUILD-sign craft pass of worm_farm, ladybird_lodge, snail_jar, frog_pond.
-- local K = dofile("/tmp/ase/states2/signs4_kit.lua"); K.init(W, H, name, out)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local SF = dofile("/tmp/ase/states2/signfont.lua")
local P = HP.P
local floor = math.floor
local K = { HP = HP, P = P, SF = SF }
local c
K.DUSKSH = "#5a4660"
-- packed earth: 3 tones plus the darker cut rim
K.EHI, K.EBASE, K.ESH, K.ERIM = "#c08a5c", "#a2704a", "#835537", "#5c3a2f"
K.GRSH, K.GRSH2 = "#6f8c7a", "#5b7868"   -- cool cast shadow where it falls on grass (transparent ground)

function K.init(W, H, name, out) K.W, K.H, K.name, K.out = W, H, name, out end
function K.newc() c = HP.canvas{ w = K.W, h = K.H, scale = 1, name = K.name }; K.c = c; return c end
function K.px(x, y, hex) if x >= 0 and y >= 0 and x < K.W and y < K.H then c:px(x, y, hex) end end
local px = K.px
function K.R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
function K.E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
function K.pt(list) local m = HP.mask() for _, q in ipairs(list) do m:set(q[1], q[2]) end return m end
function K.ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function K.lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
function K.hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
-- cool hard cast shadow: darkens what is under it, or paints grass-shadow where nothing is
function K.shadow(m, t)
  m:each(function(x, y)
    local v = c:get(x, y)
    if v then px(x, y, K.lerp(v, K.DUSKSH, t or .38)) else px(x, y, K.GRSH) end
  end)
end
-- the cleared plot: flush packed earth from a quad (FL, FR, NR, NL corners), ragged cut edge,
-- far edge = dark cut wall (rim + shade row), near edge = lit lip; clods and pale scuffs inside
function K.plotMask(q, seed)
  local m = c:poly(q)
  local e = m:edge()
  e:each(function(x, y) if K.hsh(x * 7 + seed, y * 11) < 22 then m.s[(y + 256) * 1024 + (x + 256)] = nil end end)
  local g = m:grow(1):cut(m)
  g:each(function(x, y) if K.hsh(x * 13 + seed, y * 5 + 1) < 14 then m:set(x, y) end end)
  return m
end
function K.plot(m, seed)
  seed = seed or 1
  c:fillMask(m, K.EBASE)
  m:each(function(x, y)
    local h = K.hsh(x * 5 + seed, y * 3 + seed)
    if h < 8 then px(x, y, K.EHI); if m:has(x + 1, y) then px(x + 1, y, K.EHI) end
    elseif h > 91 then px(x, y, K.ESH); if m:has(x + 1, y) and h > 96 then px(x + 1, y, K.ESH) end end
  end)
  m:each(function(x, y)
    if not m:has(x, y - 1) then px(x, y, K.ERIM)
    elseif not m:has(x, y - 2) then px(x, y, K.ESH)
    elseif not m:has(x - 1, y) then px(x, y, K.ERIM)
    elseif not m:has(x + 1, y) then px(x, y, K.ESH)
    elseif not m:has(x, y + 1) then px(x, y, K.EHI) end
  end)
end
function K.stake(x, yb, h)
  local m = c:rect(x, yb - h + 1, x, yb)
  K.ink(m); c:fillMask(m, P.wood.shade); px(x, yb - h + 1, P.wood.hi); px(x, yb - h + 2, P.wood.base)
  return m
end
function K.string(pts, col)
  c:fillMask(c:line(pts, 1), col or P.cream)
end
function K.corners(q, h, col)
  h = h or 5
  local t = {}
  for i = 1, 4 do t[i] = { q[i][1], q[i][2] - 2 } end
  for i = 1, 4 do K.string({ t[i], t[i % 4 + 1] }, col) end
  for i = 1, 4 do K.stake(q[i][1], q[i][2], h) end
end
function K.pebble(x, y)
  local m = c:rect(x, y, x + 2, y + 1); K.ink(m); c:fillMask(m, P.stone.base); K.R(x, y, x + 1, y, P.stone.hi); px(x + 2, y + 1, P.stone.shade)
end
function K.tuft(x, y)   -- grass tuft, base row y, 5 wide
  local m = K.pt{ { x, y - 1 }, { x + 1, y }, { x + 2, y - 2 }, { x + 2, y - 1 }, { x + 2, y }, { x + 3, y }, { x + 4, y - 1 }, { x, y }, { x + 4, y } }
  K.ink(m); c:fillMask(m, P.moss.base)
  px(x + 2, y - 2, P.moss.hi); px(x, y - 1, P.moss.hi); px(x + 3, y, P.moss.shade); px(x + 4, y, P.moss.shade); px(x + 4, y - 1, P.moss.shade)
end
function K.flower(x, y, col, ctr, lean)   -- 5-petal plus, stem 2 below
  local head = K.pt{ { x, y - 1 }, { x - 1, y }, { x, y }, { x + 1, y }, { x, y + 1 } }
  local stem = c:rect(x + (lean or 0), y + 2, x + (lean or 0), y + 3)
  K.ink(head, stem)
  c:fillMask(stem, P.moss.shade); c:fillMask(head, col); px(x, y, ctr or P.gold.hi)
end
function K.word(x, y, col, sh) SF.text(px, x, y, col, sh) end
local LX, LY, LZ = -0.55, -0.62, 0.56
function K.ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  m:each(function(x, y)
    local u, v = (x - cx) / (rx + .5), (y - cy) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > (o.t1 or .62) and T.hi) or (l > (o.t2 or .2) and T.base) or (l > (o.t3 or -.18) and T.shade) or T.deep)
  end)
end
function K.saveStrip(frames, name, tag)
  for _, f in ipairs(frames) do HP.assertClean(f) end
  HP.sheet{ cellw = K.W, cellh = K.H, frames = frames, tags = { { name = tag, from = 1, to = #frames } } }
    :save{ aseprite = K.out .. name .. ".aseprite", png = K.out .. name .. ".png", scale = 1 }
end
return K
