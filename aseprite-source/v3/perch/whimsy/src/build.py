import sys
S="/tmp/claude-0/-home-user-gnome-venture/9c742976-d6c0-5f98-947e-a8c24c975813/scratchpad/whimsy/src/"
c=open(S+"common.lua").read()
for i in range(1,5):
    open(S+f"run{i}.lua","w").write(c+"\n"+open(S+f"p{i}.lua").read())
