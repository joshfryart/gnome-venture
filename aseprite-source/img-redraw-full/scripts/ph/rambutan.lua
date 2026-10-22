local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy, r = 31.5, 37, 13
local body = c:ellipse(cx, cy, r, r)
local tips = {}
local n = 12
for i = 0, n - 1 do
  local a = (i + 0.5) * 2 * math.pi / n
  local dx, dy = math.cos(a), math.sin(a)
  local px, py = -dy, dx
  local function P(rr, off) return { cx + 0.5 + dx * rr + px * off, cy + 0.5 + dy * rr + py * off } end
  body:add(c:poly({ P(r - 2, -2.6), P(r + 5, -1.0), P(r + 5, 1.0), P(r - 2, 2.6) }))
  tips[#tips + 1] = { math.floor(cx + dx * (r + 4) + 0.5), math.floor(cy + dy * (r + 4) + 0.5), i % 2 }
end
local ramp = GV.ramp("#e46a9b", { shade = "#ae2a2a", deep = "#6b1b2c" })
local p = c:build{
  { "stem", c:rrect(30, 15, 33, 25, 1), GV.ramp("#2f5a2a") , { flat = true } },
  { "body", body, ramp, { gloss = { 23, 27 } } },
  { "leaf", c:line({ { 35, 18 }, { 41, 12 } }, 4):add(c:ellipse(38.5, 15, 3, 2)), "moss" },
}
for _, t in ipairs(tips) do
  local x, y = t[1], t[2]
  if p.body.m:has(x, y) then
    c:px(x, y, t[3] == 0 and "#f6b8cf" or "#ae2a2a")
  end
end
local s = c:save(O .. "aseprite/ph/rambutan.aseprite", O .. "png/ph/rambutan.png")
print(GV.report(s))
