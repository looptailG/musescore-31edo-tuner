/*
	A collection of functions and constants about notes.
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

const VERSION = "1.0.0";

/**
 * Return the english note name for the input note.
 */
function getNoteLetter(note, tpcMode = "tpc1")
{
	switch (note[tpcMode] % 7)
	{
		case 0:
			return "C";
		
		case 2:
		case -5:
			return "D";
		
		case 4:
		case -3:
			return "E";
		
		case 6:
		case -1:
			return "F";
		
		case 1:
		case -6:
			return "G";
		
		case 3:
		case -4:
			return "A";
		
		case 5:
		case -2:
			return "B";
	}
}

/*
 * Return the octave of the input note.
 */
function getOctave(note)
{
	return Math.floor(note.pitch / 12) - 1;
}
