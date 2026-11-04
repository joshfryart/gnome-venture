-- ico-spider (final, Opus). A garden spider hanging head-down on a twisted silk line: glossy ember abdomen (sphere
-- light, cream cross-and-bar markings that follow the shading, specular glint, cool reflected light lower-right),
-- a smaller plum cephalothorax below with a face (two pill eyes + two tiny side eyes, cream fangs), and eight slim
-- jointed legs (cylinder light, gold knee bands, AO where they leave the body).
-- quirk: one front foot wears a tiny striped sock.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-spider")
local PL = { "#5a1a36", "#922a3c", "#c84034", "#ea6634", "#ff9850", "#ffcd88" }
local HD = { "#1d1430", "#2e2048", "#45306a", "#5f4690", "#8468b8", "#ae96dc" }
local LG = { "#1c1428", "#2c2042", "#40305e", "#5a467e", "#7a64a0" }
local GD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SILK = { "#c8c4d8", "#fff4d6" }
local BOUNCE = "#a8508e"
local MK = { "#d98a5a", "#ffd9a0", "#fff4d6" }
local ltok, atok, htok, gtok = { r = { name = "leg" } }, { r = { name = "abd" } }, { r = { name = "head" } }, { r = { name = "gold" } }

local AX, AY = 32, 25      -- abdomen
local HX, HY = 32, 42      -- cephalothorax
local abd = c:ellipse(AX, AY, 9.5, 10.5)
local head = c:ellipse(HX, HY, 6.5, 5.5)

-- silk line with twist (top, into the spinnerets)
for y = 7, AY - 10 do c:put(AX, y, (y % 3 == 0) and SILK[1] or SILK[2], ltok) end

-- legs: hip -> knee -> foot on the left, mirrored on the right
local legsL = {
  { { 27, 45 }, { 18, 48 }, { 14, 57 } },
  { { 26, 43 }, { 15, 41 }, { 9, 50 } },
  { { 26, 40 }, { 15, 31 }, { 8, 36 } },
  { { 27, 38 }, { 19, 20 }, { 11, 14 } },
}
local legs = {}
for _, L in ipairs(legsL) do
  legs[#legs + 1] = L
  legs[#legs + 1] = { { 64 - L[1][1], L[1][2] }, { 64 - L[2][1], L[2][2] }, { 64 - L[3][1], L[3][2] } }
end
local body = abd:copy():add(head)
local knees = {}
for li, L in ipairs(legs) do
  for s = 1, 2 do
    local a, b = L[s], L[s + 1]
    local wf = s == 1 and function() return 1.35 end or function(t) return 1.3 - t * 0.35 end
    local m, n, T, S = X.cyl(a[1], a[2], b[1], b[2], wf)
    m:cut(body)
    local bias = {}
    if s == 1 then X.ao(bias, m, body, 2, -1) end
    A.shade(c, m, n, LG, { amb = 0.1, wrap = 0.3, bias = bias, tok = ltok, cuts = { 0.25, 0.45, 0.65, 0.82 } })
    -- dark foot tip
    if s == 2 then m:each(function(x, y) if T[K(x, y)] > 0.85 then c:put(x, y, LG[1], ltok) end end) end
  end
  knees[#knees + 1] = L[2]
end
-- gold knee bands
for _, kp in ipairs(knees) do
  local km = c:ellipse(kp[1], kp[2], 1.5, 1.5)
  local kn = X.sphere(kp[1], kp[2], 1.6, km)
  A.shade(c, km, kn, GD, { amb = 0.1, wrap = 0.3, tok = gtok, cuts = { 0.3, 0.55, 0.8 } })
end

-- abdomen: glossy sphere
local an = X.sphere(AX - 0.5, AY - 0.5, 10.5, abd)
local ab = {}
X.ao(ab, abd, head, 2, -1)
local aidx = A.shade(c, abd, an, PL, { amb = 0.06, wrap = 0.25, bias = ab, tok = atok })
-- markings: a cross on the back + two short bars below, tinted by the underlying light
local mark = HP.mask()
for d = -3, 3 do mark:set(AX + d, AY - 3) mark:set(AX, AY - 3 + d) end
mark:set(AX - 1, AY - 4) mark:set(AX + 1, AY - 2)
for i, yy in ipairs{ AY + 3, AY + 6 } do
  local o = 4 - i
  for d = 0, 1 do mark:set(AX - o - d, yy) mark:set(AX + o + d, yy) end
end
mark:set(AX - 6, AY - 1) mark:set(AX + 6, AY - 1) mark:set(AX - 5, AY - 1) mark:set(AX + 5, AY - 1)
mark:each(function(x, y) local i = aidx[K(x, y)] or 3
  c:put(x, y, i >= 5 and MK[3] or (i >= 3 and MK[2] or MK[1]), atok) end)
-- cool reflected light + glint
local rim = X.rim(an)
abd:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and x > AX + 2 and y > AY - 2 and y < AY + 7 and not head:grow(1):has(x, y) then c:put(x, y, BOUNCE, atok) end end)
c:put(AX - 5, AY - 7, A.CREAM, atok) c:put(AX - 4, AY - 7, PL[6], atok) c:put(AX - 6, AY - 6, PL[6], atok)
-- spinnerets: small dark nub where the silk enters
c:put(AX, AY - 10, PL[2], atok) c:put(AX - 1, AY - 10, PL[3], atok)

-- cephalothorax (in front, overlaps the abdomen's lower rim)
local hn = X.sphere(HX - 0.5, HY - 1, 7, head)
local hidx = A.shade(c, head, hn, HD, { amb = 0.08, wrap = 0.25, tok = htok })
-- dark seam row on the abdomen just above the head
head:grow(1):cut(head):each(function(x, y) if abd:has(x, y) then c:put(x, y, PL[1], atok) end end)
-- face: two pill eyes, two tiny side eyes, fangs
c:eyeSmall(HX - 4, HY - 1) c:eyeSmall(HX + 2, HY - 1)
c:px(HX - 5, HY - 3, A.INK) c:px(HX + 5, HY - 3, A.INK)
c:px(HX - 1, HY + 4, A.CREAM) c:px(HX + 1, HY + 4, A.CREAM)
c:px(HX - 1, HY + 5, "#e2cba6") c:px(HX + 1, HY + 5, "#e2cba6")
c:px(HX, HY + 3, HD[1])
c:px(HX - 3, HY - 4, HD[6]) c:px(HX - 2, HY - 4, HD[6])

-- quirk: a tiny striped sock on the right front foot
do
  local fx, fy = 64 - 14, 57
  A.map(c, {
    "abc",
    "ddd",
    "eef",
    "ddd",
    "dddf",
  }, fx - 1, fy - 4, { a = "#fff4d6", b = "#fff4d6", c = "#e2cba6", d = "#e8493b", e = "#fff4d6", f = "#b52e3f" }, ltok)
end
A.save(c, "ico-spider")
