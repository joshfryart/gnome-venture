-- fine-fly-rod (Opus single pass, aB31_3). A slim split-cane fly rod on the diagonal (butt lower-left, tip upper-right):
-- shaped cork grip (6-tone, pitted speckle, ring joints), brass reel seat + butt cap, a small brass fly reel hanging
-- below the seat (rim bevel, dark spool with line wound on, crank knob), amber varnished blank tapering 2 px to 1 px
-- with red silk guide wraps (twisted, lit/shade pixels) and tiny wire guides. The fly line runs off the tip in a loose
-- curve down to the fly.  quirk: the fly is tied as a tiny bumblebee (striped body, glassy wings).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("fine-fly-rod")
local CORK  = { "#5a3a26", "#82583a", "#a87a4e", "#c89a64", "#e2bc84", "#f4dcaa" }
local CANE  = { "#3e2418", "#64381e", "#8e5426", "#b87430", "#dc9a48", "#f6c878" }
local BRASS = { "#4e3418", "#7e5420", "#b07c2a", "#d8a43a", "#f0cc62", "#fff0b0" }
local SILK  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local WIRE  = { "#545b7c", "#a3abc2" }
local LINE  = { "#6f9a34", "#c4e07a" }
local GUN   = { "#24233a", "#38384f", "#525470", "#737693", "#9c9fb8", "#cfd2e0" }

-- rod axis: straight line butt -> tip
local BX, BY, TX, TY = 13, 54, 53, 11
local L = sqrt((TX - BX)^2 + (TY - BY)^2)
local ux, uy = (TX - BX) / L, (TY - BY) / L
local px, py = -uy, ux                          -- perpendicular, lower-right side
if px + py < 0 then px, py = -px, -py end
local function at(t, s) return BX + ux * L * t + px * s, BY + uy * L * t + py * s end
-- section half widths along t
local function hw(t)
  if t < 0.035 then return 1.9 end                         -- butt cap
  if t < 0.12 then return 1.7 end                          -- reel seat
  if t < 0.32 then local q = (t - 0.12) / 0.2 return 2.3 + 0.55 * math.sin(math.pi * q ^ 0.8) end  -- cord grip (cigar)
  if t < 0.34 then return 1.4 end                          -- winding check
  return max(0.45, 1.15 - (t - 0.34) * 0.95)               -- blank taper
end
local rm, rn, RT, RS = X.cyl(BX, BY, TX, TY, hw)
-- section masks
local function sect(t0, t1) local m = HP.mask() rm:each(function(x, y) local t = RT[K(x, y)] if t >= t0 and t < t1 then m:set(x, y) end end) return m end
local cap, seat, grip, check, blank = sect(-1, 0.035), sect(0.035, 0.12), sect(0.12, 0.32), sect(0.32, 0.34), sect(0.34, 2)

-- reel first (sits below the seat; the rod is drawn over its foot)
local RX, RY = at(0.075, 6.2)
local reel = HP.ellipse(RX, RY, 5, 5)
local reelN = X.sphere(RX, RY, 5, reel)
for k, n in pairs(reelN) do reelN[k] = { A.norm(n[1] * 0.7, n[2] * 0.7, n[3] + 0.4) } end
local rtok = A.tok("reel")
local ridx = A.tone(c, reel, reelN, GUN, { tok = rtok, amb = 0.08, wrap = 0.3 })
-- brass rim ring on the face
reel:each(function(x, y) local d = sqrt((x - RX)^2 + (y - RY)^2) if d > 3.6 and d < 4.6 then
  c:put(x, y, (x + y < RX + RY) and BRASS[5] or BRASS[3], rtok) end end)
-- spool: dark recessed disc with wound line, rim bevel stays brass
local spool = HP.ellipse(RX, RY, 3, 3)
spool:each(function(x, y) local d = sqrt((x - RX)^2 + (y - RY)^2)
  local col = GUN[1]
  if d > 1.6 then col = ((x + y) % 2 == 0) and LINE[1] or "#4e7430" end
  if d > 1.6 and x + y < RX + RY - 1 then col = ((x + y) % 2 == 0) and LINE[2] or LINE[1] end
  c:put(x, y, col, rtok) end)
