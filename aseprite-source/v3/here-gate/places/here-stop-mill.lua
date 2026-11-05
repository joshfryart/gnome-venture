-- here-stop-mill.lua : Gnome Venture "Hearth Pop" v3 gate-view rest stop (stream-side mill), 480x270 native.
-- Run: AppRun -b --script-param out=<dir>/ --script here-stop-mill.lua
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-mill"
local W, H, HOR = 480, 270, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local function rd(v) return floor(v + .5) end

---------------------------------------------------------------- helpers
local function hsh(x, y, s)
  local n = ((x * 73856093) ~ (y * 19349663) ~ ((s or 0) * 83492791)) & 0x7fffffff
  n = (n * 1103515245 + 12345) & 0x7fffffff
  n = n ~ (n >> 15)
  return (n % 10007) / 10007
end
local function F(m, col) c:fillMask(m, col) return m end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function PL(pts) local q = {} for i, p in ipairs(pts) do q[i] = { rd(p[1]), rd(p[2]) } end return c:poly(q) end
local function LN(pts, w) local q = {} for i, p in ipairs(pts) do q[i] = { rd(p[1]), rd(p[2]) } end return c:line(q, w) end
local function bb(m)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y) if x < x0 then x0 = x end if y < y0 then y0 = y end if x > x1 then x1 = x end if y > y1 then y1 = y end end)
  return x0, y0, x1, y1
end
local function tex(m, col, p, seed) m:each(function(x, y) if hsh(x, y, seed) < p then c:put(x, y, col) end end) end
local function shadeR(m, col, frac)
  local x0, _, x1 = bb(m); local cut = x1 - (x1 - x0) * frac
  m:each(function(x, y) if x >= cut then c:put(x, y, col) end end)
end
local function shadeB(m, col, rows)
  local _, _, _, y1 = bb(m)
  m:each(function(x, y) if y > y1 - rows then c:put(x, y, col) end end)
end
local function lightTL(m, col, rows) -- lit top-left edge band
  local x0, y0 = bb(m)
  m:each(function(x, y) if (x - x0) + (y - y0) < rows then c:put(x, y, col) end end)
