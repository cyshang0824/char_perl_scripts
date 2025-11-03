#!/usr/local/bin/perl

########################################################
# CY Shang (Apr. 2023) - Yorktown FLASH IO characterization
# Characterization tests supported - input sensitivity, IO leakage, PVT Compensated OD - ROCD, PVT Compensated ODT - Rtt/Vm

########################################################
# These settings are device specific


$si_therm = "NO";
$split = "TT";
$flash_select="flash";
$test = "od";
$test_mode = "typ";
$device=$ARGV[0];
chomp($device);

$cal_reference = "case";

$atp_wfs = 16;
$atp_tim = 1;
$atp_lvl = 9; #atp_max -flash ctt
$atp_dps = 3; #atp_max_flash5

$atp_wfs = 16;
$atp_tim = 1;
$atp_lvl2 = 17; #atp_max -flash ltt
$atp_dps = 3; #atp_max_flash5




#pin_leakage:
# $leak_wfs = 16;
# $leak_tim = 1;
# $leak_lvl = 10;
# $leak_dps = 6;
#override_seqlbl = "device_reset";




$bsdl_wfs = 1;
$bsdl_tim = 1;
$bsdl_lvl = 3; #bsdl_bidi_max
$bsdl_dps = 6; #atpg_max




$vil_wfs = 1;
$vih_wfs = 1;
$vilh_tim = 1;
$vilh_lvl = 3; 
$vilh_dps = 6; 



$func_wfs = 1; #waveform set for functional test
$func_tim = 1;
$func_lvl = 3; #atp_max -flash ctt
$func_dps = 6;
# vectors to use for input sensitivity
$device_func = "pm8667_bsdl_revb_DC_DC";
# vectors to use for bsdl contact check
$device_bsdl = "pm8667_bsdl_revb_DC_DC";


# vector to use for io leakage
$leak_pattern1 = "pm8667_bsdl_revb_HIZ_HIZ";
$leak_pattern2 = "flash_io_18_LEAKAGE";


# vectors to use for vil vih char
#$device_vil = "flash_io_16_CA_VIL";
#$device_vih = "flash_io_16_CA_VIH";
#$device_vil_dx = "flash_io_17_DX_VIL";
#$device_vih_dx = "flash_io_17_DX_VIH";

$device_vil = "pm8667_bsdl_revb_DC_DC";
$device_vih = "pm8667_bsdl_revb_DC_DC";
$device_vil_dx = "pm8667_bsdl_revb_DC_DC";
$device_vih_dx = "pm8667_bsdl_revb_DC_DC";

# $device_vil = "pm8667_bsdl_revb_AC_AC";
# $device_vih = "pm8667_bsdl_revb_AC_AC";
# $device_vil_dx = "pm8667_bsdl_revb_AC_AC";
# $device_vih_dx = "pm8667_bsdl_revb_AC_AC";



#voltage ratio to be used for forcing onto pin during odt/od measurements
%flash_vref_ratio = (
	"flash_ltt"	=>	0.33333333,
	"flash_ctt"	=>	0.50
);

# vectors to use for od testing
@flash_cau_od_vec = ("flash_io_2400_test_2_pu_ctt", "flash_io_2400_test_6_pu_ltt");
@flash_cad_od_vec = ("flash_io_2400_test_4_pd_ctt", "flash_io_2400_test_8_pd_ltt");
@flash_dxu_od_vec = ("flash_io_2400_test_1_pu_ctt", "flash_io_2400_test_5_pu_ltt");
@flash_dxd_od_vec = ("flash_io_2400_test_3_pd_ctt", "flash_io_2400_test_7_pd_ltt");

%flash_cau_od = (
	"flash_io_2400_test_2_pu_ctt"		=>	'48',
	"flash_io_2400_test_6_pu_ltt"		=>	'48'
);

%flash_cad_od = (
	"flash_io_2400_test_4_pd_ctt"		=>	'48',
	"flash_io_2400_test_8_pd_ltt"		=>	'48'
);

%flash_dxu_od = (
	"flash_io_2400_test_1_pu_ctt"		=>	'25',
	"flash_io_2400_test_5_pu_ltt"		=>	'25'	
);

%flash_dxd_od = (
	"flash_io_2400_test_3_pd_ctt"		=>	'25',
	"flash_io_2400_test_7_pd_ltt"		=>	'25'	
);

# # vectors to use for odt testing
# @flash_odt_vec = ("flash_io_14_ODT_48", "flash_io_15_ODT_120");

# %flash_dx_odt = (
	# "flash_io_14_ODT_48"		=>	'48',
	# "flash_io_15_ODT_120"	    	=>	'120'	
# );

# %flash_vilh_vref = (
	# "flash_io_16_CA_VIL"		=>	'0.50',
	# "flash_io_16_CA_VIH"		=>	'0.50',
	# "flash_io_17_DX_VIL"		=>	'0.50',
	# "pm8667_bsdl_reva_DC_DC"	=>	'0.50',	
	# "flash_io_17_DX_VIH"		=>	'0.50'	

# );



#class definition for all the possible pins that will be tested either in typ/rep/pvt modes

