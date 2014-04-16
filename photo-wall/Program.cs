using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CommandLine;

namespace photo_wall
{
    class Program
    {
        static void Main(string[] args)
        {
            var options = new Options();
            if (CommandLine.Parser.Default.ParseArguments(args,options)) {
                Console.WriteLine("Debug is set to {0}!", options.Debug);
            }
            Console.ReadLine();
        }
    }
}
