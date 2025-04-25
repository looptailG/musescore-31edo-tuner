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

import QtQuick 2.2
import FileIO 3.0
import MuseScore 3.0
import "libs/IterationUtils.js" as IterationUtils
import "libs/StringUtils.js" as StringUtils

MuseScore
{
	title: "31EDO Tuner - Pitch Up";
	description: "Move the selection, or the whole score if nothing is selected, up by a 31EDO step.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.2.0";
	
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
	
	// Regex used for checking if a string is valid as a custom key signature.
	property var customKeySignatureRegex: /^(x|t#|#|t|h|d|b|db|bb|)(?:\.(?:x|t#|#|t|h|d|b|db|bb|)){6}$/;
	// Array containing the notes in the order they appear in the custom key
	// signature string.
	property var customKeySignatureNoteOrder: ["F", "C", "G", "D", "A", "E", "B"];
	
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
			logger.error(msg);
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
			
			IterationUtils.iterate(
				curScore,
				{
					"onNote": onNote
				},
				logger
			);
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
				logger.error(error);
			}
			
			logger.writeLogs();
		}
	}
	
	function onNote(note)
	{

	}
}
