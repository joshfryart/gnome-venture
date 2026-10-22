-- flowers/packet: tilted paper seed packet, V flap with gold button, EMPTY label (game overlays the flower head)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- same tilt as the SVG: rotate(-6 32 34)
local a = math.rad(-6)
local ca, sa = math.cos(a), math.sin(a)
local function R(x, y)
  local dx, dy = x - 32, y - 34
  return { 32 + dx * ca - dy * sa, 34 + dx * sa + dy * ca }
end
local function P(pts) local o = {} for i, p in ipairs(pts) do o[i] = R(p[1], p[2]) end return c:poly(o) end
local function rr(x0, y0, x1, y1, r) -- rotated rounded rect as a polygon (corner arcs, 3 steps)
  local pts, cs = {}, { { x1 - r, y0 + r, -90 }, { x1 - r, y1 - r, 0 }, { x0 + r, y1 - r, 90 }, { x0 + r, y0 + r, 180 } }
  for _, k in ipairs(cs) do
    for j = 0, 3 do
      local t = math.rad(k[3] + j * 30)
      pts[#pts + 1] = { k[1] + r * math.cos(t), k[2] + r * math.sin(t) }
    end
  end
  return P(pts)
end
local body  = rr(12, 10, 52, 54, 3)
local flap  = P({ { 12, 10 }, { 52, 10 }, { 52, 13 }, { 32.5, 24.5 }, { 12, 13 } }):clip(body)
local label = rr(17, 26, 47.5, 51, 2)
local paper = GV.ramp("#f4e7c3", { shade = "#dcc48c", deep = "#c9a85a", bounce = "#e6d29c" })
local kraft = GV.ramp("#e6d29c", { shade = "#c9a85a", deep = "#b07a45", bounce = "#d9a660" })
local p = c:build{
  { "body",  body,  paper, { gloss = false } },
  { "flap",  flap,  kraft, { gloss = false, light = body } },
  { "label", label, GV.ramp("#fff3c8"), { flat = true, rim = false, gloss = false, contact = false, contour = "#c9a85a" } },
}
-- gold edge stitch round the packet edge, kept off the label
local ring = c:mask()
p.body.m:shrink(2):edge():each(function(x, y) if not label:grow(1):has(x, y) then ring:set(x, y) end end)
local n = 0
ring:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, (x - 32) + (y - 34) > 8 and GV.C.goldS or GV.C.gold) end end)
-- thread-gold seam down both flap edges to the point, button at the point
c:seam({ R(16, 14), R(29.5, 21.8) }, { free = true })
c:seam({ R(49, 14), R(35.5, 21.8) }, { free = true })
local bp = R(32.5, 23.5)
c:button(math.floor(bp[1]) - 2, math.floor(bp[2]) - 2)
-- pale gloss comma on the flap's lit upper-left
local g = R(16, 12)
c:paint({ ".ggg", "gg..", "g..d" }, math.floor(g[1]), math.floor(g[2]), { g = "#fff3c8", d = "#ffffff" })
local t = c:save(O .. "aseprite/packet.aseprite", O .. "png/packet.png")
print(GV.report(t))
