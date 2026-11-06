-- pineapple-chutney (final pass, Opus). A slim glass jar of golden pineapple chutney with a red cloth cover tied on
-- with twisted twine. Contents: per-pixel cylinder light on a 6-tone orange-gold ramp, pale pineapple cubes (lit
-- top, shaded lower-right), dark raisins and red chili flecks; a strip of empty glass headspace. Glass: pale lit
-- left wall, cool shaded right wall, a long specular streak and a short one, a thicker green-tinted base. Cloth:
-- diagonal weave, fold lines into the gathers, pinked hem; twine with a twist pattern and two loose ends. A small
-- cream label with a tiny pineapple. Ground shadow.
-- quirk: a drip of chutney has run down the glass from under the cloth and hangs as a fat drop.
-- History: Sonnet draft replaced.
local NAME = "pineapple-chutney"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local CH   = { "#6a2a1a", "#a4461e", "#d0702a", "#ec9a34", "#f8c250", "#ffe48a" }
local CUBE = { "#d89a2e", "#f4cc56", "#fff0a0" }
local GL   = { "#3a6a7a", "#5a9aa8", "#a6dcd8", "#e0f6f0" }
local CL   = { "#5a1a2e", "#8e2836", "#b83a3c", "#e0544a", "#f6805e", "#ffae86" }
local TW   = { "#7a4a22", "#c08a3c", "#ecc070" }
local LAB  = { "#c9a46e", "#ecd8a8", "#fff4d6" }

c:groundShadow(32, 53, 15, 1.5)

local X0, X1, Y0, Y1 = 19, 44, 21, 52
local CX = (X0 + X1) / 2
local RR = (X1 - X0) / 2 + 0.5
local jar = c:rrect(X0, Y0, X1, Y1, 4)
local function cyl(x) local nx = (x - CX) / (RR + 0.3) return { nx, 0.05, sqrt(max(0.05, 1 - nx * nx)) } end

