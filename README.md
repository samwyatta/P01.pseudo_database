# P01.pseudo_database
 an application for applying and searching by tags, project names or author.

This is a very unfinished project.  I plan on adding a feature for choosing the directory where the files you are interested in tagging will go.  And a save/load system for managing different directories.

at this time there is a known bug that the tags don't update when you save them (the project and author fields do update).  However, the tags do update when you restart the program.

To use this program in its current state, you need to replace every instance of 'r"D:\TestDir1"' with a string containing the file path to the directory you wish to work on, and replace 'r"D:\TestDir2"' with a string containing the file path to the directory where you will save JSONs that contain the tags, projects, authors and descriptions of the files in the other directory.
