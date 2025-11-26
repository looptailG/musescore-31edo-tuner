/*
	A collection of functions for manipulating strings.
	Copyright (C) 2024 Alessandro Culatti

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

const VERSION = "1.0.1";

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

/**
 * Round the input number to one digit after the decimal point.
 */
function roundToOneDecimalDigit(n)
{
	try
	{
		if (isNaN(n))
		{
			throw "The input is not numeric: " + n;
		}
		let roundedNumber = "" + (Math.round(n * 10) / 10);
		if (Number.isInteger(n))
		{
			roundedNumber += ".0";
		}
		return roundedNumber;
	}
	catch (error)
	{
		console.error(error);
		return "???";
	}
}
