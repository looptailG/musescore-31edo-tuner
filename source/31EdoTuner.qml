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
import FileIO 3.0
import MuseScore 3.0
import "libs/AccidentalUtils.js" as AccidentalUtils
import "libs/DateUtils.js" as DateUtils
import "libs/NoteUtils.js" as NoteUtils
import "libs/TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.0.0-alpha";

	// Size in cents of an EDO step.
	property var stepSize: 1200.0 / 31;
	// Difference in cents between a 12EDO and a 31EDO fifth.
	property var fifthDeviation: 700 - 18 * stepSize;
	// Reference note, which has a tuning offset of zero.
	property var referenceNote: "C";
	
	// Map containing the amount of EDO steps of every supported accidental.
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
		},
		"MIRRORED_FLAT":  // Half flat
		{
			"EDO_STEPS": -1,
		},
		"MIRRORED_FLAT2":  // Sesqui flat
		{
			"EDO_STEPS": -3,
		},
		"SHARP_SLASH":  // Half sharp
		{
			"EDO_STEPS": 1,
		},
		"LOWER_ONE_SEPTIMAL_COMMA":
		{
			"EDO_STEPS": -1,
		},
		"SHARP_SLASH4":  // Sesqui sharp
		{
			"EDO_STEPS": 3,
		},
		"SAGITTAL_11MDD":  // Sagittal quarter tone down
		{
			"EDO_STEPS": -1,
		},
		"SAGITTAL_11MDU":  // Sagittal quarter tone up
		{
			"EDO_STEPS": 1,
		},
		"SAGITTAL_FLAT":  // Sagittal half tone down
		{
			"EDO_STEPS": -2,
		},
		"SAGITTAL_SHARP":  // Sagittal half tone up
		{
			"EDO_STEPS": 2,
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
	
	FileIO
	{
		id: logger;
		source: Qt.resolvedUrl(".").toString().substring(8) + "logs/" + DateUtils.getFileDateTime() + "_log.txt";
		property var logMessages: "";
		property var currentLogLevel: 0;
		property variant logLevels:
		{
			0: " | TRACE   | ",
			1: " | INFO    | ",
			2: " | WARNING | ",
			3: " | ERROR   | ",
			4: " | FATAL   | ",
		}
		
		function log(message, logLevel)
		{
			if (logLevel === undefined)
			{
				logLevel = 1;
			}
			
			if (logLevel >= currentLogLevel)
			{
				logMessages += DateUtils.getRFC3339DateTime() + logLevels[logLevel] + message + "\n";
			}
		}
		
		function trace(message)
		{
			log(message, 0);
		}
		
		function warning(message)
		{
			log(message, 2);
		}
		
		function error(message)
		{
			log(message, 3);
		}
		
		function fatal(message)
		{
			log(message, 4);
		}
		
		function writeLogMessages()
		{
			write(logMessages);
		}
	}

	onRun:
	{
		try
		{
			logger.log("-- 31EDO Tuner -- Version " + version + " --");
			
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
				logger.log("Tuning the entire score.");
				startStaff = 0;
				endStaff = curScore.nstaves - 1;
				startTick = 0;
				endTick = curScore.lastSegment.tick + 1;
			}
			else
			{
				logger.log("Tuning only the current selection.");
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
				logger.trace("Tuning only ticks: " + startTick + " - " + endTick);
				logger.trace("Tuning only staffs: " + startStaff + " - " + endStaff);
			}
			
			// Loop on the portion of the score to tune.
			for (var staff = startStaff; staff <= endStaff; staff++)
			{
				for (var voice = 0; voice < 4; voice++)
				{
					logger.log("Tuning Staff: " + staff + "; Voice: " + voice);
					
					cursor.voice = voice;
					cursor.staffIdx = staff;
					cursor.rewindToTick(startTick);
					
					currentCustomKeySignature = {};

					// Loop on elements of a voice.
					while (cursor.segment && (cursor.tick < endTick))
					{
						if (cursor.segment.tick == cursor.measure.firstSegment.tick)
						{
							// New measure, empty the previous accidentals map.
							previousAccidentals = {};
						}
						
						// Check for key signature change.
						// TODO: This implementation is very ineffcient, as this piece of code is called on every element when the key signature is not empty.  Find a way to call this only when the key signature actually change.
						if (cursor.keySignature)
						{
							// The key signature has changed, empty the custom
							// key signature map.
							// TODO: This if is necessary only because the previous if is not true only when there is an actual key signature change.  This way we check if the mapping was not empty before, and thus actually needs to be emptied now.
							if (Object.keys(currentCustomKeySignature).length != 0)
							{
								logger.log("Key signature change, emptying the custom key signature map.");
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
									logger.log("Applying the current custom key signature: " + annotationText);
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
												// Non-microtonal accidentals
												// are automatically handled by
												// Musescore even in custom key
												// signatures, so we only have
												// to check for microtonal
												// accidentals.
												case "bb":
												case "b":
												case "":
												case "h":
												case "#":
												case "x":
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
										logger.error(error);
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
											logger.error(error);
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
										logger.error(error);
									}
								}
							}
						}

						cursor.next();
					}
				}
			}
			
			curScore.endCmd();
		}
		catch (error)
		{
			logger.fatal(error);
		}
		finally
		{
			logger.writeLogMessages();
			
			quit();
		}
	}

	/**
	 * Returns the amount of cents necessary to tune the input note to 31EDO.
	 */
	function calculateTuningOffset(note)
	{
		var noteLetter = NoteUtils.getNoteLetter(note, "tpc");
		var accidentalName = AccidentalUtils.getAccidentalName(note);
		var noteOctave = NoteUtils.getOctave(note);
		var noteNameOctave = noteLetter + noteOctave;
		logger.trace("Tuning note: " + noteLetter + " " + accidentalName + " " + noteOctave);
		
		var tuningOffset = -TuningUtils.circleOfFifthsDistance(note, referenceNote) * fifthDeviation;
		logger.trace("Base tuning offset: " + tuningOffset);
		
		// Certain accidentals, like the microtonal accidentals, are not
		// conveyed by the tpc property, but are instead handled directly via a
		// tuning offset.
		// Check which accidental is applied to the note.
		if (accidentalName == "NONE")
		{
			// If the note does not have any accidental applied to it, check if
			// the same note previously in the measure was modified by a
			// microtonal accidental.
			if (previousAccidentals.hasOwrProperty(noteNameOctave))
			{
				
			}
		}
		
		return tuningOffset;
	}
}
