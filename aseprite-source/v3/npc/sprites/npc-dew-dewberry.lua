-- npc-dew-dewberry sprite (npc2 P1_8) species: ladybug
-- Dew Dewberry: cheerful ladybug in a wide straw cone hat, antennae with dew beads; prop: a leaf cup holding a big dewdrop.
-- 64x96 cell, feet y=90, idle(4): base / breath(1px down, hat tip + drop settle) / base / antenna twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
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
local HEAD = { hi = "#6c5c8e", base = "#4b3e6a", shade = "#35294e", deep = "#291d3c" }
local NOSE = { hi = "#a08cbc", base = "#7c6a9c", shade = "#58497c", deep = "#3c3060" }
local SHELL = { hi = "#ff7c5e", base = "#e03a3c", shade = "#a22648", deep = "#681a42" }
local SPOT = "#3a2a4a"
local CRM = { hi = "#fbefd6", base = "#f0dcb4", shade = "#c7aa9a", deep = "#8c7486" }
local STRAW = { hi = "#ffe08c", base = "#e9b44e", shade = "#b47c40", deep = "#7c503c" }
local DEW = { hi = "#eef8f0", base = "#a2dcea", shade = "#5ca2cc", deep = "#3c6c9c" }
local LEAF = { hi = "#aad85c", base = "#62aa3e", shade = "#3c7248", deep = "#26484c" }
local NAME = "npc-dew-dewberry"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob
  c:groundShadow(32, 89.5, 13, 3)
  for _, x in ipairs({ 27, 37 }) do
    local m = c:ellipse(x, 88, 3, 1.8) form(c, m, HEAD, { off = 1, frac = 0.35, pop = { { x - 2, 87 } } }) under(c, m, HEAD.deep)
  end
  -- dome shell parted at the front over a dark belly plate
  local shell = c:ellipse(32, 73 + b, 15, 13)
  form(c, shell, SHELL, { frac = 0.3, off = 2, pop = { { 21, 64 + b }, { 22, 63 + b }, { 20, 65 + b } } })
  under(c, shell, SHELL.deep)
  local plate = c:poly{ { 29, 61 + b }, { 35, 61 + b }, { 38, 86 + b }, { 26, 86 + b } }:clip(shell)
  form(c, plate, HEAD, { frac = 0.35, off = 1 })
  for _, s in ipairs({ { 20, 70, 2 }, { 23, 80, 2 }, { 43, 68, 2 }, { 42, 79, 1.5 } }) do
    onlyOver(c, c:ellipse(s[1], s[2] + b, s[3], s[3]), { [SHELL.base] = true, [SHELL.shade] = true, [SHELL.hi] = true }, SPOT)
  end
  form(c, c:ellipse(17, 74 + b, 2, 2.5), HEAD, { off = 1, frac = 0.3 })
  -- right hand holds a leaf cup with a dewdrop
  form(c, c:ellipse(43, 77 + b, 2, 2), HEAD, { off = 1, frac = 0.5 })
  local leaf = c:ellipse(47, 78 + b, 5.5, 2.5)
  form(c, leaf, LEAF, { off = 1, frac = 0.35, inner = false, pop = { { 43, 77 + b } } })
  under(c, leaf, LEAF.deep)
  local dy = b + (p.dd or 0)
  local dew = c:ellipse(47, 74 + dy, 3.5, 3)
  dew:add(c:poly{ { 45, 73 + dy }, { 49, 73 + dy }, { 47, 68 + dy } })
  form(c, dew, DEW, { off = 1, frac = 0.35, inner = false })
  c:put(45, 72 + dy, DEW.hi) c:put(46, 71 + dy, DEW.hi) c:put(48, 76 + dy, DEW.hi)
  -- head
  local head = c:ellipse(32, 47 + b, 14, 12)
  form(c, head, HEAD, { frac = 0.3, off = 2 })
  for _, x in ipairs({ 22, 42 }) do
    local m = c:ellipse(x, 52 + b, 3.5, 2.5) form(c, m, CRM, { off = 1, frac = 0.4, inner = false })
  end
  eye4(c, 24, 45 + b, p.blink) eye4(c, 37, 45 + b, p.blink)
  local sn = c:ellipse(32.5, 51 + b, 2.5, 2)
  form(c, sn, NOSE, { off = 1, frac = 0.35, inner = false, pop = { { 31, 50 + b } } })
  for _, q in ipairs({ { 30, 54 }, { 31, 55 }, { 32, 55 }, { 33, 55 }, { 34, 55 }, { 35, 54 } }) do c:put(q[1], q[2] + b, CRM.base) end
  -- dew-bead antenna tips (stalks drawn after the outline)
  local ta = p.ta or 0
  form(c, c:ellipse(18, 24 + b, 1.5, 1.5), DEW, { off = 1, frac = 0.4, inner = false }) c:put(17, 23 + b, DEW.hi)
  form(c, c:ellipse(47, 23 + b + ta, 1.5, 1.5), DEW, { off = 1, frac = 0.4, inner = false }) c:put(46, 22 + b + ta, DEW.hi)
  -- straw cone hat: wide brim, squat cone leaning right, green band
  local ht = p.ht or 0
  local brim = c:ellipse(32, 36 + b, 18, 4.5)
  form(c, brim, STRAW, { frac = 0.3, off = 1, pop = { { 17, 35 + b }, { 18, 34 + b } } })
  under(c, brim, STRAW.deep)
  local cone = c:poly{ { 21, 35 + b }, { 43, 35 + b }, { 34 + ht, 16 + b } }
  form(c, cone, STRAW, { frac = 0.35, off = 2, pop = { { 29, 23 + b }, { 28, 25 + b }, { 30, 21 + b } } })
  cone:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.shade) end end)
  local band = c:rect(0, 31 + b, 63, 32 + b):clip(cone)
  c:fillMask(band, LEAF.base) band:each(function(x, y) if x > 37 or y == 32 + b then c:put(x, y, LEAF.shade) end end)
  for x = 15, 49 do local y = R2(36 + b + 4.5 * math.sqrt(math.max(0, 1 - ((x - 32) / 18) ^ 2)) - 1)
    if brim:has(x, y) and (x % 3 ~= 0) then c:put(x, y, STRAW.shade) end end
  c:finish{ outline = true }
  c:fillMask(c:line({ { 24, 33 + b }, { 21, 28 + b }, { 19, 26 + b } }, 1), P.ink)
  c:fillMask(c:line({ { 40, 33 + b }, { 44, 28 + b }, { 46, 25 + b + ta } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs({ { bob = 0 }, { bob = 1, ht = 1, dd = 0 }, { bob = 0 }, { bob = 0, ta = -1 } }) do frames[#frames + 1] = frame(p) end
saveAnim(frames, 64, 96, NAME)
