-- _aC22_4.lua: private helpers for marzipan, masterwork-barrow, masterwork-gnome-seeder, masterwork-harvest-cart
-- (aC22_4, Opus single pass). Uses v3/lib/hp.lua + hpx.lua read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local G = { HP = HP, X = X, K = K, DIR = DIR }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm

-- ramps, dark -> light (6 tones)
G.WOOD   = { "#3c2027", "#5e3329", "#864c33", "#ad6d3f", "#d29858", "#f0c486" }
G.OAK    = { "#40242a", "#6a3c2c", "#9a5d38", "#c4844a", "#e2ac66", "#f8d898" }
G.IRON   = { "#262338", "#3c3d58", "#5b5d78", "#8587a0", "#b6b6c8", "#e8e6f0" }
G.COPPER = { "#4a1f2a", "#7a3330", "#b0532f", "#da7838", "#f4a456", "#ffd690" }
G.BRASS  = { "#5a2d22", "#8f4a1f", "#c4741f", "#e89e2a", "#f8cc52", "#fff0a6" }
G.TEAL   = { "#1b2b48", "#1f4a64", "#277080", "#3a9a96", "#6cc4ac", "#b6ecd6" }
G.HAT    = { "#4a1530", "#7a1f38", "#b02c3e", "#dc4239", "#fb7552", "#ffb088" }
G.LEAF   = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
G.ORANGE = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
G.APPLE  = { "#4c1430", "#7c1c34", "#b42838", "#e0423e", "#ff765a", "#ffb48c" }
G.WHEAT  = { "#6a3a22", "#9a5e26", "#c8892c", "#e8b23e", "#f8d66a", "#fff2b0" }
G.MARZ   = { "#7a4a3a", "#a8744a", "#cf9f60", "#e8c886", "#f6e2aa", "#fff4d0" }
G.STRAW  = { "#561632", "#8a2038", "#c2303e", "#e6524a", "#ff8a68", "#ffc4a2" }
G.SPEC = "#fff6dc"

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along a cubic bezier with half width wfn(t): mask, normals, T, S (S<0 lit side), samples
function G.tube(p, wfn, steps)
  local N = steps or 120
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 9, floor(by1) + 9 do for x = floor(bx0) - 9, floor(bx1) + 9 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x)^2 + (y - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    local along = (x - bs.x) * bs.tx + (y - bs.y) * bs.ty
    local endcut = (bs.t == 0 and along < -0.3) or (bs.t == 1 and along > 0.3)
    if bs.w > 0 and sqrt(best) <= bs.w and not endcut then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end
-- straight rod A->B, half width w (round-ish, lit upper-left)
function G.rod(ax, ay, bx, by, w)
  return G.tube({ { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } },
    function() return w end, 60)
end
function G.oval(cx, cy, rx, ry, ang, flat)
  ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local wx, wy = u * ca - v * sa, u * sa + v * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.02)) * (flat or 1)) }
    end
  end end
  return m, n
