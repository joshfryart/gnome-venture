-- dormouse (biped (mammal)) tables from specs/dormouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "dormouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 38}
S.ramps = {main = {"#c98a5c", "#b97a4a", "#864c33", "#51302b"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c98a5c", "#b97a4a", "#864c33", "#51302b", "#f5b82e", "#d98322", "#f3e2bf", "#f5809f", "#c94f84", "#7d2c5e"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#b97a4a",
  bshade = h"#864c33",
  bhi = h"#c98a5c",
  deep = h"#51302b",
  head = h"#b97a4a",
  hat = h"#f5809f",
  hatshade = h"#c94f84",
  wing = h"#864c33",
  belly = h"#f3e2bf",
  acc = h"#f5b82e",
  accs = h"#d98322",
  eye = h"#f3e2bf",
  q = h"#c94f84",
  qshade = h"#7d2c5e",
  qhi = h"#f3e2bf",
  ink = h"#51302b", arm = h"#b97a4a", fbase = h"#864c33", fshade = h"#51302b"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 4, y = 11, x = {front = 30, back = 30, side = 33}, anchor = "crown", hex = "#c94f84"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local F = {hi = H"#c98a5c", base = H"#b97a4a", shade = H"#864c33", deep = H"#51302b"}
  local FS = {hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local Y = {hi = H"#f5b82e", base = H"#f5b82e", shade = H"#d98322", deep = H"#864c33"}
  local CAP = {hi = H"#f5809f", base = H"#c94f84", shade = H"#7d2c5e"}
  local PINK, CREAM = H"#f5809f", H"#f3e2bf"
  local b, hd = o.body, o.head
  local top = 10 + hd
  local k = frame - 2
  local LX = ({1, -1, -3, -1, 1, 3})[k] or 0
  local RX = ({-1, 1, 3, 1, -1, -3})[k] or 0
  local sw = (o.armL > 0 and 1) or (o.armL < 0 and -1) or 0
  local G = {}
  local function P(x, y, c)
    if c and x >= 14 and x <= 49 and y >= top and y <= 70 then G[y * 64 + x] = c end
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
  -- fluffy tail along a path of points; last third darker
  local function tail(pts, r)
    local n = #pts
    for i = 1, n - 1 do
      local a, c = pts[i], pts[i + 1]
      for s = 0, 3 do
        local t = s / 4
        local px, py = a[1] + (c[1] - a[1]) * t, a[2] + (c[2] - a[2]) * t
        local u = (i - 1 + t) / (n - 1)
        local rr = r * (0.75 + 0.35 * math.sin(u * math.pi))
        ell(px, py, rr, rr, function(x, y, nx, ny)
          if u > 0.72 then return (ny < -0.3) and F.shade or F.deep end
          return lit(nx, ny, F)
        end)
      end
    end
  end
  -- nightcap: front spans {y, x1, x2} (head offset applied), tip to viewer-right
  local CAPR = {{10, 28, 35}, {11, 26, 38}, {12, 25, 40}, {13, 24, 42}, {14, 24, 43}, {15, 24, 39}, {15, 41, 44},
    {16, 24, 39}, {16, 42, 45}, {17, 23, 40}, {18, 23, 40}}
  local function nightcap(mir, dx)
    local function X(x) return mir and (63 - x + dx) or (x + dx) end
    for _, r in ipairs(CAPR) do
      local y, x1, x2 = r[1], r[2], r[3]
      local tip = x1 >= 41 or (y <= 14 and false)
      local shift = (x1 >= 41) and sw or 0
      for x = x1, x2 do
        local c = CAP.base
        if y >= 17 then
          c = (y == 17) and CAP.hi or CAP.base
          if x >= x2 - 1 then c = CAP.shade end
        elseif tip then
          c = (x == x2) and CAP.shade or CAP.base
        else
          if y <= 13 and x <= x1 + 1 then c = CAP.hi end
          if y == 10 and x <= 31 then c = CAP.hi end
          if x >= x2 - 1 then c = CAP.shade end
          if y == 14 and x >= 37 then c = CAP.shade end
          if y == 16 then c = (x >= 35) and CAP.shade or c end
          if y >= 12 and y <= 15 and x == 31 + (15 - y) then c = CAP.shade end
        end
        if mir and y < 17 then
          if c == CAP.hi then c = CAP.base elseif c == CAP.shade and x >= x2 - 1 and not tip then c = CAP.hi end
        end
        P(X(x + shift), y + hd, c)
      end
    end
    local px = 44 + sw
    stamp(mir and (63 - px - 3 + dx) or (px + dx), 16 + hd, {".cc.", "cccc", "cccs", ".cs."}, {c = CREAM, s = F.hi})
  end
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR, armVL, armVR = o.footR, o.footL, o.armR, o.armL
    if not front then ftVL, ftVR, armVL, armVR = o.footL, o.footR, o.armL, o.armR end
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 2, cx + 1 do P(x, y, x >= cx and F.shade or F.base) end end
      ell(cx - 0.5, bot - 1.5, 3, 2, function(x, y, nx, ny)
        if front then
          if y == bot and x == cx - 1 then return INK end
          if y == bot - 1 and x == cx - 2 then return CREAM end
          return PINK
        end
        if y == bot - 2 then return F.shade end
        return lift < 0 and CAP.base or PINK
      end)
    end
    foot(26, ftVL); foot(38, ftVR)
    -- round body in waistcoat
    ell(CX, 54 + b, 12.5, 12.5, function(x, y, nx, ny)
      local yy = y - b
      local ax = math.abs(x - CX)
      if front then
        local hem = 60 + math.floor(ax / 4)
        if yy > hem then return lit(nx, ny, F) end
        if yy == hem then return Y.shade end
        if ax <= 0.5 and yy >= 46 then return Y.shade end
        if yy == 55 and ax >= 6.5 and ax <= 8.5 then return Y.shade end
        return lit(nx, ny, Y)
      end
      if yy >= 61 then return lit(nx, ny, F) end
      if yy == 60 then return Y.deep end
      if yy == 55 and ax <= 6.5 then return Y.shade end
      if yy == 44 and ax <= 9 then return Y.shade end
      if yy == 43 and ax <= 8 then return Y.base end
      return lit(nx, ny, Y)
    end)
    if front then
      P(32, 50 + b, F.deep); P(32, 54 + b, F.deep); P(32, 58 + b, F.deep)
      -- cream napkin tucked into the collar
      stamp(25, 40 + b, {"c..........c", "cccccccccccs", ".cccccccccs.", "..cccccccs..", "...ccccss...", "....ccs.....", ".....c......"},
        {c = CREAM, s = F.hi})
    else
      stamp(30, 54 + b, {"cc", "cs"}, {c = CREAM, s = Y.shade})
      -- big fluffy tail curling up behind
    end
    -- arms with small pink paws
    local function arm(a, side)
      local dy = front and a or -a
      local ax = side < 0 and 19.5 or 43.5
      E(ax + (side < 0 and 1 or -1), 48 + b + dy / 2, 2.6, 4, side < 0 and F or FS)
      ell(ax, 52.5 + b + dy, 2.2, 2, function(x, y, nx, ny)
        if not front then return F.shade end
        if y == math.floor(53.5 + b + dy) + 1 and x == math.floor(ax) then return CAP.base end
        return PINK
      end)
    end
    arm(armVL, -1); arm(armVR, 1)
    if not front then
      tail({{32, 64 + b}, {38, 64.5 + b}, {43, 62 + b}, {45.5, 57 + b}, {46.5, 51 + b}, {46 + sw * 0.5, 46 + b}, {44.5 + sw, 42 + b}}, 2.7)
      for _, t in ipairs({{39, 64}, {44, 60}, {46, 54}}) do P(t[1], t[2] + b, F.shade) end
    end
    -- ears
    for _, s in ipairs({-1, 1}) do
      local ex = s < 0 and 19 or 44
      ell(ex, 18 + hd, 4.9, 4.9, function(x, y, nx, ny, d)
        if front and d < 0.42 then return (ny > 0.2) and CAP.base or PINK end
        if not front and d < 0.42 then return F.shade end
        return lit(nx, ny, F)
      end)
    end
    -- head
    ell(CX, 29.5 + hd, 13, 10.5, function(x, y, nx, ny)
      return lit(nx, ny, F)
    end)
    -- cheek fluff
    P(18, 31 + hd, F.base); P(18, 33 + hd, F.base); P(45, 32 + hd, F.shade); P(45, 34 + hd, F.shade)
    if front then
      P(22, 23 + hd, CREAM); P(23, 22 + hd, F.hi); P(24, 22 + hd, CREAM)
      -- cream muzzle
      ell(CX, 34 + hd, 5.2, 3.2, function(x, y, nx, ny)
        if ny > 0.6 and nx > 0 then return F.hi end
        return CREAM
      end)
      -- sleepy eyes: heavy lid, ink pill, glint
      for _, ex in ipairs({25, 37}) do
        for y = 27, 29 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 27 + hd, CREAM); P(ex + 2, 26 + hd, F.shade)
      end
      P(22, 32 + hd, PINK); P(23, 32 + hd, PINK); P(40, 32 + hd, PINK); P(41, 32 + hd, PINK)
      stamp(30, 31 + hd, {".pp.", "pkkp", ".kk.", "....", "k..k", ".kk."},
        {p = CAP.base, k = INK})
      P(31, 31 + hd, PINK)
      -- whiskers
      P(25, 34 + hd, F.deep); P(24, 35 + hd, F.deep); P(38, 34 + hd, F.deep); P(39, 35 + hd, F.deep)
      nightcap(false, 0)
    else
      -- fur tufts on the back of the head
      for _, t in ipairs({{25, 25}, {26, 24}, {30, 26}, {31, 25}, {35, 24}, {28, 30}, {29, 29}}) do
        local c = get(t[1], t[2] + hd)
        if c == F.base or c == F.hi then P(t[1], t[2] + hd, F.hi) end
      end
      for _, t in ipairs({{38, 32}, {39, 31}, {27, 35}, {32, 35}, {33, 36}}) do P(t[1], t[2] + hd, F.shade) end
      nightcap(true, 0)
    end
  else
    -- side view, facing right
    local function foot(cx, lift, far)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, far and F.deep or (x == cx + 1 and F.shade or F.base)) end end
      ell(cx + 1, bot - 1.5, 3.4, 1.9, function(x, y, nx, ny)
        if y == bot and x == math.floor(cx + 3) then return INK end
        if far then return F.shade end
        if y == bot - 1 and x == cx - 1 then return CREAM end
        return PINK
      end)
    end
    -- long tail trailing behind, curling up
    local tw = sw * 0.6
    tail({{24, 63 + b}, {20, 62.5 + b}, {17, 60 + b}, {16 + tw, 55 + b}, {16.5 + tw, 50 + b}, {18 + tw, 46 + b}, {20.5 + tw, 43.5 + b}}, 2.4)
    foot(26 + LX, o.footL, true)
    local fax = -LX
    E(37 + fax, 51 + b, 2.2, 2, F.shade)
    -- body
    ell(30, 54 + b, 10.5, 12, function(x, y, nx, ny)
      local yy = y - b
      local hem = 60 + math.floor(math.max(0, x - 30) / 3)
      if yy > hem then return lit(nx, ny, F) end
      if yy == hem then return Y.shade end
      if x == 36 and yy >= 47 then return Y.shade end
      if yy == 55 and x >= 30 and x <= 32 then return Y.shade end
      return lit(nx, ny, Y)
    end)
    P(38, 50 + b, F.deep); P(38, 54 + b, F.deep)
    stamp(33, 41 + b, {"cccccc", ".ccccs", "..cccs", "...cs.", "....c."}, {c = CREAM, s = F.hi})
    foot(31 + RX, o.footR, false)
    -- near arm
    local ax = -RX
    for t = 0, 5 do
      local xx = math.floor(33 + ax * t / 5 + 0.5)
      P(xx - 1, 46 + t + b, F.hi); P(xx, 46 + t + b, F.base); P(xx + 1, 46 + t + b, F.shade); P(xx + 2, 46 + t + b, F.deep)
    end
    ell(35 + ax, 52.5 + b, 2.4, 2.2, function(x, y, nx, ny)
      if x == math.floor(37 + ax) and y == 53 + b then return CAP.base end
      return PINK
    end)
    -- ear behind the cap
    ell(20.5, 20.5 + hd, 4.6, 4.6, function(x, y, nx, ny, d)
      if d < 0.4 then return (ny > 0.2) and CAP.base or PINK end
      return lit(nx, ny, F)
    end)
    -- head
    ell(30, 30 + hd, 11.5, 10.5, function(x, y, nx, ny)
      if x < 24 and nx < -0.55 and ny > -0.3 and get(x, y) == nil and false then return nil end
      return lit(nx, ny, F)
    end)
    -- re-draw the ear rim over the head edge so it reads in front
    ell(20.5, 20.5 + hd, 4.6, 4.6, function(x, y, nx, ny, d)
      if y > 23 + hd then return nil end
      if d < 0.4 then return (ny > 0.2) and CAP.base or PINK end
      return lit(nx, ny, F)
    end)
    -- snout with cream muzzle
    ell(39.5, 32.5 + hd, 5.8, 3.8, function(x, y, nx, ny)
      if ny > 0.35 then return (nx > 0.5) and F.hi or CREAM end
      return ny < -0.5 and F.hi or F.base
    end)
    stamp(45, 30 + hd, {".pp", "ppk", ".p."}, {p = CAP.base, k = INK})
    P(45, 31 + hd, PINK)
    P(43, 34 + hd, F.shade)
    -- sleepy eye
    for y = 27, 29 do P(36, y + hd, INK); P(37, y + hd, INK) end
    P(36, 27 + hd, CREAM); P(38, 26 + hd, F.shade)
    P(35, 32 + hd, PINK); P(36, 32 + hd, PINK)
    P(42, 33 + hd, F.deep); P(43, 32 + hd, F.deep)
    P(22, 26 + hd, F.hi); P(21, 27 + hd, CREAM)
    nightcap(true, -1)
  end
  for key, c in pairs(G) do img:putPixel(key % 64, key // 64, c) end
  N.outline(img, INK)
end
return S
