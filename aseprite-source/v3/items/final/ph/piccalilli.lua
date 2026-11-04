-- piccalilli (Opus artist pass, single). A tall straight-sided clip-top jar packed with mustard-yellow piccalilli:
-- per-pixel cylinder light on the sauce (6 tones) with chunky veg pressed against the glass (knobbly cream
-- cauliflower florets, green gherkin and bean pieces with seed dots, red pepper flecks), each lit by the same
-- cylinder. Glass: 1px wall (pale lit rim, cool shade rim), long specular streak, domed glass lid with its own glint,
-- an orange rubber seal ring, and a steel bail wire (bright edge) over the lid down to a lever on the right.
-- A kraft tag on twine hangs from the wire on the left. Ground shadow.
-- quirk: the orange rubber seal's pull tab sticks out on the left like a little tongue.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "piccalilli"
local c = D.new(NAME)

local MUS   = { "#6a3a14", "#9a5c12", "#c98a14", "#e8b222", "#f8d240", "#fff08a" }
local GLASS = { "#3d4f7e", "#5c77a6", "#8db4cc", "#c6e6e4", "#ecfaf2" }
local CAUL  = { "#a08a5a", "#d0bc84", "#efe0b0", "#fff6d6" }
local GRN   = { "#24543a", "#3e7a40", "#6aa24a", "#a4cc66" }
local PEP   = { "#7a1e26", "#c4322e", "#f05a3a" }
local RUB   = { "#7a2a1a", "#c04a1c", "#ee7428", "#ffa052" }
local WIRE  = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local KRAFT = { "#6e4a30", "#9a6c44", "#c49464", "#e2bc88" }
local TW    = { "#6e4126", "#c99a52" }
local cx = 31.5
local gtok, mtok, wtok, rtok = D.tok("glass"), D.tok("sauce"), D.tok("wire"), D.tok("rubber")

c:groundShadow(31.5, 57, 14, 2)

-- jar body
local Y0, Y1 = 25, 56
local function hw(y)
  if y == 25 then return 9.6 elseif y == 26 then return 10.6 end
  if y == 56 then return 9.6 elseif y == 55 then return 10.6 end
  return 11.2
end
local body = D.rows(cx, Y0, Y1, hw)
local wall = body:edge()
local inside = body:copy():cut(wall)
local sauce = inside:copy()
sauce:each(function(x, y) if y < 29 then sauce.s[K(x, y)] = nil end end)
local head = inside:copy():cut(sauce)
local bx0, _, bx1 = body:bbox()
local n = D.vcyl(body, bx0, bx1, nil, Y1, 4)
local sidx, v = D.tone(c, sauce, n, MUS, { amb = 0.12, wrap = 0.35, tok = mtok })
-- sauce surface row + mustard grain specks
for x = bx0 + 1, bx1 - 1 do if sauce:has(x, 29) then c:put(x, 29, x < cx + 3 and MUS[6] or MUS[4], mtok) end end
sauce:each(function(x, y) local k = K(x, y)
  if y > 30 and X.hash(x, y, 7) > 0.93 then c:put(x, y, MUS[max(1, sidx[k] - 1)], mtok) end end)
D.tone(c, head, n, { GLASS[3], GLASS[4], GLASS[5] }, { cuts = { 0.4, 0.75 }, tok = gtok })

-- veg chunks pressed to the glass; tone shifts with the cylinder light
local function lit(x, y) return v[K(x, y)] or 0.5 end
local function floret(x0, y0, tok)
  local pat = { ".ab.", "abbc", "bbcd", ".ee." }
  for j, row in ipairs(pat) do for i = 1, #row do local ch = row:sub(i, i)
    if ch ~= "." then
      local x, y = x0 + i - 1, y0 + j - 1
      local d = (lit(x, y) < 0.45) and 1 or 0
      local map = { a = 4, b = 3, c = 2, d = 1, e = 2 }
      local idx = max(1, map[ch] - d)
      c:put(x, y, ch == "e" and GRN[2 - d] or CAUL[idx], tok)
    end end end
end
local function gherkin(x0, y0, w, tok)
  for i = 0, w - 1 do
    local x = x0 + i
    local d = (lit(x, y0) < 0.45) and 1 or 0
    c:put(x, y0, GRN[4 - d], tok) c:put(x, y0 + 1, GRN[3 - d], tok) c:put(x, y0 + 2, GRN[2 - d], tok)
  end
  c:put(x0 + 1, y0 + 1, CAUL[3], tok) c:put(x0 + w - 2, y0 + 1, CAUL[3], tok)       -- seed dots
