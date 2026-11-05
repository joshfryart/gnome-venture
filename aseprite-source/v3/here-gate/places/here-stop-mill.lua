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

---------------------------------------------------------------- v2.5.40 polish pass 4a: atmospheric perspective + tree variety
-- haze: far hills melt into warm mist near the field edge (dither bands, cooler/lighter with distance)
for y = 86, 98 do for x = 0, W - 1 do
  local k = (98 - y) / 12
  if ((x + y) % 2 == 0 and hsh(x, y, 601) < .25 + .45 * (1 - k) * (y > 92 and 1 or .4)) and y < rd(fieldTop(x)) then c:put(x, y, (y < 92) and "#c4c0dc" or "#e4dcc0") end
end end
-- tree variety on the far hedgerow: poplar, orchard tree with fruit, dark cypress
do
  local pop = PL{ { 118, 98 }, { 115, 90 }, { 116, 80 }, { 118, 72 }, { 120, 80 }, { 121, 90 }, { 121, 98 } }
  F(pop, "#86a05c"); shadeR(pop, "#5f7f52", .45); c:edgeIn(pop, "#4f6a4a"); vl(118, 74, 94, "#9db46c")
  local ot = c:ellipse(268, 90, 10, 8); F(ot, "#8aaa58"); shadeR(ot, "#668a4e", .4); c:edgeIn(ot, "#4f6a4a")
  for _, p in ipairs({ { 264, 88 }, { 270, 92 }, { 267, 94 }, { 273, 87 } }) do c:put(p[1], p[2], P.petal.base); c:put(p[1] + 1, p[2], P.petal.hi) end
  vl(268, 98, 101, P.wood.shade)
  local cy = PL{ { 430, 98 }, { 424, 96 }, { 427, 88 }, { 429, 80 }, { 432, 80 }, { 433, 88 }, { 436, 96 } }
  F(cy, "#5a7a58"); shadeR(cy, "#466648", .45); c:edgeIn(cy, "#3c5a44"); vl(430, 82, 94, "#6f8f62")
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

