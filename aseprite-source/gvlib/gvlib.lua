-- gvlib.lua : Gnome Venture "Stitched Toy" (art-style-guide Part D + addenda) helper library.
-- Aseprite 1.3.x Lua.  Use:  local GV = dofile("C:/.../gvlib/gvlib.lua")   (or paste above your script)
-- Coordinates are pixel indices on the GRID (x right, y down, 0-based). See README.md.
local GV = {}
local floor, ceil, max, min, abs = math.floor, math.ceil, math.max, math.min, math.abs
local function round(v) return floor(v + 0.5) end
local PAD = 16 -- masks extend PAD px beyond the canvas so halo morphology is not clipped

---------------------------------------------------------------- colours
GV.C = {
  halo = "#f2e4c0", ol1 = "#74462a", ol2 = "#4a2c1a", ol3 = "#2a1a10", umber = "#2a1a10",
  gold = "#f5cf6a", goldS = "#e8a317", hole = "#8a4a1c",
  leg = "#54447f", legTop = "#7b66b4", spot = "#35161f", spotGlint = "#5e2a3a", ground = "#9a6b3f",
}
local C = GV.C

local function h2rgb(h) h = h:gsub("#", "") return tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16) end
local function rgb2hex(r, g, b)
  local function c(v) return min(255, max(0, round(v))) end
  return string.format("#%02x%02x%02x", c(r), c(g), c(b))
end
local function rgb2hsl(r, g, b)
  r, g, b = r/255, g/255, b/255
  local mx, mn = max(r,g,b), min(r,g,b)
  local h, s, l = 0, 0, (mx+mn)/2
  if mx ~= mn then
    local d = mx - mn
    s = l > 0.5 and d/(2-mx-mn) or d/(mx+mn)
    if mx == r then h = (g-b)/d + (g < b and 6 or 0) elseif mx == g then h = (b-r)/d + 2 else h = (r-g)/d + 4 end
    h = h * 60
  end
  return h, s, l
end
local function hue2(p, q, t)
  if t < 0 then t = t + 1 end if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q-p)*6*t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q-p)*(2/3-t)*6 end
  return p
end
local function hsl2hex(h, s, l)
  s, l = min(1, max(0, s)), min(1, max(0, l))
  if s == 0 then return rgb2hex(l*255, l*255, l*255) end
  local q = l < 0.5 and l*(1+s) or l + s - l*s
  local p = 2*l - q
  h = (h % 360) / 360
  return rgb2hex(hue2(p,q,h+1/3)*255, hue2(p,q,h)*255, hue2(p,q,h-1/3)*255)
end
local function toward(h, t, a) -- rotate hue h toward t by at most a degrees (shortest way)
  local d = ((t - h + 540) % 360) - 180
  if abs(d) <= a then return t end
  return h + (d > 0 and a or -a)
end
GV.hsl, GV.fromHsl = function(hex) return rgb2hsl(h2rgb(hex)) end, hsl2hex

---------------------------------------------------------------- ramps
-- GV.ramp("#base" [, overrides]) -> {gloss,dot,rim,base,shade,deep,bounce,pale}
-- Addenda hue-shift recipe: lights toward yellow-orange, shade/deep toward red-violet, bounce = warmer shade.
function GV.ramp(base, ov)
  if type(base) == "string" and base:sub(1,1) ~= "#" then -- preset name, e.g. "red"
    local r = GV.R[base] or error("gvlib: unknown ramp " .. base)
    if not ov then return r end
    local n = {} for k, v in pairs(r) do n[k] = v end for k, v in pairs(ov) do n[k] = v end
    return n
  end
  if type(base) == "table" then
    if base.shade then return base end
    ov, base = base, base.base
  end
  local h, s, l = rgb2hsl(h2rgb(base))
  local r = { base = base, pale = l > 0.78 }
  if r.pale then -- cream-safe treatment (addenda "Pale and light subjects")
    r.gloss, r.dot, r.rim = "#fff3c8", "#ffffff", "#f5b860"
  else
    local gh, gl = toward(h, 45, 20), l + (1-l)*0.35
    r.gloss = hsl2hex(gh, min(1, s*1.1), gl)
    r.dot   = hsl2hex(toward(h, 45, 35), min(1, s*1.1), l + (1-l)*0.6)
    r.rim   = hsl2hex(gh, s, gl*0.9)
  end
  local sh = toward(h, 285, 10)
  r.shade  = hsl2hex(sh, s, l*0.76)
  r.deep   = hsl2hex(toward(h, 285, 25), s, l*0.52)
  r.bounce = hsl2hex(toward(sh, 30, 12), s, l*0.76*1.08)
  for k, v in pairs(ov or {}) do r[k] = v end
  return r
