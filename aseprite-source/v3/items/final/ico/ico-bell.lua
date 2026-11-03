-- ico-bell (Opus single pass). Front view brass hand bell: thick hanging loop and yoke on top, rounded shoulder,
-- slim concave waist flaring to a bevelled lip band, dark mouth with the clapper ball hanging below.
-- Material: per-pixel surface-of-revolution light (6-tone brass, normal tilts up where the skirt flares),
-- bright vertical specular streak + glint, warm-violet reflected light on the right edge, bevel lit lip, AO
-- under the shoulder bead, the yoke and inside the mouth.
-- quirk: a little heart engraved on the waist.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, abs, max, min, sqrt, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.sqrt, math.pi
local c = A.new("ico-bell")
local BRASS = { "#5a2a22", "#8f4a1f", "#c47a26", "#e8a634", "#f8cf5a", "#fff0a8" }
local IRON  = { "#1e1626", "#30243a", "#46374e", "#5e4c64", "#82708a", "#a898b0" }
local BOUNCE, SPEC = "#b07a6a", "#fff8dc"
local CX = 31.5

-- profile: half width per row of the bell body
local Y0, Y1 = 15, 45
local function hw(y)
  if y < 20 then local t = (20 - y) / 5.6 return 9.6 * sqrt(max(0, 1 - t * t)) end
  local t = (y - 20) / (Y1 - 20)
  return 9.6 + 1.4 * t + 7.2 * t ^ 3.2
end
local function dhw(y) return (hw(y + 0.5) - hw(y - 0.5)) end

-- clapper first (body paints over its top): iron ball on a short shank
local clm = c:ellipse(CX, 51, 3, 3)
local cln = X.sphere(CX - .4, 50.6, 3.2, clm)
local clidx = A.shade(clm, cln, IRON, { amb = 0.1 })
c:px(30, 50, IRON[6]) c:px(29, 50, IRON[5])

-- body
local bm, bn = HP.mask(), {}
for y = Y0, Y1 do
  local w = hw(y)
  for x = floor(CX - w), floor(CX + w) + 1 do
    if abs(x - CX) <= w then
      bm:set(x, y)
      local s = max(-0.97, min(0.97, (x - CX) / (w + 0.5)))
      local nx, nz = s, sqrt(1 - s * s)
      local ny = -dhw(y) * 0.9
      if y < 20 then ny = -(20 - y) / 5.6 * 1.2 end
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      bn[K(x, y)] = { nx / l, ny / l, nz / l }
    end
  end
end
local bidx = A.shade(bm, bn, BRASS, { amb = 0.04, wrap = 0.05, cuts = { 0.3, 0.48, 0.64, 0.8, 0.93 } })
-- reflected warm-violet light on the right edge of the body
bm:edge():each(function(x, y) if x > CX + 2 and y > 20 and y < 43 then c:px(x, y, BOUNCE) end end)
-- specular streak down the lit side, following the profile
for y = 18, 42 do
  local x = floor(CX - hw(y) * 0.52 + .5)
  if y % 7 ~= 3 then A.set(bidx, BRASS, x, y, 6) end
  if y > 22 and y < 40 then A.set(bidx, BRASS, x - 1, y, 5) end
end
c:px(floor(CX - hw(24) * 0.52 + .5), 24, SPEC)
-- shoulder bead: a raised ring at y 20/21 (lit lip above a dark groove)
for x = floor(CX - hw(21)), floor(CX + hw(21)) + 1 do
  if bm:has(x, 21) then A.sh(bidx, BRASS, x, 21, -2) end
  if bm:has(x, 20) then A.sh(bidx, BRASS, x, 20, 1) end
end

-- lip band: bevelled ring, wider than the skirt
local lw = hw(Y1) + 1
local lm = HP.mask()
for y = 44, 48 do
  local t = (y - 46) / 2.6
  local w = lw * sqrt(max(0, 1 - t * t * 0.18))
  for x = floor(CX - w), floor(CX + w) + 1 do if abs(x - CX) <= w then lm:set(x, y) end end
