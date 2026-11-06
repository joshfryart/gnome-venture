-- papaya-chutney (final, Opus). A slim swing-top glass jar of chunky papaya chutney. Glass: vertical-cylinder light,
-- pale cool core, bright shoulder rim, long specular streak left, cool reflected edge right, thick pale base lens.
-- Chutney shows through as 6-tone coral-orange with golden fruit cubes, dark AO round each chunk and black papaya seed
-- flecks; an AO row where it meets the glass and a lumpy lit surface under the headspace. Domed glass lid, an orange
-- rubber seal with a pull tab, and a bevelled steel wire bail with a lever clasp (bright edge, dark hinge eye).
-- A paper label carries a drawn papaya half. Ground shadow under the jar.
-- quirk: a drip of chutney has squeezed out past the seal and is sliding down the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "papaya-chutney"
local c = A.new(NAME)

local GLASS = { "#3d5677", "#5b83a3", "#88b3c9", "#b3d9de", "#d7efe9", "#f0fbf4" }
local CHUT  = { "#5e1f2e", "#8f2e2e", "#c84a2c", "#ea6f32", "#f99a48", "#ffc274" }
local CUBE  = { "#b5602a", "#e89a3a", "#f8c35a", "#ffe28e" }
local SEAL  = { "#7a2a2a", "#c24a2a", "#ec7438", "#ffa866" }
local STEEL = { "#3a3b55", "#5d5f7a", "#8c8ea4", "#babbc9", "#e2e1e9", "#fbf8f2" }
local PAPER = { "#c9a87a", "#e6cc9e", "#f6e6c2", "#fff4d6" }
local SEEDK = "#2e1a22"
local gtok, ctok, stok, wtok, ptok = { r = { name = "glass" } }, { r = { name = "chutney" } }, { r = { name = "seal" } }, { r = { name = "wire" } }, { r = { name = "label" } }

c:groundShadow(32, 56, 13, 2)

local JX0, JX1 = 22, 42
local body = c:rrect(JX0, 27, JX1, 55, 4)
body:add(c:rrect(JX0 + 1, 24, JX1 - 1, 30, 3))       -- shoulder
local function cylN(m, x0, x1, ytop, ybot)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    local ny = 0
    if ybot and y > ybot then ny = (y - ybot) * 0.35 end
    if ytop and y < ytop then ny = -(ytop - y) * 0.3 end
    n[K(x, y)] = { A.norm(t, ny, sqrt(1 - t * t)) }
  end)
  return n
end
local gn = cylN(body, JX0, JX1, 27, 53)

-- chutney fill
local fill = c:rrect(JX0 + 2, 30, JX1 - 2, 53, 2)
local glass = body:copy():cut(fill)
X.tone(c, glass, X.light(gn, { amb = 0.2, wrap = 0.35 }), GLASS, { cuts = { 0.12, 0.25, 0.42, 0.62, 0.84 }, tok = gtok })
-- golden fruit cubes (2x2 / 3x2) scattered, each with a dark AO ring in the chutney
local cubes = { { 26, 34, 3, 2 }, { 33, 33, 2, 2 }, { 37, 38, 3, 2 }, { 25, 41, 2, 2 }, { 30, 39, 2, 2 },
  { 34, 44, 3, 2 }, { 27, 48, 2, 2 }, { 37, 49, 2, 2 }, { 31, 51, 2, 1 } }
local cubeM = HP.mask()
for _, q in ipairs(cubes) do cubeM:add(c:rect(q[1], q[2], q[1] + q[3] - 1, q[2] + q[4] - 1)) end
cubeM:clip(fill)
local cb = {}
X.ao(cb, fill, glass, 1, -1)
X.ao(cb, fill, cubeM, 1, -1)
fill:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 11)
  if h > 0.9 then cb[k] = (cb[k] or 0) + 1 elseif h < 0.08 then cb[k] = (cb[k] or 0) - 1 end end)
local fv = X.light(gn, { amb = 0.05, wrap = 0.2 })
local fm = fill:copy():cut(cubeM)
X.tone(c, fm, fv, CHUT, { cuts = { 0.12, 0.28, 0.46, 0.64, 0.84 }, bias = cb, tok = ctok })
for _, q in ipairs(cubes) do
  for yy = q[2], q[2] + q[4] - 1 do for xx = q[1], q[1] + q[3] - 1 do
    if cubeM:has(xx, yy) then
      local tone = (yy == q[2] and xx == q[1]) and 4 or ((yy == q[2] or xx == q[1]) and 3 or 2)
      if xx > 38 or xx == q[1] + q[3] - 1 and yy == q[2] + q[4] - 1 then tone = max(1, tone - 1) end
      c:put(xx, yy, CUBE[tone], ctok)
    end
  end end
end
-- black papaya seed flecks (with a 1px glint on two)
for _, p in ipairs{ { 29, 35 }, { 36, 35 }, { 23, 38 }, { 33, 41 }, { 28, 44 }, { 38, 45 }, { 24, 50 }, { 34, 50 }, { 31, 47 }, { 39, 41 } } do
  if fill:has(p[1], p[2]) and not cubeM:has(p[1], p[2]) then c:put(p[1], p[2], SEEDK, ctok) end
end
c:put(29, 34, CHUT[6], ctok)
-- lumpy surface line under the headspace
for x = JX0 + 2, JX1 - 2 do
  local lump = (x % 5 == 1 or x % 7 == 3)
  c:put(x, 30, x < 33 and CHUT[6] or CHUT[5], ctok)
  if lump then c:put(x, 29, x < 33 and CHUT[5] or CHUT[4], ctok) end
end

