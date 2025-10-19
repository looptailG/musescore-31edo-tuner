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

// Size in EDO stpes of each accidental.
const ACCIDENTALS_STPES = {
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
// EDO step.  The arrays are ordered alphabetically.
const ENHARMONIC_EQUIVALENTS = {};
for (let i = 0; i < 31; i++)
{
	let enharmonicEquivalents = [];
	
	for (const note in NOTES_STEPS)
	{
		for (const accidental in ACCIDENTALS_STPES)
		{
			let edoSteps = NOTES_STEPS[note] + ACCIDENTALS_STPES[accidental];
			edoSteps %= 31;
			while (edoSteps < 0)
			{
				edoSteps += 31;
			}
			
			if (i == edoSteps)
			{
				enharmonicEquivalents.push(note + accidental);
			}
		}
	}
	
	enharmonicEquivalents.sort();
	ENHARMONIC_EQUIVALENTS[i] = enharmonicEquivalents;
}

/**
 * Choose the most appropriate enharmonic spelling for the input note.
 */
function chooseEnharmonicEquivalent(edoStep, keySignature, previousAccidentals)
{
	let noteName = "";
	let accidental = "";
	
	for (let i = 0; i < ENHARMONIC_EQUIVALENTS[edoStep].length; i++)
	{
		
	}
}
