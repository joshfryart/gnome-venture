-- Hearth Pop v3 : The Coralscatter (Pacific / Oceania islands) - gate view town, hero scale
-- 480x270 native, VP (240,112). Run:
-- AppRun -b --script-param out=<dir>/ --script here-town-coralscatter.lua
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-coralscatter"
local W, H = 480, 270
local floor, abs, min, max = math.floor, math.abs, math.min, math.max

---------------------------------------------------------------- buffer
local buf = {}
local function set(x, y, c) x = floor(x) y = floor(y) if c and x >= 0 and y >= 0 and x < W and y < H then buf[y * W + x] = c end end
local function get(x, y) if x >= 0 and y >= 0 and x < W and y < H then return buf[y * W + x] end end
local function hash(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  local function m(p, q) local v = floor(p + (q - p) * t + .5) return max(8, min(250, v)) end
  return string.format("#%02x%02x%02x", m(r1, r2), m(g1, g2), m(b1, b2))
end

---------------------------------------------------------------- masks
local Mk = {} Mk.__index = Mk
local function mask() return setmetatable({ s = {} }, Mk) end
function Mk:add(x, y) x = floor(x) y = floor(y) if x >= 0 and y >= 0 and x < W and y < H then self.s[y * W + x] = true end return self end
function Mk:has(x, y) if x < 0 or y < 0 or x >= W or y >= H then return false end return self.s[y * W + x] == true end
function Mk:each(f) local ks = {} for k in pairs(self.s) do ks[#ks + 1] = k end table.sort(ks) for _, k in ipairs(ks) do f(k % W, k // W) end end
function Mk:union(o) for k in pairs(o.s) do self.s[k] = true end return self end
function Mk:cut(o) for k in pairs(o.s) do self.s[k] = nil end return self end
function Mk:clip(o) local d = {} for k in pairs(self.s) do if not o.s[k] then d[#d + 1] = k end end for _, k in ipairs(d) do self.s[k] = nil end return self end
function Mk:copy() local m = mask() for k in pairs(self.s) do m.s[k] = true end return m end

local function rectM(x0, y0, x1, y1) local m = mask() for y = y0, y1 do for x = x0, x1 do m:add(x, y) end end return m end
local function polyM(p)
  local m = mask() local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, q in ipairs(p) do a = min(a, q[1]) b = max(b, q[1]) c = min(c, q[2]) d = max(d, q[2]) end
  for y = floor(c), math.ceil(d) do
    local py = y + .5
    for x = floor(a), math.ceil(b) do
      local px, inside, j = x + .5, false, #p
      for i = 1, #p do
        local xi, yi, xj, yj = p[i][1], p[i][2], p[j][1], p[j][2]
        if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
        j = i
      end
      if inside then m:add(x, y) end
    end
  end
  return m
end
local function ellM(cx, cy, rx, ry, jit, seed)
  local m = mask()
  for y = floor(cy - ry - 2), floor(cy + ry + 2) do for x = floor(cx - rx - 2), floor(cx + rx + 2) do
    local dx, dy = (x + .5 - cx) / rx, (y + .5 - cy) / ry
    local thr = 1 + (jit or 0) * (hash(floor(x / 3), floor(y / 3), seed or 0) - .5)
    if dx * dx + dy * dy < thr then m:add(x, y) end
  end end
  return m
end
local function lineM(pts, w, m)
  m = m or mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2])) * 2 + 1
    for s = 0, n do
      local t = s / n
      local px, py = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
      local ww = (type(w) == "function") and floor(w((i - 1 + t) / (#pts - 1))) or w
      local r = floor(ww / 2)
      for oy = 0, ww - 1 do for ox = 0, ww - 1 do m:add(floor(px) - r + ox, floor(py) - r + oy) end end
    end
  end
  return m
end

local function fill(m, c)
  if type(c) == "function" then m:each(function(x, y) local v = c(x, y) if v then set(x, y, v) end end)
  else m:each(function(x, y) set(x, y, c) end) end
end
local function edgeIn(m, col)
  local pts = {}
  m:each(function(x, y) if not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1)) then pts[#pts + 1] = { x, y } end end)
  for _, p in ipairs(pts) do set(p[1], p[2], col) end
end
local function rimOut(m, col)
  local seen, pts = {}, {}
  m:each(function(x, y)
    for _, d in ipairs { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local a, b = x + d[1], y + d[2]
      if a >= 0 and b >= 0 and a < W and b < H and not m:has(a, b) then
        local k = b * W + a if not seen[k] then seen[k] = true pts[#pts + 1] = { a, b } end
      end
    end
  end)
  for _, p in ipairs(pts) do set(p[1], p[2], col) end
end
local VIOLET = "#46386a"
local function shadow(m, t) m:each(function(x, y) local c = get(x, y) if c then set(x, y, mix(c, VIOLET, t or .3)) end end) end
local function warm(m, t) m:each(function(x, y) local c = get(x, y) if c then set(x, y, mix(c, "#ffd27a", t or .25)) end end) end

---------------------------------------------------------------- ramps
local function R(d, s, b, l, h) return { d = d, s = s, b = b, l = l, h = h } end
local PEACH = R("#a85e4a", "#d08868", "#f0a882", "#f8c4a0", "#fde0c4")
local TEAL = R("#24585e", "#367e80", "#4ea09c", "#74c0b6", "#a2dcce")
local BLUE = R("#344e7c", "#5476a2", "#7a9ec4", "#a0c0da", "#c6deea")
local YEL = R("#93662a", "#c49642", "#e8be64", "#f4d688", "#faeab4")
local CORAL = R("#7e3236", "#a84a46", "#cc6656", "#e28a76", "#f0ae98")
local WOOD = R("#55362a", "#7a5238", "#9a6c48", "#ba8c60", "#d4aa7c")
local THATCH = R("#7e5a2c", "#a8803c", "#cca04c", "#e2c06c", "#f0d890")
local CORK = R("#6e4430", "#9a6440", "#b8845a", "#d0a274", "#e2bc90")
local LEAF = R("#1e4a32", "#2e6a3e", "#43884a", "#62a656", "#8cc46c")
local GRASS = R("#386a34", "#4c863e", "#66a64a", "#88c25a", "#acd674")
local BARK = R("#43302e", "#634638", "#84624c", "#a48266", "#c09e80")
local STONE = R("#4a4660", "#66627e", "#86829e", "#a8a4bc", "#c8c4d6")
local ROCK = R("#38344a", "#504a64", "#6a647e", "#888298", "#a8a2b8")
local POST = R("#472a20", "#683f2e", "#8a5a3c", "#aa7a52", "#c89a6c")
local BUSH = R("#20483a", "#2e6244", "#427c50", "#5e9a5c", "#82b86e")
local PALM = R("#2c5e34", "#3e7a3c", "#549448", "#74b05a", "#98c870")

local function dark(Rm) return { d = Rm.d, s = Rm.d, b = Rm.s, l = Rm.b, h = Rm.l } end
local function boards(m, Rm, period)
  fill(m, function(x, y)
    local r = y % period
    if r == period - 1 then return Rm.s end
    if r == 0 then return Rm.l end
    local g = hash(floor(x / 5), y, 3)
    if g > .9 then return Rm.s end
    if g < .05 then return Rm.h end
    return Rm.b
  end)
end
local function corrugated(m, Rm)
  fill(m, function(x, y)
    local r = x % 3
    local t = (r == 0) and Rm.l or ((r == 1) and Rm.b or Rm.s)
    if hash(x, floor(y / 2), 5) > .975 then t = Rm.d end
    if hash(floor(x / 7), floor(y / 5), 6) > .93 then t = mix(t, "#b06a4a", .35) end -- faded rust patch
    return t
  end)
end
local function thatch(m, Rm, tier, seed)
  fill(m, function(x, y)
    local ty = (y + floor(hash(x, 0, seed) * 2)) % tier
    local g = hash(x, floor(y / 3), seed + 1)
    if ty == tier - 1 then return Rm.d end
    if ty == tier - 2 then return Rm.s end
    if g > .8 then return Rm.l elseif g < .18 then return Rm.s end
    if ty <= 1 and g > .5 then return Rm.h end
    return Rm.b
  end)
end
local function lit(m, Rm, cx, cy, rx, ry, seed, noise)
  fill(m, function(x, y)
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local v = .5 - .45 * (nx * .6 + ny * .8) + (hash(floor(x / 2), floor(y / 2), seed or 1) - .5) * (noise or .3)
    if v > .8 then return Rm.h elseif v > .6 then return Rm.l elseif v > .38 then return Rm.b elseif v > .2 then return Rm.s end
    return Rm.d
  end)
end
local function woodV(m, Rm)
  fill(m, function(x, y)
    local c = Rm.b
    if not m:has(x - 1, y) then c = Rm.l elseif not m:has(x + 1, y) then c = Rm.s end
    if hash(x, floor(y / 4), 11) > .86 then c = Rm.s end
    return c
  end)
  edgeIn(m, Rm.d)
end
local function woodH(m, Rm)
  fill(m, function(x, y)
    local c = Rm.b
    if not m:has(x, y - 1) then c = Rm.l elseif not m:has(x, y + 1) then c = Rm.s end
    if hash(floor(x / 4), y, 12) > .86 then c = Rm.s end
    return c
  end)
  edgeIn(m, Rm.d)
end

---------------------------------------------------------------- SKY
local skyC = { { 22, "#3a84c6" }, { 36, "#4894d2" }, { 50, "#5aa4da" }, { 62, "#70b4e2" }, { 74, "#8cc4e8" }, { 84, "#a8d4ec" }, { 999, "#c0e0ec" } }
for y = 0, H - 1 do
  local col = "#c0e0ec"
  for _, s in ipairs(skyC) do if y < s[1] then col = s[2] break end end
  for x = 0, W - 1 do set(x, y, col) end
end
local function cloud(x0, yb, w, seed)
  local n = 3 + floor(w / 40)
  local humps = {}
  for i = 1, n do
    local cx = x0 + w * (i - .5) / n + (hash(i, seed) - .5) * w * .12
    local r = w / n * (.75 + hash(seed, i) * .45)
    if i == 1 or i == n then r = r * .7 end
    humps[i] = { cx, r }
  end
  for x = x0, x0 + w do
    local h = 0
    for _, hp in ipairs(humps) do local d = x - hp[1] if abs(d) < hp[2] then local v = math.sqrt(hp[2] ^ 2 - d * d) * .85 if v > h then h = v end end end
    local top = floor(yb - h)
    for y = top, yb do
      local c = "#f4f7fb"
      if y >= yb - 1 then c = "#b2c4e0" elseif y >= yb - 4 then c = "#d0dcef"
      elseif x > x0 + w * .6 and y > top + 3 then c = "#e0e8f4" end
      if h > 0 then set(x, y, c) end
    end
  end
end
cloud(28, 64, 110, 1) cloud(146, 46, 84, 2) cloud(252, 30, 104, 3) cloud(372, 52, 66, 4) cloud(96, 28, 52, 5)

---------------------------------------------------------------- ISLANDS + SEA
local SEA = { { 96, "#2a8eb0" }, { 100, "#30a0ba" }, { 104, "#3ab2c2" }, { 108, "#4cc6c8" }, { 999, "#68d6cc" } }
for y = 92, 111 do
  local col for _, s in ipairs(SEA) do if y < s[1] then col = s[2] break end end
  for x = 0, W - 1 do
    local c = col
    if hash(floor(x / 4), y, 8) > .93 and y > 93 then c = "#a6e6e2" end
    set(x, y, c)
  end
end
local function island(xa, xb, peaks)
  for x = xa, xb do
    local top, pk = 92, nil
    for _, p in ipairs(peaks) do
      local d = abs(x - p[1])
      if d < p[3] then local t = p[2] + (d / p[3]) ^ 1.5 * (92 - p[2]) if t < top then top = t pk = p end end
    end
    top = floor(top)
    for y = top, 91 do
      local c = (pk and x > pk[1]) and "#6a98aa" or "#80aebb"
      if y == top and pk and x <= pk[1] then c = "#9cc2c8" end
      if y >= 84 + floor(hash(floor(x / 3), 1, 4) * 3) then c = (pk and x > pk[1]) and "#4e8680" or "#5e9a8c" end
      set(x, y, c)
    end
    if hash(floor(x / 3), 2, 9) > .5 then set(x, 92, "#d4f0ea") end
  end
end
island(70, 244, { { 150, 58, 76 }, { 206, 74, 40 }, { 98, 78, 34 } })
island(372, 479, { { 440, 70, 56 }, { 400, 82, 26 } })

---------------------------------------------------------------- SAND
for y = 112, H - 1 do
  local base = (y < 140) and "#f2dcb0" or ((y < 190) and "#eed4a4" or "#e8cc98")
  for x = 0, W - 1 do
    local c, g = base, hash(x, y, 2)
    if g > .94 then c = "#d4b484" elseif g < .035 then c = "#faecca" elseif g > .5 and g < .503 then c = "#eeb0a6" end
    set(x, y, c)
  end
end
for x = 0, W - 1 do
  local fy = 111 + floor(hash(floor(x / 5), 1, 9) * 2)
  set(x, fy, "#e6f4ee") set(x, fy + 1, "#cfe8e2")
  for y = fy + 2, 114 do set(x, y, "#dcc29a") end
end
-- surf beach spit (right)
local spit = polyM { { 294, 113 }, { 302, 106 }, { 330, 101 }, { 392, 99 }, { 480, 99 }, { 480, 113 } }
fill(spit, function(x, y) local g = hash(x, y, 2) if g > .94 then return "#d4b484" end return (y < 103) and "#e8cfa0" or "#f2dcb0" end)
for x = 300, 479 do local m = spit:has(x, 104) end

---------------------------------------------------------------- SURF (Breaker Beach)
local waveM = polyM { { 300, 101 }, { 324, 97 }, { 336, 90 }, { 342, 80 }, { 345, 70 }, { 351, 62 }, { 361, 57 }, { 374, 56 }, { 386, 60 }, { 393, 70 }, { 397, 84 }, { 398, 101 } }
fill(waveM, function(x, y)
  local c
  if y < 66 then c = "#3cb4c4" elseif y < 78 then c = "#2fa2b8" elseif y < 90 then c = "#2a92ae" else c = "#36aabe" end
  if x > 378 then c = mix(c, "#6ad2d2", .3) end
  if (x + y) % 9 == 0 and hash(x, y, 31) > .3 then c = "#62cccf" end
  return c
end)
local barrel = polyM { { 347, 70 }, { 357, 66 }, { 364, 74 }, { 362, 86 }, { 352, 92 }, { 344, 86 } }
fill(barrel, function(x, y) return ((x + y) % 7 == 0) and "#2a8ca8" or "#1d7090" end)
edgeIn(waveM, "#156a84")
local lip = lineM({ { 344, 72 }, { 350, 63 }, { 361, 58 }, { 374, 57 }, { 386, 61 }, { 393, 69 } }, 4)
fill(lip, function(x, y) return hash(x, y, 33) > .7 and "#c4e6e6" or "#eaf6f2" end)
fill(lineM({ { 344, 72 }, { 342, 80 }, { 343, 86 } }, 2), "#d8f0ee")
for i = 1, 22 do local x, y = 346 + floor(hash(i, 1, 40) * 48), 50 + floor(hash(i, 2, 40) * 7) set(x, y, "#eaf6f2") end
for x = 296, 400 do
  local top = 96 + floor(hash(floor(x / 4), 3, 41) * 3)
  for y = top, 101 do set(x, y, (y == top or hash(x, y, 42) > .6) and "#eaf6f2" or "#c4e4e6") end
end
-- surfboards on an A-frame rack
local function surfboard(cx, yt, yb, w, Rm, stripe)
  local hw = w / 2
  local m = polyM { { cx, yt }, { cx + hw, yt + (yb - yt) * .3 }, { cx + hw, yb - 3 }, { cx + hw - 1, yb }, { cx - hw + 1, yb }, { cx - hw, yb - 3 }, { cx - hw, yt + (yb - yt) * .3 } }
  fill(m, function(x, y)
    local c = (x < cx) and Rm.l or Rm.b
    if x >= cx + hw - 2 then c = Rm.s end
    if stripe and y >= yt + (yb - yt) * .55 and y < yt + (yb - yt) * .55 + 3 then c = stripe end
    return c
  end)
  for y = yt + 3, yb - 2 do set(floor(cx), y, Rm.s) end
  set(floor(cx - hw + 2), yt + 6, Rm.h) set(floor(cx - hw + 2), yt + 7, Rm.h)
  edgeIn(m, Rm.d)
  return m
end
shadow(polyM { { 312, 104 }, { 346, 104 }, { 352, 108 }, { 316, 108 } }, .3)
surfboard(315, 72, 104, 8, R("#8a3030", "#c4504a", "#e46a58", "#f2907a", "#fcc0a8"), "#f4e8cc")
surfboard(326, 66, 104, 8, R("#8a6420", "#c89a30", "#f0c848", "#f8dc78", "#fcefb0"), "#e46a58")
surfboard(337, 74, 104, 8, R("#1e6a66", "#2c8c86", "#3cb0a6", "#6ccabe", "#a6e4da"), "#f4e8cc")
woodH(rectM(308, 88, 344, 90), WOOD)
woodV(lineM({ { 309, 105 }, { 311, 88 } }, 2), WOOD)
woodV(lineM({ { 343, 105 }, { 341, 88 } }, 2), WOOD)
-- quirk: beetle-size trophy surfboard on a little post (rode one wave all afternoon)
woodV(rectM(386, 93, 387, 106), WOOD)
surfboard(386.5, 82, 93, 4, R("#7a4e8a", "#9a6aa8", "#c08ad0", "#d8ace4", "#ecd0f2"))
set(388, 94, "#e23a48") set(389, 95, "#e23a48") set(388, 95, "#a01e34")

---------------------------------------------------------------- BOARDWALK
local bw = polyM { { 150, 270 }, { 377, 270 }, { 250, 112 }, { 231, 112 } }
local TINT = { "#cfb090", "#c6a586", "#d6b898" }
fill(bw, function(x, y)
  local s = max(y - 104, 2)
  local idx = floor(math.log(s) * 9)
  if idx ~= floor(math.log(s - 1) * 9) then return "#8a6a5a" end
  local L = 10 + s * .5
  local off = hash(idx, 0, 7) * L
  local seg = floor((x + off) / L)
  if floor((x - 1 + off) / L) ~= seg and s > 30 then return "#9c7c66" end
  local c = TINT[1 + floor(hash(idx, seg, 8) * 3)]
  if idx ~= floor(math.log(max(s - 2, 1)) * 9) then c = "#e2c8a8" end
  if hash(floor(x / 3), y, 9) > .9 then c = mix(c, "#8a6a5a", .3) end
  return c
end)
edgeIn(bw, "#7a5a4a")
fill(polyM { { 152, 270 }, { 157, 270 }, { 233, 113 }, { 232, 112 } }, nil)

---------------------------------------------------------------- WILD TRAIL (right edge)
fill(polyM { { 392, 148 }, { 424, 142 }, { 461, 133 }, { 461, 123 }, { 430, 127 }, { 402, 139 } }, function(x, y)
  return hash(x, y, 50) > .9 and "#cfae7c" or "#e0c290" end)
local bush = mask()
for i, L in ipairs { { 422, 102, 18, 22 }, { 446, 96, 18, 26 }, { 458, 110, 12, 28 }, { 432, 122, 22, 12 }, { 410, 118, 10, 14 } } do
  bush:union(ellM(L[1], L[2], L[3], L[4], .4, 60 + i))
end
bush:cut(polyM { { 392, 148 }, { 424, 142 }, { 461, 133 }, { 461, 123 }, { 430, 127 }, { 402, 139 } })
bush:clip(rectM(400, 60, 461, 140))
lit(bush, BUSH, 432, 104, 34, 34, 61, .55)
edgeIn(bush, BUSH.d)
-- palm
local trunk = lineM({ { 448, 128 }, { 446, 100 }, { 442, 70 }, { 440, 44 } }, function(t) return 5 - t * 2 end)
fill(trunk, function(x, y) if y % 4 == 0 then return "#6a4c3a" end return hash(x, 0, 3) > .5 and "#a07a58" or "#8a6648" end)
edgeIn(trunk, "#4e3428")
for i, f in ipairs { { 414, 54 }, { 420, 40 }, { 434, 32 }, { 452, 34 }, { 461, 46 }, { 458, 58 }, { 426, 62 } } do
  local mid = { (440 + f[1]) / 2, (44 + f[2]) / 2 - 4 }
  local fm = lineM({ { 440, 44 }, mid, f }, 2)
  fill(fm, function(x, y) return ((x + y) % 3 == 0) and PALM.l or PALM.b end)
  local pts = {}
  for t = .3, 1, .12 do
    local px = 440 + (f[1] - 440) * t local py = 44 + (f[2] - 44) * t - 4 * math.sin(t * 3.14)
    set(px, py + 2, PALM.s) set(px, py + 3, PALM.d) set(px + 1, py + 2, PALM.s)
  end
end
fill(rectM(438, 45, 441, 47), "#6a4630") set(438, 45, "#8a6448")
-- arch
shadow(polyM { { 420, 140 }, { 462, 136 }, { 462, 142 }, { 424, 145 } }, .3)
local postL, postR = rectM(416, 74, 421, 140), rectM(450, 74, 455, 140)
woodV(postL, POST) woodV(postR, POST)
for _, pm in ipairs { { 416, 421 }, { 450, 455 } } do
  for y = 92, 132, 20 do for x = pm[1] + 1, pm[2] - 1 do set(x, y, ((x + y) % 2 == 0) and "#d0a874" or "#a07850") set(x, y + 1, ((x + y) % 2 == 1) and "#d0a874" or "#a07850") end end
end
local lintel = polyM { { 409, 77 }, { 462, 77 }, { 462, 70 }, { 454, 67 }, { 418, 67 }, { 409, 70 } }
woodH(lintel, POST)
fill(polyM { { 408, 71 }, { 411, 71 }, { 410, 62 }, { 407, 64 } }, POST.l) edgeIn(polyM { { 408, 71 }, { 411, 71 }, { 410, 62 }, { 407, 64 } }, POST.d)
for x = 414, 458, 6 do set(x, 72, POST.h) set(x + 1, 73, POST.d) set(x + 2, 72, POST.h) end
local cap = polyM { { 413, 68 }, { 460, 68 }, { 452, 57 }, { 421, 57 } }
thatch(cap, THATCH, 5, 70) edgeIn(cap, THATCH.d)
for i = 0, 7 do
  local x = 412 + i * 6 + floor(hash(i, 1, 71) * 3)
  set(x, 76, LEAF.b) set(x + 1, 77, LEAF.s)
  set(x, 78, "#e23a48") set(x + 1, 78, "#e23a48") set(x, 77, "#f47a70") set(x + 1, 79, "#a01e34")
end
-- signpost pointing out of the picture
shadow(polyM { { 414, 140 }, { 426, 140 }, { 428, 143 }, { 416, 143 } }, .3)
woodV(rectM(412, 100, 414, 140), WOOD)
local arrow = polyM { { 410, 102 }, { 428, 102 }, { 434, 107.5 }, { 428, 113 }, { 410, 113 } }
fill(arrow, function(x, y) if y <= 103 then return "#f4a868" end if y >= 111 then return "#c06030" end return "#e8884a" end)
edgeIn(arrow, "#8a3e22")
-- fern icon on the arrow
for x = 415, 426 do set(x, 108, "#2e6a3e") end
for x = 416, 425, 2 do set(x, 106, "#5ea04e") set(x + 1, 107, "#43884a") set(x, 110, "#43884a") set(x + 1, 109, "#5ea04e") end

---------------------------------------------------------------- QUIRK: island-time stepping stone loop with a found glass float
do
  local stones = { { 344, 152 }, { 352, 150 }, { 360, 148 }, { 368, 146 } }
  for a = 0, 330, 45 do stones[#stones + 1] = { 378 + 11 * math.cos(math.rad(a + 160)), 141 + 5 * math.sin(math.rad(a + 160)) } end
  stones[#stones + 1] = { 392, 144 } stones[#stones + 1] = { 400, 141 }
  for _, s in ipairs(stones) do
    local m = rectM(floor(s[1]) - 2, floor(s[2]) - 1, floor(s[1]) + 2, floor(s[2]) + 1)
    m:cut(rectM(floor(s[1]) - 2, floor(s[2]) - 1, floor(s[1]) - 2, floor(s[2]) - 1)) m:cut(rectM(floor(s[1]) + 2, floor(s[2]) + 1, floor(s[1]) + 2, floor(s[2]) + 1))
    fill(m, STONE.b) set(s[1] - 1, s[2] - 1, STONE.h) set(s[1] + 2, s[2], STONE.s) set(s[1], s[2] + 1, STONE.s) set(s[1] + 1, s[2] + 2, mix("#eed4a4", VIOLET, .3))
  end
  local fl = polyM { { 375, 138 }, { 381, 138 }, { 382, 141 }, { 381, 144 }, { 375, 144 }, { 374, 141 } }
  fill(fl, function(x, y) if x < 377 and y < 141 then return "#9ee0be" end return (x > 379) and "#2e8a6a" or "#48b08a" end)
  edgeIn(fl, "#1e6450") set(376, 139, "#e6f8ee")
  set(378, 138, "#c8a070") set(378, 141, "#c8a070") set(378, 144, "#c8a070")
  shadow(rectM(379, 145, 384, 145), .35)
end

---------------------------------------------------------------- TEAHOUSE: The Flat White
shadow(polyM { { 96, 116 }, { 160, 116 }, { 168, 121 }, { 100, 121 } }, .3)
local wallF = rectM(96, 84, 146, 116)
local wallS = polyM { { 147, 84 }, { 158, 87 }, { 158, 115 }, { 147, 117 } }
boards(wallF, PEACH, 4) boards(wallS, dark(PEACH), 4)
fill(rectM(96, 85, 146, 86), PEACH.s)
edgeIn(wallF, PEACH.d) edgeIn(wallS, PEACH.d)
local roofF = polyM { { 90, 85 }, { 153, 85 }, { 141, 62 }, { 103, 62 } }
local roofS = polyM { { 153, 85 }, { 161, 88 }, { 151, 64 }, { 141, 62 } }
corrugated(roofF, TEAL) corrugated(roofS, dark(TEAL))
for x = 91, 152 do set(x, 84, TEAL.h) end
edgeIn(roofF, TEAL.d) edgeIn(roofS, TEAL.d)
for x = 104, 140 do set(x, 62, TEAL.d) set(x, 63, TEAL.h) end
-- window with warm glow
local function window(x0, y0, x1, y1, Fr, kind)
  local fm = rectM(x0, y0, x1, y1)
  fill(fm, Fr.l)
  for x = x0, x1 do set(x, y1, Fr.s) end for y = y0, y1 do set(x1, y, Fr.s) end
  local gm = rectM(x0 + 2, y0 + 2, x1 - 2, y1 - 2)
  if kind == "books" then
    local cols = { "#c8404a", "#f0c040", "#3c8c6c", "#4a6cb0", "#8a4a9a", "#e8884a", "#f4e8cc" }
    fill(gm, function(x, y)
      local shelf = (y - y0 - 2) % 6
      if shelf == 5 then return "#7a4e30" end
      if shelf == 0 and hash(x, y, 81) > .4 then return "#5a3a2a" end
      return cols[1 + floor(hash(floor(x / 2), floor((y - y0) / 6), 80) * #cols)]
    end)
  else
    fill(gm, function(x, y)
      if y < y0 + 5 then return "#a8d4e0" end
      if (x - y) % 11 == 0 then return "#fbe8b0" end
      return (y > y1 - 5) and "#f0b858" or "#f6cc70"
    end)
  end
  for y = y0 + 2, y1 - 2 do set(floor((x0 + x1) / 2), y, Fr.b) end
  for x = x0 + 2, x1 - 2 do set(x, floor((y0 + y1) / 2), Fr.b) end
  edgeIn(fm, Fr.d)
end
local CREAM = R("#8a6a4a", "#d8c4a0", "#ecdcbc", "#f6ecd4", "#fbf6ea")
-- awning
local aw = polyM { { 99, 88 }, { 128, 88 }, { 130, 93 }, { 97, 93 } }
fill(aw, function(x, y) return (floor((x + (y - 88)) / 3) % 2 == 0) and "#e46a58" or "#f4e8cc" end)
edgeIn(aw, "#8a3030")
window(101, 94, 125, 110, CREAM, "glow")
warm(polyM { { 101, 111 }, { 126, 111 }, { 132, 120 }, { 99, 120 } }, .2)
-- door
local door = rectM(131, 92, 141, 116)
fill(door, function(x, y) if x == 131 then return TEAL.l end if x == 141 then return TEAL.s end return ((y - 92) % 8 == 0) and TEAL.s or TEAL.b end)
fill(rectM(133, 95, 139, 101), "#f6cc70") set(139, 106, "#f0c848")
edgeIn(door, TEAL.d)
-- bench under the window
woodH(rectM(102, 113, 124, 114), WOOD) set(103, 115, WOOD.d) set(123, 115, WOOD.d)
-- roof sign: flat-white cup
local sign = rectM(107, 50, 137, 61)
fill(sign, function(x, y) return (y == 50) and CREAM.h or ((x == 137 or y == 61) and CREAM.s or CREAM.l) end)
edgeIn(sign, "#6a4430")
fill(rectM(111, 62, 112, 63), WOOD.s) fill(rectM(132, 62, 133, 63), WOOD.s)
local cup = polyM { { 116, 54 }, { 128, 54 }, { 127, 59 }, { 117, 59 } }
fill(cup, function(x, y) return (x > 124) and "#dccbb0" or "#fbf3e6" end)
fill(rectM(117, 54, 127, 54), "#8a5a3a") set(121, 54, "#f2dcc0") set(122, 54, "#f2dcc0")
set(128, 55, "#8a6a4a") set(129, 56, "#8a6a4a") set(128, 57, "#8a6a4a")
fill(rectM(114, 59, 130, 59), "#c8b496") fill(rectM(116, 60, 128, 60), "#8a6a4a")
for _, p in ipairs { { 119, 52 }, { 120, 51 }, { 123, 52 }, { 124, 51 } } do set(p[1], p[2], "#b8a890") end
for y = 55, 58 do set(116, y, "#8a6a4a") set(127, y, "#8a6a4a") end

---------------------------------------------------------------- NOTICE BOARD
shadow(polyM { { 28, 122 }, { 76, 122 }, { 84, 127 }, { 32, 127 } }, .3)
woodV(rectM(28, 44, 31, 124), WOOD) woodV(rectM(66, 44, 69, 124), WOOD)
local panel = rectM(24, 52, 73, 106)
fill(panel, function(x, y) local c = ((x - 24) % 7 == 6) and CORK.s or CORK.b if hash(x, floor(y / 3), 90) > .85 then c = CORK.l end return c end)
for x = 24, 73 do set(x, 53, WOOD.l) set(x, 105, WOOD.s) end
for y = 53, 105 do set(25, y, WOOD.l) set(72, y, WOOD.s) end
edgeIn(panel, WOOD.d)
shadow(rectM(26, 54, 71, 55), .25)
local papers = { { 28, 58, 12, 14, "#f6ecd2", "wave" }, { 43, 59, 10, 12, "#f4c4c0" }, { 56, 57, 13, 10, "#c4e0ec", "wave" }, { 29, 76, 14, 10, "#d4ecc4", "leaf" },
  { 47, 73, 9, 14, "#f6e4a0" }, { 59, 71, 11, 13, "#f6ecd2", "leaf" }, { 29, 89, 10, 13, "#e0d0f0" }, { 42, 90, 14, 11, "#f6ecd2" }, { 59, 88, 10, 14, "#f4c4c0", "wave" } }
for i, p in ipairs(papers) do
  local x0, y0, x1, y1 = p[1], p[2], p[1] + p[3] - 1, p[2] + p[4] - 1
  local inkc = mix(p[5], "#3a2a40", .45)
  fill(rectM(x0, y0, x1, y1), function(x, y) if x == x1 or y == y1 then return mix(p[5], VIOLET, .25) end return p[5] end)
  set(x1 + 1, y0 + 1, CORK.d) for y = y0 + 1, y1 + 1 do set(x1 + 1, y, CORK.s) end for x = x0 + 1, x1 + 1 do set(x, y1 + 1, CORK.s) end
  if p[6] == "wave" then
    for x = x0 + 2, x1 - 2 do set(x, y0 + 4 + floor(math.sin(x * 1.2) * 1.2 + .5), inkc) end
  elseif p[6] == "leaf" then
    local cx, cy = floor((x0 + x1) / 2), floor((y0 + y1) / 2)
    fill(polyM { { cx - 3, cy + 1 }, { cx, cy - 3 }, { cx + 3, cy + 1 }, { cx, cy + 3 } }, "#5e9a4e") set(cx, cy, "#2e6a3e") set(cx, cy + 1, "#2e6a3e")
  end
  for y = y0 + ((p[6] and 7) or 4), y1 - 2, 2 do for x = x0 + 2, x1 - 2 do if hash(x, y, i) > .25 then set(x, y, inkc) end end end
  local tk = ({ "#d8404a", "#3cb0a8", "#f0c040" })[1 + i % 3]
  set(floor((x0 + x1) / 2), y0, tk) set(floor((x0 + x1) / 2) + 1, y0, mix(tk, "#3a2a40", .4)) set(floor((x0 + x1) / 2), y0 - 1, mix(tk, "#fbf6ea", .5))
end
local bcap = polyM { { 19, 54 }, { 78, 54 }, { 70, 38 }, { 28, 38 } }
thatch(bcap, THATCH, 5, 91)
for x = 19, 78 do if hash(x, 5, 92) > .4 then set(x, 54, THATCH.s) set(x, 55, THATCH.d) end end
edgeIn(bcap, THATCH.d)
for x = 29, 69 do set(x, 38, WOOD.s) set(x, 39, WOOD.l) end
-- quirk: message-bottle letterbox lashed to the post
fill(rectM(70, 107, 74, 118), function(x, y) if x == 70 then return "#9ee0be" end if x == 74 then return "#2e8a6a" end return "#48b08a" end)
fill(rectM(71, 103, 73, 106), "#48b08a") set(71, 103, "#9ee0be") fill(rectM(71, 101, 73, 102), "#c89a6c")
edgeIn(rectM(70, 101, 74, 118), "#1e6450")
fill(rectM(71, 110, 73, 114), "#f6ecd2") set(72, 112, "#c8a070")
for y = 108, 116, 4 do set(69, y, "#d0a874") set(68, y + 1, "#a07850") end

---------------------------------------------------------------- THE POHUTUKAWA GREEN (central)
shadow(polyM { { 190, 214 }, { 292, 214 }, { 300, 222 }, { 196, 222 } }, .3)
local lawn = polyM { { 198, 186 }, { 282, 186 }, { 290, 207 }, { 190, 207 } }
fill(lawn, function(x, y)
  local g = hash(x, y, 100)
  if g > .88 then return GRASS.h elseif g > .72 then return GRASS.l elseif g < .1 then return GRASS.s end
  return GRASS.b
end)
edgeIn(lawn, GRASS.d)
local kerb = rectM(190, 207, 290, 214)
fill(kerb, function(x, y) if y == 207 then return WOOD.h end if (x - 190) % 14 == 0 then return WOOD.s end if y >= 213 then return WOOD.s end return hash(floor(x / 3), y, 101) > .85 and WOOD.l or WOOD.b end)
edgeIn(kerb, WOOD.d)
-- trunks
local tr = mask()
lineM({ { 238, 200 }, { 230, 182 }, { 214, 162 } }, function(t) return 6 - t * 3 end, tr)
lineM({ { 243, 200 }, { 247, 180 }, { 262, 160 } }, function(t) return 6 - t * 3 end, tr)
lineM({ { 240, 200 }, { 238, 172 }, { 233, 150 } }, function(t) return 5 - t * 2 end, tr)
lineM({ { 245, 196 }, { 268, 174 }, { 280, 160 } }, function(t) return 4 - t * 2 end, tr)
tr:union(polyM { { 228, 204 }, { 254, 204 }, { 246, 190 }, { 236, 190 } })
shadow(polyM { { 240, 204 }, { 270, 204 }, { 280, 208 }, { 246, 208 } }, .35)
fill(tr, function(x, y)
  local c = BARK.b
  if not tr:has(x - 1, y) or not tr:has(x - 2, y) then c = BARK.l end
  if not tr:has(x + 1, y) then c = BARK.s end
  if hash(x, floor(y / 3), 102) > .82 then c = BARK.s end
  return c
end)
edgeIn(tr, BARK.d)
-- swing quirk (ropes drawn now, seat after crown)
for y = 166, 181 do set(263, y, "#c8a070") set(274, y, "#c8a070") end
-- crown
local lobes = { { 240, 124, 22, 11 }, { 226, 133, 22, 15 }, { 254, 131, 23, 15 }, { 204, 150, 18, 13 }, { 276, 148, 17, 13 }, { 240, 152, 26, 12 }, { 216, 162, 14, 7 }, { 264, 162, 14, 7 } }
local crown = mask()
for i, L in ipairs(lobes) do
  local m = ellM(L[1], L[2], L[3], L[4], .3, 110 + i)
  local before = crown:copy()
  lit(m, LEAF, L[1], L[2], L[3], L[4], 120 + i, .35)
  -- separation line where this lobe sits over an earlier one
  local sep = {}
  m:each(function(x, y) if before:has(x, y) and (not m:has(x, y - 1) or not m:has(x - 1, y)) then sep[#sep + 1] = { x, y } end end)
  for _, p in ipairs(sep) do set(p[1], p[2], LEAF.s) end
  crown:union(m)
end
edgeIn(crown, LEAF.d)
for gy = 112, 176, 4 do for gx = 186, 296, 4 do
  local ox, oy = gx + floor(hash(gx, gy, 130) * 3), gy + floor(hash(gy, gx, 131) * 3)
  local litv = 1 - ((ox - 190) / 110 * .5 + (oy - 112) / 64 * .5)
  if crown:has(ox, oy) and crown:has(ox + 2, oy + 1) and hash(ox, oy, 132) < .25 + .45 * litv then
    set(ox, oy, "#e23a48") set(ox + 1, oy, "#e23a48") set(ox + 2, oy, "#c82a3e")
    set(ox, oy - 1, "#f47a70") set(ox + 1, oy + 1, "#a01e34") set(ox + 1, oy - 1, "#ffb08a")
  end
end end
-- swing seat with one fallen blossom
woodH(rectM(260, 181, 277, 182), WOOD) set(268, 180, "#e23a48") set(269, 180, "#a01e34")
-- shade of the crown on the lawn
local shade = polyM { { 236, 188 }, { 286, 188 }, { 290, 206 }, { 248, 206 } } shade:clip(lawn) shadow(shade, .25)
-- fallen petals
for i = 1, 26 do
  local x, y = 192 + floor(hash(i, 1, 140) * 96), 188 + floor(hash(i, 2, 140) * 30)
  if y > 207 then y = y + 7 end
  if not tr:has(x, y) then set(x, y, (i % 3 == 0) and "#a01e34" or "#e23a48") end
end
-- quirk: two greeting stones leaning nose to nose
local st1 = polyM { { 199, 205 }, { 207, 205 }, { 208, 198 }, { 206, 191 }, { 203, 190 }, { 199, 196 } }
local st2 = polyM { { 207, 205 }, { 215, 205 }, { 216, 197 }, { 212, 191 }, { 208, 191 }, { 207, 198 } }
shadow(polyM { { 206, 205 }, { 220, 205 }, { 222, 208 }, { 210, 208 } }, .3)
lit(st1, STONE, 202, 196, 5, 8, 141, .1) edgeIn(st1, STONE.d)
lit(st2, STONE, 211, 196, 5, 8, 142, .1) edgeIn(st2, STONE.d)
set(207, 191, STONE.h)

---------------------------------------------------------------- LIBRARY
shadow(polyM { { 26, 212 }, { 125, 201 }, { 133, 206 }, { 32, 218 } }, .32)
local lwF = rectM(25, 172, 108, 212)
local lwS = polyM { { 109, 172 }, { 124, 166 }, { 124, 201 }, { 109, 213 } }
boards(lwF, BLUE, 4) boards(lwS, dark(BLUE), 4)
fill(rectM(25, 173, 108, 175), BLUE.s)
edgeIn(lwF, BLUE.d) edgeIn(lwS, BLUE.d)
local lrF = polyM { { 19, 173 }, { 117, 173 }, { 99, 145 }, { 37, 145 } }
local lrS = polyM { { 117, 173 }, { 128, 167 }, { 113, 144 }, { 99, 145 } }
thatch(lrF, THATCH, 6, 150) thatch(lrS, dark(THATCH), 6, 151)
for x = 19, 128 do if lrF:has(x, 172) or lrS:has(x, 168) then local yy = lrF:has(x, 172) and 173 or 169 if hash(x, 7, 152) > .45 then set(x, yy, THATCH.s) end end end
edgeIn(lrF, THATCH.d) edgeIn(lrS, THATCH.d)
for x = 37, 113 do set(x, 144, WOOD.d) set(x, 145, WOOD.s) end
-- big open book sign on the roof
local cover = polyM { { 43, 152 }, { 62, 156 }, { 81, 152 }, { 81, 166 }, { 62, 170 }, { 43, 166 } }
fill(cover, function(x, y) return (y > 165) and "#962c34" or "#c43c40" end) edgeIn(cover, "#5e1c24")
local pL = polyM { { 45, 150 }, { 62, 154 }, { 62, 167 }, { 45, 163 } }
local pR = polyM { { 62, 154 }, { 79, 150 }, { 79, 163 }, { 62, 167 } }
fill(pL, "#f8eed8") fill(pR, "#e6d6b6")
for k = 0, 3 do for x = 48, 59 do if hash(x, k, 153) > .2 then set(x, 155 + k * 3 + floor((x - 45) * 4 / 17) - 1, "#a8946e") end end
  for x = 65, 76 do if hash(x, k, 154) > .2 then set(x, 155 + k * 3 + floor((79 - x) * 4 / 17) - 1, "#9a8664") end end end
for y = 154, 167 do set(62, y, "#7a5a40") end
set(47, 152, "#fffbf0") set(48, 152, "#fbf6ea")
-- ribbon bookmark
fill(rectM(70, 164, 71, 171), "#f0c040") set(70, 172, "#c89a30")
-- windows of books, door, steps
window(30, 180, 50, 198, CREAM, "books")
window(83, 180, 103, 198, CREAM, "books")
local ld = rectM(59, 184, 74, 212)
fill(ld, function(x, y) if x == 59 then return "#5e9a8c" end if x == 74 then return "#2e6658" end if y == 184 then return "#5e9a8c" end return "#3e8070" end)
fill(rectM(62, 188, 71, 198), "#f6cc70") for x = 62, 71 do set(x, 193, "#7a4e30") end
set(72, 200, "#f0c848") edgeIn(ld, "#1e4a40")
fill(rectM(55, 211, 78, 214), STONE.b) for x = 55, 78 do set(x, 211, STONE.h) set(x, 214, STONE.s) end
warm(polyM { { 58, 215 }, { 76, 215 }, { 82, 220 }, { 56, 220 } }, .18)
-- quirk: shell wind chime under the eave
for y = 169, 184 do if y % 5 ~= 0 then set(117, y, "#d8c8a8") end end
for _, s in ipairs { { 117, 175, "#f4b0a8" }, { 117, 180, "#f2e2c4" }, { 117, 185, "#f4b0a8" } } do
  set(s[1] - 1, s[2], s[3]) set(s[1], s[2], s[3]) set(s[1], s[2] + 1, mix(s[3], "#8a5a5a", .4)) set(s[1] - 1, s[2] - 1, "#fbf6ea") set(s[1] + 1, s[2], mix(s[3], "#8a5a5a", .5))
end

---------------------------------------------------------------- SHOPS (seed shop + market front)
shadow(polyM { { 314, 224 }, { 446, 224 }, { 456, 230 }, { 322, 230 } }, .32)
local swF = rectM(316, 186, 440, 224)
local swS = polyM { { 309, 180 }, { 315, 186 }, { 315, 224 }, { 309, 216 } }
boards(swF, YEL, 4) boards(swS, dark(YEL), 4)
edgeIn(swF, YEL.d) edgeIn(swS, YEL.d)
local srF = polyM { { 312, 187 }, { 446, 187 }, { 432, 162 }, { 326, 162 } }
local srS = polyM { { 304, 181 }, { 312, 187 }, { 326, 162 }, { 318, 160 } }
corrugated(srF, CORAL) corrugated(srS, dark(CORAL))
for x = 313, 445 do set(x, 186, CORAL.h) end
edgeIn(srF, CORAL.d) edgeIn(srS, CORAL.d)
for x = 327, 431 do set(x, 162, CORAL.d) set(x, 163, CORAL.h) end
-- interior, shelves of seed packets
local inner = rectM(320, 196, 436, 209)
fill(inner, function(x, y) if (y - 196) % 6 == 5 then return "#9a6c48" end return "#5a3e40" end)
local pk = { "#f4c4c0", "#c4e0ec", "#d4ecc4", "#f6e4a0", "#e0d0f0", "#f8c4a0" }
for row = 0, 1 do for x = 322, 432, 6 do
  local y0 = 197 + row * 6
  local col = pk[1 + floor(hash(x, row, 160) * #pk)]
  fill(rectM(x, y0, x + 3, y0 + 4), col) set(x + 3, y0 + 4, mix(col, VIOLET, .3)) set(x + 1, y0 + 2, ({ "#7a4e30", "#43884a", "#e23a48" })[1 + (x + row) % 3])
end end
edgeIn(inner, "#3a2830")
-- awning
local awn = polyM { { 311, 187 }, { 447, 187 }, { 449, 196 }, { 309, 196 } }
fill(awn, function(x, y) local c = (floor((x - 309) / 6) % 2 == 0) and "#3aa0a0" or "#f4ead0" if y >= 194 then c = mix(c, VIOLET, .2) end return c end)
for x = 309, 449 do if (x - 309) % 6 < 4 then set(x, 197, (floor((x - 309) / 6) % 2 == 0) and "#2a7c7c" or "#d8c8a8") end end
edgeIn(awn, "#1e5a5a")
-- counter + crates of produce
woodH(rectM(318, 209, 438, 214), WOOD)
local function crate(x0, fillc, lightc, shadec, kind)
  local m = rectM(x0, 214, x0 + 22, 224)
  fill(m, function(x, y) if (y - 214) % 4 == 3 then return WOOD.s end return WOOD.b end)
  edgeIn(m, WOOD.d)
  for i = 0, 4 do
    local px = x0 + 2 + i * 4
    if kind == "banana" then
      fill(rectM(px, 211, px + 3, 213), fillc) set(px, 211, lightc) set(px + 3, 213, shadec) set(px + 3, 211, "#5a4a20")
    else
      fill(rectM(px, 210, px + 3, 213), fillc) set(px, 210, lightc) set(px + 1, 210, lightc) set(px + 3, 213, shadec) set(px + 2, 213, shadec)
    end
  end
end
crate(322, "#7a5034", "#a8784e", "#4e3020")
crate(350, "#f2d050", "#faea9a", "#b8902c", "banana")
crate(378, "#7cbc48", "#b0dc78", "#4a8030")
crate(406, "#7a3a6a", "#b06a9a", "#4a2242")
-- seedlings in pots, front left
for i = 0, 1 do
  local x = 330 + i * 0
end
-- leaning surfboard
surfboard(442, 192, 224, 6, R("#2e5c8a", "#4a80b4", "#6eaad8", "#98c8e8", "#c6e2f4"), "#f4e8cc")
-- seed shop sign: sprout from a seed
local ss = rectM(362, 154, 394, 166)
fill(ss, function(x, y) return (y == 154) and CREAM.h or ((x == 394 or y == 166) and CREAM.s or CREAM.l) end)
edgeIn(ss, "#6a4430")
fill(rectM(375, 162, 381, 164), "#8a5a34") set(375, 162, "#b07a4a") set(381, 164, "#5a3a24")
for y = 157, 161 do set(378, y, "#3e7a3c") end
fill(polyM { { 370, 158 }, { 377, 156 }, { 377, 159 }, { 372, 160 } }, "#5ea04e") set(371, 158, "#8cc46c")
fill(polyM { { 379, 156 }, { 386, 158 }, { 384, 160 }, { 379, 159 } }, "#43884a") set(380, 157, "#8cc46c")

---------------------------------------------------------------- ROCK POOLS
local rock = polyM { { 20, 270 }, { 21, 242 }, { 32, 231 }, { 58, 228 }, { 88, 232 }, { 116, 229 }, { 138, 236 }, { 148, 250 }, { 147, 270 } }
shadow(polyM { { 140, 240 }, { 156, 252 }, { 156, 270 }, { 146, 270 } }, .3)
fill(rock, function(x, y)
  local bx, by = floor(x / 15), floor(y / 9)
  local best, second, bdx, bdy = 1e9, 1e9, 0, 0
  for j = -1, 1 do for i = -1, 1 do
    local cx = (bx + i) * 15 + hash(bx + i, by + j, 170) * 15
    local cy = (by + j) * 9 + hash(by + j, bx + i, 171) * 9
    local d = ((x - cx) / 15) ^ 2 + ((y - cy) / 9) ^ 2
    if d < best then second = best best = d bdx, bdy = x - cx, y - cy elseif d < second then second = d end
  end end
  if second - best < .06 then return ROCK.d end
  local v = .5 - .5 * (bdx / 9 * .6 + bdy / 6 * .8) + (hash(x, y, 172) - .5) * .2
  if v > .8 then return ROCK.h elseif v > .6 then return ROCK.l elseif v > .38 then return ROCK.b elseif v > .2 then return ROCK.s end
  return ROCK.d
end)
edgeIn(rock, ROCK.d)
local pools = { { 52, 248, 19, 7 }, { 102, 243, 14, 6 }, { 124, 259, 12, 5 }, { 74, 262, 12, 4 } }
for i, P in ipairs(pools) do
  local pm = ellM(P[1], P[2], P[3], P[4], .35, 180 + i)
  rimOut(pm, ROCK.d)
  fill(pm, function(x, y)
    if not pm:has(x, y - 1) then return "#1c6878" end
    local t = (y - (P[2] - P[4])) / (2 * P[4])
    if hash(floor(x / 3), y, 181) > .9 and t > .3 then return "#c4f0ea" end
    if t < .35 then return "#2a8ea4" elseif t < .7 then return "#3cb0bc" end
    return "#62cccb"
  end)
end
-- seaweed in the big pool
for _, sx in ipairs { 44, 47, 60 } do for k = 0, 3 do set(sx + ((k % 2 == 0) and 0 or 1), 252 - k, (k < 2) and "#4f7a3a" or "#6e9a46") end end
-- shells
local fan = polyM { { 31, 242 }, { 40, 242 }, { 41, 238 }, { 36, 234 }, { 30, 238 } }
fill(fan, "#f4a8a0") for _, rx in ipairs { 33, 35, 37, 39 } do set(rx, 239, "#d8807c") set(rx, 240, "#d8807c") end set(33, 237, "#fcd6cc") edgeIn(fan, "#a85a5a")
fill(rectM(34, 242, 37, 243), "#e08a84") edgeIn(rectM(34, 242, 37, 243), "#a85a5a")
local cone = polyM { { 79, 241 }, { 91, 241 }, { 86, 233 } }
fill(cone, function(x, y) return ((x + y) % 4 < 2) and "#f2e2c4" or "#b07a4a" end) edgeIn(cone, "#6a4430") set(84, 237, "#fbf6ea")
local cow = polyM { { 112, 252 }, { 120, 252 }, { 121, 255 }, { 120, 257 }, { 112, 257 }, { 111, 255 } }
fill(cow, "#e8c8a0") for _, p in ipairs { { 114, 253 }, { 117, 254 }, { 119, 253 }, { 115, 255 } } do set(p[1], p[2], "#8a5a3a") end set(113, 253, "#fbf0dc") edgeIn(cow, "#6a4430")
for _, p in ipairs { { 26, 256 }, { 92, 252 }, { 140, 246 }, { 30, 264 } } do set(p[1], p[2], "#f4b0a8") set(p[1] + 1, p[2], "#c87a78") end
-- poking net leaning on the rocks
local stick = lineM({ { 140, 230 }, { 131, 256 } }, 1)
fill(stick, "#a07850")
local net = polyM { { 125, 255 }, { 136, 255 }, { 134, 266 }, { 127, 266 } }
fill(net, function(x, y) if ((x + y) % 3 == 0) or ((x - y) % 3 == 0) then return "#e8dcc0" end return nil end)
edgeIn(net, "#c89a6c")

---------------------------------------------------------------- dune grass tufts
local function tuft(x, y)
  for i, d in ipairs { { -2, 3 }, { -1, 5 }, { 0, 6 }, { 1, 4 }, { 2, 3 } } do
    for k = 0, d[2] - 1 do set(x + d[1] + ((k > 3 and d[1] ~= 0) and (d[1] > 0 and 1 or -1) or 0), y - k, (k < 2) and "#4e7a3a" or ((i % 2 == 0) and "#8ab45a" or "#6a9a48")) end
  end
end
tuft(136, 124) tuft(296, 150) tuft(146, 222) tuft(372, 120) tuft(86, 132) tuft(24, 222)

---------------------------------------------------------------- FRAME (timber gate, thatch, bunting, lanterns)
local function post(x0, x1, innerRight)
  local m = rectM(x0, 0, x1, H - 1)
  fill(m, function(x, y)
    local rx, w = x - x0, x1 - x0
    local c = POST.b
    if rx <= 1 then c = POST.l elseif rx >= w - 2 then c = POST.s end
    if hash(x, floor(y / 5), 11) > .86 then c = POST.s end
    local band = (y - 44) % 64
    if y > 40 and band < 8 then
      if (rx + band) % 4 == 0 then c = POST.d elseif (rx - band) % 4 == 0 or (rx + band) % 4 == 2 then c = POST.h end
    end
    local l = (y - 20) % 64
    if l >= 52 and l < 58 then c = ((x + y) % 3 == 0) and "#a07850" or "#d0a874" end
    return c
  end)
  edgeIn(m, POST.d)
end
post(0, 17) post(462, 479)
local beam = rectM(0, 0, W - 1, 9)
woodH(beam, POST)
for x = 0, W - 1 do
  local bot = 14 + floor(hash(floor(x / 2), 2, 13) * 5)
  for y = 10, bot do
    local g = hash(x, floor(y / 2), 14)
    local c = THATCH.b if g > .75 then c = THATCH.l elseif g < .22 then c = THATCH.s end
    if y == 10 then c = THATCH.d end
    if y == bot then c = THATCH.d elseif y == bot - 1 and g > .5 then c = THATCH.s end
    set(x, y, c)
  end
end
-- knee braces
for _, br in ipairs { { { 18, 18 }, { 42, 18 }, { 18, 42 } }, { { 461, 18 }, { 437, 18 }, { 461, 42 } } } do
  local m = polyM(br) local inner = polyM { br[1], { (br[2][1] + br[1][1]) / 2 + (br[1][1] < 100 and 4 or -4), br[2][2] + 1 }, { br[1][1], (br[3][2] + br[1][2]) / 2 + 4 } }
  m:cut(polyM { { br[1][1] + (br[1][1] < 100 and 1 or -1), br[1][2] + 1 }, { br[2][1] + (br[1][1] < 100 and -9 or 9), br[2][2] + 1 }, { br[1][1] + (br[1][1] < 100 and 1 or -1), br[3][2] - 9 } })
  woodH(m, POST)
end
-- pohutukawa sprigs at the beam corners
for _, sp in ipairs { { 22, 20 }, { 30, 17 }, { 448, 20 }, { 456, 17 }, { 240, 16 } } do
  fill(rectM(sp[1] - 2, sp[2], sp[1] + 2, sp[2] + 2), LEAF.b) set(sp[1] - 2, sp[2], LEAF.l) set(sp[1] + 2, sp[2] + 2, LEAF.d)
  set(sp[1], sp[2] - 1, "#e23a48") set(sp[1] + 1, sp[2] - 1, "#e23a48") set(sp[1], sp[2] - 2, "#f47a70") set(sp[1] + 1, sp[2], "#a01e34") set(sp[1] - 1, sp[2] - 1, "#c82a3e")
end
-- bunting
local function sag(x) return 22 + floor(12 * (1 - ((x - 240) / 222) ^ 2)) end
for x = 18, 461 do set(x, sag(x), "#7a5a48") end
local FL = { { "#e46a58", "#b04a40" }, { "#f2c84a", "#c49a30" }, { "#3cb0a8", "#2a807a" }, { "#f4e8cc", "#d0c0a0" }, { "#f29aa0", "#c46a74" } }
local k = 0
for x = 24, 452, 15 do
  if abs(x - 52) > 9 and abs(x - 428) > 9 then
    k = k + 1
    local f = FL[1 + k % #FL]
    local y = sag(x + 5) + 1
    local m = polyM { { x, y }, { x + 11, y }, { x + 5.5, y + 10 } }
    fill(m, function(px, py) return (px > x + 6) and f[2] or f[1] end)
    edgeIn(m, mix(f[2], "#2b1c26", .35))
  end
end
-- hanging lanterns with warm glow
for _, lx in ipairs { 52, 428 } do
  local halo = polyM { { lx, 14 }, { lx + 16, 32 }, { lx, 50 }, { lx - 16, 32 } }
  halo:cut(rectM(0, 0, W - 1, 20))
  warm(halo, .22)
  for y = 14, 24 do set(lx, y, "#5a3a2a") end
  local body = rectM(lx - 5, 26, lx + 5, 40)
  body:cut(rectM(lx - 5, 26, lx - 5, 26)) body:cut(rectM(lx + 5, 26, lx + 5, 26)) body:cut(rectM(lx - 5, 40, lx - 5, 40)) body:cut(rectM(lx + 5, 40, lx + 5, 40))
  fill(body, function(x, y)
    local dx = abs(x - lx)
    if dx >= 4 then return "#f0a040" end
    if (x - lx) % 3 == 0 and dx > 0 then return "#c87a3a" end
    if dx <= 1 and y > 29 and y < 37 then return "#fff0b0" end
    return "#ffd070"
  end)
  edgeIn(body, "#8a4a26")
  fill(rectM(lx - 4, 24, lx + 4, 25), "#6a4430") fill(rectM(lx - 3, 41, lx + 3, 42), "#6a4430")
  for y = 43, 46 do set(lx, y, "#e23a48") end set(lx, 47, "#a01e34")
  for d = 7, 9 do set(lx - d, 33, "#fbe6a8") set(lx + d, 33, "#fbe6a8") end
end

---------------------------------------------------------------- write
local c = HP.canvas { w = W, h = H, scale = 1, name = NAME }
for y = 0, H - 1 do for x = 0, W - 1 do c:px(x, y, buf[y * W + x] or "#e8cc98") end end
c:finish { outline = false }
HP.assertClean(c)
c:save { aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { "green", "The Pohutukawa Green", 190, 112, 290, 216 },
  { "tea", "The Flat White", 90, 50, 164, 121 },
  { "board", "Notice Board", 19, 36, 78, 126 },
  { "library", "Library", 18, 140, 128, 214 },
  { "s1", "Rock Pools", 20, 226, 148, 268 },
  { "s2", "Breaker Beach", 306, 54, 398, 110 },
  { "shops", "Shops", 304, 154, 452, 226 },
  { "wild", "Wild Trail", 410, 36, 461, 142 },
}
local stand = { { 184, 244 }, { 262, 240 }, { 342, 250 }, { 158, 180 }, { 320, 134 }, { 160, 134 } }
local parts = {}
for _, s in ipairs(spots) do
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], floor((s[3] + s[5]) / 2), floor((s[4] + s[6]) / 2), s[3], s[4], s[5], s[6])
end
local sp = {}
for _, s in ipairs(stand) do sp[#sp + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":104,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', table.concat(parts, ","), table.concat(sp, ",")))
f:close()
print("ok " .. NAME)
