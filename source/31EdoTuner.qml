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

import QtQuick
import FileIO
import MuseScore
import "31EdoUtils.js" as EdoUtils
import "AccidentalUtils.js" as AccidentalUtils
import "IterationUtils.js" as IterationUtils
import "Logger.js" as Logger
import "NoteUtils.js" as NoteUtils
import "SettingsIO.js" as SettingsIO
import "TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_Tuner_Thumbnail.png";
	version: "2.2.0";
	
	property variant settings: {};

	// Reference note, which has a tuning offset of zero.
	property var referenceNote: "";
	
	// Map containing the previous microtonal accidentals in the current
	// measure.  The keys are formatted as note letter concatenated with the
	// note octave, for example "C4".  The value is the last microtonal
	// accidental that was applied to that note within the current measure.
	property variant previousAccidentals: {}
	
	// Map containing the alteration presents in the current custom key
	// signature, if any.  The keys are the names of the notes, and the values
	// are the accidentals applied to them.  It supports only octave-repeating
	// key signatures.
	property variant currentCustomKeySignature: {}
	
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
		id: settingsId;
		source: Qt.resolvedUrl(".").toString() + "Settings.tsv";
	}

	onRun:
	{
		try
		{
			settings = SettingsIO.readTsvFile(settingsId);
			
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
		if (annotation.text)
		{
			EdoUtils.parseCustomKeySignature(annotation.text, currentCustomKeySignature, Logger);
		}
	}
	
	function onNote(note)
	{
		totalNotes++;
		
		try
		{
			note.tuning = TuningUtils.edoTuningOffset(
				note, NoteUtils.getNoteLetter(note, "tpc"), AccidentalUtils.getAccidentalName(note), NoteUtils.getOctave(note), referenceNote,
				EdoUtils.STEP_SIZE, EdoUtils.FIFTH_DEVIATION, EdoUtils.SUPPORTED_ACCIDENTALS, AccidentalUtils.ACCIDENTAL_DATA,
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
