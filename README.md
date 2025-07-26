# RetroPie-RSync
An rsync script for Retropie, allowing you to sync roms, saves and save states to and from your NAS.

## NAS file structure ##
This sync script assumes a lot:

* You are primarily using RetroArch and using that folder structure
  * You have configured RetroArch to have your Media, Saves and Save States in a different folder from your ROMs (see image below)
  * You have RetroArch configured to sort Saves and Save States into Folders by Content Directory. This ensurtes your GBA saves are separate and clearly labelled from your PSX saves.
* Your NAS has a folder for RetroGames and you have SSH enabled.

<img width="497" height="757" alt="image" src="https://github.com/user-attachments/assets/a8e035d6-7354-4cb5-89bd-24b8fd0df630" />

This example folder structure includes an additional save and savestate subdirectory for my RetroPie Profiles: https://github.com/DeltaGemini/retropie_profiles

## Installation Instructions ##
1) Download and save the retropie-rsync.sh script and put it in your RetroPie folder
2) Use SSH to make the script executable: chmod +x retropie-sync.sh
3) Edit the configuration section (lines near the top) to set:
  - Your NAS IP
  - SSH port and username
  - NAS path where RetroPie folders live
  - Which ROM/media folders to exclude. If nothing is here, it will sync EVERY system and game.
8) Use ssh to run it manually (./retropie-sync.sh).

I have an option to run it from the RetroPie menu in EmulationStation, but I don't have time to write up those instructions.
