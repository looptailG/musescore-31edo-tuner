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
	height: mainWindow.implicitHeight + 2 * padding;
	
	Row
	{
		id: mainWindow;
		anchors.centerIn: parent;
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
	}
	
	onRun:
	{
		if (typeof curScore === "undefined")
		{
			quit();
		}
	}
}
