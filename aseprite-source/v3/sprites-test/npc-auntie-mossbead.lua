-- npc-auntie-mossbead (sprite N1_0, turtle)
-- Auntie Mossbead: kindly elder tortoise. Silhouette: wide mossy domed shell with scalloped rim
-- flaring past the body, big bald scaly turtle head with a rounded beak-snout. Warm rose shawl + cream apron.
-- Quirk/prop: a sleepy grey cat riding in a wicker basket on her arm. 64x96, feet baseline y=90, x=32.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/sprites-test/"
local NAME = "npc-auntie-mossbead"
local R = {
  skin   = { hi = "#a8d878", base = "#6fae4f", shade = "#3f7a46", deep = "#28504a" },
  shell  = { hi = "#c99c5c", base = "#9a6a3a", shade = "#6b4535", deep = "#43303a" },
  moss   = { hi = "#c4e070", base = "#86ad3e", shade = "#55803c", deep = "#33573f" },
  shawl  = { hi = "#f6a88c", base = "#d9694f", shade = "#a2444a", deep = "#6a2c44" },
  apron  = { hi = "#fff3d6", base = "#f0d9a8", shade = "#c9a98a", deep = "#8a7080" },
  basket = { hi = "#ecc474", base = "#c08a44", shade = "#8a5a3a", deep = "#563a3a" },
  cat    = { hi = "#e2dee8", base = "#a9a3ba", shade = "#77708c", deep = "#4a4258" },
}
local INK, CREAM = "#2b1c26", "#fff3d6"

local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { noshade = true, nopop = true, inner = o.inner })
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
  if o.pop then for _, q in ipairs(o.pop) do c:put(q[1], q[2], r.hi, r) end end
  return m
end
local function under(c, m, hex)
  m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end)
end
local function each(m, fn) m:each(fn) end

local c = HP.canvas{ w = 64, h = 96, name = NAME }
c:groundShadow(32, 89, 17, 3)

-- stubby elephant-ish tortoise feet with cream toenails
for _, fx in ipairs({ 25, 39 }) do
  local f = c:ellipse(fx, 87, 5, 3)
  form(c, f, R.skin, { frac = 0.35, off = 1, pop = { { fx - 3, 85 } } })
  under(c, f, R.skin.deep)
  for i = -3, 3, 3 do c:put(fx + i, 89, R.apron.base) end
end

-- domed shell behind: wide, scalloped rim
local shell = c:ellipse(32, 63, 22, 18)
for x = 12, 52, 5 do shell:add(c:ellipse(x, 74 - math.floor(math.abs(x - 32) / 4), 2.5, 2.5)) end
form(c, shell, R.shell, { frac = 0.3, off = 2 })
under(c, shell, R.shell.deep)
-- scute seams on the visible flanks + marginal ring
for y = 52, 76 do
  local dx = math.floor(math.abs(y - 63) / 4)
  for _, x in ipairs({ 15 + dx, 49 - dx }) do if shell:has(x, y) then c:put(x, y, R.shell.deep) end end
end
for x = 10, 54 do local y = 72 - math.floor(math.abs(x - 32) / 4)
  if shell:has(x, y) and (x < 19 or x > 45) then c:put(x, y, R.shell.deep) end end
for _, q in ipairs({ { 12, 60 }, { 13, 59 }, { 12, 66 }, { 51, 67 } }) do c:put(q[1], q[2], R.shell.hi) end
-- moss blanket over the dome with drooping tufts
local moss = shell:copy()
moss:clip(c:ellipse(32, 45, 25, 12))
for _, t in ipairs({ { 12, 55 }, { 17, 57 }, { 46, 57 }, { 52, 55 }, { 22, 56 }, { 42, 56 } }) do
  local tf = c:ellipse(t[1], t[2], 2, 2) tf:clip(shell) moss:add(tf)
end
form(c, moss, R.moss, { frac = 0.3, off = 1, pop = { { 13, 50 }, { 14, 49 }, { 16, 48 } } })
each(moss, function(x, y) local h = X and 0 or ((x * 7 + y * 13) % 9)
  if h == 0 and c:get(x, y) == R.moss.base then c:put(x, y, R.moss.hi) end
  if h == 4 and c:get(x, y) == R.moss.base then c:put(x, y, R.moss.shade) end end)
under(c, moss, R.moss.deep)

-- torso (green) + cream apron with pocket
local torso = c:ellipse(32, 68, 12, 13)
form(c, torso, R.skin, { frac = 0.3 })
local ap = c:poly{ { 24, 60 }, { 40, 60 }, { 42, 78 }, { 22, 78 } }
ap:add(c:ellipse(32, 78, 10, 4))
form(c, ap, R.apron, { frac = 0.3, off = 2, pop = { { 25, 62 }, { 25, 63 } } })
under(c, ap, R.apron.deep)
for x = 26, 30 do c:put(x, 72, R.apron.shade) end
c:put(26, 73, R.apron.shade) c:put(30, 73, R.apron.shade) c:put(26, 74, R.apron.shade) c:put(30, 74, R.apron.shade)
for x = 26, 30 do c:put(x, 75, R.apron.shade) end

-- left tiny arm
local la = c:ellipse(18, 62, 3, 5)
form(c, la, R.skin, { frac = 0.3, off = 1 }) under(c, la, R.skin.deep)

-- short wrinkly neck
local neck = c:rect(27, 43, 37, 50)
form(c, neck, R.skin, { frac = 0.3, off = 1 })
c:put(29, 47, R.skin.shade) c:put(30, 48, R.skin.shade) c:put(34, 48, R.skin.shade) c:put(35, 47, R.skin.shade)

