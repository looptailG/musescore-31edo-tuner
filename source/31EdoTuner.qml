/*
	31EDO Tuner plugin for Musescore.
	Copyright (C) 2024 - 2025 Alessandro Culatti

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
import "libs/IterationUtils.js" as IterationUtils
import "libs/NoteUtils.js" as NoteUtils
import "libs/StringUtils.js" as StringUtils
import "libs/TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.1.2";
	
	property variant settings: {};

	// Size in cents of an EDO step.
	property var stepSize: 1200.0 / 31;
	// Difference in cents between a 12EDO and a 31EDO fifth.
	property var fifthDeviation: 700.0 - 18 * stepSize;
	// Reference note, which has a tuning offset of zero.
	property var referenceNote: "";
	
	// Map containing the amount of EDO steps of every supported accidental.
	property variant supportedAccidentals:
	{
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
	}
	
	// Map containing the previous microtonal accidentals in the current
	// measure.  The keys are formatted as note letter concatenated with the
	// note octave, for example C4.  The value is the last microtonal accidental
	// that was applied to that note within the current measure.
	property variant previousAccidentals: {}
	
	// Map containing the alteration presents in the current custom key
	// signature, if any.  The keys are the names of the notes, and the values
	// are the accidentals applied to them.  It supports only octave-repeating
	// key signatures.
	property variant currentCustomKeySignature: {}
	// Regex used for checking if a string is valid as a custom key signature.
	property var customKeySignatureRegex: /^(x|t#|#|t|h|d|b|db|bb|)(?:\.(?:x|t#|#|t|h|d|b|db|bb|)){6}$/;
	// Array containing the notes in the order they appear in the custom key
	// signature string.
	property var customKeySignatureNoteOrder: ["F", "C", "G", "D", "A", "E", "B"];
	
	// Amount of notes which were tuned successfully.
	property var tunedNotes: 0;
	// Total amount of notes encountered in the portion of the score to tune.
	property var totalNotes: 0;
	
	Logger
	{
		id: logger;
	}

	FileIO
	{
		id: settingsReader;
		source: Qt.resolvedUrl(".").toString().substring(8) + "Settings.tsv";
		
		onError:
		{
			logger.err(msg);
		}
	}

	onRun:
	{
		try
		{
			// Read settings file.
			settings = {};
			var settingsFileContent = settingsReader.read().split("\n");
			for (var i = 0; i < settingsFileContent.length; i++)
			{
				if (settingsFileContent[i].trim() != "")
				{
					var rowData = StringUtils.parseTsvRow(settingsFileContent[i]);
					settings[rowData[0]] = rowData[1];
				}
			}
			logger.logLevel = parseInt(settings["LogLevel"]);
			referenceNote = settings["ReferenceNote"];
			
			logger.log("-- " + title + " -- Version " + version + " --");
			logger.log("Log level set to: " + logger.logLevel);
			logger.log("Reference note set to: " + referenceNote);
			
			IterationUtils.iterate(
				curScore,
				{
					"onStaffStart": onStaffStart,
					"onNewMeasure": onNewMeasure,
					"onKeySignatureChange": onKeySignatureChange,
					"onAnnotation": onAnnotation,
					"onNote": onNote
				},
				logger
			);
			
			logger.log("Notes tuned: " + tunedNotes + " / " + totalNotes);
		}
		catch (error)
		{
			logger.fatal(error);
		}
		finally
		{
			try
			{
				quit();
			}
			catch (erorr)
			{
				logger.err(error);
			}
			
			logger.writeLogs();
		}
	}
	
	function onStaffStart()
	{
		currentCustomKeySignature = {};
		previousAccidentals = {};
	}
	
	function onNewMeasure()
	{
		previousAccidentals = {};
	}
	
	function onKeySignatureChange(keySignature)
	{
		logger.log("Key signature change, emptying the custom key signature map.");
		currentCustomKeySignature = {};
	}
	
	function onAnnotation(annotation)
	{
		let annotationText = annotation.text.replace(/\s*/g, "");
		if (customKeySignatureRegex.test(annotationText))
		{
			logger.log("Applying custom key signature: " + annotationText);
			currentCustomKeySignature = {};
			try
			{
				let annotationTextSplitted = annotationText.split(".");
				for (let i = 0; i < annotationTextSplitted.length; i++)
				{
					let currentNote = customKeySignatureNoteOrder[i];
					let currentAccidental = annotationTextSplitted[i];
					let accidentalName = "";
					switch (currentAccidental)
					{
						// Non-microtonal accidentals are automatically handled
						// by Musescore even in custom key signatures, so we
						// only have to check for microtonal accidentals.
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
				logger.err(error);
				currentCustomKeySignature = {};
			}
		}
	}
	
	function onNote(note)
	{
		totalNotes++;
		
		try
		{
			note.tuning = TuningUtils.edoTuningOffset(
				note, NoteUtils.getNoteLetter(note, "tpc"), AccidentalUtils.getAccidentalName(note), NoteUtils.getOctave(note), referenceNote,
				stepSize, fifthDeviation, supportedAccidentals, AccidentalUtils.ACCIDENTAL_DATA,
				previousAccidentals, currentCustomKeySignature,
				logger
			);
			tunedNotes++;
		}
		catch (error)
		{
			logger.err(error);
		}
	}
}
