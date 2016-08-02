import std.stdio;
import std.json;
import std.variant;

import fact_pack.packdata;
import jsonizer;
import jsonizer.internal.util;

string genericFoo(T)(T bar)
{
    return to!string(bar);
}

struct CDHeader
{
    string name;
    bool raw;
}

struct CDItem
{
    string display;
    bool raw;
    string parser;

    this(string display, string func = null, bool raw = false)
    {
        this.display = display;
        this.parser = func;
        this.raw = raw;
    }
}

class EnSource
{
    mixin JsonizeMe;
    mixin CategoryData;

    @jsonize string usage_priority;
    @CDItem("source_type", "type") @jsonize string type;
}

class SomeClass
{
    mixin JsonizeMe;
    mixin CategoryData;

    @jsonize @CDItem("Name") string name;
    @jsonize string type;
    @jsonize string energy_usage;
    @CDItem @jsonize EnSource energy_source;
}

mixin template CategoryData()
{
    private CDHeader[] cachedHeaders;

    string[] parse(Packdata pd)
    {
        string[] ret;

        alias T = typeof(this);

        foreach (x; __traits(allMembers, T))
        {
            static if (__traits(compiles, __traits(getMember, this, x))) {
                alias found = findAttribute!(CDItem, __traits(getMember, this, x));

                foreach (attr; found)
                {
                    // pragma(msg, "foo ", attr);
                    alias MemberType = typeof(mixin(x));
                    // pragma(msg, x, " ", typeof(x), " ", typeof(mixin(x)));

                    auto mem = __traits(getMember, this, x);

                    static if (is(MemberType == class))
                    {
                        ret ~= mem.parse(pd);
                    } else {
                        // pragma(msg, "xd ", "ret ~= " ~ attr.parser ~ ";");
                        
                        static if (attr.parser == null)
                        {
                            mixin("ret ~= this." ~ x ~ ";");
                        } else {
                            mixin("ret ~= " ~ attr.parser ~ ";");
                        }
                    
                        // ret ~= foo;
                    }
                }
            }
        }

        return ret;
    }

    CDHeader[] getHeaders()
    {
        if (cachedHeaders !is null)
        {
            return cachedHeaders;
        }

        CDHeader[] ret;

        alias T = typeof(this);

        foreach (x; __traits(allMembers, T))
        {
            static if (__traits(compiles, __traits(getMember, this, x))) {
                alias found = findAttribute!(CDItem, __traits(getMember, this, x));

                foreach (attr; found)
                {
                    alias MemberType = typeof(mixin(x));

                    auto mem = __traits(getMember, this, x);

                    static if (is(MemberType == class))
                    {
                        ret ~= mem.getHeaders();
                    } else {
                        // pragma(msg, "xd ", "ret ~= Header(\"" ~ attr.display ~ "\", " ~ (attr.raw ? "true" : "false") ~ ");");
                        
                        mixin("ret ~= CDHeader(\"" ~ attr.display ~ "\", " ~ (attr.raw ? "true" : "false") ~ ");");
                    }
                }
            }
        }

        return ret;
    }
}

// mixin(GenStruct!("Food", "bar"));

void what(int delegate(int) foo)
{
    writeln(foo(1));
}

void theTest(ref Packdata pd)
{
    auto bar = delegate (int x) => x * 5;
    // writeln(typeof(bar));
    what(bar);

    foreach (assem; pd.mem["assembling-machine"].object)
    {
        auto s = fromJSON!SomeClass(assem);

        writeln(s.name);
        writeln("    name=", s.name);
        writeln("    type=", s.type);
        writeln("    energy_usage=", s.energy_usage);
        writeln("    ", s.getHeaders());
        writeln("    ", s.parse(pd));
    }
}

static this()
{
    // SomeClass s;    
    // writeln("foo");
    // s._fromJSON();
}