-- c25lib.lua : shared painters for the 2.5D creature style (the look of the player gnome and of the three first examples in creature25.lua).
-- A body type (types/<arch>.lua) draws ONE creature from its spec, in FIGURE units: a = right of the creature's centre, b = UP from the ground.
-- One unit is `u` canvas px (small 1.0, medium 1.2, large 1.5, boss 2.0), so the bones a type returns are already in the fight engine's units.
-- Shapes scale with u; details (the eye, fur ticks, dots, 1 px lines) keep their pixel size, so a big creature is richer, not blurrier.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local L = { HP = HP, P = P, DIR = DIR }
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local function rd(v) return floor(v + 0.5) end
L.rd = rd

---------------------------------------------------------------- ramps
-- a ramp = { hi, base, shade, deep }. Only Hearth Pop colours, re-cut into the ramps creatures need.
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local W, G, M, S, D, PT, ST, SK, E = P.wood, P.gold, P.moss, P.sea, P.dusk, P.petal, P.stone, P.sky, P.ember
L.R = {
  cream = R(P.cream, "#ffe0bd", "#f0b98d", "#c98462"),
  white = R(P.cream, ST.hi, ST.base, ST.shade),
  stone = ST, slate = R(ST.base, ST.shade, ST.deep, D.deep),
  wood = W, bark = R(W.base, W.shade, W.deep, P.ink), tan = R("#ffe0bd", W.hi, W.base, W.shade), sand = R(W.hi, "#d9a070", "#b57850", "#8a5638"),
  rust = R(E.hi, G.shade, G.deep, W.deep), orange = R(G.hi, E.hi, G.shade, G.deep), worm = R("#f0b98d", "#c98462", "#8a5638", "#7a4036"),
  ember = E, gold = G, butter = R(P.cream, G.hi, G.base, G.shade),
  moss = M, lime = R(P.cream, M.hi, M.base, M.shade), pine = R(M.base, M.shade, M.deep, P.ink),
  sea = S, ocean = R(S.base, S.shade, S.deep, D.deep), deep = R(S.shade, S.deep, D.deep, P.ink), sky = SK, mint = R(SK.hi, S.hi, S.base, S.shade),
  dusk = D, lilac = R(P.cream, D.hi, D.base, D.shade), night = R(D.base, D.shade, D.deep, P.ink),
  petal = PT, blush = R(P.cream, PT.hi, PT.base, PT.shade),
  ink = R(ST.deep, D.deep, P.ink, P.ink),
}
-- the old mini palette (opus-test-run/scripts/minis) -> a ramp name
L.HEX = {
  ["#4f9a45"] = "moss", ["#7ab55c"] = "lime", ["#2f6a3a"] = "pine", ["#6a9a3a"] = "moss", ["#a4b86a"] = "lime",
  ["#f2e4c0"] = "cream", ["#fff3c8"] = "cream", ["#f1ece0"] = "white", ["#c9c5bc"] = "white", ["#8b8f96"] = "stone", ["#5b6470"] = "slate",
  ["#9a6b3f"] = "wood", ["#b07a45"] = "wood", ["#7a4a1f"] = "bark", ["#8a4f2a"] = "bark", ["#5e2f1e"] = "bark", ["#d9a660"] = "tan", ["#c9a96e"] = "sand",
  ["#a8582f"] = "rust", ["#f08a24"] = "orange", ["#e0501f"] = "orange", ["#d9885a"] = "worm", ["#c47a52"] = "worm",
  ["#dd3a2a"] = "ember", ["#e8a317"] = "gold", ["#f5cf6a"] = "butter",
  ["#3f8fb0"] = "ocean", ["#25637d"] = "deep", ["#a9d6ea"] = "sky", ["#c8ecdc"] = "mint",
  ["#7a5cc0"] = "dusk", ["#c3b2ea"] = "lilac", ["#4e3a8a"] = "night", ["#e46a9b"] = "petal", ["#f6b8cf"] = "blush",
}
function L.ramp(v)   -- a ramp table, a ramp name, or an old mini hex
  if type(v) == "table" then return v end
  if L.R[v] then return L.R[v] end
  local n = L.HEX[v:lower()]; assert(n, "c25: no ramp for " .. tostring(v))
  return L.R[n]
