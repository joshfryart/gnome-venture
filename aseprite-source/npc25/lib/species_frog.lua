-- frog (hopper) tables from specs/frog.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "frog", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 9, W = 36}
S.ramps = {main = {"#b6d861", "#6fae3e", "#3f7a4a", "#2f4a4c"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#b6d861", "#6fae3e", "#3f7a4a", "#2f4a4c", "#c2573c", "#8a3a46", "#5a2a3e", "#e6d38a", "#fff4d6", "#f5809f", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#6fae3e",
  bshade = h"#3f7a4a",
  bhi = h"#b6d861",
  deep = h"#2f4a4c",
  head = h"#6fae3e",
  hat = h"#c2573c",
  hatshade = h"#8a3a46",
  wing = h"#3f7a4a",
  belly = h"#e6d38a",
  acc = h"#c2573c",
  accs = h"#8a3a46",
  eye = h"#e6d38a",
  q = h"#b6d861",
  qshade = h"#3f7a4a",
  qhi = h"#f5809f",
  ink = h"#2f4a4c", arm = h"#6fae3e", fbase = h"#3f7a4a", fshade = h"#2f4a4c"}
S.bw, S.top = 20, 10
S.quirk = {w = 5, h = 2, anchor = "crown", hex = "#b6d861"}

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
  local CREAM, BELLY, PETAL = H"#fff4d6", H"#e6d38a", H"#f5809f"
  local SHI, SBA, SSH, SDP = H"#b6d861", H"#6fae3e", H"#3f7a4a", H"#2f4a4c"
  local SKIN = {nil, SHI, SBA, SSH, SDP}
  local SKINF = {nil, SBA, SSH, SDP, SDP}
  local OHI, OBA, ODP = H"#c2573c", H"#8a3a46", H"#5a2a3e"
  local OV = {nil, OHI, OHI, OBA, ODP}
  local L1, L2 = H"#aaa9b8", H"#74758c"
  -- ---------- pose ----------
  local b, hd, lift, arm = o.body, o.head, o.footL, o.armL
  -- leg extension per frame: -1 squashed, 0 sit, 3 fully stretched
  local ext = ({0, 0, -1, 2, 3, 1, -1, 0})[frame]
  local sway = (frame == 5 or frame == 8) and 1 or ((frame == 3 or frame == 7) and -1 or 0)
  local CX = 31.5
  local function X(s, d) return CX + s * d end

  part(); ell(32, 67.5, 13.5, 3, L2); ell(31, 67, 11, 2, L1)   -- shadow, id 1

  -- lily-pad hat with a pink water-lily bud; cx,cy = pad centre
  local function pad(cx, cy, rx, notchdir)
    part(INK)
    ell(cx, cy + 0.3, rx, 2.3, function(x, y, nx, ny)
      -- V notch cut out of the pad
      if false and ny > -0.4 and abs(nx - 0.2 * notchdir) < 0.1 + (ny + 0.4) * 0.18 then return end
      if ny > 0.5 then return SSH end
      if abs(nx) > 0.82 then return SBA end
      if ny < -0.2 and (x + floor(cx)) % 4 == 0 then return SBA end  -- veins
      return SHI
    end)
    -- bud: petals around a cream heart
    local fx = floor(cx) - 3 * (notchdir == 0 and 0 or notchdir) - 1
    local fy = floor(cy) - 3
    P(fx, fy + 1, PETAL); P(fx + 1, fy + 1, PETAL); P(fx + 2, fy + 1, PETAL)
    P(fx, fy, PETAL); P(fx + 1, fy, CREAM); P(fx + 2, fy, PETAL)
  end
  local function eyeball(cx, cy, r, back)
    ell(cx, cy, r, r, SKIN)
    if not back then
      ell(cx + 0.3, cy + 0.6, r - 1.3, r - 1.5, CREAM)
      local px, py = floor(cx), floor(cy)
      for y = py, py + 2 do P(px, y, INK); P(px + 1, y, INK) end
      P(px, py, CREAM)
    end
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    -- hind legs: haunches folded at the sides, webbed feet in front
    part(SDP)
    for s = -1, 1, 2 do
      local hx, hy = X(s, 10.5 + (ext < 0 and 1 or 0)), 60 + b + ext * 0.3
      local fxx = X(s, 10.5 + (ext < 0 and 1.5 or 0) - max(0, ext) * 0.7)
      local fyy = 69 + lift
      if ext > 0 then
        cap(hx, hy, fxx, fyy - 1, 2 - ext * 0.15, SKINF)
      end
      local hrx = 5.2 - max(0, ext) * 0.6
      ell(hx, hy, hrx, 5 - max(0, ext) * 0.4, SKIN)
      if front or ext > 0 then
        -- webbed foot: three toes
        local fw = ext > 1 and 2.5 or 4.3
        ell(fxx + s * 0.5, fyy + 0.4, fw, 1.6, function(x, y, nx, ny) return ny < -0.2 and SBA or SSH end)
        for t = -1, 1 do P(floor(fxx + s * 0.5 + t * (fw - 0.8) + 0.5), fyy - 1, SHI) end
      else
        ell(fxx, fyy + 0.4, 3.5, 1.6, function(x, y, nx, ny) return ny < 0 and SSH or SDP end)
      end
    end
    -- torso
    part(SDP)
    ell(CX, 51 + b, 10.5, 11.5, function(x, y, nx, ny)
      local yy = y - b
      if front then
        if yy >= 49 then return lit(nx, ny, OV) end                     -- overall pants
        if abs(nx) < 0.55 and yy >= 46 then return lit(nx, ny, OV) end   -- bib
        if abs(nx) < 0.7 then return (nx < -0.2 and yy < 46) and CREAM or BELLY end
        return lit(nx, ny, SKIN)
      end
      if yy >= 53 then return lit(nx, ny, OV) end
      local c = lit(nx, ny, SKIN)
      if (x == 27 and yy == 45) or (x == 36 and yy == 47) or (x == 30 and yy == 49) then c = SSH end
      return c
    end)
    if front then
      -- straps, buttons, bib pocket
      for s = -1, 1, 2 do
        for yy = 42, 46 do P(X(s, 5.5 - (46 - yy) * 0.25), yy + b, s < 0 and OHI or OBA) end
        P(X(s, 4.5), 47 + b, CREAM)
      end
      for x = 30, 33 do P(x, 50 + b, OBA) end
      P(30, 51 + b, OBA); P(33, 51 + b, OBA)
      for x = 30, 33 do P(x, 52 + b, ODP) end
    else
      -- crossed straps over the back
      for yy = 42, 53 do
        local t = (yy - 42) / 11
        P(floor(25 + t * 12 + 0.5), yy + b, OHI); P(floor(26 + t * 12 + 0.5), yy + b, OBA)
        P(floor(38 - t * 12 + 0.5), yy + b, OHI); P(floor(37 - t * 12 + 0.5), yy + b, OBA)
      end
      P(31, 47 + b, ODP); P(32, 47 + b, ODP)
    end
    -- arms with three-toed hands
    part(SDP)
    for s = -1, 1, 2 do
      local ay = front and arm or -arm
      local sx, sy = X(s, 9.5), 45 + b
      local hx, hy = X(s, 12.5 + max(0, ay) * 0.5), 54 + b - ay
      cap(sx, sy, hx, hy - 1, 2.2, SKIN)
      ell(hx, hy + 0.5, 2.3, 1.6, function(x, y, nx, ny) return ny > 0.3 and SSH or SBA end)
      if front then P(floor(hx + 0.5) - 1, floor(hy + 1.5), SDP); P(floor(hx + 0.5) + 1, floor(hy + 1.5), SDP) end
    end
    -- head
    part(SDP)
    ell(CX, 29 + hd, 13.5, 11.5, function(x, y, nx, ny)
      if front and ny > 0.62 and abs(nx) < 0.6 then return BELLY end   -- pale chin
      local c = lit(nx, ny, SKIN)
      if not front and ((x == 26 and y - hd == 25) or (x == 37 and y - hd == 28) or (x == 31 and y - hd == 22)) then c = SSH end
      return c
    end)
    for s = -1, 1, 2 do eyeball(X(s, 7.5), 20 + hd, 4.4, not front) end
    if front then
      for x = 21, 42 do
        local yy = 32 - ((x <= 22 or x >= 41) and 1 or 0)
        P(x, yy + hd, SDP)
      end
      P(21, 30 + hd, SDP); P(42, 30 + hd, SDP)
      P(30, 27 + hd, SDP); P(33, 27 + hd, SDP)                 -- nostrils
      P(22, 29 + hd, PETAL); P(23, 29 + hd, PETAL); P(40, 29 + hd, PETAL); P(41, 29 + hd, PETAL)
    end
    pad(CX + sway, 13.5 + hd, 8, front and 1 or -1)
  else
    -- side, facing right
    -- far leg + far arm
    part()
    ell(35 + (ext > 0 and -2 or 0), 69.4 + lift, 3.6, 1.5, SSH)
    cap(37, 46 + b, 40 + arm, 54 + b, 1.8, SKINF)
    -- torso
    part(SDP)
    ell(30.5, 50 + b, 11, 12, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 50 then return lit(nx, ny, OV) end
      if nx > 0.35 and yy >= 46 then return lit(nx, ny, OV) end
      if nx > 0.45 then return BELLY end
      local c = lit(nx, ny, SKIN)
      if (x == 26 and yy == 46) or (x == 29 and yy == 44) then c = SSH end
      return c
    end)
    for yy = 43, 49 do P(34 + floor((yy - 43) / 3), yy + b, OHI) end   -- strap
    -- near hind leg: haunch folded, shin under, long foot forward
    part(SDP)
    local hx, hy = 26, 59 + b + ext * 0.3
    local kx, ky = 20 + ext, 64 + b + ext
    local fxx, fyy = 29 - ext * 2, 69 + lift
    if ext <= 0 then
      cap(kx, ky, fxx - 3, fyy - 1, 2.2, SKIN)
      ell(fxx + 1, fyy + 0.4, 5.5 - ext, 1.6, function(x, y, nx, ny) return ny < -0.2 and SBA or SSH end)
      P(fxx + 5, fyy - 1, SHI)
    else
      cap(kx, ky, fxx - 2, fyy - 1, 2, SKIN)
      ell(fxx - 2, fyy, 3, 1.6, function(x, y, nx, ny) return ny < 0 and SBA or SSH end)
    end
    cap(hx, hy, kx, ky, 4.6 - max(0, ext) * 0.5, SKIN, 3)
    ell(hx + 1, hy - 0.5, 6 - max(0, ext) * 0.7, 5, SKIN)
    -- near arm
    part(SDP)
    local ax, ay = 37 + arm, 55 + b
    cap(33, 46 + b, ax, ay - 1, 2.2, SKIN)
    ell(ax + 1, ay + 0.5, 2.5, 1.5, function(x, y, nx, ny) return ny > 0.3 and SSH or SBA end)
    -- head: wide snout right, throat bulge, eye bulge on top
    part(SDP)
    ell(34, 29 + hd, 11.5, 11, function(x, y, nx, ny)
      if ny > 0.5 and nx > -0.3 then return BELLY end
      return lit(nx, ny, SKIN)
    end)
    ell(38, 37.5 + hd, 3.6, 2.4, function(x, y, nx, ny) return (ny < -0.2 and nx < 0.3) and CREAM or BELLY end)  -- throat bulge
    eyeball(36.5, 20 + hd, 4.2, false)
    for x = 35, 44 do P(x, 32 + hd - (x >= 44 and 1 or 0), SDP) end
    P(34, 31 + hd, SDP)
    P(44, 27 + hd, SDP)                                   -- nostril
    P(38, 30 + hd, PETAL); P(39, 30 + hd, PETAL)
    pad(31.5 + sway, 13.5 + hd, 7.5, -1)
  end
  finish()
end
return S