%flash_pin_class = (
"fc_wp_n"	=>	"flash_cmd",
"fc00_ale_p"	=>	"flash_cmd",
"fc00_ce0_n"	=>	"flash_cmd",
"fc00_ce1_n"	=>	"flash_cmd",
"fc00_ce2_n"	=>	"flash_cmd",
"fc00_ce3_n"	=>	"flash_cmd",
"fc00_ce4_n"	=>	"flash_cmd",
"fc00_ce5_n"	=>	"flash_cmd",
"fc00_ce6_n"	=>	"flash_cmd",
"fc00_ce7_n"	=>	"flash_cmd",
"fc00_cle_p"	=>	"flash_cmd",
"fc00_dbi_p"	=>	"flash_cmd",
"fc00_odt_n"	=>	"flash_cmd",
"fc00_re_nc"	=>	"flash_cmd",
"fc00_re_nt"	=>	"flash_cmd",
"fc00_we_n"	=>	"flash_cmd",
"fc01_ale_p"	=>	"flash_cmd",
"fc01_ce0_n"	=>	"flash_cmd",
"fc01_ce1_n"	=>	"flash_cmd",
"fc01_ce2_n"	=>	"flash_cmd",
"fc01_ce3_n"	=>	"flash_cmd",
"fc01_ce4_n"	=>	"flash_cmd",
"fc01_ce5_n"	=>	"flash_cmd",
"fc01_ce6_n"	=>	"flash_cmd",
"fc01_ce7_n"	=>	"flash_cmd",
"fc01_cle_p"	=>	"flash_cmd",
"fc01_dbi_p"	=>	"flash_cmd",
"fc01_odt_n"	=>	"flash_cmd",
"fc01_re_nc"	=>	"flash_cmd",
"fc01_re_nt"	=>	"flash_cmd",
"fc01_we_n"	=>	"flash_cmd",
"fc02_ale_p"	=>	"flash_cmd",
"fc02_ce0_n"	=>	"flash_cmd",
"fc02_ce1_n"	=>	"flash_cmd",
"fc02_ce2_n"	=>	"flash_cmd",
"fc02_ce3_n"	=>	"flash_cmd",
"fc02_ce4_n"	=>	"flash_cmd",
"fc02_ce5_n"	=>	"flash_cmd",
"fc02_ce6_n"	=>	"flash_cmd",
"fc02_ce7_n"	=>	"flash_cmd",
"fc02_cle_p"	=>	"flash_cmd",
"fc02_dbi_p"	=>	"flash_cmd",
"fc02_odt_n"	=>	"flash_cmd",
"fc02_re_nc"	=>	"flash_cmd",
"fc02_re_nt"	=>	"flash_cmd",
"fc02_we_n"	=>	"flash_cmd",
"fc03_ale_p"	=>	"flash_cmd",
"fc03_ce0_n"	=>	"flash_cmd",
"fc03_ce1_n"	=>	"flash_cmd",
"fc03_ce2_n"	=>	"flash_cmd",
"fc03_ce3_n"	=>	"flash_cmd",
"fc03_ce4_n"	=>	"flash_cmd",
"fc03_ce5_n"	=>	"flash_cmd",
"fc03_ce6_n"	=>	"flash_cmd",
"fc03_ce7_n"	=>	"flash_cmd",
"fc03_cle_p"	=>	"flash_cmd",
"fc03_dbi_p"	=>	"flash_cmd",
"fc03_odt_n"	=>	"flash_cmd",
"fc03_re_nc"	=>	"flash_cmd",
"fc03_re_nt"	=>	"flash_cmd",
"fc03_we_n"	=>	"flash_cmd",
"fc04_ale_p"	=>	"flash_cmd",
"fc04_ce0_n"	=>	"flash_cmd",
"fc04_ce1_n"	=>	"flash_cmd",
"fc04_ce2_n"	=>	"flash_cmd",
"fc04_ce3_n"	=>	"flash_cmd",
"fc04_ce4_n"	=>	"flash_cmd",
"fc04_ce5_n"	=>	"flash_cmd",
"fc04_ce6_n"	=>	"flash_cmd",
"fc04_ce7_n"	=>	"flash_cmd",
"fc04_cle_p"	=>	"flash_cmd",
"fc04_dbi_p"	=>	"flash_cmd",
"fc04_odt_n"	=>	"flash_cmd",
"fc04_re_nc"	=>	"flash_cmd",
"fc04_re_nt"	=>	"flash_cmd",
"fc04_we_n"	=>	"flash_cmd",
"fc05_ale_p"	=>	"flash_cmd",
"fc05_ce0_n"	=>	"flash_cmd",
"fc05_ce1_n"	=>	"flash_cmd",
"fc05_ce2_n"	=>	"flash_cmd",
"fc05_ce3_n"	=>	"flash_cmd",
"fc05_ce4_n"	=>	"flash_cmd",
"fc05_ce5_n"	=>	"flash_cmd",
"fc05_ce6_n"	=>	"flash_cmd",
"fc05_ce7_n"	=>	"flash_cmd",
"fc05_cle_p"	=>	"flash_cmd",
"fc05_dbi_p"	=>	"flash_cmd",
"fc05_odt_n"	=>	"flash_cmd",
"fc05_re_nc"	=>	"flash_cmd",
"fc05_re_nt"	=>	"flash_cmd",
"fc05_we_n"	=>	"flash_cmd",
"fc06_ale_p"	=>	"flash_cmd",
"fc06_ce0_n"	=>	"flash_cmd",
"fc06_ce1_n"	=>	"flash_cmd",
"fc06_ce2_n"	=>	"flash_cmd",
"fc06_ce3_n"	=>	"flash_cmd",
"fc06_ce4_n"	=>	"flash_cmd",
"fc06_ce5_n"	=>	"flash_cmd",
"fc06_ce6_n"	=>	"flash_cmd",
"fc06_ce7_n"	=>	"flash_cmd",
"fc06_cle_p"	=>	"flash_cmd",
"fc06_dbi_p"	=>	"flash_cmd",
"fc06_odt_n"	=>	"flash_cmd",
"fc06_re_nc"	=>	"flash_cmd",
"fc06_re_nt"	=>	"flash_cmd",
"fc06_we_n"	=>	"flash_cmd",
"fc07_ale_p"	=>	"flash_cmd",
"fc07_ce0_n"	=>	"flash_cmd",
"fc07_ce1_n"	=>	"flash_cmd",
"fc07_ce2_n"	=>	"flash_cmd",
"fc07_ce3_n"	=>	"flash_cmd",
"fc07_ce4_n"	=>	"flash_cmd",
"fc07_ce5_n"	=>	"flash_cmd",
"fc07_ce6_n"	=>	"flash_cmd",
"fc07_ce7_n"	=>	"flash_cmd",
"fc07_cle_p"	=>	"flash_cmd",
"fc07_dbi_p"	=>	"flash_cmd",
"fc07_odt_n"	=>	"flash_cmd",
"fc07_re_nc"	=>	"flash_cmd",
"fc07_re_nt"	=>	"flash_cmd",
"fc07_we_n"	=>	"flash_cmd",
"fc08_ale_p"	=>	"flash_cmd",
"fc08_ce0_n"	=>	"flash_cmd",
"fc08_ce1_n"	=>	"flash_cmd",
"fc08_ce2_n"	=>	"flash_cmd",
"fc08_ce3_n"	=>	"flash_cmd",
"fc08_ce4_n"	=>	"flash_cmd",
"fc08_ce5_n"	=>	"flash_cmd",
"fc08_ce6_n"	=>	"flash_cmd",
"fc08_ce7_n"	=>	"flash_cmd",
"fc08_cle_p"	=>	"flash_cmd",
"fc08_dbi_p"	=>	"flash_cmd",
"fc08_odt_n"	=>	"flash_cmd",
"fc08_re_nc"	=>	"flash_cmd",
"fc08_re_nt"	=>	"flash_cmd",
"fc08_we_n"	=>	"flash_cmd",
"fc09_ale_p"	=>	"flash_cmd",
"fc09_ce0_n"	=>	"flash_cmd",
"fc09_ce1_n"	=>	"flash_cmd",
"fc09_ce2_n"	=>	"flash_cmd",
"fc09_ce3_n"	=>	"flash_cmd",
"fc09_ce4_n"	=>	"flash_cmd",
"fc09_ce5_n"	=>	"flash_cmd",
"fc09_ce6_n"	=>	"flash_cmd",
"fc09_ce7_n"	=>	"flash_cmd",
"fc09_cle_p"	=>	"flash_cmd",
"fc09_dbi_p"	=>	"flash_cmd",
"fc09_odt_n"	=>	"flash_cmd",
"fc09_re_nc"	=>	"flash_cmd",
"fc09_re_nt"	=>	"flash_cmd",
"fc09_we_n"	=>	"flash_cmd",
"fc10_ale_p"	=>	"flash_cmd",
"fc10_ce0_n"	=>	"flash_cmd",
"fc10_ce1_n"	=>	"flash_cmd",
"fc10_ce2_n"	=>	"flash_cmd",
"fc10_ce3_n"	=>	"flash_cmd",
"fc10_ce4_n"	=>	"flash_cmd",
"fc10_ce5_n"	=>	"flash_cmd",
"fc10_ce6_n"	=>	"flash_cmd",
"fc10_ce7_n"	=>	"flash_cmd",
"fc10_cle_p"	=>	"flash_cmd",
"fc10_dbi_p"	=>	"flash_cmd",
"fc10_odt_n"	=>	"flash_cmd",
"fc10_re_nc"	=>	"flash_cmd",
"fc10_re_nt"	=>	"flash_cmd",
"fc10_we_n"	=>	"flash_cmd",
"fc11_ale_p"	=>	"flash_cmd",
"fc11_ce0_n"	=>	"flash_cmd",
"fc11_ce1_n"	=>	"flash_cmd",
"fc11_ce2_n"	=>	"flash_cmd",
"fc11_ce3_n"	=>	"flash_cmd",
"fc11_ce4_n"	=>	"flash_cmd",
"fc11_ce5_n"	=>	"flash_cmd",
"fc11_ce6_n"	=>	"flash_cmd",
"fc11_ce7_n"	=>	"flash_cmd",
"fc11_cle_p"	=>	"flash_cmd",
"fc11_dbi_p"	=>	"flash_cmd",
"fc11_odt_n"	=>	"flash_cmd",
"fc11_re_nc"	=>	"flash_cmd",
"fc11_re_nt"	=>	"flash_cmd",
"fc11_we_n"	=>	"flash_cmd",
"fc12_ale_p"	=>	"flash_cmd",
"fc12_ce0_n"	=>	"flash_cmd",
"fc12_ce1_n"	=>	"flash_cmd",
"fc12_ce2_n"	=>	"flash_cmd",
"fc12_ce3_n"	=>	"flash_cmd",
"fc12_ce4_n"	=>	"flash_cmd",
"fc12_ce5_n"	=>	"flash_cmd",
"fc12_ce6_n"	=>	"flash_cmd",
"fc12_ce7_n"	=>	"flash_cmd",
"fc12_cle_p"	=>	"flash_cmd",
"fc12_dbi_p"	=>	"flash_cmd",
"fc12_odt_n"	=>	"flash_cmd",
"fc12_re_nc"	=>	"flash_cmd",
"fc12_re_nt"	=>	"flash_cmd",
"fc12_we_n"	=>	"flash_cmd",
"fc13_ale_p"	=>	"flash_cmd",
"fc13_ce0_n"	=>	"flash_cmd",
"fc13_ce1_n"	=>	"flash_cmd",
"fc13_ce2_n"	=>	"flash_cmd",
"fc13_ce3_n"	=>	"flash_cmd",
"fc13_ce4_n"	=>	"flash_cmd",
"fc13_ce5_n"	=>	"flash_cmd",
"fc13_ce6_n"	=>	"flash_cmd",
"fc13_ce7_n"	=>	"flash_cmd",
"fc13_cle_p"	=>	"flash_cmd",
"fc13_dbi_p"	=>	"flash_cmd",
"fc13_odt_n"	=>	"flash_cmd",
"fc13_re_nc"	=>	"flash_cmd",
"fc13_re_nt"	=>	"flash_cmd",
"fc13_we_n"	=>	"flash_cmd",
"fc14_ale_p"	=>	"flash_cmd",
"fc14_ce0_n"	=>	"flash_cmd",
"fc14_ce1_n"	=>	"flash_cmd",
"fc14_ce2_n"	=>	"flash_cmd",
"fc14_ce3_n"	=>	"flash_cmd",
"fc14_ce4_n"	=>	"flash_cmd",
"fc14_ce5_n"	=>	"flash_cmd",
"fc14_ce6_n"	=>	"flash_cmd",
"fc14_ce7_n"	=>	"flash_cmd",
"fc14_cle_p"	=>	"flash_cmd",
"fc14_dbi_p"	=>	"flash_cmd",
"fc14_odt_n"	=>	"flash_cmd",
"fc14_re_nc"	=>	"flash_cmd",
"fc14_re_nt"	=>	"flash_cmd",
"fc14_we_n"	=>	"flash_cmd",
"fc15_ale_p"	=>	"flash_cmd",
"fc15_ce0_n"	=>	"flash_cmd",
"fc15_ce1_n"	=>	"flash_cmd",
"fc15_ce2_n"	=>	"flash_cmd",
"fc15_ce3_n"	=>	"flash_cmd",
"fc15_ce4_n"	=>	"flash_cmd",
"fc15_ce5_n"	=>	"flash_cmd",
"fc15_ce6_n"	=>	"flash_cmd",
"fc15_ce7_n"	=>	"flash_cmd",
"fc15_cle_p"	=>	"flash_cmd",
"fc15_dbi_p"	=>	"flash_cmd",
"fc15_odt_n"	=>	"flash_cmd",
"fc15_re_nc"	=>	"flash_cmd",
"fc15_re_nt"	=>	"flash_cmd",
"fc15_we_n"	=>	"flash_cmd",
"fc00_dq0_p"	=>	"data",
"fc00_dq1_p"	=>	"data",
"fc00_dq2_p"	=>	"data",
"fc00_dq3_p"	=>	"data",
"fc00_dq4_p"	=>	"data",
"fc00_dq5_p"	=>	"data",
"fc00_dq6_p"	=>	"data",
"fc00_dq7_p"	=>	"data",
"fc00_dqs_pc"	=>	"data",
"fc00_dqs_pt"	=>	"data",
"fc01_dq0_p"	=>	"data",
"fc01_dq1_p"	=>	"data",
"fc01_dq2_p"	=>	"data",
"fc01_dq3_p"	=>	"data",
"fc01_dq4_p"	=>	"data",
"fc01_dq5_p"	=>	"data",
"fc01_dq6_p"	=>	"data",
"fc01_dq7_p"	=>	"data",
"fc01_dqs_pc"	=>	"data",
"fc01_dqs_pt"	=>	"data",
"fc02_dq0_p"	=>	"data",
"fc02_dq1_p"	=>	"data",
"fc02_dq2_p"	=>	"data",
"fc02_dq3_p"	=>	"data",
"fc02_dq4_p"	=>	"data",
"fc02_dq5_p"	=>	"data",
"fc02_dq6_p"	=>	"data",
"fc02_dq7_p"	=>	"data",
"fc02_dqs_pc"	=>	"data",
"fc02_dqs_pt"	=>	"data",
"fc03_dq0_p"	=>	"data",
"fc03_dq1_p"	=>	"data",
"fc03_dq2_p"	=>	"data",
"fc03_dq3_p"	=>	"data",
"fc03_dq4_p"	=>	"data",
"fc03_dq5_p"	=>	"data",
"fc03_dq6_p"	=>	"data",
"fc03_dq7_p"	=>	"data",
"fc03_dqs_pc"	=>	"data",
"fc03_dqs_pt"	=>	"data",
"fc04_dq0_p"	=>	"data",
"fc04_dq1_p"	=>	"data",
"fc04_dq2_p"	=>	"data",
"fc04_dq3_p"	=>	"data",
"fc04_dq4_p"	=>	"data",
"fc04_dq5_p"	=>	"data",
"fc04_dq6_p"	=>	"data",
"fc04_dq7_p"	=>	"data",
"fc04_dqs_pc"	=>	"data",
"fc04_dqs_pt"	=>	"data",
"fc05_dq0_p"	=>	"data",
"fc05_dq1_p"	=>	"data",
"fc05_dq2_p"	=>	"data",
"fc05_dq3_p"	=>	"data",
"fc05_dq4_p"	=>	"data",
"fc05_dq5_p"	=>	"data",
"fc05_dq6_p"	=>	"data",
"fc05_dq7_p"	=>	"data",
"fc05_dqs_pc"	=>	"data",
"fc05_dqs_pt"	=>	"data",
"fc06_dq0_p"	=>	"data",
"fc06_dq1_p"	=>	"data",
"fc06_dq2_p"	=>	"data",
"fc06_dq3_p"	=>	"data",
"fc06_dq4_p"	=>	"data",
"fc06_dq5_p"	=>	"data",
"fc06_dq6_p"	=>	"data",
"fc06_dq7_p"	=>	"data",
"fc06_dqs_pc"	=>	"data",
"fc06_dqs_pt"	=>	"data",
"fc07_dq0_p"	=>	"data",
"fc07_dq1_p"	=>	"data",
"fc07_dq2_p"	=>	"data",
"fc07_dq3_p"	=>	"data",
"fc07_dq4_p"	=>	"data",
"fc07_dq5_p"	=>	"data",
"fc07_dq6_p"	=>	"data",
"fc07_dq7_p"	=>	"data",
"fc07_dqs_pc"	=>	"data",
"fc07_dqs_pt"	=>	"data",
"fc08_dq0_p"	=>	"data",
"fc08_dq1_p"	=>	"data",
"fc08_dq2_p"	=>	"data",
"fc08_dq3_p"	=>	"data",
"fc08_dq4_p"	=>	"data",
"fc08_dq5_p"	=>	"data",
"fc08_dq6_p"	=>	"data",
"fc08_dq7_p"	=>	"data",
"fc08_dqs_pc"	=>	"data",
"fc08_dqs_pt"	=>	"data",
"fc09_dq0_p"	=>	"data",
"fc09_dq1_p"	=>	"data",
"fc09_dq2_p"	=>	"data",
"fc09_dq3_p"	=>	"data",
"fc09_dq4_p"	=>	"data",
"fc09_dq5_p"	=>	"data",
"fc09_dq6_p"	=>	"data",
"fc09_dq7_p"	=>	"data",
"fc09_dqs_pc"	=>	"data",
"fc09_dqs_pt"	=>	"data",
"fc10_dq0_p"	=>	"data",
"fc10_dq1_p"	=>	"data",
"fc10_dq2_p"	=>	"data",
"fc10_dq3_p"	=>	"data",
"fc10_dq4_p"	=>	"data",
"fc10_dq5_p"	=>	"data",
"fc10_dq6_p"	=>	"data",
"fc10_dq7_p"	=>	"data",
"fc10_dqs_pc"	=>	"data",
"fc10_dqs_pt"	=>	"data",
"fc11_dq0_p"	=>	"data",
"fc11_dq1_p"	=>	"data",
"fc11_dq2_p"	=>	"data",
"fc11_dq3_p"	=>	"data",
"fc11_dq4_p"	=>	"data",
"fc11_dq5_p"	=>	"data",
"fc11_dq6_p"	=>	"data",
"fc11_dq7_p"	=>	"data",
"fc11_dqs_pc"	=>	"data",
"fc11_dqs_pt"	=>	"data",
"fc12_dq0_p"	=>	"data",
"fc12_dq1_p"	=>	"data",
"fc12_dq2_p"	=>	"data",
"fc12_dq3_p"	=>	"data",
"fc12_dq4_p"	=>	"data",
"fc12_dq5_p"	=>	"data",
"fc12_dq6_p"	=>	"data",
"fc12_dq7_p"	=>	"data",
"fc12_dqs_pc"	=>	"data",
"fc12_dqs_pt"	=>	"data",
"fc13_dq0_p"	=>	"data",
"fc13_dq1_p"	=>	"data",
"fc13_dq2_p"	=>	"data",
"fc13_dq3_p"	=>	"data",
"fc13_dq4_p"	=>	"data",
"fc13_dq5_p"	=>	"data",
"fc13_dq6_p"	=>	"data",
"fc13_dq7_p"	=>	"data",
"fc13_dqs_pc"	=>	"data",
"fc13_dqs_pt"	=>	"data",
"fc14_dq0_p"	=>	"data",
"fc14_dq1_p"	=>	"data",
"fc14_dq2_p"	=>	"data",
"fc14_dq3_p"	=>	"data",
"fc14_dq4_p"	=>	"data",
"fc14_dq5_p"	=>	"data",
"fc14_dq6_p"	=>	"data",
"fc14_dq7_p"	=>	"data",
"fc14_dqs_pc"	=>	"data",
"fc14_dqs_pt"	=>	"data",
"fc15_dq0_p"	=>	"data",
"fc15_dq1_p"	=>	"data",
"fc15_dq2_p"	=>	"data",
"fc15_dq3_p"	=>	"data",
"fc15_dq4_p"	=>	"data",
"fc15_dq5_p"	=>	"data",
"fc15_dq6_p"	=>	"data",
"fc15_dq7_p"	=>	"data",
"fc15_dqs_pc"	=>	"data",
"fc15_dqs_pt"	=>	"data"

);


