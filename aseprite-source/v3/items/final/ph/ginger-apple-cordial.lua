-- ginger-apple-cordial (final pass, Opus single pass). A slim tall glass bottle with sloped shoulders, amber cordial
-- up to the shoulder, a cork stopper and a twisted twine wrap at the neck; a curved paper label with a red apple
-- and a ginger knob.
-- Material: glass = bright left rim streak, pale core, thick dark base; liquid = cylinder light with a glowing
-- transmitted core on the shade side, meniscus line, rising bubbles; cork = grain + paler end; twine = twist dashes;
-- label = curved top/bottom edges, AO under the twine.
-- quirk: a tiny paper tag with a hand-drawn heart hangs off the twine.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("ginger-apple-cordial")
local AMB   = { "#5a2620", "#8f3f1a", "#c2661e", "#e8922a", "#ffbe48", "#ffe28c" }
local GLASS = { "#2f5a7a", "#5c92b0", "#94c8d8", "#c8eaea", "#e8faf4" }
local CORK  = { "#51302b", "#864c33", "#b97a4a", "#d8a06a", "#efc890" }
local PAPER = { "#a89080", "#d8c6a8", "#f2e4c4", "#fff4d6" }
local TW    = { "#6e4a2e", "#a8784a", "#d8ae74" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local SPEC  = "#fff4d6"
local CX = 32

c:groundShadow(32, 55, 12, 2)

-- glass silhouette
local body = c:rrect(23, 28, 41, 54, 4)
body:add(c:poly{ { 22.6, 33 }, { 28.6, 20.5 }, { 35.4, 20.5 }, { 41.4, 33 } })
local neck = c:rect(29, 12, 35, 22)
local glass = body:copy():add(neck)
local function hw(y) -- half width at row y
  local x0, x1 = 99, -1
  for x = 0, 63 do if glass:has(x, y) then x0 = min(x0, x) x1 = max(x1, x) end end
  return (x1 - x0 + 1) / 2, (x0 + x1) / 2
end
local LIQ = 30 -- liquid surface row
local gtok, ltok = { r = { name = "glass" } }, { r = { name = "liquid" } }
glass:each(function(x, y)
  local w, mid = hw(y)
  local s = (x - mid) / (w + 0.3)
  local nz = sqrt(max(0.05, 1 - s * s))
  local v = max(0, (-s) * -0.55 * -1 * 0.6 + nz * 0.55 + 0.1)
  if y >= LIQ and y <= 51 then
    local i = v > 0.62 and 5 or v > 0.5 and 4 or v > 0.36 and 3 or 2
    if s > 0.2 and s < 0.62 then i = i + 1 end           -- transmitted glow core on the shade side
    if s > 0.8 then i = 1 end
    if y == LIQ then i = 6 end                            -- bright meniscus
    if y == LIQ + 1 then i = max(1, i - 1) end
    c:put(x, y, AMB[max(1, min(6, i))], ltok)
  else
    local i = 3
    if s < -0.55 then i = 4 end
    if s > 0.55 then i = 2 end
    if abs(s) > 0.85 then i = (s < 0) and 4 or 1 end
    if y >= 52 then i = (y == 54) and 1 or 2 end         -- thick base
    c:put(x, y, GLASS[i], gtok)
  end
end)
-- glass rim streak (left) and a short secondary reflection (right)
for y = 23, 50 do local w, mid = hw(y) local x = floor(mid - w + 2) if glass:has(x, y) then c:put(x, y, (y < LIQ) and GLASS[5] or AMB[6], gtok) end end
for y = 34, 44 do local w, mid = hw(y) local x = floor(mid + w - 3) c:put(x, y, AMB[5], ltok) end
for y = 14, 21 do c:put(30, y, GLASS[5], gtok) end
-- bubbles rising
for _, b in ipairs({ { 36, 45 }, { 37, 41 }, { 35, 37 }, { 36, 33 } }) do c:put(b[1], b[2], AMB[6], ltok) end
c:put(36, 44, AMB[4], ltok)

-- lip ring
local lip = c:rrect(28, 10, 36, 13, 1)
lip:each(function(x, y)
  local i = 3
  if y == 10 or x == 28 then i = 5 end
  if y == 13 or x == 36 then i = 1 end
  if x == 29 and y < 13 then i = 4 end
  c:put(x, y, GLASS[i], gtok)
end)
-- cork: grain lines and pale end grain on top
local ctok = { r = { name = "cork" } }
local cork = c:rect(29, 6, 35, 9)
cork:each(function(x, y)
  local i = x <= 30 and 4 or x >= 34 and 2 or 3
  if y == 6 then i = 5 end
  if y > 6 and (x == 31 or x == 33) and (y % 2 == 1) then i = i - 1 end
  if y > 6 and X.hash(x, y, 5) > 0.85 then i = i - 1 end
  c:put(x, y, CORK[max(1, i)], ctok)
end)
c:put(30, 6, CORK[4], ctok) c:put(34, 6, CORK[3], ctok)
for x = 29, 35 do c:put(x, 9, CORK[1], ctok) end

-- twine wrap at the neck (twist dashes) with a bow knot on the right
local ttok = { r = { name = "twine" } }
for x = 29, 35 do for y = 17, 18 do
  local t = (x + y) % 3
  c:put(x, y, TW[t == 0 and 1 or (t == 1 and 3 or 2)], ttok)
end end
for x = 29, 35 do if glass:has(x, 19) then c:put(x, 19, GLASS[1], gtok) end end   -- AO under the wrap
local bow = {
  "kk..",
  "lmk.",
  ".ml.",
  ".l.m",
  ".l..",
  ".m..",
}
A.map(c, bow, 36, 16, { k = TW[1], l = TW[2], m = TW[3] }, ttok)
-- quirk: tiny paper tag with a heart on the hanging string
local tag = {
  "kppk",
  "prrp",
  "prrp",
  "pppd",
}
A.map(c, tag, 37, 22, { k = PAPER[1], p = PAPER[3], r = RED[2], d = PAPER[2] }, ttok)
c:put(38, 22, PAPER[4], ttok)

-- label: curved band with an apple and a little ginger knob
local lab = HP.mask()
for x = 24, 40 do
  local s = (x - CX) / 9
  local bow2 = floor(s * s * 1.6 + 0.5)
  for y = 38 - bow2 + 1, 50 - bow2 do lab:set(x, y) end
end
local ptok = { r = { name = "label" } }
lab:each(function(x, y)
  local s = (x - CX) / 9
  local i = s < -0.6 and 4 or s > 0.55 and 2 or 3
  if not lab:has(x, y - 1) then i = 4 end
  if not lab:has(x, y + 1) then i = 1 end
  c:put(x, y, PAPER[i], ptok)
end)
-- border line inside the label (thin red rule top and bottom)
lab:each(function(x, y) if x > 25 and x < 39 and (not lab:has(x, y - 2)) and lab:has(x, y - 1) then c:put(x, y, RED[2], ptok) end
  if x > 25 and x < 39 and (not lab:has(x, y + 2)) and lab:has(x, y + 1) then c:put(x, y, RED[2], ptok) end end)
local apple = {
  "...g.",
  "..gs.",
  ".rRrr",
  "rhRrrd",
  "rRRrrd",
  ".rrrd.",
  "..dd..",
}
A.map(c, apple, 27, 41, { g = "#3f9150", s = "#864c33", r = RED[3], R = RED[3], h = RED[4], d = RED[1] }, ptok)
for _, p in ipairs({ { 28, 44, RED[2] }, { 31, 44, RED[2] }, { 31, 45, RED[2] }, { 30, 46, RED[2] } }) do c:put(p[1], p[2], p[3], ptok) end
local ginger = {
  ".a.",
  "aab",
  "abb",
  ".bb",
}
A.map(c, ginger, 34, 43, { a = "#e8c088", b = "#aa7048" }, ptok)
c:put(36, 43, "#ee8fa0", ptok)

-- glass glint
c:put(25, 31, SPEC, gtok)
A.save(c, "ginger-apple-cordial")
