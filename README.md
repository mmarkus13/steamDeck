# steamDeck

*mergeDeckRecordings.sh* allows to merge and convert all .m4s files into mp4 format.
This is a workaround till Valve does not make any official implementation.

Currently I've set up a NAS Backup (via the Drive app) to the recordings folder
``~/.local/share/Steam/userdata/<your steam id>/gamerecordings/``
to be able to easily convert these to mp4 and upload to youtube.


# Usage

put the script into the mentioned folder above and it will pull & convert all the data from subfolders to the same folder as the script is.
The file names are equavalent to the subfolder name.
If a video file already exists with that name (for example when the conversion was done already on that folder when re-running the script..) then it will automatically skip those.
Run the script.
