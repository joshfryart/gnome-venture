-- npc-maple-leafwhisker sprite (npc2 P1_20) species: house sparrow
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function saveStrip(frames, NAME)
  local W, H, N = 64, 96, #frames
  local pc = app.pixelColor
  local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
  local imgs = {}
  for f, c in ipairs(frames) do
    local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
    for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
    imgs[f] = im
  end
  local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
  for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
  local s1 = Sprite(W * N, H, ColorMode.RGB) s1.cels[1].image = strip s1:saveCopyAs(out .. NAME .. ".png") s1:close()
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, N do spr:newEmptyFrame() end
  for f = 1, N do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
  local tg = spr:newTag(1, N) tg.name = "idle"
  spr:saveAs(out .. NAME .. ".aseprite") spr:close()
end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function blink(c, x, y) for i = 0, 3 do c:put(x + i, y + 2, P.ink) end end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function pts(c, list, hex) for _, p in ipairs(list) do c:put(p[1], p[2], hex) end end
local function leafMask(c, cx, cy, s)
  local m = HP.ellipse(cx, cy - 2.2 * s, 1.8 * s, 3.4 * s)
  m:add(HP.ellipse(cx - 3 * s, cy - 0.6 * s, 2.6 * s, 1.8 * s)) m:add(HP.ellipse(cx + 3 * s, cy - 0.6 * s, 2.6 * s, 1.8 * s))
  m:add(HP.ellipse(cx - 1.8 * s, cy + 1.6 * s, 1.5 * s, 1.1 * s)) m:add(HP.ellipse(cx + 1.8 * s, cy + 1.6 * s, 1.5 * s, 1.1 * s))
  m:add(HP.ellipse(cx, cy, 2 * s, 2 * s))
  m:add(c:line({ { cx, cy - 3.5 * s }, { cx, cy - 6 * s } }, 1))
  m:add(c:line({ { cx - 3 * s, cy - 1 * s }, { cx - 5.8 * s, cy - 2.4 * s } }, 1))
  m:add(c:line({ { cx + 3 * s, cy - 1 * s }, { cx + 5.8 * s, cy - 2.4 * s } }, 1))
  return m
end
local BR = { hi = "#c99462", base = "#9a6440", shade = "#6b4036", deep = "#43283a" }
local CRM = { hi = "#fbebcd", base = "#e8cfa3", shade = "#c09d86", deep = "#86697a" }
local BEAK = { hi = "#f8c060", base = "#e88c30", shade = "#b05a32", deep = "#6e343a" }
local BAND = { hi = "#86bce0", base = "#4a7cb8", shade = "#34508a", deep = "#272f5c" }
local LEAF = { hi = "#f88a5a", base = "#d8402e", shade = "#9e2838", deep = "#5e1f3a" }
local LAV = { hi = "#d8c8f0", base = "#b8a0e0", shade = "#8c72c0", deep = "#5e4a90" }
local NAME = "npc-maple-leafwhisker"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, tt, kn, lf = p.b or 0, p.tail or 0, p.kn or 0, p.lf or 0
  c:groundShadow(32, 88.5, 12, 3)
  local tail = c:poly{ { 38, 72 + b }, { 50 + tt, 61 + b - tt }, { 54 + tt, 65 + b - tt }, { 44, 80 + b } }
  c:part(tail, BR, { band = 2, nopop = true })
  c:fillMask(c:line({ { 42, 75 + b }, { 51 + tt, 64 + b - tt } }, 1), BR.deep)
  for _, x in ipairs{ 28, 36 } do
    c:part(c:rect(x - 1, 82, x, 88), BEAK, { band = 1, nopop = true })
    c:fillMask(c:rect(x - 3, 89, x + 2, 89), BEAK.base) c:put(x - 1, 89, BEAK.shade) c:put(x + 1, 89, BEAK.shade)
  end
  local body = c:ellipse(32, 74 + b, 14, 12)
  c:part(body, BR, { band = 2, pop = { x = 23, y = 67 + b } })
  c:part(c:ellipse(32, 75 + b, 8.5, 9):clip(body), CRM, { band = 2, nopop = true })
  for _, q in ipairs{ { 29, 71 }, { 34, 73 }, { 31, 77 }, { 36, 78 }, { 28, 80 }, { 33, 81 } } do
    c:put(q[1], q[2] + b, CRM.shade) c:put(q[1], q[2] + 1 + b, CRM.shade)
  end
  for _, s in ipairs{ -1, 1 } do
    local w = c:ellipse(32 + s * 13, 74 + b, 4.5, 8.5)
    c:part(w, BR, { band = 2, nopop = true })
    w:each(function(x, y) if y == 72 + b or y == 75 + b then c:put(x, y, CRM.base) end end)
    w:each(function(x, y) if y >= 80 + b then c:put(x, y, BR.shade) end end)
  end
  local hd = c:ellipse(32, 50 + b, 13, 12)
  hd:add(c:poly{ { 30, 39 + b }, { 32, 35 + b }, { 33, 38 + b }, { 35, 36 + b }, { 35, 40 + b } })
  c:part(hd, BR, { band = 2, pop = { x = 25, y = 43 + b } })
  c:part(c:ellipse(32, 54 + b, 9, 6.5), CRM, { band = 1, nopop = true })
  pts(c, { { 24, 55 + b }, { 25, 55 + b }, { 39, 55 + b }, { 40, 55 + b } }, BR.shade)
  -- maple leaf tucked in the band (quirk)
  local lm = leafMask(c, 20 + lf, 34 + b, 1)
  c:fillMask(c:line({ { 21 + lf, 37 + b }, { 23, 42 + b } }, 1), LEAF.shade)
  c:part(lm, LEAF, { band = 1, pop = { x = 18 + lf, y = 32 + b } })
  c:put(20 + lf, 34 + b, LEAF.shade) c:put(20 + lf, 33 + b, LEAF.shade)
  local band = hd:copy():clip(c:ellipse(32, 56 + b, 20, 17):cut(c:ellipse(32, 56 + b, 20, 14.5)))
  c:part(band, BAND, { band = 1, nopop = true })
  local knot = c:ellipse(45, 46 + b, 2, 2)
  knot:add(c:line({ { 46, 47 + b }, { 48 + kn, 52 + b } }, 2))
  c:part(knot, BAND, { band = 1, nopop = true })
  c:part(c:poly{ { 29, 51 + b }, { 36, 51 + b }, { 33, 56 + b }, { 32, 56 + b } }, BEAK, { band = 1, nopop = true })
  c:put(30, 51 + b, BEAK.hi) pts(c, { { 31, 53 + b }, { 32, 53 + b }, { 33, 53 + b }, { 34, 53 + b } }, BEAK.deep)
  if p.blink then blink(c, 24, 46 + b) blink(c, 37, 46 + b) else eye(c, 24, 46 + b) eye(c, 37, 46 + b) end
  pts(c, { { 23, 43 + b }, { 24, 43 + b }, { 25, 44 + b }, { 26, 44 + b }, { 27, 45 + b } }, P.ink)
  pts(c, { { 37, 45 + b }, { 38, 44 + b }, { 39, 44 + b }, { 40, 43 + b }, { 41, 43 + b } }, P.ink)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = {}
for _, p in ipairs{ { b = 0 }, { b = 1, kn = 1, lf = 1 }, { b = 0 }, { blink = true, tail = 1 } } do F[#F + 1] = frame(p) end
saveStrip(F, NAME)
