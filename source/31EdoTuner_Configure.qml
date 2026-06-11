/*
	Small GUI plugin to configure the 31EDO Tuner for Musescore.
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
import QtQuick.Layouts
import QtQuick.Controls
import FileIO
import Muse.Ui
import Muse.UiComponents
import MuseScore
import "AccidentalUtils.js" as AccidentalUtils
import "Logger.js" as Logger
import "SettingsIO.js" as SettingsIO

MuseScore
{
	title: "31EDO Tuner Configure";
	description: "Configure the reference note for the 31EDO tuner."
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_Configure_Thumbnail.png";
	version: "2.2.1";
	pluginType: "dialog";

	property variant settings: {};

	readonly property int defaultPadding: 10;
	width: childrenRect.width + 2 * defaultPadding;
	height: childrenRect.height + 2 * defaultPadding;

	property var referenceNoteRegex: /^\s*(A|B|C|D|E|F|G)\s*(bbb|bb|db|b|d||t|#|t#|x|#x)\s*$/i;
	property variant noteNameToIndex: {
		"A": 0,
		"B": 1,
		"C": 2,
		"D": 3,
		"E": 4,
		"F": 5,
		"G": 6
	}
	property variant accidentalToIndex: {
		"bb": 0,
		"db": 1,
		"b": 2,
		"d": 3,
		"": 4,
		"t": 5,
		"#": 6,
		"t#": 7,
		"x": 8
	}

	FileIO
	{
		id: loggerId;
	}

	FileIO
	{
		id: settingsId;
		source: Qt.resolvedUrl(".").toString() + "Settings.tsv";
	}

	ColumnLayout
	{
		anchors.centerIn: parent;
		spacing: defaultPadding;

		StyledGroupBox
		{
			title: "Reference Note";

			RowLayout
			{
				spacing: defaultPadding;

				StyledDropdown
				{
					id: referenceNoteNameId;
					width: 80;
					model: ["A", "B", "C", "D", "E", "F", "G"];

					onActivated: function(index, value)
					{
						referenceNoteNameId.currentIndex = index;
						onReferenceNoteChange();
					}
				}

				StyledDropdown
				{
					id: referenceNoteAccidentalId;
					width: 80;
					model: [
						AccidentalUtils.UNICODE_ACCIDENTALS["FLAT2"],
						AccidentalUtils.UNICODE_ACCIDENTALS["FLAT"],
						AccidentalUtils.UNICODE_ACCIDENTALS["NATURAL"],
						AccidentalUtils.UNICODE_ACCIDENTALS["SHARP"],
						AccidentalUtils.UNICODE_ACCIDENTALS["SHARP2"]
					];

					onActivated: function(index, value)
					{
						referenceNoteAccidentalId.currentIndex = index;
						onReferenceNoteChange();
					}
				}
			}
		}
	}

	Component.onCompleted:
	{
		settings = SettingsIO.readTsvFile(settingsId);

		try
		{
			Logger.initialise(loggerId, parseInt(settings["LogLevel"]));
			Logger.log(title + " - v" + version);

			let referenceNoteMatch = settings["ReferenceNote"].match(referenceNoteRegex);
			if (!referenceNoteMatch)
			{
				throw "Invalid reference note in the configuration file: " + settings["ReferenceNote"];
			}
			let referenceNoteName = referenceNoteMatch[1];
			let referenceNoteAccidental = referenceNoteMatch[2];
			Logger.log("Reference note name: " + referenceNoteName + "; Accidental: " + referenceNoteAccidental);
			referenceNoteNameId.currentIndex = noteNameToIndex[referenceNoteName];
			referenceNoteAccidentalId.currentIndex = accidentalToIndex[referenceNoteAccidental];
		}
		catch (error)
		{
			Logger.fatal(error);
		}
		finally
		{
			Logger.writeLogs();
		}
	}

	onRun:
	{
		if (typeof curScore === "undefined")
		{
			quit();
		}
	}

	function onReferenceNoteChange()
	{
		try
		{
			let selectedNoteName = referenceNoteNameComboBox.currentText;
			let selectedAccidental = unicodeToAscii[referenceNoteAccidentalComboBox.currentText];
			let newReferenceNote = selectedNoteName + selectedAccidental;
			Logger.log("Reference note set to: " + newReferenceNote);
			settings["ReferenceNote"] = newReferenceNote;
			SettingsIO.writeTsvFile(settings, settingsId);
		}
		catch (error)
		{
			Logger.err(error);
		}
		finally
		{
			Logger.writeLogs();
		}
	}
}
