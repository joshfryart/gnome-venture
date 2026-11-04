-- gnome-hybrid: new 2.5D player gnome (bent hat, braided V beard, bushy brows, belt). Same rig layers/order.
-- Run: AppRun -b --script-param out=<dir>/ --script gnome-hybrid.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local LAYERS = { "shadow", "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
local MARK = { hi = "#f0f0f0", base = "#b4b4b4", shade = "#787878", deep = "#3c3c3c" }
local function cp(r, deep) return { hi = r.hi, base = r.base, shade = r.shade, deep = deep or r.deep } end
local WD = P.wood.deep
local RAMP = {
  boots = cp(P.wood), tunic = cp(P.sea), scarf = cp(P.gold, WD), skin = cp(P.skinA, WD),
  beard = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade },
  hat = cp(P.ember), trim = cp(P.gold, WD),
}
local INK = "#2b1c26"
local SEC = "shadow"

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
  if o.pop then c:put(o.pop[1], o.pop[2], r.hi, r) c:put(o.pop[1] + 1, o.pop[2], r.hi, r) end
  return m
end
local function under(c, m, hex, x0, x1)
  m:each(function(x, y) if not m:has(x, y + 1) and (not x0 or (x >= x0 and x <= x1)) then c:put(x, y, hex) end end)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = "gnome" }
  c.lay = {}
  local rawput = getmetatable(c).put
  c.put = function(self, x, y, hex, owner)
    if x >= 0 and y >= 0 and x < self.w and y < self.h then self.lay[y * self.w + x] = SEC end
    return rawput(self, x, y, hex, owner)
  end
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  SEC = "shadow"
  c:groundShadow(31.5, 68.5, 13.5, 3.5)
  -- boots: round clogs, toe curled UP
  SEC = "boots"
  local function boot(x, dy, dir)
    local m = c:ellipse(x, 68 + dy, 4, 2)
    m:add(c:rect(x + dir * 4, 67 + dy, x + dir * 5, 68 + dy))
    m:add(c:rect(x + dir * 5, 66 + dy, x + dir * 5, 66 + dy))
    form(c, m, RAMP.boots, { frac = 0.35, off = 1 })
    under(c, m, RAMP.boots.deep)
  end
  boot(27, p.ly or 0, -1) boot(38, p.ry or 0, 1)
  -- tunic: tall smock with belt
  SEC = "tunic"
  local hs = p.hem or 0
  local tunic = c:poly{ {X(25), 45 + b}, {X(41), 45 + b}, {X(46), 62 + b}, {X(20), 62 + b} }
  tunic:add(c:ellipse(X(33) + hs, 62.5 + b, 13, 4))
  form(c, tunic, RAMP.tunic, { frac = 0.3, off = 2 })
  under(c, tunic, RAMP.tunic.deep)
  for x = 23, 43 do if tunic:has(X(x), 58 + b) then c:put(X(x), 58 + b, RAMP.tunic.deep) end end
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  local function sleeve(x0, dy, dir)
    SEC = "tunic"
    local m = c:poly{ {X(x0 + 1), 46 + b}, {X(x0 + 4), 46 + b}, {X(x0 + 5), 54 + b + dy}, {X(x0 - 1), 54 + b + dy} }
    form(c, m, RAMP.tunic, { frac = dir < 0 and 0.35 or 0.55, off = 1 })
    under(c, m, RAMP.tunic.deep)
    SEC = "skin"
    form(c, c:ellipse(X(x0 + 2) + (dir < 0 and 0 or 1), 55.5 + b + dy, 2, 1.5), RAMP.skin, { off = 1, frac = 0.35 })
  end
  sleeve(17, la, -1) sleeve(45, ra, 1)
  -- scarf: ring + knotted tail on the LEFT
  SEC = "scarf"
  form(c, c:rrect(X(20), 44 + b, X(46), 48 + b, 2), RAMP.scarf, { frac = 0.25, off = 1 })
  local tl = p.tail or 0
  local tail = c:poly{ {X(22), 47 + b}, {X(27), 47 + b}, {X(27) + tl, 56 + b}, {X(23) + tl, 56 + b} }
  form(c, tail, RAMP.scarf, { frac = 0.45, off = 1 })
  for x = 23, 27 do if x % 2 == 1 then c:put(X(x) + tl, 56 + b, RAMP.scarf.shade) end end
  -- head + long drooping ears
  SEC = "skin"
  form(c, c:ellipse(X(33), 40 + b, 11, 7), RAMP.skin, { frac = 0.25, off = 1 })
  form(c, c:poly{ {X(23), 37 + b}, {X(18), 38 + b}, {X(14), 43 + b}, {X(19), 43 + b}, {X(23), 42 + b} }, RAMP.skin, { off = 1, frac = 0.2 })
  form(c, c:poly{ {X(43), 37 + b}, {X(48), 38 + b}, {X(52), 43 + b}, {X(47), 43 + b}, {X(43), 42 + b} }, RAMP.skin, { off = 1, frac = 0.6 })
  -- beard: wide cheeks narrowing to a V point, side-swept braid with bead
  SEC = "beard"
  local bm = c:poly{ {X(22), 42 + b}, {X(44), 42 + b}, {X(46), 46 + b}, {X(41), 52 + b}, {X(36), 56 + b}, {X(33), 59 + b},
    {X(30), 56 + b}, {X(25), 52 + b}, {X(20), 46 + b} }
  form(c, bm, RAMP.beard, { frac = 0.3, off = 2, pop = { X(24), 46 + b } })
  for y = 47, 53 do c:put(X(29 + (y > 50 and 1 or 0)), y + b, RAMP.beard.shade) end
  for y = 47, 51 do c:put(X(38 - (y > 49 and 1 or 0)), y + b, RAMP.beard.shade) end
  local braid = c:line({ { X(33), 58 + b }, { X(34), 61 + b }, { X(32), 63 + b } }, 2)
  form(c, braid, RAMP.beard, { off = 1, frac = 0.4, inner = false })
  for y = 59, 63 do if (y % 2 == 0) then c:put(X(33) + (y > 60 and 0 or 0), y + b, RAMP.beard.shade) end end
  -- drooping moustache
  local ml = c:ellipse(X(29), 45 + b, 3.5, 1.5) ml:add(c:rect(X(25), 45 + b, X(25), 47 + b))
  local mr = c:ellipse(X(37), 45 + b, 3.5, 1.5) mr:add(c:rect(X(41), 45 + b, X(41), 47 + b))
  form(c, ml, RAMP.beard, { off = 1, frac = 0.15, inner = false })
  form(c, mr, RAMP.beard, { off = 1, frac = 0.35, inner = false })
  c:put(X(33), 46 + b, RAMP.beard.shade)
  -- bushy brows (quirk)
  for x = 26, 30 do c:put(X(x), 38 + b, RAMP.beard.base) end
  for x = 36, 40 do c:put(X(x), 38 + b, RAMP.beard.base) end
  c:put(X(30), 38 + b, RAMP.beard.shade) c:put(X(40), 38 + b, RAMP.beard.shade)
  -- nose
  SEC = "skin"
  local nose = c:ellipse(X(33.5), 43 + b, 2.5, 2)
  form(c, nose, RAMP.skin, { off = 1, frac = 0.35, inner = false })
  under(c, nose, RAMP.skin.shade)
  -- face (fixed): nose glint + eyes with cream disc, ink pupil, glint
  SEC = "face"
  c:put(X(32), 42 + b, P.cream)
  local function eye(x0)
    local S = P.stone.hi
    for i = 0, 3 do c:put(X(x0 + i), 39 + b, S) end
    c:put(X(x0), 40 + b, S) c:put(X(x0 + 3), 40 + b, S)
    c:put(X(x0), 41 + b, S) c:put(X(x0 + 3), 41 + b, S)
    c:put(X(x0 + 1), 40 + b, P.cream)
    c:put(X(x0 + 2), 40 + b, INK) c:put(X(x0 + 1), 41 + b, INK) c:put(X(x0 + 2), 41 + b, INK)
  end
  eye(27) eye(37)
  -- hat: bent cone leaning right, broad rolled brim, tip drooping right
  SEC = "hat"
  local hm = c:poly{ {X(19), 34 + b}, {X(47), 34 + b}, {X(45), 29 + b}, {X(43), 24 + b}, {X(40), 19 + b}, {X(36), 15 + b},
    {X(31), 14 + b}, {X(26), 17 + b}, {X(23), 22 + b}, {X(21), 28 + b} }
  hm:add(c:ellipse(X(33), 33.5 + b, 14.5, 3.5))
  form(c, hm, RAMP.hat, { frac = 0.36, off = 2, pop = { X(27), 22 + b } })
  under(c, hm, RAMP.hat.deep, X(22), X(44))
  local bx, by = (p.bell or 0), (p.bdy or 0)
  local flop = c:line({ { X(36), 14 + b }, { X(42), 13 + b }, { X(47), 16 + b }, { X(50) + bx, 21 + b + by } }, 3)
  form(c, flop, RAMP.hat, { off = 1, frac = 0.3 })
  c:put(X(36), 16 + b, RAMP.hat.deep) c:put(X(37), 17 + b, RAMP.hat.deep) c:put(X(35), 16 + b, RAMP.hat.shade)
  SEC = "trim"
  local bell = c:ellipse(X(50.5) + bx, 24.5 + b + by, 2, 2)
  form(c, bell, RAMP.trim, { off = 1, frac = 0.3 })
  c:put(X(50) + bx, 26 + b + by, RAMP.trim.deep) c:put(X(51) + bx, 26 + b + by, RAMP.trim.deep)
  -- bead on the braid, belt buckle
  c:put(X(32), 64 + b, RAMP.trim.base) c:put(X(33), 64 + b, RAMP.trim.shade)
  c:put(X(38), 58 + b, RAMP.trim.base) c:put(X(39), 58 + b, RAMP.trim.base) c:put(X(38), 59 + b, RAMP.trim.shade) c:put(X(39), 59 + b, RAMP.trim.shade)
  -- hat band stitch
  local pts = {}
  for x = 21, 45, 2 do pts[#pts + 1] = { X(x), math.floor(33.5 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 33) / 14.5) ^ 2)) - 1.5 + b + 0.5) } end
  c:stitch(pts)
  SEC = "outline"
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, bdy = 1 } }
local walk = {
  { bob = 0, ly = 2, ry = -2, arm = -1, bell = 1, hem = 1, tail = 0 },
  { bob = 1, ly = 0, ry = -3, arm = 0, sx = -1, bell = 0, bdy = 1, tail = 1 },
  { bob = 0, ly = -2, ry = 2, arm = 1, bell = -1, hem = -1, tail = 0 },
  { bob = 1, ly = -3, ry = 0, arm = 0, sx = 1, bell = 0, bdy = 1, tail = -1 },
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } } }
s:save{ png = out .. "gnome-hybrid.png", scale = 1 }

