-- gnome-dir: the approved gnome-opus player gnome in 3 views (front, back, side=facing RIGHT; left = code mirror).
-- 64x80 cells, feet baseline y=70, centre x=32. Per view 8 frames: idle 1-2, walk 3-8
-- (contact, down, passing, contact, down, passing). Same 10 disjoint layers + marker-grey contract as gnome-opus.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local LAYERS = { "shadow", "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
local MARK = { hi = "#f0f0f0", base = "#b4b4b4", shade = "#787878", deep = "#3c3c3c" }
local function cp(r, deep) return { hi = r.hi, base = r.base, shade = r.shade, deep = deep or r.deep } end
local RAMP = {
  hat = cp(P.ember), tunic = cp(P.sea), scarf = cp(P.gold, P.wood.deep), skin = cp(P.skinA, P.wood.deep),
  beard = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade },
  boots = cp(P.wood), trim = cp(P.gold, P.wood.deep),
}
local R = RAMP

local CUR
local function L(n) CUR = n end

local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
  if not o.noshade then
    local rows = {}
    m:each(function(x, y) local t = rows[y]
      if not t then rows[y] = { x, x } else t[1] = math.min(t[1], x) t[2] = math.max(t[2], x) end end)
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
  if o.pop then for _, q in ipairs(o.pop) do c:put(q[1], q[2], r.hi, r) end end
  return m
end
local function under(c, m, hex)
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end)
end
local function newCanvas()
  local c = HP.canvas{ w = 64, h = 80, name = "gnome-dir" }
  c.lay = {}
  local put = getmetatable(c).put
  c.put = function(self, x, y, hex, owner)
    if x >= 0 and y >= 0 and x < self.w and y < self.h then self.lay[y * self.w + x] = CUR end
    return put(self, x, y, hex, owner)
  end
  return c
end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function clog(c, x, dy, frac)
  local m = c:ellipse(x, 67.5 + dy, 4, 2.5)
  form(c, m, R.boots, { frac = frac or 0.35, off = 1, pop = { { math.floor(x) - 2, 66 + dy } } })
  under(c, m, R.boots.deep)
  if dy <= -2 then -- lifted: sole shows as a second deep row
    m:each(function(xx, yy) if not m:has(xx, yy + 2) and m:has(xx, yy + 1) and math.abs(xx - x) < 3 then c:put(xx, yy, R.boots.deep) end end)
  end
end
local function bead(c, x, y)
  local m = c:rect(x - 1, y, x + 1, y + 1)
  form(c, m, R.trim, { off = 1, frac = 0.34, pop = { { x - 1, y } } })
end

