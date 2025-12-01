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

// Size in cents of an EDO step.
const STEP_SIZE = 1200.0 / 31;
// Difference in cents between a 12EDO and a 31EDO fifth.
const FIFTH_DEVIATION = 700.0 - 18 * STEP_SIZE;

// Map containing the amount of EDO steps of every supported accidental.
const SUPPORTED_ACCIDENTALS = {
	"NONE": 0,
	"FLAT": -2,
	"NATURAL": 0,
	"SHARP": 2,
	"SHARP2": 4,
	"FLAT2": -4,
	"SHARP3": 6,
	"FLAT3": -6,
	"NATURAL_FLAT": -2,
	"NATURAL_SHARP": 2,
	"ARROW_DOWN": -1,
	"MIRRORED_FLAT": -1,
	"MIRRORED_FLAT2": -3,
	"SHARP_SLASH": 1,
	"LOWER_ONE_SEPTIMAL_COMMA": -1,
	"SHARP_SLASH4": 3,
	"SAGITTAL_11MDD": -1,
	"SAGITTAL_11MDU": 1,
	"SAGITTAL_FLAT": -2,
	"SAGITTAL_SHARP": 2,
};

// Regex used for checking if a string is valid as a custom key signature.
const KEY_SIGNATURE_REGEX = /^(x|t#|#|t|h|d|b|db|bb|)(?:\.(?:x|t#|#|t|h|d|b|db|bb|)){6}$/;
// Array containing the notes in the order they appear in the custom key
// signature string.
const KEY_SIGNATURE_NOTE_ORDER = ["F", "C", "G", "D", "A", "E", "B"];

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

// List of accidentals that can be used for respelling notes according to
// enharmonic equivalence.
const ENHARMONIC_ACCIDENTALS = [
	"FLAT3",
	"FLAT2",
	"MIRRORED_FLAT2",
	"FLAT",
	"MIRRORED_FLAT",
	"NONE",
	"SHARP_SLASH",
	"SHARP",
	"SHARP_SLASH4",
	"SHARP2",
	"SHARP3"
];

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
	for (const accidental of ENHARMONIC_ACCIDENTALS)
	{
		let edoSteps = NOTES_STEPS[note] + SUPPORTED_ACCIDENTALS[accidental];
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
	ENHARMONIC_EQUIVALENTS[i].sort((a, b) => SUPPORTED_ACCIDENTALS[a["ACCIDENTAL"]] - SUPPORTED_ACCIDENTALS[b["ACCIDENTAL"]]);
}

/**
 * Check if the input text is valid as a custom key signature, and if yes parse
 * it and update the input key signature map.
 */
function parseCustomKeySignature(annotationText, customKeySignature, logger = null)
{
	annotationText = annotationText.replace(/\s*/g, "");
	if (KEY_SIGNATURE_REGEX.test(annotationText))
	{
		if (logger)
		{
			logger.log("Applying custom key signature: " + annotationText);
		}
		
		// Empty the input key signature.  Can't use `customKeySignature = {}`,
		// because that would break the reference, and the new key signature
		// wouldn't be visible from outside this function.
		for (let key in customKeySignature)
		{
			delete customKeySignature[key];
		}
		try
		{
			let annotationTextSplitted = annotationText.split(".");
			for (let i = 0; i < annotationTextSplitted.length; i++)
			{
				let currentNote = KEY_SIGNATURE_NOTE_ORDER[i];
				let currentAccidental = annotationTextSplitted[i];
				let accidentalName = "";
				
				switch (currentAccidental)
				{
					case "bb":
							accidentalName = "FLAT2";
							break;
						
						case "b":
							accidentalName = "FLAT";
							break;
						
						case "":
						case "h":
							accidentalName = "NONE";
							break;
						
						case "#":
							accidentalName = "SHARP";
							break;
						
						case "x":
							accidentalName = "SHARP2";
							break;
						
						case "db":
							accidentalName = "MIRRORED_FLAT2";
							break;
						
						case "d":
							accidentalName = "MIRRORED_FLAT";
							break;

						case "t":
							accidentalName = "SHARP_SLASH";
							break;

						case "t#":
							accidentalName = "SHARP_SLASH4";
							break;

						default:
							throw "Unsupported accidental in the custom key signature: " + currentAccidental;
				}
				if (accidentalName)
				{
					if (logger)
					{
						logger.trace("Note: " + currentNote + "; Accidental: " + accidentalName);
					}
					
					customKeySignature[currentNote] = accidentalName;
				}
			}
		}
		catch (error)
		{
			if (logger)
			{
				logger.err(error);
			}
			
			customKeySignature = {};
		}
	}
	else
	{
		if (logger)
		{
			logger.trace("Text not valid as a key signature: " + annotationText);
		}
	}
}

/**
 * Choose the most appropriate enharmonic spelling for the input note, according
 * to the key signature and the eventual accidentals in the measure.
 */
function chooseEnharmonicEquivalent(edoStep, keySignature, previousAccidentals)
{
	let noteName = "";
	let accidental = "";
	
	let sharpFound = false;
	let flatFound = false;
	
	// Search if the input EDO step is present in the key signature, or as a
	// previously altered note in the current measure.
	outerLoop: for (let i = 0; i < ENHARMONIC_EQUIVALENTS[edoStep].length; i++)
	{
		let possibleNoteName = ENHARMONIC_EQUIVALENTS[edoStep][i]["NOTE_NAME"];
		let possibleAccidental = ENHARMONIC_EQUIVALENTS[edoStep][i]["ACCIDENTAL"];
		
		if (keySignature.hasOwnProperty(possibleNoteName))
		{
			let keySignatureAccidental = keySignature[possibleNoteName];
			if (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[keySignatureAccidental]] > 0)
			{
				sharpFound = true;
			}
			else if (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[keySignatureAccidental]] < 0)
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
			if (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[previousAccidental]] > 0)
			{
				sharpFound = true;
			}
			else if (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[previousAccidental]] < 0)
			{
				flatFound = true;
			}
			
			// By using includes() we ignore the octave in the string.
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
	
	// If there weren't a suitable note and accidental in the key signature or
	// in the previously altered notes, try to find the best guess.  Prefer
	// smaller accidentals if possible.
	if (!noteName || !accidental)
	{
		for (let i = 0; i < ENHARMONIC_EQUIVALENTS[edoStep].length; i++)
		{
			let currentNoteName = ENHARMONIC_EQUIVALENTS[edoStep][i]["NOTE_NAME"];
			let currentAccidental = ENHARMONIC_EQUIVALENTS[edoStep][i]["ACCIDENTAL"];
			
			if (currentAccidental === "NONE")
			{
				noteName = currentNoteName;
				accidental = currentAccidental;
				
				// Check if the note is altered by the key signature or by a
				// previous accidental in the measure, and in case replace the
				// accidental with a natural sign.
				if (keySignature.hasOwnProperty(noteName))
				{
					accidental = "NATURAL";
				}
				// TODO: this logic is probably wrong.
				for (let previousAlteredNote in previousAccidentals)
				{
					let previousAccidental = previousAccidentals[previousAlteredNote];
					if (previousAccidental !== "NATURAL")
					{
						accidental = "NATURAL";
					}
				}
				
				// Break the loop, as we can't find anything better than a
				// natural.
				break;
			}
			
			if (
				(sharpFound && (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[currentAccidental]] > 0))
				|| (flatFound && (SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[currentAccidental]] < 0))
			) {
				if (accidental)
				{
					if (abs(SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[currentAccidental]]) < abs(SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[accidental]]))
					{
						noteName = currentNoteName;
						accidental = currentAccidental;
					}
				}
				else
				{
					noteName = currentNoteName;
					accidental = currentAccidental;
				}
			}
		}
	}
	
	// If we still haven't found any suitable accidental, simply return the
	// smallest possible accidental for this EDO step.
	if (!noteName || !accidental)
	{
		let smallestAccidental = Number.MAX_VALUE;
		
		for (let i = 0; i < ENHARMONIC_EQUIVALENTS[edoStep].length; i++)
		{
			let currentNoteName = ENHARMONIC_EQUIVALENTS[edoStep][i]["NOTE_NAME"];
			let currentAccidental = ENHARMONIC_EQUIVALENTS[edoStep][i]["ACCIDENTAL"];
			
			if (abs(SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[currentAccidental]]) < smallestAccidental)
			{
				smallestAccidental = abs(SUPPORTED_ACCIDENTALS[ENHARMONIC_ACCIDENTALS[currentAccidental]]);
				noteName = noteName;
				accidental = currentAccidental;
			}
		}
	}
	
	let returnValue = {};
	returnValue["NOTE_NAME"] = noteName;
	returnValue["ACCIDENTAL"] = accidental;
	return returnValue;
}

/**
 * Starting from the current position in the score
 */
function backSearchAccidentals(cursor, keySignature, previousAccidentals, logger = null)
{
	// Empty the key signature and the previous accidentals in the measure.
	// Can't assign them to {}, because that would break the reference, and they
	// wouldn't be visible from outside this function.
	for (let key in keySignature)
	{
		delete keySignature[key];
	}
	for (let key in previousAccidentals)
	{
		delete previousAccidentals[key];
	}
	
	if (cursor.segment)
	{
		cursor.rewind(Cursor.SELECTION_START);
		let startTick = cursor.tick;
		if (startTick != 0)
		{
			if (logger)
			{
				logger.log("Back searching accidentals from tick: " + startTick);
			}
			
			let measureChanged = false;
			
			while (cursor.segment)
			{
				
				
				cursor.prev();
			}
			
			cursor.rewind(Cursor.SELECTION_START);
		}
		else
		{
			if (logger)
			{
				logger.trace("Starting from the beginning of the score, no need to back search accidentals.");
			}
		}
	}
	else
	{
		if (logger)
		{
			logger.trace("Iterating over the entire score, no need to back search accidentals.");
		}
	}
}
