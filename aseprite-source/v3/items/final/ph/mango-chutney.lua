-- mango-chutney (ph, Opus final pass, replaces the Sonnet draft). A slim glass jar of chunky mango chutney: amber
-- preserve lit as a cylinder, gold mango cubes with lit corners, dark mustard seeds, chilli flecks and raisins; glass
-- read from a pale back-wall headspace, a thick pale base, a bright vertical streak with a pale core and a cool right
-- edge. Teal cloth cap with a diagonal weave and fold lines, pinked hem, gathered by twisted twine tied in a bow.
-- Ground shadow under the jar. quirk: one sticky drip has run out from under the cloth down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("mango-chutney")
local CUTS = A.CUTS

local CH = { "#4e1a1e", "#7e2e22", "#ae4e28", "#d4722c", "#eb9a3c", "#f8c45e" }
local CUBE = { "#a85a1e", "#e09a2a", "#f7c240", "#ffe486" }
local CL = { "#1a3448", "#24505e", "#2f6e74", "#40908a", "#62b29c", "#9ad6b6" }
local TW = { "#4e3220", "#80583a", "#b48850", "#dcb87a" }

c:groundShadow(32, 55, 15, 2)

-- jar: glass body (x 21..43), neck under the cloth
local X0, X1 = 21, 43
local jar = c:rrect(X0, 24, X1, 54, 5)
local nrm = {}
jar:each(function(x, y)
  local t = max(-0.95, min(0.95, ((x - X0) / (X1 - X0)) * 2 - 1))
  local ty = (y > 50) and (y - 50) * 0.12 or 0
  nrm[K(x, y)] = { A.norm(t, ty, sqrt(1 - t * t)) }
end)
local v = X.light(nrm, { amb = 0.1, wrap = 0.3 })
local function ti(k, b) local i = 1 for j, t in ipairs(CUTS) do if v[k] >= t then i = j + 1 end end return max(1, min(6, i + (b or 0))) end

local jtok = { r = { name = "jar" } }
local inner = jar:shrink(1)
local FILL = 33
-- headspace: pale glass showing the back wall
jar:each(function(x, y) local k = K(x, y)
  if y < FILL then c:put(x, y, (x < 27) and "#e2f4ec" or (x > 38 and "#8cbcb6" or "#bfe2d8"), jtok)
  else c:put(x, y, CH[ti(k)], jtok) end
end)
-- meniscus: lit top line of the preserve, dark lip under the glass shoulder
for x = X0 + 1, X1 - 1 do local k = K(x, FILL) c:put(x, FILL, CH[min(6, ti(k) + 1)], jtok) end
-- chunks: mango cubes, seeds, chilli, raisins (deterministic scatter)
local taken = {}
for gy = FILL + 2, 50, 3 do for gx = X0 + 2, X1 - 3, 3 do
  local h = X.hash(gx, gy, 5)
  local ox, oy = floor(X.hash(gx, gy, 6) * 2), floor(X.hash(gx, gy, 7) * 2)
  local x, y = gx + ox, gy + oy
  if inner:has(x, y) and inner:has(x + 1, y + 1) then
    local k = K(x, y) local i = ti(k)
    if h < 0.42 then -- mango cube 2x2, lit corner, shadow corner, AO below
      local d = (i >= 4) and 0 or -1
      c:put(x, y, CUBE[min(4, 4 + d)], jtok) c:put(x + 1, y, CUBE[3 + d], jtok)
      c:put(x, y + 1, CUBE[3 + d], jtok) c:put(x + 1, y + 1, CUBE[2 + d], jtok)
      if inner:has(x + 1, y + 2) then c:put(x + 1, y + 2, CH[max(1, ti(K(x + 1, y + 2)) - 2)], jtok) end
    elseif h < 0.62 then c:put(x, y, "#3a1a1c", jtok) c:put(x + 1, y + 1, "#2e1a1e", jtok)
    elseif h < 0.74 then c:put(x, y, "#d2302a", jtok) c:put(x + 1, y, "#9e2228", jtok)
    elseif h < 0.86 then c:put(x, y, "#4a1e3a", jtok) c:put(x + 1, y, "#6a2c4c", jtok) c:put(x, y + 1, "#36162c", jtok)
    end
  end
end end
-- glass: cool edges, thick pale base, bright streak with a pale core
jar:edge():each(function(x, y)
  if x <= X0 + 1 then c:put(x, y, y < FILL and "#f2fbf4" or "#f6c47c", jtok)
  elseif x >= X1 - 1 then c:put(x, y, y < FILL and "#5e8e8e" or "#5a3240", jtok)
  elseif y >= 54 then c:put(x, y, "#7fb2ac", jtok) end
end)
for x = X0 + 2, X1 - 2 do c:put(x, 53, (x < 30) and "#d8f0e4" or "#9ccac0", jtok) end
for x = X0 + 4, X1 - 4 do c:put(x, 52, CH[1], jtok) end
for y = FILL + 1, 50 do c:put(X0 + 2, y, "#fff4d6", jtok) if y < 47 then c:put(X0 + 3, y, "#ffd9a0", jtok) end end
for y = 36, 40 do c:put(X1 - 3, y, "#f4b878", jtok) end
c:put(X0 + 2, 29, "#fff9ec", jtok) c:put(X0 + 2, 30, "#fff9ec", jtok)

