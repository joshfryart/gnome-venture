-- ico-fox (final, Opus): a slim red fox sitting upright, head turned a little to the viewer's left, tall ears,
-- slender front legs in dark socks, a bushy brush curled round its right side with a cream tip.
-- Material: per-pixel round light on fur (6-tone orange, violet-brown shade), cream bib and muzzle, fur tufts on the
-- cheek ruff, bib and tail edge, strand lines on the brush, AO under the chin, behind the haunch and at the tail root.
-- Face: 2x3 ink eye pills with glints, a distinct snout with an ink nose tip + cream glint, petal cheeks.
-- quirk: a tiny daisy is tucked behind its right ear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor, sin, pi = math.sqrt, math.max, math.min, math.abs, math.floor, math.sin, math.pi
local c = A.new("ico-fox")
local FOX  = { "#5c1f30", "#8e2f2e", "#c24a2a", "#e86d2b", "#f8973c", "#ffc56e" }
local CRM  = { "#9a7378", "#c79f96", "#e6c9ad", "#f7e4c6", "#fff2dc" }
local SOCK = { "#2e1622", "#4a2230", "#6c3238", "#8d4a44" }
local ft, ct, kt = { r = { name = "fur" } }, { r = { name = "cream" } }, { r = { name = "sock" } }
local FC = { 0.22, 0.38, 0.54, 0.7, 0.86 }

-- brush (behind the body)
local tm, tn, tT, tS, tidx = A.tube(c, { { 34, 52 }, { 50, 55 }, { 56, 42 }, { 48, 30 } },
  function(t) return 2.2 + 3.6 * sin(pi * min(1, 0.15 + t * 0.95)) ^ 0.7 end, FOX, { tok = ft, cuts = FC, amb = 0.05, wrap = 0.2 })
-- tufts on the outer edge of the brush
local tuft = HP.mask()
tm:edge():each(function(x, y) local k = K(x, y)
  if tS[k] > 0.5 and tT[k] > 0.25 and tT[k] < 0.92 and floor(tT[k] * 22) % 3 == 0 then tuft:set(x + 1, y) end end)
tuft:cut(tm) tuft:each(function(x, y) c:put(x, y, FOX[2], ft) end)
tm:each(function(x, y) local k = K(x, y)
  local t, s = tT[k], tS[k]
  if t > 0.86 then c:put(x, y, CRM[min(5, max(2, tidx[k] - 1))], ct)                 -- cream tip
  elseif t > 0.83 then c:put(x, y, FOX[5], ft)
  elseif abs(s - 0.1 - 0.35 * sin(t * 18)) < 0.09 and t > 0.12 then A.step(c, tidx, FOX, x, y, -1, ft)   -- strand line
  end
end)

-- body: slim pear with a neck
local body = c:ellipse(30, 44, 9, 10):add(c:ellipse(30, 36, 7, 7))
local bidx = A.shade(c, body, A.body(body, 29, 40, 12, 4, 0.55), FOX, { cuts = FC, amb = 0.05, wrap = 0.2, tok = ft })
A.sep(c, tm, tidx, FOX, body, -2, ft)                                -- tail root AO
-- haunch
local hm = c:ellipse(36, 47, 5, 7)
local hidx = A.shade(c, hm, A.body(hm, 35, 46, 7, 3, 0.6), FOX, { cuts = FC, amb = 0.05, wrap = 0.2, tok = ft })
A.sep(c, body, bidx, FOX, hm, -2, ft)
-- cream bib with a tufted lower edge
local bib = c:ellipse(28, 39, 5, 8):clip(body)
local bibn = A.body(bib, 27, 37, 8, 3, 0.5)
local cidx = A.shade(c, bib, bibn, CRM, { cuts = { 0.3, 0.5, 0.7, 0.86 }, amb = 0.15, wrap = 0.3, tok = ct })
for _, p in ipairs{ { 25, 47 }, { 27, 48 }, { 29, 48 }, { 31, 47 } } do c:put(p[1], p[2], CRM[3], ct) end
-- slender front legs, dark socks, small paws
local legs = {}
for i, lx in ipairs{ 24, 30 } do
  local lm = c:rect(lx, 45, lx + 3, 54)
  lm:cut(c:rect(lx, 54, lx, 54)) lm:cut(c:rect(lx + 3, 54, lx + 3, 54))
  local n = A.vcyl(lm, lx + 1.5, 2)
  local idx = A.shade(c, lm, n, FOX, { cuts = FC, amb = 0.05, wrap = 0.2, tok = ft })
  lm:each(function(x, y) if y >= 49 then
    local s = (x - lx - 1.5) / 2.5
    c:put(x, y, SOCK[s < -0.5 and 4 or (s < 0.1 and 3 or 2)], kt) end end)
  for x = lx, lx + 3 do c:put(x, 45, FOX[2], ft) end           -- AO under the bib
  c:put(lx + 1, 54, SOCK[1], kt)                               -- toe split
  legs[i] = lm