# power supply settings
%typ_supply = (
	"vdd_0v8"		=> 0.82,
	"avd_0v8_pcie"	 	=> 0.82,
	"avd_0v8_pcieq"	 	=> 0.82,
	"avd_0v8_dcsu"		=> 0.82,
	"avd_0v9_pcie"	 	=> 0.95,
	"avd_0v9_pcieq"	 	=> 0.95,
	"vddo_nand"		=> 1.20,
	"vddo_ddr"		=> 1.20,
	"vdd_i3c_0"		=> 1.80,
	"vdd_i3c_1"		=> 1.80,	
	"vddo_1v8"		=> 1.80,
	"vref_nand"		=> 0.60

);

%max_supply = (
	"vdd_0v8"		=> 0.8405,
	"avd_0v8_pcie"	 	=> 0.8405,
	"avd_0v8_pcieq"	 	=> 0.8405,
	"avd_0v8_dcsu"		=> 0.8405,
	"avd_0v9_pcie"	 	=> 0.9737,
	"avd_0v9_pcieq"	 	=> 0.9737,
	"vddo_nand"		=> 1.26,
	"vddo_ddr"		=> 1.25,
	"vdd_i3c_0"		=> 1.89,
	"vdd_i3c_1"		=> 1.89,	
	"vddo_1v8"		=> 1.89,
	"vref_nand"		=> 0.624
);

%pwr_loads = (
	"vdd_0v8"		=> 12,
	"avd_0v8_pcie"	 	=> 3,
	"avd_0v8_pcieq"	 	=> 3,
	"avd_0v8_dcsu"		=> 1,
	"avd_0v9_pcie"	 	=> 2,
	"avd_0v9_pcieq"	 	=> 1,	
	"vddo_nand"		=> 4,
	"vddo_ddr"		=> 2,
	"vdd_i3c_0"		=> 1,
	"vdd_i3c_1"		=> 1,
	"vddo_1v8"		=> 1,
	"vref_nand"		=> 1
);

%pwr_seq = (
	"vdd_0v8"		=> 20,
	"avd_0v8_pcie"	 	=> 20,
	"avd_0v8_pcieq"	 	=> 20,
	"avd_0v8_dcsu"		=> 20,
	"avd_0v9_pcie"	 	=> 20,
	"avd_0v9_pcieq"	 	=> 20,	
	"vddo_nand"		=> 10,
	"vddo_ddr"		=> 10,
	"vdd_i3c_0"		=> 15,
	"vdd_i3c_1"		=> 15,
	"vddo_1v8"		=> 15,	
	"vref_nand"		=> 5
);

@supply_name_array = ("vdd_0v8", "avd_0v8_pcie", "avd_0v8_pcieq", "avd_0v9_pcie", "avd_0v9_pcieq", "avd_0v8_dcsu", "vddo_nand", "vddo_ddr", "vdd_i3c_0", "vdd_i3c_1", "vddo_1v8", "vref_nand");

$PATH = "/proj/me_proj/cyshang/yorktown/flash_io_char/";

########################################################


sub erct_get_result	{ 
	my $erct_get_val;
	my $error_count_string="";
	my @erct_array=();
	$error_count_string = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
	# print "error_count_string = $error_count_string\n";

	@erct_array=split ",",$error_count_string;

	$erct_get_val=$erct_array[2];
	if ($erct_get_val == 0)	{$erct_get_val = "P";} else {print "\tERCT=$erct_get_val"; $erct_get_val = "F";}
	
	return $erct_get_val;

}

sub vilh_sweep_linear {

	my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# define current_vdd that will be used to start the linear search
    $current_put_mv = $limit_1 ;     #initial vil/vih value		


  if ($vil eq "tst") {	     # input low being tested	
  

		     `hpti 'FTST?'`;

		$pf_flag_coarse =0;
		$pf_flag_fine = 0;
	
	    while (($current_put_mv <= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv + 30 ; }#30mv per step for coarse search
		    if (($pf_flag_coarse == 1)) {$current_put_mv = $current_put_mv + 5 ;} #5mv per step for fine search
			
			if ($pf_flag_coarse ==0) {
				print "coarse: input low being tested! DRLV $vilh_lvl,$current_put_mv,$vih,($put)\t";
			}
			else {
				print "fine: input low being tested! DRLV $vilh_lvl,$current_put_mv,$vih,($put)\t";
			}
			`hpti 'DRLV $vilh_lvl,$current_put_mv,$vih,($put)'`;	
			
			#`hpti 'SQSL "$vilh_pattern"'`;
			`hpti 'WAIT 10'`;		
	        #`hpti 'FTSM SET,4547,,'`;
		    $ret_val = `hpti 'FTST?'`;
			# print "ret_val=$ret_val\n";
			
		    @retval_array = split " ",$ret_val;
			if ($retval_array[1] eq "F") {
			    $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		        print "errorcount: $ec_val\n ";

				@ec_array=();
	            @ec_array = split ",",$ec_val;
				# if ($ec_array[2] ==0) { print "\tPASS!\n";	}				
		        # print ("errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4]");
                # print ("current VIL = $current_put_mv mV\n");
				# if ($ec_array[2] eq "0") {print "PASS.................\n"; }
                if ($ec_array[2] > 0) {
					
					print "\tFAIL! error_count=$ec_array[2]"; 
					$ec=`hpti 'ERCY? CYC,0,,2,(jtag_tdo_p)'`;
					print "ecec= $ec\n";
					
					if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; $exit_count++; print "\n exit_count=$exit_count\n"; if ($exit_count>=0) {exit;}  } # stop fine search
					if($pf_flag_coarse == 0){$pf_flag_coarse = 1 ; $current_put_mv = $current_put_mv - 30 ;} # start fine search

				}
				#if ($ec_array[2] > 20 ) {$pf_flag = 1;}

				
                
			}	
			 #print ("current VIL = $current_put_mv mV\n");
			 
		}
	}
    else {            			# input high being tested

	         `hpti 'FTST?'`;
	print "\n\ngo to non-tst\n\n";	


	    while (($current_put_mv >= $limit_2) && ($pf_flag == 0)) {
		     $current_put_mv = $current_put_mv - 30 ; #30mv per step 
			print "input high being tested! DRLV $vilh_lvl,$vil,$current_put_mv,($put)";
			`hpti 'DRLV $vilh_lvl,$vil,$current_put_mv,($put)'`;			 



		     $ret_val = `hpti 'FTST?'`;
			 print "FTST = $ret_val\n";
		     @retval_array = split " ",$ret_val;
             if ($retval_array[1] eq "F") {
			    $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		        # print "errorcount: $ec_val\n ";
				@ec_array=();
	            @ec_array = split ",",$ec_val;
		        # print ("errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4]");
                # print ("current VIH = $current_put_mv mV\n");
                # if ($ec_array[2] eq "0") {$pf_flag = 1;}
                if ($ec_array[2] ne "0") {$pf_flag = 1;}
				#if ($ec_array[2] > 20 ) {$pf_flag = 1;}
			
			 }	
				 
		     #print ("current VIH = $current_put_mv mV\n");
		
		}
	}		

	return $current_put_mv;

}

sub vilh_sweep_binary {

	my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# initialize pass/fail boundary flag
	$pf_bnd_fnd = 0;
	# define current_vdd that will be used to start the binary search
	$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
	# define limit (mV) to exit the binary search
	$max_spread = 1;
	
	
	while ($pf_bnd_fnd == 0) {
		$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
		# set pin under test to new V
		if ($vil eq "tst") {
			# input low being tested
			print "input low being tested! DRLV $vilh_lvl,$current_put_mv,$vih,($put)";
			`hpti 'DRLV $vilh_lvl,$current_put_mv,$vih,($put)'`;	
		}
		else {
			# input high being tested
			print "input high being tested! DRLV $vilh_lvl,$vil,$current_put_mv,($put)";
			`hpti 'DRLV $vilh_lvl,$vil,$current_put_mv,($put)'`;
		}
		
		$ret_val = `hpti 'FTST?'`;
		@retval_array=();
		@retval_array = split " ",$ret_val;

		#print ("test reported $retval_array[1] @ vdd=$current_put_mv for $put; current test limits = $limit_1 mV and $limit_2 mV with Spread $spread mV\n");

		$retval_array[1]=&erct_get_result;
		print "\t\tresult = $retval_array[1]\n";

		if ($retval_array[1] eq "F") {
			$limit_1 = $current_put_mv;
		}
		else {
			$limit_2 = $current_put_mv;
		}
		
		# ensure spread is always a positive number
		$spread = $limit_2 - $limit_1;
		if ($spread < 0) {
			$spread = -1 * $spread;
		}
		
		if ($spread <= $max_spread) {
			$pf_bnd_fnd = 1;
			#print ("final spread = $spread V\n");
		}
	}
	
	# return the last drive level tested that resulted in a Pass
	return $limit_2;
	
}

sub pin_forceV_measI {
#&pin_forceV_measI($put,$vref,-40000,40000,"IRD")
    my($pin,$force_v,$lo_limit,$hi_limit,$curr_range) = @_;
	
	$force_mv = $force_v*1000;
	print "pin= $pin $force_mv mv $lo_limit $hi_limit $curr_range\n";
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($pin)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$curr_range,($pin)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$force_mv,($pin)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,$lo_limit,($pin)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,$hi_limit,($pin)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($pin)'`; 

	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($pin)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($pin)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
#	`hpti 'MSET 1,DC,3,MUX_PPMU_BADC,0,I,($pin)'`;


	`hpti 'MSET 1,DC,3,PMUM,0,I,($pin)'`;
	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,5,($pin)'`;

	$ret_val_string="";
	$ret_val_string = `hpti 'PMUR? VAL,($pin)'`;
    print "ret_val_string=$ret_val_string\n";
	return $ret_val_string;
	exit;
}


sub pin_forceI_measV {
#       &pin_forceI_measV($put,0,0,$supply_mv);
	my($pin, $force_i, $lo_limit, $hi_limit,$curr_range) = @_;
	
	$force_uA = $force_i*1000;
	
#	`hpti 'DFVM 1,$force_uA,$force_uA,,$pass_min,$pass_max,,I,5,PPNP,($pin); MEAS 1,1;MEAS 1,2;MEAS 1,3;MEAS 1,4; RLYC PPMU,PMU,($pin); WAIT 1000'`;
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,VOLT,($pin)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$curr_range,($pin)'`;
	`hpti 'MSET 1,DC,1,IFOR,2,$force_uA,($pin)'`;		

	`hpti 'MSET 1,DC,1,PMUL,3,$lo_limit,($pin)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,$hi_limit,($pin)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($pin)'`; 

	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($pin)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($pin)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,L,($pin)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,5,($pin)'`;


	$ret_val_1 = `hpti 'PMUR? VAL,($pin)'`;
	
	@ret_array_1 = split ",", $ret_val_1;
	$meas_v = abs($ret_array_1[1]);
#	print "(FIMV) When $pin is forced to $force_uA uA, for $pin  $meas_v mV is measured.\n";

	return $meas_v;

}

sub vilh {

	my($vdd_flash,$put,$init_vil_mv,$init_vih_mv) = @_;
	
	$vdd_flash_mv = $vdd_flash * 1000;
	
	$lo_limit = ($vdd_flash_mv*0.5) - 200;
	$hi_limit = ($vdd_flash_mv*0.5) + 200;

	#print "VILH test started with bounds = $lo_limit mV to $hi_limit mV\n";
	
	$vil_val = &vilh_sweep_binary($put,$hi_limit,$lo_limit,"tst",$init_vih_mv);
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	$vih_val = &vilh_sweep_binary($put,$lo_limit,$hi_limit,$init_vil_mv,"tst");
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	
	print "VIL value for $put = $vil_val mV, VIH value for $put = $vih_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_bsdl,$vdd_flash_level,");
	print fh_vilh ("$put,$lo_limit,$hi_limit,$vil_val,$vih_val\n");
	
}

sub vil {

	my($vdd_flash,$put,$init_vil_mv,$init_vih_mv) = @_;
	
	$vdd_flash_mv = $vdd_flash * 1000;
	$lo_limit = ($vdd_flash_mv*0.5) - 200;
	$hi_limit = ($vdd_flash_mv*0.5) + 200;
# print "lo_limit = $lo_limit, hi_limit = $hi_limit\n";
	#print "VILH test started with bounds = $lo_limit mV to $hi_limit mV\n";
	
	$vil_val = &vilh_sweep_linear($put,$lo_limit,$hi_limit,"tst",$init_vih_mv);
	print "VIL value for $put = $vil_val mV\n"; 
	# $vil_val = &vilh_sweep_binary($put,$hi_limit,$lo_limit,"tst",$init_vih_mv);
	
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	

	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_vil,$vdd_flash_mv,$vref_mv,");
	print fh_vilh ("$put,$lo_limit,$hi_limit,$vil_val,NA\n");
	
}

