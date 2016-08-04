module fact_pack.category_data;

import std.stdio;
import std.algorithm : reverse;
import std.json;
import std.regex : replaceAll, regex;
import std.string : chomp;

import jsonizer;


import fact_pack.packdata;
import fact_pack.all_types;

struct CDHeader
{
    string name;
    bool raw;
}

struct CDItem
{
    string display;
    string parser;
    bool raw;

    this(string display, string func = null, bool raw = false)
    {
        this.display = display;
        this.parser = func;
        this.raw = raw;
    }
}

struct CDContainer
{
    string name;
    string title;
    CDHeader[] headers;
    BasicEnt[] ents;
}

mixin template EnumerateCategoryData()
{
    CDContainer[string] enumerateCategoryData()
    {
        import std.traits;

        CDContainer[string] ret;

        // pragma(msg, "entityClasses()");
        foreach (mem; __traits(allMembers, typeof(this)))
        {
            static if (__traits(compiles, typeof(__traits(getMember, this,
                    mem))) && !isSomeFunction!(__traits(getMember, this, mem)))
            {
                alias MemberType = typeof(__traits(getMember, this, mem));
                // pragma(msg, "mem= ", mem, " | ", MemberType);
                static if (__traits(compiles, KeyType!MemberType))
                {
                    alias VType = ValueType!MemberType;
                    alias KType = KeyType!MemberType;
                    static if (is(KType == string) && hasMember!(VType, "getHeaders")) {
                        // pragma(msg, "    ", isAssignable!(BasicEnt, VType));
                        auto cdc = CDContainer();
                        mixin("cdc.ents = cast(BasicEnt[])" ~ mem ~ ".values();");
                        mixin("cdc.headers = " ~ mem ~ ".values()[0].getHeaders();");
                        cdc.title = chomp(replaceAll(VType.stringof, regex("([A-Z])"), " $1")) ~ "s";
                        cdc.name = mem;
                        ret[mem] = cdc;
                    }
                }
            }
        }

        return ret;
    }
}

mixin template CategoryData()
{
    private CDHeader[] cachedHeaders;

    string[] parse(Packdata pd)
    {
        import jsonizer.internal.util : findAttribute;
        
        string[] ret;

        alias T = typeof(this);

        foreach (x; __traits(allMembers, T))
        {
            static if (__traits(compiles, __traits(getMember, this, x)))
            {
                alias found = findAttribute!(CDItem, __traits(getMember, this, x));

                foreach (attr; found)
                {
                    alias MemberType = typeof(mixin(x));

                    static if (is(MemberType == class))
                    {
                        ret ~= __traits(getMember, this, x).parse(pd);
                    }
                    else
                    {
                        mixin("ret ~= to!string(" ~ (attr.parser ? attr.parser : "this." ~ x) ~ ");");
                    }
                }
            }
        }

        reverse(ret);
        return ret;
    }

    CDHeader[] getHeaders()
    {
        import jsonizer.internal.util : findAttribute;

        if (cachedHeaders !is null)
        {
            return cachedHeaders;
        }

        CDHeader[] ret;

        alias T = typeof(this);

        foreach (x; __traits(allMembers, T))
        {
            static if (__traits(compiles, __traits(getMember, this, x)))
            {
                alias found = findAttribute!(CDItem, __traits(getMember, this, x));

                foreach (attr; found)
                {
                    alias MemberType = typeof(mixin(x));

                    static if (is(MemberType == class))
                    {
                        ret ~= __traits(getMember, this, x).getHeaders();
                    }
                    else
                    {
                        mixin(
                            "ret ~= CDHeader(\"" ~ attr.display ~ "\", " ~ (
                            attr.raw ? "true" : "false") ~ ");");
                    }
                }
            }
        }

        reverse(ret);
        return ret;
    }

    import std.traits;
    static if (isAssignable!(BasicEnt, typeof(this))) {
        override bool hasCategoryData() {
            return true;
        }
    }
}
