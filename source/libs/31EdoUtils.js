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
	"bbb": -3,
	"bb": -2,
	"b": -1,
	"": 0,
	"#": 1,
	"x": 2,
	"#x": 3
};

// Map every EDO step to an array of every possible enharmonic spelling for that
// note.  The array are ordered alphabetically.
const ENHARMONIC_EQUIVALENTS = {};
for (let i = 0; i < 31; i++)
{
	let enharmonicequivalents = [];
	
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
				enharmonicequivalents.push(note + accidental);
			}
		}
	}
	
	ENHARMONIC_EQUIVALENTS[i] = enharmonicequivalents;
}

/**
 * Return a Set containing every note that is enharmonically equivalent to the
 * input note.
 */
function getEnharmonicEquivalents(note)
{
	
}

/**
 * Choose the most appropriate enharmonic spelling for the input note.
 */
function chooseEnharmonicEquivalent(note, keySignature, previousAccidentals)
{
	
}
