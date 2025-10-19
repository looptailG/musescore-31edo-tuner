/*
	A collection of functions and constants about 31 EDO.
	Copyright (C) 2025 Alessandro Culatti

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

const VERSION = "1.0.0";

// Distance of each note in EDO steps from the note C.
const NOTES_STEPS = {
	"C": 0,
	"D": 5,
	"E": 10,
	"F": 13,
	"G": 18,
	"A": 23,
	"B": 28
};

// Size in EDO stpes of each accidental that can be used for respelling notes
// according to enharmonic equivalence.
const ENHARMONIC_ACCIDENTALS_STEPS = {
	"FLAT3": -6,
	"FLAT2": -4,
	"MIRRORED_FLAT2": -3,
	"FLAT": -2,
	"MIRRORED_FLAT": -1,
	"NONE": 0,
	"SHARP_SLASH": 1,
	"SHARP": 2,
	"SHARP_SLASH4": 3,
	"SHARP2": 4,
	"SHARP3": 6
};

// Map every EDO step to an array of every possible enharmonic spelling for that
// EDO step.  The arrays contains objects with the properties "NOTE_NAME" and
// "ACCIDENTAL", and are ordered according to the number of EDO steps of the
// accidental applied to the note.
const ENHARMONIC_EQUIVALENTS = {};
for (let i = 0; i < 31; i++)
{
	ENHARMONIC_EQUIVALENTS[i] = [];
}
for (const note in NOTES_STEPS)
{
	for (const accidental in ENHARMONIC_ACCIDENTALS_STEPS)
	{
		let edoSteps = NOTES_STEPS[note] + ENHARMONIC_ACCIDENTALS_STEPS[accidental];
		edoSteps %= 31;
		while (edoSteps < 0)
		{
			edoSteps += 31;
		}
		
		let newEnharmonicEquivalent = {};
		newEnharmonicEquivalent["NOTE_NAME"] = note;
		newEnharmonicEquivalent["ACCIDENTAL"] = accidental;
		ENHARMONIC_EQUIVALENTS[edoSteps].push(newEnharmonicEquivalent);
	}
}
for (let i = 0; i < 31; i++)
{
	ENHARMONIC_EQUIVALENTS[i].sort((a, b) => ENHARMONIC_ACCIDENTALS_STEPS[a["ACCIDENTAL"]] - ENHARMONIC_ACCIDENTALS_STEPS[b["ACCIDENTAL"]]);
}

/**
 * Choose the most appropriate enharmonic spelling for the input note, according
 * to the key signature and the eventual accidentals in the measure.
 */
function chooseEnharmonicEquivalent(edoStep, keySignature, previousAccidentals)
{
	let noteName = "";
	let accidental = "";
	
	let flatFound = false;
	let sharpFound = false;
	
	// Search if the input EDO step is present in the key signature, or as a
	// previously altered note in the current measure.
	outerLoop: for (let i = 0; i < ENHARMONIC_EQUIVALENTS[edoStep].length; i++)
	{
		let possibleNoteName = ENHARMONIC_EQUIVALENTS[edoStep][i]["NOTE_NAME"];
		let possibleAccidental = ENHARMONIC_EQUIVALENTS[edoStep][i]["ACCIDENTAL"];
		
		if (keySignature.hasOwnProperty(possibleNoteName))
		{
			let keySignatureAccidental = keySignature[possibleNoteName];
			if (ENHARMONIC_ACCIDENTALS_STEPS[keySignatureAccidental] > 0)
			{
				sharpFound = true;
			}
			else if (ENHARMONIC_ACCIDENTALS_STEPS[keySignatureAccidental] < 0)
			{
				flatFound = true;
			}
			if (possibleAccidental === keySignatureAccidental)
			{
				noteName = possibleNoteName;
				accidental = possibleAccidental;
				break;
			}
		}
		
		// previousAccidentals has as keys both the note names and the octave in
		// which the accidental was found.  For the purpose of choosing the most
		// appropriate accidental, we don't consider the octave, as if the
		// accidental is found in a specific octave, it's likely to be the
		// correct enharmonic spelling in another octave as well.
		for (let previousAlteredNote in previousAccidentals)
		{
			let previousAccidental = previousAccidentals[previousAlteredNote];
			if (ENHARMONIC_ACCIDENTALS_STEPS[previousAccidental] > 0)
			{
				sharpFound = true;
			}
			else if (ENHARMONIC_ACCIDENTALS_STEPS[previousAccidental] < 0)
			{
				flatFound = true;
			}
			
			// By using inclutdes() we ignore the octave in the string.
			if (previousAlteredNote.includes(possibleNoteName))
			{
				if (possibleAccidental === previousAccidental)
				{
					noteName = possibleNoteName;
					accidental = possibleAccidental;
					break outerLoop;
				}
			}
		}
	}
	
	if (!noteName || !accidental)
	{
		
	}
}
