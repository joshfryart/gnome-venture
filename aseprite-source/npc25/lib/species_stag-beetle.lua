-- stag-beetle (six-legged) tables from specs/stag-beetle.md. Opus: replace S.draw_figure only (body-plan helper: D.sixleg).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "stag-beetle", feet_y = 71, outline = "#2b1c26", plan = "sixleg", T = 8, W = 40}
S.ramps = {main = {"#c89d62", "#9a5f36", "#64394a", "#3d2438"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c89d62", "#9a5f36", "#64394a", "#3d2438", "#7cc35a", "#3f9150", "#e8493b", "#b52e3f", "#aaa9b8", "#fff4d6", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, -1, -1, 0, 0}, {-1, -1, -2, 0, -1, 1}, {0, 0, -1, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {-1, -1, 0, 0, 1, -1}}
local h = N.hex
S.c = {
  body = h"#9a5f36",
  bshade = h"#64394a",
  bhi = h"#c89d62",
  deep = h"#3d2438",
  head = h"#9a5f36",
  hat = h"#7cc35a",
  hatshade = h"#3f9150",
  wing = h"#64394a",
  belly = h"#fff4d6",
  acc = h"#7cc35a",
  accs = h"#3f9150",
  eye = h"#fff4d6",
  q = h"#e8493b",
  qshade = h"#b52e3f",
  qhi = h"#aaa9b8",
  ink = h"#3d2438", arm = h"#9a5f36", fbase = h"#64394a", fshade = h"#3d2438"}
S.bw, S.top = 22, 9
S.quirk = {w = 3, h = 4, anchor = "hand", hex = "#e8493b"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
-- Stage 3 art: a stout chestnut stag-beetle knight with green antler-jaws and a tiny red shield.
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local floor, abs, max, min = math.floor, math.abs, math.max, math.min
  local CREAM = H"#fff4d6"
  local SHL = {spec = CREAM, hi = H"#c89d62", base = H"#9a5f36", shade = H"#64394a", deep = H"#3d2438"}
  local LEG = {hi = H"#9a5f36", base = H"#9a5f36", shade = H"#64394a", deep = H"#3d2438"}
  local LEGF = {hi = H"#64394a", base = H"#64394a", shade = H"#3d2438", deep = H"#3d2438"}
  local JAW = {hi = H"#7cc35a", base = H"#7cc35a", shade = H"#3f9150", deep = H"#3f9150"}
  local JAWF = {hi = H"#3f9150", base = H"#3f9150", shade = H"#3f9150", deep = H"#3f9150"}
  local RED, REDS, RIM, RIMS = H"#e8493b", H"#b52e3f", H"#aaa9b8", H"#74758c"
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
    if s > 0.36 then return R.shade end
    if s < -0.52 then return R.hi end
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
  local function poly(pts, r, R)
    for i = 1, #pts - 1 do seg(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], r, R) end
  end
  local CX = 31.5
  local function shadow(w)
    ell(CX, 68.6, w or 14, 2.2, function(x, y, nx, ny)
      if abs(nx) < 0.62 and ny > -0.5 then return SHB end
      return SHA
    end)
  end
  -- heater shield, rim grey, cream glint (wide = facing viewer, else edge-on)
  local function shield(x0, y0, wide)
    local pat = wide and {"ggggggm", "gcrrrsm", "grrrrsm", "grrrrsm", "grrrssm", ".grrsm.", "..gsm..", "...m..."}
      or {"ggggm", "gcrsm", "grrsm", "grrsm", "grssm", ".gsm.", "..m.."}
    for j, row in ipairs(pat) do
      for i = 1, #row do
        local c = ({g = RIM, m = RIMS, c = CREAM, r = RED, s = REDS})[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  -- one antler-jaw; m = mirror (+1 viewer-left, -1 viewer-right), y0 = head row offset
  local function jaw(m, y0, R, dx)
    dx = dx or 0
    local function X(x) return m > 0 and x + dx or 63 - x + dx end
    poly({{X(25), 31 + y0}, {X(19.5), 27.5 + y0}, {X(16.5), 21 + y0}}, 1.45, R)
    poly({{X(16.5), 21 + y0}, {X(16.5), 15 + y0}, {X(19), 10.5 + y0}}, 1.05, R)
    seg(X(19), 10.5 + y0, X(21.5), 9 + y0, 0.6, R)           -- tip hooks inward
    seg(X(16.5), 19.5 + y0, X(20.5), 17.5 + y0, 0.6, R)       -- inner tine
    P(X(16), 22 + y0, R.hi); P(X(15.5), 17 + y0, R.hi)
  end
  local function foot(x, bot, R, dir)
    ell(x + dir * 1.2, bot - 0.8, 3.2, 1.6, function(xx, y, nx, ny)
      if y >= bot then return R.deep end
      if ny < -0.3 and nx < 0 then return R.hi end
      return R.shade
    end)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local backVL, backVR, midVL, midVR, armVL, armVR
    if front then backVL, backVR, midVL, midVR, armVL, armVR = o.footR, o.footL, o.footL, o.footR, o.armR, o.armL
    else backVL, backVR, midVL, midVR, armVL, armVR = o.footL, o.footR, o.footR, o.footL, o.armL, o.armR end
    shadow()
    -- hind legs: stout, planted
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and backVL or backVR
      local lx = CX + s * 6
      local bot = 70 + lift
      seg(lx, 60 + b, lx + s * 0.6, bot - 2, 1.3, LEG)
      P(lx - s, 64 + b, LEG.deep)
      foot(lx, bot, LEG, s)
    end
    -- middle legs: spiky, out to the sides
    for _, s in ipairs({-1, 1}) do
      local lift = s < 0 and midVL or midVR
      local kx, ky = CX + s * 15.5, 53 + b + lift
      seg(CX + s * 10, 54 + b, kx, ky, 0.8, LEG)
      seg(kx, ky, kx + s * 1.5, ky + 6, 0.7, front and LEG or LEGF)
      P(kx + s * 0.5, ky + 2, LEG.deep)
      ink(floor(kx + s * 1.5 + 0.5), floor(ky + 7.5))
    end
    local function arm(a, s, behind)
      local dy = front and a or -a
      local sx, sy = CX + s * 10, 42 + b
      local ex, ey = CX + s * 14, 46 + b + dy * 0.5
      local hx, hy = CX + s * 13, 50 + b + dy
      seg(sx, sy, ex, ey, 1.1, behind and LEGF or LEG)
      seg(ex, ey, hx, hy, 0.9, behind and LEGF or LEG)
      local px, py = floor(hx + 0.5), floor(hy + 0.5)
      ink(px - 1, py + 2); ink(px + 1, py + 2)
      return px, py
    end
    if not front then arm(armVL, -1, true); arm(armVR, 1, true) end
    if front then
      -- elytra edges wrap the chest plate
      ell(CX, 51.5 + b, 12, 12.5, SHL)
      ell(CX, 53 + b, 7.5, 10, function(x, y, nx, ny)
        local yy = y - b
        if nx > 0.55 or ny > 0.8 then return SHL.deep end
        if x == 31 then return SHL.deep end
        if yy % 4 == 1 then return SHL.shade end
        if nx < -0.4 and ny < 0.2 then return SHL.hi end
        return SHL.base
      end)
      P(23, 44 + b, SHL.spec); P(22, 45 + b, SHL.hi); P(22, 46 + b, SHL.hi)
      -- pronotum collar
      ell(CX, 40 + b, 9.5, 2.8, function(x, y, nx, ny)
        if ny < -0.2 and nx < 0.2 then return SHL.hi end
        if nx > 0.6 or ny > 0.5 then return SHL.shade end
        return SHL.base
      end)
    else
      -- elytra dome with split, then pronotum plate on top
      ell(CX, 52 + b, 12.5, 12.5, function(x, y, nx, ny)
        if x == 31 then return SHL.deep end
        if x == 32 and ny > -0.95 then return SHL.hi end
        if (x == 25 or x == 38) and ny > -0.6 and ny < 0.75 then return SHL.shade end
        return lit(nx, ny, SHL)
      end)
      P(22, 46 + b, SHL.spec); P(23, 45 + b, SHL.spec); P(21, 47 + b, SHL.hi); P(21, 48 + b, SHL.hi)
      ell(CX, 40 + b, 10.5, 3.6, function(x, y, nx, ny)
        if ny > 0.55 then return SHL.deep end
        if ny < -0.1 and nx < 0 then return SHL.hi end
        if nx > 0.55 then return SHL.shade end
        return SHL.base
      end)
      P(25, 38 + b, SHL.spec)
    end
    -- jaws (behind the head in back view, drawn first either way)
    jaw(1, hd, front and JAW or JAWF); jaw(-1, hd, front and JAW or JAWF)
    if front then
      arm(armVR, 1)
      local px, py = arm(armVL, -1)
      local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
      shield(px - 3 + sw, py - 4, true)
    end
    -- head: broad and flat
    ell(CX, 30 + hd, 10.5, 7, SHL)
    if front then
      for _, e in ipairs({{25, 1}, {36, 0}}) do
        local ex = e[1]
        for y = 28, 30 do for x = ex, ex + 2 do P(x, y + hd, CREAM) end end
        P(ex + e[2], 29 + hd, INK); P(ex + e[2] + 1, 29 + hd, INK); P(ex + e[2], 30 + hd, INK); P(ex + e[2] + 1, 30 + hd, INK)
      end
      -- stern little brows and a small smile
      P(25, 27 + hd, SHL.deep); P(26, 27 + hd, SHL.deep); P(27, 26 + hd, SHL.deep)
      P(38, 27 + hd, SHL.deep); P(37, 27 + hd, SHL.deep); P(36, 26 + hd, SHL.deep)
      P(23, 32 + hd, REDS); P(40, 32 + hd, REDS)
      P(30, 33 + hd, SHL.deep); P(31, 34 + hd, SHL.deep); P(32, 34 + hd, SHL.deep); P(33, 33 + hd, SHL.deep)
      P(27, 25 + hd, SHL.spec); P(28, 25 + hd, SHL.hi)
    else
      P(26, 26 + hd, SHL.spec); P(27, 25 + hd, SHL.hi); P(28, 25 + hd, SHL.hi)
      for x = 27, 36 do P(x, 35 + hd, SHL.deep) end
    end
  else
    -- side, facing right
    shadow(13)
    local st = walk and 2 * o.armL or 0
    -- far hind leg
    local function hind(x, lift, R)
      local bot = 70 + lift
      seg(x, 59 + b, x + 0.5, bot - 2, 1.3, R)
      foot(x + 1, bot, R, 1)
    end
    hind(27 - st, o.footL, LEGF)
    -- far mid leg (behind, angled back) and far arm
    seg(22, 55 + b, 17, 57 + b + o.footR, 0.8, LEGF); seg(17, 57 + b + o.footR, 16, 62 + b + o.footR, 0.7, LEGF)
    ink(16, 64 + b + o.footR)
    local fa = o.armL
    seg(35, 42 + b, 39 + fa, 46 + b, 1.0, LEGF); seg(39 + fa, 46 + b, 41 + 2 * fa, 50 + b, 0.9, LEGF)
    ink(41 + 2 * fa, 52 + b)
    -- belly plate then elytra profile
    ell(34, 52.5 + b, 4.6, 9.5, function(x, y, nx, ny)
      local yy = y - b
      if yy % 4 == 1 then return SHL.deep end
      if nx > 0.5 or ny > 0.8 then return SHL.deep end
      return SHL.shade
    end)
    ell(27, 51 + b, 9.5, 12.5, function(x, y, nx, ny, d)
      if nx > 0.5 and d > 0.72 then return SHL.deep end
      return lit(nx, ny, SHL)
    end)
    P(20, 43 + b, SHL.spec); P(21, 42 + b, SHL.spec); P(19, 44 + b, SHL.hi); P(19, 45 + b, SHL.hi); P(19, 46 + b, SHL.hi)
    for y = 46, 59 do P(y < 52 and 22 or 23, y + b, SHL.shade) end
    -- pronotum
    ell(32, 40 + b, 7.5, 3.4, function(x, y, nx, ny)
      if ny > 0.55 then return SHL.deep end
      if ny < -0.1 and nx < 0.1 then return SHL.hi end
      if nx > 0.6 then return SHL.shade end
      return SHL.base
    end)
    -- near hind leg and near mid leg
    hind(31 + st, o.footR, LEG)
    seg(28, 58 + b, 23, 60 + b + o.footL, 0.9, LEG); seg(23, 60 + b + o.footL, 21, 64 + b + o.footL, 0.8, LEG)
    ink(20, 65 + b + o.footL)
    -- far jaw, head, near jaw
    local function sjaw(dx, dy, R, e)
      e = e or 0
      local C = e > 0 and INK or R
      poly({{42 + dx, 33 + hd + dy}, {46.5 + dx, 30 + hd + dy}, {49 + dx, 24 + hd + dy}}, 1.35 + e, C)
      poly({{49 + dx, 24 + hd + dy}, {49 + dx, 17 + hd + dy}, {46.5 + dx, 12 + hd + dy}}, 1.0 + e, C)
      seg(46.5 + dx, 12 + hd + dy, 44.5 + dx, 9.5 + hd + dy, 0.6 + e, C)
      seg(49 + dx, 21 + hd + dy, 45.5 + dx, 19 + hd + dy, 0.6 + e, C)
      if e == 0 then P(49.5 + dx, 25 + hd + dy, R.hi) end
    end
    sjaw(-5, -1, JAWF)
    ell(36, 30 + hd, 8, 6.8, SHL)
    for y = 28, 30 do for x = 39, 41 do P(x, y + hd, CREAM) end end
    P(40, 29 + hd, INK); P(41, 29 + hd, INK); P(40, 30 + hd, INK); P(41, 30 + hd, INK)
    P(38, 27 + hd, SHL.deep); P(39, 27 + hd, SHL.deep); P(40, 26 + hd, SHL.deep)
    P(38, 32 + hd, REDS)
    P(41, 34 + hd, SHL.deep); P(42, 33 + hd, SHL.deep)
    P(31, 26 + hd, SHL.spec); P(32, 25 + hd, SHL.hi); P(33, 25 + hd, SHL.hi)
    sjaw(0, 0, JAW, 0.9)
    sjaw(0, 0, JAW)
    -- near arm holds the shield forward
    local a = o.armR
    seg(35, 43 + b, 39 + a, 47 + b, 1.1, LEG); seg(39 + a, 47 + b, 41 + a, 50 + b, 0.9, LEG)
    local sw = walk and (o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)) or 0
    shield(40 + a + sw, 46 + b, false)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
  for _, p in ipairs(POST) do
    if p[2] <= 71 and p[2] >= top then img:putPixel(p[1], p[2], INK) end
  end
end
return S