end
function L.darker(r) return R(r.base, r.shade, r.deep, r.deep) end      -- the far side of a pair (legs, wings)
function L.lighter(r) return R(P.cream, r.hi, r.base, r.shade) end

---------------------------------------------------------------- pixel painters (from creature25.lua / gnome-dir.lua)
-- form: flat base, a shade band on the right `frac` of every row and where the shape ends lower right (`off`), optional hi pops {{x,y},..}
function L.form(c, m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  if not o.noshade then
    local rows = {}
    m:each(function(x, y) local t = rows[y]
      if not t then rows[y] = { x, x } else t[1] = min(t[1], x) t[2] = max(t[2], x) end end)
    local frac, off = o.frac or 0.3, o.off or 2
    local list = {}
    m:each(function(x, y)
      if c:get(x, y) ~= r.base:lower() then return end
      local t = rows[y]
      local s = (x - t[1] + 0.5) / (t[2] - t[1] + 1) > 1 - frac
      if not m:has(x + off, y + off) then s = true end
      if s then list[#list + 1] = { x, y } end
    end)
    for _, p in ipairs(list) do c:put(p[1], p[2], r.shade, r) end
  end
  if o.pop then for _, q in ipairs(o.pop) do if m:has(q[1], q[2]) then c:put(q[1], q[2], r.hi, r) end end end
  return m
end
function L.under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end   -- a deep row along the underside
function L.eye(c, x, y)   -- the gnome's 4x4 eye, top-left at x,y: ink lid, cream white, ink pupil looking right
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
-- inside: repaint a pixel only if it already holds one of the given colours (never the outline, never another part)
function L.inside(c, x, y, hex, ...) local v = c:get(x, y); for _, h in ipairs({ ... }) do if v == h:lower() then c:put(x, y, hex) return true end end end
function L.tuft(c, x, y, r, hex) L.inside(c, x, y, hex or r.shade, r.base) L.inside(c, x + 1, y + 1, hex or r.shade, r.base) L.inside(c, x + 2, y, hex or r.shade, r.base) end   -- a little v of fur or feather
function L.toplight(c, m, r, dy)   -- broken highlight just under the top edge: light from above
  local x0, y0, x1, y1 = m:bbox(); if not x0 then return end
  for x = x0 + 2, x1 - 2 do if x % 4 ~= 0 then for y = y0, y1 do if m:has(x, y) then L.inside(c, x, y + (dy or 1), r.hi, r.base) break end end end end
end
function L.belly(c, m, r, d) m:each(function(x, y) if not m:has(x, y + (d or 3)) then L.inside(c, x, y, r.shade, r.base) end end) end   -- a second, darker band along the underside

---------------------------------------------------------------- the figure: figure units -> canvas
local F = {}; F.__index = F
-- L.figure{ c=canvas, u=scale, ox=canvas x of a=0, gy=canvas row of the ground (b=0), spec=, seed= }
function L.figure(o)
  local g = setmetatable({ c = o.c, u = o.u, ox = o.ox, gy = o.gy, s = o.spec or {}, f = (o.spec and o.spec.feat) or {}, q = o.quirk or {}, tag = o.tag, seed = o.seed or 7 }, F)
  g.B = L.ramp(g.s.col or "wood"); g.A = L.ramp(g.s.acc or g.s.col or "cream")
  if g.A == g.B then g.A = L.darker(g.B) end
  g.D = L.darker(g.B)
  return g
end
function F:x(a) return rd(self.ox + a * self.u) end
function F:y(b) return rd(self.gy - b * self.u) end
function F:px(n) return max(1, rd(n * self.u)) end                      -- a length in units -> px (at least 1)
function F:T(n) if self.tag then self.tag(n) end end                   -- name the rig part the following drawing belongs to
local function half(v) return rd(v * 2) / 2 end
-- masks, in figure units
function F:E(a, b, ra, rb) return HP.ellipse(half(self.ox + a * self.u), half(self.gy - b * self.u), max(0.5, ra * self.u - 0.5), max(0.5, (rb or ra) * self.u - 0.5)) end
function F:P(pts) local t = {}; for i, p in ipairs(pts) do t[i] = { self.ox + p[1] * self.u + 0.5, self.gy - p[2] * self.u + 0.5 } end return HP.poly(t) end
function F:R(a0, b0, a1, b1) local x0, x1, y0, y1 = self:x(min(a0, a1)), self:x(max(a0, a1)), self:y(max(b0, b1)), self:y(min(b0, b1)); return HP.rect(x0, y0, x1, y1) end
function F:RR(a0, b0, a1, b1, r) local x0, x1, y0, y1 = self:x(min(a0, a1)), self:x(max(a0, a1)), self:y(max(b0, b1)), self:y(min(b0, b1)); return HP.rrect(x0, y0, x1, y1, max(1, rd((r or 2) * self.u))) end
function F:Ln(pts, w) local t = {}; for i, p in ipairs(pts) do t[i] = { self.ox + p[1] * self.u, self.gy - p[2] * self.u } end return HP.line(t, max(1, rd((w or 1) * self.u))) end   -- a stroke w units wide
function F:Ln1(pts, wpx) local t = {}; for i, p in ipairs(pts) do t[i] = { self.ox + p[1] * self.u, self.gy - p[2] * self.u } end return HP.line(t, wpx or 1) end   -- a stroke wpx PIXELS wide
-- a tapered limb / tail / neck along a polyline: width w0 units at the start, w1 at the end (round joints)
function F:Limb(pts, w0, w1)
  local m = HP.mask(); local n = #pts; local tot, seg = 0, {}
  for i = 1, n - 1 do seg[i] = sqrt((pts[i + 1][1] - pts[i][1]) ^ 2 + (pts[i + 1][2] - pts[i][2]) ^ 2); tot = tot + seg[i] end
  local acc = 0
  for i = 1, n - 1 do
    local steps = max(1, rd(seg[i] * self.u * 1.5))
    for s = 0, steps do
      local t = s / steps; local a, b = pts[i][1] + (pts[i + 1][1] - pts[i][1]) * t, pts[i][2] + (pts[i + 1][2] - pts[i][2]) * t
      local w = w0 + (w1 - w0) * ((acc + seg[i] * t) / max(tot, 1e-6))
      m:add(self:E(a, b, w / 2, w / 2))
    end
    acc = acc + seg[i]
  end
  return m
end
-- painters, in figure units
function F:form(m, r, o)
  o = o or {}
  if o.pop then local t = {}; for _, q in ipairs(o.pop) do local x, y = self:x(q[1]), self:y(q[2]); t[#t + 1] = { x, y } t[#t + 1] = { x + 1, y } if self.u >= 1.4 then t[#t + 1] = { x, y + 1 } end end o = setmetatable({ pop = t }, { __index = o }) end
  if not o.off then o = setmetatable({ off = max(1, rd((o.offu or 2.5) * self.u)) }, { __index = o }) end
  return L.form(self.c, m, r, o)
end
function F:under(m, hex) L.under(self.c, m, hex) end
function F:belly(m, r, d) L.belly(self.c, m, r, max(2, rd((d or 2) * self.u))) end
function F:toplight(m, r, dy) L.toplight(self.c, m, r, dy or (self.u >= 1.4 and 2 or 1)) end
function F:fill(m, hex) self.c:fillMask(m, hex) return m end
function F:put(a, b, hex) self.c:put(self:x(a), self:y(b), hex) end
function F:dots(list, hex) for _, q in ipairs(list) do local x, y = self:x(q[1]), self:y(q[2]); self.c:put(x, y, hex); if self.u >= 1.8 then self.c:put(x + 1, y, hex) end end end
function F:stroke(pts, hex, wpx) self.c:fillMask(self:Ln1(pts, wpx), hex) end                                 -- a 1 px (or wpx) line, painted over anything
function F:over(m, hex, ...) local c, cols = self.c, { ... }; m:each(function(x, y) L.inside(c, x, y, hex, table.unpack(cols)) end) end   -- paint mask m, but only over the given colours
function F:mark(pts, hex, ...) self:over(self:Ln1(pts, 1), hex, ...) end                                    -- a 1 px line drawn only over the given colours
function F:inside(a, b, hex, ...) return L.inside(self.c, self:x(a), self:y(b), hex, ...) end
function F:tuft(a, b, r, hex) L.tuft(self.c, self:x(a), self:y(b), r, hex) end
function F:eye(a, b) L.eye(self.c, self:x(a) - 2, self:y(b) - 2) end                                         -- the gnome's eye, centred on (a, b)
function F:shadow(a, ra) self:T("_sh"); self.c:groundShadow(self:x(a), self.gy + 0.5, ra * self.u, max(2, min(4.5, ra * self.u * 0.14))) end   -- call first
-- deterministic noise 0..1 (so every run draws the same creature)
function F:rnd(i, j) local n = (i * 374761393 + (j or 0) * 668265263 + self.seed * 2147483647) % 4294967296; n = (n ~ (n >> 13)) * 1274126177 % 4294967296; return ((n ~ (n >> 16)) % 10007) / 10007 end
-- fur / feather ticks scattered over mask m (never on its rim): n per 100 px of area
function F:fur(m, r, dens, hex)
  local c, inner = self.c, m:shrink(2); local x0, y0, x1, y1 = inner:bbox(); if not x0 then return end
  local step = max(4, rd(5 * sqrt(1 / (dens or 1))))
  for y = y0, y1, step do for x = x0 + ((y - y0) // step % 2) * (step // 2), x1, step do
    local jx, jy = rd((self:rnd(x, y) - .5) * 2), rd((self:rnd(y, x) - .5) * 2)
    if inner:has(x + jx, y + jy) and inner:has(x + jx + 2, y + jy) then L.tuft(c, x + jx, y + jy, r, hex) end
  end end
end
-- round spots scattered over m: { n=, r= radius px, hex=, ring= hex of a darker rim (rosettes) }
function F:spots(m, o)
  local c, inner = self.c, m:shrink(o.inset or 2); local x0, y0, x1, y1 = inner:bbox(); if not x0 then return end
  local rr = o.r or (self.u >= 1.4 and 1.5 or 1); local step = o.step or max(5, rd(rr * 4 + 2))
  for y = y0, y1, step do for x = x0 + ((y - y0) // step % 2) * (step // 2), x1, step do
    local jx, jy = rd((self:rnd(x, y + 3) - .5) * step * .5), rd((self:rnd(y, x + 5) - .5) * step * .4)
    local sx, sy = x + jx, y + jy
    if inner:has(sx, sy) and inner:has(sx + rd(rr), sy) and inner:has(sx - rd(rr), sy) then
      local sm = HP.ellipse(sx, sy, rr - .5 + .5, rr - .5 + .5); sm:clip(m)
      if o.ring then c:fillMask(sm, o.ring); c:put(sx, sy, o.hex) else c:fillMask(sm, o.hex) end
    end
  end end
end
-- stripes hanging down from the top edge of m (tiger / badger back): every `gap` px, `len` px long, tapering
function F:stripes(m, hex, o)
  o = o or {}; local c = self.c; local x0, y0, x1, y1 = m:bbox(); if not x0 then return end
  local gap, len = o.gap or max(4, rd(4 * self.u)), o.len or max(4, rd(6 * self.u))
  for x = x0 + (o.inset or 3), x1 - (o.inset or 3), gap do
    for y = y0, y1 do if m:has(x, y) then
      local l = rd(len * (0.7 + 0.5 * self:rnd(x, 1)))
      for k = 0, l do if m:has(x + k // 3, y + k) then c:put(x + k // 3, y + k, hex) if k < l * .6 and m:has(x + k // 3 + 1, y + k) then c:put(x + k // 3 + 1, y + k, hex) end end end
      break
    end end
  end
end
L.F = F
return L