sub vildx {

	my($vdd_flash,$put,$init_vil_mv,$init_vih_mv) = @_;
	
	$vdd_flash_mv = $vdd_flash * 1000;
	
	$lo_limit = ($vdd_flash_mv*$vref_percentage) - 250;
	$hi_limit = ($vdd_flash_mv*$vref_percentage) + 250;
	
	#print "VILH test started with bounds = $lo_limit mV to $hi_limit mV\n";
	
	$vil_val = &vilh_sweep_linear($put,$lo_limit,$hi_limit,"tst",$init_vih_mv);
	# $vil_val = &vilh_sweep_binary($put,$hi_limit,$lo_limit,"tst",$init_vih_mv);
	
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	
	print "VIL value for $put = $vil_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_vil,$vdd_flash_mv,$vref_mv,");
	print fh_vilh ("$put,$lo_limit,$hi_limit,$vil_val,NA\n");
	
}

sub vih {

	my($vdd_flash,$put,$init_vil_mv,$init_vih_mv) = @_;
	
	$vdd_flash_mv = $vdd_flash * 1000;
	
	$lo_limit = ($vdd_flash_mv*0.5) - 200;
	$hi_limit = ($vdd_flash_mv*0.5) + 200;

	#print "VILH test started with bounds = $lo_limit mV to $hi_limit mV\n";
	
	$vih_val = &vilh_sweep_binary($put,$lo_limit,$hi_limit,$init_vil_mv,"tst");
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	
	print "VIH value for $put = $vih_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_vih,$vdd_flash_mv,$vref_mv,");
	print fh_vilh ("$put,$lo_limit,$hi_limit,NA,$vih_val\n");
	
}

sub vihdx {

	my($vdd_flash,$put,$init_vil_mv,$init_vih_mv) = @_;
	
	$vdd_flash_mv = $vdd_flash * 1000;
	
	$lo_limit = ($vdd_flash_mv*$vref_percentage) - 250;
	$hi_limit = ($vdd_flash_mv*$vref_percentage) + 250;

	#print "VILH test started with bounds = $lo_limit mV to $hi_limit mV\n";
	
	$vih_val = &vilh_sweep_binary($put,$lo_limit,$hi_limit,$init_vil_mv,"tst");
	`hpti 'DRLV $vilh_lvl,$init_vil_mv,$init_vih_mv,($put)'`;
	
	print "VIH value for $put = $vih_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_vih,$vdd_flash_mv,$vref_mv,");
	print fh_vilh ("$put,$lo_limit,$hi_limit,NA,$vih_val\n");
	
}

