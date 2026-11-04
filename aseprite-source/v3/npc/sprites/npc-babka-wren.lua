-- npc-babka-wren sprite (npc2 P1_1) species: wren
-- Plump brown wren grandma: red polka-dot babushka scarf knotted under the beak, round gold spectacles,
-- cream brow stripe, cocked barred tail. Prop: a chocolate-swirl babka loaf hugged in both wings.
-- Idle: breath, scarf flaps settle, blink + tail flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-babka-wren"
local BR, SC = P.wood, P.ember
local BELLY = { hi = P.cream, base = "#f3e6c8", shade = "#d9c3b0", deep = P.wood.hi }
local CRUST = { hi = P.gold.hi, base = "#e89d28", shade = P.wood.base, deep = P.wood.shade }
local CHOC = "#5e3a2e"
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex, c.own[q[2] * c.w + q[1]]) end end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, hf = p.b or 0, p.tw or 0, p.hf or 0
  c:groundShadow(32, 89, 12, 3)
  -- cocked tail, barred
  local tail = c:poly{ { 37, 68 + b }, { 44, 71 + b }, { 53 + tw, 50 + b }, { 47 + tw, 48 + b } }
  c:part(tail, BR, { band = 1 })
  for _, y in ipairs({ 53, 57, 61, 65 }) do for x = 38, 56 do if tail:has(x, y + b) then c:put(x, y + b, BR.deep, c.own[(y + b) * 64 + x]) end end end
  -- legs + toes (fixed)
  for _, lx in ipairs({ 29, 35 }) do
    c:fillMask(c:rect(lx, 82, lx, 88), BR.shade)
    c:fillMask(c:rect(lx - 1, 89, lx + 1, 90), BR.shade) c:put(lx - 1, 90, BR.deep) c:put(lx + 1, 90, BR.deep)
  end
  -- body + belly
  local body = c:ellipse(32, 72 + b, 13, 11)
  c:part(body, BR, { band = 3 }) under(c, body, BR.deep)
  local bel = c:ellipse(32, 76 + b, 8, 7):clip(body)
  c:part(bel, BELLY, { band = 2, nopop = true })
  for _, q in ipairs({ { 28, 79 }, { 33, 80 }, { 36, 78 }, { 30, 82 } }) do if bel:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, BR.shade) end end
  -- babka loaf
  local loaf = c:rrect(21, 67 + b, 43, 76 + b, 3)
  c:part(loaf, CRUST, { band = 2, pop = { x = 24, y = 68 + b } }) under(c, loaf, CRUST.deep)
  local ins = loaf:shrink(1)
  for k = 0, 3 do c:line({ { 24 + k * 5, 68 + b }, { 27 + k * 5, 75 + b } }, 1):clip(ins):each(function(x, y) c:put(x, y, CHOC, c.own[y * 64 + x]) end) end
  for x = 23, 41, 3 do c:put(x, 68 + b, P.cream) end
  -- wings hugging the loaf
  for _, wx in ipairs({ 20, 44 }) do local w = c:ellipse(wx, 71 + b, 3, 5) c:part(w, BR, { band = 1 }) c:put(wx, 73 + b, BR.deep) c:put(wx, 70 + b, BR.deep) end
  -- head
  local head = c:ellipse(32, 45 + b, 14, 12)
  c:part(head, BR, { band = 2 })
  -- babushka scarf with face opening, chin knot, flaps
  local open = c:ellipse(32, 48 + b, 10, 8.5)
  local s = c:ellipse(32, 42 + b, 16, 13.5):cut(open):clip(c:rect(0, 0, 63, 57 + b))
  s:add(c:ellipse(32, 58 + b, 2.5, 1.5))
  s:add(c:poly{ { 31, 58 + b }, { 26, 65 + b + hf }, { 30, 65 + b + hf } })
  s:add(c:poly{ { 33, 58 + b }, { 38, 65 + b + hf }, { 34, 65 + b + hf } })
  c:part(s, SC, { band = 2, pop = { x = 20, y = 35 + b } }) under(c, s, SC.deep)
  local inn = s:shrink(1)
  for y = 31, 55, 5 do for x = 18, 46, 5 do local xx = x + ((y - 31) // 5 % 2) * 2
    if inn:has(xx, y + b) and inn:has(xx + 1, y + b) then c:put(xx, y + b, P.cream) c:put(xx + 1, y + b, P.stone.hi) end end end
  -- face: brow stripes, spectacles, eyes, beak, cheeks
  local face = open:clip(head)
  c:part(face, { hi = P.wood.hi, base = "#c98a55", shade = BR.base, deep = BR.shade }, { band = 2, nopop = true })
  for x = 24, 28 do c:put(x, 41 + b, P.cream) end for x = 36, 40 do c:put(x, 41 + b, P.cream) end
  for _, gx in ipairs({ 25, 35 }) do
    c:rect(gx, 43 + b, gx + 3, 47 + b):edge():each(function(x, y) c:put(x, y, P.gold.base) end)
    c:put(gx, 43 + b, P.gold.hi)
    if p.blink then c:put(gx + 1, 46 + b, P.ink) c:put(gx + 2, 46 + b, P.ink)
    else c:fillMask(c:rect(gx + 1, 44 + b, gx + 2, 46 + b), P.ink) c:put(gx + 1, 44 + b, P.cream) end
  end
  c:put(29, 44 + b, P.gold.shade) c:put(34, 44 + b, P.gold.shade)
  c:paint({ "hGG", "GGS", ".S." }, 31, 48 + b, { h = "gold.hi", G = "gold.base", S = "gold.shade" })
  c:cheek(24, 49 + b) c:cheek(39, 49 + b)
  return c
end
local FR = { { b = 0 }, { b = 1, hf = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(FR) do local c = frame(p) c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
