# 31EDO Tuner
A  Musescore plugin for tuning scores to [31EDO](https://en.xen.wiki/w/31edo).


## Features
This plugin tunes the whole score to 31EDO.

It's compatible with the following notation systems:

- [Circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using double sharps and flats.  In this system, a sharp <code>#</code> or a flat <code>b</code> indicates an alteration of 2 EDO steps, and a double sharp <code>x</code> or a double flat <code>bb</code> an alteration of 4 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as: <code>C</code> <code>Dbb</code> <code>C#</code> <code>Db</code> <code>Cx</code> <code>D</code>.

- [Neutral circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using half and sesqui sharps and flats.  In this system, a  half sharp <code>t</code> or half flat <code>d</code> indicates an alteration of 1 EDO step, and a sesqui sharp <code>t#</code> or a sesqui flat <code>db</code> an alteration of 3 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as: <code>C</code> <code>Ct</code> <code>C#</code> <code>Db</code> <code>Dd</code> <code>D</code>.

These notation systems are not mutually exclusive, the plugin can correctly tune a file which uses a mixture of them.
