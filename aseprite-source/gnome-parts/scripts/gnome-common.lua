-- gnome-common.lua : shared geometry + palettes for the layered player-gnome builder.
-- Every part is drawn on the same 80x100 canvas (SVG viewBox 0 0 80 100), centred on pixel column 40,
-- so the 7 PNGs stack with no offset. Layer order: shadow, body, face, beard, hat, band, star.
local G = {}
G.ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
G.OUT = G.ROOT .. "gnome-parts/"
G.GV = dofile(G.ROOT .. "gvlib/gvlib.lua")
local GV = G.GV

-- layered canvas: bust grid, no die-cut halo (the layers must composite), nothing bleeds
function G.canvas() return GV.canvas{ w = 80, h = 100, mode = "bust", halo = 0, margin = 0, bleed = "" } end

-- quadratic bezier sampled to points
function G.q(p0, p1, p2, n)
  n = n or 16
  local t = {}
  for i = 0, n do
    local s = i / n
    local a, b, c = (1-s)^2, 2*s*(1-s), s*s
    t[#t+1] = { a*p0[1] + b*p1[1] + c*p2[1], a*p0[2] + b*p1[2] + c*p2[2] }
  end
  return t
end
local function cat(...) local r = {} for _, l in ipairs({...}) do for _, p in ipairs(l) do r[#r+1] = p end end return r end
-- mirror a mask about pixel column 40 (x -> 80 - x), adding to it
function G.sym(m) local add = {} m:each(function(x, y) add[#add+1] = {80 - x, y} end) for _, p in ipairs(add) do m:set(p[1], p[2]) end return m end

-- shapes (left half + mirror, so every part is exactly symmetric on x = 40)
function G.tunic(c)   -- SVG: M18 92 Q20 64 40 62 ... Z
  return G.sym(c:poly(cat(G.q({18, 92}, {20, 64}, {40, 62}), { {41, 62}, {41, 92} })))
end
function G.belt(c, tun) return tun:copy():clip(c:rect(0, 77, 79, 82)) end   -- SVG y78..83, wraps the tunic
function G.face(c) return c:ellipse(40, 48, 15, 15) end                      -- SVG circle 40,48 r15
function G.ears(c) return G.sym(c:ellipse(24, 47, 2.5, 3)) end
function G.nose(c) return c:ellipse(40, 52, 3.5, 2.5) end                    -- SVG ellipse 40,52
function G.beard(c)   -- SVG: M25 50 Q26 80 40 86 Q54 80 55 50 Q48 60 40 58 Q32 60 25 50 Z
  local top = G.q({41, 58.5}, {32, 60.5}, {24.5, 50})
  return G.sym(c:poly(cat(G.q({24.5, 50}, {25.5, 80}, {40, 86.5}), { {41, 86.5} }, top)))
end
function G.moustache(c)
  local m = G.sym(c:ellipse(35.5, 57, 4.5, 2))
  m:del(40, 55); return m
end
function G.cone(c)    -- SVG: M40 2 Q47 20 58 40 L22 40 Q33 20 40 2 Z
  return G.sym(c:poly(cat({ {40, 1.6} }, G.q({40, 2}, {33, 20}, {22, 41}), { {41, 41}, {41, 1.6} })))
end
function G.brim(c) return c:rrect(20, 37, 60, 42, 3) end                      -- SVG rect 20,37 40x6 rx3
function G.band(c) return G.brim(c):clip(c:rect(0, 37, 79, 39)) end           -- SVG band y37..40, tier II
function G.star(c)    -- SVG star ~ (40,22), tier III; moved down 2 px so it sits inside the cone
  return c:ascii({
    "......#......",
    ".....###.....",
    ".....###.....",
    "....#####....",
    "#############",
    ".###########.",
    "..#########..",
    "...#######...",
    "...#######...",
    "..####.####..",
    "..###...###..",
    ".##.......##.",
  }, 34, 17)
end

-- fixed ramps
G.R = {
  tunic = GV.ramp("#6b8f4e", { gloss = "#c8d77a", dot = "#e6eea0", rim = "#a4b86a" }),          -- moss
  belt  = GV.ramp("#5b4636", { gloss = "#b07a45", dot = "#d9a660", rim = "#8a6a50" }),          -- bark (soil/wood)
  skin  = GV.ramp("#f1c9a5", { gloss = "#ffeccc", dot = "#fff6e2", rim = "#fbdcb8", bounce = "#d99a74",
                               shade = "#d9a07c", deep = "#b0644a", pale = false }),
  nose  = GV.ramp("#e8a587", { gloss = "#ffd6b0", dot = "#ffecd2", rim = "#f4bd98", bounce = "#cf7e62",
                               shade = "#c97a66", deep = "#9a4a44" }),
  gold  = GV.ramp("#f5cf6a", { gloss = "#fff1c8", dot = "#fff8e0", rim = "#fde49a", bounce = "#d0862a",
                               shade = "#e8a317", deep = "#b8661a" }),
}
-- neutral (hue-free) ramps for the multiply-tinted layers: near-white light down to mid-grey shade
G.N = {
  hat   = { gloss = "#f8f8f8", dot = "#fdfdfd", rim = "#e4e4e4", base = "#cbcbcb", bounce = "#9c9c9c",
            shade = "#8e8e8e", deep = "#646464", pale = false },
  brim  = { gloss = "#f0f0f0", dot = "#f8f8f8", rim = "#dcdcdc", base = "#bcbcbc", bounce = "#929292",
            shade = "#848484", deep = "#5e5e5e", pale = false },
  beard = { gloss = "#f8f8f8", dot = "#fdfdfd", rim = "#e8e8e8", base = "#d2d2d2", bounce = "#a8a8a8",
            shade = "#9a9a9a", deep = "#707070", pale = false },
  strand = "#aaaaaa", strandS = "#7c7c7c",
}
-- swap gvlib's outline + thread colours to neutral greys (for tintable layers), and back
local KEEP = {}
for _, k in ipairs({ "ol1", "ol2", "ol3", "umber", "gold", "goldS" }) do KEEP[k] = GV.C[k] end
function G.neutral(on)
  if on then
    GV.C.ol1, GV.C.ol2, GV.C.ol3, GV.C.umber = "#646464", "#464646", "#2e2e2e", "#2e2e2e"
    GV.C.gold, GV.C.goldS = "#fbfbfb", "#cacaca"   -- light thread: reads as a paler tint after multiply
  else
    for k, v in pairs(KEEP) do GV.C[k] = v end
  end
end

function G.save(c, name)
  local t = c:save(G.OUT .. "aseprite/" .. name .. ".aseprite", G.OUT .. "png/" .. name .. ".png")
  print(name .. ": " .. GV.report(t))
  assert(t.semi == 0, name .. " has semi-transparent pixels")
  return t
end
return G
