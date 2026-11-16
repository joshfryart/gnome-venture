-- ladybird (six-legged) tables from specs/ladybird.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "ladybird", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 9, W = 40}
S.ramps = {main = {"#e8584a", "#d93a30", "#a52638", "#7a2030"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8584a", "#d93a30", "#a52638", "#7a2030", "#4f4164", "#3d3150", "#3a2c48", "#f0cc6a", "#c99a48", "#6aa84a", "#f4e2bc", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#d93a30",
  bshade = h"#a52638",
  bhi = h"#e8584a",
  deep = h"#7a2030",
  head = h"#4f4164",
  hat = h"#f0cc6a",
  hatshade = h"#c99a48",
  wing = h"#e8584a",
  belly = h"#3d3150",
  acc = h"#4f4164",
  accs = h"#3d3150",
  eye = h"#3d3150",
  q = h"#d93a30",
  qshade = h"#3d3150",
  qhi = h"#d93a30",
  ink = h"#7a2030", arm = h"#d93a30", fbase = h"#a52638", fshade = h"#7a2030"}
S.bw, S.top = 22, 10
S.quirk = {w = 3, h = 4, anchor = "hand", hex = "#d93a30"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local floor, abs, max, min = math.floor, math.abs, math.max, math.min
  -- palette (look 1)
  local CREAM = H"#f4e2bc"
  local WC = {spec = CREAM, hi = H"#e8584a", base = H"#d93a30", shade = H"#a52638", deep = H"#7a2030"}
  local HEAD = {hi = H"#4f4164", base = H"#4f4164", shade = H"#3d3150", deep = H"#3a2c48"}
  local LEG = {hi = H"#4f4164", base = H"#4f4164", shade = H"#3d3150", deep = H"#3a2c48"}
  local LEGF = {hi = H"#3d3150", base = H"#3d3150", shade = H"#3a2c48", deep = H"#3a2c48"}
  local STRAW = {hi = CREAM, base = H"#f0cc6a", shade = H"#c99a48"}
  local BAND = H"#6aa84a"
  local SPOT = H"#3d3150"
  local SHA, SHB = H"#aaa9b8", H"#74758c"
  local b, hd = o.body, o.head
  local walk = frame >= 3
  local top = species.T + 1 + hd
  local G, POST = {}, {}
  local function P(x, y, c)
    x, y = floor(x + 0.5), floor(y + 0.5)
    if c and x >= 2 and x <= 61 and y >= top and y <= 70 then G[y * 64 + x] = c end
  end
  local function ink(x, y) POST[#POST + 1] = {x, y} end
  local function lit(nx, ny, R)
    local s = nx * 0.6 + ny * 0.8
    if s > 0.88 then return R.deep end
    if s > 0.38 then return R.shade end
    if s < -0.5 then return R.hi end
    return R.base
  end
  local function ell(cx, cy, rx, ry, R)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then
          local c = R
          if type(R) == "function" then c = R(x, y, nx, ny, d) elseif type(R) == "table" then c = lit(nx, ny, R) end
          P(x, y, c)
        end
      end
    end
  end
  local function seg(x0, y0, x1, y1, r, R)
    local dx, dy = x1 - x0, y1 - y0
    local L2 = dx * dx + dy * dy
    for y = floor(min(y0, y1) - r - 1), floor(max(y0, y1) + r + 1) do
      for x = floor(min(x0, x1) - r - 1), floor(max(x0, x1) + r + 1) do
        local t = L2 > 0 and max(0, min(1, ((x - x0) * dx + (y - y0) * dy) / L2)) or 0
        local ex, ey = x - (x0 + t * dx), y - (y0 + t * dy)
        if ex * ex + ey * ey <= r * r then
          if type(R) == "table" then
            local s = (ex * 0.7 + ey * 0.7) / max(r, 0.5)
            P(x, y, s > 0.3 and R.shade or (s < -0.6 and R.hi or R.base))
          else P(x, y, R) end
        end
      end
    end
  end
  local function spot(x, y) P(x, y, SPOT); P(x + 1, y, SPOT); P(x, y + 1, SPOT); P(x + 1, y + 1, SPOT) end
  local CX = 31.5
  local function shadow()
    ell(CX, 68.6, 14, 2.2, function(x, y, nx, ny)
      if abs(nx) < 0.62 and ny > -0.5 then return SHB end
      return SHA
    end)
  end
  -- spotted umbrella bag: 4x5 red bag, spots, 1 px ink handle loop above (hx = handle top x)
  local function bag(x0, y0)
    local pat = {"hbbb", "bSbs", "bbbs", "Sbss", "ssss"}
    for j, row in ipairs(pat) do
      for i = 1, 4 do
        local ch = row:sub(i, i)
        P(x0 + i - 1, y0 + j - 1, ({h = WC.hi, b = WC.base, s = WC.shade, S = SPOT})[ch])
      end
    end
    P(x0 + 1, y0 + 5, WC.shade); P(x0 + 2, y0 + 5, WC.deep) -- folded umbrella tip
    ink(x0, y0 - 1); ink(x0 + 3, y0 - 1); ink(x0 + 1, y0 - 2); ink(x0 + 2, y0 - 2)
  end
  local function hat(cx, cy, crx, brx)
    ell(cx, cy, brx, 2.4, function(x, y, nx, ny)
      if ny > 0.35 or nx > 0.8 then return STRAW.shade end
      if ny < -0.4 and nx < 0.1 then return STRAW.hi end
      if (x + 2 * y) % 6 == 0 then return STRAW.shade end
      return STRAW.base
    end)
    local x1, x2 = floor(cx - crx + 0.5), floor(cx + crx - 0.5)
    for yy = 0, 5 do
      for x = x1, x2 do
        if not (yy == 0 and (x <= x1 + 1 or x >= x2 - 1)) then
          local c = STRAW.base
          if x <= x1 + 1 then c = STRAW.hi elseif x >= x2 - 1 then c = STRAW.shade end
          if yy == 0 and x > x1 + 1 and x < x2 - 1 then c = (x < cx) and STRAW.hi or STRAW.base end
          if yy == 1 and x == floor(cx) then c = STRAW.shade end
          if yy == 4 then c = (x >= x2 - 1) and LEG.shade or BAND end
          P(x, cy - 7 + yy, c)
        end
      end
    end
  end
  local function knob(x, y) -- 3x3 diamond, top at (x+1,y)
    P(x + 1, y, HEAD.base); P(x, y + 1, HEAD.base); P(x + 1, y + 1, HEAD.shade); P(x + 2, y + 1, HEAD.deep)
    P(x + 1, y + 2, HEAD.deep)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local backVL, backVR, midVL, midVR, armVL, armVR
    if front then backVL, backVR, midVL, midVR, armVL, armVR = o.footR, o.footL, o.footL, o.footR, o.armR, o.armL
    else backVL, backVR, midVL, midVR, armVL, armVR = o.footL, o.footR, o.footR, o.footL, o.armL, o.armR end
    shadow()
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and backVL or backVR
      local lx = CX + s * 6
      local bot = 70 + lift
      seg(lx, 60 + b, lx + s * 0.5, bot - 2, 1.2, LEG)
      ell(lx + s * 1.2, bot - 0.8, 3.2, 1.6, function(x, y, nx, ny)
        if y >= bot then return LEG.deep end
        if ny < -0.3 and nx < 0 then return LEG.hi end
        return LEG.shade
      end)
    end
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and midVL or midVR
      local kx, ky = CX + s * 16, 55 + b + lift
      seg(CX + s * 11, 53 + b, kx, ky, 0.9, LEG)
      seg(kx, ky, kx + s * 0.5, ky + 5, 0.7, front and LEG or LEGF)
      ink(floor(kx + s * 0.5 + 0.5), floor(ky + 6.5))
    end
    local function arm(a, s, behind)
      local dy = front and a or -a
      local sx, sy = CX + s * 10.5, 43 + b
      local ex, ey = CX + s * 14, 47 + b + dy * 0.5
      local hx, hy = CX + s * 13.5, 51 + b + dy
      seg(sx, sy, ex, ey, 1.1, behind and LEGF or LEG)
      seg(ex, ey, hx, hy, 0.9, behind and LEGF or LEG)
      local px, py = floor(hx + 0.5), floor(hy + 0.5)
      ink(px - 1, py + 2); ink(px + 1, py + 2)
      return px, py
    end
    if not front then arm(armVL, -1, true); arm(armVR, 1, true) end
    local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
    if front then
      -- wing-cases open at the front over a dark belly
      ell(CX, 51 + b, 13.5, 13, function(x, y, nx, ny)
        local yy = y - b
        local gap = 1.2 + max(0, yy - 41) * 0.32
        if abs(x - CX) < gap then
          if yy % 3 == 0 then return HEAD.deep end
          return (x > CX) and HEAD.shade or HEAD.base
        end
        if abs(x - CX) < gap + 1 then return WC.deep end
        return lit(nx, ny, WC)
      end)
      spot(22, 45 + b); spot(20, 52 + b); spot(25, 57 + b)
      spot(40, 45 + b); spot(42, 52 + b); spot(37, 57 + b)
      P(23, 42 + b, CREAM); P(22, 43 + b, CREAM); P(21, 44 + b, WC.hi)
      -- cream shoulder patches (pronotum)
      ell(26, 39 + b, 2.6, 1.6, CREAM); ell(37, 39 + b, 2.6, 1.6, CREAM)
      ell(CX, 39 + b, 2.6, 1.6, HEAD.shade)
    else
      ell(CX, 49.5 + b, 14, 15, function(x, y, nx, ny)
        if x == 31 then return WC.deep end
        if x == 32 then return WC.shade end
        return lit(nx, ny, WC)
      end)
      for _, p in ipairs({{24, 40}, {20, 47}, {26, 49}, {21, 56}, {27, 59}}) do
        spot(p[1], p[2] + b); spot(62 - p[1], p[2] + b)
      end
      P(22, 41 + b, CREAM); P(21, 42 + b, CREAM); P(23, 40 + b, CREAM); P(20, 43 + b, WC.hi); P(20, 44 + b, WC.hi)
      P(35, 38 + b, WC.hi); P(36, 38 + b, WC.hi)
    end
    if front then
      arm(armVL, -1)
      local px, py = arm(armVR, 1)
      bag(px - 1 + sw, py + 3)
    else
      bag(13 + sw, 45 + b)
      ink(15 + sw, 42 + b); ink(16, 41 + b) -- strap to the shoulder
    end
    -- head
    ell(CX, 29.5 + hd, 9.5, 7.8, HEAD)
    if front then
      -- cream face patches
      ell(25, 32 + hd, 2, 1.6, CREAM); ell(38, 32 + hd, 2, 1.6, CREAM)
      for _, ex in ipairs({26, 35}) do
        for y = 27, 29 do for x = ex, ex + 2 do P(x, y + hd, CREAM) end end
        P(ex + 1, 28 + hd, INK); P(ex + 2, 28 + hd, INK); P(ex + 1, 29 + hd, INK); P(ex + 2, 29 + hd, INK)
        if ex == 35 then P(ex, 28 + hd, INK); P(ex, 29 + hd, INK); P(ex + 2, 28 + hd, CREAM); P(ex + 2, 29 + hd, CREAM) end
      end
      P(24, 33 + hd, WC.hi); P(39, 33 + hd, WC.hi)
      ell(CX, 33.5 + hd, 3.2, 2.2, function(x, y, nx, ny) return ny < -0.3 and HEAD.hi or HEAD.base end)
      P(31, 32 + hd, HEAD.deep); P(32, 32 + hd, HEAD.deep)
      P(29, 34 + hd, HEAD.deep); P(30, 35 + hd, HEAD.deep); P(31, 35 + hd, WC.shade); P(32, 35 + hd, WC.shade)
      P(33, 35 + hd, HEAD.deep); P(34, 34 + hd, HEAD.deep)
    else
      P(27, 25 + hd, HEAD.hi)
      ell(CX, 35 + hd, 6, 1.5, HEAD.shade)
    end
    hat(CX, 22 + hd, 6.5, 14.5)
    local lean = walk and o.armL or 0
    P(27, 14 + hd, HEAD.deep); P(26, 13 + hd, HEAD.deep)
    knob(23 + lean, 10 + hd)
    P(36, 14 + hd, HEAD.deep); P(37, 13 + hd, HEAD.deep)
    knob(38 + lean, 10 + hd)
  else
    shadow()
    local nst, fst = 2 * o.armL, -2 * o.armL
    local function hind(x, lift, R)
      local bot = 70 + lift
      seg(x, 59 + b, x + 0.5, bot - 2, 1.2, R)
      ell(x + 2, bot - 0.8, 3.2, 1.6, function(xx, y, nx, ny)
        if y >= bot then return R.deep end
        if ny < -0.3 and nx < 0 then return R.hi end
        return R.shade
      end)
    end
    hind(28 + fst / 2, o.footL, LEGF)
    -- far arm holds the bag forward
    local fa = o.armL
    seg(37, 43 + b, 42 + fa, 46 + b, 1.0, LEGF); seg(42 + fa, 46 + b, 44 + fa, 49 + b, 0.9, LEGF)
    local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
    bag(43 + fa, 51 + b)
    -- belly then wing-case dome
    ell(36, 53 + b, 4.6, 9, function(x, y, nx, ny)
      local yy = y - b
      if yy % 3 == 0 then return HEAD.deep end
      return nx > 0.4 and HEAD.shade or HEAD.base
    end)
    ell(27.5, 50 + b, 11.5, 13, function(x, y, nx, ny, d)
      if nx > 0.55 and d > 0.7 then return WC.deep end
      return lit(nx, ny, WC)
    end)
    spot(24, 44 + b); spot(29, 54 + b); spot(20, 55 + b)
    P(21, 41 + b, CREAM); P(22, 40 + b, CREAM); P(20, 42 + b, CREAM); P(19, 43 + b, WC.hi); P(19, 44 + b, WC.hi)
    ell(36, 39 + b, 2.6, 1.6, CREAM)
    -- near legs
    hind(34 + nst / 2, o.footR, LEG)
    seg(30, 59 + b, 25, 60 + b + o.footL, 0.9, LEG); seg(25, 60 + b + o.footL, 23, 64 + b + o.footL, 0.8, LEG)
    ink(22, 65 + b + o.footL)
    local a = o.armR
    seg(37, 44 + b, 40 + a, 48 + b, 1.1, LEG); seg(40 + a, 48 + b, 41 + 2 * a, 52 + b, 0.9, LEG)
    ink(40 + 2 * a, 54 + b); ink(42 + 2 * a, 54 + b)
    -- head
    ell(37.5, 30 + hd, 8, 7.2, HEAD)
    ell(43.5, 33 + hd, 2.6, 2, function(x, y, nx, ny) return ny < -0.3 and HEAD.hi or HEAD.base end)
    ell(39, 33 + hd, 1.6, 1.2, CREAM)
    for y = 27, 29 do P(40, y + hd, CREAM); P(41, y + hd, CREAM); P(42, y + hd, CREAM) end
    P(41, 28 + hd, INK); P(42, 28 + hd, INK); P(41, 29 + hd, INK); P(42, 29 + hd, INK)
    P(46, 33 + hd, HEAD.deep); P(43, 35 + hd, HEAD.deep); P(44, 35 + hd, WC.shade); P(45, 34 + hd, HEAD.deep)
    hat(36.5, 22 + hd, 6, 13)
    local lean = walk and o.armR or 0
    P(39, 14 + hd, HEAD.deep); P(40, 13 + hd, HEAD.deep)
    knob(40 + lean, 10 + hd)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
  for _, p in ipairs(POST) do
    if p[2] <= 71 and p[2] >= top then img:putPixel(p[1], p[2], INK) end
  end
end
return S
