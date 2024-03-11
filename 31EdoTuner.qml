import QtQuick 2.2
import QtQuick.Dialogs 1.1
import MuseScore 3.0

MuseScore
{
	menuPath: "Plugins.Tuner.31Edo"
	description: "Retune the whole score to 31EDO."
	version: "1.0.2"
	
	Component.onCompleted:
	{
		if (mscoreMajorVersion >= 4)
		{
			title = qsTr("31EDO Tuner");
			categoryCode = "playback";
		}
	}

	// Size in cents of an EDO step.
	property var stepSize: 1200.0 / 31;
	property var fifthDeviation: 700 - 18 * stepSize;
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
	
	property var showLog: false;
	MessageDialog
	{
		id: debugLogger;
		title: "31EDO Tuner - Debug";
		text: "";
		function log(message)
		{
			if (showLog)
			{
				text += Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") + " | " + message + "\n";
			}
		}
		function showLogMessages()
		{
			if (showLog)
			{
				debugLogger.open();
				console.log("\n" + text);
			}
		}
	}

	onRun:
	{
		curScore.startCmd();
		var cursor = curScore.newCursor();

		for (var staff = 0; staff < curScore.nstaves; staff++)
		{
			for (var voice = 0; voice < 4; voice++)
			{
				cursor.voice = voice;
				cursor.staffIdx = staff;
				cursor.rewind(0);
				debugLogger.log("-- Tuning Staff: " + staff + " -- Voice: " + voice + " --");

				// Loop elements of a voice.
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
									notes[j].tuning = calculateTuningOffset(notes[j]);
								}
							}

							// Iterate through every chord note.
							var notes = cursor.element.notes;
							for (var i = 0; i < notes.length; i++)
							{
								notes[i].tuning = calculateTuningOffset(notes[i]);
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
	 * Calculate the tuning offset for the input note.
	 */
	function calculateTuningOffset(note)
	{
		debugLogger.log("Tuning note: " + calculatenoteName(note));
		var tuningOffset = 0;

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
		}
		debugLogger.log("Base tuning offset: " + tuningOffset);

		// Apply microtonal accidentals.
		var alteration = getAlteration(note);
		if ((alteration == -3) || (alteration == -1) || (alteration == 1) || (alteration == 3))
		{
			tuningOffset += calculateMicrotonalOffset(alteration, stepSize);
		}
		debugLogger.log("Final tuning offset: " + tuningOffset);

		return tuningOffset;
	}


	/**
	 * Calculate the tuning offset due to microtonal accidentals.
	 */
	function calculateMicrotonalOffset(nSteps, stepSize)
	{
		debugLogger.log("Applying " + nSteps + " steps offset.");
		var tuningOffset = nSteps * stepSize;

		if (mscoreMajorVersion >= 4)
		{
			// Undo the automatic cent offset that Musescore 4 apply to microtonal accidentals.
			tuningOffset -= nSteps * 50;
		}

		return tuningOffset;
	}
	
	/**
	 * Calculate the note name for the input note.
	 */
	function calculatenoteName(note)
	{
		var noteName = "";
		
		switch (positiveModulo(note.tpc, 7))
		{
			case 0:
				noteName += "C";
				break;
			
			case 1:
				noteName += "G";
				break;
			
			case 2:
				noteName += "D";
				break;
			
			case 3:
				noteName += "A";
				break;
			
			case 4:
				noteName += "E";
				break;
			
			case 5:
				noteName += "B";
				break;
			
			case 6:
				noteName += "F";
				break;
			
			default:
				noteName += "?";
				break;
		}
		
		switch (getAlteration(note))
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
				noteName += "?";
				break;
		}
		
		return noteName;
	}
	
	/**
	 * Return the number of 31EDO steps this note is altered by.
	 */
	function getAlteration(note)
	{
		if (mscoreMajorVersion >= 4)
		{
			if (note.accidentalType == 5)
			{
				// Double flat.
				return -4;
			}
			else if (note.accidentalType == 24)
			{
				// Three quarter tone flat.
				return -3;
			}
			else if (note.accidentalType == 1)
			{
				// Flat.
				return -2;
			}
			else if (note.accidentalType == 23)
			{
				// Half flat.
				return -1;
			}
			else if ((note.accidentalType == 0) || (note.accidentalType == 2))
			{
				// Natural.
				return 0;
			}
			else if (note.accidentalType == 25)
			{
				// Half sharp.
				return 1;
			}
			else if (note.accidentalType == 3)
			{
				// Sharp.
				return 2;
			}
			else if (note.accidentalType == 26)
			{
				// Three quarter tone sharp.
				return 3;
			}
			else if (note.accidentalType == 4)
			{
				// Double sharp.
				return 4;
			}
			else
			{
				return "?";
			}
		}
		else
		{
			switch (note.accidentalType.toString())
			{
				// Double flat.
				case "FLAT2":
					return -4;
				
				// Three quarter tone flat.
				case "MIRRORED_FLAT2":
					return -3;
				
				// Flat.
				case "FLAT":
					return -2;
				
				// Half flat.
				case "MIRRORED_FLAT":
					return -1;
				
				// Natural.
				case "NONE":
				case "NATURAL":
					return 0;
				
				// Half sharp.
				case "SHARP_SLASH":
					return 1;
				
				// Sharp.
				case "SHARP":
					return 2;
				
				// Thre quarter tone sharp.
				case "SHARP_SLASH4":
					return 3;
				
				// Double sharp.
				case "SHARP2":
					return 4;
				
				default:
					return "?";
			}
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
