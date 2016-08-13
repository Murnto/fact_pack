import std.stdio;
import std.file;
import std.string;
import std.datetime;

import fact_pack.packdata;
import fact_pack.all_types;

void test(ref Packdata pd)
{
    // writeln("copper-ore=", pd.resources["copper-ore"].title);
}

void testDynamicPacks()
{
    foreach (ref DirEntry f; dirEntries("pack", SpanMode.shallow))
    {
        writeln(f);
        if (f.isFile)
        {
            string redir = chomp(readText(f));
            writeln("redir = ", redir);
        }
        if (f.isDir)
        {
            StopWatch sw;
            sw.start();
            auto pd = new Packdata(f.name ~ "/");
            sw.stop();
            test(pd);

            writeln("  took ", sw.peek().msecs, " ms");
        }
    }
}

void main()
{
    // testDynamicPacks();

    auto pd = new Packdata("pack/base-f12/");
    test(pd);
}