sub io_leak {
	my($leak_pattern) = @_;
	$leak_testmode=1;
	$leak_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";
#	print "wfs=$bsdl_wfs,tim=$bsdl_tim,lvl=$bsdl_lvl,dps=$bsdl_dps\n";
	`hpti '$leak_dataset'`;
	print "change pattern $leak_pattern\n";
	`hpti 'SQSL "$leak_pattern"'`;
	
	# initialize supply to test conditions for leakage
	foreach $supply_name (@supply_name_array) {
#		print "PSLV $bsdl_dps,$max_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n";
		`hpti 'PSLV $bsdl_dps,$max_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
	}
	
	`hpti 'FTST?'`;
	
	# # calibrate flash IO test supply voltage based on sense ball
	# no flash sense pin/ball in yorktown
	# $vdd_flash_force = `../voltage_force_93k.prl vdd_flash_ball vddo_ddr $bsdl_dps $max_supply{vddo_ddr}`;
	# $vdd_flash_level = `../voltage_sense_93k.prl vdd_flash_ball vddo_ddr`;
	# chomp($vdd_flash_force);
	# chomp($vdd_flash_level);
	# print "VDD flash IO level set to $vdd_flash_level mV after force = ($vdd_flash_force mV)...\n";

	# set flash_ato appropriately
	$vref_mv = ($max_supply{vddo_ddr}*1000) * 0.5;
#	print "DRLV $bsdl_lvl,$vref_mv,$vref_mv,(flash_ato)\n";
	`hpti 'DRLV $bsdl_lvl,$vref_mv,$vref_mv,(flash_ato)'`;
	

		$flash_leak_put_pins=join( ",", @flash_put );
		$force_leak_hi = 1.200;
		$force_leak_lo = 0;
		# connect pin back to tester channel and disconnect any PMU
		`hpti 'RLYC AC,OFF,(@)'`;
		`hpti 'WAIT 5000'`;
		
		$ret_val="";
		$ret_val = &pin_forceV_measI($flash_leak_put_pins,$force_leak_hi,-100,100,"IRB");
		&leak_return_val_datalog($ret_val,$force_leak_hi,$leak_pattern);
		$ret_val="";
		$ret_val = &pin_forceV_measI($flash_leak_put_pins,$force_leak_lo,-100,100,"IRB");
		&leak_return_val_datalog($ret_val,$force_leak_lo,$leak_pattern);		

	
	$leak_testmode=0;
}

sub io_leak_pvt {
	my($leak_pattern,$current_flash_sply) = @_;
	$leak_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";
#	print "wfs=$bsdl_wfs,tim=$bsdl_tim,lvl=$bsdl_lvl,dps=$bsdl_dps\n";
	`hpti '$leak_dataset'`;
	print "change pattern $leak_pattern\n";
	`hpti 'SQSL "$leak_pattern"'`;
	
	# initialize supply to test conditions for leakage
	foreach $supply_name (@supply_name_array) {

		if ($supply_name eq "vddo_ddr"){
			`hpti 'PSLV $bsdl_dps,$current_flash_sply,$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
			print "PSLV $bsdl_dps,$current_flash_sply,$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n";
		}
		else{
			`hpti 'PSLV $bsdl_dps,$max_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
			# print "PSLV $bsdl_dps,$max_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n";
		}
	}

	`hpti 'FTST?'`;
	
	# # calibrate flash IO test supply voltage based on sense ball
	# no flash sense pin/ball in yorktown
	# $vdd_flash_force = `../voltage_force_93k.prl vdd_flash_ball vddo_ddr $bsdl_dps $max_supply{vddo_ddr}`;
	# $vdd_flash_level = `../voltage_sense_93k.prl vdd_flash_ball vddo_ddr`;
	# chomp($vdd_flash_force);
	# chomp($vdd_flash_level);
	# print "VDD flash IO level set to $vdd_flash_level mV after force = ($vdd_flash_force mV)...\n";

	# set flash_ato appropriately
	$vref_mv = ($current_flash_sply*1000) * 0.5;
#	print "DRLV $bsdl_lvl,$vref_mv,$vref_mv,(flash_ato)\n";
	`hpti 'DRLV $bsdl_lvl,$vref_mv,$vref_mv,(flash_ato)'`;
	

		$flash_leak_put_pins=join( ",", @flash_put );
		$force_leak_hi = $current_flash_sply;
		$force_leak_lo = 0;
		# print "force_leak_hi=$force_leak_hi\n";
		
		# connect pin back to tester channel and disconnect any PMU
		`hpti 'RLYC AC,OFF,(@)'`;
		`hpti 'WAIT 5000'`;
		
		$ret_val="";
		$ret_val = &pin_forceV_measI($flash_leak_put_pins,$force_leak_hi,-100,100,"IRB");
		&leak_return_val_datalog($ret_val,$force_leak_hi,$leak_pattern);
		$ret_val="";
		$ret_val = &pin_forceV_measI($flash_leak_put_pins,$force_leak_lo,-100,100,"IRB");
		&leak_return_val_datalog($ret_val,$force_leak_lo,$leak_pattern);		

}





sub leak_return_val_datalog{
my($ret_val_string,$force_leak_V,$leak_pattern) = @_;
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) {
		if ($line_string ne "") {
#			print "line_string=$line_string\n";
			@temp_array=();
			@temp_array=split (/\,\,/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\,\(/,$temp_array[1]);
			$measure_value_string="";
			$measure_value_string=$temp_array2[0];
			$measure_value[$i]=$measure_value_string;
#			print "measure_value=$measure_value[$i]\n";
			@temp_array=();
			@temp_array=split (/\(/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\)/,$temp_array[1]);
			$pin_name_string="";
			$pin_name_string=$temp_array2[0];			
			if ($pin_name_string =~/,/)
			{	@temp_array=();
				@temp_array=split (/\,/,$pin_name_string);
				foreach $put (@temp_array) {
					$leak_current=$measure_value_string;
					print "$put forced to $force_leak_V V -> $leak_current uA\n";
					print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,");
					print fh_leak ("$leak_pattern,$vdd_flash_force,$vdd_flash_level,$vref_mv,");
					print fh_leak ("$put,$force_leak_V,$leak_current\n");			
				
				}
			}
			else
			{			
				$put=$pin_name_string;
				$leak_current=$measure_value_string;
				print "$put forced to $force_leak_V V -> $leak_current uA\n";
				print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,");
				print fh_leak ("$leak_pattern,$vdd_flash_force,$vdd_flash_level,$vref_mv,");
				print fh_leak ("$put,$force_leak_V,$leak_current\n");
			}
		}

	}	
}


sub pvt_comp_odt {
	my($flash_mode,$test_seq,$supply_mv,$vref_mv) = @_;
	$flash_supply_name = "vddo_ddr";

	$supply_v = $supply_mv/1000;
	$vref = $vref_mv/1000;
	print "supply_mv=$supply_mv mv  vref_mv=$vref_mv  mv\n";
	`hpti 'PSLV $atp_dps,$supply_v,$pwr_loads{$flash_supply_name},LOZ,$pwr_seq{$flash_supply_name},($flash_supply_name)'`;
#	print "PSLV $atp_dps,$supply_v,$pwr_loads{$flash_supply_name},LOZ,$pwr_seq{$flash_supply_name},($flash_supply_name)\n";
	
	$current_test_vector = "${test_seq}";
	`hpti 'SQSL "$current_test_vector"'`;

	print "\n\nchange pattern to $current_test_vector\n";
	# initialize sequencer to acquire failure map
	`hpti 'SQGB ACQF,0'`;


	# no flash sense pin/ball in yorktown
	# $vdd_flash_level = `../voltage_force_93k.prl vdd_flash_ball vddo_ddr $atp_dps $supply_v`;
	# chomp($vdd_flash_level);
	
	#wait 5ms
	`hpti 'WAIT 5000'`;
	`hpti 'FTST?'`;
	
	#wait 5ms
	`hpti 'WAIT 5000'`;

#	chomp($psme = `hpti 'PSME? 1,val,($flash_supply_name)'`);
#	@psme_values = split(',', $psme);
#	$vdd_flash_level = $psme_values[1];
#	$idd_flash_level = $psme_values[2];
	$vdd_flash_level=$supply_v;
	$idd_flash_level="NA";
#	print "\nTesting ODT using vector $current_test_vector with flash IO VDD set to $vdd_flash_level V...\n";
	
	#@zdata_odt = &zdata($flash_mode,"odt");

	if ($flash_mode eq "flash") {

		$put=join( ",", @flash_put_odt );
		
		`hpti 'WAIT 5000'`;
		# measure pin level with no load
		#$vnoload_vm = &pin_forceI_measV($put,0,0,$supply_mv,"IRB"); #pin, force_i,lo_lim, hi_lim
		$vnoload_vm="NA";$delta_vm="NA";
		#print ("$put -> Unloaded Drive level is $vnoload_vm mV\n");
		#$delta_vm = (((2*$vnoload_vm)/$supply_mv)-1)*100;
		#print ("Delta Vm % is $delta_vm %\n");

		`hpti 'RLYC AC,OFF,(@)'`;
		`hpti 'WAIT 5000'`;
		#Calculation and Datalog Output 
		$ret_val= &pin_forceV_measI($put,$vref,-40000,40000,"IRD");

		&odt_return_val_datalog($ret_val,$supply_mv,$vref_mv);
	}
	else {
		die "Incorrect flash Mode...\n";
	}
}

sub odt_return_val_datalog{
	my($ret_val_string,$supply_mv,$vref_mv) = @_;
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) {
		if ($line_string ne "") {
#			print "line_string=$line_string\n";
			@temp_array=();
			@temp_array=split (/\,\,/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\,\(/,$temp_array[1]);
			$measure_value_string="";
			$measure_value_string=$temp_array2[0];
			$measure_value[$i]=$measure_value_string;
#			print "measure_value=$measure_value[$i]\n";
			@temp_array=();
			@temp_array=split (/\(/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\)/,$temp_array[1]);
			$pin_name_string="";
			$pin_name_string=$temp_array2[0];			
			if ($pin_name_string =~/,/)
			{	@temp_array=();
				@temp_array=split (/\,/,$pin_name_string);
				foreach $put (@temp_array) {
					$ipad_odt=$measure_value_string;
					$ipad_odt_ma = abs($ipad_odt/1000);	
					if ($ipad_odt_ma != 0)	{$Rodt = ($supply_mv - $vref_mv)/($ipad_odt_ma);} else { $Rodt="NA";}	
					$pin_class = $flash_pin_class{$put};					
					print "\t$put Vnoload = $vnoload_vm mV; Force $vref_mv mV results in $ipad_odt_ma mA;  Measured Rodt is $Rodt ohms\n";	
					print fh_odt ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$flash_test_vectors,$current_odt_dx,$current_vref_mv,$current_flash_sply_mv,");
					print fh_odt ("$current_test_vector,$vdd_flash_level,$idd_flash_level,$vref_mv,$put,$pin_class,$vnoload_vm,$delta_vm,$ipad_odt_ma,$Rodt\n");				
				}
			}
			else
			{			
				$put=$pin_name_string;
				$ipad_odt=$measure_value_string;
				$ipad_odt_ma = abs($ipad_odt/1000);	
				if ($ipad_odt_ma != 0)	{$Rodt = ($supply_mv - $vref_mv)/($ipad_odt_ma);} else { $Rodt="NA";}	
				$pin_class = $flash_pin_class{$put};
				print "\t$put Vnoload = $vnoload_vm mV; Force $vref_mv mV results in $ipad_odt_ma mA;  Measured Rodt is $Rodt ohms\n";	
				print fh_odt ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$flash_test_vectors,$current_odt_dx,$current_vref_mv,$current_flash_sply_mv,");
				print fh_odt ("$current_test_vector,$vdd_flash_level,$idd_flash_level,$vref_mv,$put,$pin_class,$vnoload_vm,$delta_vm,$ipad_odt_ma,$Rodt\n");				
			}
		}

	}	
}





sub pvt_comp_drvpupd_od {
#pvt_comp_drvpu_od($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv);
	my($flash_mode,$test_seq,$supply_mv,$vref_mv,$pupd) = @_;
	$current_test_vector = "${test_seq}";
	print "change pattern to $current_test_vector\n";

	
	
	$flash_supply_name = "vddo_nand";
	$flash_vref_name = "vref_nand";
	$supply_v = $supply_mv/1000;
	$vref = $vref_mv/1000;
	$force_pad_v=0;
	if ($current_test_vector =~/ltt/) {					$force_pad_v = $supply_v * $flash_vref_ratio{"flash_ltt"};	}
	if ($current_test_vector =~/ctt/) {					$force_pad_v = $supply_v * $flash_vref_ratio{"flash_ctt"};	}
	

	`hpti 'PSLV $atp_dps,$supply_v,$pwr_loads{$flash_supply_name},LOZ,$pwr_seq{$flash_supply_name},($flash_supply_name)'`;
	`hpti 'PSLV $atp_dps,$vref,$pwr_loads{$flash_vref_name},LOZ,$pwr_seq{$flash_vref_name},($flash_vref_name)'`;
	
	print "PSLV $atp_dps,$supply_v,$pwr_loads{$flash_supply_name},LOZ,$pwr_seq{$flash_supply_name},($flash_supply_name)\n";
	print "PSLV $atp_dps,$vref,$pwr_loads{$flash_vref_name},LOZ,$pwr_seq{$flash_vref_name},($flash_vref_name)\n";

	`hpti 'SQSL "$current_test_vector"'`;
	# initialize sequencer to acquire failure map
	`hpti 'SQGB ACQF,0'`;
	
	#wait 5ms
	`hpti 'WAIT 5000'`;
	`hpti 'FTST?'`;

	#wait 5ms
	`hpti 'WAIT 5000'`;

	$vdd_flash_level=$supply_v;
	$idd_flash_level="NA";
	# print "DRLV? $atp_lvl,(flash_ato)\n";
	# chomp($drlv_vref = `hpti 'DRLV? $atp_lvl,(flash_ato)'`);
	# @drlv_values = split(',', $drlv_vref);
	# $vref_flash_level = $drlv_values[1];
	
	# if ($pupd eq "PU")
	# {	print "\nTesting OD PU using vector $current_test_vector with flash IO VDD set to $vdd_flash_level V...\n";	}
	# elsif ($pupd eq "PD")
	# {	print "\nTesting OD PD using vector $current_test_vector with flash IO VDD set to $vdd_flash_level V...\n";}
	
	$flash_put_ca="";
	$flash_put_dx1="";
	$flash_put_dx2="";
	foreach $put (@flash_put) {
		$pin_class = $flash_pin_class{$put};

		
		# print "$put  pin_class = $pin_class  current_put_type=$current_put_type\n";
		if (($flash_pin_class{$put} eq "flash_cmd") && ($current_put_type eq "ca")) {
			if ($flash_put_ca ne "")
			{	$flash_put_ca=$flash_put_ca . "," . $put;	}
			else
			{	$flash_put_ca=$put;}
		}
		elsif (($flash_pin_class{$put} eq "data") && ($current_put_type eq "dx")) {
			print "enter data and dx area\n";
			if ($put =~/_dqs_/)
			{
				if ($flash_put_dx2 ne "")
				{	
					$flash_put_dx2=$flash_put_dx2 . "," . $put;
				}
				else
				{	$flash_put_dx2=$put;}
			}
			else{
				if ($flash_put_dx1 ne "")
				{	
					$flash_put_dx1=$flash_put_dx1 . "," . $put;
				}
				else
				{	$flash_put_dx1=$put;}				
			}
			# print "flash_put_dx1=$flash_put_dx1  flash_put_dx2=$flash_put_dx2\n";
		}
		else {
			#print "pin under test: $put, mode: $current_put_type\n";
			#die "flash mode - can not determine class of pin.\n";
		}
	}
		# print "current_test_vector=uc($current_test_vector)\n";

		$vnoload_hilo="NA";
		if ( $current_put_type eq "dx")
		{
			print "get DX!\n";
			#*************  dxpin need to split to two groups and "hpti 'RLYC AC,OFF,(@)", otherwise the measured values will be incorrected **************
			`hpti 'RLYC AC,OFF,(@)'`;
			`hpti 'WAIT 5000'`;	
			$pin_class="data";	
			$ret_val="";
			$ret_val = &pin_forceV_measI($flash_put_dx1,$force_pad_v,-40000,40000,"IRD");
			&od_return_val_datalog($ret_val,$supply_mv,$force_pad_v*1000);
		
			# print "change pattern to $current_test_vector\n";
			# `hpti 'SQSL "$current_test_vector"'`;
			# # initialize sequencer to acquire failure map
			# `hpti 'SQGB ACQF,0'`;
			# #wait 5ms
			# `hpti 'WAIT 5000'`;
			# `hpti 'FTST?'`;
			# #wait 5ms
			# `hpti 'WAIT 5000'`;		
			# `hpti 'RLYC AC,OFF,(@)'`;
			# `hpti 'WAIT 5000'`;	
			if ($flash_put_dx2 ne ""){

				$ret_val="";
				$ret_val = &pin_forceV_measI($flash_put_dx2,$force_pad_v,-40000,40000,"IRD");
				&od_return_val_datalog($ret_val,$supply_mv,$force_pad_v*1000);
			}
		}
		if ( $current_put_type eq "ca")
		{
		`hpti 'RLYC AC,OFF,(@)'`;
		`hpti 'WAIT 5000'`;
			print "get CA!\n";
			$pin_class="addr_cmd";
			$ret_val="";
			$ret_val = &pin_forceV_measI($flash_put_ca,$force_pad_v,-40000,40000,"IRD");
			&od_return_val_datalog($ret_val,$supply_mv,$force_pad_v*1000);

		}	

	
}

sub od_return_val_datalog{
	my($ret_val_string,$supply_mv,$force_pad_mv) = @_;
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) {
		if ($line_string ne "") {
#			print "line_string=$line_string\n";
			@temp_array=();
			@temp_array=split (/\,\,/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\,\(/,$temp_array[1]);
			$measure_value_string="";
			$measure_value_string=$temp_array2[0];
			$measure_value[$i]=$measure_value_string;
#			print "measure_value=$measure_value[$i]\n";
			@temp_array=();
			@temp_array=split (/\(/,$line_string);
			@temp_array2=();
			@temp_array2=split (/\)/,$temp_array[1]);
			$pin_name_string="";
			$pin_name_string=$temp_array2[0];			
			if ($pin_name_string =~/,/)
			{	@temp_array=();
				@temp_array=split (/\,/,$pin_name_string);
				foreach $put (@temp_array) {
					$ipad_pupd=$measure_value_string;
					$ipad_pupd_ma = abs($ipad_pupd/1000);
					if ($ipad_pupd_ma != 0)	{$rocd_pupd = ($supply_mv - $force_pad_mv)/($ipad_pupd_ma);} else { $rocd_pupd="NA";}
					print "pin $put Vnoload = $vnoload_hilo mV; Force $force_pad_mv mV results in $ipad_pupd_ma mA and $rocd_pupd ohms\n";
					print fh_od ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$flash_test_vectors,$current_load_updn,NA,$current_vref_mv,$current_flash_sply_mv,");
					print fh_od ("$current_test_vector,$vdd_flash_level,$idd_flash_level,$force_pad_mv,$put,$pin_class,$vnoload_hilo,$ipad_pupd_ma,$rocd_pupd\n");
					print "temp=$temp\tcurrent_flash_sply_mv=$current_flash_sply_mv\tcurrent_test_vector=$current_test_vector\n";		
				}
			}
			else
			{			
				$put=$pin_name_string;
				$ipad_pupd=$measure_value_string;
				$ipad_pupd_ma = abs($ipad_pupd/1000);
				if ($ipad_pupd_ma != 0)	{$rocd_pupd = ($supply_mv - $force_pad_mv)/($ipad_pupd_ma);} else { $rocd_pupd="NA";}
				print "pin $put Vnoload = $vnoload_hilo mV; Force $force_pad_mv mV results in $ipad_pupd_ma mA and $rocd_pupd ohms\n";	
				print fh_od ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$flash_test_vectors,$current_load_updn,NA,$current_vref_mv,$current_flash_sply_mv,");
				print fh_od ("$current_test_vector,$vdd_flash_level,$idd_flash_level,$force_pad_mv,$put,$pin_class,$vnoload_hilo,$ipad_pupd_ma,$rocd_pupd\n");
				print "temp=$temp\tcurrent_flash_sply_mv=$current_flash_sply_mv\tcurrent_test_vector=$current_test_vector\n";		
			}
		}

	}	
}










sub zdata {
	my($flash_mode,$test_param) = @_;
	
	@zdata_val = (0,0,0,0);
	
	if ($test_param eq "od") {
		$start_vector = ($flash_od_offset{$flash_mode})-8;
	}
	elsif ($test_param eq "odt") {
		$start_vector = ($flash_odt_offset{$flash_mode})-8;
	}
	else {
		print "No zdata values to be collected.\n";
		@zdata_val = ("NA","NA","NA","NA");
		return @zdata_val;
	}
	$max_error_cycles = 1000;
	
	print "Collecting error cycle information for $test_param starting at cycle $start_vector...\n";
	$ret_val = `hpti 'ERCY? CYC,$start_vector,,$max_error_cycles,(jtag_tdo_p)'`;

	# parse out the return string from the ATE
	@ret_val_array = split "\n", $ret_val;

	# parse out the error cycles
	$count = 0;
	@err_cyc_array = ();
	foreach $current_ercy (@ret_val_array) {
		@ercy_array = split ",", $current_ercy;
		# print ("Error Cycle is =>  $ercy_array[1]\n");
		$err_cyc_array[$count] = $ercy_array[1];
		$count++
	}
	
	# normalize the error cycles so that any flash mode can be referenced
	if ($test_param eq "od") {
		$offset = $flash_od_offset{$flash_mode};
	}
	elsif ($test_param eq "odt") {
		$offset = $flash_odt_offset{$flash_mode};
	}
	else {
	}
	
	@err_cyc_offset_array = ();
	$count = 0;
	foreach $err_cyc_nooffset (@err_cyc_array) {
		$err_cyc_offset_array[$count] = $err_cyc_nooffset - $offset;
		$count++;
	}
	# print ("@err_cyc_offset_array\n");
	
	foreach $err_cyc_offset (@err_cyc_offset_array){
		
		if (($err_cyc_offset <= 450)) {
			$zdata_val[0] = $zdata_val[0] + $zq0dr_zdata{$err_cyc_offset};
		}
		if (($err_cyc_offset <= 4670)) {
			$zdata_val[1] = $zdata_val[1] + $zq1dr_zdata{$err_cyc_offset};
		}
		if (($err_cyc_offset <= 8890)) {
			$zdata_val[2] = $zdata_val[2] + $zq2dr_zdata{$err_cyc_offset};
		}
		if (($err_cyc_offset <= 13110)) {
			$zdata_val[3] = $zdata_val[3] + $zq3dr_zdata{$err_cyc_offset};
		}
	}
	
	print "zdata0 = $zdata_val[0], zdata1 = $zdata_val[1], zdata2 = $zdata_val[2], zdata3 = $zdata_val[3]\n";
	
	return @zdata_val;
	
}

sub calibrate_temp {
	
	my($cal_temp, $soak, $cal_location) = @_;
	print ("\n");
	print ("Setting temperature to $cal_temp C using a $si_therm silicon thermal...\n");
	chomp($cal_temp);
#	print "/proj/me_proj/cyshang/Yorktown/flash_io_char/silicon_thermal_v3_CY/set_si_temp.prl $cal_temp $soak $si_therm";
	`/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_v3_p0.prl $cal_temp $soak $si_therm`;
	chomp($case_temp);
	@temp_array=();
	@temp_array=split "Final measured temperature is: ",$case_temp;
	$case_temp=$temp_array[1];
	
	print ("Case temperature had set to $case_temp C...\n");
	
	if ($cal_location eq "case") {
		print ("Calibration location is set to Case -> Case temp = $case_temp C and Setpoint was $cal_temp C\n");
	}
#	elsif ($cal_location eq "junction") {
#		print ("Calibration location is set to Junction...Calibration is in progress...\n");
#		$temp_delta = 0;
#		$temp_delta = $cal_temp - $junction_temp;
#		print ("Current delta is: $temp_delta\n");
#		while (abs($temp_delta) > 1) {
#			$temp_adjust = $case_temp + $temp_delta;
#			print ("Temperature forcer needs to be adjusted to $temp_adjust C...\n");
#			$case_temp = `/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_v3_p0.prl $temp_adjust $soak $si_therm`;
#			print "\n case_temp = $case_temp\n";
#			chomp($case_temp);
#			print ("Case temperature set to $case_temp C...\n");
#			chdir($PATH);
#			$junction_temp = `../tdiode/pm8609_tdiode_93k.prl ext_meas b 10 0`;
#			chomp($junction_temp);
#			print ("Junction temperature is $junction_temp C...\n");
#			$temp_delta = $cal_temp - $junction_temp;
#			print ("Current delta is: $temp_delta\n");
#		}
#	}
	else {
		die "Incorrect calibration location selected -> (case/junction)\n";
	}
}

sub check_bsdl {
	$bsdl_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";

	`hpti '$bsdl_dataset'`;
	`hpti 'SQSL "$device_bsdl"'`;
	

	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	
	if ($bsdlval_array[1] eq "F") {
		# `disconnect`;
		# die "Boundary scan fails at initial conditions - check socketing.\n";
	}
	else {
		print "BSDL passes...\n";
	}
}

sub check_vih {
	$vih_dataset = "SPRM $vih_wfs,$vilh_tim,$vilh_lvl,$vilh_dps";

	`hpti '$vih_dataset'`;
	`hpti 'SQSL "$device_vih"'`;
	

	$vih_val = `hpti 'FTST?'`;
	@vih_array = split " ",$vih_val;
	
	$vih_array[1]=&erct_get_result;	
	if ($vih_array[1] eq "F") {
		# `disconnect`;
		# die "VIH vector fails at initial conditions - check socketing.\n";
		print "VIH vector fails..\n";
	}
	else {
		print "VIH vector passes...\n";
	}
}


sub check_vil {

	print "SPRM $vil_wfs,$vilh_tim,$vilh_lvl,$vilh_dps\n";
	$vil_dataset = "SPRM $vil_wfs,$vilh_tim,$vilh_lvl,$vilh_dps";

	`hpti '$vil_dataset'`;
	print "SQSL $device_vil\n";
	`hpti 'SQSL "$device_vil"'`;

	$vil_val = `hpti 'FTST?'`;
	@vil_array = split " ",$vil_val;

	$vil_array[1]=&erct_get_result;
	if ($vil_array[1] eq "F") {
		# `disconnect`;
		# die "VIL vector fails at initial conditions - check socketing.\n";
		print "VIL vector fails...\n";
	}
	else {
		print "VIL vector passes...\n";
	}
}

sub check_vih_dx {
	$vih_dataset = "SPRM $vih_wfs,$vilh_tim,$vilh_lvl,$vilh_dps";

	`hpti '$vih_dataset'`;
	`hpti 'SQSL "$device_vih_dx"'`;
	
	
	$vih_val = `hpti 'FTST?'`;
	@vih_array = split " ",$vih_val;
	
	
	
	$vih_array[1]=&erct_get_result;	
	if ($vih_array[1] eq "F") {
		# `disconnect`;
		# die "VIH vector fails at initial conditions - check socketing.\n";
	}
	else {
		print "VIH vector passes...\n";
	}
}

sub check_vil_dx {
	$vil_dataset = "SPRM $vil_wfs,$vilh_tim,$vilh_lvl,$vilh_dps";

	`hpti '$vil_dataset'`;
	`hpti 'SQSL "$device_vil_dx"'`;
	
	$vil_val = `hpti 'FTST?'`;
	@vil_array = split " ",$vil_val;
	
	$vil_array[1]=&erct_get_result;
	if ($vil_array[1] eq "F") {
		# `disconnect`;
		# die "VIL vector fails at initial conditions - check socketing.\n";
	}
	else {
		print "VIL vector passes...\n";
	}
}

sub check_functional {
	$func_dataset = "SPRM $func_wfs,$func_tim,$func_lvl,$func_dps";
	print $func_dataset."\n";
	`hpti '$func_dataset'`;
	print "SQSL $device_func\n";
	`hpti 'SQSL "$device_func"'`;

	`hpti 'SQGB ACQF,0'`;
	$func_val = `hpti 'FTST?'`;
	@funcval_array = split " ",$func_val;
	
	if ($device_func="pm8667_bsdl_reva_DC_DC"){$funcval_array[1]=&erct_get_result;}
	
	if ($funcval_array[1] eq "F") {
		# `disconnect`;
		# die "Funcational test fails at initial conditions.\n";
	}
	else {
		print "Funcational test passes...\n";
	}
}

########################################################
# Main Section of Code

$rep = 1;
$current_count = 0;
$extended = 0;

# $test_mode = $ARGV[0];
# if ($ARGV[1] eq "") {$flash_select="flash";}
# else {	$flash_select = $ARGV[1];	}
# $extended = $ARGV[2];

# ensure all data inputs are present when script is called
$test_mode or $flash_select or die "input format -> pm8667_Yorktown_flashio_char.pl <test_mode={typ/rep/pvt}> <flash=flash> <optional flag (0/1) - (comprehensive test=1)\n";

$date = `date`;
@date_array = split " ",$date;

# print "Enter Temperature Forcer Type: (WIN/ST/NO): \n";
# $si_therm = <STDIN>;
# chomp($si_therm);
# print "Enter Process Split: \n";
# $split = <STDIN>;
# chomp($split);
# print "Enter Device Serial Number: \n";
# $device = <STDIN>;
# chomp($device);

if (($test_mode eq "typ") || ($test_mode eq "rep")) {
	@flash_io_pwr_tst = (1.2);
	@flash_vilh_pwr_tst = (1.2);
	if ($test_mode eq "typ") {
		# @flash_put = (
			# "flash_dq[0]","flash_dq[1]","flash_dq[2]","flash_dq[3]","flash_dq[4]","flash_dq[5]","flash_dq[6]","flash_dq[7]","flash_dq[8]","flash_dq[9]",
			# "flash_dq[10]","flash_dq[11]","flash_dq[12]","flash_dq[13]","flash_dq[14]","flash_dq[15]","flash_dq[16]","flash_dq[17]","flash_dq[18]","flash_dq[19]",
			# "flash_dq[20]","flash_dq[21]","flash_dq[22]","flash_dq[23]","flash_dq[24]","flash_dq[25]","flash_dq[26]","flash_dq[27]","flash_dq[28]","flash_dq[29]",
			# "flash_dq[30]","flash_dq[31]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[36]","flash_dq[37]","flash_dq[38]","flash_dq[39]",
			# "flash_dq[40]","flash_dq[41]","flash_dq[42]","flash_dq[43]","flash_dq[44]","flash_dq[45]","flash_dq[46]","flash_dq[47]","flash_dq[48]","flash_dq[49]",
			# "flash_dq[50]","flash_dq[51]","flash_dq[52]","flash_dq[53]","flash_dq[54]","flash_dq[55]","flash_dq[56]","flash_dq[57]","flash_dq[58]","flash_dq[59]",
			# "flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[64]","flash_dq[65]","flash_dq[66]","flash_dq[67]","flash_dq[68]","flash_dq[69]",
			# "flash_dq[70]","flash_dq[71]","flash_dq[72]","flash_dq[73]","flash_dq[74]","flash_dq[75]","flash_dq[76]","flash_dq[77]","flash_dq[78]","flash_dq[79]",
			# "flash_dqs_c[0]","flash_dqs_c[1]","flash_dqs_c[2]","flash_dqs_c[3]","flash_dqs_c[4]","flash_dqs_c[5]","flash_dqs_c[6]","flash_dqs_c[7]","flash_dqs_c[8]",
			# "flash_dqs_c[9]","flash_dqs_c[10]","flash_dqs_c[11]","flash_dqs_c[12]","flash_dqs_c[13]","flash_dqs_c[14]","flash_dqs_c[15]","flash_dqs_c[16]","flash_dqs_c[17]","flash_dqs_c[18]","flash_dqs_c[19]",
			# "flash_dqs_t[0]","flash_dqs_t[1]","flash_dqs_t[2]","flash_dqs_t[3]","flash_dqs_t[4]","flash_dqs_t[5]","flash_dqs_t[6]","flash_dqs_t[7]","flash_dqs_t[8]",
			# "flash_dqs_t[9]","flash_dqs_t[10]","flash_dqs_t[11]","flash_dqs_t[12]","flash_dqs_t[13]","flash_dqs_t[14]","flash_dqs_t[15]","flash_dqs_t[16]","flash_dqs_t[17]","flash_dqs_t[18]","flash_dqs_t[19]",
			# "flash_a0_nc","flash_a1_ca12a","flash_a2_ca11a","flash_a3_ca10a","flash_a4_nc","flash_a5_ca9a","flash_a6_ca8a","flash_a7_ca6a","flash_a8_ca7a","flash_a9_ca3a","flash_a10_ca10b","flash_a11_ca5a","flash_a12_ca4a","flash_a13_ca12b","flash_a17_ca3b",
			# "flash_alert_n","flash_actn_ca2a","flash_ba0_ca11b","flash_ba1_ca13a","flash_bg0_ca0a","flash_bg1_ca1a","flash_casn_ca9b","flash_c0_ca6b","flash_c1_ca5b","flash_c2_ca4b","flash_cke0_cs0a","flash_cke1_cs1a","flash_cke2_cs2a","flash_cke3_cs3a",
			# "flash_cs0n_ca2b","flash_cs1n_ca1b","flash_cs2n_nc","flash_cs3n_ca0b","flash_odt0_cs0b","flash_odt1_cs1b","flash_odt2_cs2b","flash_odt3_cs3b","flash_par_ca13b",
			# "flash_wen_ca8b","flash_ck0_ck0a_0","flash_ck1_ck1a_0","flash_ck2_ck0b_0","flash_ck3_ck1b_0","flash_ck0_ck0a_1","flash_ck1_ck1a_1","flash_ck2_ck0b_1","flash_ck3_ck1b_1",
			# "flash_nc_ck2a_0","flash_nc_ck2a_1"	,"flash_nc_ck2b_0","flash_nc_ck2b_1","flash_nc_ck3a_0","flash_nc_ck3a_1","flash_nc_ck3b_0","flash_nc_ck3b_1"
			# );
		@flash_put = (
			"fc00_dq0_p","fc00_dq1_p","fc00_cle_p","fc00_dbi_p"
			);
		@flash_put_odt = (
			"flash_dq[0]","flash_dq[1]","flash_dq[2]","flash_dq[3]","flash_dq[4]","flash_dq[5]","flash_dq[6]","flash_dq[7]","flash_dq[8]","flash_dq[9]",
			"flash_dq[10]","flash_dq[11]","flash_dq[12]","flash_dq[13]","flash_dq[14]","flash_dq[15]","flash_dq[16]","flash_dq[17]","flash_dq[18]","flash_dq[19]",
			"flash_dq[20]","flash_dq[21]","flash_dq[22]","flash_dq[23]","flash_dq[24]","flash_dq[25]","flash_dq[26]","flash_dq[27]","flash_dq[28]","flash_dq[29]",
			"flash_dq[30]","flash_dq[31]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[36]","flash_dq[37]","flash_dq[38]","flash_dq[39]",
			"flash_dq[40]","flash_dq[41]","flash_dq[42]","flash_dq[43]","flash_dq[44]","flash_dq[45]","flash_dq[46]","flash_dq[47]","flash_dq[48]","flash_dq[49]",
			"flash_dq[50]","flash_dq[51]","flash_dq[52]","flash_dq[53]","flash_dq[54]","flash_dq[55]","flash_dq[56]","flash_dq[57]","flash_dq[58]","flash_dq[59]",
			"flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[64]","flash_dq[65]","flash_dq[66]","flash_dq[67]","flash_dq[68]","flash_dq[69]",
			"flash_dq[70]","flash_dq[71]","flash_dq[72]","flash_dq[73]","flash_dq[74]","flash_dq[75]","flash_dq[76]","flash_dq[77]","flash_dq[78]","flash_dq[79]",
			"flash_dqs_c[0]","flash_dqs_c[1]","flash_dqs_c[2]","flash_dqs_c[3]","flash_dqs_c[4]","flash_dqs_c[5]","flash_dqs_c[6]","flash_dqs_c[7]","flash_dqs_c[8]",
			"flash_dqs_c[9]","flash_dqs_c[10]","flash_dqs_c[11]","flash_dqs_c[12]","flash_dqs_c[13]","flash_dqs_c[14]","flash_dqs_c[15]","flash_dqs_c[16]","flash_dqs_c[17]","flash_dqs_c[18]","flash_dqs_c[19]",
			"flash_dqs_t[0]","flash_dqs_t[1]","flash_dqs_t[2]","flash_dqs_t[3]","flash_dqs_t[4]","flash_dqs_t[5]","flash_dqs_t[6]","flash_dqs_t[7]","flash_dqs_t[8]",
			"flash_dqs_t[9]","flash_dqs_t[10]","flash_dqs_t[11]","flash_dqs_t[12]","flash_dqs_t[13]","flash_dqs_t[14]","flash_dqs_t[15]","flash_dqs_t[16]","flash_dqs_t[17]","flash_dqs_t[18]","flash_dqs_t[19]"
			);
		@flash_in_ca_sngl_put = (
			"flash_a0_nc","flash_a1_ca12a","flash_a2_ca11a","flash_a3_ca10a","flash_a4_nc","flash_a5_ca9a","flash_a6_ca8a","flash_a7_ca6a","flash_a8_ca7a","flash_a9_ca3a","flash_a10_ca10b","flash_a11_ca5a","flash_a12_ca4a","flash_a13_ca12b","flash_a17_ca3b",
			"flash_alert_n","flash_actn_ca2a","flash_ba0_ca11b","flash_ba1_ca13a","flash_bg0_ca0a","flash_bg1_ca1a","flash_casn_ca9b","flash_c0_ca6b","flash_c1_ca5b","flash_c2_ca4b","flash_cke0_cs0a","flash_cke1_cs1a","flash_cke2_cs2a","flash_cke3_cs3a",
			"flash_cs0n_ca2b","flash_cs1n_ca1b","flash_cs2n_nc","flash_cs3n_ca0b","flash_odt0_cs0b","flash_odt1_cs1b","flash_odt2_cs2b","flash_odt3_cs3b","flash_par_ca13b","flash_rasn_ca7b","flash_wen_ca8b"
			);
		@flash_in_ca_diffn_put = ("flash_ck0_ck0a_0","flash_ck1_ck1a_0","flash_ck2_ck0b_0");
		@flash_in_ca_diffp_put = ("flash_ck0_ck0a_1","flash_ck1_ck1a_1","flash_ck2_ck0b_1");		
		@flash_in_dx_sngl_put = (
			"flash_dq[0]","flash_dq[1]","flash_dq[2]","flash_dq[3]","flash_dq[4]","flash_dq[5]","flash_dq[6]","flash_dq[7]","flash_dq[8]","flash_dq[9]",
			"flash_dq[10]","flash_dq[11]","flash_dq[12]","flash_dq[13]","flash_dq[14]","flash_dq[15]","flash_dq[16]","flash_dq[17]","flash_dq[18]","flash_dq[19]",
			"flash_dq[20]","flash_dq[21]","flash_dq[22]","flash_dq[23]","flash_dq[24]","flash_dq[25]","flash_dq[26]","flash_dq[27]","flash_dq[28]","flash_dq[29]",
			"flash_dq[30]","flash_dq[31]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[36]","flash_dq[37]","flash_dq[38]","flash_dq[39]",
			"flash_dq[40]","flash_dq[41]","flash_dq[42]","flash_dq[43]","flash_dq[44]","flash_dq[45]","flash_dq[46]","flash_dq[47]","flash_dq[48]","flash_dq[49]",
			"flash_dq[50]","flash_dq[51]","flash_dq[52]","flash_dq[53]","flash_dq[54]","flash_dq[55]","flash_dq[56]","flash_dq[57]","flash_dq[58]","flash_dq[59]",
			"flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[64]","flash_dq[65]","flash_dq[66]","flash_dq[67]","flash_dq[68]","flash_dq[69]",
			"flash_dq[70]","flash_dq[71]","flash_dq[72]","flash_dq[73]","flash_dq[74]","flash_dq[75]","flash_dq[76]","flash_dq[77]","flash_dq[78]","flash_dq[79]"
			);
		@flash_in_dx_diffn_put = (
			"flash_dqs_c[0]","flash_dqs_c[1]","flash_dqs_c[2]","flash_dqs_c[3]","flash_dqs_c[4]","flash_dqs_c[5]","flash_dqs_c[6]","flash_dqs_c[7]","flash_dqs_c[8]","flash_dqs_c[9]"
			);
		@flash_in_dx_diffp_put = (
			"flash_dqs_t[0]","flash_dqs_t[1]","flash_dqs_t[2]","flash_dqs_t[3]","flash_dqs_t[4]","flash_dqs_t[5]","flash_dqs_t[6]","flash_dqs_t[7]","flash_dqs_t[8]","flash_dqs_t[9]"
			);
		@flash_in_dx_diffn_put_2 = (
			"flash_dqs_c[10]","flash_dqs_c[11]","flash_dqs_c[12]","flash_dqs_c[13]","flash_dqs_c[14]","flash_dqs_c[15]","flash_dqs_c[16]","flash_dqs_c[17]","flash_dqs_c[18]","flash_dqs_c[19]"
			);
		@flash_in_dx_diffp_put_2 = (
			"flash_dqs_t[10]","flash_dqs_t[11]","flash_dqs_t[12]","flash_dqs_t[13]","flash_dqs_t[14]","flash_dqs_t[15]","flash_dqs_t[16]","flash_dqs_t[17]","flash_dqs_t[18]","flash_dqs_t[19]"
			);
		@flash_leak_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	
	}

	if ($test_mode eq "rep") {
	@flash_put = 	("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	@flash_put_odt = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	@flash_in_ca_sngl_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_odt0_cs0b");
	@flash_in_ca_diffn_put = ("flash_ck0_ck0a_0");
	@flash_in_ca_diffp_put = ("flash_ck0_ck0a_1");
	@flash_in_dx_sngl_put = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]");
	@flash_in_dx_diffn_put = ("flash_dqs_c[0]","flash_dqs_c[4]","flash_dqs_c[7]","flash_dqs_c[8]");
	@flash_in_dx_diffp_put = ("flash_dqs_t[0]","flash_dqs_t[4]","flash_dqs_t[7]","flash_dqs_t[8]");
	@flash_in_dx_diffn_put_2 = ("flash_dqs_c[9]");
	@flash_in_dx_diffp_put_2 = ("flash_dqs_t[9]");	
	@flash_leak_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	}

	
	if ($si_therm ne "NO") {
		print "Enter temperature to force on case: \n";
		$temp_entered = <STDIN>;
		chomp($temp_entered);
		@temp_C = ($temp_entered);
		$temp_soak = 10;
	}
	else {
		@temp_C = ("amb");
		$temp_soak = 0;
	}
	
	if ($test_mode eq "rep") {
		print ("Enter number of iterations: \n");
		$rep = <STDIN>;
		chomp($rep);
	}
	
}
elsif ($test_mode eq "pvt") {
	@flash_put = 	("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	@flash_put_odt = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	@flash_in_ca_sngl_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_odt0_cs0b");
	@flash_in_ca_diffn_put = ("flash_ck0_ck0a_0");
	@flash_in_ca_diffp_put = ("flash_ck0_ck0a_1");
	@flash_in_dx_sngl_put = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]");
	@flash_in_dx_diffn_put = ("flash_dqs_c[0]","flash_dqs_c[4]","flash_dqs_c[7]","flash_dqs_c[8]");
	@flash_in_dx_diffp_put = ("flash_dqs_t[0]","flash_dqs_t[4]","flash_dqs_t[7]","flash_dqs_t[8]");
	@flash_leak_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");

	@flash_io_pwr_tst = (1.14,1.2,1.26);
	@flash_vilh_pwr_tst = (1.14,1.2,1.26);
	#@flash_vilh_pwr_tst = (1.248);

	if ($si_therm ne "NO") {
		print "\n temp will run 25C,0C,105C\n";
		@temp_C = (25,-6,108);

	}
	else	{
		# print "\n temp will only run 25C\n";
		@temp_C = (25);
	
	}
		$temp_soak = 30;	
}
else {
	die "Incorrect test mode selected -> typ/rep/pvt\n";
}


# if ($extended == 1) {
# #	@flash_put = 	("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
# #	@flash_put = 	("flash_cke0_cs0a","flash_cke1_cs1a","flash_cke2_cs2a","flash_cke3_cs3a","flash_odt0_cs0b","flash_odt1_cs1b","flash_odt0_cs0b","flash_odt3_cs3b","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]");
	# @flash_put = 	("flash_cke0_cs0a","flash_odt1_cs1b","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dqs_t[4]","flash_dqs_c[4]");
# #	@flash_put_odt = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	# @flash_put_odt = ("flash_dq[0]","flash_dqs_c[8]");
	# @flash_in_ca_sngl_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_odt0_cs0b");
	# @flash_in_ca_diffn_put = ("flash_ck0_ck0a_0");
	# @flash_in_ca_diffp_put = ("flash_ck0_ck0a_1");
	# @flash_in_dx_sngl_put = ("flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]");
	# @flash_in_dx_diffn_put = ("flash_dqs_c[0]","flash_dqs_c[4]","flash_dqs_c[7]","flash_dqs_c[8]");
	# @flash_in_dx_diffp_put = ("flash_dqs_t[0]","flash_dqs_t[4]","flash_dqs_t[7]","flash_dqs_t[8]");
# #	@flash_leak_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dq[60]","flash_dq[61]","flash_dq[62]","flash_dq[63]","flash_dq[68]","flash_dq[69]","flash_dq[70]","flash_dq[71]","flash_dqs_t[0]","flash_dqs_c[0]","flash_dqs_t[4]","flash_dqs_c[4]","flash_dqs_t[7]","flash_dqs_c[7]","flash_dqs_t[8]","flash_dqs_c[8]");
	# @flash_leak_put = ("flash_cke0_cs0a","flash_a13_ca12b","flash_ck0_ck0a_1","flash_odt0_cs0b","flash_dq[0]","flash_dq[32]","flash_dq[33]","flash_dq[34]","flash_dq[35]","flash_dqs_t[8]","flash_dqs_c[8]");
# }

# print ("Enter test to perform (leak/vilh/od/odt/all): ");
# $test = <STDIN>;
# chomp($test);


if ($test eq "all") {
	print "All tests selected - (IO leakage, VILH, PVT Comp OD, PVT Comp ODT)\n";
	$datalog_file_leak = "flashio_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";
	
	$datalog_file_vilh = "flashio_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";
	
	$datalog_file_od = "flashio_od_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_od, ">>$datalog_file_od";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_od\n";
	
	$datalog_file_odt = "flashio_odt_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_odt, ">>$datalog_file_odt";
	print "PVT compensation ODT Data will be written to -> $datalog_file_odt\n";
}
elsif ($test eq "leak") {
	print "IO Leakage test selected\n";
	$datalog_file_leak = "flashio_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";
}
elsif ($test eq "vilh") {
	print "VILH test selected\n";
	$datalog_file_vilh = "flashio_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";
}
elsif ($test eq "od") {
	print "PVT Compensated Output Drive test selected\n";
	$datalog_file_od = "flashio_od_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_od, ">>$datalog_file_od";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_od\n";
}
elsif ($test eq "odt") {
	print "PVT Compensated ODT test selected\n";
	$datalog_file_odt = "flashio_odt_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}";
	open fh_odt, ">>$datalog_file_odt";
	print "PVT compensation ODT Data will be written to -> $datalog_file_odt\n";
}
else {
	die "Incorrect test selected ($test) -> (leak/vilh/od/odt/all)"
}


#ensure that the test starts at powerdown
`disconnect`;

print ("Initializing power supplies to Nominal setting.\n");
#ensure pwr supplies have been set to nominal values
foreach $supply_name (@supply_name_array) {
	`hpti 'PSLV $atp_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}



#turn on relay to connect ZQ to calibration resistor
 `hpti 'UTOT 1,,3'`;

# connect DPS to device
`connect`;

# wait for device to stablize
$stable_time = 5;
print ("Power supplies connected to device, waiting $stable_time seconds before starting test...\n");
sleep ($stable_time);

# Checking BSDL for connectivity
#print ("Checking BSDL vector for connectivity...\n");
#&check_bsdl;

# Checking functional test 
print ("Checking functional vector...\n");
&check_functional;

# Checking flash vector for vil and vih 
#&check_vih;
#&check_vil;

foreach $temp (@temp_C) {
	
	$current_count = 0;
	
	# Set and Calibrate Temperature of case if temperature forcer available
	if ($si_therm ne "NO") {
		&calibrate_temp($temp,$temp_soak,$cal_reference);
	}
	else {
		$case_temp = "NA";
		$junction_temp = "NA";
	}
	
	while ($current_count < $rep) {	

		if ($rep > 1) {
			print "\n**Current repeat count: $current_count\n";
			$mail_subject='"Current repeat count:"' . $current_count;
			system ('mail -s ' .$mail_subject .'  cy.shang@microchip.com,cyshang@gmail.com < /dev/null');
		
		}
		
		if (($test eq "all") || ($test eq "vilh")) {
			print "\n\nPerforming VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";
			foreach $vdd_flash (@flash_vilh_pwr_tst) {
				# # calibrate flash IO test supply voltage based on sense ball
				# no flash sense pin/ball in yorktown
				# $vdd_flash_level = `../voltage_force_93k.prl vdd_flash_ball vddo_ddr $atp_dps $vdd_flash`;
				# chomp($vdd_flash_level);
				# print "Testing with VDD_flash $vdd_flash V and VREF $vref V -> Calibrated to $vdd_flash_level mV\n";
				print "vdd_flash=$vdd_flash\n";
				&check_vil;

				$vref_mv = ($vdd_flash*0.5)*1000;
				$vref = $vref_mv/1000;
				# print "\nvref_mv=$vref_mv\n";					
				`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,(flash_ato)'`;				


				
				# testing single ended flash pins for input sensitivity
				foreach $put (@flash_in_ca_sngl_put) {
					print "1.VIL CA Single testing single ended CA flash pins for input sensitivity\n";
					&vil($vdd_flash,$put,0,1200);
				}

				&check_vil;

				$vref_mv = ($vdd_flash*0.50)*1000;
				$vref = $vref_mv/1000;
				#`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,(flash_ato)'`;
				
				# testing differential p flash pins for input sensitivity
				$index = 0;
				foreach $put_p (@flash_in_ca_diffp_put) {
					print "2.VIL CA P testing differential P CA flash pins for input sensitivity\n";
					# force n-channel to vref prior to testing p-channel
					$put_n = $flash_in_ca_diffn_put[$index];
					# `hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_n)'`;					
					&vil($vdd_flash,$put_p,0,1200);
					$index++;
				}
				&check_vil;

				$vref_mv = ($vdd_flash*0.50)*1000;
				$vref = $vref_mv/1000;
				#`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,(flash_ato)'`;
				
				# testing differential n flash pins for input sensitivity
				$index = 0;
				foreach $put_n (@flash_in_ca_diffn_put) {
					print "3.VIL CA N testing differential N CA flash pins for input sensitivity\n";
					#force p-channel to vref prior to testing n-channel
					$put_p = $flash_in_ca_diffp_put[$index];
					# `hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_p)'`;					
					&vil($vdd_flash,$put_n,0,1200);
					$index++;
				}
				&check_vil;
			
				$vref_mv = ($vdd_flash*0.5)*1000;
				$vref = $vref_mv/1000;
				#`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,(flash_ato)'`;
				
				# testing single ended flash pins for input sensitivity
				foreach $put (@flash_in_ca_sngl_put) {
					print "4.VIH CA Single testing single ended CA flash pins for input sensitivity\n";
					&vih($vdd_flash,$put,0,1200);
				}
				&check_vih;
	
				$vref_mv = ($vdd_flash*0.50)*1000;
				$vref = $vref_mv/1000;
				
				# testing differential p flash pins for input sensitivity
				$index = 0;
				foreach $put_p (@flash_in_ca_diffp_put) {
					print "5.VIH CA P testing differential P flash pins for input sensitivity\n";
					# force n-channel to vref prior to testing p-channel
					$put_n = $flash_in_ca_diffn_put[$index];
					&vih($vdd_flash,$put_p,0,1200);
					$index++;
				}
								
				&check_vih;

				$vref_mv = ($vdd_flash*0.50)*1000;
				$vref = $vref_mv/1000;
				# testing differential n flash pins for input sensitivity
				$index = 0;
				foreach $put_n (@flash_in_ca_diffn_put) {
					print "6.VIH CA N testing differential N flash pins for input sensitivity\n";
					#force p-channel to vref prior to testing n-channel
					$put_p = $flash_in_ca_diffp_put[$index];
					&vih($vdd_flash,$put_n,0,1200);
					$index++;
				}
				&check_vih;

				$vref_percentage = $flash_vilh_vref{$device_vil};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				
				# testing single ended flash pins for input sensitivity
				foreach $put (@flash_in_dx_sngl_put) {
					print "7.VIL DX Single testing single ended DX flash pins for input sensitivity\n";
					&vildx($vdd_flash,$put,0,1200);
				}				
				&check_vil_dx;

				$vref_percentage = $flash_vilh_vref{$device_vih};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				# testing single ended flash pins for input sensitivity
				foreach $put (@flash_in_dx_sngl_put) {
					print "8.VIH DX Single testing single ended flash pins for input sensitivity\n";
					&vihdx($vdd_flash,$put,0,1200);
				}
				&check_vih_dx;

				$vref_percentage = $flash_vilh_vref{$device_vih_dx};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				# testing differential p flash pins for input sensitivity
				$index = 0;
				foreach $put_p (@flash_in_dx_diffp_put) {
					print "9.VIH DX P testing differential p flash pins for input sensitivity\n";
					# force n-channel to vref prior to testing p-channel
					$put_n = $flash_in_dx_diffn_put[$index];
					`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_n)'`;
					&vihdx($vdd_flash,$put_p,0,1200);
					`hpti 'DRLV $vilh_lvl,0,1200,($put_n)'`;
					$index++;
				}
				&check_vih_dx;


# #Only execute in typical mode=======================
				$vref_percentage = $flash_vilh_vref{$device_vih_dx};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				# testing differential p flash pins for input sensitivity
				$index = 0;
				foreach $put_p (@flash_in_dx_diffp_put_2) {
					print "Typical VIH DX P2 testing differential p flash pins for input sensitivity\n";
					# force n-channel to vref prior to testing p-channel
					$put_n = $flash_in_dx_diffn_put_2[$index];
					`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_n)'`;
					&vihdx($vdd_flash,$put_p,0,1200);
					`hpti 'DRLV $vilh_lvl,0,1200,($put_n)'`;
					$index++;
				}				
				&check_vih_dx;
# #Only execute in typical mode************************

				$vref_percentage = $flash_vilh_vref{$device_vil_dx};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				
				# testing differential n flash pins for input sensitivity
				$index = 0;
				foreach $put_n (@flash_in_dx_diffn_put) {
					print "10.VIH DX N testing differential n flash pins for input sensitivity\n";
					#force p-channel to vref prior to testing n-channel
					$put_p = $flash_in_dx_diffp_put[$index];
					`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_p)'`;
					
					&vihdx($vdd_flash,$put_n,0,1200);
					`hpti 'DRLV $vilh_lvl,0,1200,($put_p)'`;
					$index++;
				}
				&check_vih_dx;
# #Only execute in typical mode=======================
				$vref_percentage = $flash_vilh_vref{$device_vil_dx};
				$vref_mv = ($vdd_flash*$vref_percentage)*1000;
				$vref = $vref_mv/1000;
				# testing differential n flash pins for input sensitivity
				$index = 0;
				foreach $put_n (@flash_in_dx_diffn_put_2) {
					print "Typical VIH DX N2 testing differential n flash pins for input sensitivity\n";
					#force p-channel to vref prior to testing n-channel
					$put_p = $flash_in_dx_diffp_put_2[$index];
					`hpti 'DRLV $vilh_lvl,$vref_mv,$vref_mv,($put_p)'`;
					
					&vihdx($vdd_flash,$put_n,0,1200);
					`hpti 'DRLV $vilh_lvl,0,1200,($put_p)'`;
					$index++;
				}		
				&check_vih_dx;
# #Only execute in typical mode************************

	
			}
		}
	

		if (($test eq "all") || ($test eq "od")) {


			
			print "\n\nPerforming PVT Compensated Output Drive testing on Split $split, Device $device @ Temperature $temp C ...\n";
			# $atp_lvl=$atp_lvl2;
			$atp_dataset = "SPRM $atp_wfs,$atp_tim,$atp_lvl,$atp_dps";
			`hpti '$atp_dataset'`;
			print "SPRM $atp_wfs,$atp_tim,$atp_lvl,$atp_dps";
			#testing flash rates
			if (($flash_select eq "flash") || ($flash_select eq "all")) {
				$flash_mode = "flash";
				foreach $current_flash_sply (@flash_io_pwr_tst) {
					$current_flash_sply_mv = $current_flash_sply * 1000;

					
					#start DX part

					$current_put_type = "dx";
					
					#DX PU
					foreach $flash_test_vectors (@flash_dxu_od_vec) {
						if ($flash_test_vectors =~/ltt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ltt"};	}
						if ($flash_test_vectors =~/ctt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ctt"};	}
						# $current_vref_mv = $current_flash_sply_mv /2;
						$current_load_updn = $flash_dxu_od{$flash_test_vectors};
						print "\n\n\n\n\nexpected current load = $current_load_updn\n";
						# print "flash_test_vectors=$flash_test_vectors\n";
						# print "current_vref_mv=$current_vref_mv\n";
						&pvt_comp_drvpupd_od($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv,"PU");
					}
					#DX PD					
					foreach $flash_test_vectors (@flash_dxd_od_vec) {
						if ($flash_test_vectors =~/ltt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ltt"};	}
						if ($flash_test_vectors =~/ctt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ctt"};	}						
						$current_load_updn = $flash_dxd_od{$flash_test_vectors};
						print "\n\n\n\n\nexpected current load = $current_load_updn\n";
						&pvt_comp_drvpupd_od($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv,"PD");
					}
					
					#start CA part
					$current_put_type = "ca";
					if ($flash_test_vectors =~/ltt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ltt"};	}
					if ($flash_test_vectors =~/ctt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ctt"};	}
					# $current_vref_mv = $current_flash_sply_mv /2;
					#CA PU
					foreach $flash_test_vectors (@flash_cau_od_vec) {
						if ($flash_test_vectors =~/ltt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ltt"};	}
						if ($flash_test_vectors =~/ctt/) {					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{"flash_ctt"};	}						
						$current_load_updn = $flash_cau_od{$flash_test_vectors};
						print "\n\n\n\n\nexpected current load = $current_load_updn\n";
						&pvt_comp_drvpupd_od($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv,"PU");
					}
					#CA PD					
					foreach $flash_test_vectors (@flash_cad_od_vec) {
						$current_load_dn = $flash_cad_od{$flash_test_vectors};
						print "\n\n\n\n\nexpected current load = $current_load_updn\n";
						&pvt_comp_drvpupd_od($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv,"PD");
					}
				}
			}

		}
		
		if (($test eq "all") || ($test eq "odt")) {


			print "\n\nPerforming PVT Compensated ODT testing on Split $split, Device $device @ Temperature $temp C ...\n";
			$atp_dataset = "SPRM $atp_wfs,$atp_tim,$atp_lvl,$atp_dps";
#			print "SPRM $atp_wfs,$atp_tim,$atp_lvl,$atp_dps\n";
			`hpti '$atp_dataset'`;
			#testing flash rates
			if (($flash_select eq "flash") || ($flash_select eq "all")) {
				$flash_mode = "flash";

				foreach $current_flash_sply (@flash_io_pwr_tst) {
					$current_flash_sply_mv = $current_flash_sply * 1000;
					$current_vref_mv = $current_flash_sply_mv * $flash_vref_ratio{$flash_mode};
					#&pin_forceV_measI("flash_vref",$current_vref_mv,-5,5,"IRA");
#					print "DRLV $atp_lvl,$current_vref_mv,$current_vref_mv,(flash_ato)\n";
					`hpti 'DRLV $atp_lvl,$current_vref_mv,$current_vref_mv,(flash_ato)'`;

					foreach $flash_test_vectors (@flash_odt_vec) {
						$current_odt_dx = $flash_dx_odt{$flash_test_vectors};
						&pvt_comp_odt($flash_mode,$flash_test_vectors,$current_flash_sply_mv,$current_vref_mv);
					}
				}
			}
		}
		
		if (($test eq "all") || ($test eq "leak")) {
		#turn off relay to connect ZQ to calibration resistor
		`hpti 'UTOT 1,,1'`;

			if (($si_therm eq "NO")){
					# testing device IO leakage for flash
					print "\n\nPerforming IO leakage testing on Split $split, Device $device @ Temperature $temp C ...\n";
					&io_leak($leak_pattern1);
					&io_leak($leak_pattern2);

			}
			if (($si_therm eq "ST")){
					# testing device IO leakage for flash
					print "\n\nPerforming IO leakage testing on Split $split, Device $device @ Temperature $temp C ...\n";
					if ($test_mode eq "pvt"){
						foreach $current_flash_sply (@flash_io_pwr_tst) {
							print "flash_power=$current_flash_sply";
							&io_leak_pvt($leak_pattern1,$current_flash_sply);
							&io_leak_pvt($leak_pattern2,$current_flash_sply);
						}
					}
			}			
		}
	$current_count++;
	}
}
	

# reinit the DPS supplies to nominal
foreach $supply_name (@supply_name_array) {
	`hpti 'PSLV $atp_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

#powerdown the device
`disconnect`;

if ($test eq "all") {
	close fh_leak;
	close fh_vilh;
	close fh_od;
	close fh_odt;
}
elsif ($test eq "leak") {
	close fh_leak;
}
elsif ($test eq "vilh") {
	close fh_vilh;
}
elsif ($test eq "od") {
	close fh_od;
}
elsif ($test eq "odt") {
	close fh_odt;
}
else {
}
#return to 25C
if (($test_mode eq "pvt") && ($si_therm ne "NO")){
	print "\nReturn temp to 25C\n";
	`/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_v3_p0.prl 25 30 $si_therm`;
}
`disconnect`;
print "***Test Completed Successfully!  Device powered down and can be removed.***\n";


$mail_subject=$split ."_". $temp . "C_". $device;
system ('mail -s ' .$mail_subject .'  cy.shang@microchip.com,cyshang@gmail.com < /dev/null');