end
local ctok = D.tok("veg")
floret(23, 31, ctok) floret(34, 34, ctok) floret(26, 41, ctok) floret(36, 46, ctok) floret(23, 49, ctok)
gherkin(30, 31, 4, ctok) gherkin(29, 37, 5, ctok) gherkin(37, 40, 3, ctok) gherkin(30, 47, 4, ctok) gherkin(22, 44, 3, ctok)
for _, p in ipairs{ { 33, 43 }, { 39, 52 }, { 27, 36 }, { 33, 52 } } do
  c:put(p[1], p[2], PEP[2], ctok) c:put(p[1] + 1, p[2], PEP[lit(p[1] + 1, p[2]) < 0.45 and 1 or 3], ctok) end

-- glass wall + heel + specular streak + cool reflected sliver
wall:each(function(x, y)
  local hex
  if x < cx - 3 then hex = (y < 50) and GLASS[4] or GLASS[3]
  elseif x > cx + 3 then hex = (y < 40) and GLASS[3] or GLASS[2]
  else hex = (y > 50) and GLASS[1] or GLASS[3] end
  c:put(x, y, hex, gtok)
end)
for x = bx0 + 2, bx1 - 2 do c:put(x, Y1 - 1, x < cx - 2 and GLASS[3] or GLASS[2], gtok) end
for y = 31, 52 do if y ~= 38 and y ~= 46 then c:put(23, y, GLASS[5], gtok) end end
for y = 33, 43 do c:put(22, y, GLASS[4], gtok) end
for y = 30, 33 do c:put(40, y, GLASS[4], gtok) end
for y = 34, 53 do c:put(bx1 - 1, y, "#a2785a", mtok) end
-- AO under the seal ring
for x = bx0, bx1 do if body:has(x, 25) then c:put(x, 25, GLASS[1], gtok) end end

-- rubber seal ring
local ring = c:rect(20, 23, 43, 24)
ring:each(function(x, y) c:put(x, y, RUB[y == 23 and (x < 36 and 4 or 3) or (x < 36 and 3 or 2)], rtok) end)
-- quirk: pull tab sticking out on the left
c:paint({ "ab..", "abbc", ".bcd", }, 16, 23, { a = RUB[4], b = RUB[3], c = RUB[2], d = RUB[1] })
c:put(16, 24, RUB[3], rtok) c:put(17, 25, RUB[2], rtok)

-- domed glass lid
local function lw(y)
  if y == 17 then return 6.2 elseif y == 18 then return 8.6 elseif y == 19 then return 9.6 end
  return 10.6
end
local lid = D.rows(cx, 17, 22, lw)
local lidn = X.pillow(lid, 3)
D.tone(c, lid, lidn, { GLASS[2], GLASS[3], GLASS[4], GLASS[5] }, { cuts = { 0.3, 0.55, 0.8 }, tok = gtok })
for x = 21, 42 do c:put(x, 22, x < 34 and GLASS[3] or GLASS[2], gtok) end
c:put(26, 18, D.CREAM, gtok) c:put(27, 18, D.CREAM, gtok)

-- bail wire: loop over the lid, down both sides to the hinges, lever on the right
local function wl(pts, lo)
  D.line(c, pts, nil, wtok, function(x, y) return lo and WIRE[2] or ((x + y) % 4 == 0 and WIRE[4] or WIRE[3]) end)
end
wl({ { 24, 15 }, { 28, 14 }, { 35, 14 }, { 39, 15 } })
wl({ { 24, 15 }, { 21, 18 }, { 20, 22 } })
wl({ { 39, 15 }, { 42, 18 }, { 43, 21 } }, true)
-- hinge lugs
c:put(19, 25, WIRE[3], wtok) c:put(19, 26, WIRE[2], wtok) c:put(44, 25, WIRE[2], wtok) c:put(44, 26, WIRE[1], wtok)
-- lever on the right
wl({ { 44, 22 }, { 45, 25 }, { 45, 31 } }, true)
c:put(45, 32, WIRE[1], wtok) c:put(44, 24, WIRE[3], wtok)

-- kraft tag on twine, hanging from the left wire
local ttok = D.tok("tag")
D.line(c, { { 20, 21 }, { 18, 26 }, { 17, 28 } }, nil, ttok, function(x, y) return TW[(y % 2) + 1] end)
local tag = c:poly({ { 15, 29 }, { 19, 29 }, { 20, 31 }, { 20, 38 }, { 14, 38 }, { 14, 31 } })
tag:each(function(x, y) c:put(x, y, KRAFT[(x >= 19 or y >= 37) and 2 or (x == 14 or y == 29) and 4 or 3], ttok) end)
c:put(17, 31, KRAFT[1], ttok)                                       -- punched hole
for x = 15, 18 do c:put(x, 33, KRAFT[2], ttok) end
for x = 15, 17 do c:put(x, 35, KRAFT[2], ttok) end

D.save(c, NAME)
