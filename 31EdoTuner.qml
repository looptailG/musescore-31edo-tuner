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
	property variant centOffsets:
	{
		"C":
		{
			"bb": 2 * fifthDeviation + 14 * fifthDeviation,
			"b": 2 * fifthDeviation + 7 * fifthDeviation,
			"h": 2 * fifthDeviation,
			"#": 2 * fifthDeviation - 7 * fifthDeviation,
			"x": 2 * fifthDeviation - 14 * fifthDeviation
		},
		"D":
		{
			"bb": 14 * fifthDeviation,
			"b": 7 * fifthDeviation,
			"h": 0,
			"#": -7 * fifthDeviation,
			"x": -14 * fifthDeviation
		},
		"E":
		{
			"bb": -2 * fifthDeviation + 14 * fifthDeviation,
			"b": -2 * fifthDeviation + 7 * fifthDeviation,
			"h": -2 * fifthDeviation,
			"#": -2 * fifthDeviation - 7 * fifthDeviation,
			"x": -2 * fifthDeviation - 14 * fifthDeviation
		},
		"F":
		{
			"bb": 3 * fifthDeviation + 14 * fifthDeviation,
			"b": 3 * fifthDeviation + 7 * fifthDeviation,
			"h": 3 * fifthDeviation,
			"#": 3 * fifthDeviation - 7 * fifthDeviation,
			"x": 3 * fifthDeviation - 14 * fifthDeviation
		},
		"G":
		{
			"bb": 1 * fifthDeviation + 14 * fifthDeviation,
			"b": 1 * fifthDeviation + 7 * fifthDeviation,
			"h": 1 * fifthDeviation,
			"#": 1 * fifthDeviation - 7 * fifthDeviation,
			"x": 1 * fifthDeviation - 14 * fifthDeviation
		},
		"A":
		{
			"bb": -1 * fifthDeviation + 14 * fifthDeviation,
			"b": -1 * fifthDeviation + 7 * fifthDeviation,
			"h": -1 * fifthDeviation,
			"#": -1 * fifthDeviation - 7 * fifthDeviation,
			"x": -1 * fifthDeviation - 14 * fifthDeviation
		},
		"B":
		{
			"bb": -3 * fifthDeviation + 14 * fifthDeviation,
			"b": -3 * fifthDeviation + 7 * fifthDeviation,
			"h": -3 * fifthDeviation,
			"#": -3 * fifthDeviation - 7 * fifthDeviation,
			"x": -3 * fifthDeviation - 14 * fifthDeviation
		},
	}
	
	// Map containing the properties of every supported accidental.
	// Values taken from: Musescore/src/engraving/dom/accidental.cpp
	property variant supportedAccidentals:
	{
		"0":  // No accidental
		{
			"EDO_STEPS": 0,
			"TPC": true,
		},
		"1":  // Flat
		{
			"EDO_STEPS": -2,
			"TPC": true,
		},
		"2":  // Natural
		{
			"EDO_STEPS": 0,
			"TPC": true,
		},
		"3":  // Sharp
		{
			"EDO_STEPS": 2,
			"TPC": true,
		},
		"4":  // Double sharp
		{
			"EDO_STEPS": 4,
			"TPC": true,
		},
		"5":  // Double flat
		{
			"EDO_STEPS": -4,
			"TPC": true,
		},
		"8":  // Naatural flat
		{
			"EDO_STEPS": -2,
			"TPC": true,
		},
		"9":  // Natural sharp
		{
			"EDO_STEPS": 2,
			"TPC": true,
		},
		"23":  // Half flat
		{
			"EDO_STEPS": -1,
			"TPC": false,
			"DEFAULT_OFFSET": -50,
		},
		"24":  // Sesqui flat
		{
			"EDO_STEPS": -3,
			"TPC": false,
			"DEFAULT_OFFSET": -150,
		},
		"25":  // Half sharp
		{
			"EDO_STEPS": 1,
			"TPC": false,
			"DEFAULT_OFFSET": 50,
		},
		"26":  // Sesqui sharp
		{
			"EDO_STEPS": 3,
			"TPC": false,
			"DEFAULT_OFFSET": 150,
		},
		"120":  // Sagittal quarter tone down
		{
			"EDO_STEPS": -1,
			"TPC": false,
			"DEFAULT_OFFSET": -53.3,
		},
		"121":  // Sagittal quarter tone up
		{
			"EDO_STEPS": 1,
			"TPC": false,
			"DEFAULT_OFFSET": 53.3,
		},
		"134":  // Sagittal half tone down
		{
			"EDO_STEPS": -2,
			"TPC": false,
			"DEFAULT_OFFSET": -113.7,
		},
		"135":  // Sagittal half tone up
		{
			"EDO_STEPS": 2,
			"TPC": false,
			"DEFAULT_OFFSET": 113.7,
		},
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

		// Main loop on the notes.
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
		
		var tuningOffset = 0;
		// Get the tuning offset for the input note with respect to 12EDO, based
		// on its tonal pitch class.
		switch (note.tpc)
		{
			case -1:
				tuningOffset += centOffsets["F"]["bb"];
				break;

			case 0:
				tuningOffset += centOffsets["C"]["bb"];
				break;

			case 1:
				tuningOffset += centOffsets["G"]["bb"];
				break;

			case 2:
				tuningOffset += centOffsets["D"]["bb"];
				break;

			case 3:
				tuningOffset += centOffsets["A"]["bb"];
				break;

			case 4:
				tuningOffset += centOffsets["E"]["bb"];
				break;

			case 5:
				tuningOffset += centOffsets["B"]["bb"];
				break;

			case 6:
				tuningOffset += centOffsets["F"]["b"];
				break;

			case 7:
				tuningOffset += centOffsets["C"]["b"];
				break;

			case 8:
				tuningOffset += centOffsets["G"]["b"];
				break;

			case 9:
				tuningOffset += centOffsets["D"]["b"];
				break;

			case 10:
				tuningOffset += centOffsets["A"]["b"];
				break;

			case 11:
				tuningOffset += centOffsets["E"]["b"];
				break;

			case 12:
				tuningOffset += centOffsets["B"]["b"];
				break;

			case 13:
				tuningOffset += centOffsets["F"]["h"];
				break;

			case 14:
				tuningOffset += centOffsets["C"]["h"];
				break;

			case 15:
				tuningOffset += centOffsets["G"]["h"];
				break;

			case 16:
				tuningOffset += centOffsets["D"]["h"];
				break;

			case 17:
				tuningOffset += centOffsets["A"]["h"];
				break;

			case 18:
				tuningOffset += centOffsets["E"]["h"];
				break;

			case 19:
				tuningOffset += centOffsets["B"]["h"];
				break;

			case 20:
				tuningOffset += centOffsets["F"]["#"];
				break;

			case 21:
				tuningOffset += centOffsets["C"]["#"];
				break;

			case 22:
				tuningOffset += centOffsets["G"]["#"];
				break;

			case 23:
				tuningOffset += centOffsets["D"]["#"];
				break;

			case 24:
				tuningOffset += centOffsets["A"]["#"];
				break;

			case 25:
				tuningOffset += centOffsets["E"]["#"];
				break;

			case 26:
				tuningOffset += centOffsets["B"]["#"];
				break;

			case 27:
				tuningOffset += centOffsets["F"]["x"];
				break;

			case 28:
				tuningOffset += centOffsets["C"]["x"];
				break;

			case 29:
				tuningOffset += centOffsets["G"]["x"];
				break;

			case 30:
				tuningOffset += centOffsets["D"]["x"];
				break;

			case 31:
				tuningOffset += centOffsets["A"]["x"];
				break;

			case 32:
				tuningOffset += centOffsets["E"]["x"];
				break;

			case 33:
				tuningOffset += centOffsets["B"]["x"];
				break;
			
			default:
				throw "Could not resolve the tpc: " + note.tpc;
		}
		logMessage("Base tuning offset: " + tuningOffset);
		
		// Certain accidentals, like the microtonal accidentals, are not
		// conveyed by the tpc property, but are instead handled directly via a
		// tuning offset.
		if (!supportedAccidentals[getPositiveAccidentalType(note)]["TPC"])
		{
			var accidentalTuningOffset = supportedAccidentals[getPositiveAccidentalType(note)]["EDO_STEPS"] * stepSize;
			logMessage("Applying an additional tuning offset: " + accidentalTuningOffset);
			tuningOffset += accidentalTuningOffset;
		}
		
		// Undo the default tuning offset which is applied to certain
		// accidentals.
		if (mscoreMajorVersion >= 4)
		{
			var defaultAccidentalOffset = supportedAccidentals[getPositiveAccidentalType(note)]["DEFAULT_OFFSET"];
			if (defaultAccidentalOffset !== undefined)
			{
				logMessage("Undoing the default microtonal tuning offset by adding an addition offset: " + (-defaultAccidentalOffset));
				tuningOffset -= defaultAccidentalOffset;
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
		var accidental = supportedAccidentals[getPositiveAccidentalType(note)]["EDO_STEPS"];
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
	 * Return the accidentalType property as a positive number.
	 */
	function getPositiveAccidentalType(note)
	{
		var accidentalType = note.accidentalType;
		// In Musescore3 the accidentalType property is as signed integer, while
		// in Musescore4 it's unsigned.  If it's negative, convert it to an
		// unsigned 8 bit integer by shifting it by 256.
		if (accidentalType < 0)
		{
			accidentalType += 256;
		}
		return ("" + accidentalType);
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
