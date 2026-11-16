-- grasshopper (hopper) tables from specs/grasshopper.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "grasshopper", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 38}
S.ramps = {main = {"#9ad55c", "#78bf48", "#3f8a52", "#3a3e6e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#9ad55c", "#78bf48", "#3f8a52", "#3a3e6e", "#6e8cc8", "#4e62a0", "#e4bc62", "#b98a48", "#c08a4a", "#7a5240", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#78bf48",
  bshade = h"#3f8a52",
  bhi = h"#9ad55c",
  deep = h"#3a3e6e",
  head = h"#78bf48",
  hat = h"#e4bc62",
  hatshade = h"#b98a48",
  wing = h"#c08a4a",
  belly = h"#6e8cc8",
  acc = h"#6e8cc8",
  accs = h"#4e62a0",
  eye = h"#6e8cc8",
  q = h"#c08a4a",
  qshade = h"#7a5240",
  qhi = h"#c08a4a",
  ink = h"#3a3e6e", arm = h"#78bf48", fbase = h"#3f8a52", fshade = h"#3a3e6e"}
S.bw, S.top = 20, 8
S.quirk = {w = 4, h = 3, anchor = "chest", hex = "#c08a4a"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  -- ---------- tiny paint kit: parts, rims (contact lines), own outline, ink details ----------
  local G, ID, K = {}, {}, {}
  local cur, rims, SHADOW = 0, {}, 1
  local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
  local function part(rim) cur = cur + 1; if rim then rims[#rims + 1] = {cur, rim} end end
  local function P(x, y, c)
    x, y = floor(x + 0.5), floor(y + 0.5)
    if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c; ID[y * 64 + x] = cur end
  end
  local function at(x, y) return G[y * 64 + x] end
  -- R = {hl, hi, base, shade, deep}; light from the upper left
  local function lit(nx, ny, R)
    local s = nx * 0.6 + ny * 0.8
    if s < -0.72 and R[1] then return R[1] end
    if s < -0.28 then return R[2] end
    if s > 0.86 then return R[5] or R[4] end
    if s > 0.36 then return R[4] end
    return R[3]
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
  local function cap(x0, y0, x1, y1, r, R, r1)
    r1 = r1 or r
    local r0 = r
    r = max(r0, r1)
    local dx, dy = x1 - x0, y1 - y0
    local L2 = dx * dx + dy * dy
    for y = floor(min(y0, y1) - r - 1), floor(max(y0, y1) + r + 1) do
      for x = floor(min(x0, x1) - r - 1), floor(max(x0, x1) + r + 1) do
        local t = L2 > 0 and ((x - x0) * dx + (y - y0) * dy) / L2 or 0
        t = max(0, min(1, t))
        local ex, ey = x - (x0 + t * dx), y - (y0 + t * dy)
        local d = sqrt(ex * ex + ey * ey)
        local rr = r0 + (r1 - r0) * t
        if d <= rr then
          local r = rr
          local c = R
          if type(R) == "function" then c = R(x, y, ex / r, ey / r, t) elseif type(R) == "table" then c = lit(ex / r, ey / r, R) end
          P(x, y, c)
        end
      end
    end
  end
  local function line(pts, c, ink)
    for i = 1, #pts - 1 do
      local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
      local n = max(abs(x1 - x0), abs(y1 - y0), 1)
      for j = 0, n do
        local x, y = floor(x0 + (x1 - x0) * j / n + 0.5), floor(y0 + (y1 - y0) * j / n + 0.5)
        if ink then if not G[y * 64 + x] then K[y * 64 + x] = c end else P(x, y, c) end
      end
    end
  end
  local function finish()
    for _, rm in ipairs(rims) do
      local pid, col, set = rm[1], rm[2], {}
      for k, id in pairs(ID) do
        if id < pid and id ~= SHADOW then
          if ID[k + 1] == pid or ID[k - 1] == pid or ID[k + 64] == pid or ID[k - 64] == pid then set[#set + 1] = k end
        end
      end
      for _, k in ipairs(set) do G[k] = col end
    end
    for k, id in pairs(ID) do  -- ink contour where the figure stands in its shadow
      if id == SHADOW then
        for _, n in ipairs({k + 1, k - 1, k + 64, k - 64}) do if ID[n] and ID[n] ~= SHADOW then G[k] = INK; break end end
      end
    end
    for y = 0, 79 do for x = 0, 63 do
      local k = y * 64 + x
      if G[k] then img:putPixel(x, y, G[k])
      elseif G[k + 1] and x < 63 or G[k - 1] and x > 0 or G[k + 64] or G[k - 64] or K[k] then img:putPixel(x, y, INK) end
    end end
  end
  -- ---------- palette ----------
  local GHI, GBA, GSH, GDP = H"#9ad55c", H"#78bf48", H"#3f8a52", H"#3a3e6e"
  local BODY = {nil, GHI, GBA, GSH, GDP}
  local BODYD = {nil, GBA, GSH, GDP, GDP}
  local OHI, OBA, ODP = H"#6e8cc8", H"#4e62a0", H"#3a3e6e"
  local OV = {nil, OHI, OHI, OBA, ODP}
  local STRAW = {nil, H"#e4bc62", H"#e4bc62", H"#b98a48", H"#7a5240"}
  local SBA, SSH = H"#e4bc62", H"#b98a48"
  local TAN, BRN = H"#c08a4a", H"#7a5240"
  local L1, L2 = H"#aaa9b8", H"#74758c"
  -- ---------- pose ----------
  local b, hd, lift, arm = o.body, o.head, o.footL, o.armL
  -- hind legs: knee spread, knee drop (big = leg straightens), foot spread
  local PO = {{0, 0, 0}, {0, 0, 0}, {1, -2, 2}, {-3, 8, -2}, {-5, 13, -4}, {-2, 6, -1}, {3, -1, 3}, {1, 0, 1}}
  local kx, ky, fx = PO[frame][1], PO[frame][2], PO[frame][3]
  local tipw = ({0, 0, 1, -1, -2, -1, 1, 0})[frame]
  local sway = (frame == 5 or frame == 8) and 1 or ((frame == 7) and -1 or 0)
  local CX = 31.5
  local function X(s, d) return CX + s * d end

  part(); ell(32, 67.5, 13.5, 3, L2); ell(31, 67, 11, 2, L1)   -- shadow, id 1

  local function satchel(x, y)
    part(INK)
    for j = 0, 3 do for i = 0, 4 do
      local c = TAN
      if j == 0 or (j == 1 and i > 0 and i < 4) then c = BRN end   -- flap
      if j == 3 or i == 4 then c = (j == 3 and i == 0) and TAN or BRN end
      P(x + i, y + j, c)
    end end
    P(x + 2, y + 1, SBA)  -- buckle
    P(x, y + 2, SBA)
  end
  local function hat(cx, cy, crx, brx, bry)
    part()
    ell(cx, cy - 4, crx, 4.6, function(x, y, nx, ny)
      if y > cy - 1 then return end
      if y == floor(cy - 2) or y == floor(cy - 3) then return (y == floor(cy - 3)) and OHI or OBA end
      return lit(nx, ny, STRAW)
    end)
    ell(cx, cy, brx, bry, function(x, y, nx, ny)
      if ny > 0.45 then return SSH end
      if (x + 2 * y) % 5 == 0 then return SSH end
      return SBA
    end)
  end
  local function eye(cx, cy, flip)
    ell(cx, cy, 2.6, 3.6, function(x, y, nx, ny) return (ny > 0.4 or nx * flip > 0.5) and BRN or TAN end)
    local px, py = floor(cx + 0.5) - (flip > 0 and 1 or 0), floor(cy)
    for y = py - 1, py + 1 do P(px, y, INK); P(px + 1, y, INK) end
    P(px, py - 1, SBA)
  end
  local function leg(hx, hy, kxx, kyy, fxx, fyy, R, s)
    cap(kxx, kyy, fxx, fyy, 1.1, R == BODY and BODYD or {nil, GSH, GSH, GDP, GDP})
    for t = 0.2, 0.9, 0.17 do P(kxx + (fxx - kxx) * t + s, kyy + (fyy - kyy) * t, GDP) end -- spines
    ell(fxx + s * 1.2, 69.5 + (fyy - 68), 2.4, 1.2, function(x, y, nx, ny) return ny < 0 and GSH or GDP end)
    cap(hx, hy, kxx, kyy, 2.7, function(x, y, nx, ny, t)
      if abs(nx + ny) < 0.3 and floor(t * 9) % 2 == 0 and t < 0.85 then return R == BODY and GSH or GDP end
      return lit(nx, ny, R)
    end, 1.5)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    part()
    for s = -1, 1, 2 do                          -- middle legs
      cap(X(s, 4.5), 58 + b, X(s, 6.5 + fx * 0.5), 68 + lift, 1, BODYD)
      ell(X(s, 7.5 + fx * 0.5), 69.5 + lift, 1.8, 1.2, GSH)
    end
    if not front then
      -- long leaf wing-case down the back, under the hips
      part(GDP)
      ell(CX, 52 + b, 6.5, 14, function(x, y, nx, ny)
        if x == 31 or x == 32 then return (y % 3 == 0) and BRN or TAN end   -- midrib stripe
        if abs(abs(nx) - 0.5 + ny * 0.3) < 0.09 then return GSH end
        if nx > 0.4 then return GSH end
        return ny > 0.7 and GSH or GHI
      end)
    end
    -- torso
    part(GDP)
    ell(CX, 50 + b, 7, 11, function(x, y, nx, ny)
      local yy = y - b
      if front then
        if yy >= 52 then return lit(nx, ny, OV) end
        if abs(nx) < 0.62 and yy >= 46 then return lit(nx, ny, OV) end
        if yy % 3 == 0 and abs(nx) < 0.6 then return GSH end
        return lit(nx, ny, BODY)
      end
      if yy >= 54 then return lit(nx, ny, OV) end
      return lit(nx, ny, BODY)
    end)
    if not front then  -- the leaf tip shows over the overall seat
      part(GDP)
      ell(CX, 49 + b, 4.5, 11, function(x, y, nx, ny)
        if x == 31 or x == 32 then return (y % 3 == 0) and BRN or TAN end
        return nx > 0.3 and GSH or GHI
      end)
    end
    -- straps + satchel strap
    for s = -1, 1, 2 do
      for yy = 40, 46 do P(X(s, 3.5), yy + b, s < 0 and OHI or OBA) end
      if front then P(X(s, 3.5), 46 + b, SBA) end
    end
    if front then
      for x = 30, 33 do P(x, 49 + b, OBA) end; P(30, 50 + b, OBA); P(33, 50 + b, OBA); for x = 30, 33 do P(x, 51 + b, ODP) end
    end
    for yy = 41, 53 do
      local t = (yy - 41) / 12
      local x = front and floor(26 + t * 13 + 0.5) or floor(37 - t * 13 + 0.5)
      P(x, yy + b, TAN)
    end
    -- hind legs, knees up high
    part(GDP)
    for s = -1, 1, 2 do
      leg(X(s, 5.5), 57 + b, X(s, 12.5 + kx), 37 + b + ky, X(s, 12 + fx), 68 + lift, BODY, s)
    end
    -- arms
    part(GDP)
    for s = -1, 1, 2 do
      local ay = front and arm or -arm
      local ex, ey = X(s, 9), 47 + b - ay // 2
      local hx, hy = X(s, 9.5), 54 + b - ay
      cap(X(s, 6), 40 + b, ex, ey, 1.4, BODY)
      cap(ex, ey, hx, hy, 1.1, BODY)
      ell(hx, hy + 0.5, 1.5, 1.5, BODY)
    end
    satchel(front and 37 + sway or 22 + sway, 53 + b)
    -- head: long face narrowing to the mouth
    part(GDP)
    ell(CX, 28 + hd, 8.5, 10.5, function(x, y, nx, ny)
      if ny > 0.2 and abs(nx) > 1 - (ny - 0.2) * 0.55 then return end
      if front and abs(nx) < 0.12 and ny > -0.2 and ny < 0.5 then return GSH end   -- face ridge
      return lit(nx, ny, BODY)
    end)
    if front then
      eye(24, 25 + hd, -1); eye(39, 25 + hd, 1)
      P(31, 32 + hd, GHI); P(32, 32 + hd, GHI)
      P(30, 35 + hd, INK); P(31, 35 + hd, INK); P(32, 35 + hd, INK); P(33, 35 + hd, INK)
      P(29, 34 + hd, GSH); P(34, 34 + hd, GSH)
    else
      for s = -1, 1, 2 do ell(X(s, 7.5), 25 + hd, 1.5, 3, BRN) end
    end
    hat(CX, 19.5 + hd, 7, 13, 2.2)
    for s = -1, 1, 2 do
      line({{X(s, 2.5), 14 + hd}, {X(s, 3.5), 11 + hd}, {X(s, 5.5), 9 + hd}, {X(s, 7.5 + tipw), 7 + hd}}, INK, true)
    end
  else
    -- side, facing right
    part()
    cap(32, 58 + b, 34 + fx * 0.5, 68 + lift, 1, BODYD)              -- far middle leg
    leg(28, 57 + b, 23 - kx, 39 + b + ky, 29 + fx, 68 + lift, BODYD, -1)  -- far hind leg
    cap(35, 41 + b, 39 + arm, 52 + b, 1.1, BODYD)                     -- far arm
    -- wing-case leaf along the back
    part(GDP)
    ell(25, 52 + b, 4.5, 14, function(x, y, nx, ny)
      if abs(nx - ny * 0.1) < 0.18 then return (y % 3 == 0) and BRN or TAN end
      if nx < -0.6 or ny > 0.7 then return GSH end
      return GHI
    end)
    -- torso
    part(GDP)
    ell(31, 49 + b, 7.5, 12, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 53 then return lit(nx, ny, OV) end
      if nx > 0.1 and yy >= 46 then return lit(nx, ny, OV) end
      return lit(nx, ny, BODY)
    end)
    for yy = 40, 46 do P(35, yy + b, OBA) end
    for yy = 39, 52 do P(floor(27 + (yy - 39) * 0.75 + 0.5), yy + b, TAN) end
    satchel(36 + sway, 53 + b)                                       -- on the far hip, peeking out front
    -- near middle leg + hind leg
    part(GDP)
    cap(30, 58 + b, 32 + fx * 0.5, 68 + lift, 1.1, BODYD)
    ell(33.5 + fx * 0.5, 69.5 + lift, 2.2, 1.2, function(x, y, nx, ny) return ny < 0 and GSH or GDP end)
    part(GDP)
    leg(27, 58 + b, 18 - kx, 39 + b + ky, 24 + fx, 68 + lift, BODY, -1)
    -- near arm
    part(GDP)
    local hx, hy = 39 + arm, 53 + b
    cap(34, 41 + b, 36 + arm // 2, 47 + b, 1.4, BODY)
    cap(36 + arm // 2, 47 + b, hx, hy, 1.1, BODY)
    ell(hx + 0.5, hy + 0.5, 1.5, 1.5, BODY)
    -- head: long slanted face
    part(GDP)
    ell(33.5, 27 + hd, 7, 9.5, BODY)
    cap(35, 28 + hd, 39, 34 + hd, 4, BODY)
    eye(37, 24 + hd, 1)
    P(41, 31 + hd, GHI)
    P(40, 37 + hd, INK); P(41, 37 + hd, INK); P(42, 36 + hd, INK)
    P(38, 36 + hd, GSH)
    hat(32.5, 19.5 + hd, 6.5, 12.5, 1.7)
    line({{38, 14 + hd}, {41, 12 + hd}, {44, 10 + hd}, {47 + tipw, 8 + hd}, {50 + tipw, 7 + hd}}, INK, true)
  end
  finish()
end
return S
