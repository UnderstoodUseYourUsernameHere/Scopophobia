# Scopophobia
Made in Godot 4.7.2

## Inspiration
What really inspired me with Scopophobia was Limbus Company, especially canto X of it and the themes of gaze bearing and whatnot, so i thought id have a crack at it for a project! Went through a massive hurdle (learning Godot over Unity), and i... think im getting the hang of godot now?
Art is also, an issue, unsurprisingly. But i hope with enough time i can get into asesprite for most of my assets!  

### How to Run
1. Literally just open up the demo link, here: https://mustardmustard.itch.io/scopophobia

Orrrrr, you can do this: 
1. Open Godot 4.7
2. Open this project folder
3. Press Play (▶) at the top

### How to Play
- Click the bright people on the street to get Gaze
- Dark people are not clickable
- Buy upgrades on the right
- When upgrades are bought, the icon of the upgrade spawns ontop of a clickable person, when that person is then clicked it starts a small minigame with a large multiplier on gaze earned from that click if won!
- Offline gaze earnings, up to a certain limit, the game will give you gaze passively earned when you were offline. 

## Whats New

New features: 
-Three upgrades, 
Watcher: The base upgrade, adds 0.5 passive gaze/s and costs 20, gets 1.10x more expensive each time you buy it.
Sacrifice: Eye for an eye, the theme is that you give up your eye (half of your gaze earnings per click) to get an improvement elsewhere, (2 gaze/s passive), i know this is terribly balanced but ive got no soul left in me after spending so much time on it to bother changing that.
Healer: Heals your lost eye for a cost, which gets you back 2 gaze per click, its also the most expensive upgrade. 

- Minigame function after upgrade is bought, when you click on an upgrade that upgrades icon is spawned over a person, and when that person is clicked it begins a minigame where you must click over a person that is actively running away for 16x the gaze amount. This is on a timer so you cant repeatedly do it. 
- Eye in the background that follows you and occasionally locks onto a minigamed person. 

- A new background! Drew it myself, which is why its terrible! 

- Clear all button, this was mostly for *my* debug but this is pretty useful i guess.  

- Added a confirmation popup to the clear all button

- Added a settings menu, includes volume bars for music and sfx seperately, with a keybinding hint. 

- Tweaked minigame difficulty (it isnt bugged, clicking the person does work, its just hard) 

- Added background audio and sfx on clicking, buying, and music in the chase minigame. 

- Tweaked upgrade economy and changed healer icon. 

This is hopefully pretty simple! Coded in... Gdscript, obviously, using Godot 4. 

## Credits
- SFX: Kenney Interface Sounds (kenney.nl) - CC0
- Music: "[Phantasm]" by Kevin MacLeod (incompetech.com) - CC-BY 4.0