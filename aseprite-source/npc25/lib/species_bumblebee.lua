-- bumblebee (flyer) tables from specs/bumblebee.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "bumblebee", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 8, W = 40}
S.ramps = {main = {"#e8c46a", "#f5b83a", "#c97d3a", "#b88848"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8c46a", "#f5b83a", "#c97d3a", "#b88848", "#40325a", "#30264a", "#261d3c", "#76b24e", "#477e52", "#2f5248", "#cfe4ee", "#9fb6d8"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#f5b83a",
  bshade = h"#c97d3a",
  bhi = h"#e8c46a",
  deep = h"#b88848",
  head = h"#f5b83a",
  hat = h"#40325a",
  hatshade = h"#30264a",
  wing = h"#cfe4ee",
  belly = h"#40325a",
  acc = h"#40325a",
  accs = h"#30264a",
  eye = h"#40325a",
  q = h"#f5b83a",
  qshade = h"#c97d3a",
  qhi = h"#f5b83a",
  ink = h"#b88848", arm = h"#f5b83a", fbase = h"#c97d3a", fshade = h"#b88848"}
S.bw, S.top = 16, 9
S.quirk = {w = 4, h = 4, anchor = "hand", hex = "#f5b83a"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local Y = {hi = H"#e8c46a", base = H"#f5b83a", shade = H"#c97d3a", deep = H"#b88848"}
  local ST = {hi = H"#40325a", base = H"#40325a", shade = H"#30264a", deep = H"#261d3c"}
  local AP = {hi = H"#76b24e", base = H"#76b24e", shade = H"#477e52", deep = H"#2f5248"}
  local WHI, WBA = H"#cfe4ee", H"#9fb6d8"
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
  local function inkring(x1, y1, x2, y2) -- ink frame around a small prop
    for x = x1 - 1, x2 + 1 do P(x, y1 - 1, INK); P(x, y2 + 1, INK) end
    for y = y1, y2 do P(x1 - 1, y, INK); P(x2 + 1, y, INK) end
  end
  -- quirk: honey pot, 4x4 amber body with a pale lid rim, hung on a cord
  local function pot(x0, y0)
    inkring(x0, y0 - 1, x0 + 3, y0 + 3)
    for x = x0, x0 + 3 do P(x, y0 - 1, Y.hi) end
    for y = y0, y0 + 3 do for x = x0, x0 + 3 do
      local c = Y.base
      if x == x0 + 3 or y == y0 + 3 then c = Y.shade end
      P(x, y, c)
    end end
    P(x0, y0, Y.hi); P(x0 + 1, y0 + 1, WHI); P(x0 + 1, y0 - 2, INK); P(x0 + 2, y0 - 2, INK)
    P(x0 + 1, y0 + 2, Y.deep); P(x0 + 2, y0 + 2, Y.deep) -- honey label line
  end
  local function wingcol(u, v, edge)
    if edge then return WBA end
    if math.abs(v) < 0.18 and u < 0.55 then return WBA end -- vein
    if v > 0.45 and u > -0.2 then return WBA end
    return WHI
  end
  local function hwingcol(u, v, edge) if edge then return WBA end; return (u < -0.2 and v < 0.2) and WHI or WBA end
  local function body(cx, cy, rx, ry, side)
    E(cx, cy, rx, ry, function(nx, ny, edge, x, y)
      local yy = y - b
      local sy = yy + (side and math.floor((x - cx) * -0.25) or 0)
      local striped = (sy >= 44 and sy <= 46) or (sy >= 52 and sy <= 54) or (sy >= 59 and sy <= 60)
      if striped then return lit(nx, ny, ST) end
      if edge and ny > 0.55 then return Y.deep end
      return lit(nx, ny, Y)
    end)
  end
  local function leg(x, top, bot, far)
    local c1, c2 = far and ST.shade or ST.base, far and ST.deep or ST.shade
    for y = top, bot - 2 do P(x, y, c1); P(x + 1, y, c2) end
    E(x + 0.5 + (far and 0 or 0.5), bot - 0.8, 2.2, 1.3, function(nx, ny) return ny > 0.2 and c2 or c1 end)
  end
  local function hat(cx, cy, crx, brx, side)
    -- crown
    local x1, x2 = math.floor(cx - crx + 0.5), math.floor(cx + crx - 0.5)
    for y = cy - 4, cy - 1 do
      for x = x1, x2 do
        local yy = y - (cy - 4)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = Y.hi
          if x >= x2 - 1 then c = Y.deep end
          if (x * 2 + y) % 5 == 0 and yy < 2 and x < x2 - 1 and x > x1 then c = Y.deep end
          if yy == 2 then c = (x >= x2 - 1) and AP.shade or AP.base end
          if yy == 3 then c = AP.deep end
          P(x, y, c)
        end
      end
    end
    E(cx + (side or 0), cy + 0.5, brx, 1.8, function(nx, ny, edge, x, y)
      if ny > 0.3 then return Y.shade end
      if nx > 0.6 then return Y.deep end
      if (x * 2 + y) % 5 == 0 and ny < 0.3 then return Y.deep end
      return Y.hi
    end)
  end

  local CX = 31.5
  if view == "front" or view == "back" then
    local front = view == "front"
    -- wings behind: big forewing raised, small hindwing; ws = spread (flap)
    local wt = 0.42 + ws * 0.32
    local wcx, wcy = CX - 11.5 - ws * 0.5, 36 + b - ws * 1.8
    local hwt = -0.35 - ws * 0.15
    for _, m in ipairs({false, true}) do
      RE(CX - 11 - ws * 0.3, 45 + b - ws * 0.5, 4.6, 2.6, hwt, m, hwingcol)
      RE(wcx, wcy, 7.2, 3.9, wt, m, wingcol)
    end
    -- legs (front: viewer-left = creature right foot; back: viewer-left = creature left)
    local fVL, fVR = o.footR, o.footL
    if not front then fVL, fVR = o.footL, o.footR end
    leg(27, 60 + b, 70 + fVL, false); leg(35, 60 + b, 70 + fVR, false)
    body(CX, 50 + b, 12, 12.6)
    if front then
      -- apron bib over the belly
      for y = 44 + b, 63 + b do for x = 26, 37 do
        local nx, ny = (x - CX) / 12, (y - 50 - b) / 12.6
        if nx * nx + ny * ny <= 0.8 then
          local c = AP.base
          if x >= 36 then c = AP.shade end
          if y == 44 + b then c = AP.hi end
          if nx * nx + ny * ny > 0.62 then c = AP.deep end
          P(x, y, c)
        end
      end end
      for y = 51, 55 do P(29, y + b, AP.shade); P(34, y + b, AP.shade) end
      for x = 29, 34 do P(x, 55 + b, AP.shade) end
      P(30, 51 + b, AP.shade); P(33, 51 + b, AP.shade)
      -- straps to the shoulders
      for y = 37, 43 do
        local off = math.floor((43 - y) / 3)
        P(26 - off, y + b, AP.base); P(37 + off, y + b, AP.shade)
      end
    else
      -- back: crossed straps and a waist bow
      for t = 0, 10 do
        P(24 + t, 38 + t + b, AP.base); P(39 - t, 38 + t + b, AP.shade)
      end
      for x = 20, 43 do
        local nx = (x - CX) / 12
        if nx * nx <= 0.92 then P(x, 47 + b, x > 35 and AP.shade or AP.base) end
      end
      P(30, 46 + b, AP.hi); P(29, 47 + b, AP.hi); P(30, 48 + b, AP.base); P(29, 48 + b, AP.shade)
      P(33, 46 + b, AP.base); P(34, 47 + b, AP.base); P(33, 48 + b, AP.shade); P(34, 48 + b, AP.deep)
      P(31, 47 + b, AP.deep); P(32, 47 + b, AP.deep)
      -- stinger
      P(31, 63 + b, ST.shade); P(32, 63 + b, ST.deep); P(31, 64 + b, ST.deep)
    end
    -- little arms (front legs)
    for _, s in ipairs({-1, 1}) do
      local ax = s < 0 and 20 or 43
      local dy = (ws < 0) and 1 or 0
      E(ax, 48 + b + dy, 1.6, 3.2, function(nx, ny) return lit(nx, ny, ST) end)
      if front then P(ax, 51 + b + dy, ST.shade) end
    end
    -- honey pot on the strap (front: viewer-left; back: viewer-right, same strap)
    if front then
      pot(15, 54 + b)
      for t = 0, 6 do P(25 - t, 45 + t + b, AP.deep) end
    else
      pot(45, 54 + b)
      P(41, 51 + b, AP.deep); P(42, 52 + b, AP.deep)
    end
    -- head
    E(CX, 25.5 + hd, 12.5, 9.8, function(nx, ny, edge)
      if edge and ny > 0.6 then return Y.deep end
            if not front and ny > 0.55 and ny < 0.85 then return (nx > 0.3) and ST.shade or ST.base end
      return lit(nx, ny, Y)
    end)
    for x = 22, 41 do if get(x, 20 + hd) then P(x, 20 + hd, x > 34 and Y.deep or Y.shade) end end
    if front then
      for _, ex in ipairs({26, 36}) do
        for y = 23, 25 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 23 + hd, WHI)
      end
      P(23, 27 + hd, Y.shade); P(24, 27 + hd, Y.shade); P(39, 27 + hd, Y.shade); P(40, 27 + hd, Y.shade)
      P(30, 28 + hd, INK); P(31, 29 + hd, INK); P(32, 29 + hd, INK); P(33, 28 + hd, INK)
    end
    -- antennae through the hat
    local function ant(x0, s)
      P(x0, 13 + hd, ST.base); P(x0, 12 + hd, ST.base); P(x0 - s, 11 + hd, ST.base)
      E(x0 - 1.5 * s, 9.5 + hd, 1.1, 1.1, function() return ST.base end)
      P(x0 - 2 * s + (s > 0 and 1 or 0), 9 + hd, s > 0 and WBA or ST.base)
    end
    ant(29, 1); ant(34, -1)
    hat(CX, 17 + hd, 6.5, 12)
  else
    -- side, facing right; near side = creature right
    local wt = -0.9 - ws * 0.25
    RE(25 - ws * 0.4, 32 + b - ws * 1.2, 7, 3.4, wt + 0.25, false, function(u, v, edge) return edge and WBA or (v < -0.2 and WHI or WBA) end)
    leg(26, 58 + b, 70 + o.footL, true)
    body(29, 48 + b, 10, 13, true)
    -- apron front edge with strap over the shoulder
    for y = 42 + b, 61 + b do for x = 33, 40 do
      local nx, ny = (x - 29) / 10, (y - 48 - b) / 13
      local d = nx * nx + ny * ny
      if d <= 1 and get(x, y) then
        local c = AP.base
        if d > 0.8 then c = AP.shade end
        if y == 42 + b then c = AP.hi end
        if ny > 0.8 then c = AP.deep end
        P(x, y, c)
      end
    end end
    for t = 0, 6 do P(33 - t, 42 - t + b, AP.base); P(32 - t, 42 - t + b, AP.shade) end
    for y = 48, 52 do P(36, y + b, AP.shade) end
    for x = 36, 39 do P(x, 52 + b, AP.shade) end
    leg(32, 58 + b, 70 + o.footR, false)
    -- near wing over the back
    RE(21 - ws * 0.5, 36 + b - ws * 1.3, 8, 3.8, wt, false, wingcol)
    RE(22, 44 + b - ws * 0.3, 4.5, 2.4, -0.2 - ws * 0.1, false, hwingcol)
    -- arm
    local dy = (ws < 0) and 1 or 0
    E(37, 47 + b + dy, 1.6, 3, function(nx, ny) return lit(nx, ny, ST) end)
    P(38, 50 + b + dy, ST.base)
    -- honey pot at the belly front
    P(39, 46 + b, AP.deep); P(40, 47 + b, AP.deep)
    pot(40, 50 + b)
    -- head
    E(35, 25 + hd, 10.5, 9.6, function(nx, ny, edge)
      if edge and ny > 0.6 then return Y.deep end
      return lit(nx, ny, Y)
    end)
    for x = 26, 44 do if get(x, 20 + hd) then P(x, 20 + hd, x > 40 and Y.deep or Y.shade) end end
    for y = 23, 25 do P(40, y + hd, INK); P(41, y + hd, INK) end
    P(40, 23 + hd, WHI)
    P(39, 27 + hd, Y.shade); P(40, 27 + hd, Y.shade)
    P(43, 28 + hd, INK); P(44, 28 + hd, INK); P(45, 27 + hd, INK)
    -- one antenna, swept forward
    P(37, 13 + hd, ST.base); P(38, 12 + hd, ST.base); P(39, 11 + hd, ST.base)
    E(40.5, 9.5 + hd, 1.1, 1.1, function() return ST.base end); P(40, 9 + hd, WBA)
    hat(33.5, 17 + hd, 5.5, 11, 0)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
