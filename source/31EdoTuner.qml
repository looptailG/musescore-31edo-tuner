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
import "31EdoUtils.js" as EdoUtils
import "AccidentalUtils.js" as AccidentalUtils
import "IterationUtils.js" as IterationUtils
import "Logger.js" as Logger
import "NoteUtils.js" as NoteUtils
import "StringUtils.js" as StringUtils
import "TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.2.0";
	
	property variant settings: {};

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
	
	FileIO
	{
		id: loggerId;
	}

	FileIO
	{
		id: settingsReader;
		source: Qt.resolvedUrl(".").toString() + "Settings.tsv";
		
		onError:
		{
			Logger.err(msg);
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
			
			Logger.initialise(loggerId, parseInt(settings["LogLevel"]));
			Logger.log("-- " + title + " -- Version " + version + " --");
			
			referenceNote = settings["ReferenceNote"];
			Logger.log("Reference note set to: " + referenceNote);
			
			IterationUtils.iterate(
				curScore,
				{
					"onStaffStart": onStaffStart,
					"onNewMeasure": onNewMeasure,
					"onKeySignatureChange": onKeySignatureChange,
					"onAnnotation": onAnnotation,
					"onNote": onNote
				},
				Logger
			);
			
			Logger.log("Notes tuned: " + tunedNotes + " / " + totalNotes);
		}
		catch (error)
		{
			Logger.fatal(error);
		}
		finally
		{
			try
			{
				quit();
			}
			catch (erorr)
			{
				Logger.err(error);
			}
			
			Logger.writeLogs();
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
		Logger.log("Key signature change, emptying the custom key signature map.");
		currentCustomKeySignature = {};
	}
	
	function onAnnotation(annotation)
	{
		let annotationText = annotation.text.replace(/\s*/g, "");
		if (customKeySignatureRegex.test(annotationText))
		{
			Logger.log("Applying custom key signature: " + annotationText);
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
					if (accidentalName != "")
					{
						currentCustomKeySignature[currentNote] = accidentalName;
					}
				}
			}
			catch (error)
			{
				Logger.err(error);
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
				EdoUtils.STEP_SIZE, EdoUtils.FIFTH_DEVIATION, supportedAccidentals, AccidentalUtils.ACCIDENTAL_DATA,
				previousAccidentals, currentCustomKeySignature,
				Logger
			);
			tunedNotes++;
		}
		catch (error)
		{
			Logger.err(error);
		}
	}
}