c:put(floor(RX), floor(RY), BRASS[3], rtok) -- arbor
c:put(floor(RX) - 1, floor(RY) - 1, BRASS[2], rtok)
-- crank knob on the lower right
local kx, ky = floor(RX + 4.5), floor(RY + 3.5)
c:put(kx, ky, BRASS[4], rtok) c:put(kx + 1, ky, BRASS[3], rtok) c:put(kx, ky + 1, BRASS[2], rtok) c:put(kx + 1, ky + 1, BRASS[1], rtok)
-- reel foot joining the seat (ambient dark)
local fx, fy = at(0.075, 2.4)
c:put(floor(fx + .5), floor(fy + .5), BRASS[2], rtok)

-- rod sections
local function sec(m, ramp, name, o)
  local tok = A.tok(name)
  local idx = A.tone(c, m, rn, ramp, { tok = tok, amb = (o and o.amb) or 0.1, wrap = 0.35, cuts = (o and o.cuts) or A.CUTS, bias = o and o.bias })
  return idx, tok
end
local gb = {}
X.ao(gb, grip, seat, 1, -1) X.ao(gb, grip, check, 1, -1)
local gidx, gtok = sec(grip, CORK, "cork", { bias = gb })
-- cork: ring joints every ~3 px along t plus pitted speckle
local GL = 0.2 * L
grip:each(function(x, y) local k = K(x, y) local t = RT[k]
  local q = (t - 0.12) * L
  local i = gidx[k] or 3
  if (q % 3.1) < 0.7 and q > 1 and q < GL - 1 then c:put(x, y, CORK[max(1, i - 1)], gtok)
  elseif X.hash(x, y, 7) < 0.16 then c:put(x, y, CORK[max(1, i - 2)], gtok)
  elseif X.hash(x, y, 9) < 0.08 and i < 6 then c:put(x, y, CORK[i + 1], gtok) end
end)
local sidx, stok = sec(seat, BRASS, "seat", { amb = 0.05 })
-- seat: two dark rings (sliding bands)
seat:each(function(x, y) local q = (RT[K(x, y)] - 0.035) * L if q > 0.5 and q < 1.5 or q > 4.7 and q < 5.7 then c:put(x, y, BRASS[2], stok) end end)
sec(cap, BRASS, "cap")
sec(check, SILK, "check", { cuts = { 0.3, 0.55, 0.8 } })
local bidx, btok = sec(blank, CANE, "blank", { amb = 0.12 })
-- split-cane node marks: tiny dark ticks
blank:each(function(x, y) local q = (RT[K(x, y)] - 0.34) * L
  if (q % 7.5) > 3 and (q % 7.5) < 3.8 and RS[K(x, y)] > 0 then c:put(x, y, CANE[2], btok) end end)
-- silk guide wraps: 2-px bands of red, twist = alternating lit/shade
local wraps = { 0.37, 0.5, 0.63, 0.76, 0.88, 0.985 }
for wi, wt in ipairs(wraps) do
  rm:each(function(x, y) local k = K(x, y) local t = RT[k]
    if abs((t - wt) * L) < 1.0 then
      local s = RS[k]
      local col = s < -0.2 and SILK[4] or (s < 0.3 and SILK[3] or SILK[2])
      if ((x + y) % 2 == 1) and s > -0.2 then col = SILK[1] end
      c:put(x, y, col, btok)
    end end)
  -- wire guide loop standing off the lower side (not on the tip-top)
  if wi < #wraps then
    local gx, gy = at(wt, 2.2)
    c:put(floor(gx + .5), floor(gy + .5), WIRE[2], btok)
    local gx2, gy2 = at(wt + 0.012, 2.8)
    c:put(floor(gx2 + .5), floor(gy2 + .5), WIRE[1], btok)
  end
end

-- fly line: off the tip, loose curve down to the fly
local fx2, fy2 = 49, 41
A.curve(c, { { TX + 1, TY }, { TX + 6, TY + 8 }, { TX + 4, TY + 22 }, { fx2 + 1, fy2 - 3 } }, function(t) return t < 0.5 and LINE[2] or LINE[1] end)
-- quirk: bumblebee fly (hand placed), head toward the line
local bee = {
  ".wW..",
  "wWWwk",
  ".gkgk",
  "gkGgk",
  ".kgkh",
  "..kd.",
}
local BC = { w = "#d6f0f6", W = "#a6d4e6", g = "#f5b82e", G = "#ffe38a", k = "#2b1c26", h = "#d98322", d = "#8f4a1f" }
for j, row in ipairs(bee) do for i = 1, #row do local ch = row:sub(i, i)
  if BC[ch] then c:put(fx2 - 3 + i, fy2 - 3 + j, BC[ch]) end end end
A.save(c, "fine-fly-rod")
