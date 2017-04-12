#ifndef FREESRP_UTIL_H
#define FREESRP_UTIL_H

#include <xparameters.h>
#include <xgpio.h>

#include "ad9364/ad9361.h"

void print_ensm_state(struct ad9361_rf_phy *phy);
void init_ctrl_gpio();
void ctrl_set_value(u8 gpio, u8 value);
void rx_band_select(uint32_t port);
void tx_band_select(uint32_t port);

#endif
