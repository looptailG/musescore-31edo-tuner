/*
	Plugin for Musescore for respelling the selected notes according to 31EDO.
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
	title: "31EDO Tuner - Respell";
	description: "Respelle the selection, or the whole score if nothing is selected, according to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_Respell_Thumbnail.png";
	version: "2.2.0"
	
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
			
			curScore.startCmd();
			
			for (var element of curScore.selection.elements)
			{
				if (element.type === Element.NOTE)
				{
					var noteName = NoteUtils.getNoteLetter(element, "tpc");
					var octave = NoteUtils.getOctave(element);
					var accidental = AccidentalUtils.getAccidentalName(element);
					Logger.log("Respelling note: " + noteName + " " + octave + " " + accidental);
					if (!EdoUtils.ENHARMONIC_ACCIDENTALS.includes(accidental))
					{
						Logger.warning("Accidental not supported for 31EDO enharmonic respelling: " + accidental);
						continue;
					}
					var edoStep = EdoUtils.NOTES_STEPS[noteName] + EdoUtils.SUPPORTED_ACCIDENTALS[accidental];
					Logger.trace("EDO step: " + edoStep);
					
					var previousAccidental = EdoUtils.searchPreviousAccidental(element, noteName, octave, accidental, Logger);
					if ((accidental === "NONE") && (previousAccidental !== "NONE"))
					{
						Logger.log("Current accidental replaced with: " + previousAccidental);
						accidental = previousAccidental;
					}
					
					var targetNoteName = null;
					var targetOctave = null;
					var targetAccidental = null;
					var enharmonicEquivalents = EdoUtils.ENHARMONIC_EQUIVALENTS[edoStep];
					Logger.logProperties(enharmonicEquivalents);
				}
			}
			
			curScore.endCmd();
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
}
