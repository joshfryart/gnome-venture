-- folk-hare-2 sprite (folk F1_4) variant: 2
-- Hare rest-stop villager. Tells: long ears with ink-dark tips + pink inner, pale eye ring, split Y lip + buck teeth, long hind feet, cotton tail.
-- v1 gardener: sandy hare, straw hat (ears through slots) + clover sprig, sage overalls, trowel.
-- v2 traveller: grey-fawn mountain hare, one ear folded, rust knit scarf, pack + bedroll, brass lantern.
-- v3 cook: russet hare, ears flung wide, red polka kerchief, plum smock + cream apron, copper ladle.
local V = 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-hare-" .. V
local FUR = ({
  { hi = "#ecc892", base = "#c99a62", shade = "#946a58", deep = "#5e4050" },
  { hi = "#dacbb6", base = "#a8988a", shade = "#76687e", deep = "#4a405a" },
  { hi = "#eea464", base = "#c26c3c", shade = "#8a4646", deep = "#58303e" },
})[V]
local CREAM = { hi = "#fcf2da", base = "#efdcb8", shade = "#c6aca2", deep = "#8e7688" }
local PINK = { hi = "#f8c4bc", base = "#e2929a", shade = "#b2667a", deep = "#7c425a" }
local TIP = { hi = "#6c5260", base = "#4e3a48", shade = "#3c2c3a", deep = "#33232f" }
local STRAW = { hi = "#f8e08a", base = "#e0b858", shade = "#ae8044", deep = "#76503e" }
local SAGE = { hi = "#a8cc84", base = "#6e9e5a", shade = "#4a6e54", deep = "#2f4448" }
local METAL = { hi = "#e6e4ec", base = "#a8a8bc", shade = "#6e6c88", deep = "#46445e" }
local WOOD = { hi = "#d49a62", base = "#a06a3e", shade = "#6e4436", deep = "#4a2c30" }
local TEAL = { hi = "#7cc4bc", base = "#3e8c90", shade = "#2c5e72", deep = "#223c54" }
local RUST = { hi = "#f09a5c", base = "#d0603a", shade = "#9a3c3c", deep = "#62283a" }
local LEATHER = { hi = "#c89068", base = "#8e5e44", shade = "#62403e", deep = "#40283a" }
local OAT = { hi = "#efe0b4", base = "#cdb88a", shade = "#9a8270", deep = "#64506a" }
local BRASS = { hi = "#fae79a", base = "#e0b040", shade = "#a87232", deep = "#6c4434" }
local GLOW = { hi = "#fff6c0", base = "#ffe07a", shade = "#f4b04a", deep = "#c8783a" }
local PLUM = { hi = "#c08ac4", base = "#8c5aa0", shade = "#5e3c7c", deep = "#3c2856" }
local KERCH = { hi = "#f08080", base = "#d04850", shade = "#9a2e48", deep = "#621e3a" }
local COPPER = { hi = "#f6b48a", base = "#d27848", shade = "#9a4a3c", deep = "#5e2c34" }
local function F(c, m, r, band, pop)
  c:part(m, r, { band = band or 2, nopop = true })
  if pop then for _, q in ipairs(pop) do if m:has(q[1], q[2]) then c:put(q[1], q[2], r.hi, r) end end end
  return m
end
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
local function seg(ax, ay, bx, by, w)
  local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2) / 2
  return oval((ax + bx) / 2, (ay + by) / 2, len, w, math.deg(math.atan(by - ay, bx - ax)))
end
-- hare ear: long fur blade, pink inner, ink-dark tip; optional knee K = folded-over ear
local function ear(c, B, T, w, K)
  local m, inner
  if K then
    m = seg(B[1], B[2], K[1], K[2], w) m:add(seg(K[1], K[2], T[1], T[2], w * 0.9))
    inner = seg(B[1] + (K[1] - B[1]) * .15, B[2] + (K[2] - B[2]) * .15, K[1], K[2], w * 0.45)
  else
    m = seg(B[1], B[2], T[1], T[2], w)
    local L = function(f) return B[1] + (T[1] - B[1]) * f, B[2] + (T[2] - B[2]) * f end
    local ix, iy = L(0.12) local jx, jy = L(0.76)
    inner = seg(ix, iy, jx, jy, w * 0.45)
  end
  F(c, m, FUR, 2)
  F(c, inner:clip(m:shrink(1)), PINK, 1)
  F(c, HP.ellipse(T[1], T[2], w * 1.5, w * 1.5):clip(m), TIP, 1)
  return m
