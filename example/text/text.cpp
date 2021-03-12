export module text;

// Bypass <string> -> <iosteam> ICE
import <iostream>;

import <string>;

export std::string name() { return "world"; }