-- glass streaks + reflected edge + base lens + shoulder rim
for y = 32, 51 do c:put(JX0 + 2, y, GLASS[6], gtok) if y > 34 and y < 47 then c:put(JX0 + 3, y, GLASS[5], gtok) end end
for y = 38, 41 do c:put(JX0 + 5, y, GLASS[5], gtok) end
for y = 31, 53 do c:put(JX1 - 1, y, GLASS[4], gtok) end
for x = JX0 + 3, JX1 - 3 do c:put(x, 54, GLASS[3], gtok) end
for x = JX0 + 4, JX0 + 9 do c:put(x, 54, GLASS[5], gtok) end
for x = JX0 + 3, JX0 + 7 do c:put(x, 25, GLASS[6], gtok) end

-- label: paper band with a drawn papaya half
local lab = c:rect(JX0 + 4, 39, JX1 - 4, 49)
local ln = cylN(lab, JX0, JX1)
X.tone(c, lab, X.light(ln, { amb = 0.3, wrap = 0.4 }), PAPER, { cuts = { 0.3, 0.55, 0.78 }, tok = ptok })
for x = JX0 + 4, JX1 - 4 do c:put(x, 39, PAPER[4], ptok) c:put(x, 49, PAPER[1], ptok) end
local pm = c:ellipse(32, 44, 3, 4)
pm:each(function(x, y) local e = ((x - 32) / 3.5) ^ 2 + ((y - 44) / 4.5) ^ 2
  c:put(x, y, e > 0.6 and (x > 32 and "#5a9a3e" or "#8cc84e") or (e > 0.3 and CHUT[4] or SEEDK), ptok) end)
c:put(31, 42, CHUT[5], ptok) c:put(32, 44, CHUT[2], ptok)

-- seal: orange rubber ring with a pull tab on the left
local seal = c:rect(JX0, 22, JX1, 23)
for x = JX0, JX1 do c:put(x, 22, x < 30 and SEAL[4] or SEAL[3], stok) c:put(x, 23, SEAL[2], stok) end
for _, q in ipairs{ { JX0 - 1, 22, 3 }, { JX0 - 2, 22, 3 }, { JX0 - 3, 22, 4 }, { JX0 - 1, 23, 2 }, { JX0 - 2, 23, 1 }, { JX0 - 3, 23, 2 }, { JX0 - 4, 22, 3 }, { JX0 - 4, 23, 2 } } do
  c:put(q[1], q[2], SEAL[q[3]], stok) end
c:put(JX0 - 3, 22, "#2b1c26", stok) -- tab hole
-- domed glass lid
local lid = c:ellipse(32, 21, 10, 5):clip(c:rect(0, 0, 63, 21))
lid:add(c:rect(JX0 + 1, 20, JX1 - 1, 21))
local lv = X.light(X.pillow(lid, 3), { amb = 0.25, wrap = 0.35 })
X.tone(c, lid, lv, GLASS, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, tok = gtok })
for x = 25, 29 do c:put(x, 17, GLASS[6], gtok) end
c:put(26, 18, GLASS[6], gtok)
-- AO under the lid on the jar shoulder
for x = JX0 + 1, JX1 - 1 do c:put(x, 24, GLASS[x < 32 and 2 or 1], gtok) end

-- steel wire bail: loop over the lid, down each side to the hinge, lever clasp on the right
local wire = {}
for x = 25, 39 do wire[#wire + 1] = { x, 15 } end
for _, p in ipairs{ { 24, 16 }, { 23, 17 }, { 22, 18 }, { 21, 19 }, { 21, 20 }, { 21, 21 } } do wire[#wire + 1] = p end
for _, p in ipairs{ { 40, 16 }, { 41, 17 }, { 42, 18 }, { 43, 19 }, { 43, 20 }, { 43, 21 } } do wire[#wire + 1] = p end
for _, p in ipairs(wire) do
  local lit = p[1] < 33 and p[2] <= 16
  c:put(p[1], p[2], lit and STEEL[5] or (p[1] > 40 and STEEL[2] or STEEL[3]), wtok)
end
c:put(28, 15, STEEL[6], wtok)
-- hinge band around the neck under the seal
for x = JX0 - 1, JX1 + 1 do c:put(x, 25, x < 30 and STEEL[4] or (x > 39 and STEEL[2] or STEEL[3]), wtok) c:put(x, 26, STEEL[x > 38 and 1 or 2], wtok) end
-- lever clasp: short bevelled arm on the right with a dark pivot eye
local lev = { { 44, 22, 4 }, { 44, 23, 3 }, { 44, 24, 3 }, { 44, 25, 2 }, { 45, 23, 3 }, { 45, 24, 2 }, { 45, 25, 2 }, { 45, 26, 1 },
  { 44, 26, 2 }, { 44, 27, 2 }, { 45, 27, 1 }, { 44, 28, 3 }, { 45, 28, 1 } }
for _, q in ipairs(lev) do c:put(q[1], q[2], STEEL[q[3]], wtok) end
c:put(44, 22, STEEL[6], wtok)
c:put(44, 25, "#2b1c26", wtok)

-- quirk: chutney drip squeezed past the seal, sliding down the glass on the right
local dtok = { r = { name = "drip" } }
for _, q in ipairs{ { 38, 24, 4 }, { 38, 25, 4 }, { 39, 25, 3 }, { 38, 26, 4 }, { 39, 26, 2 }, { 38, 27, 4 }, { 39, 27, 3 },
  { 38, 28, 3 }, { 39, 28, 2 }, { 38, 29, 4 }, { 39, 29, 3 }, { 38, 30, 4 }, { 39, 30, 2 }, { 39, 31, 3 }, { 38, 31, 3 }, { 38, 32, 2 }, { 39, 32, 1 } } do
  c:put(q[1], q[2], CHUT[q[3] + 1], dtok) end
c:put(38, 30, CHUT[6], dtok)

A.save(c, NAME)
