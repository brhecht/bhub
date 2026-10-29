# Note to Nico: the house style for Claude

*Brian sends this. Written 2026-10-29.*

Nico, I have been fixing how Claude writes to me, and I want the same fix on your Mac, because a lot of
what I read from you starts as text your Claude wrote: Linear issues and comments, Slack messages,
emails. The rule is one sentence: say the point, do not write about the point. Every sentence has a
real subject and a plain verb. "Pushed." becomes "I pushed it." "Two things still open." becomes "Two
items are still open: the thumbnail and the transcript." The full document is at
https://github.com/brhecht/bhub/blob/main/HOUSE-STYLE.md, and it applies to what Claude writes to you
as much as to what it writes to me. I think it will make Claude easier for you to read too.

## What to do

Open Terminal (press Command and Space, type Terminal, press Return), paste this one line, and press
Return:

```
curl -fsSL https://raw.githubusercontent.com/brhecht/bhub/main/install-house-style.sh | bash
```

It runs for two to four minutes the first time, because it downloads a grammar parser. If it says
python3 is missing, run `xcode-select --install`, click Install in the window that opens, wait for it
to finish, and paste the line again. When it prints "Done", close any open Claude Code session and open
a new one.

## What it does

It installs three things.

1. A rules file that every Claude Code session on your Mac reads at startup, so Claude writes in the
   house style from the first message.
2. A check that runs after each reply Claude writes you. It reads the reply, finds any sentence that
   breaks the rules, and shows the list to Claude at the start of the next turn so the next reply is
   better. You will not see it unless you look for it.
3. A check that runs at the moment Claude is about to save text into Linear, send a Slack message or
   send an email. If a sentence breaks the rules, Claude rewrites it before the text goes out. You may
   notice Claude take one extra turn before a Linear write. After two rewrites the text goes through as
   it is, so nothing can get stuck.

It also installs a small updater that fetches the latest rules each time Claude Code starts, so you
never have to run the install again.

It changes nothing else. It does not read your files, and it does not touch Linear, Slack or Gmail on
its own. To turn it off, delete the four "hooks" entries from the file ~/.claude/settings.json, or
ask Claude to do that.

## One more paste, this time into Claude Code

Open a new Claude Code session and paste this sentence as a message:

```
Read scheduled/weekly-writing-check.md in the bhub checkout at ~/.claude/house-style/bhub and create the scheduled task it describes, Sundays at 7:06am.
```

That creates a task that runs on Sunday mornings while Claude Code is open. It reads the week's
check results on your Mac and sends me the summary as a Slack DM, so I can see how both our Claudes
are doing in one place. It reads nothing else.

## One question

Do you also use Cowork or claude.ai? Those two cannot run the checks, but they can follow the rules if
you paste a short text into a custom Style. If you use either, tell me and I will send you the text
and the three clicks to paste it. If you only use Claude Code, you are done.
