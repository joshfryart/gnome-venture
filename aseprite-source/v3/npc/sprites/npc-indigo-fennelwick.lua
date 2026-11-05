-- npc-indigo-fennelwick sprite (npc2 P1_15) species: hedgehog
-- Indigo Fennelwick: cosy hedgehog herbalist. Chestnut spines with cream tips, indigo smock + tilted tam with a stalk,
-- mustard scarf; prop: a fennel sprig with a yellow umbel. 64x96 cell, feet y=90, idle x4 (breath, umbel settle, blink).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(v) return math.floor(v + 0.5) end
local NAME = "npc-indigo-fennelwick"
local SP = { hi = "#b07a4f", base = "#8a5636", shade = "#5e3a48", deep = "#3e2735" }
local TIP = "#ecd4a4"
local FC = { hi = "#f8ecd4", base = "#ead2b0", shade = "#c9a6a0", deep = "#8f6f86" }
local SM = { hi = "#8582d8", base = "#5553a8", shade = "#3b357a", deep = "#2a2556" }
local SCF = { hi = "#f5d36a", base = "#e0a83a", shade = "#b06a3a", deep = "#74404a" }
local ST = { hi = "#b6d86a", base = "#7fae45", shade = "#4d7a48", deep = "#2f4f45" }
local UM = { hi = "#fbe77a", base = "#e9c63e", shade = "#b88c38", deep = "#7a5a3a" }
local NO, NOG = "#4a2a40", "#9a6a8a"
local function spikes(c, m, cx, cy, rx, ry, a0, a1, n, len, w)
  local tips = {}
  for i = 0, n - 1 do
    local a, wa = math.rad(a0 + (a1 - a0) * i / (n - 1)), math.rad(w)
    local p1 = { R(cx + math.cos(a - wa) * rx * 0.85), R(cy + math.sin(a - wa) * ry * 0.85) }
    local p2 = { R(cx + math.cos(a + wa) * rx * 0.85), R(cy + math.sin(a + wa) * ry * 0.85) }
    local t = { R(cx + math.cos(a) * (rx + len)), R(cy + math.sin(a) * (ry + len)) }
    m:add(c:poly{ p1, t, p2 }) tips[#tips + 1] = { t[1], t[2], a }
  end
  return tips
end
local function tipsPaint(c, m, tips)
  for _, t in ipairs(tips) do
    local dx, dy = math.cos(t[3]), math.sin(t[3])
    for k = 2, 4 do local x, y = R(t[1] - dx * k), R(t[2] - dy * k) if m:has(x, y) then c:px(x, y, SP.deep) end end
    for k = 0, 1 do local x, y = R(t[1] - dx * k), R(t[2] - dy * k) if m:has(x, y) then c:px(x, y, TIP) end end
  end
end
local function eye(c, x, y)
  c:px(x + 1, y, INK) c:px(x + 2, y, INK)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:px(x + q[1], y + q[2], P.cream) end
  c:px(x + 1, y + 1, P.cream) c:px(x + 2, y + 1, INK) c:px(x + 1, y + 2, INK) c:px(x + 2, y + 2, INK)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, dr, st, hs = p.b or 0, p.tw or 0, p.dr or 0, p.st or 0, p.hs or 0
  c:groundShadow(32, 89.5, 13, 3)
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 88, 3.5, 2), SP, { band = 1, nopop = true }) end
  -- back spines peeking out around the body
  local back = c:ellipse(32, 71 + b, 13, 8)
  local bt = spikes(c, back, 32, 71 + b, 13, 8, 150, 215, 3, 4, 9)
  local bt2 = spikes(c, back, 32, 71 + b, 13, 8, -35, 30, 3, 4, 9)
  c:part(back, SP, { band = 2, nopop = true })
  tipsPaint(c, back, bt) tipsPaint(c, back, bt2)
  -- smock
  local body = c:ellipse(32, 76 + b, 12.5, 10.5)
  c:part(body, SM, { band = 2, pop = { x = 24, y = 72 + b } })
  for y = 74, 86 do if body:has(32, y + b) then c:px(32, y + b, SM.shade) end end
  for _, y in ipairs{ 76, 80 } do c:px(33, y + b, SCF.base) end
  -- scarf + tail
  c:part(c:rrect(21, 63 + b, 43, 68 + b, 2), SCF, { band = 1, pop = { x = 23, y = 64 + b } })
  local tail = c:poly{ { 24, 66 + b }, { 29, 66 + b }, { 28 + st, 76 + b }, { 23 + st, 75 + b } }
  c:part(tail, SCF, { band = 1, nopop = true })
  for i = 0, 4, 2 do c:px(23 + i + st, 75 + b, SCF.shade) end
  -- head: spine mass, ears, face, snout
  local hx, hy = 32, 46 + b
  local mass = c:ellipse(hx, hy, 17, 14)
  local ht = spikes(c, mass, hx, hy, 17, 14, 165, 375, 12, 5, 8)
  c:part(mass, SP, { band = 2, pop = { x = 22, y = 38 + b } })
  for _, s in ipairs{ {24,41,22,37},{29,38,28,34},{36,38,37,34},{41,41,43,37},{19,47,16,45},{45,47,48,45} } do
    c:line({ { s[1], s[2] + b }, { s[3], s[4] + b } }, 1):clip(mass):each(function(x, y) c:px(x, y, SP.hi) end)
  end
  tipsPaint(c, mass, ht)
  for _, x in ipairs{ 19, 45 } do c:part(c:ellipse(x, 48 + b, 2.5, 2.5), FC, { band = 1, nopop = true }) end
  local face = c:ellipse(32, 53 + b, 11, 7.5)
  c:part(face, FC, { band = 2, pop = { x = 25, y = 50 + b } })
  c:fillMask(c:poly{ { 26, 45 + b }, { 38, 45 + b }, { 32, 49 + b } }:clip(face), SP.base)
  local sn = c:ellipse(32, 58.5 + b, 4, 3)
  c:part(sn, FC, { band = 1, pop = { x = 30, y = 57 + b } })
  c:fillMask(c:rect(31, 60 + b, 33, 61 + b), NO) c:px(31, 60 + b, NOG)
  c:px(28, 60 + b, FC.deep) c:px(36, 60 + b, FC.deep)
  if p.blink then for _, x in ipairs{ 25, 35 } do for i = 0, 3 do c:px(x + i, 51 + b, INK) end end
  else eye(c, 25, 49 + b) eye(c, 35, 49 + b) end
  c:cheek(23, 55 + b) c:cheek(40, 55 + b)
  -- tilted indigo tam with a stalk
  local hat = c:ellipse(29, 30 + b, 10, 3.5) hat:add(c:ellipse(29, 28 + b, 8, 3.5))
  c:part(hat, SM, { band = 2, pop = { x = 23, y = 27 + b } })
  for x = 20, 38, 2 do if hat:has(x, 32 + b) then c:px(x, 32 + b, SCF.base) end end
  c:part(c:line({ { 29, 25 + b }, { 30 + hs, 22 + b } }, 2), SM, { band = 1, nopop = true, inner = false })
  -- fennel sprig held in the right paw
  local stalk = c:line({ { 46, 84 + b }, { 50, 66 + b }, { 53 + tw, 47 + b + dr } }, 2)
  c:part(stalk, ST, { band = 1, nopop = true, inner = false })
  for _, f in ipairs{ { 49, 70, 55, 66 }, { 50, 64, 45, 60 }, { 52, 58, 57, 54 }, { 52, 55, 48, 51 } } do
    c:fillMask(c:line({ { f[1], f[2] + b }, { f[3] + tw, f[4] + b + dr } }, 1), ST.hi)
  end
  local um = c:ellipse(54 + tw, 45 + b + dr, 5, 2.5)
  c:part(um, UM, { band = 1, pop = { x = 51 + tw, y = 44 + b + dr } })
  for _, q in ipairs{ {51,45},{54,44},{57,45},{53,46},{56,46} } do c:px(q[1] + tw, q[2] + b + dr, UM.hi) end
  c:part(c:ellipse(20, 78 + b, 2.5, 2.5), FC, { band = 1, nopop = true })
  c:part(c:ellipse(48, 76 + b, 2.5, 2.5), FC, { band = 1, pop = { x = 47, y = 75 + b } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local IDLE = { { b = 0 }, { b = 1, dr = 1, st = 1, hs = 1 }, { b = 0 }, { blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 4) and 0.18 or 0.32
  strip:drawImage(im, Point((f - 1) * 64, 0))
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(256, 96, ColorMode.RGB) s2.cels[1].image = strip s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " ok")