-- split into layers
local W, H, N = 64, 80, #fr
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for _, ln in ipairs(LAYERS) do imgs[ln] = {} for f = 1, N do local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0)) imgs[ln][f] = im end end
for f, c in ipairs(fr) do
  for i, hex in pairs(c.pix) do
    local ln = c.lay[i] or error("pixel without layer")
    local o = hex
    local r = RAMP[ln]
    if r then
      local h = hex:lower()
      local m
      for k, v in pairs(r) do if v:lower() == h then m = m or k if k == "deep" or k == "shade" or k == "base" or k == "hi" then m = (m == "deep" or k == "deep") and "deep" or k end end end
      m = m or error(string.format("%s colour %s not in ramp (frame %d)", ln, hex, f))
      o = MARK[m]
    end
    imgs[ln][f]:putPixel(i % W, i // W, rgba(o))
  end
end
for _, ln in ipairs(LAYERS) do
  local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, N do strip:drawImage(imgs[ln][f], Point((f - 1) * W, 0)) end
  local spr = Sprite(W * N, H, ColorMode.RGB) spr.cels[1].image = strip
  spr:saveCopyAs(out .. "gnome-" .. ln .. ".png") spr:close()
end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
for li, ln in ipairs(LAYERS) do
  local L = li == 1 and spr.layers[1] or spr:newLayer()
  L.name = ln
  for f = 1, N do spr:newCel(L, spr.frames[f], imgs[ln][f], Point(0, 0)) end
end
for _, t in ipairs({ { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } }) do local tg = spr:newTag(t.from, t.to) tg.name = t.name end
spr:saveAs(out .. "gnome-hybrid.aseprite") spr:close()
print("hybrid ok")