-- hat, shared by all views. H maps x (identity = front; 65-x = tip to the viewer's left for back/side).
local function hat(c, b, p, H, opt)
  L("hat")
  local hd = H(2) - H(1)
  local hb = (p.hb or 0) * hd
  local hm = c:ellipse(32.5, 33 + b, 15.5, 3.5)
  for _, x in ipairs({ 19, 26, 33, 40, 46 }) do hm:add(c:ellipse(H(x), 35 + b, 2, 1.5)) end
  hm:add(c:poly{ { H(21), 33 + b }, { H(44), 33 + b }, { H(40), 25 + b }, { H(25), 25 + b } })
  hm:add(c:poly{ { H(25), 26 + b }, { H(40), 26 + b }, { H(37), 18 + b }, { H(28), 19 + b } })
  hm:add(c:line({ { H(32), 19 + b }, { H(36), 14 + b }, { H(41), 12 + b } }, 5))
  hm:add(c:line({ { H(40), 12 + b }, { H(44) + hb, 12 + b }, { H(47) + hb, 15 + b } }, 3))
  form(c, hm, R.hat, { frac = 0.36, off = 2, pop = { { 27, 22 + b }, { 28, 22 + b }, { 27, 23 + b } } })
  under(c, hm, R.hat.deep)
  for _, q in ipairs({ { 36, 19 }, { 37, 19 }, { 38, 18 }, { 40, 25 }, { 39, 25 }, { 41, 14 }, { 42, 14 } }) do c:put(H(q[1]), q[2] + b, R.hat.deep) end
  for x = 22, 43 do local y = math.floor(31.5 - 1.2 * math.sqrt(math.max(0, 1 - ((x - 32.5) / 11) ^ 2)) + 0.5) + 1
    if (x + y) % 5 ~= 0 then c:put(x, y + b, R.hat.shade) end end
  if opt.patch then
    for y = 26, 29 do for x = 28, 31 do c:put(x, y + b, R.hat.shade) end end
    c:put(28, 26 + b, R.hat.deep)
  end
  if opt.seam then for y = 21, 30 do if y % 3 ~= 0 then c:put(33, y + b, R.hat.shade) end end end
  L("trim")
  local pdy = p.pdy or 0
  local px = H(48) + hb
  local pom = c:ellipse(px, 16.5 + b + pdy, 2.5, 2.5)
  form(c, pom, R.trim, { off = 1, frac = 0.35, pop = { { math.floor(px) - 1, 15 + b + pdy } } })
  if opt.patch then
    for _, q in ipairs({ { 27, 25 }, { 32, 25 }, { 27, 30 }, { 32, 30 }, { 29, 25 }, { 32, 28 } }) do c:put(q[1], q[2] + b, R.trim.base) end
  end
  local pts = {}
  for x = 19, 46, 3 do pts[#pts + 1] = { x, math.floor(33 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 32.5) / 16) ^ 2)) - 1.5 + b + 0.5) } end
  c:stitch(pts)
end
local ID = function(x) return x end
local MIR = function(x) return 65 - x end

-- FRONT ---------------------------------------------------------------------------------------------
local function front(p)
  local c = newCanvas()
  local b = -(p.bob or 0)
  L("shadow") c:groundShadow(32, 68.5, 14, 3.5)
  L("boots") clog(c, 27, p.ly or 0) clog(c, 37.5, p.ry or 0)
  L("tunic")
  local hs = p.hem or 0
  local tun = c:ellipse(32.5, 55 + b, 12, 9)
  tun:add(c:poly{ { 22, 58 + b }, { 43, 58 + b }, { 44 + hs, 64 + b }, { 21 + hs, 64 + b } })
  tun:cut(c:poly{ { 32, 62 + b }, { 33, 62 + b }, { 34 + hs, 65 + b }, { 31 + hs, 65 + b } })
  form(c, tun, R.tunic, { frac = 0.32, off = 2 })
  under(c, tun, R.tunic.deep)
  for x = 21, 44 do if tun:has(x, 57 + b) then c:put(x, 57 + b, R.tunic.deep) end end
  for x = 37, 43 do if tun:has(x, 58 + b) then c:put(x, 58 + b, R.tunic.deep) end end
  local la, ra = p.arm or 0, -(p.arm or 0)
  local function sleeve(cx, dy, fr)
    local m = c:ellipse(cx, 52 + b + dy, 3, 4.5)
    form(c, m, R.tunic, { frac = fr, off = 1 }) under(c, m, R.tunic.deep)
  end
  sleeve(20, la, 0.3) sleeve(45, ra, 0.6)
  L("skin")
  form(c, c:ellipse(20, 57 + b + la, 2.5, 2), R.skin, { off = 1, frac = 0.3 })
  form(c, c:ellipse(45, 57 + b + ra, 2.5, 2), R.skin, { off = 1, frac = 0.5 })
  L("scarf")
  local tl = p.tail or 0
  form(c, c:rrect(21, 45 + b, 44, 49 + b, 2), R.scarf, { frac = 0.25, off = 1 })
  form(c, c:poly{ { 22, 46 + b }, { 26, 47 + b }, { 20 + tl, 55 + b }, { 16 + tl, 54 + b } }, R.scarf, { frac = 0.5, off = 1 })
  for i = 0, 4, 2 do c:put(16 + i + tl, 55 + b - (i > 2 and 1 or 0), R.scarf.shade) end
  c:put(23, 48 + b, R.scarf.deep) c:put(24, 49 + b, R.scarf.deep)
  L("skin")
  form(c, c:ellipse(32.5, 39 + b, 10.5, 7), R.skin, { frac = 0.25, off = 1 })
  form(c, c:poly{ { 23, 37 + b }, { 16, 34 + b }, { 19, 39 + b }, { 23, 42 + b } }, R.skin, { off = 1, frac = 0.2 })
  form(c, c:poly{ { 42, 37 + b }, { 49, 34 + b }, { 46, 39 + b }, { 42, 42 + b } }, R.skin, { off = 1, frac = 0.6 })
  L("beard")
  local bs = p.braid or 0
  local bm = c:poly{ { 23, 42 + b }, { 42, 42 + b }, { 44, 46 + b }, { 41, 52 + b }, { 24, 52 + b }, { 21, 46 + b } }
  bm:add(c:ellipse(32.5, 51 + b, 7, 3))
  bm:add(c:line({ { 28, 51 + b }, { 27, 55 + b }, { 26 + bs, 59 + b } }, 3))
  bm:add(c:line({ { 37, 51 + b }, { 38, 55 + b }, { 39 + bs, 59 + b } }, 3))
  form(c, bm, R.beard, { frac = 0.3, off = 2, pop = { { 24, 45 + b }, { 25, 45 + b }, { 24, 46 + b } } })
  for _, q in ipairs({ { 27, 54 }, { 28, 54 }, { 26, 57 }, { 27, 57 }, { 37, 54 }, { 38, 54 }, { 38, 57 }, { 39, 57 } }) do
    local x = q[1] + (q[2] >= 57 and bs or 0)
    if bm:has(x, q[2] + b) then c:put(x, q[2] + b, R.beard.shade) end
  end
  c:put(32, 52 + b, R.beard.deep) c:put(33, 52 + b, R.beard.deep) c:put(32, 53 + b, R.beard.deep)
  local mu = c:ellipse(32.5, 45 + b, 6.5, 1.5)
  mu:add(c:rect(25, 43 + b, 25, 44 + b)) mu:add(c:rect(40, 43 + b, 40, 44 + b))
  form(c, mu, R.beard, { off = 1, frac = 0.3, inner = false, pop = { { 28, 44 + b }, { 29, 44 + b } } })
  c:put(32, 46 + b, R.beard.shade) c:put(33, 46 + b, R.beard.shade)
  L("skin")
  local nose = c:ellipse(32.5, 42.5 + b, 2.5, 2.5)
  form(c, nose, R.skin, { off = 1, frac = 0.35, inner = false }) under(c, nose, R.skin.shade)
  L("face") c:put(31, 41 + b, P.cream)
  eye(c, 25, 37 + b) eye(c, 36, 37 + b)
  c:cheek(23, 42 + b) c:cheek(41, 42 + b)
  hat(c, b, p, ID, { patch = true })
  L("trim")
  form(c, c:rect(31, 56 + b, 34, 58 + b), R.trim, { off = 1, frac = 0.3 })
  c:put(32, 57 + b, R.trim.deep) c:put(33, 57 + b, R.trim.deep)
  bead(c, 26 + bs, 60 + b) bead(c, 39 + bs, 60 + b)
  return c
end

-- BACK (mirror-consistent: tail and hat tip swap sides) --------------------------------------------
local function back(p)
  local c = newCanvas()
  local b = -(p.bob or 0)
  L("shadow") c:groundShadow(32, 68.5, 14, 3.5)
  L("boots") clog(c, 27, p.ly or 0, 0.45) clog(c, 37.5, p.ry or 0, 0.45)
  L("tunic")
  local hs = p.hem or 0
  local tun = c:ellipse(32.5, 55 + b, 12, 9)
  tun:add(c:poly{ { 22, 58 + b }, { 43, 58 + b }, { 44 + hs, 64 + b }, { 21 + hs, 64 + b } })
  form(c, tun, R.tunic, { frac = 0.32, off = 2 })
  under(c, tun, R.tunic.deep)
  for x = 21, 44 do if tun:has(x, 57 + b) then c:put(x, 57 + b, R.tunic.deep) end end
  for y = 59, 63 do c:put(32 + (y > 61 and hs or 0), y + b, R.tunic.shade) end -- back pleat
  local la, ra = p.arm or 0, -(p.arm or 0)
  local function sleeve(cx, dy, fr)
    local m = c:ellipse(cx, 52 + b + dy, 3, 4.5)
    form(c, m, R.tunic, { frac = fr, off = 1 }) under(c, m, R.tunic.deep)
  end
  sleeve(20, la, 0.3) sleeve(45, ra, 0.6)
  L("skin")
  form(c, c:ellipse(20, 57 + b + la, 2.5, 2), R.skin, { off = 1, frac = 0.3 })
  form(c, c:ellipse(45, 57 + b + ra, 2.5, 2), R.skin, { off = 1, frac = 0.5 })
  -- beard: only side wisps flaring past the cheeks
  L("beard")
  local bs = p.braid or 0
  local wl = c:poly{ { 24, 41 + b }, { 24, 47 + b }, { 21, 48 + b }, { 18 - bs, 46 + b }, { 19, 43 + b } }
  local wr = c:poly{ { 41, 41 + b }, { 41, 47 + b }, { 44, 48 + b }, { 47 - bs, 46 + b }, { 46, 43 + b } }
  form(c, wl, R.beard, { frac = 0.3, off = 1, pop = { { 20, 44 + b } } })
  form(c, wr, R.beard, { frac = 0.5, off = 1 })
  -- scarf ring + tail hanging down the back on the viewer's right (front tail mirrored)
  L("scarf")
  local tl = p.tail or 0
  form(c, c:rrect(21, 45 + b, 44, 49 + b, 2), R.scarf, { frac = 0.25, off = 1 })
  form(c, c:poly{ { 43, 46 + b }, { 39, 47 + b }, { 41 - tl, 57 + b }, { 46 - tl, 56 + b } }, R.scarf, { frac = 0.5, off = 1 })
  for i = 0, 4, 2 do c:put(41 + i - tl, 57 + b, R.scarf.shade) end
  for x = 26, 39, 4 do c:put(x, 47 + b, R.scarf.shade) end -- knit ridges
  L("skin")
  form(c, c:ellipse(32.5, 39 + b, 10.5, 7), R.skin, { frac = 0.25, off = 1 })
  form(c, c:poly{ { 23, 37 + b }, { 16, 34 + b }, { 19, 39 + b }, { 23, 42 + b } }, R.skin, { off = 1, frac = 0.2 })
  form(c, c:poly{ { 42, 37 + b }, { 49, 34 + b }, { 46, 39 + b }, { 42, 42 + b } }, R.skin, { off = 1, frac = 0.6 })
  -- back of head: white hair (beard colour), strands, nape skin peeks at the bottom
  L("beard")
  local hair = c:ellipse(32.5, 38.5 + b, 9, 6)
  form(c, hair, R.beard, { frac = 0.3, off = 1, pop = { { 26, 37 + b }, { 27, 37 + b } } })
  for _, x in ipairs({ 27, 30, 33, 36, 39 }) do for y = 41, 43 do if hair:has(x, y + b) and (x + y) % 2 == 0 then c:put(x, y + b, R.beard.shade) end end end
  hat(c, b, p, MIR, { seam = true })
  return c
end

-- SIDE (profile facing RIGHT) ------------------------------------------------------------------------
local function side(p)
  local c = newCanvas()
  local b = -(p.bob or 0)
  L("shadow") c:groundShadow(32, 68.5, 13, 3.5)
  L("boots")
  clog(c, 31 + (p.fx or -2), p.fl or 0, 0.6)
  clog(c, 33 + (p.nx or 2), p.nl or 0, 0.35)
  L("tunic")
  local hs = p.hem or 0
  local tun = c:ellipse(32.5, 55 + b, 10, 9)
  tun:add(c:ellipse(34, 56 + b, 9, 7.5))
  tun:add(c:poly{ { 24, 58 + b }, { 41, 58 + b }, { 42 + hs, 64 + b }, { 23 + hs, 64 + b } })
  form(c, tun, R.tunic, { frac = 0.32, off = 2 })
  under(c, tun, R.tunic.deep)
  for x = 20, 46 do if tun:has(x, 57 + b) then c:put(x, 57 + b, R.tunic.deep) end end
  for y = 59, 63 do c:put(27 + (y > 61 and hs or 0), y + b, R.tunic.shade) end
  -- scarf tail trailing behind
  L("scarf")
  local tl = p.tail or 0
  form(c, c:poly{ { 25, 45 + b }, { 29, 47 + b }, { 22 + tl, 56 + b }, { 18 + tl, 54 + b } }, R.scarf, { frac = 0.5, off = 1 })
  for i = 0, 4, 2 do c:put(18 + i + tl, 55 + b + (i > 2 and 1 or 0), R.scarf.shade) end
  -- near arm swinging
  L("tunic")
  local ad = p.arm or 0
  local sl = c:line({ { 31, 48 + b }, { 31 + ad // 2, 52 + b }, { 31 + ad, 55 + b } }, 5)
  form(c, sl, R.tunic, { frac = 0.5, off = 1 }) under(c, sl, R.tunic.deep)
  L("skin") form(c, c:ellipse(31 + ad, 57.5 + b, 2.5, 2), R.skin, { off = 1, frac = 0.4 })
  L("scarf")
  form(c, c:rrect(24, 45 + b, 41, 49 + b, 2), R.scarf, { frac = 0.25, off = 1 })
  c:put(27, 48 + b, R.scarf.deep) c:put(28, 49 + b, R.scarf.deep)
  L("skin")
  local head = c:ellipse(33, 39 + b, 9.5, 7)
  form(c, head, R.skin, { frac = 0.25, off = 1 })
  L("beard")
  local hair = head:copy() hair:clip(c:rect(0, 0, 30, 79))
  form(c, hair, R.beard, { frac = 0.2, off = 1, pop = { { 25, 37 + b } } })
  for _, x in ipairs({ 25, 28 }) do for y = 40, 43 do if hair:has(x, y + b) and y % 2 == 0 then c:put(x, y + b, R.beard.shade) end end end
  L("skin")
  local ear = c:poly{ { 31, 37 + b }, { 22, 33 + b }, { 25, 38 + b }, { 30, 42 + b } }
  form(c, ear, R.skin, { off = 1, frac = 0.3 })
  c:put(28, 38 + b, R.skin.shade) c:put(27, 37 + b, R.skin.shade)
  L("beard")
  local bs = p.braid or 0
  local bm = c:poly{ { 31, 42 + b }, { 40, 43 + b }, { 44, 46 + b }, { 42, 52 + b }, { 33, 52 + b }, { 29, 46 + b } }
  bm:add(c:line({ { 34, 51 + b }, { 34, 55 + b }, { 34 + bs, 58 + b } }, 3))
  bm:add(c:line({ { 39, 51 + b }, { 40, 55 + b }, { 41 + bs, 59 + b } }, 3))
  form(c, bm, R.beard, { frac = 0.3, off = 2, pop = { { 31, 45 + b }, { 32, 45 + b }, { 31, 46 + b } } })
  for _, q in ipairs({ { 39, 54 }, { 40, 54 }, { 40, 57 }, { 41, 57 }, { 33, 54 }, { 34, 54 } }) do
    local x = q[1] + (q[2] >= 57 and bs or 0)
    if bm:has(x, q[2] + b) then c:put(x, q[2] + b, R.beard.shade) end
  end
  local mu = c:ellipse(41, 45 + b, 3.5, 1.5)
  mu:add(c:rect(44, 43 + b, 44, 44 + b))
  form(c, mu, R.beard, { off = 1, frac = 0.3, inner = false, pop = { { 39, 44 + b } } })
  L("skin")
  local nose = c:ellipse(43.5, 42.5 + b, 2.5, 2.5)
  form(c, nose, R.skin, { off = 1, frac = 0.35, inner = false }) under(c, nose, R.skin.shade)
  L("face") c:put(42, 41 + b, P.cream)
  eye(c, 36, 37 + b)
  c:cheek(37, 42 + b)
  hat(c, b, p, MIR, { patch = true })
  L("trim")
  form(c, c:rect(41, 56 + b, 42, 58 + b), R.trim, { off = 1, frac = 0.3 })
  bead(c, 34 + bs, 59 + b) bead(c, 41 + bs, 60 + b)
  return c
end

-- frame tables: idle 2 + walk 6 (contact, down, passing, contact, down, passing); bob<0 = body 1px down.
-- hat tip / braid / tail lag the body by one frame.
local IDLE = { { bob = 0 }, { bob = 1, pdy = 1 } }
local FB = {
  { bob = 0,  ly = 0,  ry = -1, arm = -2, hb = 0,  braid = 0,  tail = 0,  pdy = 0, hem = 0 },
  { bob = -1, ly = 0,  ry = -2, arm = -1, hb = -1, braid = -1, tail = -1, pdy = 0, hem = -1 },
  { bob = 0,  ly = 0,  ry = -3, arm = 0,  hb = -1, braid = -1, tail = -1, pdy = 1, hem = 0 },
  { bob = 0,  ly = -1, ry = 0,  arm = 2,  hb = 0,  braid = 0,  tail = 0,  pdy = 0, hem = 0 },
  { bob = -1, ly = -2, ry = 0,  arm = 1,  hb = 1,  braid = 1,  tail = 1,  pdy = 0, hem = 1 },
  { bob = 0,  ly = -3, ry = 0,  arm = 0,  hb = 1,  braid = 1,  tail = 1,  pdy = 1, hem = 0 },
}
local SD = {
  { bob = 0,  nx = 4,  nl = 0,  fx = -4, fl = 0,  arm = -3, hb = 0, pdy = 0, braid = 0,  tail = 0,  hem = 0 },
  { bob = -1, nx = 2,  nl = 0,  fx = -3, fl = -2, arm = -2, hb = 0, pdy = 0, braid = 0,  tail = -1, hem = -1 },
  { bob = 0,  nx = -1, nl = 0,  fx = 1,  fl = -3, arm = 0,  hb = 1, pdy = 1, braid = -1, tail = -1, hem = 0 },
  { bob = 0,  nx = -4, nl = 0,  fx = 4,  fl = 0,  arm = 3,  hb = 0, pdy = 0, braid = 0,  tail = 0,  hem = 0 },
  { bob = -1, nx = -3, nl = -2, fx = 2,  fl = 0,  arm = 2,  hb = 0, pdy = 0, braid = 0,  tail = -1, hem = -1 },
  { bob = 0,  nx = 1,  nl = -3, fx = -1, fl = 0,  arm = 0,  hb = 1, pdy = 1, braid = -1, tail = -1, hem = 0 },
}
local VIEWS = { { "front", front, FB }, { "back", back, FB }, { "side", side, SD } }

local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local TINT = {}
for role, r in pairs(RAMP) do TINT[role] = { [r.hi:lower()] = "hi", [r.base:lower()] = "base", [r.shade:lower()] = "shade", [r.deep:lower()] = "deep" } end
local tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 8 } }
local W, H = 64, 80

for _, v in ipairs(VIEWS) do
  local name, fn, walk = v[1], v[2], v[3]
  local frames = {}
  for _, p in ipairs(IDLE) do local c = fn(p) L("outline") c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
  for _, p in ipairs(walk) do local c = fn(p) L("outline") c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
  local N = #frames
  HP.sheet{ cellw = W, cellh = H, frames = frames, tags = tags }:save{ png = out .. name .. ".png", scale = 1 }
  local imgs, stats = {}, {}
  for _, ln in ipairs(LAYERS) do
    imgs[ln] = {} stats[ln] = 0
    for f = 1, N do local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0)) imgs[ln][f] = im end
  end
  for f, c in ipairs(frames) do
    for i, hex in pairs(c.pix) do
      local ln = c.lay[i] or error("pixel without layer")
      local t, o = TINT[ln], hex
      if t then o = MARK[t[hex] or error(string.format("%s %s colour %s not in ramp (f%d px%d)", name, ln, hex, f, i))] end
      imgs[ln][f]:putPixel(i % W, i // W, rgba(o))
      stats[ln] = stats[ln] + 1
    end
  end
  local line = name .. ":"
  for _, ln in ipairs(LAYERS) do
    local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
    for f = 1, N do strip:drawImage(imgs[ln][f], Point((f - 1) * W, 0)) end
    local spr = Sprite(W * N, H, ColorMode.RGB) spr.cels[1].image = strip
    spr:saveCopyAs(out .. name .. "-" .. ln .. ".png") spr:close()
    line = line .. " " .. ln .. "=" .. stats[ln]
  end
  print(line)
end
print("gnome-dir: 3 views x 8 frames -> " .. out)
