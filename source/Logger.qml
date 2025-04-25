/*
	QML component for writing log messages from a MuseScore plugin.
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

import FileIO 3.0

FileIO
{
	id: logger;
	property var version: "1.1.0";
	
	source: Qt.resolvedUrl(".").toString().substring(8) + "logs/" + getFileDateTime() + "_log.txt";
	
	property var logMessages: "";
	property var logLevel: 2;
	property variant logLevels:
	[
		" | TRACE   | ",
		" | INFO    | ",
		" | WARNING | ",
		" | ERROR   | ",
		" | FATAL   | ",
	]
	
	function log(message, level)
	{
		if (level === undefined)
		{
			level = 1;
		}
		
		if (level >= logLevel)
		{
			logMessages += getRFC3339DateTime() + logLevels[level] + message + "\n";
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
		log(message, 3);
	}
	
	function fatal(message)
	{
		log(message, 4);
	}
	
	function writeLogs()
	{
		if (logMessages != "")
		{
			write(logMessages);
		}
	}
	
	function getProperties(obj)
	{
		var s = "" + obj + ":";
		for (var key in obj)
		{
			s += "\n" + key + ": " + obj[key];
		}
		return s;
	}
	
	function getFileDateTime()
	{
		var currentDate = new Date();
		var year = currentDate.getFullYear();
		var month = String(currentDate.getMonth() + 1).padStart(2, "0");
		var day = String(currentDate.getDate()).padStart(2, "0");
		var hours = String(currentDate.getHours()).padStart(2, "0");
		var minutes = String(currentDate.getMinutes()).padStart(2, "0");
		var seconds = String(currentDate.getSeconds()).padStart(2, "0");
		return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
	}
	
	function getRFC3339DateTime()
	{
		var currentDate = new Date();
		var year = currentDate.getFullYear();
		var month = String(currentDate.getMonth() + 1).padStart(2, "0");
		var day = String(currentDate.getDate()).padStart(2, "0");
		var hours = String(currentDate.getHours()).padStart(2, "0");
		var minutes = String(currentDate.getMinutes()).padStart(2, "0");
		var seconds = String(currentDate.getSeconds()).padStart(2, "0");
		var centiseconds = String(currentDate.getMilliseconds()).padStart(3, "0").slice(0, 2);
		return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${centiseconds}`;
	}
}
