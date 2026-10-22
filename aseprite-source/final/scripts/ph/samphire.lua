local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tipR = GV.ramp("#b8cc6e")

-- three forked stalks: { base x, fork x, left tip, right tip }
local stalks = {
  { 25, 19, { 12, 19 }, { 22, 17 } },
  { 32, 32, { 27, 13 }, { 38, 13 } },
  { 39, 45, { 43, 17 }, { 53, 19 } },
}
local masks, tips = {}, {}
for i, s in ipairs(stalks) do
  local m = c:line({ { s[1] - 2, 50 }, { s[2] - 2, 34 } }, 5)
  m:add(c:line({ { s[2] - 2, 34 }, { s[3][1] - 2, s[3][2] } }, 4))
  m:add(c:line({ { s[2] - 1, 34 }, { s[4][1] - 1, s[4][2] } }, 4))
  m:add(c:rrect(s[2] - 3, 31, s[2] + 2, 37, 1)) -- chubby fork knuckle
  masks[i] = m
  tips[#tips + 1] = s[3]; tips[#tips + 1] = s[4]
end

local mound = c:ellipse(31.5, 52, 19, 7):cut(c:rect(0, 53, 63, 63))
local parts = {
  { "s1", masks[1], "moss", { gloss = { 13, 24 }, cres = 2 } },
  { "s3", masks[3], "moss", { gloss = { 43, 24 }, cres = 2 } },
  { "s2", masks[2], "moss", { gloss = { 29, 18 }, cres = 2 } },
}
for i, p in ipairs(tips) do
  table.insert(parts, { "t" .. i, c:ellipse(p[1] - 0.5, p[2] - 1.5, 2.5, 2.5), tipR, { flat = true } })
end
table.insert(parts, { "mound", mound, "wood", { gloss = { 20, 48 } } })
c:build(parts)

-- joint notches across every stalk/branch
for _, m in ipairs(masks) do
  for _, y in ipairs({ 44, 25 }) do
    m:each(function(x, yy) if yy == y and not mound:has(x, yy) then c:px(x, yy, "#4a8a3e") end end)
  end
end
-- salt flecks on the mud
for _, p in ipairs({ { 18, 50 }, { 25, 47 }, { 37, 49 }, { 44, 51 }, { 30, 51 }, { 47, 48 }, { 22, 52 } }) do
  c:px(p[1], p[2], "#f1ece0")
end

local t = c:save(O .. "aseprite/ph/samphire.aseprite", O .. "png/ph/samphire.png")
print(GV.report(t))
