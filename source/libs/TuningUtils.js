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

const VERSION = "1.1.1";

// Size in cents of a justly tuned perfect fifth.
const JUST_FIFTH = 1200.0 * Math.log2(3 / 2);
// Size in cents of a 12EDO perfect fifth.
const DEFAULT_FIFTH = 700.0;
// Size in cents of the smallest fifth in the diatonic range.  It's equal to the
// 7EDO fifth.
const SMALLEST_DIATONIC_FIFTH = 1200.0 / 7 * 4;
// Size in cents of the largest fifth in the diatonic range.  It's equal to the
// 5EDO fifth.
const LARGEST_DIATONIC_FIFTH = 1200.0 / 5 * 3;

// Size in cents of the syntonic comma.
const SYNTONIC_COMMA = 1200.0 * Math.log2(81 / 80);

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
