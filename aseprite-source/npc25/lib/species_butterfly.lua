-- butterfly (flyer) tables from specs/butterfly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "butterfly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 42}
S.ramps = {main = {"#bb8a5c", "#94684f", "#664654", "#432f45"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#bb8a5c", "#94684f", "#664654", "#432f45", "#4a3352", "#2f5250", "#f7c843", "#72b24e", "#e9c274", "#f5809f", "#c94f84"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#94684f",
  bshade = h"#664654",
  bhi = h"#bb8a5c",
  deep = h"#432f45",
  head = h"#94684f",
  hat = h"#e9c274",
  hatshade = h"#f7c843",
  wing = h"#4a3352",
  belly = h"#f7c843",
  acc = h"#bb8a5c",
  accs = h"#bb8a5c",
  eye = h"#f7c843",
  q = h"#f5809f",
  qshade = h"#c94f84",
  qhi = h"#f5809f",
  ink = h"#432f45", arm = h"#94684f", fbase = h"#664654", fshade = h"#432f45"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 3, anchor = "neck", hex = "#f5809f"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local BR = {hi = H"#bb8a5c", base = H"#94684f", shade = H"#664654", deep = H"#432f45"}
  local WG = {base = H"#4a3352", shade = H"#432f45", deep = H"#2f5250"}
  local YEL, GRN, CRM = H"#f7c843", H"#72b24e", H"#e9c274"
  local AP = {shade = H"#2f5250"}
  local PK, PKS = H"#f5809f", H"#c94f84"
  local b, hd, ws = o.body, o.head, o.armL
  local G = {}
  local function P(x, y, c) if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c end end
  local function get(x, y) return G[y * 64 + x] end
  local function shape(x1, y1, x2, y2, ins, col)
    for y = math.floor(y1), math.ceil(y2) do for x = math.floor(x1), math.ceil(x2) do
      if ins(x, y) then
        local edge = not (ins(x + 1, y) and ins(x - 1, y) and ins(x, y + 1) and ins(x, y - 1))
        P(x, y, col(x, y, edge))
      end
    end end
  end
  local function E(cx, cy, rx, ry, col)
    shape(cx - rx - 1, cy - ry - 1, cx + rx + 1, cy + ry + 1,
      function(x, y) local nx, ny = (x - cx) / rx, (y - cy) / ry; return nx * nx + ny * ny <= 1 end,
      function(x, y, edge) return col((x - cx) / rx, (y - cy) / ry, edge, x, y) end)
  end
  -- rotated ellipse; mirror=true reflects it about the frame centre line
  local function RE(cx, cy, rx, ry, t, mirror, col)
    local c, s = math.cos(t), math.sin(t)
    local function ins(x, y)
      if mirror then x = 63 - x end
      local dx, dy = x - cx, y - cy
      local u, v = (dx * c + dy * s) / rx, (-dx * s + dy * c) / ry
      return u * u + v * v <= 1, u, v
    end
    local R = math.max(rx, ry) + 1
    local x1, x2 = cx - R, cx + R
    if mirror then x1, x2 = 63 - x2, 63 - x1 end
    shape(x1, cy - R, x2, cy + R, function(x, y) return (ins(x, y)) end,
      function(x, y, edge) local _, u, v = ins(x, y); return col(u, v, edge, x, y) end)
  end
  local function lit(nx, ny, r)
    local s = nx * 0.55 + ny * 0.83
    if s > 0.85 then return r.deep end
    if s > 0.35 then return r.shade end
    if s < -0.5 then return r.hi end
    return r.base
  end
  local CX = 31.5
  -- forewing colouring: uo = outward along the wing (0 root .. 1 tip), v across
  local function fore(uo, v, edge, x, y, far)
    if far then
      if edge then return WG.deep end
      return (v > 0.2) and WG.deep or WG.shade
    end
    local d = uo * uo + v * v
    if edge then return WG.deep end
    if d > 0.66 then
      if (x + 2 * y) % 4 == 0 then return CRM end
      return WG.deep
    end
    local sx, sy = uo - 0.22, v * 1.15
    if sx * sx + sy * sy < 0.27 then
      if math.abs(v) < 0.07 and uo < 0.5 then return WG.base end
      if sx > 0.25 and sy < -0.05 then return CRM end
      return YEL
    end
    local gx, gy = uo + 0.3, v - 0.5
    if gx * gx + gy * gy < 0.04 then return GRN end
    if uo < -0.45 then return WG.shade end
    if math.abs(v) < 0.09 and uo < 0.0 then return WG.shade end
    return WG.base
  end
  local function hind(uo, v, edge, x, y, far)
    if edge then return WG.deep end
    if far then return WG.deep end
    local d = uo * uo + v * v
    local sx, sy = uo - 0.12, v
    if sx * sx + sy * sy < 0.2 then return (sx > 0.2 and sy < 0) and YEL or GRN end
    if d > 0.6 then return ((x + y) % 3 == 0) and YEL or WG.deep end
    if uo < -0.4 then return WG.shade end
    return WG.base
  end
  -- wing drawn as a rotated ellipse whose u axis points OUTWARD at angle phi (radians, screen space)
  local function wing(px, py, phi, rx, ry, mirror, fn, far)
    local cx, cy = px + math.cos(phi) * rx * 0.82, py + math.sin(phi) * rx * 0.82
    RE(cx, cy, rx, ry, phi, mirror, function(u, v, edge, x, y) return fn(u, v, edge, x, y, far) end)
  end
  local function leg(x, top, bot, far)
    local c1 = far and BR.deep or BR.shade
    for y = top, bot do P(x, y, c1) end
    P(x + 1, bot, BR.deep); P(x - 1, bot, c1)
  end
  local function fuzzbody(cx, cy, rx, ry)
    E(cx, cy, rx, ry, function(nx, ny, edge, x, y)
      if edge and ny < 0.5 and (y % 3 == 0) then return nil end
      if (x + y * 2) % 5 == 0 and nx < 0.2 and ny < 0.4 then return BR.hi end
      return lit(nx, ny, BR)
    end)
  end
  local function bow(x0, y0)  -- 6x3 ribbon bow: two loops, knot, tails
    local pat = {"pp..pp", "pPkkPp", ".k..k."}
    for j, row in ipairs(pat) do for i = 1, 6 do
      local ch = row:sub(i, i)
      if ch == "p" then P(x0 + i - 1, y0 + j - 1, PK)
      elseif ch == "P" or ch == "k" then P(x0 + i - 1, y0 + j - 1, PKS) end
    end end
    P(x0, y0, PK); P(x0 + 5, y0 + 1, PKS)
  end
  local function hat(cx, cy, crx, brx)
    local x1, x2 = math.floor(cx - crx + 0.5), math.floor(cx + crx - 0.5)
    for y = cy - 4, cy - 1 do for x = x1, x2 do
      local yy = y - (cy - 4)
      if not (yy == 0 and (x == x1 or x == x2)) then
        local c = CRM
        if x <= x1 + 1 and yy < 2 then c = YEL end
        if x >= x2 - 1 then c = BR.hi end
        if yy == 2 then c = (x >= x2 - 1) and AP.shade or GRN end
        if yy == 3 then c = AP.shade end
        P(x, y, c)
      end
    end end
    E(cx, cy + 0.5, brx, 1.8, function(nx, ny, edge, x, y)
      if ny > 0.3 then return BR.hi end
      if nx < -0.5 and ny < 0 then return YEL end
      if (x * 2 + y) % 5 == 0 then return BR.hi end
      return CRM
    end)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local phi = math.pi + 1.12 - ws * 0.2       -- outward up-left; open = flatter
    local rx, ry = 11 + ws * 0.3, 6.6 - (ws < 0 and 1.4 or 0)
    for _, m in ipairs({false, true}) do
      wing(27 - ws * 0.3, 50 + b, math.pi - 0.7 + ws * 0.1, 7, 5, m, hind)
      wing(27.5 - ws * 0.3, 41 + b - ws * 0.4, phi, rx, ry, m, fore)
    end
    local fVL, fVR = o.footR, o.footL
    if not front then fVL, fVR = o.footL, o.footR end
    leg(29, 59 + b, 70 + fVL); leg(34, 59 + b, 70 + fVR)
    fuzzbody(CX, 49.5 + b, 6.6, 10.5)
    if front then
      for y = 46 + b, 60 + b do for x = 28, 35 do
        local nx, ny = (x - CX) / 6.6, (y - 49.5 - b) / 10.5
        if nx * nx + ny * ny <= 0.8 then
          local c = GRN
          if x >= 34 then c = AP.shade end
          if nx * nx + ny * ny > 0.6 then c = AP.shade end
          P(x, y, c)
        end
      end end
      P(30, 51 + b, AP.shade); P(31, 51 + b, AP.shade); P(32, 51 + b, AP.shade); P(33, 51 + b, AP.shade)
      for y = 39, 45 do P(28 - (y < 42 and 1 or 0), y + b, GRN); P(35 + (y < 42 and 1 or 0), y + b, AP.shade) end
    else
      for y = 38, 60 do if get(31, y + b) then P(31, y + b, BR.shade); P(32, y + b, BR.deep) end end
      for t = 0, 8 do P(26 + t, 39 + t + b, GRN); P(37 - t, 39 + t + b, AP.shade) end
      for x = 25, 38 do if get(x, 51 + b) then P(x, 51 + b, x > 34 and AP.shade or GRN) end end
      P(30, 52 + b, GRN); P(29, 53 + b, GRN); P(33, 52 + b, AP.shade); P(34, 53 + b, AP.shade)
    end
    -- thin arms
    local dy = ws < 0 and 1 or 0
    E(24.5, 48 + b + dy, 1.2, 3, function(nx, ny) return ny > 0.4 and BR.shade or BR.base end)
    E(38.5, 48 + b + dy, 1.2, 3, function(nx, ny) return ny > 0.4 and BR.deep or BR.shade end)
    -- head
    E(CX, 25.5 + hd, 8.8, 8.4, function(nx, ny, edge, x, y)
      if edge and ny > 0.6 then return BR.deep end
      if (x * 3 + y) % 7 == 0 and ny < 0.3 and nx < 0.3 then return BR.hi end
      return lit(nx, ny, BR)
    end)
    for x = 24, 39 do if get(x, 20 + hd) then P(x, 20 + hd, x > 35 and BR.deep or BR.shade) end end
    -- fluffy collar
    for x = 27, 36 do
      if (x % 2 == 0) then P(x, 34 + hd, BR.hi) else P(x, 34 + hd, BR.base) end
    end
    if front then
      for _, ex in ipairs({27, 35}) do
        for y = 24, 26 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 24 + hd, CRM)
      end
      P(25, 28 + hd, PK); P(26, 28 + hd, PK); P(37, 28 + hd, PK); P(38, 28 + hd, PK)
      P(31, 29 + hd, INK); P(32, 29 + hd, INK); P(30, 28 + hd, BR.deep); P(33, 28 + hd, BR.deep)
      bow(29, 33 + hd)
    end
    -- clubbed antennae
    local function ant(x0, s)
      P(x0, 13 + hd, BR.deep); P(x0 - s, 12 + hd, BR.deep); P(x0 - s, 11 + hd, BR.deep)
      P(x0 - 2 * s, 10 + hd, BR.deep); P(x0 - 3 * s, 10 + hd, BR.deep); P(x0 - 2 * s, 9 + hd, BR.deep)
      P(x0 - 3 * s, 9 + hd, s > 0 and CRM or BR.deep)
    end
    ant(29, 1); ant(34, -1)
    hat(CX, 17 + hd, 6, 10.5)
    if not front then bow(29, 12 + hd) end
  else
    -- side, facing right
    local phi = -math.pi / 2 - 0.3 - (ws + 1) * 0.3
    wing(29, 39 + b, phi + 0.35, 8.5, 5.5, false, fore, true)
    wing(27, 46 + b, math.pi - 0.45, 6, 4.2, false, hind, true)
    leg(28, 57 + b, 70 + o.footL, true)
    fuzzbody(30, 47 + b, 6.4, 11.5)
    for y = 42 + b, 59 + b do for x = 32, 37 do
      local nx, ny = (x - 30) / 6.4, (y - 47 - b) / 11.5
      local d = nx * nx + ny * ny
      if d <= 1 and get(x, y) then P(x, y, (d > 0.75 or ny > 0.7) and AP.shade or GRN) end
    end end
    for t = 0, 5 do P(32 - t, 42 - t + b, GRN) end
    leg(32, 57 + b, 70 + o.footR, false)
    wing(27, 46 + b, math.pi - 0.55 - ws * 0.05, 6.4, 4.6, false, hind)
    wing(28, 41 + b, phi, 11, 6.6 - (ws < 0 and 1.2 or 0), false, fore)
    local dy = ws < 0 and 1 or 0
    E(35.5, 46 + b + dy, 1.2, 3, function(nx, ny) return ny > 0.4 and BR.shade or BR.base end)
    -- head
    E(35, 25 + hd, 9, 8.6, function(nx, ny, edge, x, y)
      if edge and ny > 0.6 then return BR.deep end
      if (x * 3 + y) % 7 == 0 and ny < 0.3 and nx < 0.3 then return BR.hi end
      return lit(nx, ny, BR)
    end)
    for x = 27, 43 do if get(x, 20 + hd) then P(x, 20 + hd, x > 39 and BR.deep or BR.shade) end end
    for y = 24, 26 do P(39, y + hd, INK); P(40, y + hd, INK) end
    P(39, 24 + hd, CRM)
    P(38, 28 + hd, PK); P(39, 28 + hd, PK)
    -- curled proboscis
    P(43, 29 + hd, BR.deep); P(44, 30 + hd, BR.deep); P(45, 31 + hd, BR.deep); P(46, 31 + hd, BR.deep)
    P(47, 30 + hd, BR.deep); P(46, 29 + hd, BR.deep)
    -- ribbon bow behind the head
    bow(23, 27 + hd)
    -- one antenna
    P(37, 13 + hd, BR.deep); P(38, 12 + hd, BR.deep); P(38, 11 + hd, BR.deep); P(39, 10 + hd, BR.deep)
    P(40, 10 + hd, BR.deep); P(39, 9 + hd, CRM); P(40, 9 + hd, BR.deep)
    hat(33.5, 17 + hd, 5.5, 10)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
