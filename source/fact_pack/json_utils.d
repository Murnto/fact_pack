module fact_pack.json_utils;

import std.json;
import std.uni;

bool json_asbool(JSONValue jv, bool default_value = false)
{
    if (jv.isNull)
    {
        return default_value;
    }

    switch (jv.type)
    {
    case JSON_TYPE.FALSE:
        return false;
    case JSON_TYPE.TRUE:
        return true;
    case JSON_TYPE.STRING:
        if (toLower(jv.str) == "true") {
            return true;
        } else if (toLower(jv.str) == "false") {
            return false;
        }
        break;
    default:
        break;
    }

    throw new Exception("Failed to determine what " ~ jv.alignof ~ " is.");
}
