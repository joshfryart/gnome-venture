-- wood-mouse (biped (mammal)) tables from specs/wood-mouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "wood-mouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#d88a50", "#b8743c", "#8a4f34", "#5e3a2c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d88a50", "#b8743c", "#8a4f34", "#5e3a2c", "#6aa848", "#3f7a4a", "#2c4f48", "#b08848", "#e8968e", "#ecd6b0"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#b8743c",
  bshade = h"#8a4f34",
  bhi = h"#d88a50",
  deep = h"#5e3a2c",
  head = h"#b8743c",
  hat = h"#b08848",
  hatshade = h"#8a4f34",
  wing = h"#8a4f34",
  belly = h"#e8968e",
  acc = h"#6aa848",
  accs = h"#3f7a4a",
  eye = h"#e8968e",
  q = h"#b08848",
  qshade = h"#b08848",
  qhi = h"#b08848",
  ink = h"#5e3a2c", arm = h"#b8743c", fbase = h"#8a4f34", fshade = h"#5e3a2c"}
S.bw, S.top = 28, 10
S.quirk = {w = 4, h = 3, y = 11, x = {front = 30, back = 30, side = 33}, anchor = "crown", hex = "#b08848"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  -- Wood mouse scout: huge round ears, big shiny eyes, an acorn-cap helmet with a jaunty stalk,
  -- green dungaree shorts (cross straps on the back), long brown tail carried high in an S.
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local CREAM, PINK = H"#ecd6b0", H"#e8968e"
  local F = {hl = CREAM, hi = H"#d88a50", base = H"#b8743c", shade = H"#8a4f34", deep = H"#5e3a2c"}
  local FF = {hl = F.base, hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local OV = {hl = H"#6aa848", hi = H"#6aa848", base = H"#6aa848", shade = H"#3f7a4a", deep = H"#2c4f48"}
  local PK = {hl = CREAM, hi = PINK, base = PINK, shade = F.shade, deep = F.deep}
  local CAP = {hl = CREAM, hi = H"#d88a50", base = H"#b08848", shade = H"#8a4f34", deep = H"#5e3a2c"}
  local b, hd = o.body, o.head
  local G = {}
  local function P(x, y, c)
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[math.floor(y + 0.5) * 64 + math.floor(x + 0.5)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry - 1), math.ceil(cy + ry + 1) do
      for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then P(x, y, fn(x, y, nx, ny, d)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.5 + ny * 0.86
    if s > 0.93 then return r.deep end
    if s > 0.5 then return r.shade end
    if s < -0.82 then return r.hl end
    if s < -0.3 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function ring(cx, cy, rx, ry, c)
    ell(cx, cy, rx + 1, ry + 1, function(x, y) if get(x, y) then return c end end)
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  -- furry brown tail, 2 px: base on top, shade under, deep tip
  local function tail(pts)
    local function walk(fn)
      for i = 1, #pts - 1 do
        local a, c = pts[i], pts[i + 1]
        local n = math.max(math.abs(c[1] - a[1]), math.abs(c[2] - a[2]), 1)
        for t = 0, n do fn(a[1] + (c[1] - a[1]) * t / n, a[2] + (c[2] - a[2]) * t / n) end
      end
    end
    walk(function(x, y) P(x, y + 1, F.shade); P(x + 1, y + 1, F.shade) end)
    walk(function(x, y) P(x, y, F.hi) end)
    local e = pts[#pts]
    P(e[1], e[2], F.deep); P(e[1] + 1, e[2], F.deep)
  end
  -- acorn cap: scaled dome, rim, stalk; cx = centre x, by = rim row, rx half width
  local function cap(cx, by, rx, ry, lean, back)
    ell(cx, by, rx + 1, ry + 1, function(x, y) if y <= by + 3 and get(x, y) then return CAP.deep end end)
    ell(cx, by, rx, ry, function(x, y, nx, ny)
      if y > by then return end
      local row = math.floor(y - (by - ry) + 0.5)
      local s = nx * 0.6 + ny * 0.5
      local c = CAP.base
      if s > 0.45 then c = CAP.shade end
      if row % 2 == 1 and (math.floor(x + 0.5) + row) % 3 == 0 then
        c = c == CAP.base and CAP.shade or CAP.deep
      elseif row % 2 == 0 and (math.floor(x + 0.5) + row) % 3 == 1 and s < -0.1 then
        c = CAP.hi
      end
      if back and math.abs(x - cx) < 0.6 then c = CAP.deep end
      return c
    end)
    for x = math.floor(cx - rx - 0.5), math.ceil(cx + rx + 0.5) do
      local nx = (x - cx) / (rx + 1)
      if math.abs(nx) <= 1 then
        P(x, by + 1, nx < -0.5 and CREAM or (nx > 0.5 and CAP.shade or CAP.base))
        P(x, by + 2, nx > 0.3 and CAP.deep or CAP.shade)
      end
    end
    local tx = math.floor(cx + 0.5)
    P(tx, by - ry - 1, CAP.shade); P(tx + lean, by - ry - 2, CAP.deep)
    P(tx + lean + (lean ~= 0 and lean or 1), by - ry - 2, CAP.deep)
    P(tx - 3, by - ry + 1, CREAM); P(tx - 4, by - ry + 2, CREAM)
  end
  local sw = o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)
  local ts = ({0, 0, 1, 1, 0, -1, -1, 0})[frame]
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local aVL, aVR, fVL, fVR = o.armR, o.armL, o.footR, o.footL
    if not front then aVL, aVR, fVL, fVR = o.armL, o.armR, o.footL, o.footR end
    if front then
      tail({{38, 62 + b}, {42, 63 + b}, {45, 61 + b}, {46 + ts, 57 + b}, {45 + ts, 53 + b}, {46 + ts, 50 + b}, {48 + ts, 48 + b}})
    else
      tail({{31, 59 + b}, {27, 62 + b}, {22, 62 + b}, {18 + ts, 59 + b}, {17 + ts, 55 + b}, {18 + ts, 51 + b}, {16 + ts, 48 + b}})
    end
    -- legs + feet: bare fur shins under the shorts
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 60 + b, bot - 2 do for x = cx - 1, cx + 1 do
        P(x, y, x == cx + 1 and F.shade or (x == cx - 1 and F.hi or F.base))
      end end
      ell(cx, bot - 1.5, 3.3, 2.2, function(x, y, nx, ny)
        if front then
          if (x == cx - 1 or x == cx + 1) and y == bot then return F.shade end
          if lift < 0 and y >= bot then return F.shade end
          return lit(nx, ny, PK)
        end
        if y == bot then return PINK end
        return lit(nx, ny, FF)
      end)
    end
    foot(26, fVL); foot(37, fVR)
    -- torso
    ell(CX, 51 + b, 10, 12, function(x, y, nx, ny)
      local yy, ax = y - b, math.abs(x - CX)
      if yy >= 54 then
        if yy >= 59 and (x == 31 or x == 32) then return OV.deep end
        if yy == 62 then return OV.shade end -- rolled hem
        if yy == 54 then return OV.shade end
        if not front and yy == 56 and ax >= 2.5 and ax <= 6.5 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if front then
        -- rounded bib
        local bx = (x - CX) / 6, (0)
        local by = (yy - 54) / 8
        if bx * bx + by * by <= 1 then
          if yy >= 48 and yy <= 50 and ax <= 1.5 then return yy == 48 and OV.shade or OV.hi end
          return lit(nx, ny, OV)
        end
        if ax >= 4.5 and ax <= 5.5 and yy >= 40 and yy < 48 then return x > CX and OV.shade or OV.base end
        local cx2, cy2 = (x - CX) / 3.8, (yy - 44) / 4
        if cx2 * cx2 + cy2 * cy2 <= 1 then return CREAM end
        return lit(nx, ny, F)
      else
        -- straps cross in an X between the shoulder blades
        local t = (yy - 40) / 14
        local s1 = 26 + t * 11
        local s2 = 37 - t * 11
        if yy >= 40 and (math.abs(x - s1) < 1 or math.abs(x - s2) < 1) then
          return (math.abs(yy - 47) <= 0 and ax <= 1) and CREAM or (x > CX and OV.shade or OV.base)
        end
        return lit(nx, ny, F)
      end
    end)
    if front then P(27, 47 + b, CREAM); P(36, 47 + b, CREAM) end
    local function arm(side, a)
      local dy = front and a or -a
      local ax = side < 0 and 21.5 or 41.5
      local ux, uy = ax, 47 + b + dy / 2
      ring(ux, uy, 2.5, 4.8, F.deep)
      E(ux, uy, 2.5, 4.8, F)
      local px, py = ax + side * 0.5, 53 + b + dy
      ring(px, py, 2.2, 2, F.deep)
      E(px, py, 2.2, 2, PK)
    end
    arm(-1, aVL); arm(1, aVR)
    -- big ears
    local function ear(cx, cy, side)
      E(cx, cy, 6.3, 6.3, F)
      if front then
        ell(cx - side * 0.4, cy + 0.6, 4.2, 4.3, function(x, y, nx, ny)
          if ny < -0.6 or (nx * side > 0.75) then return F.shade end
          if nx * side < -0.5 and ny > -0.2 then return CREAM end
          return PINK
        end)
      else
        E(cx + side * 0.4, cy + 0.6, 3.8, 3.8, F.shade)
        P(cx - side * 2, cy - 3, F.hi)
      end
    end
    ear(19, 17 + hd, -1); ear(44, 17 + hd, 1)
    ring(CX, 28.5 + hd, 11.5, 10.5, F.deep)
    E(CX, 28.5 + hd, 11.5, 10.5, F)
    if front then
      E(CX, 33.5 + hd, 5.5, 3.6, {hl = CREAM, hi = CREAM, base = CREAM, shade = F.hi, deep = F.base})
      -- big glossy eyes 3x4
      for _, ex in ipairs({25, 36}) do
        for y = 25, 28 do for x = ex, ex + 2 do
          if not ((y == 25 or y == 28) and (x == ex or x == ex + 2)) then P(x, y + hd, INK) end
        end end
        P(ex + 1, 26 + hd, CREAM); P(ex + 2, 28 + hd - 1, F.deep)
      end
      P(23, 31 + hd, PINK); P(24, 31 + hd, PINK); P(39, 31 + hd, PINK); P(40, 31 + hd, PINK)
      stamp(30, 31 + hd, {".cp.", "pppp", ".ps."}, {c = CREAM, p = PINK, s = F.shade})
      P(31, 34 + hd, F.shade); P(32, 34 + hd, F.shade); P(30, 35 + hd, F.shade); P(33, 35 + hd, F.shade)
      for _, s in ipairs({-1, 1}) do
        P(CX + s * 6.5, 33 + hd, F.deep); P(CX + s * 7.5, 33 + hd, F.deep); P(CX + s * 8.5, 32 + hd, F.deep)
      end
      cap(CX + 0.5 * sw, 20 + hd, 10.5, 8, sw, false)
      for x = 22, 41 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
    else
      for _, q in ipairs({{25, 28}, {26, 27}, {29, 31}, {30, 30}, {36, 29}, {37, 28}}) do P(q[1], q[2] + hd, F.hi) end
      for y = 34, 39 do for x = 25, 38 do
        local g = get(x, y + hd)
        if g == F.base or g == F.hi then P(x, y + hd, F.shade) end
      end end
      cap(CX - 0.5 * sw, 20 + hd, 10.5, 8, -sw, true)
    end
  else
    local legN, legF = math.floor(o.armL * 1.5 + 0.5), math.floor(o.armR * 1.5 + 0.5)
    tail({{24, 59 + b}, {19, 62 + b}, {15, 60 + b}, {13 + ts, 56 + b}, {14 + ts, 51 + b}, {13 + ts, 47 + b}, {15 + ts, 44 + b}})
    local function foot(cx, lift, far)
      local bot = 70 + lift
      local r = far and FF or F
      for y = 59 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and r.shade or r.base) end end
      ell(cx + 1.5, bot - 1.5, 4, 2, function(x, y, nx, ny)
        if y == bot and x >= cx + 3 then return far and F.deep or F.shade end
        if far then return ny < 0 and PINK or F.shade end
        return lit(nx, ny, PK)
      end)
      if not far then P(cx + 4, bot - 1, F.shade) end
    end
    foot(28 + legF, o.footL, true)
    E(36 + o.armL, 50 + b, 2, 2.2, FF)
    ell(30.5, 51 + b, 8.5, 11.5, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 54 then
        if yy == 54 then return OV.shade end
        if yy == 62 then return OV.shade end
        return lit(nx, ny, OV)
      end
      local bx, by = (x - 39) / 6, (yy - 54) / 8
      if bx * bx + by * by <= 1 then return lit(nx, ny, OV) end
      local sx = 33 - math.floor((47 - yy) * 0.7)
      if yy < 48 and yy >= 40 and (x == sx or x == sx + 1) then return x == sx and OV.base or OV.shade end
      if x >= 35 and yy < 48 then return CREAM end
      return lit(nx, ny, F)
    end)
    P(34, 47 + b, CREAM)
    foot(32 + legN, o.footR, false)
    local ax = 32 + math.floor(o.armR * 2 + 0.5)
    for pass = 1, 2 do
      for t = 0, 6 do
        local x, y = 31 + (ax - 31) * t / 6, 44 + b + 8 * t / 6
        if pass == 1 then ring(x, y, 2, 2, F.deep) else E(x, y, 2, 2, F) end
      end
    end
    ring(ax, 53 + b, 2.2, 2, F.deep)
    E(ax, 53 + b, 2.2, 2, PK)
    -- head
    local hx, hy = 30.5, 28.5 + hd
    E(19, 17 + hd, 6, 6.3, F)
    ell(20, 17.5 + hd, 3.8, 4.3, function(x, y, nx, ny)
      if ny < -0.55 then return F.shade end
      if nx < -0.4 then return CREAM end
      return PINK
    end)
    ring(hx, hy, 10.5, 10, F.deep)
    E(hx, hy, 10.5, 10, F)
    ell(39.5, 31 + hd, 6.5, 3.6, function(x, y, nx, ny)
      if ny > 0.55 and x >= 37 and x <= 41 then return CREAM end
      return lit(nx, ny, F)
    end)
    stamp(45, 29 + hd, {"cp", "pp", "s."}, {c = CREAM, p = PINK, s = F.shade})
    -- big eye 3x4
    for y = 25, 28 do for x = 36, 38 do
      if not ((y == 25 or y == 28) and (x == 36 or x == 38)) then P(x, y + hd, INK) end
    end end
    P(37, 26 + hd, CREAM)
    P(35, 30 + hd, PINK); P(36, 30 + hd, PINK)
    P(40, 32 + hd, F.deep); P(41, 32 + hd, F.deep); P(42, 31 + hd, F.deep)
    P(42, 34 + hd, F.shade); P(43, 34 + hd, F.shade)
    cap(30 + 0.5 * sw, 20 + hd, 10, 8, 1, false)
    for x = 33, 44 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