end
local function hl(x0, x1, y, col) for x = x0, x1 do c:put(x, y, col) end end
local function vl(x, y0, y1, col) for y = y0, y1 do c:put(x, y, col) end end
local function oct(cx, cy, r, off, sy)
  local pts = {}
  for k = 0, 7 do local a = (k * 45 + (off or 22.5)) * pi / 180; pts[#pts+1] = { cx + r * cos(a), cy + r * sin(a) * (sy or 1) } end
  return PL(pts)
end
local GSH, PSH = "#647a5c", "#a88a7e" -- cool-violet ground shadow on grass / on path
local function shadow(x0, y0, x1, y1, col) F(c:rrect(x0, y0, x1, y1, math.min(4, (y1 - y0) // 2)), col or GSH) end

-- planks: boards of width step (vertical=true) with seams, grain and a lit first column
local function planks(m, rp, step, vertical, seed)
  F(m, rp.base)
  m:each(function(x, y)
    local u = vertical and x or y
    local v = vertical and y or x
    if u % step == 0 then c:put(x, y, rp.shade)
    elseif u % step == 1 then c:put(x, y, rp.hi)
    elseif hsh(u // step, v // 3, seed) < .18 and hsh(x, y, seed + 1) < .5 then c:put(x, y, rp.shade) end
  end)
end
-- shingles: rows of tiles, offset seams, deep row line
local function shingles(m, base, line, lit, rowh, tw, seed)
  F(m, base)
  local x0, y0 = bb(m)
  m:each(function(x, y)
    local r = (y - y0) // rowh
    local yy = (y - y0) % rowh
    if yy == rowh - 1 then c:put(x, y, line)
    elseif (x + r * (tw // 2)) % tw == 0 then c:put(x, y, line)
    elseif yy == 0 and lit then c:put(x, y, lit)
    elseif hsh(x, y, seed) < .05 then c:put(x, y, line) end
  end)
end
local function window(x0, y0, x1, y1, frame, glow)
  local m = R(x0, y0, x1, y1)
  F(m, frame or P.wood.deep)
  local g = R(x0 + 2, y0 + 2, x1 - 2, y1 - 2)
  F(g, glow or P.gold.hi)
  shadeR(g, P.gold.base, .35); shadeB(g, P.gold.base, 2)
  local mx = (x0 + x1) // 2; local my = (y0 + y1) // 2
  vl(mx, y0 + 2, y1 - 2, frame or P.wood.deep); hl(x0 + 2, x1 - 2, my, frame or P.wood.deep)
  c:put(x0 + 3, y0 + 3, P.cream)
  F(R(x0 - 1, y1 + 1, x1 + 1, y1 + 2), P.wood.hi); hl(x0 - 1, x1 + 1, y1 + 2, P.wood.shade)
end
local function lantern(x, ytop, ychain)
  vl(x, ytop, ychain, P.stone.deep)
  for y = ytop, ychain, 2 do c:put(x, y, P.stone.shade) end
  local cap = PL{ { x - 6, ychain + 4 }, { x, ychain }, { x + 6, ychain + 4 } }; F(cap, P.wood.shade); c:edgeIn(cap, P.wood.deep)
  local body = R(x - 5, ychain + 5, x + 5, ychain + 17); F(body, P.wood.deep)
  local glass = R(x - 3, ychain + 6, x + 3, ychain + 15); F(glass, P.gold.hi); shadeR(glass, P.gold.base, .3)
  F(R(x - 1, ychain + 9, x + 1, ychain + 13), P.ember.hi); c:put(x, ychain + 10, P.cream)
  hl(x - 6, x + 6, ychain + 18, P.wood.shade); hl(x - 6, x + 6, ychain + 17, P.wood.deep)
end

---------------------------------------------------------------- sky (late golden afternoon)
c:stripes(0, 99, { "#7fb8e4", "#9fd0f0", "#c4e6f6", "#ffeccd", "#ffdca3", "#ffc98a" }, { 3, 3, 2, 2, 2, 1 })
c:cloud(40, 44, 54, P.cream, "#f5c9b0")
c:cloud(150, 30, 40, P.cream, "#f5c9b0")
c:cloud(300, 40, 60, P.cream, "#f5c9b0")
c:cloud(400, 62, 36, P.cream, "#f5c9b0")
-- warm sun glow (flat rays, no disc)
for i = 0, 3 do hl(330 + i * 6, 380 - i * 6, 74 + i, "#fff0c8") end

---------------------------------------------------------------- far scenery
c:terrain(function(x) return 82 + 5 * sin(x / 37) + 3 * sin(x / 13 + 1) end, "#a9a2cc", HOR)
c:terrain(function(x) return 86 + 4 * sin(x / 29 + 2) + 2 * sin(x / 9) end, "#9590c0", HOR)
c:terrain(function(x) return 94 + 3 * sin(x / 45 + 4) + 2 * sin(x / 17) end, "#a9bb78", HOR)
-- golden fields with furrows converging to the vanishing point
local fieldTop = function(x) return 99 + 1.5 * sin(x / 50) end
local fm = c:terrain(fieldTop, nil, HOR - 1)
local fcols = { P.gold.hi, P.gold.base, "#e8c96a", "#f0d67e", "#c9c46a" }
fm:each(function(x, y)
  local u = (x - 240) / (y - 86)
  local k = floor(u * 1.4 + 20)
  local col = fcols[k % #fcols + 1]
  if ((u * 7) % 1) < .14 then col = P.gold.shade end
  c:put(x, y, col)
end)
-- hedgerow along the field edge + far trees + wheat stooks
for x = 0, W - 1 do local t = rd(fieldTop(x)) - 1 - ((hsh(x // 3, 1, 7) < .5) and 1 or 0); vl(x, t, rd(fieldTop(x)), "#6f8f52") end
local trees = { 60, 118, 205, 268, 352, 430 }
for i, tx in ipairs(trees) do
  local tm = PL{ { tx - 7, 98 }, { tx - 8, 92 }, { tx - 4, 86 }, { tx + 3, 85 }, { tx + 8, 90 }, { tx + 7, 98 } }
  F(tm, "#7a9a5a"); shadeR(tm, "#5f7f52", .4); c:edgeIn(tm, "#4f6a4a")
  vl(tx, 98, 101, P.wood.shade)
end
for _, sx in ipairs({ 140, 170, 300, 322, 392, 450, 24 }) do
  local st = PL{ { sx - 3, 109 }, { sx, 102 }, { sx + 3, 109 } }; F(st, P.gold.base); c:edgeIn(st, P.gold.shade)
end

---------------------------------------------------------------- ground
for y = HOR, H - 1 do
  local col = (y < 124 and "#b8c46a") or (y < 150 and "#a8c060") or (y < 200 and "#97b65a") or "#8aad54"
  hl(0, W - 1, y, col)
end
local gm = R(0, HOR, W - 1, H - 1)
tex(gm, "#7aa250", .05, 11)
tex(gm, "#c4cf74", .03, 12)
gm:each(function(x, y) if y > 118 and hsh(x, y, 13) < .008 then c:put(x, y, "#5f8a4a"); c:put(x - 1, y - 1, "#7aa250"); c:put(x + 1, y - 1, "#7aa250") end end)
gm:each(function(x, y) if y > 170 and hsh(x, y, 14) < .0025 then c:put(x, y, (hsh(x, y, 15) < .5) and P.gold.hi or P.petal.hi) end end)

---------------------------------------------------------------- path (flour-dusted dirt road)
local function L(y) return 228 - (y - HOR) * 80 / 158 end
local function Rr(y) return 252 + (y - HOR) * 80 / 158 end
local path = PL{ { 228, HOR }, { 252, HOR }, { 332, H - 1 }, { 148, H - 1 } }
F(path, "#dcb98a")
tex(path, "#c49d72", .07, 21)
tex(path, "#ecd3a8", .06, 22)
for y = HOR + 2, H - 1 do
  local d = (y - HOR) * .3
  for _, s in ipairs({ -1, 1 }) do
    local x = rd(240 + s * d)
    c:put(x, y, "#b98f68"); if y > 170 then c:put(x + s, y, "#b98f68") end
  end
  if hsh(1, y, 23) < .5 then c:put(rd(L(y)), y, "#9c7a5a") end
  if hsh(2, y, 23) < .5 then c:put(rd(Rr(y)), y, "#9c7a5a") end
end
-- edge pebbles
for y = 120, H - 1, 7 do
  for _, ex in ipairs({ L(y) - 2, Rr(y) + 2 }) do
    local pm = R(rd(ex) - 1, y, rd(ex) + 1, y + 1); F(pm, P.stone.hi); c:put(rd(ex) + 1, y + 1, P.stone.shade)
  end
end
-- flour dust patches (the yard by the mill side)
local function flour(cx, cy, rx, ry, seed)
  local fmk = c:poly{ { cx - rx, cy }, { cx - rx // 2, cy - ry }, { cx + rx // 2, cy - ry }, { cx + rx, cy }, { cx + rx // 2, cy + ry }, { cx - rx // 2, cy + ry } }
  fmk:each(function(x, y) local v = hsh(x, y, seed); if v < .6 then c:put(x, y, "#f6e6c4") elseif v < .8 then c:put(x, y, P.cream) end end)
end
flour(214, 178, 16, 5, 31); flour(226, 196, 12, 4, 32); flour(202, 230, 14, 4, 33); flour(236, 128, 10, 3, 34)
-- quirk: tiny gnome footprints in the flour
for i = 0, 4 do
  local fx, fy = 206 + i * 5, 182 + i * 4 - (i % 2) * 2
  F(R(fx, fy, fx + 1, fy + 2), "#c49d72"); c:put(fx, fy - 1, "#c49d72")
end

---------------------------------------------------------------- stream
local function sTop(x) if x < 240 then return 146 + sin(x / 23) else return 146 + (x - 240) * .11 + sin(x / 23) end end
local stream = HP.mask()
for x = 0, W - 1 do local t = rd(sTop(x)); for y = t, t + 13 do stream:set(x, y) end end
stream:each(function(x, y)
  local t = rd(sTop(x)); local d = y - t
  local col = (d <= 0 and "#6e5a48") or (d <= 2 and P.sea.shade) or (d >= 13 and "#7a6250") or P.sea.base
  c:put(x, y, col)
end)
stream:each(function(x, y)
  local t = rd(sTop(x)); local d = y - t
  if d > 3 and d < 12 then
    local v = hsh((x + y * 3) // 5, y, 41)
    if v < .16 then c:put(x, y, P.sea.hi) elseif v > .9 then c:put(x, y, P.sea.shade) end
  end
end)
-- grass lip over the far bank
for x = 0, W - 1 do local t = rd(sTop(x)); if hsh(x, 0, 42) < .4 then c:put(x, t - 1, "#7aa250") end end

---------------------------------------------------------------- bridge over the stream (on the road)
local bt, bb2 = 140, 166
local deck = PL{ { L(bt) - 8, bt }, { Rr(bt) + 8, bt }, { Rr(bb2) + 9, bb2 }, { L(bb2) - 9, bb2 } }
shadow(rd(L(bb2)) - 10, bb2 - 1, rd(Rr(bb2)) + 10, bb2 + 4, "#5e6b6e")
F(deck, P.wood.base)
deck:each(function(x, y)
  local r = (y - bt) % 5
  if r == 4 then c:put(x, y, P.wood.shade) elseif r == 0 then c:put(x, y, P.wood.hi)
  elseif hsh(x // 4, y // 5, 51) < .2 and hsh(x, y, 52) < .5 then c:put(x, y, P.wood.shade) end
end)
deck:each(function(x, y) if hsh(x, y, 53) < .06 then c:put(x, y, "#f6e6c4") end end) -- flour on planks
c:edgeIn(deck, P.wood.deep)
F(R(rd(L(bb2)) - 9, bb2 + 1, rd(Rr(bb2)) + 9, bb2 + 3), P.wood.shade); hl(rd(L(bb2)) - 9, rd(Rr(bb2)) + 9, bb2 + 3, P.wood.deep)
-- rails (receding) with posts
for _, s in ipairs({ -1, 1 }) do
  local xa = s < 0 and L(bt) - 7 or Rr(bt) + 7
  local xb = s < 0 and L(bb2) - 8 or Rr(bb2) + 8
  local rail = LN({ { xa, bt - 8 }, { xb, bb2 - 12 } }, 3); F(rail, P.wood.hi); c:edgeIn(rail, P.wood.deep)
  for _, t in ipairs({ 0, .5, 1 }) do
    local px = rd(xa + (xb - xa) * t); local py0 = rd(bt - 9 + (bb2 - 12 - bt + 8) * t)
    local ph = 10 + rd(4 * t)
    local post = R(px - 1, py0, px + 1 + rd(t), py0 + ph); F(post, P.wood.shade); c:edgeIn(post, P.wood.deep); vl(px, py0 + 1, py0 + ph - 1, P.wood.base)
  end
end

---------------------------------------------------------------- MILL (spot do)
shadow(14, 136, 118, 144)
-- stone foundation
local found = R(18, 116, 112, 141)
F(found, P.stone.base)
found:each(function(x, y)
  local r = (y - 116) // 6
  if (y - 116) % 6 == 5 or (x + r * 6) % 12 == 0 then c:put(x, y, P.stone.shade)
  elseif (y - 116) % 6 == 0 then c:put(x, y, P.stone.hi)
  elseif hsh(x, y, 61) < .06 then c:put(x, y, P.stone.shade) end
end)
shadeR(found, P.stone.shade, .12); tex(R(90, 116, 112, 141), P.stone.deep, .04, 62)
found:each(function(x, y) if y > 136 and hsh(x, y, 63) < .3 then c:put(x, y, P.moss.shade) end end) -- damp moss
c:edgeIn(found, P.stone.deep)
-- timber walls
local wall = R(22, 64, 108, 115)
planks(wall, P.wood, 6, true, 64)
shadeR(wall, P.wood.shade, .22)
F(R(22, 88, 108, 90), P.wood.deep); hl(22, 108, 88, P.wood.shade)
F(R(22, 64, 108, 66), P.wood.deep)
c:edgeIn(wall, P.wood.deep)
-- roof (blue-teal shingles)
local roof = PL{ { 10, 70 }, { 65, 24 }, { 120, 70 } }
shingles(roof, P.sea.shade, P.sea.deep, P.sea.base, 5, 10, 65)
roof:each(function(x, y) if x < 65 - (y - 24) * .35 and (y - 24) % 5 ~= 4 then c:put(x, y, P.sea.base) end end)
roof:each(function(x, y) if y >= 66 then c:put(x, y, P.sea.deep) end end)
c:edgeIn(roof, P.sea.deep)
-- loft window + hoist beam with a dangling sack
window(57, 42, 73, 56)
local beam = R(62, 34, 92, 37); F(beam, P.wood.base); c:edgeIn(beam, P.wood.deep)
vl(89, 38, 50, P.stone.deep)
local hs = c:rrect(84, 50, 95, 62, 3); F(hs, "#efe0c0"); shadeR(hs, "#cdb894", .35); c:edgeIn(hs, "#9a8268"); hl(86, 93, 52, "#9a8268")
-- weathervane: a loaf of bread (quirk)
vl(65, 13, 24, P.stone.deep)
local loaf = c:rrect(55, 8, 75, 15, 3); F(loaf, P.gold.shade); lightTL(loaf, P.gold.base, 6); c:edgeIn(loaf, P.wood.deep)
for i = 0, 2 do hl(59 + i * 5, 61 + i * 5, 10, P.gold.hi) end
-- windows
window(30, 72, 46, 86); window(84, 72, 100, 86)
-- big barn door
local door = R(54, 96, 78, 115)
planks(door, { hi = P.ember.shade, base = P.ember.shade, shade = P.ember.deep }, 5, true, 66)
F(LN({ { 56, 98 }, { 76, 113 } }, 2), P.wood.hi); F(LN({ { 76, 98 }, { 56, 113 } }, 2), P.wood.hi)
c:edgeIn(door, P.ember.deep)
F(R(52, 116, 80, 118), P.stone.hi); hl(52, 80, 118, P.stone.shade)
-- mill sign: wheat icon on a gold board
local sb = R(52, 91, 80, 98); -- board overlaps door top band slightly: draw door frame above
sb = R(50, 90, 82, 95)
local sign = R(54, 68, 78, 85)
F(sign, P.gold.base); lightTL(sign, P.gold.hi, 5); shadeR(sign, P.gold.shade, .2); c:edgeIn(sign, P.gold.deep)
vl(66, 71, 83, P.gold.deep)
for i = 0, 3 do c:put(64, 72 + i * 3, P.gold.deep); c:put(65, 72 + i * 3, P.gold.deep); c:put(67, 72 + i * 3, P.gold.deep); c:put(68, 72 + i * 3, P.gold.deep)
  c:put(63, 73 + i * 3, P.gold.deep); c:put(69, 73 + i * 3, P.gold.deep) end
-- quirk: tiny gnome door in the foundation
local gd = c:rrect(90, 124, 101, 141, 4); F(gd, P.petal.shade); lightTL(gd, P.petal.base, 4); c:edgeIn(gd, P.petal.deep)
c:put(98, 133, P.gold.hi); vl(95, 126, 140, P.petal.deep)
-- sacks by the wall
for i, sx in ipairs({ 26, 38 }) do
  local sk = c:rrect(sx, 104, sx + 11, 116, 3); F(sk, "#efe0c0"); shadeR(sk, "#cdb894", .35); c:edgeIn(sk, "#9a8268"); hl(sx + 3, sx + 8, 106, "#9a8268")
end

---------------------------------------------------------------- WATERWHEEL (part of do)
local WX, WY, WRr = 144, 124, 27
F(R(108, 122, 140, 127), P.wood.deep)
local outer = oct(WX, WY, WRr, 22.5); local inner = oct(WX, WY, WRr - 6, 22.5)
local ring = outer:copy():cut(inner)
-- spokes first
for k = 0, 3 do
  local a = (k * 45 + 22.5) * pi / 180
  local sp = LN({ { WX - (WRr - 4) * cos(a), WY - (WRr - 4) * sin(a) }, { WX + (WRr - 4) * cos(a), WY + (WRr - 4) * sin(a) } }, 3)
  F(sp, P.wood.base); c:edgeIn(sp, P.wood.shade)
end
F(ring, P.wood.shade)
ring:each(function(x, y) if (x - WX) + (y - WY) < -10 then c:put(x, y, P.wood.base) end end)
ring:each(function(x, y) if hsh(x, y, 71) < .1 then c:put(x, y, P.wood.deep) end end)
c:edgeIn(outer, P.wood.deep); c:edgeIn(inner:grow(1), P.wood.deep)
-- paddles
for k = 0, 7 do
  local a = (k * 45) * pi / 180
  local pd = LN({ { WX + (WRr - 2) * cos(a), WY + (WRr - 2) * sin(a) }, { WX + (WRr + 6) * cos(a), WY + (WRr + 6) * sin(a) } }, 5)
  F(pd, P.wood.hi); shadeR(pd, P.wood.base, .4); c:edgeIn(pd, P.wood.deep)
end
local hub = R(WX - 5, WY - 5, WX + 5, WY + 5); F(hub, P.stone.shade); lightTL(hub, P.stone.base, 5); c:edgeIn(hub, P.stone.deep); c:put(WX - 2, WY - 2, P.stone.hi)
-- splash where the wheel meets the water
for i = 0, 40 do
  local x = WX - 22 + floor(hsh(i, 1, 72) * 44); local y = 146 + floor(hsh(i, 2, 72) * 8)
  c:put(x, y, (i % 3 == 0) and P.cream or P.sea.hi)
end
-- quirk: a flower pot riding the top paddle
local fp = R(WX - 4, WY - 45, WX + 4, WY - 37); F(fp, P.ember.shade); lightTL(fp, P.ember.base, 4); c:edgeIn(fp, P.ember.deep); hl(WX - 5, WX + 5, WY - 45, P.ember.deep)
vl(WX, WY - 52, WY - 46, P.moss.shade); vl(WX - 3, WY - 50, WY - 46, P.moss.shade)
F(R(WX - 2, WY - 55, WX + 2, WY - 52), P.petal.base); c:put(WX, WY - 54, P.gold.hi)
F(R(WX - 5, WY - 52, WX - 2, WY - 50), P.petal.hi)

---------------------------------------------------------------- GRAIN STORE (part of do) on staddle stones
shadow(182, 116, 220, 120)
for _, sx in ipairs({ 189, 200, 211 }) do
  local stem = R(sx - 1, 106, sx + 1, 117); F(stem, P.stone.base); c:edgeIn(stem, P.stone.deep)
  local cap = c:rrect(sx - 5, 102, sx + 5, 106, 2); F(cap, P.stone.hi); shadeB(cap, P.stone.shade, 2); c:edgeIn(cap, P.stone.deep)
end
local gs = R(184, 76, 216, 101)
planks(gs, { hi = "#f0cf8e", base = "#d9a95c", shade = "#a87640" }, 4, false, 73)
shadeR(gs, "#a87640", .2); c:edgeIn(gs, "#6e4a2a")
local gdoor = R(195, 84, 205, 101); F(gdoor, P.wood.shade); c:edgeIn(gdoor, P.wood.deep); vl(200, 85, 100, P.wood.deep); c:put(203, 92, P.gold.hi)
local groof = PL{ { 178, 80 }, { 200, 56 }, { 222, 80 } }
F(groof, P.gold.base)
groof:each(function(x, y)
  if (x + (y // 3)) % 4 == 0 then c:put(x, y, P.gold.shade) elseif hsh(x, y, 74) < .15 then c:put(x, y, P.gold.hi) end
  if x > 200 + (y - 56) * .2 and hsh(x, y, 75) < .5 then c:put(x, y, P.gold.shade) end
end)
hl(178, 222, 79, P.gold.deep); hl(179, 221, 78, P.gold.shade); c:edgeIn(groof, P.gold.deep)
-- quirk: a kite snagged on the granary roof
local kite = PL{ { 214, 52 }, { 221, 58 }, { 214, 68 }, { 207, 58 } }
F(kite, P.petal.base); kite:each(function(x, y) if x >= 214 and y < 58 then c:put(x, y, P.sky.hi) end if x < 214 and y >= 58 then c:put(x, y, P.sky.base) end end)
vl(214, 53, 67, P.petal.deep); hl(208, 220, 58, P.petal.deep); c:edgeIn(kite, P.petal.deep)
local tail = { { 214, 69 }, { 217, 72 }, { 215, 75 }, { 219, 78 }, { 222, 77 } }
F(LN(tail, 1), P.stone.deep)
for _, b in ipairs({ { 216, 72 }, { 218, 78 } }) do F(R(b[1] - 1, b[2] - 1, b[1] + 1, b[2]), P.gold.base) end

---------------------------------------------------------------- flour sacks by the bridge (part of do)
shadow(180, 138, 214, 143)
local sacks = { { 182, 126 }, { 196, 126 }, { 189, 115 } }
for i, s in ipairs(sacks) do
  local sk = c:rrect(s[1], s[2], s[1] + 14, s[2] + 14, 4)
  F(sk, "#f2e4c4"); shadeR(sk, "#d2bd96", .35); shadeB(sk, "#d2bd96", 3); c:edgeIn(sk, "#9a8268")
  hl(s[1] + 4, s[1] + 10, s[2] + 2, "#9a8268"); c:put(s[1] + 3, s[2] + 4, P.cream)
  F(R(s[1] + 5, s[2] + 7, s[1] + 9, s[2] + 9), P.gold.base) -- wheat stamp
end
-- split sack spill: flour puff
for i = 0, 26 do
  local x = 208 + floor(hsh(i, 3, 76) * 12); local y = 132 + floor(hsh(i, 4, 76) * 10)
  c:put(x, y, (i % 2 == 0) and P.cream or "#f6e6c4")
end

---------------------------------------------------------------- HOMES (spot homes)
-- cottage A: plaster + timber, pink roof
shadow(274, 134, 334, 140)
local wa = R(280, 98, 326, 137)
F(wa, "#f3e3c3"); tex(wa, "#e2cfa8", .1, 81); shadeR(wa, "#d9c2a0", .22)
for _, x in ipairs({ 280, 303, 326 }) do vl(x, 98, 137, P.wood.shade); vl(x + 1, 98, 137, P.wood.shade) end
hl(280, 326, 117, P.wood.shade); hl(280, 326, 116, P.wood.shade)
F(LN({ { 282, 118 }, { 301, 136 } }, 1), P.wood.shade)
c:edgeIn(wa, P.wood.deep)
local ra = PL{ { 272, 101 }, { 303, 70 }, { 334, 101 } }
shingles(ra, P.petal.shade, P.petal.deep, P.petal.base, 4, 8, 82)
ra:each(function(x, y) if x < 303 - (y - 70) * .3 and (y - 70) % 4 ~= 3 then c:put(x, y, P.petal.base) end end)
c:edgeIn(ra, P.petal.deep)
local ch = R(314, 72, 321, 88); F(ch, P.stone.base); shadeR(ch, P.stone.shade, .35); c:edgeIn(ch, P.stone.deep); hl(313, 322, 72, P.stone.deep)
for i, p in ipairs({ { 318, 66 }, { 321, 61 }, { 317, 56 } }) do F(R(p[1], p[2], p[1] + 2 + i % 2, p[2] + 2), "#e8e4ee") end
window(284, 104, 296, 114); window(310, 104, 322, 114)
for _, x in ipairs({ 283, 309 }) do local fb = R(x, 117, x + 14, 120); F(fb, P.wood.shade); c:edgeIn(fb, P.wood.deep); for k = 0, 4 do c:put(x + 2 + k * 3, 116, (k % 2 == 0) and P.petal.hi or P.gold.hi) end end
local da = R(296, 122, 309, 137); F(da, P.moss.shade); lightTL(da, P.moss.base, 4); c:edgeIn(da, P.moss.deep); c:put(306, 130, P.gold.hi)
F(R(294, 136, 311, 138), P.stone.hi); hl(294, 311, 138, P.stone.shade)
-- homes icon sign (little house on a sea-blue board)
local hsn = R(296, 102, 309, 118); -- placeholder area check
local hb = R(297, 85, 309, 96); F(hb, P.sea.base); c:edgeIn(hb, P.sea.deep)
F(PL{ { 299, 91 }, { 303, 87 }, { 307, 91 } }, P.cream); F(R(300, 91, 306, 94), P.cream); F(R(302, 92, 304, 94), P.sea.deep)
vl(300, 80, 84, P.stone.deep); vl(306, 80, 84, P.stone.deep)
-- cottage B: stone walls, mossy turf roof with flowers
shadow(340, 132, 400, 138)
local wb = R(346, 104, 392, 135)
F(wb, P.stone.hi)
wb:each(function(x, y)
  local r = (y - 104) // 5
  if (y - 104) % 5 == 4 or (x + r * 4) % 9 == 0 then c:put(x, y, P.stone.base) elseif hsh(x, y, 83) < .05 then c:put(x, y, P.stone.base) end
end)
shadeR(wb, P.stone.shade, .2); c:edgeIn(wb, P.stone.deep)
local rb = PL{ { 340, 106 }, { 352, 84 }, { 386, 84 }, { 398, 106 } }
F(rb, P.moss.base)
rb:each(function(x, y)
  local v = hsh(x // 2, y // 2, 84)
  if v < .25 then c:put(x, y, P.moss.shade) elseif v > .85 then c:put(x, y, P.moss.hi) end
  if x > 380 - (y - 84) * 0 and x > 378 and hsh(x, y, 85) < .6 then c:put(x, y, P.moss.shade) end
end)
for i = 0, 14 do local x = 350 + floor(hsh(i, 1, 86) * 38); local y = 86 + floor(hsh(i, 2, 86) * 16); if rb:has(x, y) then c:put(x, y, (i % 3 == 0) and P.petal.hi or P.gold.hi) end end
hl(340, 398, 105, P.moss.deep); c:edgeIn(rb, P.moss.deep)
window(352, 112, 364, 122); window(376, 112, 388, 122)
local db = c:rrect(365, 116, 374, 135, 3); F(db, P.wood.base); planks(db, P.wood, 3, true, 87); c:edgeIn(db, P.wood.deep); c:put(372, 126, P.gold.hi)
F(R(367, 119, 372, 122), P.gold.hi)

---------------------------------------------------------------- WILD TRAIL arch (spot wild), right edge
local hedge = PL{ { 410, 162 }, { 409, 124 }, { 413, 112 }, { 420, 106 }, { 430, 102 }, { 442, 101 }, { 452, 104 }, { 460, 110 }, { 465, 120 }, { 465, 162 } }
F(hedge, P.moss.shade)
hedge:each(function(x, y)
  local v = hsh(x // 3, y // 3, 91)
  if v < .3 then c:put(x, y, P.moss.base) elseif v > .85 then c:put(x, y, P.moss.deep) end
  if (x - 410) + (y - 100) < 28 and hsh(x, y, 92) < .5 then c:put(x, y, P.moss.hi) end
end)
local opening = c:rrect(424, 120, 450, 162, 10)
F(opening, "#3f6a50")
opening:each(function(x, y) if y > 146 then c:put(x, y, "#c9a878") end if y > 140 and y <= 146 then c:put(x, y, "#5f8a5a") end end)
F(PL{ { 432, 147 }, { 442, 147 }, { 450, 162 }, { 424, 162 } }, "#d9b483") -- trail inside, leading off right
F(PL{ { 445, 128 }, { 450, 124 }, { 450, 146 }, { 446, 146 } }, P.gold.hi) -- light from beyond
c:edgeIn(opening, P.moss.deep)
c:edgeIn(hedge, P.moss.deep)
for i = 0, 18 do local x = 410 + floor(hsh(i, 1, 93) * 54); local y = 104 + floor(hsh(i, 2, 93) * 56); if hedge:has(x, y) and not opening:grow(1):has(x, y) then c:put(x, y, P.dusk.hi); c:put(x + 1, y, P.dusk.base) end end
-- stepping stones across the stream to the arch
for i, st in ipairs({ { 428, 166 }, { 440, 172 }, { 430, 179 } }) do
  local sm = c:rrect(st[1] - 5, st[2] - 2, st[1] + 5, st[2] + 2, 2); F(sm, P.stone.hi); shadeB(sm, P.stone.base, 2); c:edgeIn(sm, P.stone.deep)
end
-- wild signpost with leaf arrow pointing right
local wp = R(414, 128, 417, 162); F(wp, P.wood.base); vl(414, 129, 161, P.wood.hi); c:edgeIn(wp, P.wood.deep)
local arrow = PL{ { 404, 130 }, { 428, 130 }, { 434, 136 }, { 428, 142 }, { 404, 142 } }
F(arrow, P.wood.hi); shadeB(arrow, P.wood.base, 3); c:edgeIn(arrow, P.wood.deep)
local leaf = PL{ { 410, 136 }, { 416, 132 }, { 424, 132 }, { 428, 136 }, { 422, 140 }, { 414, 140 } }
F(leaf, P.moss.base); hl(412, 426, 136, P.moss.deep); c:edgeIn(leaf, P.moss.deep)

---------------------------------------------------------------- STOP: notice board + stamp post (spot stop), near left
shadow(24, 234, 126, 242)
for _, px in ipairs({ 34, 96 }) do local pm = R(px, 186, px + 4, 238); F(pm, P.wood.base); vl(px + 1, 187, 237, P.wood.hi); shadeR(pm, P.wood.shade, .3); c:edgeIn(pm, P.wood.deep) end
local brd = R(28, 184, 104, 224)
F(brd, P.wood.shade); c:edgeIn(brd, P.wood.deep)
local cork = R(32, 188, 100, 220)
F(cork, "#c98f5a"); tex(cork, "#b47a48", .18, 101); tex(cork, "#dca46e", .08, 102); c:edgeIn(cork, "#8a5a36")
local notes = { { 37, 192, 52, 207, P.cream, "#cdb894" }, { 57, 191, 72, 203, P.sky.hi, P.sky.shade }, { 77, 193, 95, 210, P.petal.hi, P.petal.shade },
  { 40, 210, 58, 218, P.gold.hi, P.gold.shade }, { 63, 206, 81, 218, P.moss.hi, P.moss.shade } }
for i, n in ipairs(notes) do
  local nm = R(n[1], n[2], n[3], n[4]); F(nm, n[5]); c:edgeIn(nm, n[6])
  for yy = n[2] + 4, n[4] - 3, 3 do hl(n[1] + 3, n[3] - 3 - ((yy * 7 + i) % 5), yy, n[6]) end
  F(R((n[1] + n[3]) // 2 - 1, n[2] - 1, (n[1] + n[3]) // 2, n[2]), P.ember.base)
end
-- little map note with a dotted route (quirk-free decoration)
local broof = PL{ { 22, 186 }, { 66, 168 }, { 110, 186 } }
shingles(broof, P.ember.shade, P.ember.deep, P.ember.base, 4, 8, 103)
broof:each(function(x, y) if x < 66 - (y - 168) * .5 and (y - 168) % 4 ~= 3 then c:put(x, y, P.ember.base) end end)
c:edgeIn(broof, P.ember.deep)
-- stamp post
local sp = R(112, 196, 117, 238); F(sp, P.wood.base); vl(113, 197, 237, P.wood.hi); c:edgeIn(sp, P.wood.deep)
local sbx = R(105, 180, 124, 197); F(sbx, P.ember.base); lightTL(sbx, P.ember.hi, 5); shadeR(sbx, P.ember.shade, .25); c:edgeIn(sbx, P.ember.deep)
-- stamp icon (handle knob, neck, base) in gold
F(R(112, 183, 117, 186), P.gold.hi); F(R(113, 187, 116, 189), P.gold.base); F(R(109, 190, 120, 194), P.gold.base); hl(109, 120, 194, P.gold.deep); c:put(112, 183, P.cream)
-- quirk: an ink-pad with a paper boat stamped on the post foot
local inkp = R(119, 232, 126, 236); F(inkp, P.dusk.shade); c:edgeIn(inkp, P.dusk.deep)

---------------------------------------------------------------- PEOPLE: fire pit + long table (spot people), near right
-- warm glow on the ground
local glow = c:poly{ { 318, 222 }, { 326, 212 }, { 352, 212 }, { 360, 222 }, { 352, 232 }, { 326, 232 } }
glow:each(function(x, y) if hsh(x, y, 111) < .7 then c:put(x, y, "#c8c66a") end end)
shadow(346, 214, 406, 230)
-- fire pit stones
for i, s in ipairs({ { 324, 222 }, { 331, 225 }, { 339, 226 }, { 347, 225 }, { 354, 222 }, { 333, 218 }, { 345, 218 } }) do
  local sm = c:rrect(s[1] - 4, s[2] - 3, s[1] + 4, s[2] + 3, 2); F(sm, P.stone.base); lightTL(sm, P.stone.hi, 4); shadeB(sm, P.stone.shade, 2); c:edgeIn(sm, P.stone.deep)
end
local logs = LN({ { 330, 220 }, { 348, 214 } }, 3); F(logs, P.wood.shade); c:edgeIn(logs, P.wood.deep)
local fl = PL{ { 330, 220 }, { 332, 208 }, { 336, 213 }, { 339, 198 }, { 343, 210 }, { 346, 204 }, { 349, 220 } }
F(fl, P.ember.base); c:edgeIn(fl, P.ember.shade)
local fi = PL{ { 335, 219 }, { 338, 208 }, { 341, 214 }, { 343, 210 }, { 345, 219 } }; F(fi, P.gold.base)
F(R(338, 214, 342, 219), P.gold.hi)
-- lantern-string poles + bunting lights
for _, px in ipairs({ 320, 402 }) do local pm = R(px - 1, 184, px + 1, 230); F(pm, P.wood.base); c:edgeIn(pm, P.wood.deep) end
local prev
for x = 321, 401 do local y = rd(186 + 7 * sin((x - 321) / 80 * pi)); c:put(x, y, P.stone.deep); prev = y end
local lc = { P.gold.hi, P.petal.base, P.sea.base, P.gold.hi, P.moss.hi }
for i = 0, 4 do local x = 330 + i * 15; local y = rd(186 + 7 * sin((x - 321) / 80 * pi)); local lm = R(x - 2, y + 1, x + 2, y + 5); F(lm, lc[i + 1]); c:edgeIn(lm, P.wood.deep) end
-- hanging sign with a mug icon
vl(368, 193, 196, P.stone.deep)
-- long table with checked cloth
local tt = R(352, 197, 400, 203); F(tt, P.wood.hi); c:edgeIn(tt, P.wood.deep)
for _, lx in ipairs({ 356, 395 }) do local lg = R(lx, 210, lx + 3, 222); F(lg, P.wood.shade); c:edgeIn(lg, P.wood.deep) end
local cloth = R(352, 202, 400, 212)
cloth:each(function(x, y) local a = ((x - 352) // 4 + (y - 202) // 3) % 2; c:put(x, y, a == 0 and P.ember.base or P.cream) end)
shadeR(cloth, P.ember.shade, .15); c:edgeIn(cloth, P.ember.deep)
-- mugs, bowl and loaf on the table
for _, mx in ipairs({ 358, 388 }) do local mg = R(mx, 191, mx + 5, 197); F(mg, P.sea.base); shadeR(mg, P.sea.shade, .4); c:edgeIn(mg, P.sea.deep); vl(mx + 6, 193, 195, P.sea.deep) end
local bowl = c:rrect(368, 192, 380, 197, 2); F(bowl, P.gold.shade); hl(369, 379, 192, P.gold.hi); c:edgeIn(bowl, P.gold.deep)
-- bench in front
local bench = R(350, 222, 402, 226); F(bench, P.wood.base); hl(351, 401, 223, P.wood.hi); c:edgeIn(bench, P.wood.deep)
for _, lx in ipairs({ 354, 396 }) do local lg = R(lx, 227, lx + 2, 231); F(lg, P.wood.shade); c:edgeIn(lg, P.wood.deep) end
-- people sign (gathering): mug icon board hanging on the left pole
local psb = R(322, 188, 336, 199); F(psb, P.petal.base); lightTL(psb, P.petal.hi, 4); c:edgeIn(psb, P.petal.deep)
F(R(326, 191, 331, 196), P.cream); vl(332, 192, 194, P.cream); hl(326, 331, 196, P.petal.deep)

---------------------------------------------------------------- hand cart with sacks (scenery), right
shadow(410, 222, 462, 228)
local shaft = LN({ { 456, 206 }, { 464, 224 } }, 2); F(shaft, P.wood.shade); c:edgeIn(shaft, P.wood.deep)
local bed = R(414, 202, 456, 214)
planks(bed, { hi = P.sea.hi, base = P.sea.base, shade = P.sea.shade }, 5, false, 121); shadeR(bed, P.sea.shade, .25); c:edgeIn(bed, P.sea.deep)
for i, s in ipairs({ { 417, 190 }, { 430, 192 }, { 442, 190 } }) do
  local sk = c:rrect(s[1], s[2], s[1] + 12, s[2] + 12, 3); F(sk, "#f2e4c4"); shadeR(sk, "#d2bd96", .35); c:edgeIn(sk, "#9a8268"); hl(s[1] + 3, s[1] + 9, s[2] + 2, "#9a8268")
end
local wh = oct(428, 218, 9, 22.5); F(wh, P.wood.shade); c:edgeIn(wh, P.wood.deep)
local whi = oct(428, 218, 5, 22.5); F(whi, P.wood.base); c:edgeIn(whi, P.wood.deep)
F(R(427, 217, 429, 219), P.stone.shade)
vl(428, 210, 226, P.wood.deep); hl(420, 436, 218, P.wood.deep)

---------------------------------------------------------------- GATE FRAME (timber + wheat), lanterns, charm
local function post(x0, x1)
  local pm = R(x0, 0, x1, H - 1)
  planks(pm, P.wood, 7, true, 131)
  pm:each(function(x, y) if y % 36 == 0 then c:put(x, y, P.wood.deep) end end)
  shadeR(pm, P.wood.shade, .3); c:edgeIn(pm, P.wood.deep)
  -- ivy wrap
  for y = 20, H - 1, 22 do local lv = PL{ { x0 + 2, y }, { x0 + 7, y - 4 }, { x1 - 1, y }, { x0 + 7, y + 4 } }; F(lv, P.moss.base); c:edgeIn(lv, P.moss.deep) end
end
post(0, 13); post(466, 479)
local top = R(0, 0, W - 1, 11)
planks(top, P.wood, 6, false, 132)
top:each(function(x, y) if x % 48 == 0 then c:put(x, y, P.wood.deep) end end)
c:edgeIn(top, P.wood.deep)
for _, s in ipairs({ { 14, 1 }, { 465, -1 } }) do
  local x0 = s[1]
  local knee = PL{ { x0, 12 }, { x0 + 18 * s[2], 12 }, { x0, 30 } }
  F(knee, P.wood.base); shadeB(knee, P.wood.shade, 4); c:edgeIn(knee, P.wood.deep)
end
-- wheat garland along the beam
for x = 20, 460, 9 do
  local yy = 12 + rd(3 * sin((x - 20) / 440 * pi * 3) + 3)
  F(R(x, yy, x + 2, yy + 3), P.gold.base); c:put(x, yy, P.gold.hi); c:put(x + 1, yy + 4, P.gold.shade)
end
lantern(36, 12, 22); lantern(444, 12, 22)
-- charm: hanging wheat sheaf with a red ribbon
vl(240, 12, 18, P.stone.deep)
for k = -3, 3 do F(LN({ { 240, 34 }, { 240 + k * 2, 22 } }, 1), P.gold.shade) end
for k = -3, 3 do local gx = 240 + k * 2; F(R(gx - 1, 18 + math.abs(k), gx + 1, 23 + math.abs(k)), P.gold.base); c:put(gx - 1, 18 + math.abs(k), P.gold.hi) end
F(R(237, 28, 243, 30), P.ember.base); c:put(236, 31, P.ember.shade); c:put(244, 31, P.ember.shade)

---------------------------------------------------------------- save + layout
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
local spots = {
  { k = "do", name = "Watermill", box = { 16, 4, 222, 162 } },
  { k = "people", name = "Fireside Table", box = { 316, 184, 406, 232 } },
  { k = "stop", name = "Stamp Post", box = { 20, 166, 128, 242 } },
  { k = "homes", name = "Miller's Cottages", box = { 270, 54, 400, 141 } },
  { k = "wild", name = "Wild Trail", box = { 404, 98, 465, 182 } },
}
local stand = { { 194, 252 }, { 286, 252 }, { 240, 210 }, { 156, 192 }, { 346, 252 }, { 100, 258 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts+1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name, (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st+1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":%d,"h":%d,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', W, H, HOR, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok " .. NAME)
