-- folk-hedgehog-2 portrait (folk F1_0) variant: 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile(DIR .. "/../../lib/hedgehog.lua")
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R4(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local SKIN = R4("#f6dfb0", "#e0b986", "#b38469", "#7d5763")
local PAW = R4("#e9b89a", "#c98d78", "#9a6468", "#6a4458")
local NOSE, NOSEHI, BLUSH = "#4a2c3c", "#8a5a6a", "#e8968a"
local function rnd(v) return math.floor(v + 0.5) end
local function spiky(c, cx, cy, rx, ry, a0, a1, n, len, w)
  local m = c:ellipse(cx, cy, rx, ry)
  local tips = {}
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * (i + 0.5) / n)
    local ww = math.rad(w)
    local x1, y1 = cx + math.cos(a - ww) * rx * 0.92, cy + math.sin(a - ww) * ry * 0.92
    local x2, y2 = cx + math.cos(a + ww) * rx * 0.92, cy + math.sin(a + ww) * ry * 0.92
    local tx, ty = cx + math.cos(a) * (rx + len), cy + math.sin(a) * (ry + len)
    m:add(c:poly{ { rnd(x1), rnd(y1) }, { rnd(x2), rnd(y2) }, { rnd(tx), rnd(ty) } })
    tips[#tips + 1] = { rnd(tx), rnd(ty), a }
  end
  return m, tips
end
local function quills(c, m, R, cx, cy, rx, ry, tips)
  m:each(function(x, y) if (x * 7 + y * 13) % 17 == 0 and m:has(x, y + 1) and m:has(x + 1, y) then c:put(x, y, R.deep) end end)
  for _, t in ipairs(tips) do
    local a = t[3]
    local lit = math.cos(a) < 0.25 and math.sin(a) < 0.35
    local sx, sy = rnd(cx + math.cos(a) * rx * 0.55), rnd(cy + math.sin(a) * ry * 0.55)
    local ex, ey = rnd(cx + math.cos(a) * (rx + 1)), rnd(cy + math.sin(a) * (ry + 1))
    c:line({ { sx, sy }, { ex, ey } }, 1):clip(m):each(function(x, y) c:put(x, y, lit and R.hi or R.deep) end)
    if m:has(t[1], t[2]) then c:put(t[1], t[2], lit and R.hi or R.shade) end
  end
end
local function fill(m, hex, c) m:each(function(x, y) c:put(x, y, hex) end) end
local NAME = "folk-hedgehog-2"
local SP = R4("#b8a48c", "#7f6a5e", "#54465a", "#372c40")
local CLO = R4("#8fa6d0", "#5d74a8", "#414f80", "#2e3458")
local CAP = R4("#d67a9c", "#a84a78", "#74345e", "#4a2448")
local SCARF = R4("#7fd0c4", "#3f9e9c", "#2e6c78", "#234a5a")
local PACK = R4("#d19a62", "#9c6640", "#6a4238", "#45293a")
local ROLL = R4("#efd9a8", "#cdb07e", "#9a8070", "#6a5866")
local BRASS = R4("#f2d27a", "#c99a3e", "#8a6034", "#5a3a30")
local GL1, GL2, GL3 = "#fff0a8", "#f7c75a", "#e8913f"
local BG = { base = "#a4c4dc", shade = "#7898bc", deep = "#56709a" }
local V = {}
function V.behind(c)
  local pk = c:rrect(55, 70, 75, 99, 4)
  c:part(pk, PACK, { band = 2, nopop = true, inner = false })
  local fl = c:rrect(55, 70, 75, 79, 3)
  c:part(fl, PACK, { band = 1, nopop = true, inner = false })
  fl:each(function(x, y) if not fl:has(x, y + 1) then c:put(x, y, PACK.deep) end end)
  c:put(70, 80, BRASS.hi) c:put(71, 80, BRASS.base) c:put(70, 81, BRASS.base) c:put(71, 81, BRASS.shade)
  local r = c:ellipse(64, 67, 9, 4.5)
  c:part(r, ROLL, { band = 1, nopop = true, inner = false })
  for y = 62, 72 do for _, x in ipairs{ 59, 69 } do if r:has(x, y) then c:put(x, y, PACK.shade) end end end
end
function V.body(c, sh)
  c:part(sh, CLO, { band = 3, nopop = true })
  local st = c:line({ { 57, 79 }, { 38, 99 } }, 3):clip(sh)
  fill(st, PACK.base, c)
  st:each(function(x, y) if not st:has(x + 1, y + 1) then c:put(x, y, PACK.deep) end end)
  for _, y in ipairs{ 86, 93 } do c:put(31, y, BRASS.hi) c:put(32, y, BRASS.base) c:put(31, y + 1, BRASS.base) c:put(32, y + 1, BRASS.shade) end
  local s = c:rrect(24, 69, 55, 77, 3)
  c:part(s, SCARF, { band = 2, nopop = true, inner = false })
  for x = 27, 53, 5 do for y = 70, 76 do if s:has(x, y) then c:put(x, y, SCARF.shade) end end end
  local t = c:poly{ { 27, 74 }, { 34, 74 }, { 35, 93 }, { 28, 93 } }
  c:part(t, SCARF, { band = 1, nopop = true, inner = false })
  for y = 80, 92, 4 do for x = 28, 34 do if t:has(x, y) then c:put(x, y, SCARF.shade) end end end
  for x = 28, 34, 2 do c:put(x, 94, SCARF.shade) end
end
function V.hat(c)
  local cm = c:ellipse(39.5, 35, 16, 11):clip(c:rect(0, 0, 79, 32))
  c:part(cm, CAP, { band = 2, nopop = true, inner = false })
  for x = 28, 52, 4 do for y = 24, 32 do if cm:has(x, y) and c:get(x, y) == CAP.base then c:put(x, y, CAP.shade) end end end
  local cu = c:rrect(22, 30, 57, 37, 2)
  c:part(cu, CAP, { band = 1, nopop = true, inner = false })
  for x = 23, 56, 2 do for y = 31, 35 do if cu:has(x, y) and c:get(x, y) ~= CAP.deep then c:put(x, y, CAP.shade) end end end
  c:part(c:ellipse(47, 21, 4.5, 4.5), ROLL, { band = 1, nopop = true, inner = false })
end
function V.prop(c)
  local L = c:rect(6, 64, 19, 81)
  L:add(c:poly{ { 7, 64 }, { 18, 64 }, { 16, 60 }, { 9, 60 } })
  L:add(c:rect(12, 57, 13, 59))
  c:part(L, BRASS, { band = 1, nopop = true, inner = false })
  fill(c:rect(8, 66, 17, 78), GL2, c)
  fill(c:rect(9, 67, 11, 72), GL1, c)
  fill(c:ellipse(12.5, 73, 1.5, 2.5), GL1, c)
  for y = 74, 78 do c:put(16, y, GL3) c:put(17, y, GL3) end
  for y = 66, 78 do c:put(12, y, BRASS.shade) end
  for x = 6, 19 do c:put(x, 65, BRASS.shade) c:put(x, 79, BRASS.shade) end
  c:part(c:ellipse(13, 87, 4, 3.5), PAW, { band = 1, nopop = true, inner = false })
end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local sh = c:ellipse(39.5, 104, 28, 25):clip(c:rect(0, 0, 79, 99))
V.behind(c)
local bm, bt = spiky(c, 39.5, 84, 27, 9, 165, 375, 12, 5, 7)
bm:clip(c:rect(0, 0, 79, 99))
c:part(bm, SP, { band = 2, nopop = true, inner = false })
HH.texture(c, bm, 39.5, 84, 27, 9, SP)
c:part(c:ellipse(39.5, 71, 13, 8), SKIN, { band = 2, nopop = true, inner = false })
V.body(c, sh)
HH.head(c, { cx = 39.5, cy = 49, s = 1.4, SP = SP, FACE = SKIN })
V.hat(c)
V.prop(c)
c:finish{ outline = true }
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
