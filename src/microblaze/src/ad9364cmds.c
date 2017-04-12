#include "ad9364cmds.h"
#include "ad9364/ad9361_api.h"
#include "ad9364/platform.h"
#include "ad9364/parameters.h"
#include "freesrp_util.h"
#include "freesrp.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

cmd_function cmd_list[] = {
	get_register, 			/* 00: [uint16_t] -> [uint8_t] */
	get_tx_lo_freq, 		/* 01:            -> [uint64_t] */
	set_tx_lo_freq, 		/* 02: [uint64_t] -> [uint64_t] */
	get_tx_samp_freq, 		/* 03:            -> [uint32_t] */
	set_tx_samp_freq, 		/* 04: [uint32_t] -> [uint32_t] */
	get_tx_rf_bandwidth, 	/* 05:            -> [uint32_t] */
	set_tx_rf_bandwidth, 	/* 06: [uint32_t] -> [uint32_t] */
	get_tx_attenuation, 	/* 07:            -> [uint32_t] */
	set_tx_attenuation, 	/* 08: [uint32_t] -> [uint32_t] */
	get_tx_fir_en, 			/* 09:            -> [uint8_t] */
	set_tx_fir_en, 			/* 10: [uint8_t]  -> [uint8_t] */
	get_rx_lo_freq, 		/* 11:            -> [uint64_t] */
	set_rx_lo_freq, 		/* 12: [uint64_t] -> [uint64_t] */
	get_rx_samp_freq, 		/* 13:            -> [uint32_t] */
	set_rx_samp_freq, 		/* 14: [uint32_t] -> [uint32_t] */
	get_rx_rf_bandwidth, 	/* 15:            -> [uint32_t] */
	set_rx_rf_bandwidth, 	/* 16: [uint32_t] -> [uint32_t] */
	get_rx_gc_mode, 		/* 17:            -> [uint8_t] */
	set_rx_gc_mode, 		/* 18: [uint8_t]  -> [uint8_t] */
	get_rx_rf_gain,			/* 19:            -> [int32_t] */
	set_rx_rf_gain, 		/* 20: [int32_t]  -> [int32_t] */
	get_rx_fir_en, 			/* 21:            -> [uint8_t] */
	set_rx_fir_en, 			/* 22: [uint8_t]  -> [uint8_t] */
	set_datapath_en, 		/* 23: [uint8_t]  -> [uint8_t] */
	get_version,			/* 24: 			  -> [uint64_t] */
	set_loopback_en,        /* 25: [uint8_t]  -> [uint8_t] */
};
const char cmd_no = (sizeof(cmd_list) / sizeof(cmd_function));

