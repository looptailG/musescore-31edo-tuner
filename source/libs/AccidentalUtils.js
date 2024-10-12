/*
	A collection of functions and constants about accidentals.
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

const ACCIDENTAL_DATA = {
	"NONE":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP2":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT2":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP3":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT3":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_FLAT":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_SHARP":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -50,
	},
	"FLAT_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -150,
	},
	"NATURAL_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 50,
	},
	"NATURAL_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -50,
	},
	"SHARP_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 150,
	},
	"SHARP_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 50,
	},
	"SHARP2_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 250,
	},
	"SHARP2_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 150,
	},
	"FLAT2_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -150,
	},
	"FLAT2_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -250,
	},
	"ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -50,
	},
	"ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 50,
	},
	"MIRRORED_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -50,
	},
	"MIRRORED_FLAT2":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -150,
	},
	"SHARP_SLASH":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 50,
	},
	"SHARP_SLASH4":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 150,
	},
	"FLAT_SLASH2":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_SLASH":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_SLASH3":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_SLASH2":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_ONE_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_ONE_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_ONE_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_ONE_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_ONE_ARROW_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_ONE_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_ONE_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_ONE_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_ONE_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_ONE_ARROW_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_TWO_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_TWO_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_TWO_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_TWO_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_TWO_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_TWO_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_TWO_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_TWO_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_TWO_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_TWO_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_THREE_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_THREE_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_THREE_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_THREE_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_THREE_ARROWS_DOWN":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_THREE_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_THREE_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_THREE_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_THREE_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_THREE_ARROWS_UP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"LOWER_ONE_SEPTIMAL_COMMA":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"RAISE_ONE_SEPTIMAL_COMMA":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"LOWER_TWO_SEPTIMAL_COMMAS":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"RAISE_TWO_SEPTIMAL_COMMAS":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"LOWER_ONE_UNDECIMAL_QUARTERTONE":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"RAISE_ONE_UNDECIMAL_QUARTERTONE":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"LOWER_ONE_TRIDECIMAL_QUARTERTONE":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"RAISE_ONE_TRIDECIMAL_QUARTERTONE":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_FLAT_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"NATURAL_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"SHARP_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"DOUBLE_SHARP_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"QUARTER_FLAT_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"QUARTER_SHARP_EQUAL_TEMPERED":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 0,
	},
	"FLAT_17":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -6.8,
	},
	"SHARP_17":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 6.8,
	},
	"FLAT_19":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -3.4,
	},
	"SHARP_19":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 3.4,
	},
	"FLAT_23":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -16.5,
	},
	"SHARP_23":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 16.5,
	},
	"FLAT_31":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -1.7,
	},
	"SHARP_31":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 1.7,
	},
	"FLAT_53":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -10.9,
	},
	"SHARP_53":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 10.9,
	},
	"SORI":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 33,
	},
	"KORON":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -67,
	},
	"TEN_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -167,
	},
	"TEN_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 167,
	},
	"ELEVEN_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -183,
	},
	"ELEVEN_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 183,
	},
	"ONE_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -17,
	},
	"ONE_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 17,
	},
	"TWO_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -33,
	},
	"TWO_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 33,
	},
	"THREE_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -50,
	},
	"THREE_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 50,
	},
	"FOUR_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -67,
	},
	"FOUR_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 67,
	},
	"FIVE_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -83,
	},
	"FIVE_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 83,
	},
	"SIX_TWELFTH_FLAT":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SIX_TWELFTH_SHARP":
	{
		"TPC": true,
		"DEFAULT_OFFSET": 0,
	},
	"SEVEN_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -116,
	},
	"SEVEN_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 116,
	},
	"EIGHT_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -133,
	},
	"EIGHT_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 133,
	},
	"NINE_TWELFTH_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -150,
	},
	"NINE_TWELFTH_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 150,
	},
	"SAGITTAL_5V7KD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -5.8,
	},
	"SAGITTAL_5V7KU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 5.8,
	},
	"SAGITTAL_5CD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -21.5,
	},
	"SAGITTAL_5CU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 21.5,
	},
	"SAGITTAL_7CD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -27.3,
	},
	"SAGITTAL_7CU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 27.3,
	},
	"SAGITTAL_25SDD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -43.0,
	},
	"SAGITTAL_25SDU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 43.0,
	},
	"SAGITTAL_35MDD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -48.8,
	},
	"SAGITTAL_35MDU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 48.8,
	},
	"SAGITTAL_11MDD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -53.3,
	},
	"SAGITTAL_11MDU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 53.3,
	},
	"SAGITTAL_11LDD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -60.4,
	},
	"SAGITTAL_11LDU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 60.4,
	},
	"SAGITTAL_35LDD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -64.9,
	},
	"SAGITTAL_35LDU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 64.9,
	},
	"SAGITTAL_FLAT25SU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -70.7,
	},
	"SAGITTAL_SHARP25SD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 70.7,
	},
	"SAGITTAL_FLAT7CU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -86.4,
	},
	"SAGITTAL_SHARP7CD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 86.4,
	},
	"SAGITTAL_SHARP5CD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -92.2,
	},
	"SAGITTAL_SHARP5V7KD":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 92.2,
	},
	"SAGITTAL_FLAT5CU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -107.9,
	},
	"SAGITTAL_FLAT5V7KU":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 107.9,
	},
	"SAGITTAL_FLAT":
	{
		"TPC": false,
		"DEFAULT_OFFSET": -113.7,
	},
	"SAGITTAL_SHARP":
	{
		"TPC": false,
		"DEFAULT_OFFSET": 113.7,
	},
};

/**
 * Return the name of the input note's accidental.
 */
