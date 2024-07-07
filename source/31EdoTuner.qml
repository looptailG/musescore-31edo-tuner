/*
	31EDO Tuner plugin for Musescore.
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

import QtQuick 2.2
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore
{
	menuPath: "Plugins.Tuner.31EDO";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	version: "1.5.4";
	
	Component.onCompleted:
	{
		if (mscoreMajorVersion >= 4)
		{
			title = qsTr("31EDO Tuner");
			thumbnailName = "31EdoThumbnail.png";
			categoryCode = "playback";
		}
	}

	// Size in cents of an EDO step.
	property var stepSize: 1200.0 / 31;
	// Difference in cents between a 12EDO and a 31EDO fifth.
	property var fifthDeviation: 700 - 18 * stepSize;
	// Offsets in cents between the notes in 31EDO and their 12EDO counterparts.
	property variant baseNotesOffset:
	{
		"C": 2 * fifthDeviation,
		"D": 0,
		"E": -2 * fifthDeviation,
		"F": 3 * fifthDeviation,
		"G": 1 * fifthDeviation,
		"A": -1 * fifthDeviation,
		"B": -3 * fifthDeviation,
	}
	
	// Map containing the properties of every supported accidental.  The
	// accidentals with a "DEFAULT_OFFSET" property are those not handled by the
	// tpc property, but instead by a tuning offset.
	// Values taken from: Musescore/src/engraving/dom/accidental.cpp
	property variant supportedAccidentals:
	{
		"NONE":
		{
			"EDO_STEPS": 0,
		},
		"FLAT":
		{
			"EDO_STEPS": -2,
		},
		"NATURAL":
		{
			"EDO_STEPS": 0,
		},
		"SHARP":
		{
			"EDO_STEPS": 2,
		},
		"SHARP2":
		{
			"EDO_STEPS": 4,
		},
		"FLAT2":
		{
			"EDO_STEPS": -4,
		},
		"SHARP3":
		{
			"EDO_STEPS": 6,
		},
		"FLAT3":
		{
			"EDO_STEPS": -6,
		},
		"NATURAL_FLAT":
		{
			"EDO_STEPS": -2,
		},
		"NATURAL_SHARP":
		{
			"EDO_STEPS": 2,
		},
		"ARROW_DOWN":
		{
			"EDO_STEPS": -1,
			"DEFAULT_OFFSET": -50,
		},
		"MIRRORED_FLAT":  // Half flat
		{
			"EDO_STEPS": -1,
			"DEFAULT_OFFSET": -50,
		},
		"MIRRORED_FLAT2":  // Sesqui flat
		{
			"EDO_STEPS": -3,
			"DEFAULT_OFFSET": -150,
		},
		"SHARP_SLASH":  // Half sharp
		{
			"EDO_STEPS": 1,
			"DEFAULT_OFFSET": 50,
		},
		"LOWER_ONE_SEPTIMAL_COMMA":
		{
			"EDO_STEPS": -1,
			"DEFAULT_OFFSET": 0,
		},
		"SHARP_SLASH4":  // Sesqui sharp
		{
			"EDO_STEPS": 3,
			"DEFAULT_OFFSET": 150,
		},
		"SAGITTAL_11MDD":  // Sagittal quarter tone down
		{
			"EDO_STEPS": -1,
			"DEFAULT_OFFSET": -53.3,
		},
		"SAGITTAL_11MDU":  // Sagittal quarter tone up
		{
			"EDO_STEPS": 1,
			"DEFAULT_OFFSET": 53.3,
		},
		"SAGITTAL_FLAT":  // Sagittal half tone down
		{
			"EDO_STEPS": -2,
			"DEFAULT_OFFSET": -113.7,
		},
		"SAGITTAL_SHARP":  // Sagittal half tone up
		{
			"EDO_STEPS": 2,
			"DEFAULT_OFFSET": 113.7,
		},
	}
	
	// Map containing the previous microtonal accidentals in the current
	// measure.  The keys are formatted as note letter concatenated with the
	// note octave, for example C4.  The value is the last microtonal accidental
	// that was applied to that note within the current measure.
	property variant previousAccidentals:
	{}
	
	// Map containing the alteration presents in the current custom key
	// signature, if any.  The keys are the names of the notes, and the values
	// are the accidentals applied to them.  It supports only octave-repeating
	// key signatures.
	property variant currentCustomKeySignature:
	{}
	// Regex used for checking if a string is valid as a custom key signature.
	property var customKeySignatureRegex: /^(x|t#|#|t|h|d|b|db|bb|)(?:\.(?:x|t#|#|t|h|d|b|db|bb|)){6}$/;
	// Array containing the notes in the order they appear in the custom key
	// signature string.
	property var customKeySignatureNoteOrder: ["F", "C", "G", "D", "A", "E", "B"];
	
	property var showLog: false;
	property var maxLines: 50;
	MessageDialog
	{
		id: debugLogger;
		title: "31EDO Tuner - Debug";
		text: "";

		function log(message, isErrorMessage)
		{
			if (showLog || isErrorMessage)
			{
				text += message + "\n";
			}
		}
		
		function showLogMessages()
		{
			if (text != "")
			{
				// Truncate the message to a maximum number of lines, to prevent
				// issues with the message box being too large.
				var messageLines = text.split("\n");
				if (messageLines.length > maxLines)
				{
					var messageLines = messageLines.slice(0, maxLines);
					text = messageLines.join("\n") + "\n" + "...";
				}
				debugLogger.open();
			}
		}
	}

	onRun:
	{
		logMessage("-- 31EDO Tuner -- Version " + version +  " --");
	
		curScore.startCmd();
		
		// Calculate the portion of the score to tune.
		var cursor = curScore.newCursor();
		var startStaff;
		var endStaff;
		var startTick;
		var endTick;
		cursor.rewind(Cursor.SELECTION_START);
		if (!cursor.segment)
		{
			// Tune the entire score.
			startStaff = 0;
			endStaff = curScore.nstaves - 1;
			startTick = 0;
			endTick = curScore.lastSegment.tick + 1;
			logMessage("Tuning the entire score.");
		}
		else
		{
			// Tune only the selection.
			startStaff = cursor.staffIdx;
			startTick = cursor.tick;
			cursor.rewind(Cursor.SELECTION_END);
			endStaff = cursor.staffIdx;
			if (cursor.tick == 0)
			{
				// If the selection includes the last measure of the score,
				// .rewind() overflows and goes back to tick 0.
				endTick = curScore.lastSegment.tick + 1;
			}
			else
			{
				endTick = cursor.tick;
			}
			logMessage("Tuning only the portion of the score between staffs " + startStaff + " - " + endStaff + ", and between ticks " + startTick + " - " + endTick + ".");
		}

		// Loop on the portion of the score to tune.
		for (var staff = startStaff; staff <= endStaff; staff++)
		{
			for (var voice = 0; voice < 4; voice++)
			{
				logMessage("-- Tuning Staff: " + staff + " -- Voice: " + voice + " --");
				
				cursor.voice = voice;
				cursor.staffIdx = staff;
				cursor.rewindToTick(startTick);
				
				currentCustomKeySignature = {};
				previousAccidentals = {};

				// Loop on elements of a voice.
				while (cursor.segment && (cursor.tick < endTick))
				{
					if (cursor.segment.tick == cursor.measure.firstSegment.tick)
					{
						// New measure, empty the previous accidentals map.
						previousAccidentals = {};
						logMessage("----");
					}
					
					// Check for key signature change.
					// TODO: This implementation is very ineffcient, as this piece of code is called on every element when the key signature is not empty.  Find a way to call this only when the key signature actually change.
					if (cursor.keySignature)
					{
						// The key signature has changed, empty the custom key
						// signature map.
						// TODO: This if is necessary only because the previous if is not true only when there is an actual key signature change.  This way we check if the mapping was not empty before, and thus actually needs to be emptied now.
						if (Object.keys(currentCustomKeySignature).length != 0)
						{
							logMessage("Key signature change, emptying the custom key signature map.");
							currentCustomKeySignature = {};
						}
					}
					// Check if there is a text indicating a custom key
					// signature change.
					for (var i = 0; i < cursor.segment.annotations.length; i++)
					{
						var annotationText = cursor.segment.annotations[i].text;
						if (annotationText)
						{
							annotationText = annotationText.replace(/\s*/g, "");
							if (customKeySignatureRegex.test(annotationText))
							{
								logMessage("Applying the current custom key signature: " + annotationText);
								currentCustomKeySignature = {};
								try
								{
									var annotationTextSplitted = annotationText.split(".");
									for (var j = 0; j < annotationTextSplitted.length; j++)
									{
										var currentNote = customKeySignatureNoteOrder[j];
										var currentAccidental = annotationTextSplitted[j].trim();
										var accidentalName = "";
										switch (currentAccidental)
										{
											case "bb":
											case "b":
											case "":
											case "h":
											case "#":
											case "x":
												// Non-microtonal accidentals are
												// automatically handled by
												// Musescore even in custom key
												// signatures, so we only have to
												// check for microtonal accidentals.
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
										if (accidentalName != "")
										{
											currentCustomKeySignature[currentNote] = accidentalName;
										}
									}
								}
								catch (error)
								{
									logMessage(error, true);
									currentCustomKeySignature = {};
								}
							}
						}
					}
					
					// Tune notes.
					if (cursor.element)
					{
						if (cursor.element.type == Element.CHORD)
						{
							// Iterate through every grace chord.
							var graceChords = cursor.element.graceNotes;
							for (var i = 0; i < graceChords.length; i++)
							{
								var notes = graceChords[i].notes;
								for (var j = 0; j < notes.length; j++)
								{
									try
									{
										notes[j].tuning = calculateTuningOffset(notes[j]);
									}
									catch (error)
									{
										logMessage(error, true);
									}
								}
							}

							// Iterate through every chord note.
							var notes = cursor.element.notes;
							for (var i = 0; i < notes.length; i++)
							{
								try
								{
									notes[i].tuning = calculateTuningOffset(notes[i]);
								}
								catch (error)
								{
									logMessage(error, true);
								}
							}
						}
					}

					cursor.next();
				}
			}
		}
		
		curScore.endCmd();
		
		debugLogger.showLogMessages();

		if (mscoreMajorVersion >= 4)
		{
			quit();
		}
		else
		{
			Qt.quit();
		}
	}

	/**
	 * Returns the amount of cents necessary to tune the input note to 31EDO.
	 */
	function calculateTuningOffset(note)
	{
		logMessage("Tuning note: " + calculateNoteName(note));
		
		var tuningOffset = 0;
		var noteLetter = getNoteLetter(note);
		var noteNameOctave = noteLetter + getOctave(note);
		var accidentalName = getAccidentalName(note);

		// Get the tuning offset for the input note with respect to 12EDO, based
		// on its tonal pitch class.
		tuningOffset = baseNotesOffset[noteLetter];
		// Add the tuning offset due to the accidental.  Each semitone adds 7
		// fifth deviations to the note's tuning, because we have to move 7
		// steps in the circle of fifths to get to the altered note.
		var tpcAccidental = Math.floor((note.tpc + 1) / 7) - 2;
		tuningOffset -= tpcAccidental * 7 * fifthDeviation;
		logMessage("Base tuning offset: " + tuningOffset);
		
		// Certain accidentals, like the microtonal accidentals, are not
		// conveyed by the tpc property, but are instead handled directly via a
		// tuning offset.
		// Check which accidental is applied to the note.
		if (accidentalName == "NONE")
		{
			// If the note does not have any accidental applied to it, check if
			// the same note previously in the measure was modified by a
			// microtonal accidental.
			if (previousAccidentals.hasOwnProperty(noteNameOctave))
			{
				accidentalName = previousAccidentals[noteNameOctave];
				logMessage("Applying to the following accidental to the current note from a previous note within the measure: " + accidentalName);
			}
			// If the note still does not have an accidental applied to it,
			// check if it's modified by a custom key signature.
			if (accidentalName == "NONE")
			{
				if (currentCustomKeySignature.hasOwnProperty(noteLetter))
				{
					accidentalName = currentCustomKeySignature[noteLetter];
					logMessage("Applying the following accidental from a custom key signature: " + accidentalName);
				}
			}
		}
		else
		{
			// Save the accidental in the previous accidentals map for this
			// note.
			previousAccidentals[noteNameOctave] = accidentalName;
		}
		// Check if the accidental is handled by a tuning offset.
		var defaultAccidentalOffset = supportedAccidentals[accidentalName]["DEFAULT_OFFSET"];
		if (defaultAccidentalOffset !== undefined)
		{
			// Undo the default tuning offset which is applied to certain
			// accidentals.
			// The default tuning offset is applied only if an actual microtonal
			// accidental is applied to the current note.  For this reason, we
			// must check getAccidentalName() on the current note, it is not
			// sufficient to check the value saved in accidentalName.
			if (mscoreMajorVersion >= 4)
			{
				var actualAccidentalName = getAccidentalName(note);
				var actualAccidentalOffset = supportedAccidentals[actualAccidentalName]["DEFAULT_OFFSET"];
				if (actualAccidentalOffset !== undefined)
				{
					logMessage("Undoing the default tuning offset of: " + actualAccidentalOffset);
					tuningOffset -= actualAccidentalOffset;
				}
			}
			
			// Apply the tuning offset for this specific accidental.
			var edoSteps = getAccidentalEdoSteps(accidentalName);
			logMessage("Offsetting the tuning by the following amount of EDO steps: " + edoSteps);
			tuningOffset += edoSteps * stepSize;
		}
		logMessage("Final tuning offset: " + tuningOffset);

		return tuningOffset;
	}
	
	/**
	 * Return the english note name for the input note, written with ASCII
	 * characters only.  Uses the following characters for the accidentals:
	 *
	 * - Double flat  -> bb
	 * - Sesqui flat  -> db
	 * - Flat         -> b
	 * - Half flat    -> d
	 * - Half sharp   -> t
	 * - Sharp        -> #
	 * - Sesqui sharp -> t#
	 * - Double sharp -> x
	 */
	function calculateNoteName(note)
	{
		var noteName = getNoteLetter(note);
		
		var accidental = getAccidentalEdoSteps(getAccidentalName(note));
		switch (accidental)
		{
			case -6:
				noteName += "bbb";
				break;
		
			case -4:
				noteName += "bb";
				break;
			
			case -3:
				noteName += "db";
				break;
			
			case -2:
				noteName += "b";
				break;
			
			case -1:
				noteName += "d";
				break;
			
			case 0:
				break;
			
			case 1:
				noteName += "t";
				break;
			
			case 2:
				noteName += "#";
				break;
			
			case 3:
				noteName += "t#";
				break;
			
			case 4:
				noteName += "x";
				break;
			
			case 6:
				noteName += "#x";
				break;
			
			default:
				throw "Unsupported accidental: " + accidental;
		}
		
		return noteName;
	}
	
	/**
	 * Return the english note name for the input note.
	 */
	function getNoteLetter(note)
	{
		switch (note.tpc % 7)
		{
			case 0:
				return "C";
			
			case 2:
			case -5:
				return "D";
			
			case 4:
			case -3:
				return "E";
			
			case 6:
			case -1:
				return "F";
			
			case 1:
			case -6:
				return "G";
			
			case 3:
			case -4:
				return "A";
			
			case 5:
			case -2:
				return "B";
		}
	}
	
	/**
	 * Return the number of 31EDO steps this note is altered by.
	 */
	function getAccidentalEdoSteps(accidentalName)
	{
		var edoSteps = supportedAccidentals[accidentalName]["EDO_STEPS"];
		if (edoSteps !== undefined)
		{
			return edoSteps;
		}
		else
		{
			throw "Could not find the following accidental in the accidentals mapping: " + accidentalName;
		}
	}
	
	/**
	 * Return the name of the input note's accidental for the supported
	 * accidentals.
	 */
	function getAccidentalName(note)
	{
		// Casting the accidentalType as a string is necessary to obtain the
		// number corresponding to the enum value.  Parsing it as an int is
		// needed to properly compare it with the enum values in a switch
		// statement.
		var accidentalType = parseInt("" + note.accidentalType);
		// In Musescore3 the accidentalType property is a signed integer, while
		// the Accidentals enum values are always positive.  If it's negative,
		// convert it to an unsigned 8 bit integer by shifting it by 256.
		if (accidentalType < 0)
		{
			accidentalType += 256;
		}
		if ((accidentalType < 0) || (accidentalType >= 256))
		{
			throw "Out of bound accidental type: " + accidentalType;
		}
		switch (accidentalType)
		{
			case Accidental.NONE:
				return "NONE";
			
			case Accidental.FLAT:
				return "FLAT";
			
			case Accidental.NATURAL:
				return "NATURAL";
			
			case Accidental.SHARP:
				return "SHARP";
			
			case Accidental.SHARP2:
				return "SHARP2";
			
			case Accidental.FLAT2:
				return "FLAT2";
			
			case Accidental.SHARP3:
				return "SHARP3";
			
			case Accidental.FLAT3:
				return "FLAT3";
			
			case Accidental.NATURAL_FLAT:
				return "NATURAL_FLAT";
			
			case Accidental.NATURAL_SHARP:
				return "NATURAL_SHARP";
			
			case Accidental.ARROW_DOWN:
				return "ARROW_DOWN";
			
			case Accidental.MIRRORED_FLAT:
				return "MIRRORED_FLAT";
			
			case Accidental.MIRRORED_FLAT2:
				return "MIRRORED_FLAT2";
			
			case Accidental.SHARP_SLASH:
				return "SHARP_SLASH";
			
			case Accidental.SHARP_SLASH4:
				return "SHARP_SLASH4";
			
			case Accidental.LOWER_ONE_SEPTIMAL_COMMA:
				return "LOWER_ONE_SEPTIMAL_COMMA";
			
			case Accidental.SAGITTAL_11MDD:
				return "SAGITTAL_11MDD";
			
			case Accidental.SAGITTAL_11MDU:
				return "SAGITTAL_11MDU";
			
			case Accidental.SAGITTAL_FLAT:
				return "SAGITTAL_FLAT";
			
			case Accidental.SAGITTAL_SHARP:
				return "SAGITTAL_SHARP";
			
			default:
				throw "Unsupported accidental: " + note.accidentalType;
		}
	}
	
	/**
	 * Return the octave of the input note.
	 */
	function getOctave(note)
	{
		return Math.floor(note.pitch / 12) - 1;
	}
	
	/**
	 * Log the input message, and automatically redirect the output message
	 * depending on the MuseScore version.
	 */
	function logMessage(message, isErrorMessage)
	{
		if (isErrorMessage === undefined)
		{
			isErrorMessage = false;
		}
	
		if (mscoreMajorVersion >= 4)
		{
			debugLogger.log(message, isErrorMessage);
		}
		else
		{
			if (isErrorMessage)
			{
				console.error(message);
				debugLogger.log(message, isErrorMessage);
			}
			else
			{
				console.log(message);
			}
		}
	}
}
