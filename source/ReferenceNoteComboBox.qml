/*
	A combo-box formatted to look similar to StyledGroupBox, but with a
	customisable font.
	Copyright (C) 2026 Alessandro Culatti

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

ComboBox
{
	property var version: "1.0.0";

	id: root;

	property font comboBoxFont;

	padding: 10;
	rightPadding: indicatorId.width + root.padding * 2;

	contentItem: Text
	{
		text: root.displayText;
		font: root.comboBoxFont;
		color: ui.theme.fontPrimaryColor;
		elide: Text.ElideRight;
		verticalAlignment: Text.AlignVCenter;
	}

	background: Rectangle
	{
		color: ui.theme.buttonColor;
		border.color: ui.theme.backgroundSecondaryColor;
	}

	indicator: Text
	{
		id: indicatorId;
		text: "▼";
		color: ui.theme.fontPrimaryColor;
		x: root.width - indicatorId.width - defaultPadding;
		y: (root.height - indicatorId.height) / 2;
	}

	delegate: ItemDelegate
	{
		width: root.width;
		height: 30;

		contentItem: Text
		{
			text: modelData;
			font: root.comboBoxFont;
			color: ui.theme.fontPrimaryColor;
			verticalAlignment: Text.AlignVCenter;
			elide: Text.ElideRight;
		}

		background: Rectangle
		{
			color: ui.theme.buttonColor;
		}
	}
}
