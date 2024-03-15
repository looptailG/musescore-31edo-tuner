/*
	31EDO Tuner plugin for Musescore
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
	menuPath: "Plugins.Tuner.31EDO"
	description: "Retune the whole score to 31EDO."
	version: "1.2.0-alpha"
	
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
	// Difference in cents between a 12EDO and a 31EDO fifths.
	property var fifthDeviation: 700 - 18 * stepSize;
	// Offsets in cents between the notes in 31EDO and their 12EDO counterparts.
	// The notes with an even accidental, which are those with a standard
	// accidental, have a tuning offset which depends by how many fifths they
	// are distant from the reference note in the circle of fifths.
	// The notes with an odd accidental, which are those with a microtonal
	// accidental, have the same tuning offset of the note without an
	// accidental, plus a shift of some EDO steps.  That's because in Musescore
	// those notes are not considered a different note, like it is for the
	// regular accidentals, but are instead simply handled by a tunining offset.
	property variant centOffsets:
	{
		"C":
		{
			"-4": 2 * fifthDeviation + 14 * fifthDeviation,
			"-3": 2 * fifthDeviation - 3 * stepSize,
			"-2": 2 * fifthDeviation + 7 * fifthDeviation,
			"-1": 2 * fifthDeviation - 1 * stepSize,
			"0": 2 * fifthDeviation,
			"1": 2 * fifthDeviation + 1 * stepSize,
			"2": 2 * fifthDeviation - 7 * fifthDeviation,
			"3": 2 * fifthDeviation + 3 * stepSize,
			"4": 2 * fifthDeviation - 14 * fifthDeviation
		},
		"D":
		{
			"-4": 14 * fifthDeviation,
			"-3": -3 * stepSize,
			"-2": 7 * fifthDeviation,
			"-1": -1 * stepSize,
			"0": 0,
			"1": 1 * stepSize,
			"2": -7 * fifthDeviation,
			"3": 3 * stepSize,
			"4": -14 * fifthDeviation
		},
		"E":
		{
			"-4": -2 * fifthDeviation + 14 * fifthDeviation,
			"-3": -2 * fifthDeviation - 3 * stepSize,
			"-2": -2 * fifthDeviation + 7 * fifthDeviation,
			"-1": -2 * fifthDeviation - 1 * stepSize,
			"0": -2 * fifthDeviation,
			"1": -2 * fifthDeviation + 1 * stepSize,
			"2": -2 * fifthDeviation - 7 * fifthDeviation,
			"3": -2 * fifthDeviation + 3 * stepSize,
			"4": -2 * fifthDeviation - 14 * fifthDeviation
		},
		"F":
		{
			"-4": 3 * fifthDeviation + 14 * fifthDeviation,
			"-3": 3 * fifthDeviation - 3 * stepSize,
			"-2": 3 * fifthDeviation + 7 * fifthDeviation,
			"-1": 3 * fifthDeviation - 1 * stepSize,
			"0": 3 * fifthDeviation,
			"1": 3 * fifthDeviation + 1 * stepSize,
			"2": 3 * fifthDeviation - 7 * fifthDeviation,
			"3": 3 * fifthDeviation + 3 * stepSize,
			"4": 3 * fifthDeviation - 14 * fifthDeviation
		},
		"G":
		{
			"-4": 1 * fifthDeviation + 14 * fifthDeviation,
			"-3": 1 * fifthDeviation - 3 * stepSize,
			"-2": 1 * fifthDeviation + 7 * fifthDeviation,
			"-1": 1 * fifthDeviation - 1 * stepSize,
			"0": 1 * fifthDeviation,
			"1": 1 * fifthDeviation + 1 * stepSize,
			"2": 1 * fifthDeviation - 7 * fifthDeviation,
			"3": 1 * fifthDeviation + 3 * stepSize,
			"4": 1 * fifthDeviation - 14 * fifthDeviation
		},
		"A":
		{
			"-4": -1 * fifthDeviation + 14 * fifthDeviation,
			"-3": -1 * fifthDeviation - 3 * stepSize,
			"-2": -1 * fifthDeviation + 7 * fifthDeviation,
			"-1": -1 * fifthDeviation - 1 * stepSize,
			"0": -1 * fifthDeviation,
			"1": -1 * fifthDeviation + 1 * stepSize,
			"2": -1 * fifthDeviation - 7 * fifthDeviation,
			"3": -1 * fifthDeviation + 3 * stepSize,
			"4": -1 * fifthDeviation - 14 * fifthDeviation
		},
		"B":
		{
			"-4": -3 * fifthDeviation + 14 * fifthDeviation,
			"-3": -3 * fifthDeviation - 3 * stepSize,
			"-2": -3 * fifthDeviation + 7 * fifthDeviation,
			"-1": -3 * fifthDeviation - 1 * stepSize,
			"0": -3 * fifthDeviation,
			"1": -3 * fifthDeviation + 1 * stepSize,
			"2": -3 * fifthDeviation - 7 * fifthDeviation,
			"3": -3 * fifthDeviation + 3 * stepSize,
			"4": -3 * fifthDeviation - 14 * fifthDeviation
		}
	}
	
	// Map containing every supported accidental, having as value the number of
	// EDO steps they modify a note by.
	property variant accidentalsEdoSteps:
	{
		"0":   0,  // No accidental
		"1":  -2,  // Flat
		"2":   0,  // Natural
		"3":   2,  // Sharp
		"4":   4,  // Double sharp
		"5":  -4,  // Double flat
		"23": -1,  // Half flat
		"24": -3,  // Sesqui flat
		"25":  1,  // Half sharp
		"26":  3,  // Sesqui sharp
	}
	
	// Map containing every supported microtonal accidental, having as value the
	// number of cent of the default tuning offset in Musescore.
	property variant microtonalAccidentalsDefaultOffset:
	{
		"23":  -50,  // Half flat
		"24": -150,  // Sesqui flat
		"25":   50,  // Half sharp
		"26":  150,  // Sesqui sharp
	}
	
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
				var messageLines = text.split("\n").slice(0, maxLines);
				text = messageLines.join("\n") + "\n" + "...";
				debugLogger.open();
			}
		}
	}

	onRun:
	{
		logMessage("-- 31EDO Tuner -- Version " + version +  " --");
	
		curScore.startCmd();
		var cursor = curScore.newCursor();

		for (var staff = 0; staff < curScore.nstaves; staff++)
		{
			for (var voice = 0; voice < 4; voice++)
			{
				cursor.voice = voice;
				cursor.staffIdx = staff;
				cursor.rewind(0);
				logMessage("-- Tuning Staff: " + staff + " -- Voice: " + voice + " --");

				// Loop on elements of a voice.
				while (cursor.segment)
				{
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
									catch(error)
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
								catch(error)
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

		// Calculate the tuning offset with respect to 12EDO.
		var noteLetter = getNoteLetter(note);
		var accidental = getAccidental(note);
		var tuningOffset = centOffsets[noteLetter]["" + accidental];
		if (tuningOffset === undefined)
		{
			throw "Could not find the note " + calculateNoteName(note) + " in the tuning offset mapping.";
		}
		logMessage("Base tuning offset: " + tuningOffset);
		
		// Undo the default tuning offset which is applied to microtonal
		// accidentals.
		if (mscoreMajorVersion >= 4)
		{
			var defaultMicrotonalOffset = microtonalAccidentalsDefaultOffset["" + note.accidentalType];
			if (defaultMicrotonalOffset !== undefined)
			{
				// If the accidental is present in the default microtonal
				// accidentals mapping, it means it has a default tuning offset
				// that has to be accounted for.  Otherwise, it is a standard
				// accidental, and no extra action needs to be done.
				logMessage("Undoing the default microtonal tuning offset by adding an addition offset: " + (- defaultMicrotonalOffset));
				tuningOffset -= defaultMicrotonalOffset;
			}
		}

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
	 * - sharp        -> #
	 * - Sesqui sharp -> t#
	 * - Double sharp -> x
	 */
	function calculateNoteName(note)
	{
		var noteName = getNoteLetter(note);
		
		var accidental = getAccidental(note);
		switch (accidental)
		{
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
		switch (positiveModulo(note.tpc, 7))
		{
			case 0:
				return "C";
			
			case 1:
				return "G";
			
			case 2:
				return "D";
			
			case 3:
				return "A";
			
			case 4:
				return "E";
			
			case 5:
				return "B";
			
			case 6:
				return "F";
			
			default:
				throw "Could not resolve the tpc: " + note.tpc;
		}
	}
	
	/**
	 * Return the number of 31EDO steps this note is altered by.
	 */
	function getAccidental(note)
	{
		var accidentalType = note.accidentalType;
		// In Musescore3 the accidentalType property is as signed integer, while
		// in Musescore4 it's unsigned.  If it's negative, convert it to an
		// unsigned 8 bit integer by shifting it by 256.
		if (accidentalType < 0)
		{
			accidentalType += 256;
		}
		var accidental = accidentalsEdoSteps["" + accidentalType];
		if (accidental !== undefined)
		{
			return accidental;
		}
		else
		{
			throw "Could not find the following accidental in the accidentals mapping: " + note.accidentalType;
		}
	}
	
	/**
	 * Log the input message, prefixed by the timestamp.  Automatically redirect
	 * the output message depending on the MuseScore version.
	 */
	function logMessage(message, isErrorMessage)
	{
		if (isErrorMessage === undefined)
		{
			isErrorMessage = false;
		}
	
		var formattedMessage = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") + " | " + message;
		if (mscoreMajorVersion >= 4)
		{
			debugLogger.log(formattedMessage, isErrorMessage);
		}
		else
		{
			console.log(formattedMessage);	
		}
	}
	
	/**
	 * Return the modulo as a positive number.
	 */
	function positiveModulo(a, b)
	{
		return (((a % b) + b) % b);
	}
}