end

-- Approved ramps (Part D + pilot redraws). Use GV.R.name or GV.ramp("#hex").
GV.R = {
  red   = GV.ramp("#dd3a2a", {gloss="#ff9158", dot="#ffc27a", rim="#f2793a", bounce="#b8452f", shade="#ae2a2a", deep="#6b1b2c"}),
  dusk  = GV.ramp("#3e2f66", {gloss="#a894dc", dot="#c3b2ea", rim="#7b66b4", shade="#291d4a", deep="#1e1438", bounce="#4a3a7a"}),
  moss  = GV.ramp("#7ab55c", {gloss="#c8d77a", dot="#e6eea0", rim="#a4b86a", bounce="#6a9a3a", shade="#4a8a3e", deep="#2f5a2a"}),
  leaf  = GV.ramp("#4f9a45", {gloss="#c8d77a", dot="#e6eea0", rim="#a4b86a", shade="#2f6a3a", deep="#1f3f3a", bounce="#5f7a34"}),
  wood  = GV.ramp("#b07a45", {gloss="#ecc58a", dot="#f8e6b8", rim="#d9a660", bounce="#a8582f", shade="#8a4f2a", deep="#5e2f1e"}),
  soil  = GV.ramp("#9a6b3f", {gloss="#e8a060", dot="#ffc27a", rim="#c98a4a", bounce="#b0623a", shade="#7a4a1f", deep="#4e2a16"}),
  gold  = GV.ramp("#e8a317", {gloss="#fff1c8", dot="#fff8e0", rim="#f5cf6a", bounce="#d0862a", shade="#b8661a", deep="#7a3a14"}),
  skin  = GV.ramp("#e9b98a", {gloss="#ffe2a8", dot="#fff4d8", rim="#f9d49c", bounce="#d9885a", shade="#c47a52", deep="#8a4234", pale=false}),
  water = GV.ramp("#3f8fb0", {gloss="#c8ecdc", dot="#eaf8e4", rim="#8fcbd8", bounce="#5a86b8", shade="#2f6290", deep="#2a3c6c"}),
  glass = GV.ramp("#a9d6ea", {gloss="#eef8f2", dot="#f8fcf4", rim="#eef8f2", bounce="#8fb4d6", shade="#6f98c4", deep="#4e5f9a", pale=false}),
  cream = GV.ramp("#f1ece0", {shade="#d8c49a", bounce="#e6d4ac", deep="#9a6b3f"}),
  flame = GV.ramp("#e0501f", {gloss="#ff9158", dot="#ffc27a", rim="#f08a24", bounce="#b8452f", shade="#ae2a2a", deep="#6b1b2c"}),
  petal = GV.ramp("#e46a9b"),
  stone = GV.ramp("#8b8f96"),
  leg   = { base="#54447f", rim="#7b66b4", shade="#54447f", deep="#3e2f66", bounce="#54447f", gloss="#7b66b4", dot="#7b66b4" },
}

