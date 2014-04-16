using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CommandLine;
using CommandLine.Text;

namespace photo_wall
{
    class Options
    {
        [Option('d', "debug", DefaultValue = false, HelpText = "Whether to print debug messages.")]
        public Boolean Debug  { get; set; }
        [ParserState]
        public IParserState LastParserState { get; set; }

        [HelpOption]
        public string GetUsage() {
            return HelpText.AutoBuild(this,
                (HelpText current) => HelpText.DefaultParsingErrorsHandler(this, current));
        }
    }
}
