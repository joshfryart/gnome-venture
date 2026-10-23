local L = dofile(os.getenv("GV_ROOT") .. "opus-test-run/scripts/minis/lib.lua")
local T = {
  { slug = "t-bug", size = "small", arch = "bug", col = "#7a4a1f", acc = "#a8582f", feat = { pincers = true, shell = true } },
  { slug = "t-snail", size = "small", arch = "snail", col = "#f2e4c0", acc = "#a8582f", base = "soil" },
  { slug = "t-quad", size = "large", arch = "quad", col = "#e0501f", acc = "#f2e4c0", feat = { tail = true }, base = "moss" },
  { slug = "t-bird", size = "medium", arch = "bird", col = "#4e3a8a", acc = "#7a5cc0" },
  { slug = "t-crab", size = "medium", arch = "crab", col = "#dd3a2a", acc = "#f08a24", base = "sand" },
  { slug = "t-frog", size = "medium", arch = "frog", col = "#4f9a45", acc = "#f2e4c0", feat = { spots = true } },
  { slug = "t-snake", size = "large", arch = "snake", col = "#7ab55c", acc = "#4f9a45", feat = { band = true } },
  { slug = "t-golem", size = "large", arch = "golem", col = "#8b8f96", acc = "#7ab55c", feat = { moss = true }, base = "stone" },
  { slug = "t-folk", size = "party", arch = "folk", col = "#e8a317", base = "moss", feat = { species = "hare", face = "#d9a660", hat = "cap", hatc = "#7a5cc0", cloth = "#3f8fb0" } },
}
for _, s in ipairs(T) do L.mini(s, "mini-test") end
