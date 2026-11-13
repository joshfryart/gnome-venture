import sys
from PIL import Image, ImageDraw
D="/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase4/banners/"
G="/home/user/gnome-venture/game/assets/img/"
codes="CB SE SA EE MENA EA CSA SEA WCA ESA OC".split()
ks="coral_pennyfeather nonna_briscola abuela_quilla babka_wren auntie_saffira grandmother_hoshi didi_marigold pak_lontar auntie_mossbead old_baobab_kito captain_pipi_shellback".split()
def bg(theme): return (236,230,220) if theme=="light" else (36,32,44)
# banners 2x: old left, new right? stack: each row old over new. 11 rows too tall; 2 columns pairs
for theme in ("light","dark"):
    s=2; w=480*s; h=120*s
    W=Image.new("RGB",(w*2+30, (h+6)*11+0),bg(theme))
    for i,c in enumerate(codes):
        o=Image.open(G+"catfish/banner-%s-pets.png"%c).convert("RGBA").resize((w,h),0)
        n=Image.open(D+"out/banner-%s-pets.png"%c).convert("RGBA").resize((w,h),0)
        W.paste(o,(0,i*(h+6)),o); W.paste(n,(w+30,i*(h+6)),n)
    W.save(D+"sheet-banners-%s.png"%theme)
    s=4
    W=Image.new("RGB",(80*s*11,100*s*2+8),bg(theme))
    for i,k in enumerate(ks):
        o=Image.open(G+"ph/npc-%s.png"%k.replace("_","-")).convert("RGBA").resize((80*s,100*s),0)
        n=Image.open(D+"out/npc-%s.png"%k).convert("RGBA").resize((80*s,100*s),0)
        W.paste(o,(i*80*s,0),o); W.paste(n,(i*80*s,100*s+8),n)
    W.save(D+"sheet-busts-%s.png"%theme)
