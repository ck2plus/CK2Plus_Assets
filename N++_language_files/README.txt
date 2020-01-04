=== Instructions: ===

If you used previous versions by importing via "Language -> Define your language...", remove them there.
Remove CK2.xml from "Notepad++/plugins/API".

Copy both folders into "appData\Roaming\Notepad++" (or into your portable Notepad++ installation folder), overwriting existing files if they exist.
You can choose to only copy the regular or dark mode variants.

Run Notepad++, open "Settings -> Preferences -> Auto-Completion" and check "Enable auto-completion on each input" and "Function completion".



=== Which language highlighting to use: ===

CK2
All text files in
 - "common"
 - "decisions"
 - "dlc_metadata"
 - "events"
 - "history"
 - "maps"
And also
 - "interface/portrait_properties/00_portrait_properties.txt"
 - "music/songs.txt"

CK2Localisation - .csv files as well as customizable localisation .txt files

CK2Graphics - .gui and .gfx files in both "interface" and "launcher/interface"

CK2Save - uncompressed .ck2 save files - be sure to replace all '=' with ' = ' to make proper use of it. Extract compressed saves with your favourite archiving tool (WinRAR, 7-Zip, etc.)



=== Other instructions: ===

You can disable the false positive highlighting of certain terms by unticking "Prefix mode" in "Language -> User Defined Language -> Define your language... -> CK2 -> Keywords Lists"