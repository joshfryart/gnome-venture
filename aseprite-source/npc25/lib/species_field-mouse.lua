-- field-mouse (biped (mammal)) tables from specs/field-mouse.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "field-mouse", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 40}
S.ramps = {main = {"#e0a46c", "#cf9450", "#946048", "#705446"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e0a46c", "#cf9450", "#946048", "#705446", "#78b04c", "#4a7c4c", "#2e4e46", "#e8c262", "#b48a4c", "#e8a898", "#f2dcba"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#cf9450",
  bshade = h"#946048",
  bhi = h"#e0a46c",
  deep = h"#705446",
  head = h"#cf9450",
  hat = h"#e8c262",
  hatshade = h"#b48a4c",
  wing = h"#946048",
  belly = h"#e8a898",
  acc = h"#78b04c",
  accs = h"#4a7c4c",
  eye = h"#e8a898",
  q = h"#b48a4c",
  qshade = h"#e8c262",
  qhi = h"#b48a4c",
  ink = h"#705446", arm = h"#cf9450", fbase = h"#946048", fshade = h"#705446"}
S.bw, S.top = 28, 10
S.quirk = {w = 1, h = 6, y = 56, x = {front = 48, back = 13, side = 36}, anchor = "hand", hex = "#b48a4c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  -- Field mouse farmhand: big round ears beside a woven straw hat, green overalls,
  -- pink paws and tail, a ripe wheat stalk held upright in the near hand.
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local CREAM, PINK = H"#f2dcba", H"#e8a898"
  local F = {hl = CREAM, hi = H"#e0a46c", base = H"#cf9450", shade = H"#946048", deep = H"#705446"}
  local FF = {hl = F.base, hi = F.base, base = F.shade, shade = F.deep, deep = F.deep} -- far side
  local OV = {hl = H"#78b04c", hi = H"#78b04c", base = H"#78b04c", shade = H"#4a7c4c", deep = H"#2e4e46"}
  local OVF = {hl = OV.shade, hi = OV.shade, base = OV.shade, shade = OV.deep, deep = OV.deep}
  local HAT = {hl = CREAM, hi = H"#e8c262", base = H"#e8c262", shade = H"#b48a4c", deep = F.shade}
  local PK = {hl = CREAM, hi = PINK, base = PINK, shade = F.shade, deep = F.deep}
  local MUZ = {hl = CREAM, hi = CREAM, base = CREAM, shade = F.hi, deep = F.base}
  local GOLD, STALK = H"#e8c262", H"#b48a4c"
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
  -- dark seam where a part overlaps something already drawn (inner contour, outline stays outside)
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
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for t = 0, n do P(x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n, c) end
  end
  -- tail: list of points, 2 px thick, pink with shade under, cream tip
  local function tail(pts, sh)
    for i = 1, #pts - 1 do
      local a, c = pts[i], pts[i + 1]
      local n = math.max(math.abs(c[1] - a[1]), math.abs(c[2] - a[2]), 1)
      for t = 0, n do
        local x, y = a[1] + (c[1] - a[1]) * t / n, a[2] + (c[2] - a[2]) * t / n
        P(x, y + 1, sh); P(x + 1, y + 1, sh)
      end
    end
    for i = 1, #pts - 1 do line(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], PINK) end
    local e = pts[#pts]
    P(e[1], e[2], CREAM); P(e[1], e[2] + 1, CREAM)
  end
  -- wheat ear, stalk top at (x, y): kernels in a braid, one awn
  local function wheat(x, y, ylo)
    for yy = y, ylo do P(x, yy, STALK) end
    stamp(x - 1, y - 9, {".c.", "gcs", "sgg", "gcs", "sgg", "gcs", "sgg", ".s."}, {g = GOLD, s = STALK, c = CREAM})
  end
  local ts = ({0, 0, 1, 1, 0, -1, -1, 0})[frame]
  local sw = o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local aVL, aVR, fVL, fVR = o.armR, o.armL, o.footR, o.footL
    if not front then aVL, aVR, fVL, fVR = o.armL, o.armR, o.footL, o.footR end
    -- tail
    if front then
      tail({{24, 62 + b}, {20, 63 + b}, {17, 61 + b}, {16 + ts, 57 + b}, {17 + ts, 54 + b}}, F.shade)
    else
      tail({{32, 60 + b}, {36, 63 + b}, {41, 63 + b}, {44 + ts, 60 + b}, {45 + ts, 56 + b}, {44 + ts, 53 + b}}, F.shade)
    end
    -- feet (behind the trousers)
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and F.shade or F.base) end end
      ell(cx, bot - 2, 3.3, 2.6, function(x, y, nx, ny)
        if front then
          if x == cx and y >= bot - 1 then return F.shade end
          if lift < 0 and y >= bot - 1 then return F.shade end
          return lit(nx, ny, PK)
        end
        if y == bot and math.abs(x - cx) <= 1 then return F.shade end
        if y >= bot - 1 then return PINK end
        return lit(nx, ny, FF)
      end)
    end
    foot(26, fVL); foot(37, fVR)
    -- torso
    ell(CX, 52 + b, 10.5, 13, function(x, y, nx, ny)
      local yy, ax = y - b, math.abs(x - CX)
      if yy >= 55 then
        if yy >= 61 and (x == 31 or x == 32) then return OV.deep end
        if yy == 55 then return OV.shade end
        if not front and yy >= 57 and yy <= 59 and (ax == 3.5 or ax == 6.5) then return OV.shade end
        if not front and yy == 57 and ax > 3.5 and ax < 6.5 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if front then
        if yy >= 46 and ax <= 5.5 then
          if yy == 46 then return OV.hi end
          if yy >= 49 and yy <= 52 and ax <= 2.5 then
            if yy == 49 or yy == 52 or ax == 2.5 then return OV.shade end
            return OV.hi
          end
          return lit(nx, ny, OV)
        end
        if ax >= 4.5 and ax <= 5.5 and yy >= 40 then return x > CX and OV.shade or OV.base end
        local cx2, cy2 = (x - CX) / 4.2, (yy - 45) / 5
        if cx2 * cx2 + cy2 * cy2 <= 1 then return CREAM end
        return lit(nx, ny, F)
      else
        local sx = 6.5 - math.floor((55 - yy) / 4)
        if ax >= sx - 1 and ax <= sx and yy >= 40 then return x > CX and OV.shade or OV.base end
        if yy >= 41 and yy <= 44 and ax <= 1.5 then return F.shade end
        return lit(nx, ny, F)
      end
    end)
    if front then P(27, 46 + b, GOLD); P(36, 46 + b, GOLD) end
    -- arms + wheat
    local function arm(side, a)
      local dy = front and a or -a
      local ax = side < 0 and 21 or 42
      local ux, uy = ax, 48 + b + dy / 2
      ring(ux, uy, 2.6, 5, F.deep)
      E(ux, uy, 2.6, 5, F)
      local px, py = ax + side * 1.5, 54 + b + dy
      ring(px, py, 2.3, 2, F.deep)
      E(px, py, 2.3, 2, PK)
      return px, py
    end
    local px, py = arm(-1, aVL)
    local qx, qy = arm(1, aVR)
    local wx, wy = front and math.floor(qx) + 3 + sw or math.floor(px) - 2 - sw, front and qy or py
    -- head
    local function ear(cx, cy, side)
      E(cx, cy, 6, 6, F)
      if front then
        ell(cx - side * 0.6 , cy + 0.6, 3.6, 3.8, function(x, y, nx, ny)
          if ny < -0.55 then return F.shade end
          return PINK
        end)
      else
        E(cx + side * 0.5, cy + 0.5, 3.4, 3.6, F.shade)
      end
    end
    ear(19.5, 15.5 + hd, -1); ear(43.5, 15.5 + hd, 1)
    ring(CX, 28 + hd, 12.5, 11, F.deep)
    E(CX, 28 + hd, 12.5, 11, F)
    if front then
      E(CX, 32.5 + hd, 5.2, 3.4, MUZ)
      -- eyes: 2x3 ink pill + glint
      for _, ex in ipairs({25, 37}) do
        for y = 25, 27 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 25 + hd, CREAM)
      end
      P(23, 29 + hd, PINK); P(24, 29 + hd, PINK); P(39, 29 + hd, PINK); P(40, 29 + hd, PINK)
      -- nose + smile
      P(31, 30 + hd, PINK); P(32, 30 + hd, PINK); P(31, 31 + hd, PINK); P(32, 31 + hd, F.shade)
      P(31, 30 + hd, CREAM)
      P(30, 33 + hd, F.shade); P(33, 33 + hd, F.shade); P(31, 34 + hd, F.shade); P(32, 34 + hd, F.shade)
      -- whiskers
      for _, s in ipairs({-1, 1}) do
        for i = 0, 2 do
          P(CX + s * (7.5 + i), 31 + hd, F.deep)
          P(CX + s * (7.5 + i), 33 + hd + (i == 2 and 1 or 0), F.deep)
        end
      end
    else
      for _, q in ipairs({{24, 27}, {25, 26}, {27, 30}, {28, 29}, {35, 28}, {36, 27}, {30, 33}, {31, 32}}) do
        P(q[1], q[2] + hd, F.hi)
      end
      for y = 33, 38 do for x = 26, 37 do
        local g = get(x, y + hd)
        if g == F.base or g == F.hi then P(x, y + hd, F.shade) end
      end end
    end
    -- straw hat
    local function hat(cx, by)
      ell(cx, by, 12.5, 3, function(x, y, nx, ny)
        if ny > 0.45 then return HAT.shade end
        if (x + y) % 4 == 0 and ny > -0.4 then return HAT.shade end
        if ny < -0.6 and nx < 0 then return CREAM end
        return HAT.base
      end)
      local top = by - 9.5
      for yy = 0, 8 do
        local inset = yy == 0 and 2 or (yy == 1 and 1 or 0)
        for x = 24 + inset, 39 - inset do
          local c = HAT.base
          if x <= 25 then c = yy < 4 and CREAM or HAT.base elseif x >= 38 then c = HAT.shade end
          if yy % 2 == 1 and (x + yy) % 3 == 0 and x > 25 then c = HAT.shade end
          if yy == 5 or yy == 6 then c = (x >= 38) and OV.deep or (yy == 5 and OV.hi or OV.shade) end
          if yy == 0 and x >= 28 and x <= 30 then c = CREAM end
          P(x, top + yy, c)
        end
      end
      -- a sprig of wheat tucked in the band
      local fx = front and 36 or 27
      P(fx, top + 4, GOLD); P(fx + (front and 1 or -1), top + 3, GOLD)
    end
    hat(CX, 19.5 + hd)
    if front then
      for x = 20, 43 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
    end
    -- wheat in front of everything except its paw
    wheat(wx, wy - 20, wy - 1)
    if front then E(qx, qy, 2.3, 2, PK) else E(px, py, 2.3, 2, PK) end
  else
    -- side view, facing right; near side = creature right
    local legN, legF = math.floor(o.armL * 1.5 + 0.5), math.floor(o.armR * 1.5 + 0.5)
    tail({{24, 60 + b}, {20, 63 + b}, {16, 64 + b}, {13, 62 + b}, {12 + ts, 58 + b}, {13 + ts, 55 + b}}, F.shade)
    local function foot(cx, lift, far)
      local bot = 70 + lift
      local r = far and FF or F
      for y = 61 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and r.shade or r.base) end end
      ell(cx + 1.5, bot - 1.5, 4, 2, function(x, y, nx, ny)
        if y == bot and x >= cx + 3 then return far and F.deep or F.shade end
        if far then return ny < 0 and PINK or F.shade end
        return lit(nx, ny, PK)
      end)
      if not far then P(cx + 4, bot - 1, F.shade) end
    end
    foot(28 + legF, o.footL, true)
    E(37 + o.armL, 50 + b, 2, 2.2, FF) -- far paw
    -- torso
    ell(30.5, 52 + b, 8.5, 12.5, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        if yy >= 59 and x == 30 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if x >= 33 and yy >= 46 then
        if yy == 46 then return OV.hi end
        if yy >= 48 and yy <= 51 and x == 35 then return OV.shade end
        return lit(nx, ny, OV)
      end
      local sx = 33 - math.floor((46 - yy) * 0.7)
      if yy < 46 and yy >= 40 and (x == sx or x == sx + 1) then return x == sx and OV.base or OV.shade end
      if x >= 35 and yy < 46 then return CREAM end
      return lit(nx, ny, F)
    end)
    P(33, 46 + b, GOLD)
    foot(32 + legN, o.footR, false)
    -- near arm holding the wheat upright in front of the chest
    local ax = 37 + math.floor(o.armR * 1.5 + 0.5)
    for pass = 1, 2 do
      for t = 0, 6 do
        local x, y = 31 + (ax - 31) * t / 6, 45 + b + (52 - 45) * t / 6
        if pass == 1 then ring(x, y, 2, 2, F.deep) else E(x, y, 2, 2, F) end
      end
    end
    ring(ax, 53 + b, 2.2, 2, F.deep)
    E(ax, 53 + b, 2.2, 2, PK)
    local wx, wy = ax + 2, 53 + b
    -- head
    local hx, hy = 30.5, 28 + hd
    E(22, 15.5 + hd, 5.5, 5.6, F)
    ell(23, 16 + hd, 3.2, 3.6, function(x, y, nx, ny) return ny < -0.5 and F.shade or PINK end)
    ring(hx, hy, 11, 10.5, F.deep)
    E(hx, hy, 11, 10.5, F)
    ell(39.5, 30.5 + hd, 6, 3.4, function(x, y, nx, ny)
      if ny > 0.55 and x < 43 then return CREAM end
      return lit(nx, ny, F)
    end)
    -- nose tip, eye, cheek, whiskers, mouth
    stamp(45, 29 + hd, {"cp", "pp", "s."}, {c = CREAM, p = PINK, s = F.shade})
    for y = 24, 26 do P(37, y + hd, INK); P(38, y + hd, INK) end
    P(37, 24 + hd, CREAM)
    P(36, 29 + hd, PINK); P(37, 29 + hd, PINK)
    for i = 0, 2 do P(39 + i, 31 + hd - (i == 2 and 1 or 0), F.deep) end
    P(41, 33 + hd, F.shade); P(42, 33 + hd, F.shade)
    -- hat profile
    ell(30.5, 19.5 + hd, 12, 2.6, function(x, y, nx, ny)
      if ny > 0.45 then return HAT.shade end
      if (x + y) % 4 == 0 and ny > -0.4 then return HAT.shade end
      if ny < -0.6 and nx < 0 then return CREAM end
      return HAT.base
    end)
    local top = 10 + hd
    for yy = 0, 8 do
      local inset = yy == 0 and 2 or (yy == 1 and 1 or 0)
      for x = 24 + inset, 37 - inset do
        local c = HAT.base
        if x <= 25 then c = yy < 4 and CREAM or HAT.base elseif x >= 36 then c = HAT.shade end
        if yy % 2 == 1 and (x + yy) % 3 == 0 and x > 25 then c = HAT.shade end
        if yy == 5 or yy == 6 then c = (x >= 36) and OV.deep or (yy == 5 and OV.hi or OV.shade) end
        if yy == 0 and x >= 27 and x <= 29 then c = CREAM end
        P(x, top + yy, c)
      end
    end
    P(25, top + 4, GOLD); P(24, top + 3, GOLD)
    for x = 33, 44 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
    wheat(wx + sw, wy - 9, wy - 1)
    E(ax, 53 + b, 2.2, 2, PK)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
