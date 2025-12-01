/*
	Plugin for Musescore to move the selected notes up by a 31EDO step.
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
import "IterationUtils.js" as IterationUtils
import "Logger.js" as Logger
import "SettingsIO.js" as SettingsIO

MuseScore
{
	title: "31EDO Pitch Up";
	description: "Move the selection, or the whole score if nothing is selected, up by a 31EDO step.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_PitchUp_Thumbnail.png";
	version: "2.2.0";
	
	property variant settings: {};
	
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
			
			IterationUtils.iterate(
				curScore,
				{
					"onStaffStart": searchAccidentals
				},
				Logger
			);
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
	
	function searchAccidentals()
	{
		currentCustomKeySignature = {};
		previousAccidentals = {};
		
		if (curScore.selection.isRange)
		{
			if (curScore.selection.startSegment)
			{
				let originalSelectionStartTick = curScore.selection.startSegment.tick;
				
				if (originalSelectionStartTick > 0)
				{
					let originalSelectionEndTick;
					if (curScore.selection.endSegment)
					{
						originalSelectionEndTick = curScore.selection.endSegment.tick;
					}
					else
					{
						// If the selection includes the last note of the score,
						// tick overflows and goes back to tick 0.  In this
						// case, set the end tick manually to the last tick of
						// the score.
						originalSelectionEndTick = curScore.lastSegment.tick;
					}
					
					let originalSelectionStartStaff = curScore.selection.startStaff;
					let originalSelectionEndStaff = curScore.selection.endStaff;
					
					curScore.selection.selectRange(0, originalSelectionStartTick, originalSelectionStartStaff, originalSelectionEndStaff);
					
					Logger.log("Back searching accidentals before tick " + originalSelectionStartTick + " for staff " + originalSelectionStartStaff);
					IterationUtils.iterate
					(
						curScore,
						{
							"onStaffStart": onStaffStart,
							"onNewMeasure": onNewMeasure,
							"onKeySignatureChange": onKeySignatureChange,
							"onAnnotation": onAnnotation
						},
						Logger
					);
					
					// TODO: check if adding 1 is sufficient to offset the fact that when selecting a range the last tick is not included.
					curScore.selection.selectRange(originalSelectionStartTick, originalSelectionEndTick + 1, originalSelectionStartStaff, originalSelectionEndStaff);
				}
				else
				{
					Logger.trace("Starting from the beginning of the score, no need to back search for accidentals.");
				}
			}
			else
			{
				Logger.trace("Iterating over the entire score, no need to back search for accidentals.");
			}
		}
		else
		{
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
}