end
local ln = {}
lm:each(function(x, y)
  local s = max(-0.97, min(0.97, (x - CX) / (lw + 0.5)))
  local ny = (y - 46) / 2.2
  local nz = sqrt(max(0.05, 1 - s * s - ny * ny * 0.6))
  local l = sqrt(s * s + ny * ny + nz * nz)
  ln[K(x, y)] = { s / l, ny / l, nz / l } end)
local lidx = A.shade(lm, ln, BRASS, { amb = 0.04, wrap = 0.05, cuts = { 0.3, 0.48, 0.64, 0.8, 0.93 } })
for x = 0, 63 do if lm:has(x, 48) then A.sh(lidx, BRASS, x, 48, -1) end end
-- deep groove where the skirt meets the lip
for x = floor(CX - hw(43)), floor(CX + hw(43)) + 1 do if bm:has(x, 43) then A.sh(bidx, BRASS, x, 43, -2) end end
for x = floor(CX - lw) + 2, floor(CX) - 3 do if lm:has(x, 45) then A.set(lidx, BRASS, x, 45, 6) end end
-- mouth: dark crescent under the lip, clapper shank
local mm = HP.mask()
for x = floor(CX - lw) + 3, floor(CX + lw) - 2 do
  local t = (x - CX) / (lw - 2.5)
  if abs(t) <= 1 then local d = floor(1.6 * sqrt(1 - t * t) + .5) for y = 49, 48 + d do mm:set(x, y) end end
end
mm:cut(clm)
mm:each(function(x, y) c:px(x, y, (y == 49 and x < CX) and BRASS[2] or BRASS[1]) end)
c:px(31, 48, IRON[2]) c:px(32, 48, IRON[2])
A.ao(clidx, IRON, clm, mm, 1, -1)

-- yoke + loop on top
local ym = c:rect(28, 11, 35, 14)
local yn = {}
ym:each(function(x, y) local s = max(-.95, min(.95, (x - CX) / 4.2)) yn[K(x, y)] = { s, y == 11 and -0.6 or 0, sqrt(1 - s * s) } end)
local yidx = A.shade(ym, yn, BRASS, { amb = 0.04, wrap = 0.1 })
for x = 28, 35 do A.sh(yidx, BRASS, x, 14, -1) end
local lpm = c:ellipse(CX, 7, 4.4, 4.2):cut(c:ellipse(CX, 7, 1.4, 1.3))
lpm:cut(c:rect(0, 11, 63, 63))
local lpn = {}
lpm:each(function(x, y)
  local dx, dy = x - CX, y - 7
  local r = sqrt(dx * dx + dy * dy)
  local tube = (r - 2.9) / 1.6
  local ox, oy = dx / max(r, 0.1), dy / max(r, 0.1)
  local nz = sqrt(max(0.05, 1 - tube * tube))
  local nx, ny = ox * tube, oy * tube
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  lpn[K(x, y)] = { nx / l, ny / l, nz / l } end)
local lpidx = A.shade(lpm, lpn, BRASS, { amb = 0.04, wrap = 0.1 })
A.ao(yidx, BRASS, ym, lpm, 1, -1)
-- body darkens under the yoke
for x = 27, 36 do if bm:has(x, 15) then A.sh(bidx, BRASS, x, 15, -1) end end

-- quirk: engraved heart on the waist (groove dark, lower-right lip lit)
local heart = { "0110110", "1111111", "1111111", "0111110", "0011100", "0001000" }
local hx, hy = 30, 29
for r, row in ipairs(heart) do for i = 1, #row do if row:sub(i, i) == "1" then
  local x, y = hx + i - 1, hy + r - 1
  local edge = (i == #row or row:sub(i + 1, i + 1) ~= "1") or (r == #heart or heart[r + 1]:sub(i, i) ~= "1")
  local top = (r == 1 or heart[r - 1]:sub(i, i) ~= "1") or (i == 1 or row:sub(i - 1, i - 1) ~= "1")
  if top then A.sh(bidx, BRASS, x, y, -2) elseif edge then A.sh(bidx, BRASS, x, y, 1) else A.sh(bidx, BRASS, x, y, -1) end
end end end

A.save("ico-bell")
