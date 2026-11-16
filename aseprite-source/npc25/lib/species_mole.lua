-- mole (biped (mammal)) tables from specs/mole.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "mole", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#8a7184", "#6b5462", "#4c3a4f", "#33283a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#8a7184", "#6b5462", "#4c3a4f", "#33283a", "#7fae5a", "#4f7f4a", "#33533f", "#e9bf5c", "#b98a3e", "#f2949a", "#fff4d6"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#6b5462",
  bshade = h"#4c3a4f",
  bhi = h"#8a7184",
  deep = h"#33283a",
  head = h"#6b5462",
  hat = h"#e9bf5c",
  hatshade = h"#b98a3e",
  wing = h"#4c3a4f",
  belly = h"#7fae5a",
  acc = h"#7fae5a",
  accs = h"#4f7f4a",
  eye = h"#7fae5a",
  q = h"#e9bf5c",
  qshade = h"#fff4d6",
  qhi = h"#e9bf5c",
  ink = h"#33283a", arm = h"#6b5462", fbase = h"#4c3a4f", fshade = h"#33283a"}
S.bw, S.top = 28, 10
S.quirk = {w = 3, h = 3, y = 11, x = {front = 31, back = 31, side = 34}, anchor = "crown", hex = "#e9bf5c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local F = {hi = H"#8a7184", base = H"#6b5462", shade = H"#4c3a4f", deep = H"#33283a"}
  local FS = {hi = F.base, base = F.shade, shade = F.deep, deep = F.deep} -- far side fur
  local OV = {hi = H"#7fae5a", base = H"#7fae5a", shade = H"#4f7f4a", deep = H"#33533f"}
  local HAT = {hi = H"#fff4d6", base = H"#e9bf5c", shade = H"#b98a3e"}
  local PINK, CREAM = H"#f2949a", H"#fff4d6"
  local b, hd = o.body, o.head
  local top = 10 + hd
  local k = frame - 2
  -- side stride (stance foot slides back, swing foot comes forward)
  local LX = ({1, -1, -3, -1, 1, 3})[k] or 0
  local RX = ({-1, 1, 3, 1, -1, -3})[k] or 0
  local sw = (o.armL > 0 and 1) or (o.armL < 0 and -1) or 0
  local G = {}
  local function P(x, y, c)
    if c and x >= 13 and x <= 50 and y >= top and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry) - 1, math.ceil(cy + ry) + 1 do
      for x = math.floor(cx - rx) - 1, math.ceil(cx + rx) + 1 do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then P(x, y, fn(x, y, nx, ny, d)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.55 + ny * 0.83
    if s > 0.88 and r.deep then return r.deep end
    if s > 0.4 then return r.shade end
    if s < -0.5 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  local LMAP = {d = INK, Q = HAT.base, s = HAT.shade, c = CREAM, k = INK}
  -- straw texture
  local function straw(x, y, c)
    if c == HAT.base and (x * 2 + y * 3) % 9 == 0 then return HAT.shade end
    return c
  end
  local function hat(cx, cy, x1, x2, brx, front)
    -- back half of brim
    ell(cx, cy, brx, 2.6, function(x, y, nx, ny)
      if ny > 0.45 or nx > 0.82 then return HAT.shade end
      return straw(x, y, HAT.base)
    end)
    for y = top + (front and 1 or 0), cy - 1 do
      for x = x1, x2 do
        local yy = y - top
        if not (yy == 1 and (x == x1 or x == x2)) then
          local c = HAT.base
          if x >= x2 - 2 then c = HAT.shade end
          if yy == 1 and x >= x1 + 2 and x <= x1 + 3 then c = HAT.hi end
          c = straw(x, y, c)
          if y >= cy - 3 and y <= cy - 2 then c = (x >= x2 - 2) and OV.deep or OV.shade end
          P(x, y, c)
        end
      end
    end
    -- front half of brim
    ell(cx, cy, brx, 2.6, function(x, y, nx, ny)
      if y < cy then return nil end
      if ny > 0.45 or nx > 0.82 then return HAT.shade end
      return straw(x, y, HAT.base)
    end)
  end
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR, armVL, armVR = o.footR, o.footL, o.armR, o.armL
    if not front then ftVL, ftVR, armVL, armVR = o.footL, o.footR, o.armL, o.armR end
    -- legs + feet
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 62 + b, bot - 3 do for x = cx - 2, cx + 2 do P(x, y, x >= cx + 1 and F.deep or F.shade) end end
      local ry = lift < 0 and 2.2 or 2.6
      ell(cx, bot - ry + 0.4, 3.6, ry, function(x, y, nx, ny)
        if front then
          if y == bot and (x == cx - 1 or x == cx + 1) then return INK end
          if y == bot - 2 and x == cx - 2 then return CREAM end
          return PINK
        end
        if y >= bot - 1 and math.abs(x - cx) <= 1 then return lift < 0 and F.shade or PINK end
        if y == bot - 2 and math.abs(x - cx) <= 2 then return F.deep end
        return PINK
      end)
    end
    foot(25, ftVL); foot(38, ftVR)
    -- torso
    ell(CX, 53 + b, 12.5, 12.5, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        if not front and yy >= 61 and (x == 31 or x == 32) then return OV.deep end
        return lit(nx, ny, OV)
      end
      if front then
        local ax = math.abs(x - CX)
        if ax <= 6 and yy >= 45 then
          if yy == 45 then return (ax >= 5) and HAT.base or OV.hi end
          if (yy == 48 and ax <= 2.5) then return OV.shade end
          if (yy == 49 or yy == 50) and (ax == 2.5) then return OV.shade end
          return lit(nx, ny, OV)
        end
        if ax >= 4.5 and ax <= 5.5 and yy >= 41 then return OV.base end
        return lit(nx, ny, F)
      end
      -- back: crossing straps
      local s1 = math.floor(25 + (yy - 41) * 0.55 + 0.5)
      local s2 = math.floor(38 - (yy - 41) * 0.55 + 0.5)
      if yy >= 41 and (x == s1 or x == s2) then return (x > 32) and OV.shade or OV.base end
      return lit(nx, ny, F)
    end)
    if not front then
      -- tiny tail stub
      stamp(30, 63 + b, {".hb.", "hbbd", ".bd."}, {h = F.hi, b = F.base, d = F.deep})
    end
    -- arms + big pink digging hands
    local function arm(a, side)
      local dy = front and a or -a
      local hx = side < 0 and 18 or 45
      local hy = 52 + b + dy
      E(side < 0 and 20.5 or 42.5, 47.5 + b + dy / 2, 3, 3.6, side < 0 and F or FS)
      ell(hx, hy, 4, 3.6, function(x, y, nx, ny)
        local yb = math.floor(hy + 3.6)
        if y == yb and (x == hx - 1 or x == hx + 1) then return INK end
        if front and side < 0 and y == hy - 2 and x == hx - 1 then return CREAM end
        if not front and ny < -0.3 then return F.shade end
        return PINK
      end)
      -- claw tips
      for _, dx in ipairs({-2, 0, 2}) do P(hx + dx, math.floor(hy + 3.6) + 1, CREAM) end
    end
    arm(armVL, -1); arm(armVR, 1)
    -- head
    ell(CX, 29 + hd, 13.5, 11, function(x, y, nx, ny)
      return lit(nx, ny, F)
    end)
    -- fur tufts on the cheeks
    for _, t in ipairs({{17, 31}, {46, 32}}) do
      P(t[1], t[2] + hd, t[1] < 32 and F.base or F.shade)
    end
    -- brim shadow + sheen
    for x = 19, 44 do if get(x, 21 + hd) then P(x, 21 + hd, F.deep) end end
    for x = 20, 43 do if get(x, 22 + hd) and x > 37 then P(x, 22 + hd, F.deep) end end
    if front then
      P(21, 25 + hd, F.hi); P(22, 24 + hd, F.hi); P(24, 23 + hd, F.hi)
      -- eyes (small, deep in fur)
      for _, ex in ipairs({25, 37}) do
        P(ex, 27 + hd, INK); P(ex + 1, 27 + hd, INK); P(ex, 28 + hd, INK); P(ex + 1, 28 + hd, INK)
        P(ex, 27 + hd, CREAM); P(ex - 1, 26 + hd, F.hi); P(ex + 2, 26 + hd, F.hi)
      end
      P(23, 31 + hd, PINK); P(24, 31 + hd, PINK); P(39, 31 + hd, PINK); P(40, 31 + hd, PINK)
      -- big pink snout
      stamp(28, 29 + hd, {"..pppp..", ".pcpppp.", "pppppppp", "pkppppkp", ".pppppp.", "..dddd..", "...kk..."},
        {p = PINK, c = CREAM, k = INK, d = F.deep})
      P(30, 36 + hd, F.deep); P(33, 36 + hd, F.deep)
      -- lamp cord down the right cheek to the belt
    else
      -- fur strands on the back of the head
      for _, t in ipairs({{24, 25}, {25, 24}, {29, 24}, {30, 23}, {35, 25}, {27, 30}, {28, 29}, {33, 29}}) do
        if get(t[1], t[2] + hd) == F.base or get(t[1], t[2] + hd) == F.hi then P(t[1], t[2] + hd, F.hi) end
      end
      for _, t in ipairs({{38, 32}, {39, 31}, {26, 35}, {31, 34}, {32, 35}}) do P(t[1], t[2] + hd, F.shade) end
      -- cord from the lamp strap down the back to a battery box on the belt
      for y = 41, 52 do P(math.floor(25 - (y - 41) * 0.25 + 0.5) + sw, y + b, HAT.shade) end
      stamp(21 + sw, 52 + b, {"dddd", "dcQd", "dQsd", "dddd"}, LMAP)
    end
    hat(CX, 18.5 + hd, 24, 39, 18.5, front)
    if front then
      stamp(29 + sw, top, {".ddd.", "dccQd", "dcQsd", "dQssd", ".ddd."}, LMAP)
      for x = 34 + sw, 39 do P(x, 16 + hd, HAT.shade) end
    else
      -- lamp housing peeking over the crown, buckle on the band
      stamp(29 - sw, top, {".ddd.", "dQQsd"}, LMAP)
      stamp(30 - sw, 15 + hd, {"cQs", "QQs"}, LMAP)
    end
  else
    -- side view, facing right
    local function foot(cx, lift, far)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 2, cx + 1 do P(x, y, far and F.deep or (x == cx + 1 and F.shade or F.base)) end end
      ell(cx + 1, bot - 1.6, 4, 2, function(x, y, nx, ny)
        if y == bot and x >= cx + 3 then return INK end
        if x == math.floor(cx + 4.5) and y == bot - 1 then return CREAM end
        if far then return y >= bot - 1 and F.shade or PINK end
        return PINK
      end)
    end
    local LS, RS = o.footL, o.footR
    foot(27 + LX, LS, true)
    -- far arm + hand reaching forward in shade
    local fax = -LX
    E(37 + fax, 48 + b, 2.5, 3, FS)
    ell(41 + fax, 52 + b, 3, 3, function(x, y, nx, ny)
      if x == math.floor(41 + fax) + 2 and y == 52 + b then return INK end
      if ny < -0.2 then return F.shade end
      return PINK
    end)
    -- torso
    ell(29.5, 54 + b, 11, 12, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if x >= 33 and yy >= 46 then
        if yy == 46 then return OV.hi end
        if yy == 49 and x >= 35 and x <= 37 then return OV.shade end
        return lit(nx, ny, OV)
      end
      return lit(nx, ny, F)
    end)
    for yy = 41, 46 do P(28 + math.floor((yy - 41) * 0.9), yy + b, OV.base) end
    P(33, 46 + b, HAT.base)
    -- short tail
    P(18, 59 + b, F.base); P(17, 60 + b, F.base); P(16, 61 + b, F.shade)
    foot(32 + RX, RS, false)
    -- near arm + big digging hand
    local ax = -RX
    E(33 + ax / 2, 48 + b, 3, 3.5, F)
    local hx, hy = 37 + ax, 53 + b
    ell(hx, hy, 3.6, 3.3, function(x, y, nx, ny)
      local xr = math.floor(hx + 3.6)
      if x == xr and (y == hy - 1 or y == hy + 1) then return INK end
      if x == hx - 1 and y == hy - 2 then return CREAM end
      return PINK
    end)
    for _, dy in ipairs({-2, 0, 2}) do P(math.floor(hx + 3.6) + 1, hy + dy, CREAM) end
    -- head
    ell(30, 30 + hd, 12.5, 11.5, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(41.5, 32 + hd, 6, 3.3, function(x, y, nx, ny)
      if ny < -0.4 then return F.base end
      if ny > 0.4 then return F.shade end
      return F.base
    end)
    P(17, 32 + hd, F.base)
    for x = 18, 41 do if get(x, 21 + hd) then P(x, 21 + hd, F.deep) end end
    P(22, 24 + hd, F.hi); P(23, 23 + hd, F.hi); P(25, 23 + hd, F.hi)
    stamp(45, 30 + hd, {".pp..", "pcppp", "ppppk", ".ppp."}, {p = PINK, c = CREAM, k = INK})
    -- eye, cheek, mouth
    P(37, 27 + hd, INK); P(38, 27 + hd, INK); P(37, 28 + hd, INK); P(38, 28 + hd, INK); P(37, 27 + hd, CREAM)
    P(36, 26 + hd, F.hi); P(39, 26 + hd, F.hi)
    P(36, 31 + hd, PINK); P(37, 31 + hd, PINK)
    P(41, 35 + hd, INK); P(42, 35 + hd, INK); P(40, 34 + hd, F.deep)
    -- cord from the lamp back along the brim and down the back
    hat(30, 18.5 + hd, 23, 36, 15, false)
    for x = 37, 41 + sw do P(x, 17 + hd, HAT.shade) end
    -- miner's lamp riding on the brim front
    stamp(41 + sw, 13 + hd, {"ddd..", "ddcQd", "ddQQs", "ddQss", "ddd.."}, LMAP)
    P(46 + sw, 15 + hd, CREAM)
  end
  for key, c in pairs(G) do img:putPixel(key % 64, key // 64, c) end
  N.outline(img, INK)
end
return S
