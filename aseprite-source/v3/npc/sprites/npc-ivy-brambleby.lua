-- npc-ivy-brambleby sprite (npc2 P1_15) species: grasshopper
-- Ivy Brambleby: sunny grasshopper forager. Lime body, big folded jumping legs with knees above the hips, plum vest,
-- ivy-leaf cap; prop: a wicker basket of blackberries. 64x96 cell, feet y=90, idle x4 (breath, antenna settle, blink+twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(v) return math.floor(v + 0.5) end
local NAME = "npc-ivy-brambleby"
local GR = { hi = "#c7e06e", base = "#8cc04a", shade = "#5a8a4a", deep = "#35574a" }
local PL = { hi = "#f0f2b0", base = "#d6e08a", shade = "#9fb46a", deep = "#5a8a4a" }
local VE = { hi = "#b8689a", base = "#8a3f6e", shade = "#612b5a", deep = "#3f1f45" }
local BK = { hi = "#e8b870", base = "#c48a48", shade = "#8f5a3a", deep = "#5a3838" }
local BE = { hi = "#8a6ab0", base = "#4f3a7a", shade = "#33264f", deep = "#33264f" }
local IV = { hi = "#7fc06a", base = "#3f8a4f", shade = "#2a6048", deep = "#1f3f3a" }
local BG = "#d9c8ee"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ad, at = p.b or 0, p.ad or 0, p.at or 0
  c:groundShadow(32, 89.5, 14, 3)
  for _, x in ipairs{ 28, 36 } do c:part(c:ellipse(x, 88.5, 2.5, 1.5), GR, { band = 1, nopop = true }) end
  -- folded hind legs
  for _, s in ipairs{ -1, 1 } do
    local hipx, kx, fx = 32 + s * 6, 32 + s * 13, 32 + s * 12
    c:part(c:line({ { kx, 64 + b }, { fx, 87 } }, 2), GR, { band = 1, nopop = true, inner = false })
    c:part(c:ellipse(fx + s, 88.5, 2.5, 1.5), GR, { band = 1, nopop = true })
    local fem = c:line({ { hipx, 78 + b }, { kx, 65 + b } }, 5)
    c:part(fem, GR, { band = 2, pop = { x = kx - 1, y = 65 + b } })
    for k = 0, 2 do c:px(R(hipx + (kx - hipx) * (0.3 + k * 0.2)) + s, R(78 + (65 - 78) * (0.3 + k * 0.2)) + b, GR.shade) end
    c:px(kx, 63 + b, GR.deep)
  end
  -- neck joins head to body
  c:part(c:rect(28, 58 + b, 36, 69 + b), GR, { band = 1, nopop = true })
  -- body: plum vest open over pale belly
  local body = c:ellipse(32, 76 + b, 9, 10)
  c:part(body, VE, { band = 2, pop = { x = 26, y = 71 + b } })
  local bel = c:ellipse(32, 77 + b, 3.5, 8.5):clip(body)
  c:part(bel, PL, { band = 1, nopop = true })
  for _, y in ipairs{ 72, 75, 78, 81, 84 } do for x = 30, 34 do if bel:has(x, y + b) then c:px(x, y + b, PL.shade) end end end
  -- basket of blackberries
  c:fillMask(c:line({ { 27, 78 + b }, { 32, 71 + b }, { 37, 78 + b } }, 1), BK.shade)
  for _, q in ipairs{ {29,77},{32,76},{35,77},{31,78},{34,78} } do
    c:part(c:ellipse(q[1], q[2] + b, 1.5, 1.5), BE, { band = 1, nopop = true, inner = false })
  end
  for _, q in ipairs{ {28,76},{31,75},{34,76} } do c:px(q[1], q[2] + b, BE.hi) end
  local bk = c:rrect(26, 79 + b, 38, 85 + b, 2)
  c:part(bk, BK, { band = 2, pop = { x = 27, y = 80 + b } })
  for _, y in ipairs{ 81, 83 } do for x = 27, 37 do if (x + y) % 2 == 0 and bk:has(x, y + b) then c:px(x, y + b, BK.shade) end end end
  c:part(c:ellipse(24, 80 + b, 2, 2.5), GR, { band = 1, nopop = true })
  c:part(c:ellipse(40, 80 + b, 2, 2.5), GR, { band = 1, nopop = true })
  -- antennae (long, swept back)
  c:fillMask(c:line({ { 28, 37 + b }, { 23, 26 + b }, { 19 + at, 14 + b + ad } }, 1), GR.shade)
  c:fillMask(c:line({ { 36, 37 + b }, { 41, 26 + b }, { 45, 14 + b + ad } }, 1), GR.shade)
  -- head: cranium + long muzzle + side eye domes
  local head = c:ellipse(32, 44 + b, 12, 10) head:add(c:ellipse(32, 54 + b, 8, 7))
  c:part(head, GR, { band = 2, pop = { x = 25, y = 38 + b } })
  local mz = c:ellipse(32, 57 + b, 5.5, 4)
  c:part(mz, PL, { band = 1, nopop = true })
  c:px(30, 55 + b, GR.deep) c:px(34, 55 + b, GR.deep)
  for _, q in ipairs{ {29,59},{30,60},{31,60},{32,60},{33,60},{34,60},{35,59} } do c:px(q[1], q[2] + b, INK) end
  for _, s in ipairs{ -1, 1 } do
    local ex = 32 + s * 11
    c:part(c:ellipse(ex, 45 + b, 4, 4.5), GR, { band = 1, nopop = true })
    if p.blink then
      c:fillMask(c:ellipse(ex, 45 + b, 2.5, 3), GR.shade)
      for x = ex - 2, ex + 2 do c:px(x, 46 + b, INK) end
    else
      c:fillMask(c:ellipse(ex, 45 + b, 2.5, 3), P.cream)
      c:fillMask(c:rect(ex - 1 + (s > 0 and 0 or 1), 44 + b, ex + (s > 0 and 0 or 1), 46 + b), INK)
      c:px(ex - 1 + (s > 0 and 0 or 1), 44 + b, P.cream)
    end
  end
  c:cheek(25, 52 + b) c:cheek(37, 52 + b)
  -- ivy-leaf cap
  local leaf = c:ellipse(32, 35 + b, 4, 3.5) leaf:add(c:ellipse(27.5, 37 + b, 3, 2.5)) leaf:add(c:ellipse(36.5, 37 + b, 3, 2.5))
  leaf:add(c:poly{ { 29, 34 + b }, { 35, 34 + b }, { 32, 29 + b } })
  c:part(leaf, IV, { band = 2, pop = { x = 29, y = 33 + b } })
  c:fillMask(c:line({ { 32, 31 + b }, { 32, 37 + b } }, 1), IV.hi)
  c:px(30, 36 + b, IV.hi) c:px(34, 36 + b, IV.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local IDLE = { { b = 0 }, { b = 1, ad = 1 }, { b = 0 }, { blink = true, at = -1 } }
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
