-- npc-cricket-hollowell sprite (npc2 P1_8) species: hedgehog
-- Cricket Hollowell: shy round hedgehog, quill crown, button snout; quirk/prop: a red apple skewered on her back quills.
-- 64x96 cell, feet y=90, idle(4): base / breath(1px down, apple+leaf settle) / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or (DIR .. "/")
local function R2(v) return math.floor(v + 0.5) end
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
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function spikes(c, cx, cy, rx, ry, a0, a1, step, len, w)
  local m = HP.mask()
  for a = a0, a1, step do
    local r, r1, r2 = math.rad(a), math.rad(a - w), math.rad(a + w)
    m:add(c:poly{ { R2(cx + math.cos(r1) * rx), R2(cy + math.sin(r1) * ry) }, { R2(cx + math.cos(r) * (rx + len)), R2(cy + math.sin(r) * (ry + len)) }, { R2(cx + math.cos(r2) * rx), R2(cy + math.sin(r2) * ry) } })
  end
  return m
end
local function quills(c, m, R, cx, cy, rx, ry, a0, a1, step, len)
  for a = a0, a1, step do
    local r = math.rad(a)
    local lm = c:line({ { R2(cx + math.cos(r) * (rx - 3)), R2(cy + math.sin(r) * (ry - 3)) }, { R2(cx + math.cos(r) * (rx + len - 2)), R2(cy + math.sin(r) * (ry + len - 2)) } }, 1)
    local aa = a % 360
    local lit = aa >= 185 and aa <= 265
    lm:each(function(x, y) if m:has(x, y) then c:put(x, y, lit and R.hi or R.shade) end end)
    local q = math.rad(a + step / 2)
    local lm2 = c:line({ { R2(cx + math.cos(q) * (rx - 4)), R2(cy + math.sin(q) * (ry - 4)) }, { R2(cx + math.cos(q) * (rx - 1)), R2(cy + math.sin(q) * (ry - 1)) } }, 1)
    lm2:each(function(x, y) if m:has(x, y) then c:put(x, y, R.deep) end end)
  end
end
local function onlyOver(c, m, hexset, hex) m:each(function(x, y) if hexset[c:get(x, y) or ""] then c:put(x, y, hex) end end) end
local function saveAnim(frames, W, H, name)
  local pc = app.pixelColor
  local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
  local imgs = {}
  for f, c in ipairs(frames) do
    local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
    for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
    imgs[f] = im
  end
  local strip = Image(W * #frames, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, #frames do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
  local s = Sprite(W * #frames, H, ColorMode.RGB) s.cels[1].image = strip
  s:saveCopyAs(out .. name .. ".png") s:close()
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, #frames do spr:newEmptyFrame() end
  for f = 1, #frames do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
  local tg = spr:newTag(1, #frames) tg.name = "idle"
  spr:saveAs(out .. name .. ".aseprite") spr:close()
  print(name .. ": " .. #frames .. " frames")
end
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local SPN = { hi = "#b0804e", base = "#80573a", shade = "#5a3c4c", deep = "#3c2840" }
local FACE = { hi = "#f8e6c4", base = "#e6c294", shade = "#b98c7c", deep = "#80606c" }
local PAW = { hi = "#eeac90", base = "#cc8070", shade = "#925668", deep = "#603852" }
local APL = { hi = "#ff9070", base = "#da443c", shade = "#9c2c48", deep = "#621c3e" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local NAME = "npc-cricket-hollowell"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob
  c:groundShadow(32, 89.5, 13, 3)
  for _, x in ipairs({ 26, 38 }) do
    local m = c:ellipse(x, 88, 3.5, 2) form(c, m, PAW, { off = 1, frac = 0.35, pop = { { x - 2, 87 } } }) under(c, m, PAW.deep)
  end
  -- body: quilled back showing at the sides, cream belly
  local body = c:ellipse(32, 74 + b, 14, 11)
  body:add(spikes(c, 32, 74 + b, 13, 10, 150, 215, 20, 4, 9)) body:add(spikes(c, 32, 74 + b, 13, 10, -35, 30, 20, 4, 9))
  form(c, body, SPN, { frac = 0.3, off = 2 })
  HH.texture(c, body, 32, 72 + b, 14, 11, SPN)
  local belly = c:ellipse(32, 77 + b, 9, 9):clip(c:ellipse(32, 74 + b, 14, 11))
  form(c, belly, FACE, { frac = 0.3, off = 2, pop = { { 26, 72 + b }, { 27, 71 + b } } })
  for _, x in ipairs({ 19, 45 }) do form(c, c:ellipse(x, 74 + b, 2.5, 2.5), PAW, { off = 1, frac = x > 30 and 0.5 or 0.3 }) end
  HH.head(c, { cx = 32, cy = 47 + b, s = 1, SP = SPN, FACE = FACE, blink = p.blink })
  -- apple skewered on the quills (upper right)
  local ay = 35 + b + (p.ad or 0)
  local ap = c:ellipse(45, ay, 4, 3.5)
  form(c, ap, APL, { off = 1, frac = 0.35, pop = { { 43, ay - 2 }, { 42, ay - 1 } } })
  under(c, ap, APL.deep)
  c:put(45, ay - 3, APL.deep)
  c:fillMask(c:line({ { 45, ay - 4 }, { 46, ay - 6 } }, 1), SPN.deep)
  local lf = c:poly{ { 47, ay - 5 }, { 50, ay - 7 + (p.lf or 0) }, { 51, ay - 5 + (p.lf or 0) }, { 48, ay - 4 } }
  form(c, lf, LEAF, { off = 1, frac = 0.4, inner = false })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs({ { bob = 0 }, { bob = 1, ad = 0, lf = 1 }, { bob = 0 }, { bob = 0, blink = true } }) do frames[#frames + 1] = frame(p) end
saveAnim(frames, 64, 96, NAME)
