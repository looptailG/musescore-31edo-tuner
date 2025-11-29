/*
	Plugin for Musescore to move the selected notes down by a 31EDO step.
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

MuseScore
{
	title: "31EDO Tuner - Pitch Down";
	description: "Move the selection, or the whole score if nothing is selected, down by a 31EDO step.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.2.0"

	onRun:
	{}
}
