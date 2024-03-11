# 31EDO Tuner
A  Musescore plugin for tuning scores to 31EDO.


## Features
This plugin tunes the whole score to 31EDO.

It's compatible with the following notation systems:

- Circle of fifths notation, using double sharps and flats.  In this system, a sharp or a flat indicates an alteration of 2 EDO steps, and a double sharp or flat an alteration of 4 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be the following: <code>C</code> <code>Dbb</code> <code>C#</code> <code>Db</code> <code>Cx</code> <code>D</code>.

- Neutral circle of fifths notation, using half and sesqui sharps and flats.  In this system, a  halfsharp or a flat indicates an alteration of 1 EDO step, and a sesqui sharp or flat an alteration of 3 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be the following: <code>C</code> <code>Ct</code> <code>C#</code> <code>Db</code> <code>Dd</code> <code>D</code>.

These notation systems are not mutually exclusive, the plugin can correctly tune a file which uses a mixture of them.
