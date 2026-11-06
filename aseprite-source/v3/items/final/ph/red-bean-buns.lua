-- red-bean-buns (final D12_0, Sonnet high). A round bamboo steamer tier (vertical slats, woven hoops, thick rim) with two
-- fluffy steamed buns sitting in it: the left one whole with a red food-colour dot, the right one bitten at the upper
-- right to show glossy dark red-bean paste inside a torn crumb rim. quirk: the bite, with two steam curls rising from it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("red-bean-buns")
local BAM = { "#46301a", "#6e4a22", "#9a6c30", "#c8964a", "#e6bc6a", "#f8e098" }
local BUN = { "#a47c76", "#cda798", "#ebcfb8", "#f9e6d0", "#fff1de", "#fff9ee" }
local CRUMB = { "#c89a7a", "#e4bc96", "#f4d8b0", "#fdeccb", "#fff4d8", "#fffae8" }
local PASTE = { "#2a0e1c", "#4a1428", "#6e1e36", "#913048", "#b84e5a", "#e08486" }
local RED = { "#7c1f2e", "#c8323c", "#ee5a48", "#ff9a78" }
local INTERIOR = "#2c1a14"

c:groundShadow(32, 53, 23, 2.4)

-- ---------------------------------------------------------------- steamer wall (vertical cylinder)
local CX, RX, RY, TOPY, BOTY = 32, 23.5, 6.2, 35, 46
local wall = c:rect(CX - 23, TOPY, CX + 23, BOTY):add(c:ellipse(CX, BOTY, RX, RY))
local function nx(x) return A.clamp((x - CX) / (RX + 0.6), -0.97, 0.97) end
local wn = {}
wall:each(function(x, y) local t = nx(x) wn[K(x, y)] = { t, 0.1, sqrt(1 - t * t) } end)
local wv = X.light(wn, { amb = 0.1, wrap = 0.32 })
local widx = X.tone(c, wall, wv, BAM, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
wall:each(function(x, y) local k = K(x, y)
  local i = widx[k]
  local col = (x - (CX - 23)) % 5
  -- slats: dark gap, lit left edge, shaded right edge
  if col == 0 then i = i - 2 elseif col == 1 then i = i + 1 elseif col == 4 then i = i - 1 end
  -- hoops (woven bands) near the top and bottom: diagonal weave
  local hoopT = y >= TOPY + 4 and y <= TOPY + 6
  local hoopB = y >= BOTY - 1 and y <= BOTY + 1
  if hoopT or hoopB then
    local w = (x + y * 2) % 4
    i = widx[k] + (w < 2 and 0 or -1)
    if (hoopT and y == TOPY + 4) or (hoopB and y == BOTY - 1) then i = i + 1 end
    if (hoopT and y == TOPY + 6) or (hoopB and y == BOTY + 1) then i = i - 1 end
  end
  -- slats curve away under the bottom lip: darker toward the lower curve
  if y > BOTY + 1 then i = i - 1 end
  if y > BOTY + 3 then i = i - 1 end
  c:px(x, y, BAM[A.clamp(i, 1, 6)])
end)

-- ---------------------------------------------------------------- rim ring (outer thick lip) + dark interior
local outer = c:ellipse(CX, TOPY, RX + 0.5, RY + 0.4)
local inner = c:ellipse(CX, TOPY, RX - 2.6, RY - 2.4)
local ring = outer:copy():cut(inner)
local function paintRing(filter)
  ring:each(function(x, y)
    if not filter(x, y) then return end
    local t = nx(x)
    -- top surface of the rim faces up and out: lit upper-left, shaded right; inner wall of the lip darker
    local ang = (y - TOPY) / (RY + 0.4)
    local i = 4 - floor(t * 1.8 + 0.5)
    if ang < -0.35 then i = i + 1 end          -- back lip catches more light
    if ang > 0.5 then i = i - 1 end            -- front lower edge turns away
    if inner:copy():grow(1):has(x, y) then i = i - 1 end   -- inside lip shadow
    if outer:copy():shrink(1):has(x, y) == false then i = i + (t < 0 and 1 or -1) end
    c:px(x, y, BAM[A.clamp(i, 1, 6)])
  end)
end
paintRing(function() return true end)
c:fillMask(inner, INTERIOR)
-- a faint basket mat texture inside
inner:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, "#3a2418") end end)

