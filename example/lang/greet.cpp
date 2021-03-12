export module lang:greet;

import <iostream>;

import text;

export void greet() { std::cout << "Hello, " << name() << "!\n"; }
