/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#ifndef AIMathCompatibility
#define AIMathCompatibility 1

#if __LP64__ || NS_BUILD_32_LIKE_64
	#define AIfabs( X )			fabs((X))
	#define AIround( X )		round((X))
	#define AIceil( X )			ceil((X))
	#define AIfloor( X )		floor((X))
	#define AIfmod( X, Y )	fmod((X),(Y))
	#define AIfmin( X, Y )	fmin((X),(Y))
	#define AIsqrt( X )			sqrt((X))

	#define AIsin( X )			sin((X))
	#define AIcos( X )			cos((X))
	#define AIatan2( X, Y )	atan2((X),(Y))
#else
	#define AIfabs( X )			fabsf((X))
	#define AIround( X )		roundf((X))
	#define AIceil( X )			ceilf((X))
	#define AIfloor( X )		floorf((X))
	#define AIfmod( X, Y )	fmodf((X),(Y))
	#define AIfmin( X, Y )	fminf((X),(Y))
	#define AIsqrt( X )			sqrtf((X))

	#define AIsin( X )			sinf((X))
	#define AIcos( X )			cosf((X))
	#define AIatan2( X, Y )	atan2f((X),(Y))
#endif

#endif
