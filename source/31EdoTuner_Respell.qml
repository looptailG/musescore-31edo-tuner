/*
	Plugin for Musescore for respelling the selected notes according to 31EDO.
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
import FileIO
import MuseScore
import "31EdoUtils.js" as EdoUtils
import "AccidentalUtils.js" as AccidentalUtils
import "Logger.js" as Logger
import "NoteUtils.js" as NoteUtils
import "SettingsIO.js" as SettingsIO
import "TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner - Respell";
	description: "Respelle the selection, or the whole score if nothing is selected, according to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "thumbnails/31Edo_Respell_Thumbnail.png";
	version: "2.2.0"
	
	property variant settings: {};
	
	property variant keySignatures: {
		"-7": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "FLAT", "B": "FLAT"},
		"-6": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "FLAT", "B": "NONE"},
		"-5": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "FLAT", "E": "NONE", "B": "NONE"},
		"-4": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "FLAT", "A": "NONE", "E": "NONE", "B": "NONE"},
		"-3": {"F": "FLAT", "C": "FLAT", "G": "FLAT", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"-2": {"F": "FLAT", "C": "FLAT", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"-1": {"F": "FLAT", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"0": {"F": "NONE", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"1": {"F": "SHARP", "C": "NONE", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"2": {"F": "SHARP", "C": "SHARP", "G": "NONE", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"3": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "NONE", "A": "NONE", "E": "NONE", "B": "NONE"},
		"4": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "NONE", "E": "NONE", "B": "NONE"},
		"5": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "NONE", "B": "NONE"},
		"6": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "SHARP", "B": "NONE"},
		"7": {"F": "SHARP", "C": "SHARP", "G": "SHARP", "D": "SHARP", "A": "SHARP", "E": "SHARP", "B": "SHARP"}
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

	onRun:
	{
		try
		{
			settings = SettingsIO.readTsvFile(settingsId);
			
			Logger.initialise(loggerId, parseInt(settings["LogLevel"]));
			Logger.log("-- " + title + " -- Version " + version + " --");
			
			curScore.startCmd();
			
			for (var element of curScore.selection.elements)
			{
				if (element.type === Element.NOTE)
				{
					var noteName = NoteUtils.getNoteLetter(element, "tpc");
					var octave = NoteUtils.getOctave(element);
					var accidental = AccidentalUtils.getAccidentalName(element);
					Logger.log("Respelling note: " + noteName + " " + octave + " " + accidental);
					
					var segment = element.parent.parent;
					var cursor = curScore.newCursor();
					cursor.voice = element.voice;
					cursor.staffIdx = (element.staff.part.startTrack / 4) + 1;
					cursor.rewindToTick(segment.tick);
					
					// Check what accidental, if any, is applied to the current
					// note by a previous key signature or accidental.
					var previousAccidental = null;
					// Check if a standard key signature changes the current
					// note.
					var keySignature = cursor.keySignature;
					previousAccidental = keySignatures[keySignature][noteName];
					Logger.log("Key signature: " + keySignature + "; Accidental: " + previousAccidental);
					// Iterate on the previous elements, to search for a custom
					// key signature or an accidental applied to this note.
					var accidentalFound = false;
					var keySignatureChangeFound = false;
					var measureChanged = false;
					var measureStartTick = cursor.measure.firstSegment.tick;
					while (cursor.segment)
					{
						// Check for a standard key signature change.
						if (!keySignatureChangeFound && (cursor.keySignature !== keySignature))
						{
							keySignatureChangeFound = true;
							Logger.trace("Key signature change found.");
						}
						// Check for a custom key signature change.  This is
						// only relevant if we didn't find a key signature
						// change, because otherwise the custom key signature
						// wouldn't be in effect for the note we're respelling.
						// Additionally, we only check if the key signature is
						// 0, because that's what custom key signatures return.
						if (!keySignatureChangeFound && (cursor.keySignature === 0))
						{
							for (var i = 0; i < cursor.segment.annotations.length; i++)
							{
								var annotation = cursor.segment.annotations[i];
								// TODO: check that staff text elements apply only to the current staff.
								
								var customKeySignature = {};
								EdoUtils.parseCustomKeySignature(annotation.text, customKeySignature, Logger);
								if (!isEmpty(customKeySignature))
								{
									keySignatureChangeFound = true;
									var previousAccidental = customKeySignature[noteName];
									Logger.log("Previous accidental from a standard key signature: " + previousAccidental);
									break;
								}
							}
							if (keySignatureChangeFound)
							{
								break;
							}
						}
						
						// Check if we moved to a previous measure, in which
						// case we do not have to check for altered notes
						// anymore.
						if (!measureChanged && (cursor.tick < measureStartTick))
						{
							measureChanged = true;
							Logger.trace("Measure changed.");
						}
						// Check if the same note previously in the measure
						// was altered by an accidental.
						if (!measureChanged && cursor.element && (cursor.element.type === Element.CHORD))
						{
							var notes = cursor.element.notes;
							for (var i = 0; i < notes.length; i++)
							{
								var currentAccidental = checkAccidental(notes[i], noteName, octave);
								if (currentAccidental && (currentAccidental !== "NONE"))
								{
									Logger.log("Previous accidentals from a previous note in the measure: " + currentAccidental);
									previousAccidental = currentAccidental;
									accidentalFound = true;
									break;
								}
							}
							if (accidentalFound)
							{
								break;
							}
							
							var graceChords = cursor.element.graceNotes;
							for (var i = graceChords.length - 1; i >= 0; i--)
							{
								var graceNotes = graceChords[i].notes;
								for (let j = 0; j < graceNotes.length; j++)
								{
									var currentAccidental = checkAccidental(graceNotes[j], noteName, octave);
									if (currentAccidental && (currentAccidental !== "NONE"))
									{
										Logger.log("Accidental changed by a previous note in the measure: " + currentAccidental);
										accidental = currentAccidental;
										accidentalFound = true;
										break;
									}
								}
								if (accidentalFound)
								{
									break;
								}
							}
							if (accidentalFound)
							{
								break;
							}
						}
						
						if (keySignatureChangeFound && measureChanged)
						{
							break;
						}
						
						cursor.prev();
					}
					
					if (previousAccidental && (accidental === "NONE"))
					{
						Logger.log("Current accidental replaced by: " + previousAccidental);
					}
				}
			}
			
			curScore.endCmd();
		}
		catch (error)
		{
			Logger.fatal(error);
		}
		finally
		{
			try
			{
				quit();
			}
			catch (error)
			{
				Logger.err(error);
			}
			
			Logger.writeLogs();
		}
	}
	
	function checkAccidental(note, targetNote, targetOctave)
	{
		var noteName = NoteUtils.getNoteLetter(note, "tpc");
		var octave = NoteUtils.getOctave(note);
		Logger.trace("Checking accidentl for note: " + noteName + " " + octave);
		if ((noteName === targetNote) && (octave === targetOctave))
		{
			var currentAccidental = AccidentalUtils.getAccidentalName(note);
			Logger.trace("Accidental found: " + currentAccidental);
			return currentAccidental;
		}
		else
		{
			return null;
		}
	}
	
	function isEmpty(o)
	{
		for (var key in o)
		{
			return false;
		}
		return true;
	}
}
