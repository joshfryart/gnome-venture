-- greenhouse-lantern (aC10_2 Opus pass): a slim octagonal glass pavilion seen corner-on (three faces), lit from inside
-- like a lantern: amber glass brightest round the hanging lamp, plants backlit as dark silhouettes, dark iron posts and
-- ribs, a faceted pyramid roof with a vent crown and ball finial, a stone octagon plinth (right face in shade).
-- Two little iron lanterns hang from scroll brackets on the outer posts.
-- quirk: a pale moth flutters round the left lantern.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_2.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local c = D.new("greenhouse-lantern")
local GW, IR = D.GLW, D.IRON
local SIL = { "#2a2a30", "#3c4430", "#56623a", "#7a7c3c", "#a89a44", "#d8c060" }  -- backlit leaves
c:groundShadow(32, 54, 21, 2)

-- plinth: three faces
local st = D.blocks(c, 15, 46, 49, 52, D.STONE, { bh = 3, bw = { 5, 7 }, seed = 21 })
for y = 46, 52 do
  for x = 15, 20 do D.shift(c, x, y, D.STONE, 0) end
  for x = 44, 49 do D.shift(c, x, y, D.STONE, -1) end
  c:put(21, y, D.STONE[5], st) c:put(43, y, D.STONE[2], st)
end
D.ledge(c, 14, 50, 44, D.STONE)

-- walls: glowing glass, brightest round the lamp
local gt = D.tok("glow")
local function glow(m, off)
  m:each(function(x, y)
    local dx, dy = (x - 32) / 13, (y - 35) / 11
    local v = 0.98 - 0.45 * sqrt(dx * dx + dy * dy) + off
    if (x + y) % 11 < 1 then v = v + 0.12 end
    c:put(x, y, GW[max(1, min(6, floor(v * 6) + 1))], gt)
  end)
end
glow(HP.rect(16, 28, 21, 43), -0.12) glow(HP.rect(22, 28, 42, 43), 0) glow(HP.rect(43, 28, 48, 43), -0.28)
-- backlit plants
D.bush(c, 16, 28, 43, 7, nil, { ramp = SIL, seed = 31 })
D.bush(c, 36, 48, 43, 6, nil, { ramp = SIL, seed = 33 })
-- hanging lamp
local lt = D.tok("lamp")
for y = 28, 31 do c:put(32, y, IR[4], lt) end
c:put(31, 32, IR[4], lt) c:put(32, 32, IR[5], lt) c:put(33, 32, IR[3], lt)
for y = 33, 35 do c:put(31, y, GW[6], lt) c:put(32, y, D.CREAM, lt) c:put(33, y, GW[5], lt) end
c:put(32, 36, IR[3], lt)
-- iron frame
local ft = D.tok("iron", true)
D.vbar(c, 15, 27, 43, 1, ft, IR) D.vbar(c, 49, 27, 43, 1, ft, IR)
for y = 27, 43 do c:put(15, y, IR[5], ft) c:put(49, y, IR[3], ft) end
D.vbar(c, 21, 27, 43, 2, ft, IR) D.vbar(c, 42, 27, 43, 2, ft, IR)
D.vbar(c, 18, 28, 43, 1, ft, IR) D.vbar(c, 46, 28, 43, 1, ft, IR)
D.vbar(c, 27, 28, 43, 1, ft, IR) D.vbar(c, 37, 28, 43, 1, ft, IR)
D.hbar(c, 16, 48, 32, 1, ft, IR)
-- door (centre face): arched frame
for y = 34, 43 do c:put(29, y, IR[4], ft) c:put(35, y, IR[3], ft) end
for x = 30, 34 do c:put(x, 33, IR[4], ft) end
c:put(34, 39, D.GOLD[5], ft)
for x = 22, 41 do if not (x >= 29 and x <= 35) then c:put(x, 37, IR[3], ft) end end
-- glass rim: pixels right of a bar get +1 (bright rim), below a bar -1
D.rims(c, gt, GW)

-- roof: three facets of dimmer glass + iron ribs
local rt = D.tok("roofglass")
local function facet(pts, off)
  local m = HP.poly(pts)
  m:each(function(x, y)
    local v = 0.62 - (27 - y) * 0.018 + off
    if (x - y) % 9 < 1 then v = v + 0.14 end
    c:put(x, y, GW[max(1, min(6, floor(v * 6) + 1))], rt)
  end)
  return m
end
facet({ { 14, 27 }, { 21, 27 }, { 32, 12 } }, -0.12)
facet({ { 21, 27 }, { 43, 27 }, { 32, 12 } }, 0)
facet({ { 43, 27 }, { 50, 27 }, { 32, 12 } }, -0.3)
D.sbar(c, 14, 27, 31, 12, 5, ft, IR) D.sbar(c, 50, 27, 33, 12, 3, ft, IR)
D.sbar(c, 21, 27, 31, 13, 4, ft, IR) D.sbar(c, 43, 27, 33, 13, 4, ft, IR)
D.sbar(c, 27, 27, 31, 14, 4, ft, IR) D.sbar(c, 37, 27, 33, 14, 4, ft, IR)
D.rims(c, rt, GW)
-- eave band
for x = 13, 51 do c:put(x, 27, IR[5], ft) c:put(x, 28, IR[2], ft) end
c:put(13, 27, IR[6], ft)
-- vent crown + finial
local cr = D.tok("crown", true)
for x = 29, 35 do c:put(x, 12, IR[(x < 32) and 5 or 3], cr) c:put(x, 11, IR[2], cr) end
for x = 30, 34, 2 do c:put(x, 10, IR[4], cr) end
for x = 30, 34 do c:put(x, 9, IR[5], cr) end
local ball = G.rell(32, 7, 1, 0, 1.6, 1.6)
D.vol(c, ball, D.GOLD, 1.4, { name = "ball" })

-- side lanterns on scroll brackets
local function lantern(px, dir)
  local bk = D.tok("bracket")
  local ax = px + dir * 5
  for i = 0, 5 do c:put(px + dir * i, 30, IR[4], bk) end
  c:put(px + dir * 2, 31, IR[3], bk) c:put(px + dir * 3, 32, IR[3], bk)  -- scroll
  c:put(px + dir * 4, 31, IR[3], bk)
  c:put(ax, 29, IR[5], bk)
  local lx = ax
  c:put(lx, 31, IR[4], bk)
  for x = lx - 2, lx + 2 do c:put(x, 32, IR[(x < lx) and 5 or 3], bk) end
  for x = lx - 1, lx + 1 do c:put(x, 31, IR[4], bk) end
  local lg = D.tok("lglass")
  for y = 33, 36 do for x = lx - 2, lx + 2 do
    local hx
    if x == lx - 2 or x == lx + 2 then hx = IR[(x < lx) and 4 or 2]
    elseif y == 33 then hx = GW[4]
    elseif x == lx and y < 36 then hx = D.CREAM
    else hx = (x < lx) and GW[6] or GW[5] end
    c:put(x, y, hx, lg)
  end end
  for x = lx - 2, lx + 2 do c:put(x, 37, IR[(x < lx) and 4 or 2], bk) end
  c:put(lx, 38, IR[3], bk)
end
lantern(14, -1) lantern(50, 1)

-- quirk: moth by the left lantern
local mt = D.tok("moth")
c:put(10, 24, "#e8dcc4", mt) c:put(11, 25, "#b8a888", mt) c:put(12, 24, "#e8dcc4", mt)
c:put(10, 25, "#cfc0a4", mt) c:put(12, 25, "#cfc0a4", mt) c:put(11, 24, D.WOOD[2], mt)
D.save(c, "greenhouse-lantern")
