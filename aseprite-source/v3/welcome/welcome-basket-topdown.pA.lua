-- welcome-basket-topdown PASS A (form). Draw 190x165, save x2 = 380x330. TOP-DOWN round woven basket.
-- Rim from outside in: ink outline, twisted rope roll (diagonal twist), 3 rows of 2/2 twill (dashes over 2
-- stakes, shifted 1 stake per row = readable diagonals), dark binding, deep inner edge; flat coiled-straw
-- floor (low contrast) kept clear for a 3x2 grid of 46px items; rim casts a crescent shadow on the floor
-- upper-left. Transparent outside, 2-tone hard cast shadow lower-right.
-- quirk: a ladybird walking over the rim (lower left).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "welcome-basket-topdown"
local SUF = app.params.suf or ".pA"
local c = HP.canvas{ w = 190, h = 165, scale = 2, name = NAME }
local atan, sqrt, floor, pi, abs = math.atan, math.sqrt, math.floor, math.pi, math.abs

local CX, CY, RX, RY = 93, 79, 91, 77
-- straw ramp (6 tones) + stake wood
local S = { hi = "#ffe6a8", lt = "#f7cf7e", base = "#e8b462", sh = "#c98c45", dp = "#965c2e", dd = "#5e3524" }
local STK = { "#b0723c", "#8a5230" }
local FL = { a = "#f0cf8e", b = "#e7c27f", line = "#dcb06c", sh = "#cf9d5c", sh2 = "#b98448" }

local RIM_ROPE, RIM_WEAVE0, ROWH, NROWS = 4, 5, 4, 3
local RIM_BIND = RIM_WEAVE0 + ROWH * NROWS        -- 17
local RIM = RIM_BIND + 2                          -- 19: floor starts here
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
local function light(nx, ny) -- +1 lit (upper-left), 0 mid, -1 shade (lower-right)
  local L = -(nx + ny)
  if L > 0.55 then return 1 elseif L < -0.55 then return -1 end
  return 0
end
local function lshift(tones, idx, l) -- shift index along ramp by lighting
  local i = idx - l
  if i < 1 then i = 1 elseif i > #tones then i = #tones end
  return tones[i]
end
local T = { S.hi, S.lt, S.base, S.sh, S.dp, S.dd }

outer:each(function(x, y)
  local dd, a, nx, ny = polar(x, y)
  local s = a * MEANR
  local l = light(nx, ny)
  local col
  if dd < RIM_ROPE then
    -- twisted rope roll: diagonal twist bands, outer row darker
    local band = floor((s + dd * 1.6) / 4) % 2
    local i = band == 0 and 2 or 3
    if dd < 1 then i = i + 1 end
    if floor((s + dd * 1.6)) % 4 == 3 then i = 4 end
    col = lshift(T, i, l)
  elseif dd < RIM_WEAVE0 then
    col = S.dd
  elseif dd < RIM_BIND then
    local w = dd - RIM_WEAVE0
    local row = floor(w / ROWH)
    local t = w - row * ROWH
    if t >= ROWH - 1 then
      col = S.dp                                   -- gap between rows
    else
      local P12 = 12
      local u = (s + row * 3) % P12
      if u < 9 then
        local i = 3
        if t < 1 then i = 2 elseif t >= 2 then i = 4 end
        if u < 1 or u >= 8 then i = 4 end
        col = lshift(T, i, l)
      else
        col = (u >= 10 and u < 11) and STK[1] or STK[2]
      end
    end
  elseif dd < RIM_BIND + 1 then
    col = lshift(T, 4, l)
  elseif dd < RIM then
    col = S.dd
  else
    -- floor: coiled straw, very low contrast
    local fx, fy = (x - CX) / (RX - RIM), (y - CY) / (RY - RIM)
    local inner = (1 - sqrt(fx * fx + fy * fy)) * (RY - RIM)
    col = ((inner % 5) < 1) and FL.line or FL.a
    -- rim casts shadow on the floor upper-left
    local L = -(nx + ny)
    if inner < 2 then col = FL.sh2
    elseif inner < 5 and L > 0.2 then col = FL.sh
    elseif inner < 3 then col = FL.sh end
  end
  c:put(x, y, col, "basket")
end)

-- quirk: ladybird on the rim lower-left
do
  local lx, ly = 33, 123
  c:paint({
    ".kk..",
    "krrrk",
    "rrkrr",
    "rkrkr",
    ".rrr.",
  }, lx, ly, { k = P.ink, r = P.ember.base })
  c:px(lx + 1, ly + 1, P.ember.hi)
end

c:finish{ outline = true }
-- cast shadow lower-right, two hard tones
local whole = outer:copy():grow(1)
local sh1 = whole:shift(3, 4)
local sh2 = whole:shift(5, 7)
sh2:each(function(x, y) if not c:get(x, y) then c:put(x, y, "#cdbb9c", "shadow") end end)
sh1:each(function(x, y) if c:get(x, y) == "#cdbb9c" or not c:get(x, y) then c:put(x, y, "#b49d7e", "shadow") end end)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. SUF .. ".aseprite", png = out .. NAME .. SUF .. ".png", scale = 2 }