-- rose shawl over the shoulders, point down the front, fringe
local sh = c:rrect(16, 48, 48, 55, 3)
sh:add(c:poly{ { 22, 54 }, { 42, 54 }, { 32, 63 } })
form(c, sh, R.shawl, { frac = 0.3, off = 2, pop = { { 19, 49 }, { 20, 49 }, { 18, 50 } } })
under(c, sh, R.shawl.deep)
for x = 17, 47, 2 do if not sh:has(x, 56) then c:put(x, 56, R.shawl.shade) end end
c:put(31, 64, R.shawl.shade) c:put(33, 64, R.shawl.shade)
for x = 18, 46, 4 do c:put(x, 51, R.shawl.hi) end

-- right arm reaching to the basket handle
local ra = c:ellipse(46, 61, 3, 4)
form(c, ra, R.skin, { frac = 0.5, off = 1 })

-- basket handle (behind cat)
local hd = c:line({ { 35, 72 }, { 37, 64 }, { 42, 62 }, { 47, 64 }, { 49, 72 } }, 2)
form(c, hd, R.basket, { frac = 0.4, off = 1 })
-- cat peeking out
local cat = c:ellipse(42, 69, 4.5, 3.5)
cat:add(c:poly{ { 38, 68 }, { 38, 64 }, { 41, 66 } })
cat:add(c:poly{ { 43, 66 }, { 46, 64 }, { 46, 68 } })
form(c, cat, R.cat, { frac = 0.35, off = 1, pop = { { 39, 67 }, { 40, 66 } } })
c:put(39, 65, "#e89aa6") c:put(45, 65, "#e89aa6")
c:put(39, 69, INK) c:put(40, 69, INK) c:put(44, 69, INK) c:put(45, 69, INK) -- sleepy shut eyes
c:put(42, 70, "#e89aa6") c:put(41, 71, R.cat.deep) c:put(43, 71, R.cat.deep)
-- basket body with weave
local bk = c:poly{ { 33, 72 }, { 51, 72 }, { 49, 80 }, { 35, 80 } }
bk:add(c:ellipse(42, 80, 7, 1.5))
form(c, bk, R.basket, { frac = 0.35, off = 1 })
each(bk, function(x, y) if y > 73 and ((x + (y // 2) * 2) % 4 == 0) then c:put(x, y, R.basket.shade) end end)
for x = 33, 51 do if bk:has(x, 72) then c:put(x, 72, (x % 3 == 0) and R.basket.base or R.basket.hi) end end
under(c, bk, R.basket.deep)
-- cat paws over the rim, her hand on the handle
c:put(39, 72, R.cat.hi) c:put(40, 72, R.cat.hi) c:put(44, 72, R.cat.hi) c:put(45, 72, R.cat.hi)
local hand = c:ellipse(47, 65, 2, 2)
form(c, hand, R.skin, { frac = 0.4, off = 1 })

-- big bald scaly turtle head + rounded snout
local head = c:ellipse(32, 30, 16, 15)
head:add(c:ellipse(32, 39, 10, 6))
form(c, head, R.skin, { frac = 0.28, off = 2, pop = { { 22, 20 }, { 23, 19 }, { 24, 19 }, { 22, 21 } } })
under(c, head, R.skin.deep)
-- crown scale plates (hex-ish)
for _, q in ipairs({ { 27, 19 }, { 33, 18 }, { 39, 20 }, { 24, 24 }, { 30, 23 }, { 36, 23 }, { 42, 25 }, { 33, 28 } }) do
  local x, y = q[1], q[2]
  c:put(x, y, R.skin.shade) c:put(x + 1, y, R.skin.shade) c:put(x - 1, y + 1, R.skin.shade) c:put(x + 2, y + 1, R.skin.shade)
  c:put(x, y + 1, R.skin.hi)
end
-- kindly eyes: drooping lids, dark eye, glint, crow's-feet
local function eye(x, y)
  for i = -1, 3 do c:put(x + i, y - 1, R.skin.deep) end
  c:put(x, y, INK) c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  c:put(x, y + 1, INK) c:put(x + 1, y + 1, CREAM) c:put(x + 2, y + 1, INK)
  c:put(x + 1, y + 2, INK)
  c:put(x + (x < 32 and -2 or 4), y + 1, R.skin.shade) c:put(x + (x < 32 and -2 or 4), y + 2, R.skin.shade)
end
eye(23, 30) eye(38, 30)
-- snout: nostrils, beak-line smile
c:put(30, 36, R.skin.deep) c:put(34, 36, R.skin.deep)
c:put(30, 35, R.skin.hi) c:put(31, 35, R.skin.hi)
for x = 28, 36 do c:put(x, 41, R.skin.deep) end
c:put(27, 40, R.skin.deep) c:put(37, 40, R.skin.deep) c:put(32, 42, R.skin.shade)
c:cheek(20, 36) c:cheek(42, 36)

c:finish{ outline = true }
HP.assertClean(c)
local s = HP.sheet{ cellw = 64, cellh = 96, frames = { c } }
s:save{ png = out .. "auntie-mossbead.png", scale = 1 }
local pc = app.pixelColor
local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
for i, hex in pairs(c.pix) do
  im:putPixel(i % 64, i // 64, pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255))
end
local spr = Sprite(64, 96, ColorMode.RGB) spr.cels[1].image = im spr.layers[1].name = NAME
spr:saveAs(out .. "auntie-mossbead.aseprite") spr:close()
print(NAME .. " ok")
