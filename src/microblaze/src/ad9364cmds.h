#ifndef AD9364CMDS_H
#define AD9364CMDS_H

#include "ad9364/ad9361.h"

typedef void (*cmd_function)(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);
typedef enum command_error
{
	CMD_OK = 0,
	CMD_INVALID_PARAM,
	CMD_ENSM_ERR
} command_error;

/* Displays all available commands. */
void get_help(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets the specified register value. */
void get_register(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current TX LO frequency. */
void get_tx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the TX LO frequency. */
void set_tx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current TX sampling frequency. */
void get_tx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the TX sampling frequency. */
void set_tx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current TX RF bandwidth. */
void get_tx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the TX RF bandwidth. */
void set_tx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current TX attenuation. */
void get_tx_attenuation(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the TX attenuation. */
void set_tx_attenuation(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current TX FIR state. */
void get_tx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the TX FIR state. */
void set_tx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX LO frequency. */
void get_rx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX LO frequency. */
void set_rx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX sampling frequency. */
void get_rx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX sampling frequency. */
void set_rx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX RF bandwidth. */
void get_rx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX RF bandwidth. */
void set_rx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX1 GC mode. */
void get_rx_gc_mode(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX GC mode. */
void set_rx_gc_mode(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX RF gain. */
void get_rx_rf_gain(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX RF gain. */
void set_rx_rf_gain(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Gets current RX FIR state. */
void get_rx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Sets the RX FIR state. */
void set_rx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Enables/disables the datapath. (Puts AD9364 into FDD state/alert state and notifies the rest of the FPGA system) */
void set_datapath_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Get FPGA design version. */
void get_version(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

/* Enables/disables the AD9364's loopback BIST mode */
void set_loopback_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response);

#endif
