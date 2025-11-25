# 31EDO Tuner
A  Musescore plugin for tuning scores to [31EDO](https://en.xen.wiki/w/31edo).

## Features
This plugin can be used to tune the whole score, or only a portion of it, to 31EDO.

### Accidentals

This plugin is compatible with the following notation systems:

- [Circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using double sharps and flats.  In this system, a sharp or a flat indicates an alteration of 2 EDO steps, and a double sharp or a double flat an alteration of 4 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/dacd45b3-dc7e-4f1e-8ed3-5fea6f26330c)

- [Neutral circle of fifths notation](https://en.xen.wiki/w/31edo#Notations), using half and sesqui sharps and flats.  In this system, a half sharp or a half flat indicates an alteration of 1 EDO step, and a sesqui sharp or a sesqui flat an alteration of 3 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/fcb25851-e60a-4892-b757-a9a29b4030b0)

- [Sagittal notation](https://en.xen.wiki/w/Sagittal_notation), using quarter tone and half tone arrows.  In this system, a quarter tone arrow indicates an alteration of 1 EDO step, and a half tone arrow indicates an alteration of 2 EDO steps.  For example, a chromatic scale between <code>C</code> and <code>D</code> would be written as:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/eea3a806-9c91-436c-8e0b-3cfefbeb46f3)

These notation systems are not mutually exclusive, the plugin can correctly tune a score which uses a mixture of them.

Be sure to use the correct accidental, as there are several microtonal accidentals that look similar to each other, but not all of them are supported by this plugin.  See [here](https://github.com/looptailG/musescore-31edo-tuner/wiki/Supported-Accidentals) for a list of every supported accidental, and their name in Musescore.

This plugin remembers which accidental is applied to any given note, and will automatically apply the correct tuning offset to the following notes within the same measure.  This is also true for microtonal accidentals, for which this is usually not automatically done in Musescore.  A limitation of this is that the plugin only checks for accidentals for each voice individually, so if there are multiple voices with microtonal accidentals, it might be necessary to add an extra accidental for the first modified note in each voice.  This extra accidental can be safely made invisible, as that won't affect the plugin, as in the following example:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/ae091a16-ded2-43df-aa22-28144d39982c)

### Key Signatures

This plugin supports custom key signatures.  If the custom key signatures only contain standard accidentals, no extra action is required other than inserting the custom key signaturs into the score.

If the key signature contains microtonal accidentals, then it is necessary to also add a text (`System Text`  or `Staff Text`) to inform the plugin about the accidentals present in the key signature.  This text has to be formatted as `X.X.X.X.X.X.X`, where `X` are the accidental applied to each note, arranged according to the circle of fifths: `F.C.G.D.A.E.B`.  These accidentals are written using ASCII characters only in the following way:

| Accidental | Text |
| :--------: | :--: |
| ![doubleFlat](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/aed40ea1-31b3-4ce8-97a3-c737ec7dc51c) | `bb` |
| ![sesquiFlat](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/562b6267-9f08-417e-a8e5-5960f48c105b) | `db` |
| ![flat](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/5fe008de-b58c-4ad4-bec7-51449c2050f4) | `b` |
| ![halfFlat](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/2324736a-ccb3-4ebe-b8e2-4480019a3a93) | `d` |
| ![halfSharp](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/e903afe2-8625-442d-b8ab-5914eac0ecba) | `t` |
| ![sharp](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/8d63ed6d-6495-4f73-a4f5-2c2dde707008) | `#` |
| ![sesquiSharp](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/b167b72d-6b81-46b5-8dd7-e85dbf40ac6c) | `t#` |
| ![doubleSharp](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/83bbb0e3-00e3-4ed6-b57d-ac679d757401) | `x` |

If a note does not have an accidental in the custom key signature, you can leave the text for that note empty.

The text describing the custom key signature can be safely made invisible, as that won't affect the plugin, as in the following example:

![image](https://github.com/looptailG/musescore-31edo-tuner/assets/99362337/e005d94a-6d25-4149-896b-997a8bafc316)


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
- Download the file <code>31edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.  You can find the latest version compatible with Musescore3 [here](https://github.com/looptailG/musescore-31edo-tuner/releases/tag/v1.6.0).
- Extract the file `31EdoTuner.qml`, and move it to Musescore's plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/3/plugins#enable-disable) to enable the plugin.

### Musescore4
- Download the file <code>31edo_tuner_x.y.z.zip</code>, where <code>x.y.z</code> is the version of the plugin.  You can find the latest version [here](https://github.com/looptailG/musescore-31edo-tuner/releases/latest).
- Extract the folder `31edo_tuner` and move it to Musescore's plugin folder.
- Follow the steps listed [here](https://musescore.org/en/handbook/4/plugins#enable-disable) to enable the plugin.