end
A.sep(c, body, bidx, FOX, legs[1]:copy():add(legs[2]), -1, ft)

-- head
local head = c:ellipse(29, 22, 9.5, 7.5)
head:add(c:poly{ { 18, 23 }, { 15, 29 }, { 22, 28 } }):add(c:poly{ { 40, 23 }, { 43, 29 }, { 36, 28 } })   -- cheek ruff
local earL = c:poly{ { 19, 19 }, { 21, 5 }, { 28, 15 } }
local earR = c:poly{ { 31, 15 }, { 38, 5 }, { 40, 19 } }
local hd = head:copy():add(earL):add(earR)
local hidx2 = A.shade(c, hd, A.body(hd, 28, 20, 11, 3, 0.5), FOX, { cuts = FC, amb = 0.05, wrap = 0.2, tok = ft })
A.sep(c, body, bidx, FOX, hd, -2, ft) A.sep(c, bib, cidx, CRM, hd, -2, ct)       -- shadow under the chin
-- inner ears (dark) with a cream fluff tuft
for _, e in ipairs{ { { 21, 17 }, { 22, 9 }, { 26, 15 } }, { { 33, 15 }, { 37, 9 }, { 38, 17 } } } do
  local im = c:poly(e)
  im:each(function(x, y) c:put(x, y, (x + y) % 5 == 0 and SOCK[3] or SOCK[2], kt) end)
end
c:put(23, 16, CRM[4], ct) c:put(24, 16, CRM[3], ct) c:put(35, 16, CRM[3], ct) c:put(36, 16, CRM[2], ct)
-- cream lower face + muzzle (snout pushed a little to the left)
local face = c:ellipse(28, 26, 7, 3.5):add(c:poly{ { 17, 25 }, { 15, 29 }, { 22, 28 } }):add(c:poly{ { 39, 25 }, { 43, 29 }, { 36, 28 } })
face:clip(head) face:cut(c:rect(0, 0, 63, 23))
A.shade(c, face, A.body(face, 27, 25, 8, 2, 0.5), CRM, { cuts = { 0.3, 0.5, 0.7, 0.86 }, amb = 0.15, wrap = 0.3, tok = ct })
local snout = c:ellipse(27, 25.5, 3.5, 2.5)
local sidx = A.shade(c, snout, A.body(snout, 26, 25, 4, 2, 0.6), CRM, { cuts = { 0.25, 0.45, 0.65, 0.82 }, amb = 0.15, wrap = 0.3, tok = ct })
for x = 25, 30 do A.step(c, sidx, CRM, x, 28, -1, ct) end                        -- dark underside row
-- nose: ink tip with cream glint, mouth
for _, p in ipairs{ { 26, 23 }, { 27, 23 }, { 28, 23 }, { 26, 24 }, { 27, 24 }, { 28, 24 }, { 27, 25 } } do c:put(p[1], p[2], A.INK, kt) end
c:put(26, 23, A.CREAM, kt)
c:put(27, 26, CRM[1], ct) c:put(26, 27, CRM[1], ct) c:put(28, 27, CRM[1], ct)
-- fur tufts on the cheek ruff
c:put(16, 28, CRM[3], ct) c:put(42, 28, CRM[2], ct) c:put(19, 27, CRM[2], ct) c:put(39, 27, CRM[1], ct)
-- eyes + cheeks
c:eyeSmall(22, 18) c:eyeSmall(32, 18)
c:cheek(20, 23) c:cheek(35, 23)
-- brow fur mark (darker tone line above eyes)
for _, p in ipairs{ { 21, 17 }, { 22, 16 }, { 33, 16 }, { 34, 17 } } do A.step(c, hidx2, FOX, p[1], p[2], -1, ft) end

-- quirk: a daisy tucked behind the right ear
local dtok = { r = { name = "daisy" } }
A.map(c, {
  ".cc.",
  "cGgc",
  "sgos",
  ".ss.",
}, 40, 10, { c = "#fff4d6", s = "#e3d3b8", G = "#ffe38a", g = "#f5b82e", o = "#d98322" }, dtok)
A.save(c, "ico-fox")
