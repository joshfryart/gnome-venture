-- npc-old-baobab-kito sprite (npc2 P1_26) species: elephant
-- Old Baobab Kito: kindly elder elephant, cream kufi with stitched band, kente shawl, woven basket on the hip with a ginger cat peeking out (prop).
local NAME = "npc-old-baobab-kito"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local INK, CREAM = "#2b1c26", "#f4ead0"
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function recol(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:put(x, y, to) end end) end
local HIDE  = { hi = "#c4b4b4", base = "#8e8098", shade = "#665a7a", deep = "#463c5a" }
local EAR   = { hi = "#c89aa4", base = "#a87888", shade = "#7c5670", deep = "#5a3e5a" }
local KUFI  = { hi = "#f6eed8", base = "#e6d6b4", shade = "#bca88c", deep = "#8a7464" }
local GOLD  = { hi = "#f8d870", base = "#e8a830", shade = "#b8702a", deep = "#7a4630" }
local GRN   = { hi = "#7cc048", base = "#3f8a3a", shade = "#2e6038", deep = "#24403a" }
local RED   = { hi = "#f07a50", base = "#c8402e", shade = "#94303a", deep = "#5e2436" }
local BASK  = { hi = "#e8c27a", base = "#c08a44", shade = "#8e5a34", deep = "#5e3a2e" }
local CAT   = { hi = "#f4b46a", base = "#e0843a", shade = "#a8562e", deep = "#6e3428" }
local TUSK  = { hi = CREAM, base = "#e8dcc0", shade = "#c0ae94", deep = "#8a7868" }
local function F(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, e = p.b or 0, p.ear or 0
  c:groundShadow(32.5, 89.5, 15, 3)
  -- stumpy feet (fixed) with toenails
  for _, fx in ipairs{ 24, 35 } do
    c:part(c:rrect(fx, 82, fx + 6, 89, 1), HIDE, { band = 2, nopop = true })
    for i = 1, 5, 2 do c:put(fx + i, 89, TUSK.base) end
  end
  -- body
  local bd = c:ellipse(32.5, 73 + b, 14, 11)
  c:part(bd, HIDE, { band = 2, nopop = true })
  -- kente shawl
  local sh = c:ellipse(32.5, 68 + b, 15, 7)
  sh:add(c:poly{ { 18, 69 + b }, { 47, 69 + b }, { 33, 81 + b } })
  c:part(sh, GOLD, { band = 2, pop = { x = 21, y = 64 + b } })
  local S = { [66] = GRN, [67] = GRN, [70] = RED, [71] = RED, [74] = GRN, [77] = RED }
  sh:each(function(x, y) local r = S[y - b] if r then c:put(x, y, x > 39 and r.shade or ((x + y) % 6 == 0 and GOLD.hi or r.base)) end end)
  sh:each(function(x, y) if not sh:has(x, y + 1) then c:put(x, y, GOLD.deep) end end)
  -- arms
  c:part(c:ellipse(19.5, 72 + b, 3, 4), HIDE, { band = 1, nopop = true })
  c:part(c:ellipse(45.5, 71 + b, 3, 4), HIDE, { band = 1, nopop = true })
  -- basket on right hip + ginger cat
  local ct = c:ellipse(46.5, 68 + b + (p.cat or 0), 4, 3)
  ct:add(c:poly{ { 43, 67 + b }, { 43, 63 + b + (p.catear or 0) }, { 46, 66 + b } })
  ct:add(c:poly{ { 47, 66 + b }, { 50, 63 + b }, { 50, 67 + b } })
  c:part(ct, CAT, { band = 1, pop = { x = 44, y = 67 + b } })
  c:put(45, 68 + b, INK) c:put(48, 68 + b, INK) c:put(46, 69 + b, EAR.base)
  local bk = c:rrect(40, 70 + b, 53, 80 + b, 2)
  c:part(bk, BASK, { band = 2, nopop = true })
  bk:each(function(x, y) if (x + (y // 2)) % 2 == 0 and y % 2 == 0 and c:get(x, y) == BASK.base then c:put(x, y, BASK.shade) end end)
  for x = 41, 52 do c:put(x, 70 + b, x < 47 and BASK.hi or BASK.base) end
  c:put(44, 71 + b, HIDE.base) c:put(45, 71 + b, HIDE.base)
  -- ears (behind head)
  for _, s in ipairs{ -1, 1 } do
    local er = c:ellipse(32.5 + s * 13, 50 + b, 7 + e, 8)
    c:part(er, HIDE, { band = 2, nopop = true })
    c:part(c:ellipse(32.5 + s * 13.5, 51 + b, 4 + e, 5), EAR, { band = 1, nopop = true, inner = false })
  end
  -- head
  local hd = c:ellipse(32.5, 49 + b, 11, 9)
  c:part(hd, HIDE, { band = 2, pop = { x = 25, y = 44 + b } })
  for _, x in ipairs{ 30, 34 } do c:put(x, 42 + b, HIDE.shade) c:put(x + 1, 42 + b, HIDE.shade) end
  -- trunk curling to the left, rings
  local tr = c:line({ { 32.5, 52 + b }, { 32.5, 60 + b }, { 31, 64 + b }, { 28, 65 + b } }, 4)
  c:part(tr, HIDE, { band = 1, nopop = true })
  tr:each(function(x, y) if (y - b) % 2 == 0 and y > 54 + b and y < 63 + b and c:get(x, y) == HIDE.base then c:put(x, y, HIDE.shade) end end)
  c:put(26, 65 + b, HIDE.deep)
  -- tusks
  for _, tx in ipairs{ 28, 37 } do c:put(tx, 56 + b, TUSK.hi) c:put(tx, 57 + b, TUSK.base) c:put(tx + (tx < 32 and 1 or -1), 58 + b, TUSK.shade) end
  -- eyes + bushy elder brows
  eye4(c, 26, 45 + b, p.blink) eye4(c, 36, 45 + b, p.blink)
  for _, q in ipairs{ { 25, 44 }, { 26, 43 }, { 27, 43 }, { 28, 44 }, { 36, 44 }, { 37, 43 }, { 38, 43 }, { 39, 44 } } do c:put(q[1], q[2] + b, CREAM) end
  -- kufi cap
  local kf = c:rect(25, 36 + b, 40, 41 + b)
  kf:add(c:ellipse(32.5, 36 + b, 7.5, 2.5))
  c:part(kf, KUFI, { band = 2, pop = { x = 27, y = 35 + b } })
  local DOT = { RED.base, GRN.base, GOLD.base }
  for x = 26, 39, 2 do c:put(x, 39 + b, DOT[(x // 2) % 3 + 1]) end
  for x = 25, 40 do c:put(x, 41 + b, KUFI.deep) end
  return c
end
local FR = { { b = 0 }, { b = 1, cat = 0 }, { b = 0 }, { b = 0, ear = 1, catear = -1 } }
local frames = {}
for _, p in ipairs(FR) do local c = F(p) c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local strip = Sprite(256, 96, ColorMode.RGB)
local sim = Image(256, 96, ColorMode.RGB) sim:clear(pc.rgba(0, 0, 0, 0))
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local L = spr.layers[1] L.name = NAME
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) sim:putPixel((f - 1) * 64 + i % 64, i // 64, rgba(hex)) end
  spr:newCel(L, spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f % 2 == 1) and 0.45 or 0.3
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
strip.cels[1].image = sim strip:saveCopyAs(out .. NAME .. ".png") strip:close()
print(NAME .. " ok")
