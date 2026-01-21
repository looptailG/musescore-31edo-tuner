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
	
	property variant keySignatures: {
		"-7": ["B", "E", "A", "D", "G", "C", "F"],
		"-6": ["B", "E", "A", "D", "G", "C"],
		"-5": ["B", "E", "A", "D", "G"],
		"-4": ["B", "E", "A", "D"],
		"-3": ["B", "E", "A"],
		"-2": ["B", "E"],
		"-1": ["B"],
		"1": ["F"],
		"2": ["F", "C"],
		"3": ["F", "C", "G"],
		"4": ["F", "C", "G", "D"],
		"5": ["F", "C", "G", "D", "A"],
		"6": ["F", "C", "G", "D", "A", "E"],
		"7": ["F", "C", "G", "D", "A", "E", "B"]
	};
	
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
					var accidental = AccidentalUtils.getAccidentalName(element);
					Logger.log("Respelling note: " + noteName + " " + accidental);
					
					var segment = element.parent.parent;
					var cursor = curScore.newCursor();
					cursor.voice = element.voice;
					cursor.staffIdx = element.staff.part.startTrack / 4;
					cursor.rewindToTick(segment.tick);
					
					// Check if a standard key signature changes the current
					// note.
					var keySignature = cursor.keySignature;
					Logger.trace("Key signature: " + keySignature);
					if ((keySignature !== 0) && keySignatures[keySignature].includes(noteName))
					{
						if (keySignature > 0)
						{
							accidental = "SHARP";
						}
						else
						{
							accidental = "FLAT";
						}
						Logger.log("accidental changed by key signature: " + accidental);
					}
					
					if (accidental === "NONE")
					{
						// The note does not have an accidental applied to it,
						// check if a previous key signature or accidental is
						// applied to this note.
						while (cursor.segment)
						{
							cursor.prev();
						}
					}
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
