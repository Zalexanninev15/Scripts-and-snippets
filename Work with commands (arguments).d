// Written in the D Programming Language, version 2

import std.stdio;
import std.string;
import std.conv;
import std.math;
import std.exception;

int main(string[] args)
{
	bool usage;
	for (int i=1; i<args.length; i++)
		switch (args[i])
		{
			case "-h":
			case "--help":
				usage = true;
				break;
			case "-g":
			case "--gamma":
				// code for gamma
				break;
			case "--sRGB":
				// code for sRGB
				break;
			default:
				string expr = join(args[i..$], " ");
				writeln(eval(expr));
				return 0;
		}

	if (args.length == 1 || usage)
	{
		stderr.writeln("Usage: " ~ args[0] ~ " [OPTIONS]... EXPRESSION");
		stderr.writeln("Options:");
		stderr.writeln("  -h	--help		Display this help screen.");
		stderr.writeln("  -g	--gamma GAMMA	Use specified gamma value (default: 2.2).");
		stderr.writeln("			Specify 0 to disable gamma correction (mathematically equivalent to specifying 1).");
		stderr.writeln("	--sRGB		Use sRGB instead of gamma correction.");
		return 2;
	}

	throw new Exception("No expression given.");
}