module fact_pack.types.item_amount;

import std.json;

import jsonizer;

import fact_pack.json_utils;

struct ItemAmount
{
    string name;
    real amount = 1;
    real amount_min = -1;
    real amount_max = -1;
    real probability = -1;
    string type = "item";
    string info_type;

    this(JSONValue jv)
    {
        if ("1" in jv)
        {
            this.name = jv["1"].str;
            this.amount = fromJSON!real(jv["2"]);
            if ("3" in jv)
            {
                this.type = jv["3"].str;
            }
        }
        else
        {
            this.name = jv["name"].str;

            if ("probability" in jv)
            {
                this.probability = fromJSON!real(jv["probability"]);
            }

            if ("amount_min" in jv)
            {
                this.amount_min = fromJSON!real(jv["amount_min"]);
                this.amount_max = fromJSON!real(jv["amount_max"]);
                this.amount = -1;
            }
            else
            {
                this.amount = fromJSON!real(jv["amount"]);
            }
            if ("type" in jv)
            {
                this.type = jv["type"].str;
            }
        }
    }
}