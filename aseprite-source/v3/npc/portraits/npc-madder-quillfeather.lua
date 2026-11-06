-- npc-madder-quillfeather portrait (npc2 P1_20) species: harvest mouse (scribe)
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
local FUR = { hi = "#f2b878", base = "#d9844a", shade = "#a2553e", deep = "#663445" }
local CRM = { hi = "#fff2dc", base = "#f2dab6", shade = "#cfae9e", deep = "#93768a" }
local ROSE = { hi = "#f4a2b2", base = "#d8607e", shade = "#a3405e", deep = "#66294a" }
local PINK = { hi = "#fbc8c0", base = "#ec9a9c", shade = "#bd6a80", deep = "#7c4462" }
local QUILL = { hi = "#bdf0e0", base = "#6cc8b8", shade = "#3f8e9c", deep = "#2c5872" }
local NAME = "npc-madder-quillfeather"
local TEAL = { hi = "#bdeee2", base = "#8fd8c8", shade = "#5fb0aa", deep = "#3d7e88" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local body = c:ellipse(39.5, 106, 34, 32):clip(c:rect(0, 72, 79, 99))
c:part(body, ROSE, { band = 3, pop = { x = 14, y = 86 } })
c:part(c:rrect(29, 78, 50, 99, 4), CRM, { nopop = true, band = 2 })
c:part(c:line({ { 31, 79 }, { 29, 73 } }, 3), CRM, { nopop = true, band = 1 })
c:part(c:line({ { 48, 79 }, { 50, 73 } }, 3), CRM, { nopop = true, band = 1 })
c:stitch{ { 33, 90 }, { 46, 90 } }
c:part(c:ellipse(39.5, 85, 1.5, 1.5), "gold", { band = 1, nopop = true })
c:fillMask(c:line({ { 27, 80 }, { 25, 99 } }, 1), ROSE.shade) c:fillMask(c:line({ { 52, 80 }, { 54, 99 } }, 1), ROSE.deep)
for _, s in ipairs{ -1, 1 } do
  c:part(c:ellipse(39.5 + s * 19, 29, 10, 10), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(39.5 + s * 19, 30, 6, 6), PINK, { band = 2, nopop = true })
end
local hd = c:ellipse(39.5, 50, 20, 17)
hd:add(HP.ellipse(20, 56, 2, 2)) hd:add(HP.ellipse(59, 56, 2, 2)) hd:add(HP.ellipse(21, 60, 1.5, 1.5)) hd:add(HP.ellipse(58, 60, 1.5, 1.5))
hd:add(c:poly{ { 34, 35 }, { 37, 28 }, { 39, 33 }, { 43, 29 }, { 45, 35 } })
c:part(hd, FUR, { band = 3, pop = { x = 27, y = 40 } })
pts(c, { { 26, 39 }, { 27, 39 }, { 25, 40 }, { 38, 30 }, { 37, 31 } }, FUR.hi)
for _, s in ipairs{ { 30, 37, 31, 35 }, { 46, 37, 47, 35 }, { 24, 46, 25, 44 }, { 53, 45, 54, 43 } } do
  c:fillMask(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1), FUR.shade)
end
c:part(c:ellipse(39.5, 58, 11, 7.5), CRM, { band = 2, nopop = true })
c:part(c:ellipse(39.5, 53, 4, 3), PINK, { band = 1, nopop = true })
pts(c, { { 37, 51 }, { 38, 51 } }, PINK.hi)
pts(c, { { 39, 56 }, { 40, 56 }, { 39, 57 }, { 40, 57 }, { 38, 58 }, { 41, 58 }, { 37, 59 }, { 42, 59 }, { 36, 58 }, { 43, 58 } }, FUR.deep)
for _, l in ipairs{ { { 22, 57 }, { 29, 58 } }, { { 22, 61 }, { 29, 60 } }, { { 50, 58 }, { 57, 57 } }, { { 50, 60 }, { 57, 61 } } } do
  c:fillMask(c:line(l, 1), FUR.deep)
end
c:eyeLocked(30, 44) c:eyeLocked(45, 44)
c:fillMask(c:rect(24, 52, 26, 53), PINK.base) c:fillMask(c:rect(53, 52, 55, 53), PINK.base)
pts(c, { { 24, 52 }, { 53, 52 } }, PINK.hi)
pts(c, { { 47, 63 }, { 48, 63 }, { 48, 64 } }, QUILL.shade)
-- quill held up in the right paw
local vane = c:poly{ { 60, 80 }, { 63, 62 }, { 68, 46 }, { 72, 38 }, { 74, 42 }, { 71, 58 }, { 65, 80 } }
c:part(vane, QUILL, { band = 2, pop = { x = 66, y = 52 } })
c:fillMask(c:line({ { 62, 80 }, { 66, 62 }, { 72, 41 } }, 1):clip(vane), CRM.hi)
for _, y in ipairs{ 50, 58, 66, 73 } do c:put(70 - (y - 50) // 5, y, QUILL.deep) end
c:fillMask(c:line({ { 59, 96 }, { 62, 81 } }, 1), CRM.shade)
c:part(c:ellipse(61, 83, 4.5, 4), FUR, { band = 1, pop = { x = 59, y = 81 } })
c:part(c:ellipse(61, 91, 5, 4), ROSE, { band = 1, nopop = true })
c:finish{ outline = true }
backdrop(c, TEAL)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
