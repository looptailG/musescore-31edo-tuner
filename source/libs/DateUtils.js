/*
	A collection of functions for manipulating dates.
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
 * Return the current date time in a format compatible with file names.
 */
function getFileDateTime()
{
	const currentDate = new Date();
	const year = currentDate.getFullYear();
	const month = String(currentDate.getMonth() + 1).padStart(2, '0');
	const day = String(currentDate.getDate()).padStart(2, '0');
	const hours = String(currentDate.getHours()).padStart(2, '0');
	const minutes = String(currentDate.getMinutes()).padStart(2, '0');
	const seconds = String(currentDate.getSeconds()).padStart(2, '0');
	return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
}

/**
 * Return the current date time in the RFC3339 format.
 */
function getRFC3339DateTime()
{
	const currentDate = new Date();
	const year = currentDate.getFullYear();
	const month = String(currentDate.getMonth() + 1).padStart(2, '0');
	const day = String(currentDate.getDate()).padStart(2, '0');
	const hours = String(currentDate.getHours()).padStart(2, '0');
	const minutes = String(currentDate.getMinutes()).padStart(2, '0');
	const seconds = String(currentDate.getSeconds()).padStart(2, '0');
	const centiseconds = String(currentDate.getMilliseconds()).padStart(3, '0').slice(0, 2);
	return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${centiseconds}`;
}
