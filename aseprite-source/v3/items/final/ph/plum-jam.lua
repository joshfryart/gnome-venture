-- plum-jam (aC35_3 final, Opus single pass). A slim hexagonal glass jar of deep plum jam: three lit facets (flat facet
-- light, bright facet edges, pale glass corners), 6-tone jam with whole plum halves pressed against the glass (glossy
-- flesh, dark skin rim) and gold seed-flecks, a pale headspace and thick glass base. Knurled gold screw lid (ribs,
-- bevel, specular streak) over a scalloped wax-paper disc. Cream paper label with a plum sketch and twine tie.
-- Ground shadow. History: Sonnet draft replaced.
-- quirk: a tiny wasp has landed on the lid, drawn by the sugar.
local NAME = "plum-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local JAM   = { "#1e0b2a", "#341542", "#4e2160", "#6c3080", "#8e48a0", "#b870c4" }
local FLESH = { "#8a3a52", "#c25a5e", "#e8866a", "#fbb98a" }
local GLASS = { "#3f5f7e", "#62889f", "#93bcc8", "#c6e4ea", "#eaf8f6" }
local GOLD  = { "#5e3218", "#8f4a1f", "#c4741e", "#e8a22a", "#f8cc5a", "#fff0a8" }
local PAPER = { "#8a7680", "#b8a49a", "#d8c8b0", "#ece0c4", "#f8efd8" }
local WAX   = { "#b8a890", "#e2d6b8", "#f6eed6" }
local TWINE = { "#7a5530", "#b08850", "#e6c88a" }

c:groundShadow(32, 58, 13, 1.4)
-- hex jar: faces split at x 26 and 38
local X0, X1, FL, FR = 22, 42, 26, 38
local body = HP.rrect(X0, 25, X1, 57, 2)
local neck = HP.rect(25, 22, 39, 25)
local jar = body:copy():add(neck)
local function facetN(x)
  if x < FL then return { A.norm(-0.75, 0, 0.66) } elseif x > FR then return { A.norm(0.75, 0, 0.66) } end
  return { A.norm((x - 32) / 40, 0, 1) }
end
local gtok = A.tok("glass")
local gn = {}
jar:each(function(x, y) gn[K(x, y)] = facetN(x) end)
A.tone(c, jar, gn, GLASS, { tok = gtok, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.5, 0.7, 0.88 } })
-- jam
local jam = body:shrink(1):clip(HP.rect(0, 29, 63, 55))
local jtok = A.tok("jam")
local jn, jb = {}, {}
jam:each(function(x, y) jn[K(x, y)] = facetN(x) if y >= 53 then jb[K(x, y)] = -1 end if y == 29 then jb[K(x, y)] = 1 end end)
local jidx = A.tone(c, jam, jn, JAM, { tok = jtok, amb = 0.04, wrap = 0.2, bias = jb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
jam:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 4) < 0.04 and y > 30 then c:put(x, y, (jidx[k] or 3) >= 4 and "#f0c060" or "#a8743a", jtok) end end)
-- plum halves pressed against the glass (flesh disc with a dark skin rim and a lit gloss)
for _, p in ipairs{ { 25, 34, 2.4 }, { 39, 49, 2.2 }, { 31, 53, 1.8 } } do
  local m = HP.ellipse(p[1], p[2], p[3], p[3] * 0.8):clip(jam)
  local fn = X.sphere(p[1] - .5, p[2] - .5, p[3] + 1, m)
  local fi = X.tone(c, m, X.light(fn, { amb = 0.15, wrap = 0.3 }), FLESH, { cuts = { 0.3, 0.55, 0.78 }, tok = jtok })
  m:edge():each(function(x, y) if x >= p[1] or y >= p[2] then c:put(x, y, JAM[2], jtok) end end)
