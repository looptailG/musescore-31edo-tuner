/*
	Plugin for Musescore to move the selected notes up by a 31EDO step.
	Copyright (C) 2024 - 2026 Alessandro Culatti

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
import "Logger.js" as Logger
import "NoteUtils.js" as NoteUtils
import "SettingsIO.js" as SettingsIO
import "TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner Pitch Up";
	description: "Move the selection, or the whole score if nothing is selected, up by a 31EDO step.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_PitchUp_Thumbnail.png";
	version: "2.2.0";
	
	property variant settings: {};
	
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
			
			// We can't respell every note in the selection in a single pass, 
			// because if there are two or more of the same note with the same
			// microtonal accidental (which is applied only to the first note of
			// the measure), after we respell the first note, the accidental 
			// will not be there for the following notes anymore.  For this 
			// reason we first have to calculate every pitch up respelling for
			// every note in the current selection, and only then respell the 
			// notes.
			var targetEdoSteps = {};
			searchEdoStepsUp(curScore.selection.elements, targetEdoSteps, Logger);
			applyEdoStepUp(curScore.selection.elements, targetEdoSteps, Logger);
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
			catch (error)
			{
				Logger.err(error);
			}
			
			Logger.writeLogs();
		}
	}
	
	/**
	 * Search for the target EDO step for the notes in the current selection.
	 */
	function searchEdoStepsUp(selection, targetEdoSteps, logger)
	{
		for (var element of selection)
		{
			if (element.type === Element.NOTE)
			{
				var noteName = NoteUtils.getNoteLetter(element, "tpc");
				var octave = NoteUtils.getOctave(element);
				var accidental = AccidentalUtils.getAccidentalName(element);
				logger.log("Searching EDO step up for note: " + noteName + " " + octave + " " + accidental);
				
				if (accidental === "NONE")
				{
					var previousAccidental = EdoUtils.searchPreviousAccidental(element, noteName, octave, logger);
					if (previousAccidental !== "NONE")
					{
						logger.log("Current accidental replaced by: " + previousAccidental);
						accidental = previousAccidental;
					}
				}
				
				var targetEdoStep = EdoUtils.NOTES_STEPS[noteName] + EdoUtils.SUPPORTED_ACCIDENTALS[accidental];
				var inputOctaveShift = null;
				if (targetEdoStep >= 31)
				{
					inputOctaveShift = 1;
				}
				else if (targetEdoStep < 0)
				{
					inputOctaveShift = -1;
				}
				else
				{
					inputOctaveShift = 0;
				}
				targetEdoStep++;
				var targetOctaveShift = null;
				if (targetEdoStep >= 31)
				{
					targetOctaveShift = 1;
				}
				else if (targetEdoStep < 0)
				{
					targetOctaveShift = -1;
				}
				else
				{
					targetOctaveShift = 0;
				}
				targetOctaveShift -= inputOctaveShift;
				targetEdoStep %= 31;
				while (targetEdoStep < 0)
				{
					targetEdoStep += 31;
				}
				logger.log("Target EDO step: " + targetEdoStep + "; Target octave shift: " + targetOctaveShift);
				
				targetEdoSteps[element.eid] = {
					"EDO_STEP": targetEdoStep,
					"OCTAVE_SHIFT": targetOctaveShift
				};
			}
		}
	}
	
	/**
	 * Apply the EDO step pitch ups to the notes in the current selection.
	 */
	function applyEdoStepUp(selection, targetEdoSteps, logger)
	{
		for (var element of selection)
		{
			if (element.type === Element.NOTE)
			{
				var noteName = NoteUtils.getNoteLetter(element, "tpc");
				var octave = NoteUtils.getOctave(element);
				var accidental = AccidentalUtils.getAccidentalName(element);
				logger.log("Applying EDO step up to note: " + noteName + " " + octave + " " + accidental);
				
				var targetEdoStep = targetEdoSteps[element.eid]["EDO_STEP"];
				var targetOctaveShift = targetEdoSteps[element.eid]["OCTAVE_SHIFT"];
				
				var enharmonicSpelling = EdoUtils.chooseEnharmonicSpelling(element, targetEdoStep, 1, logger);
			}
		}
	}
}
