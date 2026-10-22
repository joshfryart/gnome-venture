local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
  end
  return c:poly(pts)
end

local pages = c:rrect(18, 50, 50, 57, 2)
local cover = c:rrect(14, 7, 52, 55, 4):add(c:rect(14, 7, 22, 55))
local spine = c:rrect(10, 7, 17, 55, 2)
local plate = c:rrect(23, 14, 46, 29, 3)
local st = star(41, 44, 8, 3.6)

local p = c:build{
  { "pages", pages, "#f1ece0", { flat = true } },
  { "cover", cover, "#58a03e" },
  { "spine", spine, "#2f5a2a", { gloss = { 12, 11 } } },
  { "plate", plate, "#f4f0e0" },
  { "star",  st, GV.ramp("#f5cf6a", { shade = "#e8a317" }), { gloss = false } },
}
-- ink dashes on label
c:fill(c:rect(27, 20, 42, 21), "#2a1a10")
c:fill(c:rect(27, 24, 36, 25), "#2a1a10")
-- page lines
c:paint({ "pppppppppppppppppppppppppppppp" }, 20, 56, { p = "#c9a96e" })
-- seam beside spine
c:seam({ { 19, 11 }, { 19, 52 } })
c:px(40, 42, "#fff1c8")

local t = c:save(D .. "img-redraw-full/aseprite/ph/guide-wca.aseprite", D .. "img-redraw-full/png/ph/guide-wca.png")
print(GV.report(t))
