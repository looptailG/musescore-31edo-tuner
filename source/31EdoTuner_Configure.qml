/*
	Small GUI plugin to configuer the 31EDO Tuner for Musescore.
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
import QtQuick.Controls
import FileIO
import MuseScore
import "Logger.js" as Logger
import "SettingsIO.js" as SettingsIO

MuseScore
{
	title: "31EDO Tuner - Configure";
	description: "Configure the reference note for the 31EDO tuner."
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.2.0";
	
	pluginType: "dialog";
	property var padding: 10;
	width: mainWindow.implicitWidth + 2 * padding;
	height: Math.max(mainWindow.implicitHeight, 250) + 2 * padding;
	
	property variant settings: {};
	
	property var tripleFlat: "\uE266";
	property var doubleFlat: "\uE264";
	// Naming this variable "flat" doesn't work properly, possibily because it's
	// a reserved keyword.
	property var flat_: "\uE260";
	property var natural: "\uE261";
	property var sharp: "\uE262";
	property var doubleSharp: "\uE263";
	property var tripleSharp: "\uE265";
	property variant unicodeToAscii: {
		"\uE266": "bbb",
		"\uE264": "bb",
		"\uE260": "b",
		"\uE261": "",
		"\uE262": "#",
		"\uE263": "x",
		"\uE265": "#x"
	}
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
		"bbb": 0,
		"bb": 1,
		"b": 2,
		"": 3,
		"#": 4,
		"x": 5,
		"#x": 6
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
	
	Row
	{
		id: mainWindow;
		spacing: padding;
		
		Text
		{
			text: "Reference Note:";
			font: ui.theme.bodyBoldFont;
			color: ui.theme.fontPrimaryColor;
		}
		
		ComboBox
		{
			id: referenceNoteNameComboBox;
			model: ["A", "B", "C", "D", "E", "F", "G"];
		}
		
		ComboBox
		{
			id: referenceNoteAccidentalComboBox;
			model: [
				tripleFlat,
				doubleFlat,
				flat_,
				natural,
				sharp,
				doubleSharp,
				tripleSharp
			];
			font: ui.theme.musicalFont;
			
			delegate: ItemDelegate
			{
				text: modelData;
				font: ui.theme.musicalFont;
				height: 30;
			}
		}
	}
	
	Component.onCompleted:
	{
		settings = SettingsIO.readTsvFile(settingsId);
		
		Logger.initialise(loggerId, parseInt(settings["LogLevel"]));
		
		try
		{
			
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
}
