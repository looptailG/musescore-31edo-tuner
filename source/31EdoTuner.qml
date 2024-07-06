/*
	31EDO Tuner plugin for Musescore.
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

import QtQuick 2.2
import FileIO 3.0
import MuseScore 3.0
import "libs/AccidentalUtils.js" as AccidentalUtils
import "libs/DateUtils.js" as DateUtils
import "libs/NoteUtils.js" as NoteUtils
import "libs/TuningUtils.js" as TuningUtils

MuseScore
{
	title: "31EDO Tuner";
	description: "Retune the selection, or the whole score if nothing is selected, to 31EDO.";
	categoryCode: "playback";
	thumbnailName: "31EdoThumbnail.png";
	version: "2.0.0-alpha";
	
	FileIO
	{
		id: logger;
		source: Qt.resolvedUrl(".").toString().substring(8) + "logs/" + DateUtils.getFileDateTime() + "_log.txt";
		property var logMessages: "";
		property var currentLogLevel: 0;
		property variant logLevels:
		{
			0: " | TRACE   | ",
			1: " | INFO    | ",
			2: " | WARNING | ",
			3: " | ERROR   | ",
			4: " | FATAL   | ",
		}
		
		function log(message, logLevel)
		{
			if (logLevel === undefined)
			{
				logLevel = 1;
			}
			
			if (logLevel >= currentLogLevel)
			{
				logMessages += DateUtils.getRFC3339DateTime() + logLevels[logLevel] + message + "\n";
			}
		}
		
		function trace(message)
		{
			log(message, 0);
		}
		
		function warning(message)
		{
			log(message, 2);
		}
		
		function error(message)
		{
			log(measure, 3);
		}
		
		function fatal(message)
		{
			log(message, 4);
		}
		
		function writeLogMessages()
		{
			write(logMessages);
		}
	}
	
	FileIO
	{
		id: backupLogger;
		source: "C:/MSPlugins/log.txt";
	}

	onRun:
	{
		try
		{
//			logger.log("hello world");
			backupLogger.write("hello world");
		}
		catch (error)
		{
			backupLogger.write(error);
		}
		finally
		{
//			logger.writeLogMessages();
		}

		quit();
	}
}
