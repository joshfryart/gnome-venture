-- npc-bracken-spurwing sprite (npc2 P1_2) species: ground beetle
-- Bracken Spurwing: stout brown ground beetle, glossy elytra shell, purple bandana with knot tails,
-- red vest, four tiny arms; prop/quirk: carries a curled bracken fiddlehead frond. idle(4), feet fixed.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-bracken-spurwing"
local SH = { hi = "#d39a5e", base = "#9a5f36", shade = "#64394a", deep = "#3d2438" }
local CLY = { hi = "#e8b47a", base = "#b97a44", shade = "#7a4a44", deep = "#4a2c3a" }
local MAND = { hi = "#f2d29a", base = "#c9955a", shade = "#8a5a48", deep = "#5a3644" }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local VEST, BAND, FERN = P.ember, P.dusk, P.moss
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local NO = { band = 1, nopop = true, inner = false }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  -- elytra shell behind the body, glossy
  local shell = c:ellipse(32, 75 + b, 14, 9.5)
  c:part(shell, SH, { band = 2, pop = { x = 20, y = 71 + b }, inner = false })
  under(c, shell, SH.deep)
  -- bracken frond (behind head), fiddlehead curl on top
  local sw = p.fs or 0
  local function sx(y) local t = (80 - y) / 40 return 45 + 4 * t + (t > 0.55 and sw or 0) end
  local fern = c:line({ { 45, 80 + b }, { 47, 60 + b }, { 49 + sw, 44 + b } }, 1)
  for y = 74, 49, -5 do local x = sx(y)
    fern:add(c:line({ { x, y + b }, { x - 4, y + 2 + b } }, 2)) fern:add(c:line({ { x + 1, y - 2 + b }, { x + 5, y + b } }, 2)) end
  fern:add(c:ellipse(51 + sw, 40 + b, 2.5, 2.5))
  c:part(fern, FERN, { band = 1, inner = false, pop = { x = 49 + sw, y = 38 + b } })
  c:put(51 + sw, 40 + b, FERN.deep) c:put(52 + sw, 40 + b, FERN.shade) c:put(51 + sw, 41 + b, FERN.shade)
  -- antennae (elbowed, clubbed)
  local ta, tw = p.ta or 0, p.tw or 0
  local an = c:line({ { 27, 45 + b }, { 24, 38 + b }, { 20, 34 + b + ta } }, 1)
  an:add(c:line({ { 37, 45 + b }, { 40, 38 + b }, { 44 + tw, 34 + b + ta - tw } }, 1))
  c:fillMask(an, SH.shade)
  for _, t in ipairs{ { 18.5, 33 + b + ta }, { 45.5 + tw, 33 + b + ta - tw } } do
    c:part(c:ellipse(t[1], t[2], 1.5, 1.5), SH, { band = 1, inner = false, pop = { x = math.floor(t[1]) - 1, y = math.floor(t[2]) - 1 } })
  end
  -- vest + shirt
  local vest = c:ellipse(32, 78 + b, 10, 8)
  c:part(vest, VEST, { band = 2, inner = false, pop = { x = 25, y = 73 + b } })
  under(c, vest, VEST.deep)
  c:part(c:poly{ { 28, 70 + b }, { 37, 70 + b }, { 32.5, 76 + b } }, CR, NO)
  for y = 76, 85 do c:put(32, y + b, VEST.deep) end
  c:button(32, 80 + b)
  -- four tiny arms
  for _, a in ipairs{ { 20, 72 }, { 44, 72 }, { 21, 79 }, { 43, 79 } } do
    local m = c:ellipse(a[1], a[2] + b, 2, 1.5) c:part(m, SH, NO) under(c, m, SH.deep)
  end
  -- feet (fixed)
  for _, x in ipairs{ 26.5, 37.5 } do local m = c:ellipse(x, 88, 3, 1.5) c:part(m, SH, NO) under(c, m, SH.deep) end
  -- big glossy head
  local head = c:ellipse(32, 56 + b, 14, 12.5)
  c:part(head, SH, { band = 2, inner = false, nopop = true })
  under(c, head, SH.deep)
  for _, q in ipairs{ { 25, 46 }, { 26, 45 }, { 27, 45 }, { 28, 44 } } do c:put(q[1], q[2] + b, SH.hi) end
  c:put(27, 45 + b, P.cream)
  -- bandana arc + knot + tails
  local band = HP.mask()
  head:each(function(x, y) local t = 47 + b + math.floor(3 * (1 - ((x - 32) / 14) ^ 2) + 0.5)
    if y >= t and y <= t + 2 then band:set(x, y) end end)
  c:part(band, BAND, NO)
  band:each(function(x, y) if not band:has(x, y - 1) and x < 34 then c:put(x, y, BAND.hi) end end)
  local tl = p.tl or 0
  local tails = c:poly{ { 46, 48 + b }, { 53, 51 + b + tl }, { 52, 54 + b + tl } }
  tails:add(c:poly{ { 46, 50 + b }, { 50, 55 + b + tl }, { 48, 56 + b + tl } })
  c:part(tails, BAND, NO) under(c, tails, BAND.deep)
  c:part(c:ellipse(46, 49 + b, 2, 2), BAND, { band = 1, inner = false, pop = { x = 45, y = 48 + b } })
  -- face
  c:eyeLocked(23, 55 + b) c:eyeLocked(37, 55 + b)
  c:part(c:rrect(29, 61 + b, 35, 63 + b, 1), CLY, { band = 1, inner = false, pop = { x = 30, y = 61 + b } })
  for _, q in ipairs{ { 30, 65 }, { 31, 66 }, { 32, 66 }, { 33, 66 }, { 34, 65 } } do c:put(q[1], q[2] + b, P.ink) end
  local md = c:line({ { 25, 63 + b }, { 25, 66 + b }, { 28, 69 + b } }, 2):add(c:line({ { 38, 63 + b }, { 38, 66 + b }, { 35, 69 + b } }, 2))
  c:part(md, MAND, NO)
  c:put(25, 63 + b, MAND.hi) c:put(38, 63 + b, MAND.hi)
  c:cheek(20, 61 + b) c:cheek(43, 61 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { bob = 1, tl = 1, fs = -1 }, {}, { tw = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
