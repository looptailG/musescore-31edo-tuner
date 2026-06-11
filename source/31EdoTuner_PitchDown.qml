/*
	Plugin for Musescore to move the selected notes down by a 31EDO step.
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
	title: "31EDO Tuner Pitch Down";
	description: "Move the selection down by a 31EDO step.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_PitchDown_Thumbnail.png";
	version: "2.2.1";

	property variant settings: {};

	property var iterationLimit: 0;

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

			iterationLimit = parseInt(settings["IterationLimit"]);

			// We can't respell every note in the selection in a single pass,
			// because if there are two or more of the same note with the same
			// microtonal accidental (which is applied only to the first note of
			// the measure), after we respell the first note, the accidental
			// will not be there for the following notes anymore.  For this
			// reason we first have to calculate every pitch up respelling for
			// every note in the current selection, and only then respell the
			// notes.
			var targetEdoSteps = {};
			searchEdoStepsDown(curScore.selection.elements, targetEdoSteps, Logger);
			applyEdoStepDown(curScore.selection.elements, targetEdoSteps, Logger);
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
	function searchEdoStepsDown(selection, targetEdoSteps, logger)
	{
		try
		{
			var counter = 0;
			for (var element of selection)
			{
				if (element.type === Element.NOTE)
				{
					counter++;
					if (counter > iterationLimit)
					{
						Logger.log("Iteration limit exceeded.");
						return;
					}

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
					targetEdoStep--;
					targetEdoStep %= 31;
					while (targetEdoStep < 0)
					{
						targetEdoStep += 31;
					}
					logger.log("Target EDO step: " + targetEdoStep);
					targetEdoSteps[element.eid] = targetEdoStep;
				}
			}
		}
		catch (error)
		{
			Logger.err(error);
		}
	}

	/**
	 * Apply the EDO step pitch downs to the notes in the current selection.
	 */
	function applyEdoStepDown(selection, targetEdoSteps, logger)
	{
		try
		{
			var counter = 0;
			for (var element of selection)
			{
				if (element.type === Element.NOTE)
				{
					counter++;
					if (counter > iterationLimit)
					{
						Logger.log("Iteration limit exceeded.");
						return;
					}

					var noteName = NoteUtils.getNoteLetter(element, "tpc");
					var octave = NoteUtils.getOctave(element);
					var accidental = AccidentalUtils.getAccidentalName(element);
					logger.log("Applying EDO step down to note: " + noteName + " " + octave + " " + accidental);

					var targetEdoStep = targetEdoSteps[element.eid];

					var enharmonicSpelling = EdoUtils.chooseEnharmonicSpelling(element, targetEdoStep, -1, logger);
					var targetNoteName = enharmonicSpelling["NOTE_NAME"];
					var targetAccidental = enharmonicSpelling["ACCIDENTAL"];
					if ((targetNoteName === "B") && (EdoUtils.SUPPORTED_ACCIDENTALS[targetAccidental] > 0))
					{
						// Account for octave shift.  Only necessary for sharp
						// accidentals, because for flat accidentals the altered
						// B is already in the correct octave.
						octave -= 1;
					}

					var targetTpc = null;
					var targetPitch = null;
					if (AccidentalUtils.ACCIDENTAL_DATA[targetAccidental]["TPC"])
					{
						targetTpc = NoteUtils.noteNameToTpc(targetNoteName, targetAccidental);
						targetPitch = NoteUtils.noteToMidiNumber(targetNoteName, targetAccidental, octave);
					}
					else
					{
						// Microtonal accidentals are not handled by the TPC
						// property.  Search the pitch / TPC without any
						// accidental to put the note in the correct staff
						// space, and then the accidental will be added
						// manually.
						targetTpc = NoteUtils.noteNameToTpc(targetNoteName, "NONE");
						targetPitch = NoteUtils.noteToMidiNumber(targetNoteName, "NONE", octave);
					}
					logger.log("Target TPC: " + targetTpc + "; Target Pitch: " + targetPitch);

					// Changing a note's pitch and applying a microtonal
					// accidental to it in the same .startCmd() - .endCmd()
					// block does not work correctly, keep them separated.
					curScore.startCmd();
					element.accidentalType = Accidental.NONE;
					element.pitch = targetPitch;
					element.tpc1 = targetTpc;
					element.tpc2 = targetTpc;
					curScore.endCmd();

					var previousAccidental = EdoUtils.searchPreviousAccidental(element, targetNoteName, octave, logger);
					if (previousAccidental !== targetAccidental)
					{
						if (!AccidentalUtils.ACCIDENTAL_DATA[targetAccidental]["TPC"])
						{
							var targetAccidentalType = AccidentalUtils.getAccidentalType(targetAccidental);
							logger.trace("Target accidental type: " + targetAccidentalType);
							curScore.startCmd();
							element.accidentalType = targetAccidentalType;
							curScore.endCmd();
						}
						else
						{
							if ((targetAccidental === "NONE") && (previousAccidental !== "NONE"))
							{
								logger.log("Accidental replaced with natural.");
								curScore.startCmd();
								element.accidentalType = Accidental.NATURAL;
								curScore.endCmd();
							}
						}
					}
					else
					{
						logger.log("Target accidental already applied to the note.");
						curScore.startCmd();
						element.accidentalType = Accidental.NONE;
						curScore.endCmd();
					}
				}
			}
		}
		catch (error)
		{
			Logger.err(error);
		}
	}
}