-- contents (cylinder light), inside the glass walls
local inner = c:rrect(X0 + 1, 25, X1 - 1, Y1 - 3, 3)
local n = {}
inner:each(function(x, y) n[K(x, y)] = cyl(x) end)
local ctok = { r = { name = "chutney" } }
local idx = A.shade(c, inner, n, CH, { amb = 0.12, wrap = 0.35, tok = ctok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
-- surface row lit
for x = X0 + 2, X1 - 2 do A.step(c, idx, CH, x, 25, 1, ctok) end
-- chunks: pineapple cubes, raisins, chili flecks
for gy = 0, 7 do for gx = 0, 6 do
  local h = X.hash(gx, gy, 41)
  local x, y = X0 + 3 + gx * 3 + floor(X.hash(gx, gy, 42) * 2), 27 + gy * 3 + floor(X.hash(gx, gy, 43) * 2)
  if inner:has(x, y) and inner:has(x + 1, y + 1) then
    local d = (x - CX) / RR
    if h < 0.42 then
      local o = d > 0.45 and -1 or 0
      c:put(x, y, CUBE[3 + o], ctok) c:put(x + 1, y, CUBE[2 + o], ctok)
      c:put(x, y + 1, CUBE[2 + o], ctok) c:put(x + 1, y + 1, CUBE[1], ctok)
    elseif h < 0.55 then c:put(x, y, "#4a1e2a", ctok)
    elseif h < 0.68 then c:put(x, y, "#e2382e", ctok) end
  end
end end

-- glass: headspace, walls, base
local gtok = { r = { name = "glass" } }
jar:each(function(x, y) if not inner:has(x, y) then
  local col
  if y >= Y1 - 2 then col = (x < CX - 4) and GL[3] or GL[2]
  elseif y < 25 then col = (x < CX - 6) and GL[4] or (x > CX + 6 and GL[2] or GL[3])
  else col = (x < CX) and GL[3] or GL[2] end
  if y == Y1 and x > X0 + 2 and x < X1 - 2 then col = GL[1] end
  c:put(x, y, col, gtok)
end end)
-- specular streaks
for y = 28, 46 do c:put(X0 + 3, y, (y < 32 or y > 42) and GL[3] or GL[4], gtok) end
for y = 30, 35 do c:put(X0 + 5, y, GL[3], gtok) end
c:px(X0 + 3, 30, "#fff4d6")
-- cool reflected light on the right wall
for y = 30, 46 do c:put(X1 - 2, y, (y % 6 < 4) and "#7a8fb0" or CH[2], gtok) end

-- label
local ltok = { r = { name = "label" } }
local lab = c:rrect(24, 34, 39, 44, 1)
lab:each(function(x, y)
  local col = LAB[2]
  if x >= 37 then col = LAB[1] end
  if x <= 25 or y == 34 then col = LAB[3] end
  if y == 44 or x == 39 then col = LAB[1] end
  c:put(x, y, col, ltok)
end)
-- tiny pineapple on the label
c:paint({
  ".g.g.",
  "..g..",
  ".hbb.",
  "hbdbs",
  "bdbds",
  ".sss.",
}, 30, 36, { g = "#3f9150", h = "#ffe38a", b = "#f5b82e", d = "#d98322", s = "#b06a20" })
c:px(29, 37, "#7cc35a") c:px(35, 37, "#3f9150")

-- cloth cover: domed top over the lid, gathered skirt with a pinked hem
local cl = HP.mask()
cl:add(c:ellipse(CX, 16, 13.5, 5))
cl:add(c:rect(X0 - 1, 16, X1 + 1, 20))
for x = X0 - 2, X1 + 2 do
  local hem = 23 + ((x % 3 == 0) and 1 or 0) + ((x < X0 + 2 or x > X1 - 2) and 1 or 0)
  for y = 17, hem do cl:set(x, y) end
end
cl:cut(c:rect(0, 0, 63, 10))
local cn = X.pillow(cl, 4)
-- folds: vertical gathers below the twine
local cb = {}
cl:each(function(x, y) local k = K(x, y)
  if y >= 21 and (x - X0) % 5 == 2 then cb[k] = -1 end
  if y >= 21 and (x - X0) % 5 == 3 then cb[k] = 1 end
  if y < 19 and ((x + y) % 4 == 0) then cb[k] = (cb[k] or 0) - 1 end   -- diagonal weave
end)
local cltok = { r = { name = "cloth" } }
A.shade(c, cl, cn, CL, { amb = 0.1, wrap = 0.3, bias = cb, tok = cltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
-- jar under the hem: AO row
for x = X0, X1 do local y = 25 if jar:has(x, y) and not cl:has(x, y) and cl:has(x, y - 1) then c:put(x, y, GL[1], gtok) end end

-- twine band with twist + loose ends
local ttok = { r = { name = "twine" } }
for x = X0 - 2, X1 + 2 do
  c:put(x, 19, ((x % 3) == 0) and TW[1] or TW[3], ttok)
  c:put(x, 20, ((x % 3) == 1) and TW[1] or TW[2], ttok)
end
for _, p in ipairs{ { X1 + 3, 20, 2 }, { X1 + 4, 21, 3 }, { X1 + 4, 22, 2 }, { X1 + 5, 23, 1 }, { X1 + 3, 21, 1 }, { X1 + 3, 22, 3 }, { X1 + 3, 23, 2 }, { X1 + 2, 24, 1 } } do
  c:put(p[1], p[2], TW[p[3]], ttok)
end

-- quirk: drip down the glass from under the hem
local dtok = { r = { name = "drip" } }
for y = 24, 30 do c:put(39, y, CH[4], dtok) c:put(40, y, CH[3], dtok) end
c:put(39, 31, CH[4], dtok) c:put(40, 31, CH[3], dtok) c:put(41, 31, CH[2], dtok)
c:put(38, 32, CH[4], dtok) c:put(39, 32, CH[5], dtok) c:put(40, 32, CH[3], dtok) c:put(41, 32, CH[2], dtok)
c:put(39, 33, CH[3], dtok) c:put(40, 33, CH[2], dtok)
c:put(39, 26, CH[6], dtok) c:put(39, 31, "#fff4d6", dtok)

A.save(c, NAME)
