/*
	A collection of functions and constants about 31 EDO.
	Copyright (C) 2026 Alessandro Culatti

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
	"SAGITTAL_SHARP": 2
};

// List of supported microtonal accidentals.
const SUPPORTED_MICROTONAL_ACCIDENTALS = [
	"ARROW_DOWN",
	"MIRRORED_FLAT",
	"MIRRORED_FLAT2",
	"SHARP_SLASH",
	"LOWER_ONE_SEPTIMAL_COMMA",
	"SHARP_SLASH4",
	"SAGITTAL_11MDD",
	"SAGITTAL_11MDU",
	"SAGITTAL_FLAT",
	"SAGITTAL_SHARP"
];

// Regex used for checking if a string is valid as a custom key signature.
const KEY_SIGNATURE_REGEX = /^(x|t#|#|t|h|d|b|db|bb|)(?:\.(?:x|t#|#|t|h|d|b|db|bb|)){6}$/;
// Array containing the notes in the order they appear in the custom key
// signature string.
const KEY_SIGNATURE_NOTE_ORDER = ["F", "C", "G", "D", "A", "E", "B"];

const STANDARD_KEY_SIGNATURES = {
	"-7": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "FLAT", "B": "FLAT"},
	"-6": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "FLAT", "B": "NONE"},
	"-5": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "NONE", "B": "NONE"},
	"-4": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "NONE", "E": "NONE", "B": "NONE"},
	"-3": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"-2": {"F": "FLAT", "C": "FLAT", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"-1": {"F": "FLAT", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"0": {"F": "NONE", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"1": {"F": "SHARP", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"2": {"F": "SHARP", "C": "SHARP", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"3": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
	"4": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "NONE", "E": "NONE", "B": "NONE"},
	"5": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "NONE", "B": "NONE"},
	"6": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "SHARP", "B": "NONE"},
	"7": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "SHARP", "B": "SHARP"}
};

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
	"NATURAL",
	"SHARP_SLASH",
	"SHARP",
	"SHARP_SLASH4",
	"SHARP2",
	"SHARP3"
];

// Map every EDO step to an array of every possible enharmonic spelling for that
// EDO step.  The arrays contains objects with the properties "NOTE_NAME",
// "ACCIDENTAL" and "OCTAVE_SHIFT", and are ordered according to the number of
// EDO steps of the accidental applied to the note.
const ENHARMONIC_EQUIVALENTS = {};
for (let i = 0; i < 31; i++)
{
	ENHARMONIC_EQUIVALENTS[i] = [];
}
for (const note in NOTES_STEPS)
{
	for (const accidental of ENHARMONIC_ACCIDENTALS)
	{
		if (accidental === "NATURAL")
		{
			continue;
		}
		
		let edoSteps = NOTES_STEPS[note] + SUPPORTED_ACCIDENTALS[accidental];
		
		let octaveShift;
		if (edoSteps < 0)
		{
			octaveShift = -1;
		}
		else if (edoSteps >= 31)
		{
			octaveShift = 1;
		}
		else
		{
			octaveShift = 0;
		}
		
		edoSteps %= 31;
		while (edoSteps < 0)
		{
			edoSteps += 31;
		}
		
		let newEnharmonicEquivalent = {};
		newEnharmonicEquivalent["NOTE_NAME"] = note;
		newEnharmonicEquivalent["ACCIDENTAL"] = accidental;
		newEnharmonicEquivalent["OCTAVE_SHIFT"] = octaveShift;
		ENHARMONIC_EQUIVALENTS[edoSteps].push(newEnharmonicEquivalent);
	}
}
for (let i = 0; i < 31; i++)
{
	ENHARMONIC_EQUIVALENTS[i].sort((a, b) => SUPPORTED_ACCIDENTALS[a["ACCIDENTAL"]] - SUPPORTED_ACCIDENTALS[b["ACCIDENTAL"]]);
}

/**
 * Return a note enharmonically equivalent to the input one, but written without
 * using microtonal accidentals.
 */ 
function getNonMicrotonalEnharmonicEquivalent(note)
{
	switch (note)
	{
		case "Cdb":
			return "B";
		
		case "Cd":
			return "B#";
		
		case "Ct":
			return "Dbb";
		
		case "Ct#":
			return "Db";
		
		case "Ddb":
			return "C#";
		
		case "Dd":
			return "Cx";
		
		case "Dt":
			return "Ebb";
		
		case "Dt#":
			return "Eb";
		
		case "Edb":
			return "D#";
		
		case "Ed":
			return "Dx";
		
		case "Et":
			return "Fb";
		
		case "Et#":
			return "F";
		
		case "Fdb":
			return "E";
		
		case "Fd":
			return "E#";
		
		case "Ft":
			return "Gbb";
		
		case "Ft#":
			return "Gb";
		
		case "Gdb":
			return "F#";
		
		case "Gd":
			return "Fx";
		
		case "Gt":
			return "Abb";
		
		case "Gt#":
			return "Ab";
		
		case "Adb":
			return "G#";
		
		case "Ad":
			return "Gx";
		
		case "At":
			return "Bbb";
		
		case "At#":
			return "Bb";
		
		case "Bdb":
			return "A#";
		
		case "Bd":
			return "Ax";
		
		case "Bt":
			return "Cb";
		
		case "Bt#":
			return "C";
		
		default:
			throw "Unsupported note for respelling without microtonal accidentals: " + note;
	}
}

/**
 * Check if the input text is valid as a custom key signature, and if yes parse
 * it and update the input key signature map.
 */
