module fact_pack.types.module_item;

import std.json;

import jsonizer;

import fact_pack.all_types;

class EffectBonus
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize real bonus = 1;
}

class ModuleEffects
{
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize(JsonizeIn.opt) EffectBonus consumption;
    @jsonize(JsonizeIn.opt) EffectBonus speed;
    @jsonize(JsonizeIn.opt) EffectBonus productivity;
    @jsonize(JsonizeIn.opt) EffectBonus pollution;
}

class Module : Craftable
{
    // mixin JsonizeMe;
    mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize JSONValue flags;
    @jsonize(JsonizeIn.opt) string category; // missing < 0.12
    @jsonize(JsonizeIn.opt) int tier; // missing < 0.12
    @jsonize ModuleEffects effect;
    @jsonize int stack_size;
    @jsonize(JsonizeIn.opt) string[string] limitation;
    @jsonize(JsonizeIn.opt) string limitation_message_key;
    @jsonize(JsonizeIn.opt) int default_request_amount;
}