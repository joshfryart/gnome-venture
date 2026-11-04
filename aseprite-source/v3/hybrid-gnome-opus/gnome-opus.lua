-- gnome-opus: new player gnome on the recolourable rig contract (10 disjoint layers, marker greys).
-- 64x80 cell, 3/4 top-down, feet baseline y=70, centre x=32. idle(2) + walk(4).
-- Design: crooked kinked hat leaning back-right with a pom-pom and a stitched patch, wavy brim;
-- forked braided beard with trim beads; barrel tunic with belt + buckle; scarf tail over the LEFT shoulder;
-- round clogs; cream-disc eyes (read on any skin). Draws straight into tracked layers (no anchors needed).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local LAYERS = { "shadow", "outline", "boots", "tunic", "scarf", "skin", "beard", "face", "hat", "trim" }
local MARK = { hi = "#f0f0f0", base = "#b4b4b4", shade = "#787878", deep = "#3c3c3c" }
local function cp(r, deep) return { hi = r.hi, base = r.base, shade = r.shade, deep = deep or r.deep } end
-- as-drawn ramps == rig.json "default" presets, so --verify and every preset/hex work unchanged
local RAMP = {
  hat = cp(P.ember), tunic = cp(P.sea), scarf = cp(P.gold, P.wood.deep), skin = cp(P.skinA, P.wood.deep),
  beard = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade },
  boots = cp(P.wood), trim = cp(P.gold, P.wood.deep),
}

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
local function under(c, m, hex, x0, x1)
  m:each(function(x, y) if not m:has(x, y + 1) and (not x0 or (x >= x0 and x <= x1)) then c:put(x, y, hex) end end)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 80, name = "gnome-opus" }
  c.lay = {}
  local put = getmetatable(c).put
  c.put = function(self, x, y, hex, owner)
    if x >= 0 and y >= 0 and x < self.w and y < self.h then self.lay[y * self.w + x] = CUR end
    return put(self, x, y, hex, owner)
  end
  local b, sx = -p.bob, p.sx or 0
  local function X(x) return x + sx end
  local R = RAMP

  L("shadow") c:groundShadow(32, 68.5, 14, 3.5)

  -- round clogs: stubby, front cap seen from above, sole deep
  L("boots")
  local function clog(x, dy)
    local m = c:ellipse(x, 67.5 + dy, 4, 2.5)
    form(c, m, R.boots, { frac = 0.35, off = 1, pop = { { math.floor(x) - 2, 66 + dy } } })
    under(c, m, R.boots.deep)
  end
  clog(27, p.ly or 0) clog(37.5, p.ry or 0)

  -- barrel tunic: round belly, centre-front hem split, belt
  L("tunic")
  local hs = p.hem or 0
  local tun = c:ellipse(X(32.5), 55 + b, 12, 9)
  tun:add(c:poly{ { X(22), 58 + b }, { X(43), 58 + b }, { X(44) + hs, 64 + b }, { X(21) + hs, 64 + b } })
  tun:cut(c:poly{ { X(32), 62 + b }, { X(33), 62 + b }, { X(34) + hs, 65 + b }, { X(31) + hs, 65 + b } })
  form(c, tun, R.tunic, { frac = 0.32, off = 2 })
  under(c, tun, R.tunic.deep)
  for x = 21, 44 do if tun:has(X(x), 57 + b) then c:put(X(x), 57 + b, R.tunic.deep) end end
  for x = 22, 43 do if tun:has(X(x), 58 + b) and x > 36 then c:put(X(x), 58 + b, R.tunic.deep) end end
  -- stubby sleeves, swing opposite
  local la, ra = (p.arm or 0) * 2, -(p.arm or 0) * 2
  local function sleeve(cx, dy, dir)
    local m = c:ellipse(X(cx), 52 + b + dy, 3, 4.5)
    form(c, m, R.tunic, { frac = dir < 0 and 0.3 or 0.6, off = 1 })
    under(c, m, R.tunic.deep)
    return m
  end
  sleeve(20, la, -1) sleeve(45, ra, 1)
  L("skin")
  form(c, c:ellipse(X(20), 57 + b + la, 2.5, 2), R.skin, { off = 1, frac = 0.3 })
  form(c, c:ellipse(X(45), 57 + b + ra, 2.5, 2), R.skin, { off = 1, frac = 0.5 })

  -- scarf: chunky cowl + tail flung back over the LEFT shoulder, notched fringe
  L("scarf")
  local tl = p.tail or 0
  form(c, c:rrect(X(21), 45 + b, X(44), 49 + b, 2), R.scarf, { frac = 0.25, off = 1 })
  local tail = c:poly{ { X(22), 46 + b }, { X(26), 47 + b }, { X(20) + tl, 55 + b }, { X(16) + tl, 54 + b } }
  form(c, tail, R.scarf, { frac = 0.5, off = 1 })
  for i = 0, 4 do if i % 2 == 0 then c:put(X(16 + i) + tl, 55 + b - (i > 2 and 1 or 0), R.scarf.shade) end end
  c:put(X(23), 48 + b, R.scarf.deep) c:put(X(24), 49 + b, R.scarf.deep)

  -- big round head + long swept-back ears
  L("skin")
  form(c, c:ellipse(X(32.5), 39 + b, 10.5, 7), R.skin, { frac = 0.25, off = 1 })
  form(c, c:poly{ { X(23), 37 + b }, { X(16), 34 + b }, { X(19), 39 + b }, { X(23), 42 + b } }, R.skin, { off = 1, frac = 0.2 })
  form(c, c:poly{ { X(42), 37 + b }, { X(49), 34 + b }, { X(46), 39 + b }, { X(42), 42 + b } }, R.skin, { off = 1, frac = 0.6 })

  -- forked beard: wide bib, then two braids with bands, beads at the ends (trim)
  L("beard")
  local bs = p.braid or 0
  local bm = c:poly{ { X(23), 42 + b }, { X(42), 42 + b }, { X(44), 46 + b }, { X(41), 52 + b }, { X(24), 52 + b }, { X(21), 46 + b } }
  bm:add(c:ellipse(X(32.5), 51 + b, 7, 3))
  local brL = c:line({ { X(28), 51 + b }, { X(27), 55 + b }, { X(26) + bs, 59 + b } }, 3)
  local brR = c:line({ { X(37), 51 + b }, { X(38), 55 + b }, { X(39) + bs, 59 + b } }, 3)
  bm:add(brL) bm:add(brR)
  form(c, bm, R.beard, { frac = 0.3, off = 2, pop = { { X(24), 45 + b }, { X(25), 45 + b }, { X(24), 46 + b } } })
  for _, q in ipairs({ { 27, 54 }, { 28, 54 }, { 26, 57 }, { 27, 57 }, { 37, 54 }, { 38, 54 }, { 38, 57 }, { 39, 57 } }) do
    local x = q[1] + (q[2] >= 57 and bs or 0)
    if bm:has(X(x), q[2] + b) then c:put(X(x), q[2] + b, R.beard.shade) end
  end
  c:put(X(32), 52 + b, R.beard.deep) c:put(X(33), 52 + b, R.beard.deep) c:put(X(32), 53 + b, R.beard.deep)
  -- bushy handlebar moustache, tips flick up
  local mu = c:ellipse(X(32.5), 45 + b, 6.5, 1.5)
  mu:add(c:rect(X(25), 43 + b, X(25), 44 + b)) mu:add(c:rect(X(40), 43 + b, X(40), 44 + b))
  form(c, mu, R.beard, { off = 1, frac = 0.3, inner = false, pop = { { X(28), 44 + b }, { X(29), 44 + b } } })
  c:put(X(32), 46 + b, R.beard.shade) c:put(X(33), 46 + b, R.beard.shade)

  -- nose: rounder and lower
  L("skin")
  local nose = c:ellipse(X(32.5), 42.5 + b, 2.5, 2.5)
  form(c, nose, R.skin, { off = 1, frac = 0.35, inner = false })
  under(c, nose, R.skin.shade)
  L("face") c:put(X(31), 41 + b, P.cream)

  -- eyes: ink lid + cream disc + ink pupil + cream glint (contrast on any skin); petal cheeks
  local function eye(x, y)
    c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
    for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
    c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
  end
  local ey = 37 + b + (p.blink and 1 or 0)
  if p.blink then
    for _, x in ipairs({ 25, 36 }) do for i = 0, 3 do c:put(X(x + i), ey + 1, P.ink) end end
  else eye(X(25), ey) eye(X(36), ey) end
  c:cheek(X(23), 42 + b) c:cheek(X(41), 42 + b)

  -- hat: wavy wide brim, cone with two kinks leaning back-right, droopy tip
  L("hat")
  local hb = p.hb or 0
  local hm = c:ellipse(X(32.5), 33 + b, 15.5, 3.5)
  for _, x in ipairs({ 19, 26, 33, 40, 46 }) do hm:add(c:ellipse(X(x), 35 + b, 2, 1.5)) end
  hm:add(c:poly{ { X(21), 33 + b }, { X(44), 33 + b }, { X(40), 25 + b }, { X(25), 25 + b } })
  hm:add(c:poly{ { X(25), 26 + b }, { X(40), 26 + b }, { X(37), 18 + b }, { X(28), 19 + b } })
  hm:add(c:line({ { X(32), 19 + b }, { X(36), 14 + b }, { X(41), 12 + b } }, 5))
  hm:add(c:line({ { X(40), 12 + b }, { X(44) + hb, 12 + b }, { X(47) + hb, 15 + b } }, 3))
  form(c, hm, R.hat, { frac = 0.36, off = 2, pop = { { X(27), 22 + b }, { X(28), 22 + b }, { X(27), 23 + b } } })
  under(c, hm, R.hat.deep)
  -- kink creases (deep), brim top fold line
  for _, q in ipairs({ { 36, 19 }, { 37, 19 }, { 38, 18 }, { 40, 25 }, { 39, 25 }, { 41, 14 }, { 42, 14 } }) do c:put(X(q[1]), q[2] + b, R.hat.deep) end
  for x = 22, 43 do local y = math.floor(31.5 - 1.2 * math.sqrt(math.max(0, 1 - ((x - 32.5) / 11) ^ 2)) + 0.5) + 1
    if (x + y) % 5 ~= 0 then c:put(X(x), y + b, R.hat.shade) end end
  -- patch (quirk): square of shade on the cone's lit side
  for y = 26, 29 do for x = 28, 31 do c:put(X(x), y + b, R.hat.shade) end end
  c:put(X(28), 26 + b, R.hat.deep)

  -- trim: pom-pom, patch cross-stitches, hat band dashes, belt buckle, braid beads
  L("trim")
  local pom = c:ellipse(X(48) + hb, 16.5 + b + (p.pdy or 0), 2.5, 2.5)
  form(c, pom, R.trim, { off = 1, frac = 0.35, pop = { { X(47) + hb, 15 + b + (p.pdy or 0) } } })
  for _, q in ipairs({ { 27, 25 }, { 32, 25 }, { 27, 30 }, { 32, 30 }, { 29, 25 }, { 32, 28 } }) do c:put(X(q[1]), q[2] + b, R.trim.base) end
  local pts = {}
  for x = 19, 46, 3 do pts[#pts + 1] = { X(x), math.floor(33 + 3.5 * math.sqrt(math.max(0, 1 - ((x - 32.5) / 16) ^ 2)) - 1.5 + b + 0.5) } end
  c:stitch(pts)
  local bk = c:rect(X(31), 56 + b, X(34), 58 + b)
  form(c, bk, R.trim, { off = 1, frac = 0.3, noshade = false })
  c:put(X(32), 57 + b, R.tunic.deep == nil and R.trim.deep or R.trim.deep) c:put(X(33), 57 + b, R.trim.deep)
  for _, q in ipairs({ { 26 + bs, 60 }, { 39 + bs, 60 } }) do
    local m = c:rect(X(q[1]) - 1, q[2] + b, X(q[1]) + 1, q[2] + 1 + b)
    form(c, m, R.trim, { off = 1, frac = 0.34, pop = { { X(q[1]) - 1, q[2] + b } } })
  end

  L("outline") c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { { bob = 0 }, { bob = 1, pdy = 1, blink = false } }
local walk = {
  { bob = 0, ly = 2, ry = -2, arm = -1, hb = 1, hem = 1, tail = 0, braid = 1 },
  { bob = 1, ly = 0, ry = -3, arm = 0, sx = -1, hb = 0, pdy = 1, tail = 1, braid = 0 },
  { bob = 0, ly = -2, ry = 2, arm = 1, hb = -1, hem = -1, tail = 0, braid = -1 },
  { bob = 1, ly = -3, ry = 0, arm = 0, sx = 1, hb = 0, pdy = 1, tail = -1, braid = 0 },
}
local frames = {}
for _, p in ipairs(idle) do frames[#frames + 1] = frame(p) end
for _, p in ipairs(walk) do frames[#frames + 1] = frame(p) end
local tags = { { name = "idle", from = 1, to = 2 }, { name = "walk", from = 3, to = 6 } }
local s = HP.sheet{ cellw = 64, cellh = 80, frames = frames, tags = tags }
s:save{ png = out .. "gnome-player.png", scale = 1 }
s:save{ png = out .. "gnome-player_x4.png", scale = 4 }

-- split into layers (marker greys for tint layers), check each colour is in its layer's ramp
local W, H, N = 64, 80, #frames
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local TINT = {}
for role, r in pairs(RAMP) do TINT[role] = { [r.hi:lower()] = "hi", [r.base:lower()] = "base", [r.shade:lower()] = "shade", [r.deep:lower()] = "deep" } end
local imgs, stats = {}, {}
for _, ln in ipairs(LAYERS) do
  imgs[ln] = {} stats[ln] = 0
  for f = 1, N do local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0)) imgs[ln][f] = im end
end
for f, c in ipairs(frames) do
  for i, hex in pairs(c.pix) do
    local ln = c.lay[i] or error("pixel without layer")
    local t, o = TINT[ln], hex
    if t then o = MARK[t[hex] or error(string.format("%s colour %s not in ramp (f%d px%d)", ln, hex, f, i))] end
    imgs[ln][f]:putPixel(i % W, i // W, rgba(o))
    stats[ln] = stats[ln] + 1
  end
end
for _, ln in ipairs(LAYERS) do
  local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, N do strip:drawImage(imgs[ln][f], Point((f - 1) * W, 0)) end
  local spr = Sprite(W * N, H, ColorMode.RGB) spr.cels[1].image = strip
  spr:saveCopyAs(out .. "gnome-" .. ln .. ".png") spr:close()
  print(string.format("%-8s %5d px", ln, stats[ln]))
end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
for li, ln in ipairs(LAYERS) do
  local Ly = li == 1 and spr.layers[1] or spr:newLayer()
  Ly.name = ln
  for f = 1, N do spr:newCel(Ly, spr.frames[f], imgs[ln][f], Point(0, 0)) end
end
for _, t in ipairs(tags) do local tg = spr:newTag(t.from, t.to) tg.name = t.name end
spr:saveAs(out .. "gnome-rig.aseprite") spr:close()
print("gnome-opus: " .. N .. " frames, " .. #LAYERS .. " layers -> " .. out)
