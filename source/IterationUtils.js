/*
	A collection of functions and constants for iterating over a score.
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

const VERSION = "1.3.0";

function iterate(curScore, actions, logger)
{
	try
	{
		let voicesFilter = actions.voicesFilter || null;
		let onStaffStart = actions.onStaffStart || null;
		let onNewMeasure = actions.onNewMeasure || null;
		let onClef = actions.onClef || null;
		let onKeySignature = actions.onKeySignature || null;
		let onTimeSignature = actions.onTimeSignature || null;
		let onAnnotation = actions.onAnnotation || null;
		let staffTextOnCurrentStaffOnly = (actions.staffTextOnCurrentStaffOnly !== undefined)
			? actions.staffTextOnCurrentStaffOnly : true;
		let onChord = actions.onChord || null;
		let onNote = actions.onNote || null;
		let onRest = actions.onRest || null;
		let onBarLine = actions.onBarLine || null;
		let skipSystemStartBarLine = (actions.skipSystemStartBarLine !== undefined)
			? actions.skipSystemStartBarLine : true;
		let onLayoutBreak = actions.onLayoutBreak || null;
		let onStaffEnd = actions.onStaffEnd || null;

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
			logger.log("Iterating on the entire score.");
			startStaff = 0;
			endStaff = curScore.nstaves - 1;
			startTick = 0;
			endTick = curScore.lastSegment.tick;
		}
		else
		{
			logger.log("Iterating only on the current selection.");
			startStaff = cursor.staffIdx;
			startTick = cursor.tick;
			cursor.rewind(Cursor.SELECTION_END);
			endStaff = cursor.staffIdx;
			if (cursor.tick == 0)
			{
				// If the selection includes the last note of the score,
				// .rewind() overflows and goes back to tick 0.  In this case,
				// set the end tick manually to the last tick of the score.
				endTick = curScore.lastSegment.tick;
			}
			else
			{
				endTick = cursor.tick;
			}
			logger.trace("Iterating only on ticks: " + startTick + " - " + endTick);
			logger.trace("Iterating only on staffs: " + startStaff + " - " + endStaff);
		}

		// Iterate on the score.  Segments are walked directly, rather than
		// with one cursor pass per voice, so that every voice sees the same
		// staff-wide context (annotations, measure starts, accidentals) in
		// time order.
		let voices = [0, 1, 2, 3].filter(v => !voicesFilter || voicesFilter.includes(v));
		for (let staff = startStaff; staff <= endStaff; staff++)
		{
			logger.log("Staff: " + staff);
			let staffTrack = 4 * staff;

			if (onStaffStart)
			{
				onStaffStart();
			}

			for (let measure = curScore.firstMeasure; measure; measure = measure.nextMeasure)
			{
				if (measure.firstSegment.tick > endTick)
				{
					break;
				}
				if (measure.lastSegment.tick < startTick)
				{
					continue;
				}

				if (onNewMeasure)
				{
					onNewMeasure();
				}

				if (onLayoutBreak)
				{
					for (let e of measure.elements)
					{
						// TODO: improve this check.
						if (e.name.toLowerCase() === "layoutbreak")
						{
							onLayoutBreak(e);
						}
					}
				}

				for (let segment = measure.firstSegment; segment; segment = segment.nextInMeasure)
				{
					if (segment.tick < startTick)
					{
						continue;
					}
					if (segment.tick > endTick)
					{
						break;
					}

					let staffElement = segment.elementAt(staffTrack);
					if (staffElement)
					{
						if (onClef && (staffElement.type === Element.CLEF))
						{
							onClef(staffElement);
						}

						if (onKeySignature && (staffElement.type === Element.KEYSIG))
						{
							onKeySignature(staffElement);
						}

						if (onTimeSignature && (staffElement.type === Element.TIMESIG))
						{
							onTimeSignature(staffElement);
						}

						if (
							onBarLine
							&& (staffElement.type === Element.BAR_LINE)
							&& !(skipSystemStartBarLine && (segment.segmentType === Segment.BeginBarLine))
						) {
							onBarLine(staffElement);
						}
					}

					if (onAnnotation)
					{
						for (let i = 0; i < segment.annotations.length; i++)
						{
							let annotation = segment.annotations[i];
							if (staffTextOnCurrentStaffOnly && (annotation.type === Element.STAFF_TEXT))
							{
								let annotationPart = annotation.staff.part;
								if (!(
									(staffTrack >= annotationPart.startTrack)
									&& (staffTrack < annotationPart.endTrack)
								)) {
									continue;
								}
							}

							onAnnotation(annotation);
						}
					}

					for (let voice of voices)
					{
						let element = segment.elementAt(staffTrack + voice);
						if (!element)
						{
							continue;
						}

						if (element.type === Element.CHORD)
						{
							if (onChord)
							{
								onChord(element);
							}

							if (onNote)
							{
								let graceChords = element.graceNotes;
								for (let i = 0; i < graceChords.length; i++)
								{
									let notes = graceChords[i].notes;
									for (let j = 0; j < notes.length; j++)
									{
										onNote(notes[j]);
									}
								}

								let notes = element.notes;
								for (let i = 0; i < notes.length; i++)
								{
									onNote(notes[i]);
								}
							}
						}
						else if (onRest && (element.type === Element.REST))
						{
							onRest(element);
						}
					}
				}
			}

			if (onStaffEnd)
			{
				onStaffEnd();
			}
		}
	}
	catch (error)
	{
		logger.err(error);
		throw error;
	}
	finally
	{
		curScore.endCmd();
	}
}
