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

const VERSION = "2.1.1";

let loggerId = null;

const TRACE = 0;
const INFO = 1;
const WARNING = 2;
const ERROR = 3;
const FATAL = 4;
const LOG_LEVEL_NAMES = [
	"TRACE",
	"INFO",
	"WARNING",
	"ERROR",
	"FATAL",
];
// Current log level.  Only messages with a level equal or greater than this
// will be logged.
let logLevel = null;

let logMessages = null;
const SEPARATOR = "\t";

/**
 * Initialise the logger with input ID, and optionally with the input log level.
 * Also initialise the log file path with the current date time, and to be in
 * the specified folder.  The folder must already exist, this library does not
 * create it if it's missing.
 */
function initialise(id, level = ERROR, folderPath = "logs")
{
	loggerId = id;
	loggerId.source = Qt.resolvedUrl(".").toString() + folderPath + "/" + getFileDateTime() + "_log.txt";
	
	logLevel = level;
	logMessages = "";
}

/**
 * Log the input message with the specified log level, or INFO if no log level
 * is specified.
 */
function log(message, level = INFO)
{
	if (level >= logLevel)
	{
		logMessages += `${getRFC3339DateTime()}${SEPARATOR}${LOG_LEVEL_NAMES[level]}${SEPARATOR}${message}\n`;
	}
}

/**
 * Log the input message with TRACE level.
 */
function trace(message)
{
	log(message, TRACE);
}

/**
 * Log the input message with WARNING level.
 */
function warning(message)
{
	log(message, WARNING);
}

/**
 * Log the input message with ERROR level.
 */
function err(message)
{
	log(message, ERROR);
}

/**
 * Log the input message with FATAL level.
 */
function fatal(message)
{
	log(message, FATAL);
}

/**
 * Write the log messages to the log file.  This should be called at the end of
 * the plugin, to write the log messages, if any, to the log file.
 */
function writeLogs()
{
	if (logMessages)
	{
		loggerId.write(logMessages);
	}
}

/**
 * Log every property of the input object, with the specified level, or INFO if
 * no log level is specified.
 */
function logProperties(obj, level = INFO)
{
	let s = "" + obj + ":";
	for (let key in obj)
	{
		s += "\n\t" + key + ": " + obj[key];
	}
	log(s, level);
}

/**
 * Return the current date time in a format compatible with file names.
 */
function getFileDateTime()
{
	let currentDate = new Date();
	let year = currentDate.getFullYear();
	let month = String(currentDate.getMonth() + 1).padStart(2, "0");
	let day = String(currentDate.getDate()).padStart(2, "0");
	let hours = String(currentDate.getHours()).padStart(2, "0");
	let minutes = String(currentDate.getMinutes()).padStart(2, "0");
	let seconds = String(currentDate.getSeconds()).padStart(2, "0");
	return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
}

/**
 * Return the current date time in the RFC3339 format.
 */
function getRFC3339DateTime()
{
	let currentDate = new Date();
	let year = currentDate.getFullYear();
	let month = String(currentDate.getMonth() + 1).padStart(2, "0");
	let day = String(currentDate.getDate()).padStart(2, "0");
	let hours = String(currentDate.getHours()).padStart(2, "0");
	let minutes = String(currentDate.getMinutes()).padStart(2, "0");
	let seconds = String(currentDate.getSeconds()).padStart(2, "0");
	let milliseconds = String(currentDate.getMilliseconds()).padStart(3, "0");
	return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${milliseconds}`;
}
