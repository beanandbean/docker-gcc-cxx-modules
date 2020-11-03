module;
#include <iostream>

export module lang:greet;

import text;

export void greet() { std::cout << "Hello, " << name() << "!\n"; }