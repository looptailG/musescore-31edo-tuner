/*
	QML component for reading and writing configuration files.
	Copyright (C) 2025 Alessandro Culatti

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

const VERSION = "1.0.0";

/**
 * Read the input TSV file, and return its content as a dictionary, where the
 * keys are the content of keyColumn, and the values the content of valueColumn.
 */
function readTsvFile(filePath, fileIO, keyColumn = 0, valueColumn = 1)
{
	let settings = {};
	
	let fileContent = fileIO.read().split("\n");
	for (let i = 0; i < fileContent.length; i++)
	{
		if (fileContent[i])
		{
			let rowData = parseTsvRow(fileContent[i]);
			settings[rowData[keyColumn]] = rowData[valueColumn];
		}
	}
	
	return settings;
}
