-- welcome-basket-topdown PASS B (final). Pass A = welcome-basket-topdown.pA.lua. Draw 190x165, save x2 = 380x330.
-- TOP-DOWN round woven basket for welcome step 2; items (3x2 grid of 46px slots + labels) sit on the floor.
-- Rim from outside in: ink outline over a scalloped rope roll (each twist bulges 1px), 3 rows of 2/2 twill
-- (every dash is one shaded strand with rounded ends; stakes show in the gaps and step diagonally), a wrapped
-- dark binding, then the deep inner edge. Lighting is chosen per strand (not per pixel) so there are no ragged
-- light-zone seams. Floor: flat coiled straw, very low contrast; the rim casts a 2-tone crescent on the floor
-- upper-left and the far inner wall catches a thin light lower-right. 2-tone hard cast shadow lower-right.
-- quirk: a ladybird trundling over the rim (lower left).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "welcome-basket-topdown"
local SUF = app.params.suf or ""
local c = HP.canvas{ w = 190, h = 165, scale = 2, name = NAME }
local atan, sqrt, floor, pi, abs, cos, sin = math.atan, math.sqrt, math.floor, math.pi, math.abs, math.cos, math.sin

local CX, CY, RX, RY = 93, 79, 91, 77
-- straw ramp, 6 tones (hi .. darkest)
local T = { "#fff0c2", "#ffd98a", "#f0b95e", "#d0903f", "#9c5f2a", "#5a3020" }
local STK = { "#b5743a", "#8a4f2a", "#6a3a22" }           -- stakes seen through the twill
local FL = { a = "#f2d395", line = "#e6c17c", sh = "#d9aa66", sh2 = "#bf8a4c", lit = "#f9e2ad" }

local ROPE, W0, ROWH, NROWS = 5, 6, 4, 3
local BIND = W0 + ROWH * NROWS    -- 18
local RIM = BIND + 2              -- 20
local MEANR = 76
local outer = c:ellipse(CX, CY, RX, RY)

local function polar(x, y)
  local nx, ny = (x - CX) / RX, (y - CY) / RY
  local r = sqrt(nx * nx + ny * ny)
  local dist = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
  local dd = r > 0 and (1 - r) / r * dist or 999
  local a = atan(ny, nx) if a < 0 then a = a + 2 * pi end
  return dd, a, nx, ny
end
-- light level for an arc position s (px along the mean circumference): +1 lit, 0, -1 shade, -2 deep
local function lightAt(s)
  local a = s / MEANR
  local L = -(cos(a) + sin(a))
  if L > 0.75 then return 1 elseif L > -0.35 then return 0 elseif L > -1.15 then return -1 end
  return -2
end
local function tone(i, l) i = i - l if i < 1 then i = 1 elseif i > 6 then i = 6 end return T[i] end

local P12, OVER, SHIFT = 12, 9, 3
local basket = HP.mask()
outer:each(function(x, y)
  local dd, a, nx, ny = polar(x, y)
  local s = a * MEANR
  local col
  if dd < ROPE then
    -- rope roll: twist segments 5px along the arc, slanted; outermost row only where a twist bulges
    local q = s + dd * 1.4
    local seg = floor(q / 5)
    local ph = q - seg * 5
    local l = lightAt(seg * 5 + 2.5)
    if dd < 1 and (ph < 1 or ph >= 4) then return end         -- scallop cut between twists
    if ph < 1 then col = tone(5, l)                            -- groove between twists
    elseif dd < 1.5 then col = tone(ph < 2.5 and 2 or 3, l) -- outer lit edge of the twist
    elseif dd >= ROPE - 1 then col = tone(4, l)               -- underside row of the roll
    else col = tone(ph < 2 and 2 or 3, l) end
    if l >= 1 and dd >= 1.5 and dd < 2.5 and ph >= 1.5 and ph < 3 then col = T[1] end
  elseif dd < W0 then
    col = T[6]
  elseif dd < BIND then
    local w = dd - W0
    local row = floor(w / ROWH)
    local t = w - row * ROWH
    local q = s + row * SHIFT
    local seg = floor(q / P12)
    local u = q - seg * P12
    local l = lightAt(seg * P12 - row * SHIFT + OVER / 2)
    if t >= ROWH - 1 then
      col = (u >= OVER) and STK[3] or T[5]                      -- gap between rows
    elseif u < OVER then
      local i = 3
      if t < 1 then i = 2 elseif t >= 2 then i = 4 end
      local endp = (u < 1) or (u >= OVER - 1)
      if endp then i = (t >= 1 and t < 2) and 4 or 5 end      -- rounded strand ends
      if i == 2 and u >= 2 and u < 4 and l >= 0 then i = 1 end -- glint on each lit strand
      col = tone(i, l)
    else
      col = (u < OVER + 1.2) and STK[1] or STK[2]               -- stake: lit edge + body
      if l <= -1 then col = STK[2] end
    end
  elseif dd < BIND + 2 then
    -- wrapped binding: tight diagonal wraps, dark
    local q = s - (dd - BIND) * 2
    local ph = floor(q) % 3
    col = (ph == 0) and T[6] or ((lightAt(s) >= 1) and T[4] or T[5])
  else
    -- floor: coiled straw, low contrast
    local fx, fy = (x - CX) / (RX - RIM), (y - CY) / (RY - RIM)
    local inner = (1 - sqrt(fx * fx + fy * fy)) * (RY - RIM)
    col = ((inner % 6) < 1 and inner < 26) and FL.line or FL.a
    local L = -(nx + ny)
    if inner < 1 then col = T[6]                                -- deep inner edge, all round
    elseif inner < 3 and L > -0.2 then col = FL.sh2
    elseif inner < 6 and L > 0.45 then col = FL.sh             -- rim shadow crescent upper-left
    elseif inner < 2 and L < -0.7 then col = FL.lit            -- far inner wall catches light
    elseif inner < 2 then col = FL.sh end
  end
  c:put(x, y, col, "basket")
  basket:set(x, y)
end)

-- quirk: ladybird walking over the rim, lower left (on the twill)
do
  local lx, ly = 22, 119
  c:paint({
    "....kkkkk..",
    "..kkrHrkrk.",
    ".kkrHrrrrrk",
    "kekkdddddrk",
    ".kkrrkrrsrk",
    "..kkrrrksk.",
    "....kkkkk..",
  }, lx, ly, { k = P.ink, r = P.ember.base, H = P.ember.hi, e = P.cream, d = P.ember.deep, s = P.ember.shade })
  -- legs
  c:px(lx + 5, ly - 1, P.ink) c:px(lx + 7, ly - 1, P.ink) c:px(lx + 5, ly + 7, P.ink) c:px(lx + 7, ly + 7, P.ink)
end

c:finish{ outline = true }
-- cast shadow lower-right, two hard tones (near = darker)
local whole = basket:copy():grow(1)
local far = whole:shift(5, 7)
local near = whole:shift(3, 4)
far:each(function(x, y) if not c:get(x, y) then c:put(x, y, "#d2c1a3", "shadow") end end)
near:each(function(x, y) local g = c:get(x, y) if not g or g == "#d2c1a3" then c:put(x, y, "#b9a283", "shadow") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 2 }
