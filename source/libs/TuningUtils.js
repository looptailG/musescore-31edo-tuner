/*
	A collection of functions and constants about tuning.
	Copyright (C) 2024 Alessandro Culatti

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

const VERSION = "1.3.0";

// Size in cents of a justly tuned perfect fifth.
const JUST_FIFTH = intervalInCents(3 / 2);
// Size in cents of a 12EDO perfect fifth.
const DEFAULT_FIFTH = 700.0;
// Size in cents of the smallest fifth in the diatonic range.  It's equal to the
// 7EDO fifth.
const SMALLEST_DIATONIC_FIFTH = 1200.0 / 7 * 4;
// Size in cents of the largest fifth in the diatonic range.  It's equal to the
// 5EDO fifth.
const LARGEST_DIATONIC_FIFTH = 1200.0 / 5 * 3;

// Size in cents of the syntonic comma.
const SYNTONIC_COMMA = intervalInCents(81 / 80);

// Note distance in the circle of fifths, from the note C.
const CIRCLE_OF_FIFTHS_DISTANCE = {
	"Fbbb": -22, "Cbbb": -21, "Gbbb": -20, "Dbbb": -19, "Abbb": -18, "Ebbb": -17, "Bbbb": -16,
	"Fbb": -15,  "Cbb": -14,  "Gbb": -13,  "Dbb": -12,  "Abb": -11,  "Ebb": -10,  "Bbb": -9,
	"Fb": -8,    "Cb": -7,    "Gb": -6,    "Db": -5,    "Ab": -4,    "Eb": -3,    "Bb": -2,
	"F": -1,     "C": 0,      "G": 1,      "D": 2,      "A": 3,      "E": 4,      "B": 5,
	"F#": 6,     "C#": 7,     "G#": 8,     "D#": 9,     "A#": 10,    "E#": 11,    "B#": 12,
	"Fx": 13,    "Cx": 14,    "Gx": 15,    "Dx": 16,    "Ax": 17,    "Ex": 18,    "Bx": 19,
	"F#x": 20,   "C#x": 21,   "G#x": 22,   "D#x": 23,   "A#x": 24,   "E#x": 25,   "B#x": 26,
};

/**
 * Distance between two notes according to the circle of fifths.
 */
function circleOfFifthsDistance(n1, n2, tpcMode = "tpc1")
{
	var n1Tpc;
	switch (typeof n1)
	{
		case "object":
			n1Tpc = n1[tpcMode] - 14;
			break;
		
		case "string":
			n1Tpc = CIRCLE_OF_FIFTHS_DISTANCE[n1];
			break;
		
		default:
			throw "Unsupported n1 type: " + (typeof n1);
	}
	
	var n2Tpc;
	switch (typeof n2)
	{
		case "object":
			n2Tpc = n2[tpcMode] - 14;
			break;
		
		case "string":
			n2Tpc = CIRCLE_OF_FIFTHS_DISTANCE[n2];
			break;
		
		default:
			throw "Unsupported n2 type: " + (typeof n2);
	}
	
	return n1Tpc - n2Tpc;
}

/**
 * Return the input frequency ratio in cents.
 */
function intervalInCents(frequencyRatio)
{
	return 1200 * Math.log2(frequencyRatio);
}

/**
 * Return the offset in cents for the input scale degree in the harmonic scale.
 */
function harmonicScaleOffset(scaleDegree)
{
	var harmonic = harmonicScaleHarmonic(scaleDegree);
	var interval = intervalInCents(harmonic / 16);
	var defaultTuning = 100.0 * scaleDegree;
	return interval - defaultTuning;
}

/**
 * Return the harmonic corresponding to the input scale degree in the harmonic
 * scale.
 */
function harmonicScaleHarmonic(scaleDegree)
{
	switch (scaleDegree)
	{
		case 0:
			return 16;
		
		case 1:
			return 17;
		
		case 2:
			return 18;
		
		case 3:
			return 19;
		
		case 4:
			return 20;
		
		case 5:
			return 21;
		
		case 6:
			return 22;
		
		case 7:
			return 24;
		
		case 8:
			return 26;
		
		case 9:
			return 27;
		
		case 10:
			return 28;
		
		case 11:
			return 30;
		
		default:
			throw "Invalid scale degree: " + scaleDegree;
	}
}

/**
 * Calculate the tuning offset for an EDO tuning.
 */
function edoTuningOffset(
	note, noteName, accidental, octave, referenceNote,
	stepSize, fifthDeviation, supportedAccidentals, accidentalData,
	previousAccidentals, customKeySignature,
	logger
) {
	logger.trace("Tuning note: " + noteName + " " + accidental + " " + octave);
	let actualAccidental = accidental;
	let effectiveAccidental = accidental;
	let fullNoteName = noteName + accidental;
	let noteNameOctave = noteName + octave;
	
	let tuningOffset;
	
	tuningOffset = -circleOfFifthsDistance(note, referenceNote) * fifthDeviation;
	logger.trace("Base tuning offset: " + tuningOffset);
	
	// Certain accidentals, like the microtonal accidentals, are not
	// conveyed by the tpc property, but are instead handled directly via a
	// tuning offset.
	// Check which accidental is applied to the note.
	if (effectiveAccidental == "NONE")
	{
		// If the note does not have any accidental applied to it, check if
		// the same note previously in the measure was modified by a
		// microtonal accidental.
		if (previousAccidentals.hasOwnProperty(noteNameOctave))
		{
			effectiveAccidental = previousAccidentals[noteNameOctave];
			logger.trace("Applying the following accidental to the current note from a previous note in the measure: " + effectiveAccidental);
		}
		// If the note still does not have an accidental applied to itself,
		// check if it's modified by a custom key signature.
		if (effectiveAccidental == "NONE")
		{
			if (customKeySignature.hasOwnProperty(noteName))
			{
				effectiveAccidental = customKeySignature[noteName];
				logger.trace("Applying the following accidental from the custom key signature: " + effectiveAccidental);
			}
		}
	}
	else
	{
		// Save the accidental in the previous accidentals map for this
		// note.
		previousAccidentals[noteNameOctave] = actualAccidental;
	}
	
	// Check if the accidental is handled by a tuning offset.
	if (!accidentalData[effectiveAccidental]["TPC"])
	{
		// Undo the default tuning offset which is applied to certain
		// accidentals.
		// The default tuning offset is applied only if an actual microtonal
		// accidental is applied to the current note.
		let actualAccidentalOffset = accidentalData[actualAccidental]["DEFAULT_OFFSET"];
		tuningOffset -= actualAccidentalOffset;
		logger.trace("Undoing the default tuning offset of: " + actualAccidentalOffset);
		
		// Apply the tuning offset for this specific accidental.
		let edoSteps = supportedAccidentals[effectiveAccidental];
		if (edoSteps === undefined)
		{
			throw "Unsupported accidental: " + effectiveAccidental;
		}
		tuningOffset += edoSteps * stepSize;
		logger.trace("Offsetting the tuning by " + edoSteps + " EDO steps.");
	}
	
	logger.trace("Final tuning offset: " + tuningOffset);
	return tuningOffset;
}