function getAccidentalName(note)
{
	// Casting accidentalType to string is necessary to obtain the number
	// corresponding to the enum value.  Parsing it as int is needed to properly
	// compare it with the enum values in a switch statement.
	var accidentalType = parseInt("" + note.accidentalType);
	if ((accidentalType < 0) || (accidentalType >= 256))
	{
		throw "Out of bound accidental type: " + accidentalType;
	}
	
	switch (accidentalType)
	{
		case Accidental.NONE:
			return "NONE";

		case Accidental.FLAT:
			return "FLAT";

		case Accidental.NATURAL:
			return "NATURAL";

		case Accidental.SHARP:
			return "SHARP";

		case Accidental.SHARP2:
			return "SHARP2";

		case Accidental.FLAT2:
			return "FLAT2";

		case Accidental.SHARP3:
			return "SHARP3";

		case Accidental.FLAT3:
			return "FLAT3";

		case Accidental.NATURAL_FLAT:
			return "NATURAL_FLAT";

		case Accidental.NATURAL_SHARP:
			return "NATURAL_SHARP";

		case Accidental.SHARP_SHARP:
			return "SHARP_SHARP";

		case Accidental.FLAT_ARROW_UP:
			return "FLAT_ARROW_UP";

		case Accidental.FLAT_ARROW_DOWN:
			return "FLAT_ARROW_DOWN";

		case Accidental.NATURAL_ARROW_UP:
			return "NATURAL_ARROW_UP";

		case Accidental.NATURAL_ARROW_DOWN:
			return "NATURAL_ARROW_DOWN";

		case Accidental.SHARP_ARROW_UP:
			return "SHARP_ARROW_UP";

		case Accidental.SHARP_ARROW_DOWN:
			return "SHARP_ARROW_DOWN";

		case Accidental.SHARP2_ARROW_UP:
			return "SHARP2_ARROW_UP";

		case Accidental.SHARP2_ARROW_DOWN:
			return "SHARP2_ARROW_DOWN";

		case Accidental.FLAT2_ARROW_UP:
			return "FLAT2_ARROW_UP";

		case Accidental.FLAT2_ARROW_DOWN:
			return "FLAT2_ARROW_DOWN";

		case Accidental.ARROW_DOWN:
			return "ARROW_DOWN";

		case Accidental.ARROW_UP:
			return "ARROW_UP";

		case Accidental.MIRRORED_FLAT:
			return "MIRRORED_FLAT";

		case Accidental.MIRRORED_FLAT2:
			return "MIRRORED_FLAT2";

		case Accidental.SHARP_SLASH:
			return "SHARP_SLASH";

		case Accidental.SHARP_SLASH4:
			return "SHARP_SLASH4";

		case Accidental.FLAT_SLASH2:
			return "FLAT_SLASH2";

		case Accidental.FLAT_SLASH:
			return "FLAT_SLASH";

		case Accidental.SHARP_SLASH3:
			return "SHARP_SLASH3";

		case Accidental.SHARP_SLASH2:
			return "SHARP_SLASH2";

		case Accidental.DOUBLE_FLAT_ONE_ARROW_DOWN:
			return "DOUBLE_FLAT_ONE_ARROW_DOWN";

		case Accidental.FLAT_ONE_ARROW_DOWN:
			return "FLAT_ONE_ARROW_DOWN";

		case Accidental.NATURAL_ONE_ARROW_DOWN:
			return "NATURAL_ONE_ARROW_DOWN";

		case Accidental.SHARP_ONE_ARROW_DOWN:
			return "SHARP_ONE_ARROW_DOWN";

		case Accidental.DOUBLE_SHARP_ONE_ARROW_DOWN:
			return "DOUBLE_SHARP_ONE_ARROW_DOWN";

		case Accidental.DOUBLE_FLAT_ONE_ARROW_UP:
			return "DOUBLE_FLAT_ONE_ARROW_UP";

		case Accidental.FLAT_ONE_ARROW_UP:
			return "FLAT_ONE_ARROW_UP";

		case Accidental.NATURAL_ONE_ARROW_UP:
			return "NATURAL_ONE_ARROW_UP";

		case Accidental.SHARP_ONE_ARROW_UP:
			return "SHARP_ONE_ARROW_UP";

		case Accidental.DOUBLE_SHARP_ONE_ARROW_UP:
			return "DOUBLE_SHARP_ONE_ARROW_UP";

		case Accidental.DOUBLE_FLAT_TWO_ARROWS_DOWN:
			return "DOUBLE_FLAT_TWO_ARROWS_DOWN";

		case Accidental.FLAT_TWO_ARROWS_DOWN:
			return "FLAT_TWO_ARROWS_DOWN";

		case Accidental.NATURAL_TWO_ARROWS_DOWN:
			return "NATURAL_TWO_ARROWS_DOWN";

		case Accidental.SHARP_TWO_ARROWS_DOWN:
			return "SHARP_TWO_ARROWS_DOWN";

		case Accidental.DOUBLE_SHARP_TWO_ARROWS_DOWN:
			return "DOUBLE_SHARP_TWO_ARROWS_DOWN";

		case Accidental.DOUBLE_FLAT_TWO_ARROWS_UP:
			return "DOUBLE_FLAT_TWO_ARROWS_UP";

		case Accidental.FLAT_TWO_ARROWS_UP:
			return "FLAT_TWO_ARROWS_UP";

		case Accidental.NATURAL_TWO_ARROWS_UP:
			return "NATURAL_TWO_ARROWS_UP";

		case Accidental.SHARP_TWO_ARROWS_UP:
			return "SHARP_TWO_ARROWS_UP";

		case Accidental.DOUBLE_SHARP_TWO_ARROWS_UP:
			return "DOUBLE_SHARP_TWO_ARROWS_UP";

		case Accidental.DOUBLE_FLAT_THREE_ARROWS_DOWN:
			return "DOUBLE_FLAT_THREE_ARROWS_DOWN";

		case Accidental.FLAT_THREE_ARROWS_DOWN:
			return "FLAT_THREE_ARROWS_DOWN";

		case Accidental.NATURAL_THREE_ARROWS_DOWN:
			return "NATURAL_THREE_ARROWS_DOWN";

		case Accidental.SHARP_THREE_ARROWS_DOWN:
			return "SHARP_THREE_ARROWS_DOWN";

		case Accidental.DOUBLE_SHARP_THREE_ARROWS_DOWN:
			return "DOUBLE_SHARP_THREE_ARROWS_DOWN";

		case Accidental.DOUBLE_FLAT_THREE_ARROWS_UP:
			return "DOUBLE_FLAT_THREE_ARROWS_UP";

		case Accidental.FLAT_THREE_ARROWS_UP:
			return "FLAT_THREE_ARROWS_UP";

		case Accidental.NATURAL_THREE_ARROWS_UP:
			return "NATURAL_THREE_ARROWS_UP";

		case Accidental.SHARP_THREE_ARROWS_UP:
			return "SHARP_THREE_ARROWS_UP";

		case Accidental.DOUBLE_SHARP_THREE_ARROWS_UP:
			return "DOUBLE_SHARP_THREE_ARROWS_UP";

		case Accidental.LOWER_ONE_SEPTIMAL_COMMA:
			return "LOWER_ONE_SEPTIMAL_COMMA";

		case Accidental.RAISE_ONE_SEPTIMAL_COMMA:
			return "RAISE_ONE_SEPTIMAL_COMMA";

		case Accidental.LOWER_TWO_SEPTIMAL_COMMAS:
			return "LOWER_TWO_SEPTIMAL_COMMAS";

		case Accidental.RAISE_TWO_SEPTIMAL_COMMAS:
			return "RAISE_TWO_SEPTIMAL_COMMAS";

		case Accidental.LOWER_ONE_UNDECIMAL_QUARTERTONE:
			return "LOWER_ONE_UNDECIMAL_QUARTERTONE";

		case Accidental.RAISE_ONE_UNDECIMAL_QUARTERTONE:
			return "RAISE_ONE_UNDECIMAL_QUARTERTONE";

		case Accidental.LOWER_ONE_TRIDECIMAL_QUARTERTONE:
			return "LOWER_ONE_TRIDECIMAL_QUARTERTONE";

		case Accidental.RAISE_ONE_TRIDECIMAL_QUARTERTONE:
			return "RAISE_ONE_TRIDECIMAL_QUARTERTONE";

		case Accidental.DOUBLE_FLAT_EQUAL_TEMPERED:
			return "DOUBLE_FLAT_EQUAL_TEMPERED";

		case Accidental.FLAT_EQUAL_TEMPERED:
			return "FLAT_EQUAL_TEMPERED";

		case Accidental.NATURAL_EQUAL_TEMPERED:
			return "NATURAL_EQUAL_TEMPERED";

		case Accidental.SHARP_EQUAL_TEMPERED:
			return "SHARP_EQUAL_TEMPERED";

		case Accidental.DOUBLE_SHARP_EQUAL_TEMPERED:
			return "DOUBLE_SHARP_EQUAL_TEMPERED";

		case Accidental.QUARTER_FLAT_EQUAL_TEMPERED:
			return "QUARTER_FLAT_EQUAL_TEMPERED";

		case Accidental.QUARTER_SHARP_EQUAL_TEMPERED:
			return "QUARTER_SHARP_EQUAL_TEMPERED";

		case Accidental.FLAT_17:
			return "FLAT_17";

		case Accidental.SHARP_17:
			return "SHARP_17";

		case Accidental.FLAT_19:
			return "FLAT_19";

		case Accidental.SHARP_19:
			return "SHARP_19";

		case Accidental.FLAT_23:
			return "FLAT_23";

		case Accidental.SHARP_23:
			return "SHARP_23";

		case Accidental.FLAT_31:
			return "FLAT_31";

		case Accidental.SHARP_31:
			return "SHARP_31";

		case Accidental.FLAT_53:
			return "FLAT_53";

		case Accidental.SHARP_53:
			return "SHARP_53";

		case Accidental.SORI:
			return "SORI";

		case Accidental.KORON:
			return "KORON";

		case Accidental.TEN_TWELFTH_FLAT:
			return "TEN_TWELFTH_FLAT";

		case Accidental.TEN_TWELFTH_SHARP:
			return "TEN_TWELFTH_SHARP";

		case Accidental.ELEVEN_TWELFTH_FLAT:
			return "ELEVEN_TWELFTH_FLAT";

		case Accidental.ELEVEN_TWELFTH_SHARP:
			return "ELEVEN_TWELFTH_SHARP";

		case Accidental.ONE_TWELFTH_FLAT:
			return "ONE_TWELFTH_FLAT";

		case Accidental.ONE_TWELFTH_SHARP:
			return "ONE_TWELFTH_SHARP";

		case Accidental.TWO_TWELFTH_FLAT:
			return "TWO_TWELFTH_FLAT";

		case Accidental.TWO_TWELFTH_SHARP:
			return "TWO_TWELFTH_SHARP";

		case Accidental.THREE_TWELFTH_FLAT:
			return "THREE_TWELFTH_FLAT";

		case Accidental.THREE_TWELFTH_SHARP:
			return "THREE_TWELFTH_SHARP";

		case Accidental.FOUR_TWELFTH_FLAT:
			return "FOUR_TWELFTH_FLAT";

		case Accidental.FOUR_TWELFTH_SHARP:
			return "FOUR_TWELFTH_SHARP";

		case Accidental.FIVE_TWELFTH_FLAT:
			return "FIVE_TWELFTH_FLAT";

		case Accidental.FIVE_TWELFTH_SHARP:
			return "FIVE_TWELFTH_SHARP";

		case Accidental.SIX_TWELFTH_FLAT:
			return "SIX_TWELFTH_FLAT";

		case Accidental.SIX_TWELFTH_SHARP:
			return "SIX_TWELFTH_SHARP";

		case Accidental.SEVEN_TWELFTH_FLAT:
			return "SEVEN_TWELFTH_FLAT";

		case Accidental.SEVEN_TWELFTH_SHARP:
			return "SEVEN_TWELFTH_SHARP";

		case Accidental.EIGHT_TWELFTH_FLAT:
			return "EIGHT_TWELFTH_FLAT";

		case Accidental.EIGHT_TWELFTH_SHARP:
			return "EIGHT_TWELFTH_SHARP";

		case Accidental.NINE_TWELFTH_FLAT:
			return "NINE_TWELFTH_FLAT";

		case Accidental.NINE_TWELFTH_SHARP:
			return "NINE_TWELFTH_SHARP";

		case Accidental.SAGITTAL_5V7KD:
			return "SAGITTAL_5V7KD";

		case Accidental.SAGITTAL_5V7KU:
			return "SAGITTAL_5V7KU";

		case Accidental.SAGITTAL_5CD:
			return "SAGITTAL_5CD";

		case Accidental.SAGITTAL_5CU:
			return "SAGITTAL_5CU";

		case Accidental.SAGITTAL_7CD:
			return "SAGITTAL_7CD";

		case Accidental.SAGITTAL_7CU:
			return "SAGITTAL_7CU";

		case Accidental.SAGITTAL_25SDD:
			return "SAGITTAL_25SDD";

		case Accidental.SAGITTAL_25SDU:
			return "SAGITTAL_25SDU";

		case Accidental.SAGITTAL_35MDD:
			return "SAGITTAL_35MDD";

		case Accidental.SAGITTAL_35MDU:
			return "SAGITTAL_35MDU";

		case Accidental.SAGITTAL_11MDD:
			return "SAGITTAL_11MDD";

		case Accidental.SAGITTAL_11MDU:
			return "SAGITTAL_11MDU";

		case Accidental.SAGITTAL_11LDD:
			return "SAGITTAL_11LDD";

		case Accidental.SAGITTAL_11LDU:
			return "SAGITTAL_11LDU";

		case Accidental.SAGITTAL_35LDD:
			return "SAGITTAL_35LDD";

		case Accidental.SAGITTAL_35LDU:
			return "SAGITTAL_35LDU";

		case Accidental.SAGITTAL_FLAT25SU:
			return "SAGITTAL_FLAT25SU";

		case Accidental.SAGITTAL_SHARP25SD:
			return "SAGITTAL_SHARP25SD";

		case Accidental.SAGITTAL_FLAT7CU:
			return "SAGITTAL_FLAT7CU";

		case Accidental.SAGITTAL_SHARP7CD:
			return "SAGITTAL_SHARP7CD";

		case Accidental.SAGITTAL_SHARP5CD:
			return "SAGITTAL_SHARP5CD";

		case Accidental.SAGITTAL_SHARP5V7KD:
			return "SAGITTAL_SHARP5V7KD";

		case Accidental.SAGITTAL_FLAT5CU:
			return "SAGITTAL_FLAT5CU";

		case Accidental.SAGITTAL_FLAT5V7KU:
			return "SAGITTAL_FLAT5V7KU";

		case Accidental.SAGITTAL_FLAT:
			return "SAGITTAL_FLAT";

		case Accidental.SAGITTAL_SHARP:
			return "SAGITTAL_SHARP";
		
		default:
			throw "Unrecognised accidental type: " + note.accidentalType;
	}
}
