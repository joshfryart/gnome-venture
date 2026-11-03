-- ico-info (final, Opus). A round enamel badge: domed cobalt enamel sunk into a bevelled brass bezel, with a bold
-- embossed cream serif "i". Material: per-pixel lit 6-tone enamel (dome + rim shadow on the upper-left inner edge,
-- bounce light on the lower-right), glossy arc specular, brass bezel lit as a bevel (bright outer-top edge, dark
-- inner lip), 5-tone raised glyph with a cast shadow on the enamel.
-- quirk: a tiny garden snail has climbed onto the bezel, leaving a shiny slime trail behind it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_0.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.atan
local c = A.new("ico-info")
local BLUE = { "#1c2a5e", "#24448a", "#2e66b8", "#3f8ad8", "#62b0ee", "#a8dcfa" }
local BRASS = { "#5e2e1a", "#8f4a1f", "#c06e22", "#e4972c", "#f7c24c", "#ffe79a" }
local CRM = { "#9c7660", "#cfa984", "#eccfa6", "#fae6c2", "#fff4d6" }
local CX, CY, R, RI = 32, 31, 21.5, 17.6

-- bezel ring
local disc, ring, enamel = HP.mask(), HP.mask(), HP.mask()
local rn, en = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - CX, y - CY
  local d = sqrt(dx*dx + dy*dy)
  if d <= R + 0.45 then
    disc:set(x, y)
    local ux, uy = dx / max(d, 0.01), dy / max(d, 0.01)
    if d > RI then
      ring:set(x, y)
      local u = ((d - RI) / (R + 0.45 - RI)) * 2 - 1      -- -1 inner .. +1 outer
      local b = u * 0.85
      rn[K(x, y)] = { A.norm(ux * b, uy * b, sqrt(1 - b*b) + 0.1) }
    else
      enamel:set(x, y)
      local s = d / 40
      en[K(x, y)] = { A.norm(ux * s, uy * s, 1) }
    end
  end
end end
local rtok = { r = { name = "brass" } }
local ridx = A.shade(c, ring, rn, BRASS, { amb = 0.1, wrap = 0.2, tok = rtok })
-- groove in the middle of the bezel (machined line)
ring:each(function(x, y) local d = sqrt((x - CX)^2 + (y - CY)^2)
  if d > 19.3 and d < 20.1 then A.step(c, ridx, BRASS, x, y, -1, rtok) end end)

-- glyph masks
local dot = c:rrect(29, 15, 35, 21, 2)
local stem = c:rect(29, 24, 35, 41)
local tab = c:rect(26, 24, 28, 26)
local foot = c:rrect(25, 42, 39, 45, 1)
local glyph = HP.mask():add(dot):add(stem):add(tab):add(foot)

-- enamel: AO under the bezel lip on the upper-left, cast shadow of the glyph
local bias = {}
enamel:each(function(x, y) local dx, dy = x - CX, y - CY
  local d = sqrt(dx*dx + dy*dy)
  if d > RI - 1.6 and (dx + dy) < 2 then bias[K(x, y)] = -1 end
  if d > RI - 0.8 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end
end)
A.cast(bias, enamel, glyph, 1, 1, -2)
A.cast(bias, enamel, glyph, 2, 2, -1)
local etok = { r = { name = "enamel" } }
local eidx = A.shade(c, enamel, en, BLUE, { amb = 0.08, wrap = 0.3, cuts = { 0.15, 0.3, 0.5, 0.72, 0.95 }, bias = bias, tok = etok })
-- cool bounce on the lower-right inner edge (lit lip of the recess)
enamel:each(function(x, y) local dx, dy = x - CX, y - CY
  local d = sqrt(dx*dx + dy*dy)
  if d > RI - 1.2 and dx + dy > 12 and not glyph:has(x, y) then c:put(x, y, BLUE[5], etok) end end)
-- glossy arc highlight upper-left
enamel:each(function(x, y) local dx, dy = x - CX, y - CY
  local d = sqrt(dx*dx + dy*dy)
  local a = math.deg(atan(dy, dx))
  if d > 13.2 and d < 14.6 and a > -160 and a < -112 and not glyph:has(x, y) then c:put(x, y, BLUE[6], etok) end
  if d > 13.2 and d < 14.6 and a >= -112 and a < -100 and not glyph:has(x, y) then c:put(x, y, BLUE[5], etok) end
end)

-- glyph: raised cream letter
local gn = X.pillow(glyph, 1.7)
local gtok = { r = { name = "glyph" } }
local gidx = A.shade(c, glyph, gn, CRM, { amb = 0.2, wrap = 0.35, cuts = { 0.3, 0.5, 0.7, 0.88 }, tok = gtok })
-- inner corner AO where stem meets foot / tab
for _, p in ipairs{ { 28, 41 }, { 36, 41 }, { 29, 27 } } do A.step(c, gidx, CRM, p[1], p[2], -1, gtok) end
-- foot underside row
for x = 26, 38 do A.step(c, gidx, CRM, x, 45, -1, gtok) end
-- glyph specular
c:put(30, 25, A.CREAM, gtok) c:put(30, 26, A.CREAM, gtok)
c:put(30, 16, A.CREAM, gtok) c:put(31, 16, A.CREAM, gtok)

-- bezel pop: bright 2x1 on the outer upper-left edge
c:put(18, 15, BRASS[6], rtok) c:put(19, 14, BRASS[6], rtok)

-- quirk: snail on the bezel, lower right, crawling up-right along the rim; slime trail glints behind it
local S = { K = A.INK, s = "#f5809f", S = "#c94f84", d = "#7d2c5e", h = "#ffc4d8", b = "#d8c6a8", B = "#a88f78", e = "#fff4d6" }
A.map(c, {
  "...KKKK......",
  "..KhssSK.K.K.",
  ".KhsdddSKbKb.",
  ".KsdsSdSKbbK.",
  ".KsdSSdSKbbK.",
  "..KSSSSKbbbK.",
  "KKbbbbbbbbBK.",
  "KbBBBBBBBBK..",
  ".KKKKKKKKK...",
}, 42, 43, S)
c:put(45, 45, A.CREAM) -- shell glint
-- slime trail on the bezel behind it (wet glints)
c:put(41, 50, BRASS[6], rtok) c:put(39, 51, BRASS[6], rtok) c:put(37, 52, BRASS[6], rtok)
c:sparkle(50, 12)
A.save(c, "ico-info")