-- ---------------------------------------------------------------- buns (inside, clipped by the front lip)
local clipTo = outer:copy():add(c:rect(0, 0, 63, TOPY))
-- bun A (whole)
local ma, na = A.oval(22, 29, 11, 9.5, 0, 0.95)
-- bun B (bitten), in front of A
local mb, nb = A.oval(42, 28, 11.5, 10.2, 0, 0.95)
ma:clip(clipTo) mb:clip(clipTo)
local bias = {}
A.cast(bias, ma, mb, -1, 0, -1) A.cast(bias, ma, mb, -2, 0, -1)
local aidx = A.toneN(c, ma, na, BUN, { bias = bias, amb = 0.12, wrap = 0.36, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- steamed-dough pores + a cool bounce along the lower-right
ma:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 5)
  if h < 0.06 and aidx[k] >= 3 then c:px(x, y, BUN[aidx[k] - 1]) end
  if h > 0.97 and aidx[k] >= 2 then c:px(x, y, BUN[min(6, aidx[k] + 1)]) end
end)
-- red food-colour dot on top of bun A
c:fillMask(c:rect(21, 20, 23, 21), RED[3]) c:px(21, 20, RED[4]) c:px(22, 19, RED[3]) c:px(22, 22, RED[2])
c:px(23, 21, RED[2]) c:px(20, 21, RED[2]) c:px(24, 20, RED[2]) c:px(21, 19, RED[2]) c:px(23, 19, RED[2])
c:px(21, 20, RED[4])
-- soft pinch crease on bun A's left shoulder
for _, q in ipairs{ { 14, 27 }, { 14, 28 }, { 15, 29 } } do c:px(q[1], q[2], BUN[2]) end

-- bun B body
local bite = c:ellipse(51.5, 21, 4.2, 4.0):add(c:ellipse(54.5, 26, 3.4, 3.4)):add(c:ellipse(47.5, 18, 3.3, 3.2)):add(c:ellipse(50, 24, 3.4, 3.2))
local removed = bite:copy():clip(mb)
local bodyB = mb:copy():cut(bite)
local bbias = {}
A.cast(bbias, mb, ma, 0, 0, 0)
local bidx = A.toneN(c, mb, nb, BUN, { amb = 0.12, wrap = 0.36, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
mb:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 9)
  if h < 0.06 and bidx[k] >= 3 then c:px(x, y, BUN[bidx[k] - 1]) end
  if h > 0.97 and bidx[k] >= 2 then c:px(x, y, BUN[min(6, bidx[k] + 1)]) end
end)
-- the bite: wipe pixels, then show crumb + paste
removed:each(function(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end)
local pasteM = c:ellipse(46.8, 23.8, 5.2, 3.8):clip(mb):cut(bite)
local crumb = HP.mask()
bodyB:each(function(x, y)
  -- torn crumb rim: pixels within ~2 px of the bite edge
  for dy = -2, 2 do for dx = -2, 2 do
    if dx * dx + dy * dy <= 5 and bite:has(x + dx, y + dy) then crumb:set(x, y) end
  end end
end)
crumb:cut(pasteM)
-- crumb: pale, concave so the light comes from the lower-right side of the wall
crumb:each(function(x, y)
  local lx = (x - 51) * -0.12 + (y - 23) * -0.12
  local i = 4 + floor(A.clamp(lx, -1, 1.2) + 0.5)
  if X.hash(x, y, 3) < 0.25 then i = i - 1 end
  c:px(x, y, CRUMB[A.clamp(i, 1, 6)])
end)
-- red-bean paste (glossy, with bean-skin flecks)
local pn = X.pillow(pasteM, 2.4)
local pidx = A.toneN(c, pasteM, pn, PASTE, { amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.4, 0.58, 0.74, 0.9 } })
pasteM:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 13)
  if h < 0.1 then c:px(x, y, PASTE[A.clamp(pidx[k] + 1, 1, 6)]) end
  if h > 0.92 then c:px(x, y, PASTE[A.clamp(pidx[k] - 1, 1, 6)]) end
end)
c:px(44, 22, PASTE[6]) c:px(45, 22, PASTE[5]) c:px(44, 23, PASTE[5]) c:px(46, 25, PASTE[1])
-- paste meets crumb: ambient dark row
A.touch(pasteM, crumb):each(function(x, y) c:px(x, y, PASTE[1]) end)
-- bun B drop shadow onto bun A
bodyB:copy():shift(-1, 0):cut(mb):clip(ma):each(function(x, y) c:px(x, y, BUN[1]) end)

-- ---------------------------------------------------------------- front lip over the bun bottoms
paintRing(function(x, y) return y >= TOPY + 1 end)
-- contact shadow of the buns on the back lip is hidden; add a shadow row under the front lip
wall:each(function(x, y) if y == TOPY + RY + 3 and outer:has(x, y - 3) then end end)

-- ---------------------------------------------------------------- steam curls
local S1, S2 = "#eaf8ff", "#b6dcf0"
A.pline(c, { { 50, 14 }, { 51, 12 }, { 49, 10 }, { 50, 8 }, { 52, 6 } }, S1)
A.pline(c, { { 54, 17 }, { 55, 15 }, { 54, 13 }, { 55, 11 } }, S2)
c:px(49, 10, S2) c:px(51, 12, S2)
-- a bright catch-light on bun A and a sparkle on the paste
c:px(17, 22, BUN[6]) c:px(18, 21, BUN[6]) c:px(17, 21, BUN[6])
A.save(c, "red-bean-buns")
