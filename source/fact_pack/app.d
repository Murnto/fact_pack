import std.stdio;
import std.file;
import std.string;
import std.datetime;

import fact_pack.packdata;
import fact_pack.all_types;

import testfoo;

void test(ref Packdata pd)
{
    // writeln("copper-ore=", pd.resources["copper-ore"].title);
    theTest(pd);
}

void main()
{

    // foreach (ref DirEntry f; dirEntries("pack", SpanMode.shallow))
    // {
    //     writeln(f);
    //     if (f.isFile)
    //     {
    //         string redir = chomp(readText(f));
    //         writeln("redir = ", redir);
    //     }
    //     if (f.isDir)
    //     {
	// 		StopWatch sw;
	// 		sw.start();
    //         auto pd = new Packdata(f.name ~ "/");
	// 		sw.stop();
	// 		test(pd);

	// 		writeln("  took ", sw.peek().msecs, " ms");
    //     }
    // }

    auto pd = new Packdata("/home/dave/dev/factorio/pack/base-f12/");
    test(pd);
    // pd = new Packdata("/home/dave/dev/factorio/pack/base-f13/");
    // test(pd);
    // pd = new Packdata("/home/dave/dev/factorio/pack/dytech-f12/");
    // pd = new Packdata("/home/dave/dev/factorio/pack/5dim-f12/");
    // pd = new Packdata("/home/dave/dev/factorio/pack/bobmods-f12/");
    // pd = new Packdata("/home/dave/dev/factorio/pack/mopack-f12/");
    // pd = new Packdata("/home/dave/dev/factorio/pack/yuoki-f12/");
    // pd = new Packdata("/home/dave/dev/factorio/pack/yuoki-f12-a/");
    // writeln(pd.find_recipes_using("item", "iron-plate"));
}
