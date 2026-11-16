-- cricket (hopper) tables from specs/cricket.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "cricket", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 40}
S.ramps = {main = {"#e8a868", "#b8682f", "#7d3f33", "#4a2633"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e8a868", "#b8682f", "#7d3f33", "#4a2633", "#5f9b45", "#3d6749", "#29404a", "#e3bb5e", "#a9824c", "#eadcb8", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#b8682f",
  bshade = h"#7d3f33",
  bhi = h"#e8a868",
  deep = h"#4a2633",
  head = h"#b8682f",
  hat = h"#e3bb5e",
  hatshade = h"#a9824c",
  wing = h"#5f9b45",
  belly = h"#e8a868",
  acc = h"#e8a868",
  accs = h"#e8a868",
  eye = h"#e8a868",
  q = h"#a9824c",
  qshade = h"#eadcb8",
  qhi = h"#a9824c",
  ink = h"#4a2633", arm = h"#b8682f", fbase = h"#7d3f33", fshade = h"#4a2633"}
S.bw, S.top = 20, 8
S.quirk = {w = 2, h = 6, anchor = "hand", hex = "#a9824c"}

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
  local CREAM = H"#eadcb8"
  local BODY = {CREAM, H"#e8a868", H"#b8682f", H"#7d3f33", H"#4a2633"}
  local BODYD = {nil, H"#b8682f", H"#7d3f33", H"#4a2633", H"#4a2633"}      -- far / shin
  local BODYF = {nil, H"#7d3f33", H"#7d3f33", H"#4a2633", H"#4a2633"}      -- farthest
  local WING = {nil, H"#5f9b45", H"#5f9b45", H"#3d6749", H"#29404a"}
  local WHI, WSH, WDP = H"#5f9b45", H"#3d6749", H"#29404a"
  local STRAW = {CREAM, H"#e3bb5e", H"#e3bb5e", H"#a9824c", H"#7d3f33"}
  local SHI, SBA, SSH = H"#eadcb8", H"#e3bb5e", H"#a9824c"
  local BHL, BHI, BBA, BSH, BDP = CREAM, H"#e8a868", H"#b8682f", H"#7d3f33", H"#4a2633"
  local BOW = H"#a9824c"
  local L1, L2 = H"#aaa9b8", H"#74758c"
  -- ---------- pose ----------
  local b, hd, lift, arm = o.body, o.head, o.footL, o.armL
  -- hind-leg pose per frame: knee spread, knee drop, foot spread (crouch, launch, apex, descend, land, settle)
  local PO = {{0, 0, 0}, {0, 0, 0}, {1, -2, 2}, {-3, 6, -2}, {-5, 10, -3}, {-2, 5, -1}, {2, -1, 3}, {1, 0, 1}}
  local kx, ky, fx = PO[frame][1], PO[frame][2], PO[frame][3]
  local tipw = ({0, 0, 1, -1, -1, 0, 1, 0})[frame]   -- antenna tips spring
  local sway = (frame == 5 or frame == 8) and 1 or 0
  local CX = 31.5
  local function X(s, d) return CX + s * d end

  part() ; ell(32, 67.5, 13.5, 3, L2); ell(31, 67, 11, 2, L1)   -- shadow, id 1

  local function bow(x, y, dir) -- diagonal fiddle bow through x,y; dir 1 = top leans right
    local pts = {}
    for i = -6, 6 do
      local px, py = x + dir * floor(i * 0.6 + 0.5), y - i
      P(px, py, (i == 6) and BDP or BOW); P(px + 1, py, (i == -6 or i == 6) and BDP or CREAM)
    end
  end
  local function hat(cx, cy, crx, brx, bry, profile)
    part()
    ell(cx, cy - 4.5, crx, 5, function(x, y, nx, ny)
      if y > cy - 1 then return end
      if y == floor(cy - 3) or y == floor(cy - 2) then return (y == floor(cy - 3) and nx < -0.2) and WHI or WSH end
      return lit(nx, ny, STRAW)
    end)
    ell(cx, cy, brx, bry, function(x, y, nx, ny)
      if ny < -0.35 then return (nx < -0.2 and SHI) or SBA end
      if ny > 0.45 then return (x % 3 == 0) and BSH or SSH end
      if (x + y) % 4 == 0 then return SSH end
      return SBA
    end)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    -- middle legs (short, under the body)
    part()
    for s = -1, 1, 2 do
      cap(X(s, 5.5), 56 + b, X(s, 7.5 + fx * 0.5), 68 + lift, 1.2, BODYD)
      ell(X(s, 8.5 + fx * 0.5), 69.5 + lift, 2, 1.2, BSH)
    end
    -- torso
    part(BDP)
    ell(CX, 49 + b, 8, 11.5, function(x, y, nx, ny)
      local yy = y - b
      if front and abs(nx) < 0.62 and yy >= 43 then
        if yy % 4 == 2 then return BBA end
        return (nx < -0.1 and yy < 52) and BHL or BHI
      end
      if not front and yy % 4 == 2 and abs(nx) < 0.8 then return BSH end
      return lit(nx, ny, BODY)
    end)
    -- wing-cases
    part(BDP)
    if front then
      for s = -1, 1, 2 do
        ell(X(s, 9), 49 + b, 3.6, 11, function(x, y, nx, ny)
          if abs(nx) < 0.25 and ny > -0.7 then return WSH end   -- vein
          if s > 0 then return ny > 0.5 and WDP or (nx > 0.3 and WSH or WHI) end
          return ny > 0.6 and WSH or WHI
        end)
      end
    else
      ell(CX, 50 + b, 10.5, 12.5, function(x, y, nx, ny)
        if x == 31 then return WDP end
        if x == 32 then return WSH end
        local vx = abs(nx) - 0.45 - ny * 0.1
        if abs(vx) < 0.07 then return WSH end
        if abs(nx) > 0.8 and ny > -0.4 then return WSH end
        if ny > 0.75 then return WDP end
        if nx > 0.55 and ny > 0.2 then return WSH end
        return WHI
      end)
      P(26, 43 + b, CREAM); P(27, 43 + b, CREAM)
      -- pronotum saddle
      ell(CX, 38 + b, 7.5, 3, function(x, y, nx, ny) return lit(nx, ny, BODY) end)
    end
    -- hind legs: thigh up to the knee, shin down to the foot
    part(BDP)
    for s = -1, 1, 2 do
      local hx, hy = X(s, 8.5), 58 + b
      local kxx, kyy = X(s, 15.5 + kx), 43 + b + ky
      local fxx, fyy = X(s, 14 + fx), 68 + lift
      cap(kxx, kyy, fxx, fyy, 1.3, BODYD)
      for t = 0.25, 0.85, 0.2 do P(kxx + (fxx - kxx) * t + s * 2, kyy + (fyy - kyy) * t, BSH) end -- spurs
      ell(fxx + s * 1, 69.5 + lift, 2.6, 1.3, function(x, y, nx, ny) return ny < 0 and BBA or BSH end)
      cap(hx, hy, kxx, kyy, 2.6, function(x, y, nx, ny, t)
        if abs(nx + ny) < 0.35 and (floor(t * 8) % 2 == 0) and t < 0.85 then return BSH end -- chevron stripe
        return lit(nx, ny, BODY)
      end, 1.6)
    end
    -- front arms + fiddle bow
    part(BDP)
    local hands = {}
    for s = -1, 1, 2 do
      local ay = front and arm or -arm
      local sx, sy = X(s, 7.5), 40 + b
      local ex, ey = X(s, 11.5), 45 + b - ay // 2
      local hx, hy = X(s, 10.5), 51 + b - ay
      cap(sx, sy, ex, ey, 1.6, BODY)
      cap(ex, ey, hx, hy, 1.3, BODY)
      ell(hx, hy + 0.5, 1.6, 1.6, BODY)
      hands[s] = {hx, hy}
    end
    part(INK)
    if front then bow(floor(hands[1][1]) + sway, floor(hands[1][2]), -1)
    else bow(floor(hands[-1][1]) - 1 + sway, floor(hands[-1][2]), 1) end
    -- head
    part(BDP)
    ell(CX, 28 + hd, 10.5, 9.2, BODY)
    if front then
      for s = -1, 1, 2 do
        local ex = s < 0 and 26 or 37
        ell(ex + 0.5, 28 + hd, 3.2, 3.4, function(x, y, nx, ny) return (ny < -0.6 and BSH) or BDP end)
        for y = 27, 29 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 27 + hd, CREAM)
      end
      P(31, 31 + hd, BHL); P(32, 31 + hd, BHI); P(31, 32 + hd, BSH); P(32, 32 + hd, BSH)   -- button nose
      for x = 30, 33 do P(x, 34 + hd, INK) end
      P(29, 33 + hd, INK); P(34, 33 + hd, INK)
      P(30, 35 + hd, BSH); P(33, 35 + hd, BSH)
    else
      for y = 33, 36 do P(31, y + hd, BSH) end
    end
    hat(CX, 20.5 + hd, 7.5, 15, 2.6)
    -- antennae: 1 px ink, tips at the head top row
    local t = 7 + hd
    for s = -1, 1, 2 do
      local base = front and 3.5 or 2.5
      line({{X(s, base), 15 + hd}, {X(s, base + 2), 12 + hd}, {X(s, base + 5), 9 + hd},
            {X(s, base + 8 + tipw), 8 + hd}, {X(s, base + 11 + tipw), t}}, INK, true)
    end
  else
    -- side, facing right
    local sb = sway
    -- far legs
    part()
    cap(33, 57 + b, 36 + fx * 0.5, 68 + lift, 1.1, BODYF)
    ell(37.5 + fx * 0.5, 69.5 + lift, 2.2, 1.2, BDP)
    cap(26, 55 + b, 23 - kx, 44 + b + ky, 2.2, BODYF)
    cap(23 - kx, 44 + b + ky, 28 + fx, 68 + lift, 1.1, BODYF)
    ell(30 + fx, 69.5 + lift, 2.4, 1.2, BDP)
    -- far arm
    cap(36, 41 + b, 40 + arm, 49 + b, 1.2, BODYF)
    -- torso
    part(BDP)
    ell(31, 49 + b, 7.5, 11.5, function(x, y, nx, ny)
      local yy = y - b
      if nx > 0.25 and yy >= 43 then
        if yy % 4 == 2 then return BBA end
        return yy < 50 and BHL or BHI
      end
      return lit(nx, ny, BODY)
    end)
    -- wing-case folded on the back
    part(WDP)
    ell(26.5, 49 + b, 5, 13, function(x, y, nx, ny)
      if x > 29 + floor((y - b - 38) / 6) then return end
      if abs(nx + 0.1) < 0.12 and ny > -0.6 then return WSH end
      if ny > 0.7 or nx < -0.75 then return WDP end
      if nx > 0.5 then return WSH end
      return WHI
    end)
    P(24, 41 + b, CREAM)
    -- near middle leg
    part(BDP)
    cap(31, 58 + b, 33 + fx * 0.5, 68 + lift, 1.2, BODYD)
    ell(34.5 + fx * 0.5, 69.5 + lift, 2.4, 1.2, function(x, y, nx, ny) return ny < 0 and BBA or BSH end)
    -- near hind leg: knee up and back, toe forward
    part(BDP)
    local kxx, kyy = 19 - kx, 41 + b + ky
    local fxx, fyy = 26 + fx, 68 + lift
    cap(kxx, kyy, fxx, fyy, 1.3, BODYD)
    for tt = 0.3, 0.9, 0.2 do P(kxx + (fxx - kxx) * tt - 2, kyy + (fyy - kyy) * tt, BSH) end
    ell(fxx + 2, 69.5 + lift, 3, 1.3, function(x, y, nx, ny) return ny < 0 and BBA or BSH end)
    cap(30, 57 + b, kxx, kyy, 3.8, function(x, y, nx, ny, t)
      if abs(nx + ny) < 0.35 and floor(t * 8) % 2 == 0 and t < 0.85 then return BSH end
      return lit(nx, ny, BODY)
    end, 1.7)
    -- near arm + bow hanging off it
    part(BDP)
    local hx, hy = 39 + arm, 51 + b
    cap(34, 41 + b, 37 + arm // 2, 46 + b, 1.6, BODY)
    cap(37 + arm // 2, 46 + b, hx, hy, 1.3, BODY)
    ell(hx + 0.5, hy + 0.5, 1.6, 1.6, BODY)
    part(INK)
    bow(hx + 2 + sb, hy + 1, 1)
    -- head, face forward on the right
    part(BDP)
    ell(34.5, 28 + hd, 9, 9, BODY)
    ell(39.5, 31 + hd, 5.5, 5, BODY)
    ell(39.5, 27 + hd, 2.8, 3.4, function(x, y, nx, ny) return (ny < -0.6 and BSH) or BDP end)
    for y = 26, 28 do P(39, y + hd, INK); P(40, y + hd, INK) end
    P(39, 26 + hd, CREAM)
    P(44, 31 + hd, BHL); P(45, 31 + hd, BHI); P(45, 32 + hd, BSH)
    for x = 41, 44 do P(x, 34 + hd, INK) end
    P(42, 35 + hd, BSH)
    hat(33.5, 20.5 + hd, 6.5, 13.5, 1.8)
    line({{41, 15 + hd}, {44, 12 + hd}, {46, 10 + hd}, {48 + tipw, 8 + hd}, {51 + tipw, 7 + hd}}, INK, true)
    line({{38, 15 + hd}, {39, 12 + hd}, {41, 9 + hd}, {43 + tipw, 7 + hd}}, INK, true)
  end
  finish()
end
return S
