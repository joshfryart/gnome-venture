-- _aC34_0.lua: private helpers for chunk C34 pickles (pickled-bamboo-shoots, -beets, -capers, -carrots).
-- Wraps v3/lib/hp.lua + hpx.lua read-only. Lathe bodies (per-pixel normals), glass overlay, leaves, recentre + save.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua") X.init(HP)
local K = X.K
local floor, ceil, sqrt, max, min, abs = math.floor, math.ceil, math.sqrt, math.max, math.min, math.abs
local A = { HP = HP, X = X, K = K, P = HP.P }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name } A.c, A.name = c, name return c end

local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function A.mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
-- recolour existing pixels of mask toward hex by t (keeps owner)
function A.tint(c, m, hex, t)
  m:each(function(x, y) local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, hex, t) end end)
end

-- lathe body: rows y0..y1, half width hw(y) (nil = none). Returns mask, normals, NX (signed -1..1 across)
function A.lathe(cx, y0, y1, hw, slope)
  local m, n, NX = HP.mask(), {}, {}
  for y = y0, y1 do local w = hw(y) if w then
    local wa, wb = hw(y - 1) or w, hw(y + 1) or w
    local dw = (wb - wa) / 2 * (slope or 1)
    for x = floor(cx - w - 1), ceil(cx + w + 1) do
      local d = x + .5 - cx
      if abs(d) <= w then
        m:set(x, y)
        local sn = max(-.97, min(.97, d / (w + .35)))
        local nz = sqrt(1 - sn * sn)
        local k = K(x, y)
        n[k] = { norm(sn, -dw * nz, nz) }
        NX[k] = sn
      end
    end
  end end
  return m, n, NX
end

A.CUT6 = { .18, .34, .5, .64, .8 }
function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or .08, wrap = o.wrap or .25 })
  local cuts = o.cuts
  if not cuts then
    if #ramp == 6 then cuts = A.CUT6 else cuts = {} for i = 1, #ramp - 1 do cuts[i] = i / #ramp end end
  end
  local idx, tok = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok, name = o.name })
  return idx, tok, v
end

function A.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local a = dx * ux + dy * uy
    local b = -dx * uy + dy * ux
    if (a / ra)^2 + (b / rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
function A.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end

A.GLASS = { "#3e5f8f", "#6c9cc8", "#9cc8e4", "#c4e6f4", "#e2f5fb", "#f7fdff" }
A.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
A.METAL = { "#2f3050", "#4a4c68", "#74758c", "#a2a2b4", "#cfcfdc", "#f2f2f8" }
A.SPEC = "#fff4d6"

-- glass look over contents already painted in `inner`: left highlight band, pale core, dark right band, cool bounce.
-- NX[k] = across coordinate (-1 lit edge .. 1 shade edge). ys/ye limit rows. walls (body - inner) toned glass.
function A.glass(c, body, inner, n, NX, o)
  o = o or {}
  inner:each(function(x, y)
    local k = K(x, y) local s = NX[k]
    if s and (not o.ys or y >= o.ys) then
      local h = c:get(x, y)
      if h then
        if s > -.74 and s < -.5 and (o.hiRow == nil or o.hiRow(y)) then h = A.mix(h, "#f4fbff", .62)
        elseif s > -.34 and s < -.24 and (y % 9) < 6 then h = A.mix(h, "#eaf8ff", .28)
        elseif s > .86 then h = A.mix(h, "#bfeaf0", .38)
        elseif s > .6 then h = A.mix(h, "#24304f", .26) end
        c.pix[y * c.w + x] = h
      end
    end
  end)
  local wall = body:copy():cut(inner)
  if o.wallClip then wall:clip(o.wallClip) end
  local wn = {} wall:each(function(x, y) wn[K(x, y)] = n[K(x, y)] end)
  return A.tone(c, wall, wn, A.GLASS, { amb = .25, wrap = .4, tok = o.tok })
end

-- leaf blade (pillow normals) from base (bx,by) along (ux,uy); midrib darker
function A.leaf(c, bx, by, ux, uy, len, wid, ramp, o)
  o = o or {}
  local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local m = A.rell(bx + ux * len / 2, by + uy * len / 2, ux, uy, len / 2 + .3, wid)
  local n = X.pillow(m, o.R or 1.6)
  local idx = A.tone(c, m, n, ramp or A.LEAF, { amb = .12, wrap = .3, tok = o.tok, bias = o.bias })
  if not o.norib then
    for i = 1, floor(len) - 2 do
      local x, y = floor(bx + ux * i + .5), floor(by + uy * i + .5)
      if m:has(x, y) then local k = K(x, y) c:put(x, y, (ramp or A.LEAF)[max(1, (idx[k] or 3) - 1)], o.tok) end
    end
  end
  return m
end

-- shift all drawn pixels so the outlined bbox is centred on the canvas
function A.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2 + .5) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + .5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined %dx%d)", dx, dy, W, Hh))
end

function A.fin(c, name)
  A.recentre(c)
  c:finish()
  HP.assertClean(c)
  HP.report(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return A
