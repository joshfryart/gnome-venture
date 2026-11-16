-- bat (flyer) tables from specs/bat.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "bat", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 7, W = 44}
S.ramps = {main = {"#c9b2f0", "#8a6fd0", "#5a459e", "#35295f"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c9b2f0", "#8a6fd0", "#5a459e", "#35295f", "#f5b82e", "#d98322", "#f5809f", "#8f4a1f", "#aaa9b8"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#8a6fd0",
  bshade = h"#5a459e",
  bhi = h"#c9b2f0",
  deep = h"#35295f",
  head = h"#8a6fd0",
  hat = h"#f5b82e",
  hatshade = h"#d98322",
  wing = h"#c9b2f0",
  belly = h"#f5b82e",
  acc = h"#f5b82e",
  accs = h"#d98322",
  eye = h"#f5b82e",
  q = h"#d98322",
  qshade = h"#8f4a1f",
  qhi = h"#aaa9b8",
  ink = h"#35295f", arm = h"#8a6fd0", fbase = h"#5a459e", fshade = h"#35295f"}
S.bw, S.top = 16, 8
S.quirk = {w = 5, h = 4, anchor = "hand", hex = "#d98322"}

-- Stage 3 (Opus): hand-placed pixel art for one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local b, hd = o.body, o.head
  local walk = frame >= 3
  local s = o.armL                      -- wing spread: 2 open, 1 down-stroke, 0 half, -1 closed
  local top = species.T + 1 + hd         -- first painted row (outline sits one above)
  local G, TAG, cur = {}, {}, "x"
  local floor, ceil, sqrt, rad, cos, sin = math.floor, math.ceil, math.sqrt, math.rad, math.cos, math.sin
  local function P(x, y, c)
    if c and x >= 1 and x <= 62 and y >= top and y <= 70 then G[y * 64 + x] = c; TAG[y * 64 + x] = cur end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function tag(x, y) return TAG[y * 64 + x] end
  local function mx(x) return 63 - x end
  local function lit(nx, ny, r)
    local d = nx * 0.55 + ny * 0.83
    if d > 0.92 and r.deep then return r.deep end
    if d > 0.42 then return r.shade end
    if d < -0.55 then return r.hi end
    return r.base
  end
  local function paint(r, x, y, nx, ny)
    if type(r) == "function" then return r(x, y, nx, ny) end
    if type(r) == "table" then return lit(nx, ny, r) end
    return r
  end
  local function E(cx, cy, rx, ry, r)
    for y = floor(cy - ry - 1), ceil(cy + ry + 1) do
      for x = floor(cx - rx - 1), ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, paint(r, x, y, nx, ny)) end
      end
    end
  end
  -- rotated ellipse from (x0,y0) along (dx,dy), length L, half width w
  local function limb(x0, y0, dx, dy, L, w, r)
    local n = sqrt(dx * dx + dy * dy); dx, dy = dx / n, dy / n
    local cx, cy, R = x0 + dx * L / 2, y0 + dy * L / 2, L / 2 + w
    for y = floor(cy - R), ceil(cy + R) do
      for x = floor(cx - R), ceil(cx + R) do
        local px, py = x - cx, y - cy
        local u, v = (px * dx + py * dy) / (L / 2), (-px * dy + py * dx) / w
        if u * u + v * v <= 1 then P(x, y, paint(r, x, y, u * dx - v * dy, u * dy + v * dx)) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  -- paint pixels of part `back` that touch part `front` with colour c (inner separation line)
  local function sep(back, front, c)
    local list = {}
    for k, t in pairs(TAG) do
      if t == back then
        local x, y = k % 64, k // 64
        for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
          if tag(x + d[1], y + d[2]) == front then list[#list + 1] = k; break end
        end
      end
    end
    for _, k in ipairs(list) do G[k] = c end
  end
  local function wingdir(sg, e) e = rad(e); return sg * cos(e), -sin(e) end
  -- bat: tall pink-lined ears, lavender fur, golden pants, scalloped membrane wings, furled umbrella (quirk)
  local FU = {hi = H"#c9b2f0", base = H"#8a6fd0", shade = H"#5a459e", deep = H"#35295f"}
  local GOLD, GOLDS = H"#f5b82e", H"#d98322"
  local PINK = H"#f5809f"
  local UMB, UMBS, METAL = H"#d98322", H"#8f4a1f", H"#aaa9b8"
  local MEM, MEDGE = H"#5a459e", H"#35295f"
  local function inpoly(px, py, poly)
    local inside, j = false, #poly
    for i = 1, #poly do
      local xi, yi, xj, yj = poly[i][1], poly[i][2], poly[j][1], poly[j][2]
      if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
      j = i
    end
    return inside
  end
  -- wing key points for the viewer-left wing (mirror with mx for the right). {wrist, tip1, tip2, tip3}
  local WK = {
    rest = {{19, 40}, {16, 50}, {17, 58}, {21, 62}},
    [2] = {{13, 29}, {4, 30}, {5, 42}, {12, 53}},
    [1] = {{12, 36}, {3, 41}, {6, 51}, {14, 58}},
    [0] = {{15, 40}, {8, 48}, {11, 56}, {17, 61}},
    [-1] = {{18, 44}, {15, 54}, {17, 61}, {21, 63}},
  }
  local function batwing(sg, sx, sy, hipx, hipy, k, dark, dy)
    dy = dy or 0
    local function X(x) return sg < 0 and x or mx(x) end
    local w, t1, t2, t3 = k[1], k[2], k[3], k[4]
    local wr = {X(w[1]), w[2] + dy}
    local T = {{X(t1[1]), t1[2] + dy}, {X(t2[1]), t2[2] + dy}, {X(t3[1]), t3[2] + dy}}
    local poly = {{sx, sy}, wr, T[1], T[2], T[3], {hipx, hipy}}
    -- scallop bites between tips
    local bites = {}
    local edge = {T[1], T[2], T[3], {hipx, hipy}}
    for i = 1, 3 do
      local a, c = edge[i], edge[i + 1]
      local len = sqrt((a[1] - c[1]) ^ 2 + (a[2] - c[2]) ^ 2)
      bites[#bites + 1] = {(a[1] + c[1]) / 2, (a[2] + c[2]) / 2, len * 0.32}
    end
    local function bitten(x, y)
      for _, bt in ipairs(bites) do if (x - bt[1]) ^ 2 + (y - bt[2]) ^ 2 < bt[3] ^ 2 then return true end end
      return false
    end
    local function inside(x, y) return inpoly(x + 0.5, y + 0.5, poly) and not bitten(x, y) end
    local x0, x1, y0, y1 = 99, -99, 99, -99
    for _, p in ipairs(poly) do x0 = math.min(x0, p[1]); x1 = math.max(x1, p[1]); y0 = math.min(y0, p[2]); y1 = math.max(y1, p[2]) end
    for y = floor(y0) - 1, ceil(y1) + 1 do
      for x = floor(x0) - 1, ceil(x1) + 1 do
        if inside(x, y) then
          local e = not (inside(x + 1, y) and inside(x - 1, y) and inside(x, y + 1) and inside(x, y - 1))
          P(x, y, (e or dark) and MEDGE or MEM)
        end
      end
    end
    -- finger bones and the arm
    line(sx, sy, wr[1], wr[2], dark and MEDGE or FU.base)
    line(sx, sy + 1, wr[1], wr[2] + 1, dark and MEDGE or FU.shade)
    for i = 1, 3 do line(wr[1], wr[2], T[i][1], T[i][2], MEDGE) end
    P(wr[1], wr[2] - 1, FU.hi)    -- thumb claw
    return wr
  end
  local function umbrella(x0, y0, dx, dy, L)   -- hook handle at x0,y0, furled canopy along dx,dy
    cur = "umb"
    local n = sqrt(dx * dx + dy * dy); dx, dy = dx / n, dy / n
    -- hook (curls back over the top)
    local hx, hy = floor(-dy + 0.5), floor(dx + 0.5)
    P(x0, y0, METAL); P(x0 - floor(dx + 0.5), y0 - floor(dy + 0.5), METAL)
    P(x0 - floor(dx + 0.5) + hx, y0 - floor(dy + 0.5) + hy, METAL)
    P(x0 + hx * 2 - floor(dx + 0.5), y0 + hy * 2 - floor(dy + 0.5), METAL)
    P(x0 + hx * 2, y0 + hy * 2, METAL)
    line(x0, y0, floor(x0 + dx * 4 + 0.5), floor(y0 + dy * 4 + 0.5), METAL)
    local cx, cy = x0 + dx * 4, y0 + dy * 4
    limb(cx, cy, dx, dy, L, 2.4, function(x, y, nx, ny)
      local px, py = x - cx, y - cy
      local u = (px * dx + py * dy) / L
      local v = (-px * dy + py * dx)
      if u > 0.42 and u < 0.56 then return GOLD end   -- tie strap
      if math.abs(v) < 0.5 and u > 0.1 then return UMBS end
      return (nx * 0.55 + ny * 0.83 > 0.2) and UMBS or UMB
    end)
    P(floor(cx + dx * (L + 1) + 0.5), floor(cy + dy * (L + 1) + 0.5), METAL)
  end
  local function eye(x, y)
    for j = 0, 2 do P(x, y + j, INK); P(x + 1, y + j, INK) end
    P(x, y, FU.hi)
  end
  local function ear(bx0, bx1, by, tx, ty, inner)   -- triangle: base span bx0..bx1 at row by, tip tx,ty
    cur = "ear"
    for y = ty, by do
      local t = (y - ty) / (by - ty)
      local l = floor(tx + (bx0 - tx) * t + 0.5)
      local r = floor(tx + (bx1 - tx) * t + 0.5)
      for x = l, r do
        local c = (x == l) and FU.hi or ((x == r) and FU.shade or FU.base)
        if inner and t > 0.25 and x > l and x < r and (x > l + 1 or t > 0.6) then c = inner end
        P(x, y, c)
      end
    end
  end
  local function foot(cx, lift, r)
    local bot = 70 + lift
    cur = "leg"
    for y = 63 + b, bot - 1 do P(cx, y, r.shade); P(cx + 1, y, r.deep) end
    E(cx + 0.5, bot - 0.3, 2.2, 1.3, r)
    P(cx - 1, bot, r.deep); P(cx + 2, bot, r.deep)
  end
  local key = walk and WK[s] or WK.rest
  local function soft(nx, ny)   -- gentle fur shading: small lit cap, shade crescent lower right
    local d = nx * 0.55 + ny * 0.83
    if d > 0.88 then return FU.deep end
    if d > 0.5 then return FU.shade end
    if d < -0.78 then return FU.hi end
    return FU.base
  end
  local sw = walk and (s >= 1 and -1 or (s < 0 and 1 or 0)) or 0

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR = o.footR, o.footL
    if not front then ftVL, ftVR = o.footL, o.footR end
    local wrR
    if front then
      cur = "wing"; batwing(-1, 24, 42 + b, 25, 60 + b, key, false, b)
      cur = "wing"; wrR = batwing(1, mx(24), 42 + b, mx(25), 60 + b, key, false, b)
    end
    foot(26, ftVL, FU); foot(36, ftVR, FU)
    cur = "body"
    E(31.5, 51 + b, 9.5, 12, function(x, y, nx, ny) return soft(nx, ny) end)
    cur = "pants"
    E(31.5, 56 + b, 9.6, 8.2, function(x, y, nx, ny)
      if y - b <= 49 then return nil end
      if y - b == 50 then return GOLDS end
      return lit(nx, ny, {hi = GOLD, base = GOLD, shade = GOLDS, deep = UMBS})
    end)
    if front then
      cur = "tuft"
      stamp(28, 40 + b, {"hhhhhhh", ".hhhhh.", "..hhh..", "...h..."}, {h = FU.hi})
      P(31, 51 + b, GOLD); P(32, 51 + b, GOLD)
    else
      for y = 51, 63 do P(31, y + b, GOLDS) end
    end
    -- head
    cur = "face"
    ear(20, 27, 22 + hd, 20, top, front and PINK or FU.shade)
    ear(36, 43, 22 + hd, 43, top, front and PINK or FU.shade)
    cur = "face"
    E(31.5, 28 + hd, 11, 9.4, function(x, y, nx, ny) return soft(nx, ny) end)
    if front then
      E(31.5, 32 + hd, 5.2, 3.3, function(x, y, nx, ny) return ny > 0.6 and FU.base or FU.hi end)
      eye(26, 25 + hd); eye(36, 25 + hd)
      P(31, 30 + hd, PINK); P(32, 30 + hd, PINK)
      P(29, 33 + hd, INK); P(30, 34 + hd, INK); P(31, 34 + hd, INK); P(32, 34 + hd, INK); P(33, 34 + hd, INK); P(34, 33 + hd, INK)
      P(30, 35 + hd, FU.hi); P(33, 35 + hd, FU.hi)
      P(23, 31 + hd, PINK); P(24, 31 + hd, PINK); P(39, 31 + hd, PINK); P(40, 31 + hd, PINK)
      -- tuft of fur between the ears
      P(30, 19 + hd, FU.hi); P(31, 18 + hd, FU.hi); P(32, 19 + hd, FU.hi); P(33, 18 + hd, FU.hi)
      umbrella(wrR[1], wrR[2] + 1, 0, 1, 11)
    else
      for x = 25, 38 do if tag(x, 32 + hd) == "face" then P(x, 32 + hd, FU.shade) end end
      P(31, 18 + hd, FU.hi); P(32, 18 + hd, FU.hi)
      for x = 27, 36 do P(x, 35 + hd, FU.shade) end   -- nape fold
      -- folded wings over the back, umbrella over the right shoulder
      cur = "wing"; batwing(-1, 26, 43 + b, 28, 60 + b, walk and key or {{22, 42}, {20, 52}, {22, 59}, {26, 62}}, true, b)
      cur = "wing"; batwing(1, mx(26), 43 + b, mx(28), 60 + b, walk and key or {{22, 42}, {20, 52}, {22, 59}, {26, 62}}, true, b)
      cur = "hand"; E(35, 51 + b, 1.6, 1.6, FU)
      umbrella(36, 50 + b, 0.5, -1, 15)
    end
    sep("wing", "body", MEDGE); sep("wing", "pants", MEDGE)
    sep("body", "umb", FU.deep); sep("pants", "umb", UMBS); sep("face", "umb", FU.deep); sep("wing", "umb", MEDGE)
    sep("ear", "face", FU.shade)
  else
    -- side, facing right
    local dk = {{key[1][1] - 6, key[1][2] - 2}, {key[2][1] - 4, key[2][2]}, {key[3][1] - 4, key[3][2]}, {key[4][1] - 4, key[4][2]}}
    if walk then cur = "fwing"; batwing(-1, 28, 42 + b, 29, 59 + b, dk, true, b) end
    foot(29, o.footL, {hi = FU.shade, base = FU.shade, shade = FU.deep, deep = FU.deep})
    foot(34, o.footR, FU)
    cur = "body"
    E(31.5, 51 + b, 8.6, 12, function(x, y, nx, ny) return soft(nx, ny) end)
    cur = "pants"
    E(32.5, 56 + b, 8.8, 8.2, function(x, y, nx, ny)
      if y - b <= 49 then return nil end
      if y - b == 50 then return GOLDS end
      return lit(nx, ny, {hi = GOLD, base = GOLD, shade = GOLDS, deep = UMBS})
    end)
    cur = "tuft"
    stamp(35, 40 + b, {"hhhh", "hhh.", "hh.."}, {h = FU.hi})
    -- head
    ear(25, 29, 22 + hd, 25, top + 2, FU.shade)       -- far ear
    ear(29, 35, 22 + hd, 30, top, PINK)                -- near ear
    cur = "face"
    E(33.5, 28 + hd, 9.6, 9.2, function(x, y, nx, ny) return soft(nx, ny) end)
    E(40.5, 31 + hd, 4.5, 3.5, function(x, y, nx, ny) return ny > 0.6 and FU.base or FU.hi end)
    eye(38, 25 + hd)
    P(45, 30 + hd, PINK); P(44, 30 + hd, PINK)
    P(42, 33 + hd, INK); P(43, 33 + hd, INK); P(44, 32 + hd, INK); P(42, 34 + hd, FU.hi)
    P(36, 30 + hd, PINK); P(37, 30 + hd, PINK)
    -- near wing swept back
    local nk = walk and key or {{20, 41}, {18, 50}, {20, 58}, {24, 62}}
    cur = "wing"; batwing(-1, 29, 43 + b, 30, 60 + b, nk, false, b)
    -- arm forward with the umbrella like a cane
    cur = "arm"
    limb(36, 45 + b, 1, 0.45, 7, 1.6, FU)
    E(43, 48 + b, 1.6, 1.6, FU)
    umbrella(44 + sw, 47 + b, 0.75, 1, 12)
    sep("wing", "body", MEDGE); sep("wing", "pants", MEDGE); sep("fwing", "body", MEDGE)
    sep("body", "arm", FU.deep); sep("pants", "umb", UMBS); sep("body", "umb", FU.deep)
    sep("ear", "face", FU.shade)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
