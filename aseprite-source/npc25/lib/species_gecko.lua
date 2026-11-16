-- gecko (biped (mammal)) tables from specs/gecko.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "gecko", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#ffcf8e", "#f29a52", "#b8604c", "#7c5e4e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#ffcf8e", "#f29a52", "#b8604c", "#7c5e4e", "#e6c766", "#b48f56", "#5fae4c", "#3d7c4c", "#285450", "#f6ecd2", "#7a3a4c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#f29a52",
  bshade = h"#b8604c",
  bhi = h"#ffcf8e",
  deep = h"#7c5e4e",
  head = h"#f29a52",
  hat = h"#e6c766",
  hatshade = h"#b48f56",
  wing = h"#b8604c",
  belly = h"#f6ecd2",
  acc = h"#5fae4c",
  accs = h"#3d7c4c",
  eye = h"#f6ecd2",
  q = h"#b8604c",
  qshade = h"#7a3a4c",
  qhi = h"#b8604c",
  ink = h"#7c5e4e", arm = h"#f29a52", fbase = h"#b8604c", fshade = h"#7c5e4e"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 2, y = 29, x = {front = 28, back = 28, side = 32}, anchor = "neck", hex = "#b8604c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local SK = {hi = H"#ffcf8e", base = H"#f29a52", shade = H"#b8604c", deep = H"#7c5e4e"}
  local SKF = {hi = SK.base, base = SK.shade, shade = SK.deep, deep = SK.deep}
  local OV = {hi = H"#5fae4c", base = H"#5fae4c", shade = H"#3d7c4c", deep = H"#285450"}
  local HAT = {hi = H"#ffcf8e", base = H"#e6c766", shade = H"#b48f56"}
  local LEAF, LEAFD = H"#5fae4c", H"#3d7c4c"
  local BELLY = H"#f6ecd2"
  local SC, SCD = H"#b8604c", H"#7a3a4c"
  local b, hd = o.body, o.head
  local top = 10 + hd
  local k = frame - 2
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
  -- tapering tail along points, r0 -> r1
  local function tail(pts, r0, r1, ramp)
    local n = #pts
    for i = 1, n - 1 do
      local a, c = pts[i], pts[i + 1]
      for s = 0, 3 do
        local t = s / 4
        local u = (i - 1 + t) / (n - 1)
        local rr = r0 + (r1 - r0) * u
        E(a[1] + (c[1] - a[1]) * t, a[2] + (c[2] - a[2]) * t, rr, rr, ramp)
      end
    end
    local l = pts[n]
    E(l[1], l[2], r1, r1, ramp)
  end
  -- spots on the skin
  local function spots(list)
    for _, t in ipairs(list) do
      local c = get(t[1], t[2])
      if c == SK.base or c == SK.hi then P(t[1], t[2], SK.shade) end
    end
  end
  local function hat(cx, cy, x1, x2, brx, leafLeft)
    ell(cx, cy, brx, 2.5, function(x, y, nx, ny)
      if ny > 0.45 or nx > 0.85 then return HAT.shade end
      if (x + y * 2) % 6 == 0 then return HAT.shade end
      return HAT.base
    end)
    for y = top + 1, cy - 1 do
      for x = x1, x2 do
        local yy = y - top
        if not (yy == 1 and (x == x1 or x == x2)) then
          local c = HAT.base
          if x >= x2 - 2 then c = HAT.shade end
          if yy == 1 and x >= x1 + 2 and x <= x1 + 4 then c = HAT.hi end
          if c == HAT.base and (x * 3 + y) % 7 == 0 then c = HAT.shade end
          if y >= cy - 3 and y <= cy - 2 then c = (x >= x2 - 2) and SCD or SC end
          P(x, y, c)
        end
      end
    end
    ell(cx, cy, brx, 2.5, function(x, y, nx, ny)
      if y < cy then return nil end
      if ny > 0.45 or nx > 0.85 then return HAT.shade end
      if (x + y * 2) % 6 == 0 then return HAT.shade end
      return HAT.base
    end)
    -- leaf sprig tucked in the band
    if leafLeft ~= nil then
      local lx = leafLeft and x1 - 4 or x2 + 1
      local rows = leafLeft and {"ll...", "lLl..", ".lLl.", "..lLs", "...ss"} or {"...ll", "..lLl", ".lLl.", "sLl..", "ss..."}
      stamp(lx, top, rows, {l = LEAF, L = LEAFD, s = LEAFD})
    end
  end
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR, armVL, armVR = o.footR, o.footL, o.armR, o.armL
    if not front then ftVL, ftVR, armVL, armVR = o.footL, o.footR, o.armL, o.armR end
    if front then
      -- tail curling out on the viewer's left
      local tw = sw * 0.5
      tail({{26, 62 + b}, {21, 64}, {17, 63.5}, {15 + tw, 60.5}, {16 + tw, 57.5}, {18.5 + tw, 57}}, 2.6, 1.2, SK)
      P(17, 61, BELLY); P(18, 60, BELLY)
    end
    -- legs + splayed three-toed feet
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 61 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and SK.shade or SK.base) end end
      local tz = lift < 0 and SK.shade or SK.base
      stamp(cx - 3, bot - 2, {".hhhh..", "hbbbbbs", "b.b.b.s"},
        {h = front and SK.hi or SK.shade, b = front and tz or SK.shade, s = SK.shade})
      if front then P(cx - 3, bot, SK.hi); P(cx + 1, bot, SK.hi) end
    end
    foot(26, ftVL); foot(37, ftVR)
    -- body: overalls, cream chest
    ell(CX, 52.5 + b, 11, 13, function(x, y, nx, ny)
      local yy = y - b
      local ax = math.abs(x - CX)
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        if yy >= 62 and ax <= 0.5 then return OV.deep end
        return lit(nx, ny, OV)
      end
      if front then
        if ax <= 5.5 and yy >= 47 then
          if yy == 47 then return OV.hi end
          if yy == 50 and ax <= 2.5 then return OV.shade end
          if (yy == 51 or yy == 52) and ax == 2.5 then return OV.shade end
          return lit(nx, ny, OV)
        end
        if (ax == 4.5) and yy >= 40 then return x > 32 and OV.shade or OV.base end
        if ax <= 3.5 then return (yy % 2 == 0 and ax <= 2.5) and BELLY or BELLY end
        return lit(nx, ny, SK)
      end
      local s1 = math.floor(25 + (yy - 40) * 0.45 + 0.5)
      local s2 = math.floor(38 - (yy - 40) * 0.45 + 0.5)
      if yy >= 40 and (x == s1 or x == s2) then return x > 32 and OV.shade or OV.base end
      return lit(nx, ny, SK)
    end)
    if front then
      P(27, 47 + b, HAT.base); P(36, 47 + b, HAT.base)
      P(30, 44 + b, SK.hi); P(33, 42 + b, SK.hi)
    else
      -- thick tail base sweeping out to the viewer's right
      local tw = sw * 0.5
      tail({{31.5, 59 + b}, {34, 63}, {39, 65}, {44, 64}, {46.5 + tw, 61}, {45.5 + tw, 57.5}}, 3.2, 1.3, SK)
      spots({{35, 63}, {41, 64}, {45, 62}})
      P(33, 61 + b, SK.hi); P(34, 62 + b, SK.hi)
    end
    -- skinny arms with sticky toe-pad fingers
    local function arm(a, side)
      local dy = front and a or -a
      local sx = side < 0 and 21 or 42
      local hx = side < 0 and 18 or 45
      local hy = 54 + b + dy
      for t = 0, 8 do
        local yy = 43 + b + (hy - 1 - 43 - b) * t / 8
        local xx = sx + (hx - sx) * t / 8
        E(xx, yy, 1.7, 1.7, front and (side < 0 and SK or SKF) or SKF)
      end
      local rows = side < 0 and {".bbb.", "bbbbs", "h.h.h"} or {".bbb.", "hbbbs", "h.h.h"}
      if not front then rows = {".sss.", "sssss", "s.s.s"} end
      stamp(hx - 2, hy - 1, rows, {b = SK.base, s = SK.shade, h = SK.hi})
    end
    arm(armVL, -1); arm(armVR, 1)
    -- wide flat head
    ell(CX, 28 + hd, 14.5, 8.8, function(x, y, nx, ny)
      if front and ny > 0.6 and math.abs(nx) < 0.5 then return BELLY end
      return lit(nx, ny, SK)
    end)
    -- bulging eyes on the head corners
    for _, s in ipairs({-1, 1}) do
      local ex = s < 0 and 22.5 or 40.5
      ell(ex, 24.5 + hd, 3.6, 3.4, function(x, y, nx, ny, d)
        if d > 0.5 or not front then return lit(nx, ny, SK) end
        return BELLY
      end)
      if front then
        local px = s < 0 and 23 or 40
        P(px, 24 + hd, INK); P(px + 1, 24 + hd, INK); P(px, 25 + hd, INK); P(px + 1, 25 + hd, INK)
        P(px, 24 + hd, BELLY)
      end
    end
    if front then
      -- nostrils + big smile + cheeks
      P(29, 28 + hd, SK.deep); P(34, 28 + hd, SK.deep)
      for x = 22, 41 do
        local dx = math.abs(x - CX)
        local y = 31 + hd - (dx > 5 and 1 or 0) - (dx > 8 and 1 or 0)
        if dx <= 8.5 then P(x, y, INK) end
      end
      P(30, 32 + hd, SK.shade); P(31, 32 + hd, SK.shade); P(32, 32 + hd, SK.shade); P(33, 32 + hd, SK.shade)
      P(20, 30 + hd, SK.hi); P(43, 30 + hd, SK.shade)
      spots({{21, 29 + hd}, {26, 22 + hd}, {37, 22 + hd}, {42, 29 + hd}, {31, 23 + hd}, {19, 52}, {44, 53}})
    else
      spots({{24, 30 + hd}, {29, 26 + hd}, {35, 25 + hd}, {38, 31 + hd}, {31, 32 + hd}, {27, 33 + hd}})
      P(20, 26 + hd, SK.hi); P(21, 25 + hd, SK.hi)
    end
    -- striped scarf, knot on the viewer's right, end hangs down the back
    for x = 21, 42 do
      for y = 36, 39 do
        if not ((x == 21 or x == 42) and (y == 36 or y == 39)) then
          local c = (y >= 37 and x % 3 == 0) and SCD or SC
          if y == 39 or x >= 40 then c = SCD end
          P(x, y + b, c)
        end
      end
    end
    if front then
      stamp(36 + sw, 39 + b, {"sss.", "ssd.", ".sd.", ".ssd", ".sd.", ".cc."}, {s = SC, d = SCD, c = BELLY})
    else
      stamp(30 + sw, 40 + b, {"sssd", "sssd", ".sd.", ".sd.", ".cc."}, {s = SC, d = SCD, c = BELLY})
    end
    hat(CX, 18.5 + hd, 25, 38, 16, front)
  else
    -- side view, facing right
    local tw = sw * 0.5
    tail({{22, 61 + b}, {18, 64}, {15, 62}, {14.5 + tw, 58}, {16 + tw, 54.5}, {19 + tw, 54}}, 2.8, 1.2, SK)
    P(16, 60, BELLY); P(16, 59, BELLY)
    local function foot(cx, lift, far)
      local bot = 70 + lift
      local r = far and SKF or SK
      for y = 61 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and r.shade or r.base) end end
      stamp(cx - 1, bot - 1, {"bbbbh", "bbb.b.b"}, {b = r.base, h = r.hi})
      P(cx + 5, bot, r.base)
    end
    foot(27 + LX, o.footL, true)
    -- far arm
    local fax = -LX
    stamp(37 + fax, 50 + b, {"ss.", "sss", "s.s"}, {s = SK.shade})
    -- body
    ell(30, 52.5 + b, 10, 13.2, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if x >= 29 and yy >= 46 then
        if yy == 46 then return OV.hi end
        if yy == 49 and x >= 34 and x <= 36 then return OV.shade end
        if x == 29 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if x >= 36 then return BELLY end
      return lit(nx, ny, SK)
    end)
    P(29, 46 + b, HAT.base)
    foot(32 + RX, o.footR, false)
    -- near arm
    local ax = -RX
    for t = 0, 7 do
      E(32 + ax * t / 7, 43.5 + t + b, 1.7, 1.7, SK)
    end
    stamp(30 + ax, 51 + b, {".bbb", "hbbbs", "h.h.h"}, {b = SK.base, s = SK.shade, h = SK.hi})
    -- head with long snout
    ell(30, 28 + hd, 11, 8.3, function(x, y, nx, ny) return lit(nx, ny, SK) end)
    ell(40.5, 29.5 + hd, 7.5, 5, function(x, y, nx, ny)
      if ny > 0.45 then return BELLY end
      if ny < -0.4 then return SK.hi end
      return (nx > 0.6 and ny > 0) and SK.shade or SK.base
    end)
    -- bulging eye on top
    ell(36, 24.5 + hd, 3.4, 3.3, function(x, y, nx, ny, d)
      if d < 0.5 then return BELLY end
      return lit(nx, ny, SK)
    end)
    P(37, 24 + hd, INK); P(37, 25 + hd, INK); P(36, 25 + hd, INK); P(36, 24 + hd, BELLY)
    -- nostril, smile, ear hole
    P(46, 27 + hd, SK.deep)
    for x = 35, 47 do P(x, 32 + hd - (x <= 36 and 1 or 0), INK) end
    P(27, 29 + hd, INK); P(28, 29 + hd, SK.deep)
    spots({{24, 25 + hd}, {22, 30 + hd}, {30, 23 + hd}, {41, 27 + hd}, {26, 33 + hd}, {19, 60}, {17, 57}})
    P(24, 23 + hd, SK.hi); P(43, 27 + hd, SK.hi)
    -- scarf with a trailing end
    for x = 23, 37 do
      for y = 35, 38 do
        local c = (y >= 36 and x % 3 == 0) and SCD or SC
        if y == 38 or x >= 35 then c = SCD end
        P(x, y + b, c)
      end
    end
    stamp(18 - sw, 36 + b, {"..sss", "ssssd", "sd.d.", "c...."}, {s = SC, d = SCD, c = BELLY})
    hat(29.5, 18.5 + hd, 23, 36, 13.5, true)
  end
  for key, c in pairs(G) do img:putPixel(key % 64, key // 64, c) end
  N.outline(img, INK)
end
return S