/**************************************************************************//***
 * @brief Reads specified register.
 *
 * @return None.
*******************************************************************************/
void get_register(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "register?" command
{
	uint16_t reg_addr;
	uint8_t reg_val;
	struct spi_device spi;

	if(param_no >= 1)
	{
		spi.id_no = 0;
		memcpy(&reg_addr, param, sizeof(reg_addr));
		reg_val = ad9361_spi_read(&spi, reg_addr);
		*error = CMD_OK;
		memcpy(response, &reg_val, sizeof(reg_val));
		printf("register[0x%x]=0x%x\n\r", reg_addr, reg_val);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: get_register: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current TX LO frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void get_tx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_lo_freq?" command
{
	uint64_t lo_freq_hz;

	ad9361_get_tx_lo_freq(ad9361_phy, &lo_freq_hz);

	*error = CMD_OK;
	memcpy(response, &lo_freq_hz, sizeof(lo_freq_hz));

	printf("tx_lo_freq=%llu Hz\n\r", lo_freq_hz);
}

/**************************************************************************//***
 * @brief Sets the TX LO frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void set_tx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_lo_freq=" command
{
	uint64_t lo_freq_hz;
	uint32_t port = TXA;

	if(param_no >= 1)
	{
		memcpy(&lo_freq_hz, param, sizeof(lo_freq_hz));

		// Select appropriate signal port/path
		if(lo_freq_hz >= 3000000000ULL) // 3000-6000 MHz: Port A
		{
			port = TXA;
			printf("INFO: using TX port A\n\r");
		}
		else // 70-3000 MHz: Port B
		{
			port = TXB;
			printf("INFO: using TX port B\n\r");
		}
		ad9361_set_tx_rf_port_output(ad9361_phy, port);
		tx_band_select(port);

		ad9361_set_tx_lo_freq(ad9361_phy, lo_freq_hz);
		ad9361_get_tx_lo_freq(ad9361_phy, &lo_freq_hz);

		*error = CMD_OK;
		memcpy(response, &lo_freq_hz, sizeof(lo_freq_hz));

		printf("tx_lo_freq=%llu Hz\n\r", lo_freq_hz);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_tx_lo_freq: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current sampling frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void get_tx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_samp_freq?" command
{
	uint32_t sampling_freq_hz;

	ad9361_get_tx_sampling_freq(ad9361_phy, &sampling_freq_hz);

	*error = CMD_OK;
	memcpy(response, &sampling_freq_hz, sizeof(sampling_freq_hz));

	printf("tx_samp_freq=%lu Hz\n\r", sampling_freq_hz);
}

/**************************************************************************//***
 * @brief Sets the sampling frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void set_tx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_samp_freq=" command
{
	uint32_t sampling_freq_hz;

	if(param_no >= 1)
	{
		memcpy(&sampling_freq_hz, param, sizeof(sampling_freq_hz));
		ad9361_set_tx_sampling_freq(ad9361_phy, sampling_freq_hz);
		ad9361_get_tx_sampling_freq(ad9361_phy, &sampling_freq_hz);

		*error = CMD_OK;
		memcpy(response, &sampling_freq_hz, sizeof(sampling_freq_hz));

		printf("tx_samp_freq=%lu Hz\n\r", sampling_freq_hz);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_tx_samp_freq: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current TX RF bandwidth [Hz].
 *
 * @return None.
*******************************************************************************/
void get_tx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_rf_bandwidth?" command
{
	uint32_t bandwidth_hz;

	ad9361_get_tx_rf_bandwidth(ad9361_phy, &bandwidth_hz);

	*error = CMD_OK;
	memcpy(response, &bandwidth_hz, sizeof(bandwidth_hz));

	printf("tx_rf_bandwidth=%lu Hz\n\r", bandwidth_hz);
}

/**************************************************************************//***
 * @brief Sets the TX RF bandwidth [Hz].
 *
 * @return None.
*******************************************************************************/
void set_tx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_rf_bandwidth=" command
{
	uint32_t bandwidth_hz;

	if(param_no >= 1)
	{
		memcpy(&bandwidth_hz, param, sizeof(bandwidth_hz));
		ad9361_set_tx_rf_bandwidth(ad9361_phy, bandwidth_hz);
		ad9361_get_tx_rf_bandwidth(ad9361_phy, &bandwidth_hz);

		*error = CMD_OK;
		memcpy(response, &bandwidth_hz, sizeof(bandwidth_hz));

		printf("tx_rf_bandwidth=%lu Hz\n\r", bandwidth_hz);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_tx_rf_bandwidth: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current TX attenuation [mdB].
 *
 * @return None.
*******************************************************************************/
void get_tx_attenuation(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx1_attenuation?" command
{
	uint32_t attenuation_mdb;

	ad9361_get_tx_attenuation(ad9361_phy, 0, &attenuation_mdb);

	*error = CMD_OK;
	memcpy(response, &attenuation_mdb, sizeof(attenuation_mdb));

	printf("tx_attenuation=%lu mdB\n\r", attenuation_mdb);
}

/**************************************************************************//***
 * @brief Sets the TX attenuation [mdB].
 *
 * @return None.
*******************************************************************************/
void set_tx_attenuation(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx1_attenuation=" command
{
	uint32_t attenuation_mdb;

	if(param_no >= 1)
	{
		attenuation_mdb = param[0];
		memcpy(&attenuation_mdb, param, sizeof(attenuation_mdb));
		ad9361_set_tx_attenuation(ad9361_phy, 0, attenuation_mdb);
		ad9361_get_tx_attenuation(ad9361_phy, 0, &attenuation_mdb);

		*error = CMD_OK;
		memcpy(response, &attenuation_mdb, sizeof(attenuation_mdb));

		printf("tx_attenuation=%lu mdB\n\r", attenuation_mdb);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_tx_attenuation: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current TX FIR state.
 *
 * @return None.
*******************************************************************************/
void get_tx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_fir_en?" command
{
	uint8_t en_dis;

	ad9361_get_tx_fir_en_dis(ad9361_phy, &en_dis);

	*error = CMD_OK;
	memcpy(response, &en_dis, sizeof(en_dis));

	printf("tx_fir_en=%d\n\r", en_dis);
}

/**************************************************************************//***
 * @brief Sets the TX FIR state.
 *
 * @return None.
*******************************************************************************/
void set_tx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "tx_fir_en=" command
{
	uint8_t en_dis;

	if(param_no >= 1)
	{
		en_dis = param[0];
		memcpy(&en_dis, param, sizeof(en_dis));
		ad9361_set_tx_fir_en_dis(ad9361_phy, en_dis);
		ad9361_get_tx_fir_en_dis(ad9361_phy, &en_dis);

		*error = CMD_OK;
		memcpy(response, &en_dis, sizeof(en_dis));

		printf("tx_fir_en=%d\n\r", en_dis);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_tx_fir_en: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX LO frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void get_rx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_lo_freq?" command
{
	uint64_t lo_freq_hz;

	ad9361_get_rx_lo_freq(ad9361_phy, &lo_freq_hz);

	*error = CMD_OK;
	memcpy(response, &lo_freq_hz, sizeof(lo_freq_hz));

	printf("rx_lo_freq=%llu Hz\n\r", lo_freq_hz);
}

/**************************************************************************//***
 * @brief Sets the RX LO frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void set_rx_lo_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_lo_freq=" command
{
	uint64_t lo_freq_hz;
	uint32_t port = A_BALANCED;

	if(param_no >= 1)
	{
		memcpy(&lo_freq_hz, param, sizeof(lo_freq_hz));

		// Select appropriate signal port/path
		if(lo_freq_hz >= 3000000000ULL) // 3000-6000 MHz: Port A
		{
			port = A_BALANCED;
			printf("INFO: using RX port A\n\r");
		}
		else if(lo_freq_hz >= 1600000000ULL) // 1600-3000 MHz: Port B
		{
			port = B_BALANCED;
			printf("INFO: using RX port B\n\r");
		}
		else // 70-1800 MHz: Port C
		{
			port = C_BALANCED;
			printf("INFO: using RX port C\n\r");
		}
		ad9361_set_rx_rf_port_input(ad9361_phy, port);
		rx_band_select(port);

		// Set LO frequency
		ad9361_set_rx_lo_freq(ad9361_phy, lo_freq_hz);
		ad9361_get_rx_lo_freq(ad9361_phy, &lo_freq_hz);

		*error = CMD_OK;
		memcpy(response, &lo_freq_hz, sizeof(lo_freq_hz));

		printf("rx_lo_freq=%llu Hz\n\r", lo_freq_hz);
	}
	else
	{
		printf("ERROR: set_rx_lo_freq: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX sampling frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void get_rx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_samp_freq?" command
{
	uint32_t sampling_freq_hz;

	ad9361_get_rx_sampling_freq(ad9361_phy, &sampling_freq_hz);

	*error = CMD_OK;
	memcpy(response, &sampling_freq_hz, sizeof(sampling_freq_hz));

	printf("rx_samp_freq=%lu Hz\n\r", sampling_freq_hz);
}

/**************************************************************************//***
 * @brief Sets the RX sampling frequency [Hz].
 *
 * @return None.
*******************************************************************************/
void set_rx_samp_freq(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_samp_freq=" command
{
	uint32_t sampling_freq_hz;

	if(param_no >= 1)
	{
		sampling_freq_hz = (uint32_t)param[0];
		memcpy(&sampling_freq_hz, param, sizeof(sampling_freq_hz));
		ad9361_set_rx_sampling_freq(ad9361_phy, sampling_freq_hz);
		ad9361_get_rx_sampling_freq(ad9361_phy, &sampling_freq_hz);

		*error = CMD_OK;
		memcpy(response, &sampling_freq_hz, sizeof(sampling_freq_hz));

		printf("rx_samp_freq=%lu Hz\n\r", sampling_freq_hz);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: rx_samp_freq: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX RF bandwidth [Hz].
 *
 * @return None.
*******************************************************************************/
void get_rx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_rf_bandwidth?" command
{
	uint32_t bandwidth_hz;

	ad9361_get_rx_rf_bandwidth(ad9361_phy, &bandwidth_hz);

	*error = CMD_OK;
	memcpy(response, &bandwidth_hz, sizeof(bandwidth_hz));

	printf("rx_rf_bandwidth=%lu Hz\n\r", bandwidth_hz);
}

/**************************************************************************//***
 * @brief Sets the RX RF bandwidth [Hz].
 *
 * @return None.
*******************************************************************************/
void set_rx_rf_bandwidth(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_rf_bandwidth=" command
{
	uint32_t bandwidth_hz;

	if(param_no >= 1)
	{
		memcpy(&bandwidth_hz, param, sizeof(bandwidth_hz));
		ad9361_set_rx_rf_bandwidth(ad9361_phy, bandwidth_hz);
		ad9361_get_rx_rf_bandwidth(ad9361_phy, &bandwidth_hz);

		*error = CMD_OK;
		memcpy(response, &bandwidth_hz, sizeof(bandwidth_hz));

		printf("rx_rf_bandwidth=%lu Hz\n\r", bandwidth_hz);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_rx_rf_bandwidth: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX GC mode.
 *
 * @return None.
*******************************************************************************/
void get_rx_gc_mode(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx1_gc_mode?" command
{
	uint8_t gc_mode;

	ad9361_get_rx_gain_control_mode(ad9361_phy, 0, &gc_mode);

	*error = CMD_OK;
	memcpy(response, &gc_mode, sizeof(gc_mode));

	printf("rx_gc_mode=%d\n\r", gc_mode);
}

/**************************************************************************//***
 * @brief Sets the RX GC mode.
 *
 * @return None.
*******************************************************************************/
void set_rx_gc_mode(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx1_gc_mode=" command
{
	uint8_t gc_mode;

	if(param_no >= 1)
	{
		memcpy(&gc_mode, param, sizeof(gc_mode));
		ad9361_set_rx_gain_control_mode(ad9361_phy, 0, gc_mode);
		ad9361_get_rx_gain_control_mode(ad9361_phy, 0, &gc_mode);

		*error = CMD_OK;
		memcpy(response, &gc_mode, sizeof(gc_mode));

		printf("rx_gc_mode=%d\n\r", gc_mode);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_rx_gc_mode: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX RF gain.
 *
 * @return None.
*******************************************************************************/
void get_rx_rf_gain(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx1_rf_gain?" command
{
	int32_t gain_db;

	ad9361_get_rx_rf_gain(ad9361_phy, 0, &gain_db);

	*error = CMD_OK;
	memcpy(response, &gain_db, sizeof(gain_db));

	printf("rx_rf_gain=%ld dB\n\r", gain_db);
}

/**************************************************************************//***
 * @brief Sets the RX RF gain. [dB]
 *
 * @return None.
*******************************************************************************/
void set_rx_rf_gain(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx1_rf_gain=" command
{
	int32_t gain_db;

	if(param_no >= 1)
	{
		memcpy(&gain_db, param, sizeof(gain_db));
		ad9361_set_rx_rf_gain(ad9361_phy, 0, gain_db);
		ad9361_get_rx_rf_gain(ad9361_phy, 0, &gain_db);

		*error = CMD_OK;
		memcpy(response, &gain_db, sizeof(gain_db));

		printf("rx_rf_gain=%ld dB\n\r", gain_db);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_rx_rf_gain: invalid parameter!\n\r");
	}
}

/**************************************************************************//***
 * @brief Gets current RX FIR state.
 *
 * @return None.
*******************************************************************************/
void get_rx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_fir_en?" command
{
	uint8_t en_dis;

	ad9361_get_rx_fir_en_dis(ad9361_phy, &en_dis);

	*error = CMD_OK;
	memcpy(response, &en_dis, sizeof(en_dis));

	printf("rx_fir_en=%d\n\r", en_dis);
}

/**************************************************************************//***
 * @brief Sets the RX FIR state.
 *
 * @return None.
*******************************************************************************/
void set_rx_fir_en(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response) // "rx_fir_en=" command
{
	uint8_t en_dis;

	if(param_no >= 1)
	{
		memcpy(&en_dis, param, sizeof(en_dis));
		ad9361_set_rx_fir_en_dis(ad9361_phy, en_dis);
		ad9361_get_rx_fir_en_dis(ad9361_phy, &en_dis);

		*error = CMD_OK;
		memcpy(response, &en_dis, sizeof(en_dis));

		printf("rx_fir_en=%d\n\r", en_dis);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_rx_fir_en: invalid parameter!\n\r");
	}
}

void set_datapath_en(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response)
{
	uint8_t en_dis;
	int ret = -1;

	if(param_no >= 1)
	{
		memcpy(&en_dis, param, sizeof(en_dis));
		*error = CMD_OK;
		memcpy(response, &en_dis, sizeof(en_dis));

		if(en_dis == 1)
		{
			// Enable FDD
			ret = ad9361_set_en_state_machine_mode(ad9361_phy, ENSM_MODE_PINCTRL_FDD_INDEP);
			print_ensm_state(ad9361_phy);

			if(ret == 0)
			{
				// Enable
				ctrl_set_value(GPIO_DATAPATH_ENABLE, 0);
				ctrl_set_value(GPIO_DATAPATH_FLUSH, 1);
				udelay(10);
				ctrl_set_value(GPIO_DATAPATH_FLUSH, 0);
				ctrl_set_value(GPIO_DATAPATH_ENABLE, 1);
			}
		}
		else
		{
			// Disable
			ctrl_set_value(GPIO_DATAPATH_ENABLE, 0);
			ctrl_set_value(GPIO_DATAPATH_FLUSH, 1);
			udelay(10);
			ctrl_set_value(GPIO_DATAPATH_FLUSH, 0);

			// Go to wait state
			ret = ad9361_set_en_state_machine_mode(ad9361_phy, ENSM_MODE_WAIT);
			print_ensm_state(ad9361_phy);
		}

		if(ret != 0)
		{
			*error = CMD_ENSM_ERR;
		}

		printf("datapath_en=%d\n\r", en_dis);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_datapath_en: invalid parameter!\n\r");
	}
}

void get_version(struct ad9361_rf_phy *ad9361_phy, uint64_t *param, char param_no, char* error, uint64_t* response)
{
	uint8_t version[8] = {
			FREESRP_FPGA_VERSION_MAJOR,
			FREESRP_FPGA_VERSION_MINOR,
			FREESRP_FPGA_VERSION_PATCH,
			0,
			0,
			0,
			0,
			0
	};

	*error = CMD_OK;
	memcpy(response, &version, sizeof(uint64_t));
}

void set_loopback_en(struct ad9361_rf_phy *ad9361_phy, uint64_t* param, char param_no, char* error, uint64_t* response)
{
	uint8_t en_dis;
	int ret = -1;

	if(param_no >= 1)
	{
		memcpy(&en_dis, param, sizeof(en_dis));
		*error = CMD_OK;
		memcpy(response, &en_dis, sizeof(en_dis));

		if(en_dis == 1)
		{
			// Enable loopback
			ret = ad9361_bist_loopback(ad9361_phy, 1);
		}
		else
		{
			// Disable
			ret = ad9361_bist_loopback(ad9361_phy, 0);
		}

		if(ret != 0)
		{
			*error = CMD_ENSM_ERR;
		}

		printf("loopback_en=%d\n\r", en_dis);
	}
	else
	{
		*error = CMD_INVALID_PARAM;
		printf("ERROR: set_loopback_en: invalid parameter!\n\r");
	}
}
