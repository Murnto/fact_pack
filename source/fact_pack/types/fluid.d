module fact_pack.types.fluid;

import jsonizer;

import fact_pack.all_types;

class Fluid : Craftable
{
    mixin JsonizeMe;
    // mixin JsonizeMe!(JsonizeIgnoreExtraKeys.no);

    @jsonize Color base_color;
    @jsonize string heat_capacity;
    @jsonize Color flow_color;
    @jsonize float flow_to_energy_ratio;
    @jsonize float pressure_to_speed_ratio;
    @jsonize float max_temperature;
    @jsonize float default_temperature;
}