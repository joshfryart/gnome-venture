-- dragonfly (flyer) tables from specs/dragonfly.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "dragonfly", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 46}
S.ramps = {main = {"#4fb35a", "#2f7f5a", "#2a6a4c", "#2f6a92"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#4fb35a", "#2f7f5a", "#2a6a4c", "#2f6a92", "#3a9fbf", "#d6ead8", "#a2c6c2", "#c96e3c", "#e2b552", "#f4f6e2"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#2f7f5a",
  bshade = h"#2a6a4c",
  bhi = h"#4fb35a",
  deep = h"#2f6a92",
  head = h"#2f7f5a",
  hat = h"#c96e3c",
  hatshade = h"#e2b552",
  wing = h"#d6ead8",
  belly = h"#3a9fbf",
  acc = h"#3a9fbf",
  accs = h"#2f6a92",
  eye = h"#3a9fbf",
  q = h"#e2b552",
  qshade = h"#f4f6e2",
  qhi = h"#e2b552",
  ink = h"#2f6a92", arm = h"#2f7f5a", fbase = h"#2a6a4c", fshade = h"#2f6a92"}
S.bw, S.top = 16, 9
S.quirk = {w = 3, h = 3, anchor = "chest", hex = "#e2b552"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local GR = {hi = H"#4fb35a", base = H"#2f7f5a", shade = H"#2a6a4c", deep = H"#2f6a92"}
  local GOG = H"#3a9fbf"
  local WH, WB, WE = H"#d6ead8", H"#a2c6c2", H"#2f6a92"
  local ORG, GOLD, GL = H"#c96e3c", H"#e2b552", H"#f4f6e2"
  local b, hd, ws = o.body + 3, o.head, o.armL
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
  local function wingc(uo, v, edge, x, y, far)
    if edge then return WE end
    if far then return (math.abs(v) < 0.2) and WE or WB end
    if uo > 0.62 and v < -0.15 and v > -0.75 then return WE end      -- pterostigma
    if math.abs(v) < 0.16 and uo < 0.8 then return WB end            -- main vein
    local k = (uo + 1) * 3.2
    if k - math.floor(k) < 0.16 then return WB end                   -- cross veins
    return (v > 0.35) and WB or WH
  end
  local function wing(px, py, phi, rx, ry, mirror, far)
    local cx, cy = px + math.cos(phi) * rx * 0.86, py + math.sin(phi) * rx * 0.86
    RE(cx, cy, rx, ry, phi, mirror, function(u, v, edge, x, y) return wingc(u, v, edge, x, y, far) end)
  end
  local function seg(pts, r)
    for i, p in ipairs(pts) do
      E(p[1], p[2], r, r, function(nx, ny, edge)
        if i % 2 == 0 then return (nx + ny > 0.6) and GR.shade or ORG end
        return lit(nx, ny, GR)
      end)
    end
  end
  local function leg(x, top, bot, far)
    local c = far and GR.shade or GR.base
    for y = top, bot - 3 do P(x, y, c); P(x + 1, y, GR.shade) end
    for y = bot - 2, bot do for xx = x - 1, x + 2 do
      local k = ORG
      if y == bot then k = GR.deep elseif xx == x + 2 or far then k = GR.shade end
      if y == bot - 2 and (xx == x - 1 or xx == x + 2) then k = nil end
      if k then P(xx, y, k) end
    end end
    if not far then P(x - 1, bot - 1, GOLD) end
  end
  local function watch(x0, y0)  -- 3x3 gold face with ink rim and glint
    for x = x0 - 1, x0 + 3 do P(x, y0 - 1, INK); P(x, y0 + 3, INK) end
    for y = y0, y0 + 2 do P(x0 - 1, y, INK); P(x0 + 3, y, INK) end
    for y = y0, y0 + 2 do for x = x0, x0 + 2 do P(x, y, GOLD) end end
    P(x0, y0, GL); P(x0 + 1, y0 + 1, GR.deep); P(x0 + 2, y0 + 1, GR.deep)
    P(x0 + 1, y0 - 2, GOLD)
  end
  local function hat(cx, cy, crx, brx)
    local x1, x2 = math.floor(cx - crx + 0.5), math.floor(cx + crx - 0.5)
    for y = cy - 6, cy - 1 do for x = x1, x2 do
      local yy = y - (cy - 6)
      if not (yy == 0 and (x == x1 or x == x2)) then
        local c = GOLD
        if yy == 0 and x <= x1 + 2 then c = GL end
        if x >= x2 then c = ORG end
        if (x * 3 + y) % 7 == 0 and yy < 4 and x < x2 and x > x1 then c = ORG end
        if yy == 4 then c = ORG end
        if yy == 5 then c = GR.deep end
        P(x, y, c)
      end
    end end
    E(cx, cy + 0.5, brx, 1.7, function(nx, ny, edge, x, y)
      if ny > 0.3 then return ORG end
      if nx > 0.65 then return ORG end
      return GOLD
    end)
  end
  local function lens(cx, cy, r, pupil)
    E(cx, cy, r, r, function(nx, ny, edge)
      if edge then return GR.deep end
      if nx + ny > 0.7 then return GR.deep end
      return GOG
    end)
    if pupil then
      local px, py = math.floor(cx - 0.5), math.floor(cy - 1)
      for y = py, py + 2 do P(px, y, INK); P(px + 1, y, INK) end
      P(px, py, GL)
    end
    P(math.floor(cx - r * 0.55), math.floor(cy - r * 0.55), WH)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local up = 0.28 + ws * 0.2
    for _, m in ipairs({false, true}) do
      wing(30, 41 + b, math.pi + up - 0.55, 9.6, 2.6, m)
      wing(30, 37 + b, math.pi + up, 10.5, 3, m)
    end
    local fVL, fVR = o.footR, o.footL
    if not front then fVL, fVR = o.footL, o.footR end
    leg(28, 44 + b, 70 + fVL); leg(35, 44 + b, 70 + fVR)
    if front then
      -- tail curls out to the viewer's right
      seg({{32, 48 + b}, {33.5, 51 + b}, {35, 54 + b}, {37.5, 56.5 + b}, {40.5, 57.5 + b}, {43.5, 56 + b}, {45, 53 + b}, {45, 50 + b}}, 1.9)
    else
      local pts = {}
      for i = 0, 6 do pts[#pts + 1] = {31.5, 48 + i * 2.6 + b} end
      seg(pts, 1.9)
      for i = 1, 6 do local y = math.floor(48 + i * 2.6 - 1.3 + b); P(31, y, GR.deep); P(32, y, GR.deep) end
    end
    -- thorax
    E(CX, 40 + b, 6.6, 7.4, function(nx, ny, edge, x, y)
      if edge and ny > 0.5 then return GR.deep end
      if front and ny > -0.1 and ny < 0.7 and math.abs(nx) < 0.45 then return GR.hi end
      return lit(nx, ny, GR)
    end)
    if not front then for y = 34, 46 do P(31, y + b, GR.shade) end end
    -- arms
    local dy = ws < 0 and 1 or 0
    for _, s in ipairs({-1, 1}) do
      local ax = s < 0 and 24 or 39
      for y = 37, 43 do P(ax, y + b + (y > 40 and dy or 0), s < 0 and GR.base or GR.shade) end
      E(ax, 44.5 + b + dy, 1.3, 1.3, function(nx, ny) return ny > 0.3 and GR.shade or GR.base end)
    end
    -- pocket watch: front viewer-left on a chain, back between the wings
    if front then
      for t = 0, 4 do P(30 - t, 42 + math.floor(t / 2) + b, GOLD) end
      watch(23, 46 + b)
    else
      P(30, 37 + b, GOLD); P(33, 37 + b, GOLD)
      watch(30, 39 + b)
    end
    -- head
    E(CX, 25.5 + hd, 9.6, 8.8, function(nx, ny, edge, x, y)
      if edge and ny > 0.6 then return GR.deep end
      if front and ny > 0.35 and math.abs(nx) < 0.55 then return (ny > 0.75) and GR.base or GR.hi end
      return lit(nx, ny, GR)
    end)
    if front then
      -- goggle strap then lenses
      for x = 21, 42 do if get(x, 22 + hd) then P(x, 22 + hd, GR.deep) end end
      lens(26.5, 22.5 + hd, 4.4, true); lens(36.5, 22.5 + hd, 4.4, true)
      P(31, 22 + hd, GR.deep); P(32, 22 + hd, GR.deep)
      P(30, 30 + hd, INK); P(31, 31 + hd, INK); P(32, 31 + hd, INK); P(33, 30 + hd, INK)
      P(25, 29 + hd, ORG); P(26, 29 + hd, ORG); P(37, 29 + hd, ORG); P(38, 29 + hd, ORG)
    else
      for x = 22, 41 do if get(x, 22 + hd) then P(x, 22 + hd, GR.deep); P(x, 23 + hd, GR.deep) end end
      P(31, 22 + hd, GOG); P(32, 22 + hd, GOG); P(31, 23 + hd, GR.deep)
    end
    for x = 23, 40 do if get(x, 18 + hd) and not front then P(x, 18 + hd, GR.shade) end end
    hat(CX, 15 + hd, 6, 11)
  else
    -- side, facing right: long tail to the left, goggles on the right
    local phi = -math.pi / 2 - 0.45 - ws * 0.33
    wing(31, 36 + b, phi + 0.35, 10, 2.8, false, true)
    wing(30, 40 + b, phi - 0.25, 9, 2.6, false, true)
    leg(30, 45 + b, 70 + o.footL, true)
    local sw = (ws < 0) and 1 or 0
    seg({{27, 45 + b}, {24, 46 + b}, {21, 47 + b + sw}, {18, 47.5 + b + sw}, {15, 47.5 + b + sw}, {12.5, 46.5 + b + sw}, {11, 44.5 + b + sw}}, 1.9)
    E(32, 41 + b, 5.8, 7.2, function(nx, ny, edge)
      if edge and ny > 0.5 then return GR.deep end
      return lit(nx, ny, GR)
    end)
    leg(34, 45 + b, 70 + o.footR, false)
    wing(30, 39 + b, phi - 0.3, 9.5, 2.7, false)
    wing(31, 35 + b, phi, 10.5, 3, false)
    local dy = ws < 0 and 1 or 0
    for y = 37, 43 do P(36, y + b + (y > 40 and dy or 0), GR.base) end
    E(36.5, 44.5 + b + dy, 1.3, 1.3, function(nx, ny) return ny > 0.3 and GR.shade or GR.base end)
    P(35, 38 + b, GOLD); P(36, 39 + b, GOLD)
    watch(38, 40 + b)
    E(36, 25.5 + hd, 8.6, 8.8, function(nx, ny, edge, x, y)
      if edge and ny > 0.6 then return GR.deep end
      if ny > 0.35 and nx > 0.0 and nx < 0.75 then return GR.hi end
      return lit(nx, ny, GR)
    end)
    for x = 28, 41 do if get(x, 22 + hd) then P(x, 22 + hd, GR.deep) end end
    lens(41.5, 22.5 + hd, 4.4, true)
    P(42, 30 + hd, INK); P(43, 30 + hd, INK); P(44, 29 + hd, INK)
    P(38, 29 + hd, ORG); P(39, 29 + hd, ORG)
    hat(34.5, 15 + hd, 5.5, 10.5)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
