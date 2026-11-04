-- npc-maple-leafwhisker portrait (npc2 P1_20) species: house sparrow
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
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local body = c:ellipse(39.5, 106, 34, 32):clip(c:rect(0, 72, 79, 99))
c:part(body, BR, { band = 3, pop = { x = 14, y = 86 } })
local bib = c:ellipse(39.5, 102, 14, 26):clip(body)
c:part(bib, CRM, { band = 2, nopop = true })
body:each(function(x, y) if not bib:has(x, y) and y % 6 == 0 and (x + y // 6 * 3) % 6 < 4 then c:put(x, y, BR.shade) end end)
for _, q in ipairs{ { 33, 82 }, { 44, 84 }, { 38, 88 }, { 47, 92 }, { 31, 93 }, { 40, 96 } } do pts(c, { q, { q[1], q[2] + 1 } }, CRM.shade) end
local hd = c:ellipse(39.5, 49, 21, 18)
hd:add(c:poly{ { 36, 33 }, { 38, 25 }, { 40, 30 }, { 43, 26 }, { 43, 33 } })
c:part(hd, BR, { band = 3, pop = { x = 27, y = 38 } })
c:part(c:ellipse(39.5, 56, 14.5, 10.5), CRM, { band = 2, nopop = true })
c:fillMask(c:rect(23, 57, 26, 59), BR.shade) c:fillMask(c:rect(53, 57, 56, 59), BR.shade)
-- maple leaf, stem tucked under the headband
local lm = leafMask(c, 18, 27, 1.7)
c:fillMask(c:line({ { 19, 31 }, { 26, 38 } }, 2), LEAF.shade)
c:part(lm, LEAF, { band = 2, pop = { x = 14, y = 23 } })
for _, v in ipairs{ { { 18, 30 }, { 18, 19 } }, { { 18, 29 }, { 10, 24 } }, { { 18, 29 }, { 26, 24 } } } do
  c:fillMask(c:line(v, 1):clip(lm:copy():shrink(1)), LEAF.shade)
end
local band = hd:copy():clip(c:ellipse(39.5, 62, 30, 28):cut(c:ellipse(39.5, 62, 30, 24.5)))
c:part(band, BAND, { band = 1, pop = { x = 30, y = 36 } })
local knot = c:ellipse(60, 42, 3, 2.5)
knot:add(c:line({ { 61, 43 }, { 65, 49 }, { 64, 54 } }, 2)) knot:add(c:line({ { 62, 42 }, { 68, 45 }, { 70, 50 } }, 2))
c:part(knot, BAND, { band = 1, nopop = true })
c:eyeLocked(29, 45) c:eyeLocked(46, 45)
c:fillMask(c:line({ { 26, 41 }, { 34, 44 } }, 2), P.ink) c:fillMask(c:line({ { 45, 44 }, { 53, 41 } }, 2), P.ink)
c:part(c:poly{ { 33, 51 }, { 46, 51 }, { 41, 61 }, { 38, 61 } }, BEAK, { band = 2, nopop = true })
pts(c, { { 35, 52 }, { 36, 52 } }, BEAK.hi)
for x = 37, 42 do c:put(x, 56, BEAK.deep) end pts(c, { { 36, 57 }, { 43, 57 }, { 37, 53 }, { 42, 53 } }, BEAK.deep)
c:finish{ outline = true }
backdrop(c, LAV)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
