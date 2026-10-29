-- yi-treat.lua : Cat Fish 2.2.x Yarn panel icon `treat` (Mood Treat, 2 Yarn/day: the playing cat has a second
-- mood today). 64x64 gvlib "icon", the house look of cf_icons.lua (cf-up-*): a heart-shaped felt biscuit with
-- a locked-eye face and a tiny smile, edge-stitched, a pink yarn ball (the Yarn panel accent) tucked at its
-- lower right with a loose curling end. Main colour honey biscuit (wood/skin family via GV.ramp) and a heart
-- silhouette keep it apart from cf-up-bowl (pink pedestal bowl) and the other Yarn icons.
-- Run: AppRun -b --script yi-treat.lua        Writes out/cf-yi-treat.png + .aseprite.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- helpers copied from cf_icons.lua
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

local BISC = felt("#dc9a50", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f2c070", shade = "#ae6634" })
local PINK = felt("#e46a9b", { gloss = "#ffc8dc", dot = "#ffc8dc", rim = "#f29abb" })

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local heart = c:ellipse(20.5, 22, 12.5):add(c:ellipse(41.5, 22, 12.5))
heart:add(c:poly({ {8.5, 25}, {54.5, 25}, {31.5, 54} })):closed(2)
local ball = c:ellipse(46.5, 47, 9)
local strand = c:line({ {39, 51}, {36, 53}, {32, 53} }, 2)
local p = c:build{
  { "heart", heart, BISC, { cres = 4, gloss = false } },
  { "strand", strand, PINK, { flat = true, contact = false } },
  { "ball", ball, PINK, { cres = 3, gloss = { 42, 42 } } },
}
c:stitch(heart)                                                                    -- felt edge stitch
c:paint({                                                                          -- enamel comma, upper-left lobe
  "...gggd",
  ".ggd...",
  "gd.....",
  "g......",
}, 12, 15, { g = BISC.gloss, d = BISC.dot })
for _, q in ipairs({ { 25, 19 }, { 38, 19 }, { 31, 38 }, { 17, 31 } }) do           -- biscuit docking holes
  onPart(c, c:rect(q[1], q[2], q[1], q[2]), p.heart, BISC.shade, true)
end
-- yarn wraps: arcs round a point off the upper right, clipped to the ball
for _, r in ipairs({ 6, 10 }) do
  local m = c:ellipse(54, 39, r + 1):cut(c:ellipse(54, 39, r))
  onPart(c, m, p.ball, PINK.shade)
end
local m = c:ellipse(36, 52, 7):cut(c:ellipse(36, 52, 6))
onPart(c, m, p.ball, PINK.shade)
-- face: locked eyes and a tiny smile
c:eye(19, 24); c:eye(35, 24)
c:paint({ "u....u", ".uuuu." }, 26, 32, { u = "ol2" })

local t = c:save(OUT .. "cf-yi-treat.aseprite", OUT .. "cf-yi-treat.png")
print("treat    " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