end
-- light + quantise; o: amb, wrap, cuts, bias, tok, spec(power,thresh)
function G.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.2, L = o.L })
  if o.flat then for k, val in pairs(v) do v[k] = val * (1 - o.flat) + o.flat * (o.flatv or 0.6) end end
  local tok = o.tok or { r = { name = o.name or "part" } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = o.bias, tok = tok })
  if o.spec then
    local s = X.spec(n, o.spec[1])
    for k, val in pairs(s) do if val > o.spec[2] and m.s[k] then
      local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, o.spec[3] or ramp[#ramp], tok) end end
  end
  return idx, tok, v
end
function G.pillow(c, m, R, ramp, o)
  local n = X.pillow(m, R, o and o.h)
  local idx, tok, v = G.shade(c, m, n, ramp, o)
  return idx, tok, n
end
-- AO bias helper: pixels of m within r of other get amt
function G.ao(bias, m, other, r, amt) return X.ao(bias, m, other, r, amt) end
-- bias pixels of m that lie under caster shifted by (dx,dy) (contact shadow)
function G.cast(bias, m, caster, dx, dy, amt)
  local sh = caster:shift(dx, dy)
  m:each(function(x, y) if sh:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end end)
  return bias
end
-- recolour pixels already painted with ramp index i by +d (needs idx table)
function G.step(c, m, idx, ramp, d, tok)
  m:each(function(x, y) local k = K(x, y) local i = idx[k] if i then
    i = max(1, min(#ramp, i + d)) idx[k] = i c:put(x, y, ramp[i], tok) end end)
end
function G.pline(c, pts, hex, tok, clip)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for j = 0, n do
      local x, y = floor(x0 + (x1 - x0) * j / n + .5), floor(y0 + (y1 - y0) * j / n + .5)
      if not clip or clip:has(x, y) then c:put(x, y, hex, tok) end
    end
  end
end
-- spoked wheel. o: R (outer), tw (tyre width), hub, spokes, tyre ramp, wood ramp, rot
function G.wheel(c, cx, cy, o)
  local R, tw = o.R, o.tw or 2
  local tok = { r = { name = o.name or "wheel" } }
  local all = HP.mask()
  -- tyre ring
  local ring = HP.mask()
  for y = floor(cy - R - 1), floor(cy + R + 1) do for x = floor(cx - R - 1), floor(cx + R + 1) do
    local d = sqrt((x - cx)^2 + (y - cy)^2)
    if d <= R + 0.4 and d > R - tw - 0.6 then ring:set(x, y) end
  end end
  local n = {}
  ring:each(function(x, y)
    local dx, dy = x - cx, y - cy local d = sqrt(dx*dx + dy*dy) + 1e-6
    local mid = R - tw / 2 - 0.1
    local s = max(-0.95, min(0.95, (d - mid) / (tw / 2 + 0.6)))
    -- outer half faces outward, inner half faces inward
    n[K(x, y)] = { norm(dx / d * s, dy / d * s, sqrt(1 - s*s) + 0.15) }
  end)
  -- felloe (wooden rim) just inside the tyre for wood wheels
  local fel
  if o.felloe then
    fel = HP.mask()
    for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
      local d = sqrt((x - cx)^2 + (y - cy)^2)
      if d <= R - tw - 0.6 and d > R - tw - 0.6 - o.felloe then fel:set(x, y) end
    end end
  end
  -- spokes
  local sp = HP.mask()
  local spn = {}
  local inner = R - tw - (o.felloe or 0)
  for i = 0, o.spokes - 1 do
    local a = (o.rot or 0) + i * 2 * math.pi / o.spokes
    local ux, uy = cos(a), sin(a)
    local m2, n2 = G.rod(cx, cy, cx + ux * (inner + 0.2), cy + uy * (inner + 0.2), o.sw or 0.6)
    sp:add(m2) for k, v in pairs(n2) do spn[k] = v end
  end
  local hubm, hubn = G.oval(cx, cy, o.hub, o.hub, 0, 0.8)
  -- paint: spokes, felloe, tyre, hub
  if sp:count() > 0 then
    local b = {}
    G.ao(b, sp, hubm, 1, -1)
    G.shade(c, sp, spn, o.wood or G.WOOD, { tok = tok, bias = b, amb = 0.15 })
  end
  if fel then
    local fn = {}
    fel:each(function(x, y) local dx, dy = x - cx, y - cy local d = sqrt(dx*dx + dy*dy) + 1e-6
      fn[K(x, y)] = { norm(-dx / d * 0.5, -dy / d * 0.5, 1) } end)
    local b = {}
    fel:each(function(x, y) local d = sqrt((x - cx)^2 + (y - cy)^2) if d > R - tw - 1.4 then b[K(x, y)] = -1 end end)
    G.shade(c, fel, fn, o.wood or G.WOOD, { tok = tok, bias = b, amb = 0.2 })
  end
  local ti = G.shade(c, ring, n, o.tyre or G.IRON, { tok = tok, amb = 0.12, wrap = 0.1, spec = o.spec and { 18, 0.75, o.spec } })
  local hb = {}
  G.shade(c, hubm, hubn, o.hubRamp or G.BRASS, { tok = tok, bias = hb, amb = 0.15, spec = { 12, 0.7, G.SPEC } })
  c:put(floor(cx + .5), floor(cy + .5), (o.hubRamp or G.BRASS)[1], tok)
  all:add(ring) all:add(sp) all:add(hubm) if fel then all:add(fel) end
  return all, ring, hubm, tok
end
function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("%s: recentre dx %d dy %d (outlined size %dx%d)", c.name, dx, dy, W, Hh))
end
function G.save(c, folder, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.assertClean(c)
  local r = HP.report(c, true)
  print(name, "margin", r.margin and (type(r.margin) == "table" and table.concat(r.margin, ",") or r.margin) or "?", "distinct", r.distinct)
  local FIN = DIR .. "/../" .. folder .. "/" .. name
  c:save{ aseprite = FIN .. ".aseprite", png = FIN .. ".png", scale = 1 }
  if app.params.out then c:save{ png = app.params.out .. name .. ".png", scale = 1 } end
end
return G
