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
function readTsvFile(fileIO, keyColumn = 0, valueColumn = 1)
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

/**
 * Write the content of the input dictionary to the specified TSV file.  The
 * keys will be written in column 0, and the values in column 1.
 */
function writeTsvFile(settings, fileIO)
{
	let fileContent = "";
	for (let key in settings)
	{
		let value = settings[key];
		fileContent += formatForTsv(key.toString()) + "\t" + formatForTsv(value.toString()) + "\n";
	}
	fileIO.write(fileContent);
}

/**
 * Split the input string using the tab character, and replace the escaped
 * characters.
 */
function parseTsvRow(s)
{
	s = s.split("\t");
	
	// QML does not support lookbehind in regex, which would be necessary to
	// properly unescape the characters, so we have to manually loop on the
	// strings and check for escape characters.
	for (let i = 0; i < s.length; i++)
	{
		let unescapedString = "";
		let escapedString = s[i];
		let j = 0;
		while (j < escapedString.length)
		{
			let c = escapedString.charAt(j);
			if (c == "\\")
			{
				let nextCharacter = escapedString.charAt(++j);
				switch (nextCharacter)
				{
					case "\\":
						unescapedString += "\\";
						break;
					
					case "n":
						unescapedString += "\n";
						break;
					
					case "r":
						unescapedString += "\r";
						break;
					
					case "t":
						unescapedString += "\t";
						break;
					
					default:
						throw "Invalid escape sequence: " + c + nextCharacter;
				}
			}
			else
			{
				unescapedString += c;
			}

			j++;
		}
		s[i] = unescapedString;
	}
	
	return s;
}

/**
 * Escape the necessary characters for a TSV file in the input string.
 */
function formatForTsv(s)
{
	s = s.replace(/\t/g, "\\t");
	s = s.replace(/\\/g, "\\\\");
	s = s.replace(/\n/g, "\\n");
	s = s.replace(/\r/g, "\\r");
	return s;
}

/**
 * Remove the empty rows from the input string.  The resulting string will have
 * a new line character at the end.
 */
function removeEmptyRows(s)
{
	s = s.split("\n");
	for (let i = s.length - 1; i >= 0; i--)
	{
		if (s[i].trim() == "")
		{
			s.splice(i, 1);
		}
	}
	return s.join("\n") + "\n";
}
