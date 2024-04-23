# 31EDO Tuner
A  Musescore plugin for tuning scores to [31EDO](https://en.xen.wiki/w/31edo).

## Features
This plugin can be used to tune the whole score, or only a portion of it, to 31EDO.

It's compatible with the following notation systems:

- [Circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using double sharps and flats.  In this system, a sharp or a flat indicates an alteration of 2 EDO steps, and a double sharp or a double flat an alteration of 4 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/dacd45b3-dc7e-4f1e-8ed3-5fea6f26330c)

- [Neutral circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using half and sesqui sharps and flats.  In this system, a half sharp or a half flat indicates an alteration of 1 EDO step, and a sesqui sharp or a sesqui flat an alteration of 3 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/fcb25851-e60a-4892-b757-a9a29b4030b0)

- [Sagittal notation](https://en.xen.wiki/w/Sagittal_notation), using quarter tone and half tone arrows.  In this system, a quarter tone arrow indicates an alteration of 1 EDO step, and a half tone arrow indicates an alteration of 2 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/b6343855-5eb4-4666-a231-aefb26eb4dbe)

These notation systems are not mutually exclusive, the plugin can correctly tune a score which uses a mixture of them.

See [here](https://github.com/looptailG/musescore-31edo-tuner/wiki/Supported-Accidentals) for a list of every supported accidental.


## Usage
- If the score contains transposing instruments, ensure that the score is being displayed at concert pitch.  If it's not, the notes of transposing instruments will not be tuned correctly.
- If you want to tune only a portion of the score, select it before running the plugin.  If nothing is selected, the entire score will be tuned.
- Launch the plugin:
  - Musescore3: <code>Plugins</code> → <code>Tuner</code> → <code>31EDO</code>
  - Musescore4: <code>Plugins</code> → <code>Playback</code> → <code>31EDO Tuner</code>

If the score contains transposing instruments, you can safely turn off concert pitch after running the plugin, as the tuning of the notes will not be affected.

See [here](https://github.com/looptailG/musescore-31edo-tuner/wiki/Known-Issues#incorrect-handling-of-microtonal-accidental-for-transposing-instruments) for a known issue regarding transposing instruments.


## Installing
### Musescore3
- Download the file <code>31edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.  You can find the latest version [here](https://github.com/looptailG/musescore-31edo-tuner/releases/latest).
- Extract the file `31EdoTuner.qml`, and move it to Musescore's plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/3/plugins) to enable the plugin.

### Musescore4
- Download the file <code>31edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.  You can find the latest version [here](https://github.com/looptailG/musescore-31edo-tuner/releases/latest).
- Extract the folder `31edo_tuner` and move it to Musescore's plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/4/plugins)to enable the plugin.