end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end c:put(x, y + 1, P.ink) c:put(x + 3, y + 1, P.ink) return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, s, t = p.b or 0, p.settle or 0, p.tw or 0
  c:groundShadow(32, 89.5, 14, 3)
  if V == 2 then -- pack + bedroll behind the shoulders
    F(c, c:rrect(17, 64 + b, 47, 81 + b, 4), LEATHER, 2)
    F(c, c:rrect(15, 57 + b, 49, 63 + b, 3), OAT, 2, { { 16, 58 + b }, { 17, 58 + b } })
    for _, x in ipairs{ 19, 20, 44, 45 } do for y = 57, 63 do if c:get(x, y + b) then c:put(x, y + b, RUST.base) end end end
  else
    F(c, c:ellipse(45.5, 81 + b, 2.5, 2.5), CREAM, 1, { { 44, 79 + b } }) -- cotton tail
  end
  for _, fx in ipairs{ 25, 39 } do -- long hind feet (never move)
    F(c, c:ellipse(fx, 88.5, 5.5, 2), FUR, 1, { { fx - 4, 88 } })
    c:put(fx - 2, 90, FUR.deep) c:put(fx + 1, 90, FUR.deep)
  end
  local hL, hR = c:ellipse(24.5, 83 + b, 5.5, 4.5), c:ellipse(39.5, 83 + b, 5.5, 4.5)
  F(c, hL, FUR, 2, { { 21, 81 + b } }) F(c, hR, FUR, 2)
  local torso = c:ellipse(32, 75 + b, 10.5, 9.5)
  F(c, torso, ({ FUR, TEAL, PLUM })[V], 2, { { 26, 68 + b }, { 27, 68 + b } })
  if V == 1 then
    F(c, c:ellipse(32, 75 + b, 6, 6.5), CREAM, 1)
    local ov = torso:copy():add(hL:copy()):add(hR:copy()):clip(c:rect(0, 78 + b, 63, 85 + b))
    ov:add(c:rrect(26, 69 + b, 37, 78 + b, 1))
    F(c, ov, SAGE, 2, { { 27, 71 + b } })
    F(c, c:rect(29, 72 + b, 34, 75 + b), SAGE, 1)
    F(c, c:line({ { 27, 70 + b }, { 25, 65 + b } }, 2), SAGE, 1)
    F(c, c:line({ { 36, 70 + b }, { 38, 65 + b } }, 2), SAGE, 1)
    c:put(27, 70 + b, BRASS.hi) c:put(36, 70 + b, BRASS.base)
    F(c, c:rect(22, 81 + b, 24, 83 + b), STRAW, 1) -- knee patch
    F(c, c:rect(43, 76 + b, 44, 80 + b), WOOD, 1) -- trowel
    F(c, c:poly{ { 41, 80 + b }, { 46, 80 + b }, { 45, 85 + b }, { 44, 87 + b }, { 43, 87 + b }, { 42, 85 + b } }, METAL, 1, { { 42, 81 + b } })
    c:put(43, 83 + b, METAL.shade) c:put(43, 85 + b, METAL.shade) c:put(45, 82 + b, WOOD.shade)
  elseif V == 2 then
    F(c, torso:copy():clip(c:rect(0, 79 + b, 63, 80 + b)), LEATHER, 1)
    F(c, c:rect(31, 79 + b, 32, 80 + b), BRASS, 1)
    F(c, c:line({ { 24, 66 + b }, { 23, 78 + b } }, 2), LEATHER, 1)
    F(c, c:line({ { 40, 66 + b }, { 41, 78 + b } }, 2), LEATHER, 1)
    c:put(32, 72 + b, BRASS.base) c:put(32, 75 + b, BRASS.base)
  else
    F(c, c:rrect(25, 68 + b, 38, 86 + b, 2), CREAM, 2, { { 26, 69 + b }, { 26, 70 + b } })
    for x = 25, 38 do c:put(x, 75 + b, CREAM.shade) end
    F(c, c:rect(28, 79 + b, 35, 83 + b), CREAM, 1)
    c:put(30, 71 + b, CREAM.hi) c:put(33, 73 + b, CREAM.hi)
    F(c, c:line({ { 44, 78 + b }, { 47 + t, 60 + b } }, 2), COPPER, 1) -- ladle
    F(c, c:ellipse(48.5 + t, 57.5 + b, 3, 2.5), COPPER, 1, { { 47 + t, 56 + b } })
    for x = 47, 50 do c:put(x + t, 56 + b, x == 47 and BRASS.hi or BRASS.base) end
  end
  for _, ax in ipairs{ 20.5, 43.5 } do
    F(c, c:ellipse(ax, 73 + b, 2.8, 4.2), ({ FUR, TEAL, PLUM })[V], 1)
    F(c, c:ellipse(ax, 77.5 + b, 2.5, 2), FUR, 1)
  end
  if V == 2 then -- brass lantern hanging from the left paw
    c:put(19, 79 + b, BRASS.deep) c:put(22, 79 + b, BRASS.deep)
    F(c, c:rect(18, 80 + b, 23, 81 + b), BRASS, 1)
    F(c, c:rect(18, 82 + b, 23, 86 + b), BRASS, 1)
    F(c, c:rect(19, 83 + b, 22, 85 + b), GLOW, 1, { { 19, 83 + b } })
    F(c, c:rect(17, 87 + b, 24, 87 + b), BRASS, 1)
  end
  local hy = 53 + b
  if V == 2 then
    ear(c, { 28, 46 + b }, { 25 - s, 12 + b }, 3.3)
    ear(c, { 36, 46 + b }, { 45, 31 + b + s }, 3.3, { 39, 24 + b })
  elseif V == 3 then
    ear(c, { 27, 46 + b }, { 15 - s, 17 + b }, 3.3)
    ear(c, { 37, 46 + b }, { 49 + s + t, 17 + b - t }, 3.3)
  end
  local head = c:ellipse(32, hy, 12.5, 10)
  head:add(c:ellipse(20, hy + 4, 2, 2)) head:add(c:ellipse(44, hy + 4, 2, 2))
  F(c, head, FUR, 2, { { 25, hy - 7 }, { 26, hy - 7 }, { 24, hy - 6 } })
  F(c, c:ellipse(32, hy + 5, 5.5, 3.5), CREAM, 1, { { 29, hy + 3 } })
  c:fillMask(c:ellipse(26, hy - 2, 3, 3), CREAM.base) c:fillMask(c:ellipse(38, hy - 2, 3, 3), CREAM.base)
  eye(c, 24, hy - 4, p.blink) eye(c, 36, hy - 4, p.blink)
  for x = 30, 33 do c:put(x, hy + 2, PINK.base) end
  c:put(30, hy + 2, PINK.hi) c:put(31, hy + 3, PINK.shade) c:put(32, hy + 3, PINK.shade)
  c:put(31, hy + 4, P.ink) c:put(32, hy + 4, P.ink) c:put(30, hy + 5, P.ink) c:put(33, hy + 5, P.ink)
  c:put(31, hy + 5, CREAM.hi) c:put(32, hy + 5, CREAM.hi)
  for _, q in ipairs{ { 28, 4 }, { 27, 6 }, { 35, 4 }, { 36, 6 } } do c:put(q[1], hy + q[2], CREAM.deep) end
  for _, x in ipairs{ 22, 23, 40, 41 } do c:put(x, hy + 3, PINK.base) end
  if V == 1 then
    local brim, crown = c:ellipse(32, hy - 8, 16, 3.2), c:rrect(24, hy - 15, 40, hy - 8, 3)
    F(c, brim, STRAW, 1, { { 18, hy - 9 } })
    brim:each(function(x, y) if not brim:has(x, y + 1) then c:put(x, y, STRAW.deep) end end)
    F(c, crown, STRAW, 2, { { 25, hy - 13 }, { 26, hy - 14 } })
    brim:copy():add(crown):each(function(x, y) if c:get(x, y) == STRAW.base and (x + 2 * y) % 4 == 0 then c:put(x, y, STRAW.shade) end end)
    crown:each(function(x, y) if y >= hy - 10 and y <= hy - 9 then c:put(x, y, y == hy - 10 and SAGE.base or SAGE.shade) end end)
    ear(c, { 28, hy - 12 }, { 24 - s, 10 + b }, 3.3)
    ear(c, { 36, hy - 12 }, { 40 + s + 2 * t, 10 + b + t }, 3.3)
    for _, q in ipairs{ { 39, -12, SAGE.hi }, { 40, -13, SAGE.base }, { 41, -12, SAGE.base }, { 40, -11, SAGE.shade } } do c:put(q[1], hy + q[2], q[3]) end
  elseif V == 3 then
    local band = head:copy():clip(c:rect(0, hy - 9, 63, hy - 7))
    F(c, band, KERCH, 1)
    for x = 22, 42, 3 do if band:has(x, hy - 8) then c:put(x, hy - 8, CREAM.hi) end end
    F(c, c:ellipse(43.5, hy - 6, 1.8, 1.8), KERCH, 1)
    F(c, c:poly{ { 44, hy - 5 }, { 48, hy - 2 }, { 47, hy - 1 }, { 44, hy - 3 } }, KERCH, 1)
  else
    local sc = c:rrect(21, hy + 9, 43, hy + 13, 2)
    F(c, sc, RUST, 1)
    sc:each(function(x, y) if x % 2 == 0 and c:get(x, y) == RUST.base then c:put(x, y, RUST.shade) end end)
    F(c, c:rrect(22, hy + 11, 26, hy + 21, 1), RUST, 1, { { 22, hy + 12 } })
    for x = 22, 26, 2 do c:put(x, hy + 21, RUST.deep) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local PARAMS = { { b = 0 }, { b = 1, settle = 1 }, { b = 0 }, { b = 0, tw = (V ~= 2) and 1 or 0, blink = (V == 2) } }
local frames = {}
for _, p in ipairs(PARAMS) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local DUR = { 0.45, 0.35, 0.45, 0.3 }
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = DUR[f]
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
