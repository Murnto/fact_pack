module fact_pack.category_data;

import std.stdio;
import std.json;

import fact_pack.packdata;
import jsonizer;
import jsonizer.internal.util : findAttribute;

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

mixin template CategoryData()
{
    private CDHeader[] cachedHeaders;

    string[] parse(Packdata pd)
    {
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
                        mixin("ret ~= " ~ (attr.parser ? attr.parser : "this." ~ x) ~ ";");
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

        return ret;
    }

    override bool hasCategoryData() {
        return true;
    }
}