---------------------------------------------------------------- v2.5.40 polish pass 1: ground variety
local STANDS = { { 194, 252 }, { 286, 252 }, { 240, 210 }, { 156, 192 }, { 346, 252 }, { 100, 258 } }
local function freeP(x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return false end
  if x >= 380 and y >= 230 then return false end
  for _, s in ipairs(STANDS) do if math.abs(x - s[1]) < 17 and math.abs(y - s[2]) < 17 then return false end end
  return true
end
local function gp(x, y, col) if freeP(x, y) then c:put(x, y, col) end end
local function vn(x, y, sc, s) return .5 + .25 * sin(x / sc + hsh(s, 1, 5) * 6) + .25 * sin(y / (sc * .7) + x / (sc * 2.3) + hsh(s, 2, 5) * 6) end
-- big soft tone patches in the grass (banded, no gradients)
for y = HOR + 2, H - 1 do
  for x = 0, W - 1 do
    if not path:has(x, y) and freeP(x, y) then
      local v = vn(x, y, 17, 3)
      if v > .74 then c:put(x, y, (y < 170) and "#b2c866" or "#9fc060")
      elseif v < .27 then c:put(x, y, (y < 170) and "#9db858" or "#80a64e")
      elseif v < .31 and hsh(x, y, 301) < .5 then c:put(x, y, "#80a64e") end
    end
  end
end
-- path: packed-dust bands, mud near the edges, pebbles, worn ruts
for y = HOR + 3, H - 1 do
  for x = rd(L(y)) + 1, rd(Rr(y)) - 1 do
    local v = vn(x, y, 9, 7)
    if v > .78 then gp(x, y, "#e4c698") elseif v < .22 then gp(x, y, "#d0aa7c") end
    if (x < L(y) + 5 or x > Rr(y) - 5) and hsh(x, y, 302) < .25 then gp(x, y, "#c49d72") end
  end
end
for i = 0, 70 do
  local y = HOR + 6 + floor(hsh(i, 1, 303) * 150); local x = rd(L(y)) + 4 + floor(hsh(i, 2, 303) * (Rr(y) - L(y) - 8))
  if freeP(x, y) then c:put(x, y, P.stone.base); c:put(x + 1, y, P.stone.hi); c:put(x, y + 1, "#9c7a5a") end
end
-- worn side paths to the notice board, fire table and the arch
for i = 0, 17 do local x = 128 - i * 1.3; local y = 232 + sin(i / 3) * 2 + i * .4; gp(rd(x), rd(y), "#d0aa7c"); gp(rd(x) + 1, rd(y) + 1, "#dcb98a"); gp(rd(x) - 1, rd(y), "#c49d72") end
for i = 0, 14 do local x = 326 + i * 1.1; local y = 238 + sin(i / 2) * 1.5; gp(rd(x), rd(y), "#d0aa7c"); gp(rd(x) + 1, rd(y) + 1, "#dcb98a") end
for i = 0, 22 do local x = 336 + i * 3.4; local y = 188 - i * .5 + sin(i / 2); gp(rd(x), rd(y), "#d0aa7c"); gp(rd(x) + 1, rd(y), "#dcb98a") end
-- grass tufts, pebbles, fallen leaves, flowers
for i = 0, 190 do
  local x = floor(hsh(i, 1, 304) * W); local y = HOR + 8 + floor(hsh(i, 2, 304) * (H - HOR - 10))
  if not path:has(x, y) and freeP(x, y) and not (y >= 146 and y <= 162 and sTop and false) then
    local k = i % 5
    if k == 0 then c:put(x, y, "#5f8a4a"); c:put(x - 1, y - 1, "#5f8a4a"); c:put(x + 1, y - 2, "#5f8a4a"); c:put(x, y - 1, "#6f9a52")
    elseif k == 1 then c:put(x, y, P.stone.hi); c:put(x + 1, y, P.stone.base); c:put(x, y + 1, "#7a7a8a")
    elseif k == 2 then c:put(x, y, "#c98a3c"); c:put(x + 1, y, "#e0a84a"); c:put(x, y + 1, "#a8652e")
    elseif k == 3 then c:put(x, y, P.petal.base); c:put(x - 1, y, P.petal.hi); c:put(x + 1, y, P.petal.hi); c:put(x, y - 1, P.petal.hi); c:put(x, y + 1, P.petal.hi); c:put(x, y, P.gold.hi); c:put(x, y + 2, "#5f8a4a")
    else c:put(x, y, P.cream); c:put(x - 1, y, P.sky.hi); c:put(x + 1, y, P.sky.hi); c:put(x, y - 1, P.sky.hi); c:put(x, y + 1, P.sky.hi); c:put(x, y, P.gold.base); c:put(x, y + 2, "#5f8a4a") end
  end
end

-- v2.5.40 polish pass 4b (ground part, painted before the props so they sit on top)
-- cast shadows all fall to the right (light from the top-left)
for _, r in ipairs({ { 334, 118, 342, 140 }, { 392, 114, 400, 136 }, { 112, 118, 118, 141 }, { 216, 100, 224, 118 }, { 104, 202, 114, 240 }, { 126, 198, 134, 240 } }) do
  for y = r[2], r[4] do for x = r[1], r[3] do if (x + y) % 2 == 0 or x < r[1] + 3 then gp(x, y, (y > 150) and "#6b8a56" or GSH) end end end
end
local function glowDither(cx, cy, rx, ry, col, p)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
    if d < 1 and (x + y) % 2 == 0 and hsh(x, y, 611) < p * (1 - d) then gp(x, y, col) end
  end end
end
glowDither(303, 143, 14, 4, "#e8d27a", .8); glowDither(369, 140, 12, 4, "#e8d27a", .8)
glowDither(338, 224, 32, 13, "#d8cc72", .9); glowDither(338, 224, 20, 9, "#e8d078", .9)

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

---------------------------------------------------------------- v2.5.40 polish pass 2: material cues
local function dots(list, col) for _, p in ipairs(list) do c:put(p[1], p[2], col) end end
local function patch(x0, y0, x1, y1, cols, seed, p, mk) -- irregular clump of colours inside a box (optionally clipped to mask mk)
  for y = y0, y1 do for x = x0, x1 do
    if mk and not mk:has(x, y) then goto skip end
    local e = math.min(x - x0, x1 - x, y - y0, y1 - y); if e > 0 or hsh(x, y, seed) < .5 then
      if hsh(x, y, seed + 1) < (p or .8) then c:put(x, y, cols[1 + floor(hsh(x, y, seed + 2) * #cols)]) end end
    ::skip::
  end end
end
-- mill foundation: stone chips, lichen, moss on the shaded north (left) side
for _, ch in ipairs({ { 30, 122 }, { 47, 129 }, { 61, 134 }, { 76, 124 }, { 84, 131 }, { 40, 137 } }) do
  c:put(ch[1], ch[2], P.stone.deep); c:put(ch[1] + 1, ch[2], P.stone.deep); c:put(ch[1], ch[2] + 1, P.stone.shade); c:put(ch[1] + 2, ch[2] - 1, P.stone.hi)
end
patch(19, 117, 30, 140, { P.moss.base, P.moss.shade, P.moss.shade, P.moss.hi }, 401, .7)
patch(56, 134, 66, 140, { P.moss.base, P.moss.shade }, 403, .6)
dots({ { 70, 120 }, { 71, 120 }, { 72, 121 }, { 44, 118 }, { 45, 119 }, { 100, 128 }, { 101, 128 } }, "#d9b04a")  -- lichen
-- mill walls: knots, nail heads, rain-streaks under the sill, moss under the eaves on the left
for _, k in ipairs({ { 26, 98 }, { 36, 106 }, { 49, 77 }, { 88, 100 }, { 98, 94 }, { 104, 108 } }) do
  c:put(k[1], k[2], P.wood.deep); c:put(k[1] + 1, k[2], P.wood.deep); c:put(k[1], k[2] + 1, P.wood.shade); c:put(k[1] + 1, k[2] + 1, P.wood.shade)
end
for _, wx in ipairs({ 38, 92 }) do for dy = 0, 6 do if dy % 3 ~= 2 then c:put(wx + (dy % 2), 89 + dy, P.wood.shade) end end end
for x = 24, 104, 8 do c:put(x, 92, P.stone.shade) end
patch(23, 67, 36, 71, { P.moss.base, P.moss.shade }, 405, .55)
-- roof: mossy north-west slope, a couple of replaced lighter shingles, ridge cap
patch(22, 56, 44, 66, { P.moss.shade, P.moss.base, P.moss.deep }, 407, .5, roof:shrink(1))
for _, sh in ipairs({ { 80, 58 }, { 94, 63 }, { 50, 51 }, { 68, 60 } }) do F(R(sh[1], sh[2], sh[1] + 5, sh[2] + 2), P.sea.hi); hl(sh[1], sh[1] + 5, sh[2] + 3, P.sea.deep) end
-- waterwheel: damp green on the lower paddles, drip streaks, rusty hub bolts
for k = 1, 4 do local a = k * 45 * pi / 180; local px, py = WX + (WRr + 3) * cos(a), WY + (WRr + 3) * sin(a)
  c:put(rd(px), rd(py), P.moss.shade); c:put(rd(px) - 1, rd(py) + 1, P.moss.base); c:put(rd(px) + 1, rd(py) + 1, P.moss.deep) end
for _, d in ipairs({ { 122, 150 }, { 140, 151 }, { 160, 150 } }) do vl(d[1], d[2], d[2] + 3, P.sea.base); c:put(d[1], d[2] + 4, P.sea.hi) end
dots({ { WX - 4, WY - 4 }, { WX + 4, WY - 4 }, { WX - 4, WY + 4 }, { WX + 4, WY + 4 } }, "#b3643a")
dots({ { WX + 5, WY + 1 }, { WX + 5, WY + 2 } }, "#b3643a")
-- granary thatch: darker bundle courses and a mossy ridge, plank knots
for y = 62, 76, 5 do for x = 178, 222 do if groof:shrink(2):has(x, y) and (x + y) % 3 ~= 0 then c:put(x, y, P.gold.shade) end end end
patch(178, 72, 192, 78, { P.moss.shade, P.gold.shade }, 411, .4, groof:shrink(1))
for _, k in ipairs({ { 188, 94 }, { 210, 88 }, { 190, 80 } }) do c:put(k[1], k[2], "#6e4a2a"); c:put(k[1] + 1, k[2], "#6e4a2a") end
-- cottage A: plaster cracks, damp at the base, flour handprints
for _, p in ipairs({ { 289, 125 }, { 290, 126 }, { 290, 127 }, { 291, 128 }, { 316, 107 }, { 316, 108 }, { 317, 109 } }) do c:put(p[1], p[2], "#bfa682") end
patch(281, 132, 295, 136, { P.moss.shade, "#d9c2a0" }, 413, .35)
-- cottage B: stone chips, lichen, moss on the north (left) corner, cracked sill
for _, ch in ipairs({ { 349, 126 }, { 357, 130 }, { 384, 112 }, { 370, 108 }, { 389, 128 } }) do c:put(ch[1], ch[2], P.stone.deep); c:put(ch[1] + 1, ch[2], P.stone.shade); c:put(ch[1], ch[2] - 1, P.stone.hi) end
patch(347, 120, 356, 134, { P.moss.base, P.moss.shade, P.moss.hi }, 415, .6)
dots({ { 380, 126 }, { 381, 126 }, { 381, 127 }, { 360, 106 }, { 361, 106 } }, "#d9b04a")
-- hedge arch: a few thorny dark twigs and berry clusters
for _, p in ipairs({ { 418, 120 }, { 456, 130 }, { 414, 140 }, { 458, 148 } }) do c:put(p[1], p[2], P.petal.base); c:put(p[1] + 1, p[2] + 1, P.petal.shade); c:put(p[1] + 2, p[2], P.petal.base) end
-- signposts / notice board: cork pins, nails, wood cracks
for _, p in ipairs({ { 30, 190 }, { 102, 190 }, { 30, 222 }, { 102, 222 }, { 66, 186 } }) do c:put(p[1], p[2], P.stone.hi) end
for _, p in ipairs({ { 33, 205 }, { 34, 206 }, { 98, 200 }, { 98, 201 }, { 97, 202 } }) do c:put(p[1], p[2], "#8a5a36") end
for y = 214, 236, 4 do c:put(35, y, P.wood.deep) end; for y = 200, 232, 5 do c:put(97, y, P.wood.deep) end
for y = 205, 233, 6 do c:put(114, y, P.wood.shade) end
for y = 132, 158, 5 do c:put(415, y, P.wood.deep) end
dots({ { 408, 134 }, { 418, 139 }, { 424, 134 }, { 430, 138 } }, P.wood.shade) -- sign grain
-- fire table: cloth folds, soot on the stones, charred log end
for x = 358, 394, 12 do vl(x, 204, 211, P.ember.shade) end
for _, p in ipairs({ { 325, 221 }, { 332, 224 }, { 340, 225 }, { 348, 224 } }) do c:put(p[1], p[2], P.stone.deep); c:put(p[1] + 1, p[2] - 1, P.stone.deep) end
-- cart: rope around the shafts, rusty rim studs, plank nails
F(LN({ { 457, 205 }, { 465, 223 } }, 1), P.gold.shade)
for i = 0, 7 do local a = i * pi / 4; c:put(rd(428 + 7 * cos(a)), rd(218 + 7 * sin(a)), "#b3643a") end
for x = 418, 452, 8 do c:put(x, 205, P.sea.deep) end
-- gate frame: knots, deep cracks and moss on the north-facing post
for _, p in ipairs({ { 4, 52 }, { 9, 120 }, { 3, 190 }, { 470, 70 }, { 474, 150 }, { 469, 220 } }) do c:put(p[1], p[2], P.wood.deep); c:put(p[1] + 1, p[2], P.wood.deep); c:put(p[1], p[2] + 1, P.wood.shade) end
for y = 80, 100 do if y % 4 ~= 3 then c:put(2, y, P.wood.deep) end end
for y = 150, 172 do if y % 5 ~= 4 then c:put(476, y, P.wood.deep) end end
patch(0, 230, 6, 262, { P.moss.base, P.moss.shade, P.moss.hi }, 421, .5)

---------------------------------------------------------------- v2.5.40 polish pass 3: lived-in props
-- flour dust re-laid over the road bands, trailing from the mill yard to the bridge
local function flourSpeck(cx, cy, rx, ry, seed)
  for y = cy - ry, cy + ry do for x = cx - rx, cx + rx do
    local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
    if d < 1 and freeP(x, y) then local v = hsh(x, y, seed); if v < .55 - d * .3 then gp(x, y, "#f6e6c4") elseif v < .7 - d * .2 then gp(x, y, P.cream) end end
  end end
end
flourSpeck(214, 178, 16, 5, 31); flourSpeck(228, 160, 9, 3, 35); flourSpeck(262, 172, 12, 3, 36); flourSpeck(236, 128, 10, 3, 34)
for i = 0, 4 do local fx, fy = 206 + i * 5, 182 + i * 4 - (i % 2) * 2; F(R(fx, fy, fx + 1, fy + 2), "#c49d72"); c:put(fx, fy - 1, "#c49d72") end
-- barrel (flour) by cottage A, banded
local function barrel(x, y, w, h)
  shadow(x - 1, y + h - 1, x + w + 5, y + h + 2, GSH)
  local b = c:rrect(x, y, x + w, y + h, 3); F(b, P.wood.base); lightTL(b, P.wood.hi, 4); shadeR(b, P.wood.shade, .3)
  hl(x + 1, x + w - 1, y + 3, P.stone.shade); hl(x + 1, x + w - 1, y + h - 3, P.stone.shade); vl(x + w // 2, y + 4, y + h - 4, P.wood.shade)
  c:edgeIn(b, P.wood.deep); hl(x + 2, x + w - 2, y, "#f6e6c4")
end
barrel(264, 124, 10, 13); barrel(266, 112, 9, 11)
-- wheat sheaves stacked by cottage B
local function sheaf(x, y)
  for k = -3, 3 do F(LN({ { x, y + 14 }, { x + k * 2, y } }, 1), P.gold.base) end
  F(R(x - 5, y + 7, x + 5, y + 9), P.ember.base); c:put(x - 3, y + 1, P.gold.hi); c:put(x + 2, y + 2, P.gold.hi)
  F(R(x - 4, y + 10, x + 4, y + 14), P.gold.shade); c:edgeIn(R(x - 6, y, x + 6, y + 14), P.gold.deep)
end
shadow(334, 134, 346, 139, GSH); sheaf(340, 123)
-- millstone leaning on a block by the far bank, with a spilled sack of grain
local MX, MY = 184, 174
shadow(MX - 8, MY + 10, MX + 26, MY + 17)
local blk1 = R(MX - 2, MY + 6, MX + 10, MY + 14); F(blk1, P.stone.base); lightTL(blk1, P.stone.hi, 4); c:edgeIn(blk1, P.stone.deep)
local ms = oct(MX, MY, 12, 22.5); F(ms, P.stone.hi); shadeR(ms, P.stone.base, .4); c:edgeIn(ms, P.stone.deep)
local hole = oct(MX, MY, 3, 22.5); F(hole, P.stone.deep)
for k = 0, 7 do local a = k * pi / 4 + .2; F(LN({ { MX + 5 * cos(a), MY + 5 * sin(a) }, { MX + 10 * cos(a + .3), MY + 10 * sin(a + .3) } }, 1), P.stone.shade) end
for i = 0, 14 do c:put(MX + 5 + floor(hsh(i, 1, 502) * 12), MY + 8 + floor(hsh(i, 2, 502) * 5), (i % 2 == 0) and P.gold.base or P.gold.hi) end
-- wicker grain baskets by the notice board
local function basket(x, y, w, h)
  shadow(x, y + h - 1, x + w + 4, y + h + 2, GSH)
  local b = c:rrect(x, y + 3, x + w, y + h, 3); F(b, "#c9944a")
  b:each(function(px, py) if (px + py) % 3 == 0 then c:put(px, py, "#a8703a") end end)
  shadeR(b, "#a8703a", .25); c:edgeIn(b, "#6e4a2a")
  local top = R(x - 1, y + 2, x + w + 1, y + 4); F(top, "#e0b060"); c:edgeIn(top, "#6e4a2a")
  for i = 0, w - 2 do c:put(x + 1 + i, y + 1 - (i % 3 == 1 and 1 or 0), (i % 2 == 0) and P.gold.hi or P.gold.base) end
end
basket(131, 216, 13, 9); basket(143, 220, 9, 7)
-- ladle bucket and rake leaning at the mill door
local bk = R(40, 112, 47, 118); F(bk, P.wood.base); hl(40, 47, 114, P.stone.shade); c:edgeIn(bk, P.wood.deep); hl(41, 46, 112, P.sea.base)
F(LN({ { 46, 119 }, { 50, 102 } }, 1), P.wood.shade); hl(47, 53, 101, P.wood.deep); for x = 47, 53, 2 do c:put(x, 102, P.wood.deep) end
-- spray droplets flung by the wheel (arcs of hard pixels)
for i = 0, 22 do
  local a = (150 + hsh(i, 1, 503) * 70) * pi / 180; local r = 31 + hsh(i, 2, 503) * 14
  local x, y = rd(WX + r * cos(a)), rd(WY + r * sin(a))
  if y >= 134 and y < 160 then c:put(x, y, (i % 3 == 0) and P.cream or P.sea.hi); if i % 4 == 0 then c:put(x, y + 1, P.sea.base) end end
end
for i = 0, 18 do local x = 118 + floor(hsh(i, 3, 503) * 52); c:put(x, 141 + floor(hsh(i, 4, 503) * 5), P.cream) end
-- chalk marks of the day's tally on the mill wall by the sacks
for i = 0, 3 do vl(27 + i * 2, 92, 95, P.cream) end; F(LN({ { 26, 95 }, { 34, 92 } }, 1), P.cream)
-- sack with a scoop on the cart side and a fallen sack by the table end
shadow(404, 232, 420, 237, GSH)
local fs = c:rrect(404, 224, 415, 232, 3); F(fs, "#f2e4c4"); shadeR(fs, "#d2bd96", .35); c:edgeIn(fs, "#9a8268"); hl(406, 412, 226, "#9a8268")

---------------------------------------------------------------- v2.5.40 polish pass 4b: key light top-left, rim, warm glows, foreground frame
-- rim light (cool-warm pale edge) on the lit top-left slopes of the main roofs, wheel and board
for y = 25, 69 do local x = rd(65 - (y - 24) * 55 / 46) + 2; c:put(x, y, P.sea.hi); c:put(x + 1, y, P.sea.base) end
for y = 71, 100 do local x = rd(303 - (y - 70) * 31 / 31) + 2; c:put(x, y, P.petal.hi) end
for y = 57, 79 do local x = rd(200 - (y - 56)) + 2; c:put(x, y, P.gold.hi); c:put(x + 1, y, "#fff0c8") end
hl(30, 102, 185, P.wood.hi); hl(23, 28, 186, P.wood.hi)
for k = 0, 7 do local a = (200 + k * 8) * pi / 180; c:put(rd(WX + (WRr + 1) * cos(a)), rd(WY + (WRr + 1) * sin(a)), P.cream) end
for x = 342, 351 do c:put(x, 107 - (x - 342) // 2 * 2 + 0, P.moss.hi) end
-- warm window / lantern / fire glow on neighbouring surfaces (dither only)
glowDither(36, 40, 15, 12, "#ffe3a0", .9); glowDither(444, 40, 15, 12, "#ffe3a0", .9)   -- lantern halo in the sky
for y = 200, 212 do if (y % 2 == 0) then c:put(353, y, P.gold.hi) end end   -- fire light on the table edge
for x = 351, 360, 2 do c:put(x, 224, P.gold.base) end
-- foreground frame: reeds, foxglove spires, ferns, poppies (clear of stand points and the compass corner)
local function reed(x, y, h, lean)
  for i = 0, h do c:put(x + rd(lean * i / h), y - i, (i % 4 == 3) and "#7aa250" or "#5f8a4a") end
  if h > 8 then F(R(x + rd(lean) - 1, y - h - 4, x + rd(lean), y - h), "#7a4a2e"); c:put(x + rd(lean) - 1, y - h - 4, "#a8703a") end
end
for i, p in ipairs({ { 24, 156, 12, -2 }, { 28, 157, 15, 1 }, { 33, 156, 10, 3 }, { 150, 163, 11, 2 }, { 154, 164, 14, -2 }, { 232, 164, 10, -2 }, { 288, 169, 12, 2 }, { 292, 170, 9, -2 } }) do reed(p[1], p[2], p[3], p[4]) end
local function fox(x, y, h)
  vl(x, y - h, y, "#5f8a4a"); vl(x + 1, y - h + 4, y, "#4f7a42")
  for i = 0, h - 4, 3 do c:put(x - 1, y - i - 2, P.dusk.base); c:put(x + 2, y - i - 3, P.dusk.hi); c:put(x, y - i - 3, P.dusk.hi); c:put(x + 1, y - i - 2, P.dusk.shade) end
  F(R(x - 1, y - h - 2, x + 2, y - h), P.dusk.hi); c:put(x, y - h - 3, P.dusk.base)
  for k = -1, 1 do F(LN({ { x, y }, { x + k * 4, y - 3 } }, 1), "#4f7a42") end
end
fox(22, 266, 16); fox(30, 267, 12); fox(66, 264, 14)
local function fern(x, y, r)
  for k = -3, 3 do local a = (270 + k * 28) * pi / 180
    for i = 1, r do local px, py = rd(x + i * cos(a)), rd(y + i * sin(a) * .8); c:put(px, py, (i % 2 == 0) and "#4f7a42" or "#6f9a52"); if i % 3 == 0 then c:put(px + 1, py, "#7aa250") end end end
end
fern(46, 266, 9); fern(54, 267, 7); fern(158, 268, 8)
for i = 0, 9 do local x, y = 140 + floor(hsh(i, 1, 621) * 34), 256 + floor(hsh(i, 2, 621) * 11)
  if freeP(x, y) and freeP(x + 2, y) then c:put(x, y + 1, "#4f7a42"); c:put(x, y + 2, "#4f7a42"); c:put(x, y, P.ember.base); c:put(x - 1, y, P.ember.hi); c:put(x + 1, y, P.ember.base); c:put(x, y - 1, P.ember.shade); c:put(x, y, P.dusk.deep) end end
-- berry bush on the bank by the bridge (round, lit top-left)
do
  local bsh = c:ellipse(300, 176, 10, 7); F(bsh, "#6f9a52"); shadeR(bsh, "#4f7a42", .4); c:edgeIn(bsh, "#3c5a44")
  for _, p in ipairs({ { 295, 172 }, { 299, 170 }, { 303, 175 }, { 297, 177 }, { 305, 179 } }) do c:put(p[1], p[2], P.petal.base); c:put(p[1] + 1, p[2], P.petal.hi) end
  hl(293, 298, 170, "#9db46c")
end

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
