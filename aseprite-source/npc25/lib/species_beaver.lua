-- beaver (biped (mammal)) tables from specs/beaver.md. Stage 3 art in S.draw_figure.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local S = {name = "beaver", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 42}
S.ramps = {main = {"#c98d58", "#b97a4a", "#864c33", "#51302b"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c98d58", "#b97a4a", "#864c33", "#51302b", "#e8b982", "#fff4d6", "#3d2532", "#f5809f",
  "#e8705a", "#d0503e", "#9a3a36", "#7fa2d0", "#6188bc", "#465c92", "#323c66",
  "#d8b47a", "#b08a58", "#7a5a3c", "#e8c262", "#d6d4de", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
S.quirk = {name = "axe and stick bundle", anchor = "back", hex = "#b08a58"}

-- one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local F = {hi = H"#c98d58", base = H"#b97a4a", shade = H"#864c33", deep = H"#51302b"}
  local FS = {hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local PAW = {hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local AP = {hi = H"#7fa2d0", base = H"#6188bc", shade = H"#465c92", deep = H"#323c66"}
  local CAP = {hi = H"#e8705a", base = H"#d0503e", shade = H"#9a3a36", deep = H"#9a3a36"}
  local ST = {hi = H"#d8b47a", base = H"#b08a58", shade = H"#7a5a3c"}
  local STEEL = {hi = H"#d6d4de", base = H"#aaa9b8", shade = H"#74758c"}
  local MUZ, CREAM, NOSE, PINK, TW = H"#e8b982", H"#fff4d6", H"#3d2532", H"#f5809f", H"#e8c262"
  local b, hd = o.body, o.head
  local top = 10 + hd
  local k = frame - 2
  local LX = ({1, -1, -3, -1, 1, 3})[k] or 0
  local RX = ({-1, 1, 3, 1, -1, -3})[k] or 0
  local G = {}
  local function P(x, y, c)
    if c and x >= 12 and x <= 51 and y >= top and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry) - 1, math.ceil(cy + ry) + 1 do
      for x = math.floor(cx - rx) - 1, math.ceil(cx + rx) + 1 do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
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
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return lit(nx, ny, r) end)
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  -- bundle of 4 sticks along a line (per-row span of 4 px), staggered cut ends, two twine bands
  local function bundle(x0, y0, x1, y1)
    local n = y1 - y0
    local t1, t2 = y0 + math.floor(n * 0.3), y0 + math.floor(n * 0.7)
    local s0, s1 = {1, 0, 2, 0, 1, 3}, {0, 2, 1, 3, 0, 1}
    local col = {ST.hi, ST.base, ST.shade, ST.hi, ST.base, ST.shade}
    for y = y0, y1 do
      local xc = math.floor(x0 + (x1 - x0) * (y - y0) / n + 0.5)
      for i = 1, 6 do
        if y >= y0 + s0[i] and y <= y1 - s1[i] then
          local c = col[i]
          if y == y0 + s0[i] or y == y1 - s1[i] then c = MUZ end
          if y == t1 or y == t2 then c = TW end
          P(xc - 4 + i, y + b, c)
        end
      end
    end
  end
  -- flat paddle tail with crosshatch
  local function tail(cx, cy, rx, ry)
    ell(cx, cy, rx, ry, function(x, y, nx, ny)
      if nx < -0.6 or ny < -0.75 then return F.shade end
      if (x + y) % 3 == 0 or (x - y) % 3 == 0 then return NOSE end
      return F.deep
    end)
  end
  -- axe: handle through the hand at (hx, hy), steel head on top, blade toward dir
  local function axe(hx, hy, dir)
    for y = hy - 11, hy + 3 do P(hx, y, (y % 3 == 0) and ST.base or ST.hi); P(hx + dir, y, ST.shade) end
    P(hx, hy - 12, ST.shade); P(hx + dir, hy - 12, ST.shade)
    local rows = dir > 0 and {"sbb...", "sbbbh.", "sbbbbh", "sbbbbh", "sbbbh.", "sss..."} or {"...bbs", ".hbbbs", "hbbbbs", "hbbbbs", ".hbbbs", "...sss"}
    stamp(dir > 0 and hx or hx - 5, hy - 13, rows, {s = STEEL.shade, b = STEEL.base, h = STEEL.hi})
  end
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR, armVL, armVR = o.footR, o.footL, o.armR, o.armL
    if not front then ftVL, ftVR, armVL, armVR = o.footL, o.footR, o.armL, o.armR end
    if front then
      bundle(17, 32, 44, 61)
      tail(CX, 68.5, 4.5, 2.2)
    end
    -- legs + big hind feet
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 2, cx + 2 do P(x, y, x >= cx + 1 and F.deep or F.shade) end end
      ell(cx, bot - 1.6, 4, 2.2, function(x, y, nx, ny)
        if front and y == bot and (x == cx - 1 or x == cx + 1) then return INK end
        if ny < -0.4 and nx < 0.2 then return F.shade end
        return F.deep
      end)
    end
    foot(25, ftVL); foot(38, ftVR)
    -- stocky torso
    ell(CX, 54 + b, 13, 12.5, function(x, y, nx, ny)
      local yy = y - b
      local ax = math.abs(x - CX)
      if front then
        if yy >= 55 and ax <= 10 then
          if yy >= 64 then return AP.deep end
          if yy == 55 then return AP.shade end
          if (yy == 57 or yy == 60) and ax <= 3 then return AP.shade end
          if yy >= 57 and yy <= 60 and (ax >= 2.5 and ax <= 3.5) then return AP.shade end
          return lit(nx, ny, AP)
        end
        if ax <= 5.5 and yy >= 46 then
          if yy == 46 then return AP.hi end
          return lit(nx, ny, AP)
        end
        if ax >= 4.5 and ax <= 5.5 and yy >= 42 then return AP.base end
        if ax <= 4 and yy >= 42 and yy <= 45 then return MUZ end
        return lit(nx, ny, F)
      end
      -- back: crossing straps + waist tie
      if yy == 55 or yy == 56 then return yy == 55 and AP.base or AP.shade end
      local s1 = math.floor(24 + (yy - 42) * 0.6 + 0.5)
      local s2 = math.floor(39 - (yy - 42) * 0.6 + 0.5)
      if yy >= 42 and yy < 55 and (x == s1 or x == s2) then return (x > 32) and AP.shade or AP.base end
      return lit(nx, ny, F)
    end)
    if not front then
      -- apron bow + paddle tail hanging to the ground
      stamp(29, 54 + b, {"bb.bb", "bsbsb", "b...b"}, {b = AP.base, s = AP.shade})
      tail(CX, 63.5 + b, 5.5, 7)
    end
    -- arms + paws; axe in one hand
    local function arm(a, side)
      local dy = front and a or -a
      local hx = side < 0 and 18 or 45
      local hy = 54 + b + dy
      E(side < 0 and 20.5 or 42.5, 48 + b + dy / 2, 3.2, 4, side < 0 and F or FS)
      local carry = (front and side > 0) or (not front and side < 0)
      if carry then axe(hx, hy, side) end
      E(hx, hy, 2.8, 2.6, PAW)
      P(hx - 1, hy + 2, INK); P(hx + 1, hy + 2, INK)
    end
    arm(armVL, -1); arm(armVR, 1)
    -- ears
    for _, ex in ipairs({19, 44}) do
      E(ex, 20 + hd, 3.4, 3.2, ex < 32 and F or FS)
      if front then P(ex, 20 + hd, F.deep); P(ex + (ex < 32 and 1 or -1), 21 + hd, F.deep) end
    end
    -- head (wide jowls)
    ell(CX, 28.5 + hd, 13.5, 11, function(x, y, nx, ny) return lit(nx, ny, F) end)
    if front then
      P(21, 24 + hd, F.hi); P(22, 23 + hd, F.hi); P(23, 22 + hd, F.hi)
      -- muzzle
      ell(CX, 32 + hd, 6.5, 4.6, function(x, y, nx, ny)
        if ny > 0.6 and nx > -0.2 then return F.hi end
        return MUZ
      end)
      -- eyes
      for _, ex in ipairs({24, 38}) do
        P(ex, 25 + hd, INK); P(ex + 1, 25 + hd, INK); P(ex, 26 + hd, INK); P(ex + 1, 26 + hd, INK)
        P(ex, 25 + hd, CREAM)
      end
      P(21, 29 + hd, PINK); P(22, 29 + hd, PINK); P(41, 29 + hd, PINK); P(42, 29 + hd, PINK)
      -- nose, mouth, buck teeth
      stamp(29, 29 + hd, {".nnnn.", "nnnnnn", "..nn.."}, {n = NOSE})
      P(30, 29 + hd, CREAM)
      stamp(28, 32 + hd, {".k...k.", "kkkkkkk", "kcckcck", "kcskcsk", "kcskcsk", ".kk.kk."}, {k = INK, c = CREAM, s = MUZ})
    else
      for _, t in ipairs({{24, 25}, {25, 24}, {29, 23}, {30, 22}, {27, 30}, {28, 29}}) do P(t[1], t[2] + hd, F.hi) end
      for _, t in ipairs({{38, 33}, {39, 32}, {33, 35}, {34, 36}}) do P(t[1], t[2] + hd, F.shade) end
      bundle(46, 32, 19, 61)
    end
    -- knit beanie: dome + ribbed band
    ell(CX, 21 + hd, 11.5, 11.2, function(x, y, nx, ny)
      if y > 20 + hd then return nil end
      if y >= 18 + hd then
        if y == 20 + hd then return CAP.shade end
        return (x % 2 == 0) and CAP.shade or CAP.base
      end
      if y == 17 + hd then return CAP.shade end
      return lit(nx, ny, CAP)
    end)
    if front then P(25, 12 + hd, CAP.hi); P(24, 13 + hd, CAP.hi) end
  else
    -- side view, facing right
    local function foot(cx, lift, far)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 2, cx + 1 do P(x, y, far and F.deep or (x == cx + 1 and F.shade or F.base)) end end
      ell(cx + 2, bot - 1.5, 5, 2.1, function(x, y, nx, ny)
        if not far and y == bot and x >= cx + 4 then return INK end
        if far then return F.deep end
        if ny < -0.3 then return F.shade end
        return F.deep
      end)
    end
    -- stick bundle on the back (behind everything)
    bundle(15, 33, 18, 60)
    -- paddle tail lying on the ground behind
    for y = 61, 65 do P(19 - (y - 61) // 2, y + (y < 64 and b or 0), F.deep); P(20 - (y - 61) // 2, y + (y < 64 and b or 0), F.deep) end
    tail(18, 67.4, 6, 2.4)
    local LS, RS = o.footL, o.footR
    foot(28 + LX, LS, true)
    -- far arm
    local fax = -LX
    E(35 + fax / 2, 48 + b, 2.5, 3.2, FS)
    E(37 + fax, 53 + b, 2.4, 2.4, {hi = F.shade, base = F.deep, shade = F.deep, deep = F.deep})
    -- torso
    ell(29, 54 + b, 11, 12.5, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 and x >= 27 then
        if yy >= 64 then return AP.deep end
        if yy == 55 then return AP.shade end
        return lit(nx, ny, AP)
      end
      if x >= 34 and yy >= 46 then
        if yy == 46 then return AP.hi end
        return lit(nx, ny, AP)
      end
      if x >= 35 and yy >= 42 then return MUZ end
      return lit(nx, ny, F)
    end)
    for yy = 41, 46 do P(29 + math.floor((yy - 41) * 1.0), yy + b, AP.base) end
    P(27, 55 + b, AP.base); P(26, 56 + b, AP.shade)
    -- twine strap holding the bundle
    for i = 0, 8 do P(20 + i, 44 + b + math.floor(i * 0.75), TW) end
    foot(32 + RX, RS, false)
    -- head
    ell(28.5, 29 + hd, 12, 11, function(x, y, nx, ny) return lit(nx, ny, F) end)
    -- blunt snout
    ell(39.5, 31.5 + hd, 6.5, 5, function(x, y, nx, ny)
      if ny > 0.3 then return MUZ end
      if ny < -0.5 then return F.base end
      return F.base
    end)
    P(23, 23 + hd, F.hi); P(24, 22 + hd, F.hi); P(22, 24 + hd, F.hi)
    stamp(44, 28 + hd, {".nn.", "nnnn", ".nn."}, {n = NOSE})
    P(45, 28 + hd, CREAM)
    -- mouth + teeth
    P(42, 33 + hd, INK); P(43, 33 + hd, INK); P(41, 32 + hd, INK)
    stamp(42, 34 + hd, {"kcck", "kcsk", "kcsk", ".kk."}, {k = INK, c = CREAM, s = MUZ})
    -- eye, cheek
    P(36, 25 + hd, INK); P(37, 25 + hd, INK); P(36, 26 + hd, INK); P(37, 26 + hd, INK); P(36, 25 + hd, CREAM)
    P(36, 29 + hd, PINK); P(37, 29 + hd, PINK)
    -- ear
    E(22.5, 21 + hd, 3.2, 3.2, F)
    P(22, 21 + hd, F.deep); P(23, 22 + hd, F.deep)
    -- beanie
    ell(27.5, 21 + hd, 11, 11.2, function(x, y, nx, ny)
      if y > 20 + hd then return nil end
      if y >= 18 + hd then
        if y == 20 + hd then return CAP.shade end
        return (x % 2 == 0) and CAP.shade or CAP.base
      end
      if y == 17 + hd then return CAP.shade end
      return lit(nx, ny, CAP)
    end)
    P(22, 12 + hd, CAP.hi); P(21, 13 + hd, CAP.hi)
    -- near arm + paw holding the axe
    local ax = -RX
    E(30 + ax / 2, 48 + b, 3, 3.8, F)
    local hx, hy = 33 + ax, 54 + b
    axe(hx, hy, 1)
    E(hx, hy, 2.6, 2.5, PAW)
    P(hx + 2, hy + 1, INK)
  end
  for key, c in pairs(G) do img:putPixel(key % 64, key // 64, c) end
  N.outline(img, INK)
end
return S
