-- shrew (biped (mammal)) tables from specs/shrew.md. Opus: replace S.draw_figure only (body-plan helper: D.draw).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "shrew", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 9, W = 42}
S.ramps = {main = {"#a8826a", "#8c6852", "#6e5040", "#3f2d3d"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a8826a", "#8c6852", "#6e5040", "#3f2d3d", "#82a45a", "#567858", "#38524a", "#dbb65c", "#aa824c", "#e2908e", "#f2dcba"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0}, {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {
  body = h"#8c6852",
  bshade = h"#6e5040",
  bhi = h"#a8826a",
  deep = h"#3f2d3d",
  head = h"#8c6852",
  hat = h"#dbb65c",
  hatshade = h"#aa824c",
  wing = h"#6e5040",
  belly = h"#82a45a",
  acc = h"#82a45a",
  accs = h"#567858",
  eye = h"#82a45a",
  q = h"#dbb65c",
  qshade = h"#e2908e",
  qhi = h"#f2dcba",
  ink = h"#3f2d3d", arm = h"#8c6852", fbase = h"#6e5040", fshade = h"#3f2d3d"}
S.bw, S.top = 28, 10
S.quirk = {w = 2, h = 6, y = 14, x = {front = 39, back = 22, side = 30}, anchor = "ear", hex = "#dbb65c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  -- Shrew clerk: velvety dusk-brown fur, long twitchy pointed snout with a pink tip, tiny eyes,
  -- small ears under a wide straw hat with a pink band, olive overalls with a notepad in the
  -- bib pocket, a thin tail, and a pencil tucked behind the near ear.
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local CREAM, PINK = H"#f2dcba", H"#e2908e"
  local F = {hl = H"#a8826a", hi = H"#a8826a", base = H"#8c6852", shade = H"#6e5040", deep = H"#3f2d3d"}
  local FF = {hl = F.base, hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local OV = {hl = H"#82a45a", hi = H"#82a45a", base = H"#82a45a", shade = H"#567858", deep = H"#38524a"}
  local PK = {hl = CREAM, hi = PINK, base = PINK, shade = F.shade, deep = F.deep}
  local HATB, HATS = H"#dbb65c", H"#aa824c"
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
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for t = 0, n do P(x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n, c) end
  end
  -- thin 1 px tail through points, pale tip
  local function tail(pts)
    for i = 1, #pts - 1 do line(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], F.shade) end
    local e = pts[#pts]
    P(e[1], e[2], F.hi)
  end
  -- pencil from eraser end (x0,y0) to point (x1,y1), 2 px thick: eraser, ferrule, body, wood, lead
  local function pencil(x0, y0, x1, y1)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
    local ox, oy = 1, 0
    if math.abs(x1 - x0) > math.abs(y1 - y0) then ox, oy = 0, 1 end
    for t = 0, n do
      local x, y = x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n
      for k = -1, 2 do P(x + ox * k, y + oy * k, F.deep) end
    end
    for t = 0, n do
      local x, y = x0 + (x1 - x0) * t / n, y0 + (y1 - y0) * t / n
      local c1, c2 = HATB, HATS
      if t <= 1 then c1, c2 = PINK, PINK
      elseif t == 2 then c1, c2 = CREAM, F.hi
      elseif t == n - 1 then c1, c2 = CREAM, CREAM
      elseif t == n then c1, c2 = F.deep, nil end
      P(x, y, c1); if c2 then P(x + ox, y + oy, c2) end
    end
  end
  -- straw hat: brim ellipse + crown, pink band, weave
  local function hat(cx, by, brx, cw, front)
    ell(cx, by, brx, 3.2, function(x, y, nx, ny)
      if ny > 0.5 then return HATS end
      if (x * 2 + y) % 5 == 0 then return HATS end
      if ny < -0.65 and nx < -0.2 then return CREAM end
      return HATB
    end)
    local top = by - 9.5
    local x1, x2 = math.floor(cx - cw + 0.5), math.floor(cx + cw - 0.5)
    for yy = 0, 8 do
      local inset = yy == 0 and 2 or (yy == 1 and 1 or 0)
      for x = x1 + inset, x2 - inset do
        local c = HATB
        if x <= x1 + 1 then c = yy < 4 and CREAM or HATB elseif x >= x2 - 1 then c = HATS end
        if yy % 2 == 0 and (x + yy) % 4 == 0 and x > x1 + 1 then c = HATS end
        if yy == 6 or yy == 7 then c = (x >= x2 - 1) and F.shade or PINK end
        if yy == 6 and x <= x1 + 1 then c = CREAM end
        P(x, top + yy, c)
      end
    end
    if not front then
      P(x2 - 2, top + 3, HATS); P(x2 - 3, top + 4, HATS)
    end
  end
  local sw = o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)
  local ts = ({0, 0, 1, 1, 0, -1, -1, 0})[frame]
  -- the snout twitches: tip nudges on the in-between frames
  local tw = ({0, 1, 0, 1, 0, 0, 1, 0})[frame]
  local CX = 31.5

  if view == "front" or view == "back" then
    local front = view == "front"
    local aVL, aVR, fVL, fVR = o.armR, o.armL, o.footR, o.footL
    if not front then aVL, aVR, fVL, fVR = o.armL, o.armR, o.footL, o.footR end
    if front then
      tail({{22, 63 + b}, {18, 64 + b}, {15, 62 + b}, {14 + ts, 59 + b}, {15 + ts, 56 + b}})
    else
      tail({{32, 61 + b}, {35, 64 + b}, {40, 65 + b}, {44 + ts, 63 + b}, {46 + ts, 60 + b}, {46 + ts, 57 + b}})
    end
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and F.shade or F.base) end end
      ell(cx, bot - 1.5, 3, 2.2, function(x, y, nx, ny)
        if front then
          if x == cx and y >= bot - 1 then return F.shade end
          if lift < 0 and y >= bot then return F.shade end
          return lit(nx, ny, PK)
        end
        if y == bot then return PINK end
        return lit(nx, ny, FF)
      end)
    end
    foot(26, fVL); foot(37, fVR)
    -- torso, a touch plumper than the mice
    ell(CX, 52 + b, 11.5, 13, function(x, y, nx, ny)
      local yy, ax = y - b, math.abs(x - CX)
      if yy >= 55 then
        if yy >= 61 and (x == 31 or x == 32) then return OV.deep end
        if yy == 55 then return OV.shade end
        if not front and yy >= 57 and yy <= 59 and x >= 34 and x <= 38 then
          return (yy == 57 or x == 34 or x == 38) and OV.shade or OV.hi
        end
        return lit(nx, ny, OV)
      end
      if front then
        if yy >= 46 and ax <= 6.5 then
          if yy == 46 then return OV.hi end
          -- pocket with a notepad peeking out
          if yy >= 49 and yy <= 53 and ax <= 3.5 then
            if yy == 49 or ax == 3.5 or yy == 53 then return OV.shade end
            return OV.hi
          end
          return lit(nx, ny, OV)
        end
        if ax >= 5.5 and ax <= 6.5 and yy >= 40 then return x > CX and OV.shade or OV.base end
        if ax <= 4.5 then return yy <= 42 and F.base or F.hi end
        return lit(nx, ny, F)
      else
        local sx = 6.5 - math.floor((55 - yy) / 4)
        if ax >= sx - 1 and ax <= sx and yy >= 40 then return x > CX and OV.shade or OV.base end
        return lit(nx, ny, F)
      end
    end)
    if front then
      stamp(29, 46 + b, {"cccc", "cssc", "cccc"}, {c = CREAM, s = F.hi})
      P(26, 46 + b, HATB); P(37, 46 + b, HATB)
    end
    local function arm(side, a)
      local dy = front and a or -a
      local ax = side < 0 and 20 or 43
      local ux, uy = ax, 48 + b + dy / 2
      ring(ux, uy, 2.5, 4.8, F.deep)
      E(ux, uy, 2.5, 4.8, F)
      local px, py = ax + side * 0.5, 54 + b + dy
      ring(px, py, 2, 1.8, F.deep)
      E(px, py, 2, 1.8, PK)
    end
    arm(-1, aVL); arm(1, aVR)
    -- head
    local function ear(cx, cy, side)
      E(cx, cy, 3.6, 3.4, F)
      if front then E(cx - side * 0.4, cy + 0.4, 2, 1.8, PINK) else P(cx, cy, F.shade) end
    end
    ear(20.5, 23 + hd, -1); ear(42.5, 23 + hd, 1)
    ring(CX, 28 + hd, 11, 10, F.deep)
    E(CX, 28 + hd, 11, 10, F)
    if front then
      -- long tapering snout, drooping over the chest
      for y = 29, 39 do
        local w = 4 - (y - 29) * 0.3
        for x = math.floor(CX - w + 0.5), math.floor(CX + w + 0.5) do
          local c = F.base
          if x < CX - w + 1.5 then c = F.hi elseif x > CX + w - 1.5 then c = F.shade end
          if y >= 36 and x > CX then c = F.shade end
          P(x, y + hd, c)
        end
      end
      for y = 31, 37, 2 do P(CX - 0.5, y + hd, F.hi) end
      stamp(29 + tw, 39 + hd, {".cp.", "pppp", ".ss."}, {c = CREAM, p = PINK, s = F.shade})
      -- tiny eyes
      for _, ex in ipairs({25, 37}) do
        P(ex, 26 + hd, INK); P(ex + 1, 26 + hd, INK); P(ex, 27 + hd, INK); P(ex + 1, 27 + hd, INK)
        P(ex, 26 + hd, CREAM)
      end
      P(23, 30 + hd, PINK); P(24, 30 + hd, PINK); P(39, 30 + hd, PINK); P(40, 30 + hd, PINK)
      for _, s in ipairs({-1, 1}) do
        line(CX + s * 3.5, 36 + hd, CX + s * 6.5, 35 + hd, F.deep)
        line(CX + s * 3.5, 38 + hd, CX + s * 6.5, 38 + hd, F.deep)
      end
    else
      for _, q in ipairs({{24, 27}, {25, 26}, {28, 30}, {29, 29}, {35, 28}, {36, 27}, {31, 33}, {32, 32}}) do
        P(q[1], q[2] + hd, F.hi)
      end
      for y = 34, 38 do for x = 25, 38 do
        local g = get(x, y + hd)
        if g == F.base or g == F.hi then P(x, y + hd, F.shade) end
      end end
    end
    hat(CX, 19.5 + hd, 15.5, 8, front)
    if front then
      for x = 20, 43 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
      pencil(48 + sw, 15 + hd, 44 + sw, 30 + hd)
      E(42.5, 23 + hd, 2.6, 2.4, F)
      E(42.1, 23.4 + hd, 1.3, 1.2, PINK)
    else
      pencil(15 - sw, 15 + hd, 19 - sw, 30 + hd)
      E(20.5, 23 + hd, 2.6, 2.4, F)
      P(20, 23 + hd, F.shade)
    end
  else
    local legN, legF = math.floor(o.armL * 1.5 + 0.5), math.floor(o.armR * 1.5 + 0.5)
    tail({{23, 61 + b}, {19, 64 + b}, {15, 64 + b}, {12 + ts, 62 + b}, {11 + ts, 59 + b}})
    local function foot(cx, lift, far)
      local bot = 70 + lift
      local r = far and FF or F
      for y = 61 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and r.shade or r.base) end end
      ell(cx + 1.5, bot - 1.5, 3.6, 2, function(x, y, nx, ny)
        if y == bot and x >= cx + 3 then return far and F.deep or F.shade end
        if far then return ny < 0 and PINK or F.shade end
        return lit(nx, ny, PK)
      end)
    end
    foot(28 + legF, o.footL, true)
    E(37 + o.armL, 51 + b, 2, 2, FF)
    ell(30, 52.5 + b, 9.5, 13.5, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 55 then
        if yy == 55 then return OV.shade end
        if yy >= 59 and x == 30 then return OV.shade end
        return lit(nx, ny, OV)
      end
      if x >= 33 and yy >= 46 then
        if yy == 46 then return OV.hi end
        return lit(nx, ny, OV)
      end
      local sx = 33 - math.floor((46 - yy) * 0.7)
      if yy < 46 and yy >= 41 and (x == sx or x == sx + 1) then return x == sx and OV.base or OV.shade end
      if x >= 35 and yy < 46 then return F.hi end
      return lit(nx, ny, F)
    end)
    stamp(37, 47 + b, {"cc", "sc"}, {c = CREAM, s = F.hi})
    P(33, 46 + b, HATB)
    foot(32 + legN, o.footR, false)
    local ax = 32 + math.floor(o.armR * 2 + 0.5)
    for pass = 1, 2 do
      for t = 0, 6 do
        local x, y = 30 + (ax - 30) * t / 6, 45 + b + 8 * t / 6
        if pass == 1 then ring(x, y, 2, 2, F.deep) else E(x, y, 2, 2, F) end
      end
    end
    ring(ax, 54 + b, 2, 1.8, F.deep)
    E(ax, 54 + b, 2, 1.8, PK)
    -- head with the long snout
    ring(28.5, 29 + hd, 10, 10, F.deep)
    E(28.5, 29 + hd, 10, 10, F)
    for x = 35, 47 do
      local t = (x - 35) / 12
      local ytop = 27 + t * 2.5
      local ybot = 34 - t * 2.2 + t * t * 1.2
      for y = math.floor(ytop + 0.5), math.floor(ybot + 0.5) do
        local c = F.base
        if y <= ytop + 0.6 then c = F.hi elseif y >= ybot - 0.6 then c = F.shade end
        P(x, y + hd, c)
      end
    end
    stamp(46 + tw, 29 + hd, {"cp", "ppp", "ss"}, {c = CREAM, p = PINK, s = F.shade})
    P(38, 33 + hd, F.deep); P(39, 33 + hd, F.deep); P(40, 32 + hd, F.deep)
    line(42, 31 + hd, 45, 29 + hd, F.deep); line(42, 32 + hd, 46, 33 + hd, F.deep)
    P(36, 25 + hd, INK); P(37, 25 + hd, INK); P(36, 26 + hd, INK); P(37, 26 + hd, INK); P(36, 25 + hd, CREAM)
    P(34, 29 + hd, PINK); P(35, 29 + hd, PINK)
    hat(28.5, 19.5 + hd, 13.5, 7, false)
    for x = 30, 42 do local g = get(x, 23 + hd); if g == F.base or g == F.hi then P(x, 23 + hd, F.shade) end end
    -- pencil behind the ear: eraser up-back over the brim, point forward-down
    E(26, 25 + hd, 2.6, 2.6, F)
    E(26.5, 25.3 + hd, 1.4, 1.4, PINK)
    P(24, 23 + hd, F.hi)
    pencil(15 + sw, 19 + hd, 29 + sw, 30 + hd)
    E(25, 24 + hd, 1.6, 1.6, F)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
