-- npc-madder-quillfeather sprite (npc2 P1_20) species: harvest mouse (scribe)
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, tt, qt, ea = p.b or 0, p.tail or 0, p.qt or 0, p.ear or 0
  c:groundShadow(32, 88.5, 13, 3)
  c:part(c:line({ { 38, 82 + b }, { 48, 85 }, { 54, 80 }, { 54 + tt, 73 }, { 51 + tt, 70 - tt } }, 2), PINK, { band = 1, nopop = true })
  local body = c:ellipse(32, 77 + b, 11, 11):clip(c:rect(0, 0, 63, 87 + b))
  c:part(body, ROSE, { band = 2, pop = { x = 25, y = 70 + b } })
  local ap = c:rrect(27, 72 + b, 37, 87 + b, 2)
  c:part(ap, CRM, { band = 1, nopop = true })
  pts(c, { { 28, 71 + b }, { 36, 71 + b } }, CRM.shade)
  c:put(32, 78 + b, QUILL.shade) c:put(31, 78 + b, QUILL.base)
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 88.5, 3, 1.5), PINK, { band = 1, nopop = true }) end
  c:part(c:ellipse(21, 75 + b, 3, 4.5), ROSE, { band = 1, nopop = true })
  c:part(c:ellipse(43, 75 + b, 3, 4.5), ROSE, { band = 1, nopop = true })
  c:part(c:ellipse(21, 80 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- quill (prop) in the right paw
  local vane = c:poly{ { 44, 75 + b }, { 46, 66 + b }, { 50 + qt, 57 + b }, { 53 + qt, 55 + b }, { 53 + qt, 60 + b }, { 49, 69 + b }, { 46, 76 + b } }
  c:part(vane, QUILL, { band = 1, pop = { x = 47, y = 64 + b } })
  c:fillMask(c:line({ { 45, 76 + b }, { 48, 66 + b }, { 52 + qt, 57 + b } }, 1):clip(vane), CRM.hi)
  c:fillMask(c:line({ { 42, 82 + b }, { 44, 76 + b } }, 1), CRM.shade)
  c:put(42, 83 + b, P.ink)
  c:part(c:ellipse(43, 79 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- ears
  for _, s in ipairs{ -1, 1 } do
    local ex = 32 + s * (13 + ea)
    c:part(c:ellipse(ex, 38 + b, 7, 6.5), FUR, { band = 2, nopop = true })
    c:part(c:ellipse(ex, 39 + b, 4, 4), PINK, { band = 1, nopop = true })
  end
  local hd = c:ellipse(32, 51 + b, 14, 12)
  hd:add(c:poly{ { 29, 41 + b }, { 31, 36 + b }, { 33, 40 + b }, { 36, 37 + b }, { 36, 42 + b } })
  c:part(hd, FUR, { band = 2, pop = { x = 24, y = 44 + b } })
  pts(c, { { 26, 42 + b }, { 27, 42 + b }, { 25, 43 + b } }, FUR.hi)
  c:part(c:ellipse(32, 57 + b, 7, 4.5), CRM, { band = 1, nopop = true })
  c:part(c:ellipse(32, 53.5 + b, 2, 1.5), PINK, { band = 1, nopop = true })
  c:put(31, 53 + b, PINK.hi)
  pts(c, { { 30, 57 + b }, { 31, 58 + b }, { 32, 57 + b }, { 33, 58 + b }, { 34, 57 + b } }, FUR.deep)
  for _, l in ipairs{ { { 20, 55 }, { 24, 56 } }, { { 20, 58 }, { 24, 57 } }, { { 40, 56 }, { 44, 55 } }, { { 40, 57 }, { 44, 58 } } } do
    c:fillMask(c:line({ { l[1][1], l[1][2] + b }, { l[2][1], l[2][2] + b } }, 1), FUR.deep)
  end
  pts(c, { { 36, 59 + b }, { 37, 59 + b } }, QUILL.shade) -- ink smudge
  if p.blink then blink(c, 25, 47 + b) blink(c, 36, 47 + b) else eye(c, 25, 47 + b) eye(c, 36, 47 + b) end
  c:cheek(22, 52 + b) c:cheek(41, 52 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = {}
for _, p in ipairs{ { b = 0 }, { b = 1, ear = 1, qt = -1 }, { b = 0 }, { blink = true, tail = 1, qt = 1 } } do F[#F + 1] = frame(p) end
saveStrip(F, NAME)
