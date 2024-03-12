# 31EDO Tuner
A  Musescore plugin for tuning scores to [31EDO](https://en.xen.wiki/w/31edo).


## Features
This plugin tunes the whole score to 31EDO.

It's compatible with the following notation systems:

- [Circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using double sharps and flats.  In this system, a sharp <code>#</code> or a flat <code>b</code> indicates an alteration of 2 EDO steps, and a double sharp <code>x</code> or a double flat <code>bb</code> an alteration of 4 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as: <code>C</code> <code>Dbb</code> <code>C#</code> <code>Db</code> <code>Cx</code> <code>D</code>.

- [Neutral circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using half and sesqui sharps and flats.  In this system, a  half sharp <code>t</code> or half flat <code>d</code> indicates an alteration of 1 EDO step, and a sesqui sharp <code>t#</code> or a sesqui flat <code>db</code> an alteration of 3 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as: <code>C</code> <code>Ct</code> <code>C#</code> <code>Db</code> <code>Dd</code> <code>D</code>.

These notation systems are not mutually exclusive, the plugin can correctly tune a file which uses a mixture of them.


## Usage
- If the score contains transposing instruments, ensure that the score is being displayed at concert pitch.  If it's not, the notes of transposing instruments will not be tuned correctly.
- Launch the plugin:
  - Musescore3: Plugins -> Tuner -> 31Edo
  - Musescore4: Plugins -> Playback -> 31EDO Tuner

At this point your score will be tuned according to 31EDO.

If the score contains transposing instruments, you can safely turn off concert pitch after running the plugin, as the tuning of the notes will not be affected.


## Installing
### Musescore3
- Download the file <code>31_edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.
- Extract the folder <code>31_edo_tuner</code>, navigate inside it and copy the file <code>31EdoTuner.qml</code> inside Musescore3 plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/3/plugins) to enable the plugin.

### Musescore4
- Download the file <code>31_edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.
- Extract the folder <code>31_edo_tuner</code> and copy it inside Musescore4 plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/4/plugins) to enable the plugin.
