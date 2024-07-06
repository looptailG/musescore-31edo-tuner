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
	
	// Map containing the amount of EDO steps of every supporte accidental.
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
			log(measure, 3);
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
}