-- cloth cap: dome over the lid, gathered at the neck, flared pinked skirt
local dome = c:ellipse(32, 18, 11, 6) dome:clip(c:rect(0, 11, 63, 21))
local waist = c:rect(23, 20, 41, 22)
local skirt = c:poly({ { 23, 22 }, { 41, 22 }, { 47, 29 }, { 17, 29 } })
local cloth = dome:copy():add(waist):add(skirt)
local function hemY(x) return 27 + abs((x % 4) - 2) end
local cut = {}
cloth:each(function(x, y) if y > hemY(x) then cut[#cut + 1] = K(x, y) end end)
for _, k in ipairs(cut) do cloth.s[k] = nil end
local cn = X.pillow(cloth, 3)
-- the waist pinches in: tilt normals of the skirt downward-out
cloth:each(function(x, y) local k = K(x, y) if y >= 23 then local nn = cn[k] cn[k] = { A.norm(nn[1] * 1.2, nn[2] + 0.35, nn[3]) } end end)
local ctok = { r = { name = "cloth" } }
local cb = {}
-- ambient under the twine
for x = 20, 44 do cb[K(x, 23)] = -1 cb[K(x, 19)] = -1 end
local cidx = A.shade(c, cloth, cn, CL, { amb = 0.08, wrap = 0.28, bias = cb, tok = ctok })
cloth:each(function(x, y) local k = K(x, y) local i = cidx[k]
  if (x + y) % 3 == 0 and i > 1 then c:put(x, y, CL[i - 1], ctok) end           -- diagonal weave
end)
for _, fx in ipairs{ { 26, -1 }, { 31, 1 }, { 37, -1 } } do                       -- fold lines down the skirt
  for y = 24, 28 do local x = fx[1] + floor((y - 24) * (fx[1] - 32) / 10 + 0.5)
    if cloth:has(x, y) then local i = cidx[K(x, y)] c:put(x, y, CL[max(1, i - 2)], ctok)
      if cloth:has(x - 1, y) then c:put(x - 1, y, CL[min(6, cidx[K(x - 1, y)] + 1)], ctok) end end end
end
for x = 26, 34 do if cloth:has(x, 13) then c:put(x, 13, CL[6], ctok) end end      -- lit crown of the dome
-- twine: two twisted rows round the waist, bow on the right
local ttok = { r = { name = "twine" } }
for x = 22, 42 do
  c:put(x, 21, ((x % 3) == 0) and TW[2] or TW[(x < 32) and 4 or 3], ttok)
  c:put(x, 22, ((x % 3) == 1) and TW[1] or TW[(x < 32) and 3 or 2], ttok)
end
local bow = { { 43, 20, 3 }, { 44, 19, 4 }, { 45, 19, 3 }, { 46, 20, 2 }, { 45, 21, 2 }, { 44, 21, 1 }, { 43, 21, 2 }, { 43, 22, 2 },
  { 44, 23, 3 }, { 45, 23, 2 }, { 46, 24, 2 }, { 45, 24, 1 }, { 44, 24, 1 },
  { 44, 25, 3 }, { 45, 26, 2 }, { 45, 27, 3 }, { 46, 28, 2 }, { 43, 25, 2 }, { 42, 26, 3 }, { 42, 27, 2 } }
for _, p in ipairs(bow) do c:put(p[1], p[2], TW[p[3]], ttok) end
c:put(42, 22, TW[1], ttok)

-- quirk: a drip of chutney running from under the hem down the glass
local dtok = { r = { name = "drip" } }
local drip = { { 29, 29, 3 }, { 30, 29, 2 }, { 29, 30, 4 }, { 30, 30, 2 }, { 29, 31, 4 }, { 30, 31, 3 }, { 29, 32, 4 }, { 30, 32, 3 },
  { 28, 33, 3 }, { 29, 33, 6 }, { 30, 33, 4 }, { 31, 33, 2 }, { 28, 34, 2 }, { 29, 34, 4 }, { 30, 34, 3 }, { 31, 34, 1 }, { 29, 35, 2 }, { 30, 35, 1 } }
for _, p in ipairs(drip) do c:put(p[1], p[2], CH[p[3]], dtok) end
c:put(29, 33, "#fff0c0", dtok)

A.save(c, "mango-chutney")