---------------------------------------------------------------- masks
local Mask = {}; Mask.__index = Mask
local Canvas = {}; Canvas.__index = Canvas
local DISC = {}
local function disc(r)
  if not DISC[r] then
    local d = {}
    for dy = -r, r do for dx = -r, r do if dx*dx + dy*dy <= r*r + r*0.6 then d[#d+1] = {dx, dy} end end end
    DISC[r] = d
  end
  return DISC[r]
end

function Canvas:key(x, y) return (y + PAD) * self.WW + (x + PAD) end
function Canvas:xy(k) return k % self.WW - PAD, k // self.WW - PAD end
function Canvas:inside(x, y) return x >= 0 and y >= 0 and x < self.W and y < self.H end
function Canvas:mask() return setmetatable({ c = self, s = {} }, Mask) end

function Mask:inpad(x, y) local c = self.c return x >= -PAD and y >= -PAD and x < c.W + PAD and y < c.H + PAD end
function Mask:set(x, y) if self:inpad(x, y) then self.s[self.c:key(x, y)] = true end return self end
function Mask:del(x, y) if self:inpad(x, y) then self.s[self.c:key(x, y)] = nil end return self end
function Mask:has(x, y)
  local c = self.c
  if self:inpad(x, y) and self.s[c:key(x, y)] then return true end
  local b = c.bl
  if c:inside(x, y) then return false end
  if (x < 0 and not b.l) or (x >= c.W and not b.r) or (y < 0 and not b.t) or (y >= c.H and not b.b) then return false end
  return self.s[c:key(min(max(x, 0), c.W-1), min(max(y, 0), c.H-1))] == true -- bleed: clamp to the frame edge
end
local function span(m, x0, y0, x1, y1)
  local W, H = m.c.W, m.c.H
  return max(-PAD, floor(x0)), max(-PAD, floor(y0)), min(W+PAD-1, ceil(x1)), min(H+PAD-1, ceil(y1))
end
-- shapes (all add to the mask and return it, so they chain)
function Mask:rect(x0, y0, x1, y1) -- inclusive corners
  local a, b, c2, d = span(self, x0, y0, x1, y1)
  for y = b, d do for x = a, c2 do self:set(x, y) end end
  return self
end
function Mask:rrect(x0, y0, x1, y1, r) -- inclusive corners, corner radius r
  local a, b, c2, d = span(self, x0, y0, x1, y1)
  for y = b, d do for x = a, c2 do
    local cx, cy = max(x0 + r, min(x, x1 - r)), max(y0 + r, min(y, y1 - r))
    local dx, dy = x - cx, y - cy
    if dx*dx + dy*dy <= r*r + r*0.6 then self:set(x, y) end
  end end
  return self
end
function Mask:ellipse(cx, cy, rx, ry) -- centre pixel, radii in px (spans cx-rx..cx+rx)
  ry = ry or rx
  local ax, ay = rx + 0.35, ry + 0.35
  local a, b, c2, d = span(self, cx - ax, cy - ay, cx + ax, cy + ay)
  for y = b, d do for x = a, c2 do
    local dx, dy = (x - cx)/ax, (y - cy)/ay
    if dx*dx + dy*dy <= 1 then self:set(x, y) end
  end end
  return self
end
function Mask:poly(pts) -- {{x,y},...}; right/bottom edges exclusive
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0, y0, x1, y1 = min(x0,p[1]), min(y0,p[2]), max(x1,p[1]), max(y1,p[2]) end
  local a, b, c2, d = span(self, x0, y0, x1, y1)
  for y = b, d do for x = a, c2 do
    local inside, j = false, #pts
    for i = 1, #pts do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > y) ~= (yj > y)) and (x < (xj-xi)*(y-yi)/(yj-yi) + xi) then inside = not inside end
      j = i
    end
    if inside then self:set(x, y) end
  end end
  return self
end
function Mask:line(pts, w) -- polyline {{x,y},...}, exact width w px (w>=4 gets cut corners)
  w = w or 2
  local o = -floor((w - 1) / 2)
  local function stamp(x, y)
    for dy = 0, w-1 do for dx = 0, w-1 do
      if not (w >= 4 and (dx == 0 or dx == w-1) and (dy == 0 or dy == w-1)) then self:set(x+o+dx, y+o+dy) end
    end end
  end
  if #pts == 1 then stamp(round(pts[1][1]), round(pts[1][2])) end
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local n = max(1, ceil(max(abs(x1-x0), abs(y1-y0))))
    for s = 0, n do stamp(round(x0 + (x1-x0)*s/n), round(y0 + (y1-y0)*s/n)) end
  end
  return self
end
function Mask:ascii(rows, x0, y0, chars) -- set pixels whose char is in `chars` (default: any but '.' and ' ')
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if (chars and chars:find(ch, 1, true)) or (not chars and ch ~= "." and ch ~= " ") then self:set(x0+i-1, y0+j-1) end
  end end
  return self
end
-- set operations (add/cut/clip modify in place; the rest return new masks)
function Mask:add(m) for k in pairs(m.s) do self.s[k] = true end return self end
function Mask:cut(m) for k in pairs(m.s) do self.s[k] = nil end return self end
function Mask:clip(m) for k in pairs(self.s) do if not m.s[k] then self.s[k] = nil end end return self end
function Mask:copy() local n = self.c:mask() for k in pairs(self.s) do n.s[k] = true end return n end
function Mask:grow(r)
  local n, c = self.c:mask(), self.c
  if r <= 0 then return self:copy() end
  local d = disc(r)
  for k in pairs(self.s) do
    local x, y = c:xy(k)
    for _, o in ipairs(d) do n:set(x + o[1], y + o[2]) end
  end
  return n
end
function Mask:shrink(r)
  local n, c = self.c:mask(), self.c
  if r <= 0 then return self:copy() end
  local d = disc(r)
  for k in pairs(self.s) do
    local x, y = c:xy(k)
    local ok = true
    for _, o in ipairs(d) do if not self:has(x + o[1], y + o[2]) then ok = false break end end
    if ok then n.s[k] = true end
  end
  return n
end
function Mask:closed(r) return self:grow(r):shrink(r) end
function Mask:shift(dx, dy) local n, c = self.c:mask(), self.c for k in pairs(self.s) do local x, y = c:xy(k) n:set(x+dx, y+dy) end return n end
function Mask:edge() -- 1 px inner border (4-neighbour)
  local n, c = self.c:mask(), self.c
  for k in pairs(self.s) do
    local x, y = c:xy(k)
    if not (self:has(x+1,y) and self:has(x-1,y) and self:has(x,y+1) and self:has(x,y-1)) then n.s[k] = true end
  end
  return n
end
function Mask:bbox() -- in-canvas bbox: x0,y0,x1,y1 (nil if empty)
  local c, x0, y0, x1, y1 = self.c, 1e9, 1e9, -1e9, -1e9
  for k in pairs(self.s) do
    local x, y = c:xy(k)
    if c:inside(x, y) then x0, y0, x1, y1 = min(x0,x), min(y0,y), max(x1,x), max(y1,y) end
  end
  if x1 < x0 then return nil end
  return x0, y0, x1, y1
end
function Mask:count() local n = 0 for _ in pairs(self.s) do n = n + 1 end return n end
function Mask:each(f) local c = self.c for k in pairs(self.s) do local x, y = c:xy(k) if c:inside(x, y) then f(x, y) end end end
-- shortcuts: c:ellipse(...) == c:mask():ellipse(...)
for _, n in ipairs({"rect","rrect","ellipse","poly","line","ascii"}) do
  Canvas[n] = function(self, ...) local m = self:mask() return m[n](m, ...) end
end

---------------------------------------------------------------- canvas
local MODES = {
  sticker = { halo=5, close=6, ol=2, olx=1, cres=4, margin=3, gl=0 },
  icon    = { halo=6, close=6, ol=2, olx=1, cres=5, margin=3, gl=1 },
  bust    = { w=80, h=100, halo=3, close=4, ol=1, olx=1, cres=5, margin=2, bleed="b", fixed=true, gl=0 },
  scene   = { halo=0, close=0, ol=2, olx=1, cres=4, margin=0, bleed="lrtb", gl=0 },
}
-- GV.canvas{w=64,h=64, mode="sticker"|"icon"|"bust"|"scene", out=1|2, bleed="lrtb", halo=,close=,ol=,olx=,cres=,deep=,margin=}
function GV.canvas(o)
  o = o or {}
  local M = MODES[o.mode or "sticker"] or error("gvlib: unknown mode " .. tostring(o.mode))
  local c = setmetatable({}, Canvas)
  c.mode = o.mode or "sticker"
  c.W, c.H, c.out = o.w or M.w or 64, o.h or M.h or 64, o.out or 1
  c.k = min(c.W, c.H) / 64
  local kk = min(c.k, 1)
  local function pen(n, fl) if o[n] then return o[n] end if M.fixed or M[n] == 0 then return M[n] end return max(fl, round(M[n]*kk)) end
  c.halo, c.close = pen("halo", 3), pen("close", 3)
  c.ol, c.olx = o.ol or M.ol, o.olx or M.olx -- outline never scales up (addenda)
  c.cres = o.cres or max(2, round(M.cres * (M.fixed and 1 or c.k)))
  c.deep = o.deep or max(2, round(1.5 * c.k))
  c.margin = o.margin or (M.fixed and M.margin or max(2, round(M.margin * c.k)))
  c.glx = M.gl
  c.cx, c.cy = o.cx or c.W/2, o.cy or c.H/2
  c.t1, c.t2, c.tx = -18*c.k, -2*c.k, 12*c.k -- selective-outline thresholds on s=(x-cx)+(y-cy)
  local b = o.bleed or M.bleed or ""
  c.bl = { l = b:find("l") ~= nil, r = b:find("r") ~= nil, t = b:find("t") ~= nil, b = b:find("b") ~= nil }
  c.WW = c.W + 2*PAD
  c.pix, c.own, c.shd, c.parts, c.grounds = {}, {}, {}, {}, {}
  c.sil, c.gl = c:mask(), c:mask()
  return c
end
function Canvas:s(x, y) return (x - self.cx) + (y - self.cy) end
function Canvas:tone(x, y) local s = self:s(x, y) return s < self.t1 and C.ol1 or (s < self.t2 and C.ol2 or C.ol3) end
function Canvas:px(x, y, hex) if self:inside(x, y) then self.pix[self:key(x, y)] = hex end return self end
function Canvas:get(x, y) return self:inside(x, y) and self.pix[self:key(x, y)] or nil end
function Canvas:fill(m, hex) m:each(function(x, y) self:px(x, y, hex) end) return self end
-- paint ascii art: legend maps char -> "#hex" or a GV.C name; other chars are skipped
function Canvas:paint(rows, x0, y0, legend)
  for j, row in ipairs(rows) do for i = 1, #row do
    local v = legend[row:sub(i, i)]
    if v then self:px(x0+i-1, y0+j-1, v:sub(1,1) == "#" and v or C[v]) end
  end end
  return self
end

-- c:part(mask, ramp, opts): paint one shaded part on top of what is there.
-- opts: cres, deep (crescent depths), light=mask (crescent measured on this mask), rim=false, bounce=false,
--       gloss=false|{x,y}, contour=false|"#hex", contact=false, stitch=true|{side="lit"}, flat=true,
--       solid=false (not part of the halo/outline silhouette), outline=false (scene mode), pale=true|false
function Canvas:part(m, ramp, o)
  o = o or {}
  local r = GV.ramp(ramp)
  local P = { m = m, r = r, o = o, pale = (o.pale == nil) and r.pale or o.pale, solid = o.solid ~= false }
  local L, cres, dp = o.light or m, o.cres or self.cres, o.deep or self.deep
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return P end
  local mcx, mcy = (x0 + x1)/2, (y0 + y1)/2
  local paint = {}
  for k in pairs(m.s) do
    local x, y = self:xy(k)
    if self:inside(x, y) then
      local col, sh = r.base, false
      local lit = not m:has(x-1, y) or not m:has(x, y-1)
      if o.flat then
        if lit and o.rim ~= false then col = r.rim end
      else
        if not L:has(x+cres, y+cres) then col, sh = r.shade, true end
        if dp > 0 and not L:has(x+dp, y+dp) then col, sh = r.deep, true end
        if o.bounce ~= false and not m:has(x+1, y+1) and (x-mcx) + (y-mcy) > 0 then col, sh = r.bounce, true end
        if o.rim ~= false and not sh and lit then col = r.rim end
      end
      paint[k] = { col, sh }
    end
  end
  local contour = o.contour
  if contour == nil then contour = not (self.mode == "scene" and o.outline ~= false) end
  if contour then -- inner contour where this part overlaps an earlier solid part
    for k, v in pairs(paint) do
      local x, y = self:xy(k)
      for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
        local kn = self:key(x+d[1], y+d[2])
        local q = self.own[kn]
        if not m.s[kn] and q and q ~= P and q.solid then
          v[1] = type(contour) == "string" and contour or (self:s(x, y) < self.t2 and C.ol2 or C.ol3)
          v[2] = true
          break
        end
      end
    end
  end
  if o.contact ~= false then -- 1 px contact shadow on the part below
    for k in pairs(paint) do
      local x, y = self:xy(k)
      local kb = self:key(x, y+1)
      local q = self.own[kb]
      if self:inside(x, y+1) and not m.s[kb] and q and q ~= P then self.pix[kb] = q.r.shade; self.shd[kb] = true end
    end
  end
  for k, v in pairs(paint) do self.pix[k], self.own[k], self.shd[k], self.gl.s[k] = v[1], P, v[2] or nil, nil end
  if P.solid then self.sil:add(m) end
  self.parts[#self.parts+1] = P
  if o.gloss ~= false and not o.flat then self:gloss(m, r, o.gloss) end
  if o.stitch then self:stitch(m, type(o.stitch) == "table" and o.stitch or {}) end
  if self.mode == "scene" and o.outline ~= false then self:outline(m) end
  return P
end

-- c:build{ {"name", mask, ramp, opts}, ... } : parts back to front; returns {name = part}; part.m is its mask
function Canvas:build(list)
  local out = {}
  for _, e in ipairs(list) do out[e[1]] = self:part(e[2], e[3], e[4]) end
  return out
end

-- 2 px lavender limb with a lit top edge, no shading (Part D shape language)
function Canvas:limb(pts, w, o)
  o = o or {}
  o.flat = true
  if o.contact == nil then o.contact = false end
  return self:part(self:line(pts, w or 2), GV.R.leg, o)
end

local function ring2(self, m, d) -- pixels exactly d (default 2) px inside the edge, in canvas
  local s1 = m:shrink((d or 2) - 1)
  local s2 = s1:shrink(1)
  local out = {}
  for k in pairs(s1.s) do
    local x, y = self:xy(k)
    if not s2.s[k] and self:inside(x, y) then out[#out+1] = { x, y, k } end
  end
  return out
end

-- enamel comma on the lit upper-left (2 px in; 3 px in on parts >= 16 px), or nearest to at={x,y}
function Canvas:gloss(m, ramp, at)
  local r = GV.ramp(ramp)
  local x0, y0, x1, y1 = m:bbox()
  if not x0 or x1 - x0 < 5 or y1 - y0 < 5 then return self end
  local ring, best, bv = ring2(self, m, min(x1-x0, y1-y0) >= 15 and 3 or 2), nil, 1e9
  for _, p in ipairs(ring) do
    local v = (type(at) == "table") and ((p[1]-at[1])^2 + (p[2]-at[2])^2) or (p[1] + p[2] + p[2]*0.01)
    if not self.shd[p[3]] and v < bv then best, bv = p, v end
  end
  if not best then return self end
  local L = min(5, max(2, round(min(x1-x0, y1-y0)/7))) + self.glx
  for _, p in ipairs(ring) do
    local dx, dy = p[1]-best[1], p[2]-best[2]
    if dx*dx + dy*dy <= L*L and (dx - dy) >= -L*0.6 and not self.shd[p[3]] then
      self.pix[p[3]] = r.gloss; self.gl.s[p[3]] = true
    end
  end
  local kd = self:key(best[1]+1, best[2]+1)
  if m.s[kd] and not self.shd[kd] then self.pix[kd] = r.dot; self.gl.s[kd] = true end
  return self
end

-- edge stitch: 1 px thread-gold dashes 2 px inside the edge, every 3rd diagonal; skips gloss
function Canvas:stitch(m, o)
  o = o or {}
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return self end
  local mcx, mcy = (x0+x1)/2, (y0+y1)/2
  for _, p in ipairs(ring2(self, m)) do
    local x, y, k = p[1], p[2], p[3]
    if (x + y) % 3 == 0 and not self.gl.s[k] and self.pix[k] and (o.side ~= "lit" or (x-mcx)+(y-mcy) <= 0) then
      self.pix[k] = self.shd[k] and C.goldS or C.gold
    end
  end
  return self
end

-- seam: thread gold 2 on / 1 off along a polyline of pixel points; only on painted parts unless free=true
-- opts: on=2, off=1, gap="#hex" (colour for the off pixels), free=true
function Canvas:seam(pts, o)
  o = o or {}
  local on, off, n, seen = o.on or 2, o.off or 1, 0, {}
  local function visit(x, y)
    local k = self:key(x, y)
    if seen[k] or not self:inside(x, y) then return end
    seen[k] = true
    if not (o.free or self.own[k]) then return end
    if n % (on + off) < on then
      if not self.gl.s[k] then self.pix[k] = self.shd[k] and C.goldS or C.gold end
    elseif o.gap then self.pix[k] = o.gap end
    n = n + 1
  end
  if #pts == 1 then visit(pts[1][1], pts[1][2]) end
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local s = max(1, ceil(max(abs(x1-x0), abs(y1-y0))))
    for t = 0, s do visit(round(x0 + (x1-x0)*t/s), round(y0 + (y1-y0)*t/s)) end
  end
  return self
end

-- 4x4 cut-corner gold button, top-left at (x,y), darker lower-right, two diagonal holes
function Canvas:button(x, y)
  for j = 0, 3 do for i = 0, 3 do
    if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then self:px(x+i, y+j, (i + j >= 4) and C.goldS or C.gold) end
  end end
  self:px(x+1, y+1, C.hole); self:px(x+2, y+2, C.hole)
  return self
end

-- locked eye, top-left at (x,y): 5x5 cream cut-corner disc, 3x3 umber pupil, 1 px glint.
-- small=true (heads under 20 px wide): 3x3 cream disc, 2x2 pupil lower-right.
function Canvas:eye(x, y, small)
  if small then
    for j = 0, 2 do for i = 0, 2 do self:px(x+i, y+j, C.halo) end end
    for j = 1, 2 do for i = 1, 2 do self:px(x+i, y+j, C.ol3) end end
    return self
  end
  for j = 0, 4 do for i = 0, 4 do
    if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then self:px(x+i, y+j, C.halo) end
  end end
  for j = 1, 3 do for i = 1, 3 do self:px(x+i, y+j, C.ol3) end end
  self:px(x+1, y+1, C.halo)
  return self
end

-- spot/marking: fill mask with spot colour + 1 px glaze glint at its upper-left
function Canvas:spot(m, hex, glint)
  self:fill(m, hex or C.spot)
  local x0, y0 = m:bbox()
  if x0 then
    local best, bv = nil, 1e9
    m:each(function(x, y) if x + y < bv then best, bv = {x, y}, x + y end end)
    self:px(best[1], best[2], glint or C.spotGlint)
  end
  return self
end

-- stepped ellipse ground shadow under standing objects (drawn at finish, behind the outline)
function Canvas:ground(cx, cy, rx, ry, hex)
  self.grounds[#self.grounds+1] = { self:ellipse(cx, cy, rx, ry), hex or C.ground }
  return self
end

-- hard stepped bands (skies/glows): o.dir="v"(top->bottom, default)|"h"|"radial" (o.cx,o.cy,o.r)
function Canvas:bands(m, cols, o)
  o = o or {}
  m = m or self:rect(0, 0, self.W-1, self.H-1)
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return self end
  local n = #cols
  m:each(function(x, y)
    local t
    if o.dir == "h" then t = (x - x0) / (x1 - x0 + 1)
    elseif o.dir == "radial" then t = math.sqrt((x - o.cx)^2 + (y - o.cy)^2) / o.r
    else t = (y - y0) / (y1 - y0 + 1) end
    self:px(x, y, cols[min(n, max(1, floor(t * n) + 1))])
  end)
  return self
end

-- 3-tone selective outline: ol px all round, +olx px where s > tx (lower-right). keep=true: only empty px.
function Canvas:outline(m, o)
  o = o or {}
  local ol, olx = o.ol or self.ol, o.olx or self.olx
  local g1 = m:grow(ol)
  local g2 = olx > 0 and m:grow(ol + olx) or g1
  for k in pairs(g2.s) do
    local x, y = self:xy(k)
    if not m.s[k] and self:inside(x, y) and (g1.s[k] or self:s(x, y) > self.tx) and not (o.keep and self.pix[k]) then
      local t = self:tone(x, y)
      if t == C.ol1 and o.pale and o.pale.s[k] then t = C.ol2 end
      self.pix[k], self.own[k], self.shd[k] = t, nil, nil
    end
  end
  return self
end

-- builds outline (non-scene), ground shadows and the 1 px black border (non-scene). Called by save()/check().
function Canvas:finish()
  if self.done then return self end
  self.done = true
  if self.mode ~= "scene" then
    local pale = self:mask()
    for _, P in ipairs(self.parts) do if P.pale and P.solid then pale:add(P.m) end end
    self:outline(self.sil, { keep = true, pale = pale:grow(self.ol + self.olx) })
  end
  for _, g in ipairs(self.grounds) do
    g[1]:each(function(x, y) local k = self:key(x, y) if not self.pix[k] then self.pix[k] = g[2] end end)
  end
  if self.mode ~= "scene" then -- no cream halo: 1 px #000000 border on every transparent px 4-adjacent to art
    local add = {}
    for y = 0, self.H-1 do for x = 0, self.W-1 do
      local k = self:key(x, y)
      if not self.pix[k] and (self.pix[self:key(x+1,y)] or self.pix[self:key(x-1,y)] or self.pix[self:key(x,y+1)] or self.pix[self:key(x,y-1)]) then add[k] = true end
    end end
    for k in pairs(add) do self.pix[k] = "#000000" end
  end
  return self
end

function Canvas:image()
  self:finish()
  local o = self.out
  local img = Image(self.W * o, self.H * o, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  local cache = {}
  for k, h in pairs(self.pix) do
    local x, y = self:xy(k)
    if self:inside(x, y) then
      if not cache[h] then local r, g, b = h2rgb(h) cache[h] = app.pixelColor.rgba(r, g, b, 255) end
      for j = 0, o-1 do for i = 0, o-1 do img:putPixel(x*o + i, y*o + j, cache[h]) end end
    end
  end
  return img
end

-- self-check of an Image: bbox, margin (min gap from any opaque px to the frame), semi (0<alpha<255 count),
-- colours (distinct opaque colours), bw (pure #ffffff px; #000000 is the border), opaque (px count)
function GV.check(img)
  local pc = app.pixelColor
  local W, H = img.width, img.height
  local x0, y0, x1, y1, semi, ncol, bw, opq, seen = W, H, -1, -1, 0, 0, 0, 0, {}
  for it in img:pixels() do
    local v = it()
    local a = pc.rgbaA(v)
    if a > 0 then
      if a < 255 then semi = semi + 1 end
      opq = opq + 1
      local x, y = it.x, it.y
      x0, y0, x1, y1 = min(x0,x), min(y0,y), max(x1,x), max(y1,y)
      local key = pc.rgbaR(v)*65536 + pc.rgbaG(v)*256 + pc.rgbaB(v)
      if not seen[key] then seen[key] = true; ncol = ncol + 1 end
      if key == 0xffffff then bw = bw + 1 end
    end
  end
  local t = { w = W, h = H, bbox = { x0, y0, x1, y1 }, semi = semi, colours = ncol, bw = bw, opaque = opq }
  t.margin = opq > 0 and min(x0, y0, W-1-x1, H-1-y1) or -1
  return t
end
function GV.report(t)
  return string.format("%dx%d bbox=%d,%d..%d,%d margin=%d semi=%d colours=%d pureBW=%d opaque=%d",
    t.w, t.h, t.bbox[1], t.bbox[2], t.bbox[3], t.bbox[4], t.margin, t.semi, t.colours, t.bw, t.opaque)
end
function Canvas:check() return GV.check(self:image()) end

-- save .aseprite and/or .png (either may be nil); creates folders; returns the check table
function Canvas:save(ase, png)
  local img = self:image()
  local spr = Sprite(img.width, img.height, ColorMode.RGB)
  spr.cels[1].image = img
  for _, p in ipairs({ ase, png }) do
    if p then pcall(function() app.fs.makeAllDirectories(app.fs.filePath(p)) end) end
  end
  if ase then spr:saveAs(ase) end
  if png then spr:saveCopyAs(png) end
  local t = GV.check(img)
  spr:close()
  return t
end

return GV
