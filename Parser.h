/*
 * Parser.h
 *
 *  Created on: Dec 24, 2014
 *      Author: kennyskaggs
 */

#ifndef __PARSER_H_
#define __PARSER_H_

#include <vector>
#include "ClassGraphic.h"

class Parser {
	public:
		static vector<ClassGraphic*> classesFromFile(int argc, const char **argv);
};

#endif /* __PARSER_H_ */
