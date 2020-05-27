// ~\~ language=C++ filename=99-bottles/src/99-bottles.cc
// ~\~ begin <<lit/99-bottles.md|99-bottles/src/99-bottles.cc>>[0]
// ~\~ begin <<lit/99-bottles.md|includes>>[0]
#include <cstdlib>
#include <iostream>
#include <argagg/argagg.hpp>
#include <fmt/format.h>
// ~\~ end
// ~\~ begin <<lit/99-bottles.md|version>>[0]
#define VERSION "1.1"
// ~\~ end

// ~\~ begin <<lit/99-bottles.md|bottles-function>>[0]
std::string bottles(unsigned i)
{
    if (i > 1) {
        return fmt::format("{} bottles", i);
    }
    if (i == 1) {
        return "1 bottle";
    }
    return "no more bottles";
}
// ~\~ end
// ~\~ begin <<lit/99-bottles.md|print-song-function>>[0]
void print_song(unsigned n)
{
    unsigned i = n;
    while (i > 0)
    {
        fmt::print(
            "{0} of beer on the wall, "
            "{0} of beer.\n",
            bottles(i));

        fmt::print(
            "Take one down and pass it around, "
            "{} of beer on the wall.\n", 
            bottles(--i));
    }

    fmt::print(
        "No more bottles of beer on the wall, "
        "no more bottles of beer.\n"
        "Go to the store and buy some more, "
        "{} of beer on the wall.\n",
        bottles(n));
}
// ~\~ end
// ~\~ begin <<lit/99-bottles.md|main-function>>[0]
int main(int argc, char **argv)
{
    // ~\~ begin <<lit/99-bottles.md|main-body>>[0]
    // ~\~ begin <<lit/99-bottles.md|declare-arguments>>[0]
    argagg::parser argparser {{
        { "n", {"-n"},
            "(99) number of bottles to start with", 1 },
        { "help", {"-h", "--help"},
            "shows this help message", 0 },
        { "version", {"-v", "--version"},
            "shows the software version", 0 }
    }};
    // ~\~ end
    // ~\~ begin <<lit/99-bottles.md|parse-arguments>>[0]
    argagg::parser_results args;
    try {
        args = argparser.parse(argc, argv);
    } catch (std::exception const &e) {
        std::cerr << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    // ~\~ end
    // ~\~ begin <<lit/99-bottles.md|print-help-or-version>>[0]
    if (args["help"]) {
        std::cerr << "99 bottles -- " << VERSION << std::endl;
        std::cerr << "Usage: " << args.program << " [options]" << std::endl;
        std::cerr << argparser;
        return EXIT_SUCCESS;
    }

    if (args["version"]) {
        std::cerr << "99 bottles -- " << VERSION << std::endl;
        return EXIT_SUCCESS;
    }
    // ~\~ end
    // ~\~ begin <<lit/99-bottles.md|sing-a-song>>[0]
    unsigned n = args["n"].as<unsigned>(99);
    print_song(n);
    // ~\~ end
    // ~\~ end

    return EXIT_SUCCESS;
}
// ~\~ end
// ~\~ end
