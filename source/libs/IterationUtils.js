/*
	A collection of functions and constants for iterating over a score.
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

const ELEMENT_STAFF_TEXT = 48;

function iterate(curScore, actions, logger)
{
	let onStaffStart = actions.onStaffStart || null;
	let onNewMeasure = actions.onNewMeasure || null;
	let onKeySignatureChange = actions.onKeySignatureChange || null;
	let onAnnotation = actions.onAnnotation || null;
	let staffTextOnCurrentStaffOnly = actions.staffTextOnCurrentStaffOnly || true;
	let onNote = actions.onNote || null;
	
	curScore.startCmd();
	let cursor = curScore.newCursor();
	
	// Calculate the portion of the score to iterate on.
	let startStaff;
	let endStaff;
	let startTick;
	let endTick;
	cursor.rewind(Cursor.SELECTION_START);
	if (!cursor.segment)
	{
		logger.log("Tuning the entire score.");
		startStaff = 0;
		endStaff = curScore.nstaves - 1;
		startTick = 0;
		endTick = curScore.lastSegment.tick;
	}
	else
	{
		logger.log("Tuning only the current selection.");
		startStaff = cursor.staffIdx;
		startTick = cursor.tick;
		cursor.rewind(Cursor.SELECTION_END);
		endStaff = cursor.staffIdx;
		if (cursor.tick == 0)
		{
			// If the selection includes the last note of the score, .rewind()
			// overflows and goes back to tick 0.
			endTick = curScore.lastSegment.tick;
		}
		else
		{
			endTick = cursor.tick;
		}
		logger.trace("Tuning only ticks: " + startTick + " - " + endTick);
		logger.trace("Tuning only staffs: " + startStaff + " - " + endStaff);
	}
	
	// Iterate on the score.
	for (let staff = startStaff; staff <= endStaff; staff++)
	{
		for (let voice = 0; voice < 4; voice++)
		{
			logger.log("Tuning Staff: " + staff + "; Voice: " + voice);
			
			cursor.voice = voice;
			cursor.staffIdx = staff;
			cursor.rewindToTick(startTick);
			
			let previousKeySignature = cursor.keySignature;
			
			if (onStaffStart)
			{
				onStaffStart();
			}
			
			// Loop on the element of the current staff.
			while (cursor.segment && (cursor.tick <= endTick))
			{
				if (cursor.segment.tick == cursor.measure.firstSegment.tick)
				{
					if (onNewMeasure)
					{
						onNewMeasure();
					}
				}
				
				if (cursor.keySignature != previousKeySignature)
				{
					if (onKeySignatureChange)
					{
						onKeySignatureChange(cursor.keySignature);
					}
					previousKeySignature = cursor.keySignature;
				}
				
				for (let i = 0; i < cursor.segment.annotations.length; i++)
				{
					let annotation = cursor.segment.annotations[i];
					let annotationText = annotation.text;
					if (annotationText)
					{
						if (onAnnotation)
						{
							if ((annotation.type === ELEMENT_STAFF_TEXT) && staffTextOnCurrentStaffOnly)
							{
								let annotationPart = annotation.staff.part;
								if ((4 * staff >= annotationPart.startTrack) && (4 * staff < annotationPart.endTrack))
								{
									onAnnotation(annotation);
								}
							}
							else
							{
								onAnnotation(annotation);
							}
						}
					}
				}
				
				if (cursor.element && (cursor.element.type == Element.CHORD))
				{
					let graceChords = cursor.element.graceNotes;
					for (let i = 0; i < graceChords.length; i++)
					{
						let notes = graceChords[i].notes;
						for (let j = 0; j < notes.length; j++)
						{
							if (onNote)
							{
								onNote(notes[j]);
							}
						}
					}
					
					let notes = cursor.element.notes;
					for (let i = 0; i < notes.length; i++)
					{
						if (onNote)
						{
							onNote(notes[i]);
						}
					}
				}
				
				cursor.next();
			}
		}
	}
	
	curScore.endCmd();
}
