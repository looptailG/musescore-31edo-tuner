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

				// The combo boxes use the old style elements, because I need to
				// be able to set the font to the musical font, in order to use
				// the proper SMuFL code points for the accidentals.

				ComboBox
				{
					id: referenceNoteNameId;
					font: ui.theme.bodyFont;

					model: ["A", "B", "C", "D", "E", "F", "G"];

					delegate: ItemDelegate
					{
						text: modelData;
						font: ui.theme.bodyFont;
						height: 30;
					}

					onActivated: function(index, value)
					{
						onReferenceNoteChange();
					}
				}

				ComboBox
				{
					id: referenceNoteAccidentalId;
					font: ui.theme.musicalFont;

					model: [
						AccidentalUtils.SMUFL_ACCIDENTALS["FLAT3"],
						AccidentalUtils.SMUFL_ACCIDENTALS["FLAT2"],
						AccidentalUtils.SMUFL_ACCIDENTALS["MIRRORED_FLAT2"],
						AccidentalUtils.SMUFL_ACCIDENTALS["FLAT"],
						AccidentalUtils.SMUFL_ACCIDENTALS["MIRRORED_FLAT"],
						AccidentalUtils.SMUFL_ACCIDENTALS["NATURAL"],
						AccidentalUtils.SMUFL_ACCIDENTALS["SHARP_SLASH"],
						AccidentalUtils.SMUFL_ACCIDENTALS["SHARP"],
						AccidentalUtils.SMUFL_ACCIDENTALS["SHARP_SLASH4"],
						AccidentalUtils.SMUFL_ACCIDENTALS["SHARP2"],
						AccidentalUtils.SMUFL_ACCIDENTALS["SHARP3"]
					];

					delegate: ItemDelegate
					{
						text: modelData;
						font: ui.theme.musicalFont;
						height: 30;
					}

					onActivated: function(index, value)
					{
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

			var accidentalToIndex = {};
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["FLAT3"]]] = 0;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["FLAT2"]]] = 1;
			accidentalToIndex[
				AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["MIRRORED_FLAT2"]]
			] = 2;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["FLAT"]]] = 3;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["MIRRORED_FLAT"]]] = 4;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["NATURAL"]]] = 5;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["SHARP_SLASH"]]] = 6;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["SHARP"]]] = 7;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["SHARP_SLASH4"]]] = 8;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["SHARP2"]]] = 9;
			accidentalToIndex[AccidentalUtils.UNICODE_TO_ASCII[AccidentalUtils.SMUFL_ACCIDENTALS["SHARP3"]]] = 10;
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
