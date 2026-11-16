-- beetle (six-legged) tables from specs/beetle.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "beetle", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 8, W = 36}
S.ramps = {main = {"#4fae5a", "#4e7a5c", "#36564f", "#2c3646"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#4fae5a", "#4e7a5c", "#36564f", "#2c3646", "#e2b654", "#cfc278", "#e0584e", "#a83a4e", "#b07c44", "#655c56", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#4e7a5c",
  bshade = h"#36564f",
  bhi = h"#4fae5a",
  deep = h"#2c3646",
  head = h"#4e7a5c",
  hat = h"#e2b654",
  hatshade = h"#cfc278",
  wing = h"#36564f",
  belly = h"#b07c44",
  acc = h"#e0584e",
  accs = h"#a83a4e",
  eye = h"#b07c44",
  q = h"#b07c44",
  qshade = h"#e0584e",
  qhi = h"#b07c44",
  ink = h"#2c3646", arm = h"#4e7a5c", fbase = h"#36564f", fshade = h"#2c3646"}
S.bw, S.top = 22, 9
S.quirk = {w = 4, h = 3, anchor = "back", hex = "#b07c44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
  -- palette (look 1)
  local SHL = {spec = H"#cfc278", hi = H"#4fae5a", base = H"#4e7a5c", shade = H"#36564f", deep = H"#2c3646"}
  local STRAW = {hi = H"#cfc278", base = H"#e2b654", shade = H"#b07c44", deep = H"#655c56"}
  local LEAF, LEAFS = H"#4fae5a", H"#4e7a5c"
  local KER, KERS = H"#e0584e", H"#a83a4e"
  local LEG = {hi = H"#cfc278", base = H"#b07c44", shade = H"#655c56", deep = H"#2c3646"}
  local LEGF = {hi = H"#b07c44", base = H"#655c56", shade = H"#2c3646", deep = H"#2c3646"}
  local BELLY, BSEG, BSH = H"#cfc278", H"#e2b654", H"#b07c44"
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
  -- capsule from (x0,y0) to (x1,y1), radius r; colour from side of the axis (lit left, shade right)
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
  local function mx(x) return 63 - x end
  local CX = 31.5
  local function shadow()
    ell(CX, 68.6, 13, 2.2, function(x, y, nx, ny)
      if abs(nx) < 0.62 and ny > -0.5 then return SHB end
      return SHA
    end)
  end
  -- tiny parcel: 5x4 box, ribbon cross, bow on top
  local function parcel(x0, y0)
    local pat = {"..rr..", "hbbRbb", "bbbRbs", "RRRRRR", "bbbRbs", "sssRss"}
    for j, row in ipairs(pat) do
      for i = 1, 6 do
        local ch = row:sub(i, i)
        local x, y = x0 + i - 1, y0 + j - 2
        local c = ({b = LEG.base, s = LEG.shade, h = LEG.hi, R = KER, r = KER})[ch]
        if ch == "R" and (i >= 5 or j == 6) then c = KERS end
        if c then P(x, y, c) end
      end
    end
  end
  local function hat(cx, cy, crx, brx)  -- cy = brim centre row
    ell(cx, cy, brx, 2.3, function(x, y, nx, ny)
      if ny > 0.35 or nx > 0.78 then return STRAW.shade end
      if (x * 2 + y) % 5 == 0 then return STRAW.hi end
      if ny < -0.4 and nx < 0.2 then return STRAW.hi end
      return STRAW.base
    end)
    local x1, x2 = floor(cx - crx + 0.5), floor(cx + crx - 0.5)
    for yy = 0, 4 do
      for x = x1, x2 do
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = STRAW.base
          if x <= x1 + 1 then c = STRAW.hi elseif x >= x2 - 1 then c = STRAW.shade end
          if yy == 0 and x > x1 + 1 and x < x2 - 1 then c = STRAW.hi end
          if yy == 3 then c = (x >= x2 - 1) and LEAFS or LEAF end
          if yy == 2 and (x + yy) % 4 == 0 and c == STRAW.base then c = STRAW.hi end
          P(x, cy - 6 + yy, c)
        end
      end
    end
  end
  local function leafTip(x, y) -- 3x3 leaf, top pixel at (x+1,y)
    P(x + 1, y, LEAF); P(x, y + 1, LEAF); P(x + 1, y + 1, LEAF); P(x + 2, y + 1, LEAFS)
    P(x + 1, y + 2, LEAFS); P(x + 2, y + 2, LEAFS)
  end
  local function stalk(pts) for _, p in ipairs(pts) do P(p[1], p[2], SHL.deep) end end

  if view == "front" or view == "back" then
    local front = view == "front"
    -- viewer-left / viewer-right limb mapping (tripod A = footL: L front, R mid, L back)
    local backVL, backVR, midVL, midVR, armVL, armVR
    if front then backVL, backVR, midVL, midVR, armVL, armVR = o.footR, o.footL, o.footL, o.footR, o.armR, o.armL
    else backVL, backVR, midVL, midVR, armVL, armVR = o.footL, o.footR, o.footR, o.footL, o.armL, o.armR end
    shadow()
    -- hind legs and feet
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and backVL or backVR
      local lx = CX + s * 5
      local bot = 70 + lift
      local R = front and LEG or LEGF
      seg(lx, 60 + b, lx + s * 0.5, bot - 2, 1.2, R)
      P(lx - 1, 64 + b, R.deep); P(lx + 1, 64 + b, R.deep)
      ell(lx + s * 1.2, bot - 0.8, 3.2, 1.6, function(x, y, nx, ny)
        if y >= bot then return R.shade end
        if ny < -0.3 and nx < 0 then return R.hi end
        return R.base
      end)
    end
    -- middle legs (bent, angled out and down)
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and midVL or midVR
      local kx, ky = CX + s * 14.5, 55 + b + lift
      seg(CX + s * 9.5, 53 + b, kx, ky, 0.8, LEG)
      seg(kx, ky, kx + s * 1, ky + 5 + (lift < 0 and 0 or 0), 0.7, front and LEG or LEGF)
      ink(floor(kx + s * 1 + 0.5) + (s > 0 and 0 or 0), floor(ky + 6.5))
    end
    -- arms behind body in back view
    local function arm(a, s, behind)
      local dy = front and a or -a
      local sx, sy = CX + s * 9.5, 42 + b
      local ex, ey = CX + s * 13, 46 + b + dy * 0.5
      local hx, hy = CX + s * 12, 50 + b + dy
      seg(sx, sy, ex, ey, 1.1, behind and LEGF or LEG)
      seg(ex, ey, hx, hy, 0.9, behind and LEGF or LEG)
      local px, py = floor(hx + 0.5), floor(hy + 0.5)
      ink(px - 1, py + 2); ink(px + 1, py + 2)
    end
    if not front then arm(armVL, -1, true); arm(armVR, 1, true) end
    -- body
    if front then
      ell(CX, 51 + b, 11, 12.5, SHL)
      ell(CX, 53.5 + b, 6.5, 9.5, function(x, y, nx, ny)
        local yy = y - b
        if nx > 0.62 or ny > 0.85 then return BSH end
        if yy % 3 == 0 then return BSEG end
        if x == 31 or x == 32 then return (x == 32) and BSEG or BELLY end
        return BELLY
      end)
      for yy = 45, 61 do P(31, yy + b, BSEG) end
      P(25, 43 + b, SHL.spec); P(24, 44 + b, SHL.spec); P(24, 45 + b, SHL.hi)
    else
      ell(CX, 50.5 + b, 12, 14, function(x, y, nx, ny)
        local c = lit(nx, ny, SHL)
        if x == 31 then return SHL.deep end
        if x == 32 and ny < 0.9 then return SHL.hi end
        return c
      end)
      ell(26, 48 + b, 1.6, 1.6, SHL.deep); ell(37.5, 55 + b, 1.6, 1.6, SHL.deep)
      P(23, 42 + b, SHL.spec); P(24, 41 + b, SHL.spec); P(22, 43 + b, SHL.spec); P(22, 44 + b, SHL.hi)
      P(34, 40 + b, SHL.hi); P(35, 40 + b, SHL.hi)
    end
    -- neckerchief
    if front then
      for yy = 0, 6 do
        local hw = 7 - yy
        for x = floor(CX - hw + 0.5), floor(CX + hw - 0.5) do
          local c = KER
          if yy == 0 or x >= CX + hw - 2 or x > CX + 1 and yy >= 4 then c = KERS end
          P(x, 37 + yy + b, c)
        end
      end
      P(27, 38 + b, H"#cfc278")
    else
      for x = 27, 36 do P(x, 37 + b, x > 33 and KERS or KER) end
      P(30, 38 + b, KER); P(31, 38 + b, KER); P(32, 38 + b, KERS); P(33, 38 + b, KERS)
      P(30, 39 + b, KER); P(29, 40 + b, KER); P(33, 39 + b, KERS); P(34, 40 + b, KERS)
    end
    if front then arm(armVL, -1); arm(armVR, 1) end
    -- parcel: front on viewer-right shoulder, back on viewer-left
    local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
    if front then parcel(39 + sw, 35 + b) else parcel(23 + sw, 43 + b) end
    -- head
    ell(CX, 28.5 + hd, 9.5, 8, SHL)
    if front then
      for _, ex in ipairs({26, 36}) do
        for y = 27, 29 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 27 + hd, SHL.spec)
      end
      P(24, 31 + hd, KER); P(25, 31 + hd, KER); P(38, 31 + hd, KER); P(39, 31 + hd, KER)
      P(30, 31 + hd, SHL.spec); P(31, 31 + hd, SHL.hi); P(32, 31 + hd, SHL.hi); P(33, 31 + hd, SHL.base)
      P(31, 32 + hd, SHL.deep); P(32, 32 + hd, SHL.deep)
      P(29, 33 + hd, SHL.deep); P(34, 33 + hd, SHL.deep); P(30, 34 + hd, SHL.deep); P(31, 34 + hd, KERS)
      P(32, 34 + hd, KERS); P(33, 34 + hd, SHL.deep)
    else
      P(26, 24 + hd, SHL.hi); P(27, 24 + hd, SHL.hi); P(25, 25 + hd, SHL.hi)
    end
    hat(CX, 21 + hd, 6, 13)
    -- antennae with leaf tips (lean with the walk)
    local lean = walk and o.armL or 0
    stalk({{28, 13 + hd}, {27, 12 + hd}})
    leafTip(25 + lean, 9 + hd)
    stalk({{35, 13 + hd}, {36, 12 + hd}})
    leafTip(36 + lean, 9 + hd)
  else
    -- side, facing right. near side = creature right
    shadow()
    local nst, fst = 2 * o.armL, -2 * o.armL
    -- far hind leg
    local function hind(x, lift, R)
      local bot = 70 + lift
      seg(x, 59 + b, x + 0.5, bot - 2, 1.2, R)
      ell(x + 2, bot - 0.8, 3.2, 1.6, function(xx, y, nx, ny)
        if y >= bot then return R.shade end
        if ny < -0.3 and nx < 0 then return R.hi end
        return R.base
      end)
    end
    hind(29 + fst / 2, o.footL, LEGF)
    -- far mid leg + far arm
    seg(37, 42 + b, 41 + o.armL, 46 + b, 1.0, LEGF); seg(41 + o.armL, 46 + b, 43 + 2 * o.armL, 50 + b, 0.9, LEGF)
    ink(43 + 2 * o.armL, 52 + b)
    -- belly (front) then shell (back)
    ell(36, 52 + b, 4.6, 9.5, function(x, y, nx, ny)
      local yy = y - b
      if nx > 0.6 or ny > 0.8 then return BSH end
      if yy % 3 == 0 then return BSEG end
      return BELLY
    end)
    ell(28, 50 + b, 9.5, 12.5, function(x, y, nx, ny, d)
      if nx > 0.55 and d > 0.7 then return SHL.deep end
      if nx > 0.35 and d > 0.72 and ny < 0 then return SHL.hi end
      return lit(nx, ny, SHL)
    end)
    P(22, 42 + b, SHL.spec); P(23, 41 + b, SHL.spec); P(21, 43 + b, SHL.spec); P(21, 44 + b, SHL.hi)
    ell(24, 53 + b, 1.5, 1.5, SHL.deep)
    -- parcel on the shell back
    local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
    parcel(16 + sw, 39 + b)
    -- near legs
    hind(34 + nst / 2, o.footR, LEG)
    seg(30, 58 + b, 26, 59 + b + o.footL, 0.9, LEG); seg(26, 59 + b + o.footL, 24, 63 + b + o.footL, 0.8, LEG)
    ink(23, 64 + b + o.footL)
    -- neckerchief collar + tail
    for x = 30, 39 do P(x, 37 + b, x > 36 and KERS or KER) end
    for x = 33, 38 do P(x, 38 + b, x > 36 and KERS or KER) end
    local tw = walk and (frame % 2) or 0
    P(29, 38 + b, KER); P(28, 39 + b, KER); P(29, 39 + b, KERS); P(27 - tw, 40 + b, KERS); P(28 - tw, 40 + b, KER)
    -- near arm
    local a = o.armR
    seg(37, 42 + b, 41 + a, 46 + b, 1.1, LEG); seg(41 + a, 46 + b, 42 + 2 * a, 50 + b, 0.9, LEG)
    ink(41 + 2 * a, 52 + b); ink(43 + 2 * a, 52 + b)
    -- head
    ell(35.5, 28.5 + hd, 8.5, 7.5, SHL)
    ell(42.5, 31.5 + hd, 2.6, 1.8, function(x, y, nx, ny) return ny > 0.4 and SHL.base or SHL.hi end)
    P(42, 30 + hd, SHL.spec); P(45, 32 + hd, SHL.deep)
    for y = 27, 29 do P(39, y + hd, INK); P(40, y + hd, INK) end
    P(39, 27 + hd, SHL.spec)
    P(38, 31 + hd, KER); P(39, 31 + hd, KER)
    P(41, 34 + hd, SHL.deep); P(42, 34 + hd, SHL.deep); P(43, 33 + hd, SHL.deep)
    hat(34.5, 21 + hd, 5.5, 12.5)
    local lean = walk and o.armR or 0
    stalk({{37, 13 + hd}, {38, 12 + hd}})
    leafTip(38 + lean, 9 + hd)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
  for _, p in ipairs(POST) do
    if p[2] <= 71 and p[2] >= top then img:putPixel(p[1], p[2], INK) end
  end
end
return S