function parseCustomKeySignature(annotationText, customKeySignature, logger)
{
	annotationText = annotationText.replace(/\s*/g, "");
	if (KEY_SIGNATURE_REGEX.test(annotationText))
	{
		logger.log("Applying custom key signature: " + annotationText);
		
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
					logger.trace("Note: " + currentNote + "; Accidental: " + accidentalName);
					
					customKeySignature[currentNote] = accidentalName;
				}
			}
		}
		catch (error)
		{
			logger.err(error);
			
			customKeySignature = {};
		}
	}
	else
	{
		logger.trace("Text not valid as a key signature: " + annotationText);
	}
}

/**
 * Search for the previous accidental which is applied to the input note.
 */
function searchPreviousAccidental(note, noteName, octave, logger)
{
	logger.log("Searching previous accidental for note: " + noteName + " " + octave);
	
	// Create a cursor at the position of the input note.
	let segment = note.parent.parent;
	let cursor = curScore.newCursor();
	cursor.voice = note.voice;
	cursor.staffIdx = note.staff.part.startTrack / 4;
	cursor.rewindToTick(segment.tick);
	
	// Check what accidental, if any, is applied to the current note by a
	// previous key signature or accidental.
	// Check if a standard key signature changes the current note.
	let keySignature = cursor.keySignature;
	let previousAccidental = STANDARD_KEY_SIGNATURES[keySignature][noteName];
	logger.log("Key signature: " + keySignature + "; Accidental: " + previousAccidental);
	// Iterate on the previous elements, to search for a custom key signature or
	// an accidental applied to this note.
	let accidentalFound = false;
	let keySignatureChangeFound = false;
	let measureChanged = false;
	let measureStartTick = cursor.measure.firstSegment.tick;
	while (cursor.segment)
	{
		// Check for a standard key signature change.
		if (!keySignatureChangeFound && (cursor.keySignature !== keySignature))
		{
			keySignatureChangeFound = true;
			logger.trace("Key signature change found.");
		}
		// Check for a custom key signature change.  This is only relevant if we
		// didn't find a key signature change, because otherwise the custom key
		// signature wouldn't be in effect for the note we're respelling.
		// Additionally, we only check if the key signature is 0, because that's
		// what custom key signatures return.
		if (!keySignatureChangeFound && (cursor.keySignature === 0))
		{
			for (let i = 0; i < cursor.segment.annotations.length; i++)
			{
				let annotation = cursor.segment.annotations[i];
				// TODO: check that staff text elements apply only to the current staff.
				
				let customKeySignature = {};
				EdoUtils.parseCustomKeySignature(annotation.text, customKeySignature, logger);
				if (!isEmpty(customKeySignature))
				{
					keySignatureChangeFound = true;
					let previousAccidental = customKeySignature[noteName];
					logger.log("Previous accidental from a standard key signature: " + previousAccidental);
					break;
				}
			}
			if (keySignatureChangeFound)
			{
				break;
			}
		}
		
		// Check if we moved to a previous measure, in which case we do not have
		// to check for altered notes anymore.
		if (!measureChanged && (cursor.tick < measureStartTick))
		{
			measureChanged = true;
			logger.trace("Measure changed.");
		}
		// Check if the same note previously in the measure was altered by an
		// accidental.
		if (!measureChanged && cursor.element && (cursor.element.type === Element.CHORD))
		{
			let notes = cursor.element.notes;
			for (let i = 0; i < notes.length; i++)
			{
				let currentAccidental = checkAccidental(notes[i], noteName, octave);
				if (currentAccidental && (currentAccidental !== "NONE"))
				{
					logger.log("Previous accidentals from a previous note in the measure: " + currentAccidental);
					previousAccidental = currentAccidental;
					accidentalFound = true;
					break;
				}
			}
			if (accidentalFound)
			{
				break;
			}
			
			// TODO: add a check that the current note is not the same as the input note.
			let graceChords = cursor.element.graceNotes;
			for (let i = graceChords.length - 1; i >= 0; i--)
			{
				let graceNotes = graceChords[i].notes;
				for (let j = 0; j < graceNotes.length; j++)
				{
					let currentAccidental = checkAccidental(graceNotes[j], noteName, octave);
					if (currentAccidental && (currentAccidental !== "NONE"))
					{
						logger.log("Accidental changed by a previous note in the measure: " + currentAccidental);
						previousAccidental = currentAccidental;
						accidentalFound = true;
						break;
					}
				}
				if (accidentalFound)
				{
					break;
				}
			}
			if (accidentalFound)
			{
				break;
			}
		}
		
		if (keySignatureChangeFound && measureChanged)
		{
			break;
		}
		
		cursor.prev();
	}
	
	logger.log("Previous accidental found: " + previousAccidental);
	return previousAccidental;
}

/**
 * Check if the input note is the same as the input targetNote and targetOctave,
 * in which case return its accidental.  If it's not, return null.
 */
function checkAccidental(note, targetNote, targetOctave)
{
	var noteName = NoteUtils.getNoteLetter(note, "tpc");
	var octave = NoteUtils.getOctave(note);
	Logger.trace("Checking accidental for note: " + noteName + " " + octave);
	if ((noteName === targetNote) && (octave === targetOctave))
	{
		var currentAccidental = AccidentalUtils.getAccidentalName(note);
		Logger.trace("Accidental found: " + currentAccidental);
		return currentAccidental;
	}
	else
	{
		return null;
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

function isEmpty(o)
{
	for (var key in o)
	{
		return false;
	}
	return true;
}