end
-- meniscus
for x = 23, 41 do c:put(x, 29, x < 32 and JAM[6] or JAM[5], jtok) end
-- facet edges (bright on the lit side, dim on the right) + streaks
for y = 23, 56 do
  if jar:has(FL, y) then c:put(FL, y, GLASS[5], gtok) end
  if jar:has(FR, y) then c:put(FR, y, GLASS[3], gtok) end
end
for y = 30, 50 do c:put(23, y, GLASS[4], gtok) end
for y = 32, 37 do c:put(28, y, GLASS[5], gtok) end
for x = 24, 40 do c:put(x, 56, x < 29 and GLASS[4] or GLASS[3], gtok) end   -- thick base
for x = 24, 40 do c:put(x, 57, GLASS[2], gtok) end

-- label: cream paper wrapped on the front facet only (sits flat), twine tie above
local ltok = A.tok("label")
local lab = HP.rect(FL + 1, 37, FR - 1, 49)
for y = 37, 49 do for x = FL + 1, FR - 1 do
  local i = (x <= 28) and 5 or ((x >= 36) and 3 or 4)
  if y == 37 then i = 5 end if y == 49 then i = 2 end
  c:put(x, y, PAPER[i], ltok) end end
for x = FL + 1, FR - 1 do c:put(x, 50, JAM[1], jtok) end   -- AO under the label
local sk = {
  "...g...",
  "....g..",
  "..ppp..",
  ".pPPpd.",
  ".pPppd.",
  ".pppdd.",
  "..ddd..",
}
local SK = { g = "#3f9150", p = "#6a3a86", P = "#a07ad0", d = "#3a2252" }
for j, row in ipairs(sk) do for i = 1, #row do local ch = row:sub(i, i)
  if SK[ch] then c:put(28 + i, 37 + j, SK[ch], ltok) end end end
for x = 29, 35 do if x ~= 32 then c:put(x, 47, PAPER[2], ltok) end end

-- wax-paper disc under the lid, scalloped edge
local wtok = A.tok("wax")
for x = 22, 42 do
  c:put(x, 22, (x < 30) and WAX[3] or WAX[2], wtok)
  if x % 2 == 0 then c:put(x, 23, x < 30 and WAX[2] or WAX[1], wtok) end
end
-- knurled gold lid
local lid = HP.rrect(23, 14, 41, 21, 1)
local ltk = A.tok("lid")
local lidN = A.vcylN(lid, 23, 41, 0)
for k, nn in pairs(lidN) do local y = k // 1024 - 256 if y <= 14 then lidN[k] = { A.norm(nn[1], -0.8, nn[3]) } end end
local lidx = A.tone(c, lid, lidN, GOLD, { tok = ltk, amb = 0.08, wrap = 0.25 })
lid:each(function(x, y) local k = K(x, y)
  if y >= 16 and y <= 20 and x % 2 == 1 then c:put(x, y, GOLD[max(1, (lidx[k] or 3) - 1)], ltk) end end)
for x = 24, 40 do c:put(x, 15, x < 32 and GOLD[6] or GOLD[5], ltk) c:put(x, 21, GOLD[2], ltk) end
for y = 16, 20 do c:put(26, y, GOLD[6], ltk) end            -- specular streak
-- twine twist around the neck
local ttok = A.tok("twine")
for x = 25, 39 do c:put(x, 24, (x % 2 == 0) and TWINE[3] or TWINE[2], ttok) c:put(x, 25, (x % 2 == 0) and TWINE[2] or TWINE[1], ttok) end
c:put(40, 25, TWINE[2], ttok) c:put(41, 26, TWINE[3], ttok) c:put(41, 27, TWINE[2], ttok) c:put(42, 28, TWINE[1], ttok)

-- quirk: wasp on the lid
local wasp = {
  ".ww..",
  "kykyk",
  ".kyk.",
}
local WS = { w = "#d8eef0", k = "#2b1c26", y = "#f5b82e" }
for j, row in ipairs(wasp) do for i = 1, #row do local ch = row:sub(i, i)
  if WS[ch] then c:put(32 + i, 10 + j, WS[ch], ltk) end end end
A.save(c, NAME)
