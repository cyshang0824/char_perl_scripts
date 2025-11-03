#!/usr/local/bin/perl

########################################################
# CY SHANG (July 2024) - Titan I3C characterization
# Characterization tests supported - input sensitivity, IO leakage, PVT Compensated OD - ROCD, PVT Compensated ODT - Rtt/Vm
# Fixed Vhyst measurement and Rpupd will by remeasured by IRB if current is too small.

$date = `date`;
@date_array = split " ",$date;

$PATH = "/proj/me_proj/cyshang/Titan/i3c_char/";
my $time_file_path = $PATH . "time_file_${date_array[1]}${date_array[2]}.txt";

# my $subject="test123";
# create_time_file($time_file_path, $subject);
# exit;


$gCapSize = 100000;
$gScan_port = "jtag_tdo_p";


$cal_reference = "case";
$debug = 0 ;

$atp_wfs = 16;
$atp_tim = 1;
$lvl = 3;
$dps = 6;


$bsdl_wfs = 1;
$bsdl_tim = 1;
$bsdl_lvl = 11;
$bsdl_dps = 6;


$i3c_transparency_wfs = 3;
$i3c_transparency_tim = 1;
$i3c_transparency_lvl = 3;
$i3c_transparency_dps = 6;



# vectors to use for bsdl contact check
$device_bsdl = "pm35160_bsdl_reva_DC_DC";
$device_vil = "pm35160_bsdl_reva_HIZ_HIZ";


# Current: 3.6, 7.2, 14.4, 18A 
# vectors to use for vol voh char
# $volh_pattern = "i3c_transparency_D0_to_D1";

#$cfg_dataset = "SPRM $i3c_wfs,$tim,$lvl,$dps";
$sch_vilh_dataset = "SPRM 16,1,$lvl,$dps";
#$sch_vilh_dataset = "SPRM 16,1,$bsdl_lvl,$bsdl_dps";
$i3c_transparency_vilh_dataset = "SPRM 3,1,$i3c_transparency_lvl,$i3c_transparency_dps";


# vectors to use for vil vih char
#$vilh_pattern = "pm35160_bsdl_reva_DC_DC";
$vilh_pattern = "i3c_transparency_D0_to_D1";
# $vilh_pattern2 = "i3c_transparency_D0_to_D1_VILH";

$vil_pattern = "i3c_transparency_D0_to_D1_VIL";
$vih_pattern = "i3c_transparency_D0_to_D1_VIH";

$iolh_pattern = "i3c_transparency_D0_to_D1";

# vectors to use for Rpu, Rpd char
# $pupd_pattern = "i3c_transparency_D0_to_D1";


# vector to use for io leakage
# $device_io_leak = "i3c_leakage";

				  
@iolh_MaxSpec_array = ( 0,-9.71,9.9,-17.81,18.35,-27.71,28.27,-33.13,34.76,-12.22,12.58,12.58,14.54,14.54,26.22,
                      -6.1,6.24,-11.23,11.6,-17.64,18.42,-21.12,22.19,-7.78,8.04,8.04,12.75,12.75,
                      -4.89,4.98,-9.04,9.28,-14.3,14.86,-18.13,17.92,-7.51,7.72,7.72,12.42,10.44,14.04,10.44);					  
@iolh_MinSpec_array = ( 0,-7.24,7.53,-13.56,14.21,-22.25,23.47,-26.81,28.43,-9.29,9.72,9.72,11.54,11.54,23.22,
                      -3.49,3.68,-6.58,6.98,-11,11.72,-13.29,14.22,-5.56,5.89,5.89,9.75,9.75,
					  -2.67,2.78,-5.05,5.29,-8.55,9.02,-10.35,11.03,-5.09,5.34,5.34,9.13,7.44,11.04,7.44);					  

#class definition for all the possible pins that will be tested either in typ/rep/pvt modes
%i3c_pin_class = (
	"i3c_clk0_p"		=>	"lvcmos18_ns",
	"i3c_clk1_p"		=>	"lvcmos18_ns",
	"i3c_data0_p"		=>	"lvcmos18_ns",
	"i3c_data1_p"		=>	"lvcmos18_ns",
);


# power supply settings
%typ_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.734,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,
	"vddo_i3c_0"		=> 1.8,	
	"vddo_i3c_1"		=> 1.8,	
	
);

%typ_1v2_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80, 
	"vdd_core"		=> 0.734,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,
	"vddo_i3c_0"		=> 1.2,	
	"vddo_i3c_1"		=> 1.2,	
);
	
%typ_1v1_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80, 
	"vdd_core"		=> 0.734,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,
	"vddo_i3c_0"		=> 1.1,	
	"vddo_i3c_1"		=> 1.1,	
);

	
%typ_1v0_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80, 
	"vdd_core"		=> 0.734,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.0,	
	"vddo_i3c_1"		=> 1.0,		
);

%min_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.71,	
	"vddo_i3c_1"		=> 1.71,			
);

%min_1v2_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.14,	
	"vddo_i3c_1"		=> 1.14,		
);

%min_1v1_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.045,	
	"vddo_i3c_1"		=> 1.045,	
); 

%min_1v0_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 0.95,	
	"vddo_i3c_1"		=> 0.95,		
); 

%max_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.89,	
	"vddo_i3c_1"		=> 1.89,		
);

%max_1v2_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.26,	
	"vddo_i3c_1"		=> 1.26,		
);

%max_1v1_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.155,	
	"vddo_i3c_1"		=> 1.155,	
);

%max_1v0_supply = (
	"vddo_gpio_n"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"vddo_gpio_s"		=> 1.8,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.05,	
	"vddo_i3c_1"		=> 1.05,		
);


%pwr_loads = (
	"vddo_gpio_n"		=> 2,
	"avdh_pcie_vph"	 	=> 4,
	"vddo_gpio_s"		=> 2,
	"avd_serdes"		=> 10,
	"vddo_i3c_1"		=> 1,
	"vddo_fc"		=> 8,
	"vddo_ddr_pll"		=> 1,
	"avd_pll_pcie_refclk"	=> 4,
	"avdh_dcsu_pll"		=> 4,
	"vdd_core"		=> 20,
	"vddo_i3c_0"		=> 1,
	"avdh_pcie_refclk"	=> 1,
	"vddo_ddr_io"		=> 6,
);

%pwr_seq = (
	"vddo_gpio_n"		=> 15,
	"avdh_pcie_vph"	 	=> 20,
	"vddo_gpio_s"		=> 15,
	"avd_serdes"		=> 20,
	"vddo_i3c_1"		=> 20,
	"vddo_fc"		=> 20,
	"vddo_ddr_pll"		=> 25,
	"avd_pll_pcie_refclk"	=> 20,
	"avdh_dcsu_pll"		=> 20,
	"vdd_core"		=> 20,
	"vddo_i3c_0"		=> 20,
	"avdh_pcie_refclk"	=> 20,
	"vddo_ddr_io"		=> 15,
);

@supply_name_array = ("vddo_gpio_n", "avdh_pcie_vph", "vddo_gpio_s", "avd_serdes", "vddo_i3c_1","vddo_fc", "vddo_ddr_pll", "avd_pll_pcie_refclk", "avdh_dcsu_pll", "vdd_core", "vddo_i3c_0", "avdh_pcie_refclk", "vddo_ddr_io");
@i3c_put = ("i3c_data0_p");
@i3c_all_put = ("i3c_clk0_p","i3c_clk1_p","i3c_data0_p","i3c_data1_p");			
@i3c_output = ("i3c_data1_p");



########################################################
sub set_device_power {
	

	my($vdd_0, $wait_time) = @_;
    
	print ("\n\nPower supplies setting: $vdd_0 ...\n");
	
	if ($vdd_0 eq "off") {  
		$vdd = 0.0; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("off power ($vdd): $dps,$off_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$off_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v8") {  
		$vdd = 1.8; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v8. power ($vdd): $dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v2") {  
		$vdd = 1.8; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v2. power ($vdd): $dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v1") {  
		$vdd = 1.8; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v1. power ($vdd): $dps,$typ_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	

	elsif ($vdd_0 eq "typ_1v0") {  
		$vdd = 1.8; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v0. power ($vdd): $dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	

	elsif ($vdd_0 eq "min_1v8") {  
		$vdd = 1.2;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v8. power ($vdd): $dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "min_1v2") {  
		$vdd = 1.2;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v2. power ($vdd): $dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "min_1v1") {  
		$vdd = 1.2;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v1. power ($vdd): $dps,$min_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "min_1v0") {  
		$vdd = 1.2;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v0. power ($vdd): $dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	
	elsif ($vdd_0 eq "max_1v8") {  
		$vdd = 1.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v8. power ($vdd): $dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v2") {  
		$vdd = 1.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v2. power ($vdd): $dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v1") {
		$vdd = 1.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v1. power ($vdd): $dps,$max_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v1_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	
	elsif ($vdd_0 eq "max_1v0") {
		$vdd = 1.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v0. power ($vdd): $dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}		
	# wait for device to stablize
	if($debug > 0.5) { print ("Power supplies connected to device, waiting $wait_time seconds before starting test...\n"); }
	sleep ($wait_time);

return $vdd;
}
sub iolh_sweep_binary {
    
	my($vddo_v,$Vin_set,$put_i,$pat_cfg,$vdd_i3c,$ilimit,$meas) = @_;
	
	# initialize pass/fail boundary flag
	$pf_bnd_fnd = 0;

	# define loop count 10 times to exit the binary search
	$loop = 0;
	
  	if ($meas eq "IOH") { $Vsearch1 = $Vin_set*0.5 ; $Vsearch2 = $Vin_set ; $iL = -$ilimit*1000; $iH = -100; print "iL= $iL\n";} # set pin under test to new mV to search IOH
	elsif($meas eq "IOL") { $Vsearch2 = $Vin_set ; $Vsearch1 = $Vin_set*1.5 ;  $iL = 100; $iH = $ilimit*1000; print "iH= $iH\n";} # set pin under test to new mV to search IOL
	
	while ($pf_bnd_fnd == 0) {
		
	   if ($meas eq "IOH") { $current_put_mv = $Vsearch2 - (($Vsearch2 - $Vsearch1)/2); } # set pin under test to new mV to search IOH
       elsif($meas eq "IOL") { $current_put_mv = $Vsearch2 + (($Vsearch1 - $Vsearch2)/2);} # set pin under test to new mV to search IOL
	
	
	   `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	   `hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	   `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	   `hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
       `hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
       #if($debug > 0.5) { print "-- MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)\n"; }
	   `hpti 'MSET 1,DC,1,UFOR,2,$current_put_mv,($put_i)'`;	
       #if($debug > 0.5) { print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n"; }
	   `hpti 'MSET 1,DC,1,PMUL,3,$iL,($put_i)'`;
	   `hpti 'MSET 1,DC,1,PMUH,4,$iH,($put_i)'`;
	   `hpti 'MSET 1,DC,1,ACTI,5,,($put_i)'`; 

	   `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	   `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	   `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	   `hpti 'MSET 1,DC,2,PPMU,0,ON,($put_i)'`;
	   `hpti 'MSET 1,DC,2,ACTI,1,,($put_i)'`;

	   `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	   `hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	   `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	   `hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;

	   `hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	   #`hpti 'MEAR VAL,10,($put_i)'`;
	   #`hpti 'MEAR VMUM,10,($put_i)'`;

	   $ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;
	   	 
	   if($debug > 0.5) { print "$ret_val_1\n"; }
	
	   @ret_array_1 = split " ", $ret_val_1;
	   
	   @ret_array_2 = split ",", @ret_array_1[1];

	
       if(@ret_array_2[0] eq "P"){ $Vsearch2 = $current_put_mv ;}
	   elsif (@ret_array_2[0] eq "F") {$Vsearch1 = $current_put_mv ;} 
	
       #if($loop>=20) { print ("fail to search the voltage\n"); $pf_bnd_fnd = 1; }
	   $loop = ++$loop;
	   $spread = $Vsearch2 - $Vsearch1;
	   $max_spread = $Vin_set * 0.005 ;
	   if ($spread < 0) { $spread = -1 * $spread;}		
	   if (($spread <= $max_spread)&&(@ret_array_2[0] eq "F")||($loop>20)) {$meas_i =  @ret_array_2[2]/1000; $pf_bnd_fnd = 1;}
	   
    }

  	`hpti 'RLYC AC,OFF,($put_i)'`;		
	
	print "Search voltage = $current_put_mv IOLH value for $put_i = $meas_i mA \n";

	print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$vddo_v,vdd_i3c=$vdd_i3c,");
	print fh_iolh ("$put_i,SearchV=$current_put_mv mv,$meas=$meas_i mA\n");
			
}
sub iolh_volt_meas {
    
	my($vddo_v,$put_set,$pat_cfg,$mode,$vdd_i3c,$vddc,$ilimit,$parameter,$first_run) = @_;
	
	   $iforce = $ilimit*1000; #uA
	   print "iforce = $iforce,($put_set)\n";
	   `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	   `hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	   `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	   #`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
       `hpti 'MSET 1,DC,1,SEL,0,VOLT,($put_set)'`;
       #`hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
	   `hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_set)'`;
       #if($debug > 0.5) { print "-- MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)\n"; }
	   #`hpti 'MSET 1,DC,1,UFOR,2,$current_put_mv,($put_i)'`;	
	   `hpti 'MSET 1,DC,1,IFOR,2,$iforce,($put_set)'`;
       #if($debug > 0.5) { print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n"; }
	   #`hpti 'MSET 1,DC,1,PMUL,3,$iL,($put_i)'`;
	   `hpti 'MSET 1,DC,1,PMUL,3,0,($put_set)'`;
	   `hpti 'MSET 1,DC,1,PMUH,4,2000,($put_set)'`;
	   `hpti 'MSET 1,DC,1,ACTI,5,,($put_set)'`; 
       if($first_run ne "0"){
	   `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	   `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	   `hpti 'MSET 1,DC,2,ACT,,,(@)'`;	  
	   `hpti 'MSET 1,DC,2,PPMU,0,ON,($put_set)'`;
	   `hpti 'MSET 1,DC,2,ACTI,1,,($put_set)'`;
       }
	   `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	   `hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	   `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	   `hpti 'MSET 1,DC,3,PMUM,0,L,($put_set)'`;
	   
	   `hpti 'MSET 1,DC,4,LEN,4,,(@)'`;
       `hpti 'MSET 1,DC,4,WAIT,,0,(@)'`;
       `hpti 'MSET 1,DC,4,ACT,,,(@)'`;
       `hpti 'MSET 1,DC,4,CLPH,0,1800,($put_set)'`;
       `hpti 'MSET 1,DC,4,CLPL,1,0,($put_set)'`;
       `hpti 'MSET 1,DC,4,CLMP,2,ON,($put_set)'`;
       `hpti 'MSET 1,DC,4,ACTI,3,,($put_set)'`;


       if($first_run ne "0"){`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3; MEAS 1,4'`;}
	   else{`hpti 'MEAS 1,1; MEAS 1,3; MEAS 1,4'`;}
	   
	   `hpti 'MEAR VAL,5,($put_set)'`;
	   #`hpti 'MEAR VMUM,10,($put_i)'`;

	   $ret_val_1 = `hpti 'PMUR? VAL,($put_set)'`;
	   	 
	   if($debug > 0.5) { print "$ret_val_1"; }
	
	   @ret_array_1 = split ",", $ret_val_1;
	   $meas_volt = @ret_array_1[1]/1000 ;

  	#`hpti 'RLYC AC,OFF,($put_set)'`;		
	
	print "Search voltage = $meas_volt V , IOLH value for $ilimit mA\n";

	print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
	print fh_iolh ("$put_i,$parameter,SearchV= $meas_volt V,$meas=$ilimit mA\n");
	
	
	
	
}
sub lvcmos_volh {

	my($Vin_set,$put_i,$Iin_set,$put_v) = @_;
				
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,20,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
	`hpti 'MSET 1,DC,1,SEL,0,VOLT,($put_v)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_v)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)'`;	
print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n";
	`hpti 'MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)'`;
	`hpti 'MSET 1,DC,1,PMUL,3,-50,($put_i)'`;
	`hpti 'MSET 1,DC,1,PMUL,3,500,($put_v)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,50,($put_i)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,2500,($put_v)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put_i,$put_v)'`; 

	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,100,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,ACPM,0,ON,($put_i)'`;
	`hpti 'MSET 1,DC,2,ACPM,0,ON,($put_v)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($put_i,$put_v)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,500,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,L,($put_v)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	##`hpti 'MEAR VAL,10,($put_i)'`;

	#$ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;
	#print "$ret_val_1\n";
	
	#@ret_array_1 = split ",", $ret_val_1;
	#$meas_i = $ret_array_1[2];

	$ret_val_2 = `hpti 'PMUR? VAL,($put_v)'`;
	print "$ret_val_2\n";
	
	@ret_array_2 = split ",", $ret_val_2;
	$meas_mV = $ret_array_2[1];
	
	print "measures value for $put_v = $meas_mV mV\n";

#print ("Enter yes/no to check (yes/no): ");
#$check_1 = <STDIN>;
#chomp($check_1);

	`hpti 'RLYC IDLE,OFF,($put_i,$put_v)'`;				

	print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_vil,$vdd_lvdsrx_level,");
	print fh_volh ("$put_v,$Iin_set,$lo_limit,$hi_limit,$meas_mV\n");
	
}
sub power_reset {

# connect DPS to device
`disconnect`;
	
print ("Initializing power supplies to Nominal setting.\n");
#ensure pwr supplies have been set to nominal values
foreach $supply_name (@supply_name_array) {

print ("power: $dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n");

	`hpti 'PSLV $dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

# connect DPS to device
`connect`;

# wait for device to stablize
$stable_time = 5;
print ("Power supplies connected to device, waiting $stable_time seconds before starting test...\n");
sleep ($stable_time);

}
sub PUPD_I {

my($vddo_v,$vin_test,$put,$put_set,$mode,$vdd_i3c,$vddc,$parameter,$Irng,$pat_cfg) = @_;


my $Rng_ReMes_enable = 0;
my $pin_i=0;
do {
    `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
    `hpti 'MSET 1,DC,1,WAIT,,20,(@)'`;
    `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
    `hpti 'MSET 1,DC,1,SEL,0,CURR,($put)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$Irng,($put)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$vin_test,($put)'`;
	if ($Irng eq "IRD")
	{#Set the current range of the IRD
		`hpti 'MSET 1,DC,1,PMUL,3,-13000,($put)'`;
		`hpti 'MSET 1,DC,1,PMUH,4,5000,($put)'`;
	}
	elsif ($Irng eq"IRA")
	{#Set the current range of the IRA
		`hpti 'MSET 1,DC,1,PMUL,3,-10,($put)'`;
		`hpti 'MSET 1,DC,1,PMUH,4,10,($put)'`;
	}	
	elsif ($Irng eq"IRB")
	{#Set the current range of the IRB
		`hpti 'MSET 1,DC,1,PMUL,3,-100,($put)'`;
		`hpti 'MSET 1,DC,1,PMUH,4,100,($put)'`;
	}
	elsif ($Irng eq"IRC")
	{#Set the current range of the IRC
		`hpti 'MSET 1,DC,1,PMUL,3,-1000,($put)'`;
		`hpti 'MSET 1,DC,1,PMUH,4,1000,($put)'`;
	}
    `hpti 'MSET 1,DC,1,ACTI,5,,($put)'`;

    `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
    `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
    `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
    `hpti 'MSET 1,DC,2,PPMU,0,ON,($put)'`;
    `hpti 'MSET 1,DC,2,ACTI,1,,($put)'`;

    `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
    `hpti 'MSET 1,DC,3,WAIT,,3,(@)'`;
    `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
    `hpti 'MSET 1,DC,3,PMUM,0,I,($put)'`;

    `hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;

    `hpti 'MEAR VAL,10,($put)'`;

    my $ret_val_1 = `hpti 'PMUR? VAL,($put)'`;

    my @ret_array_1 = split ",", $ret_val_1;
    $pin_i = $ret_array_1[2];
	
	if ($pin_i != 0) {			$R_value1 = abs($vdd_i3c/$pin_i *1000);	}
	else { $R_value1 ="offline";}
	print "$put current $pin_i uA is measured, Rpu/pd = $R_value1 kohm, $Irng\n";	
	if ($Irng eq "IRD")
	{
		# print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		# print fh_pupd ("$put,$parameter,ForceV=$vin_test,$lo_limit,$hi_limit,$pin_i uA,$Irng,$R_value1 kohm\n");
  	}
	
    if (abs($pin_i) <= 10 && $Rng_ReMes_enable == 0) 
	{   $Irng = "IRA";        $Rng_ReMes_enable = 1;        print "\nIRA_enable...\n";
		# print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		# print fh_pupd ("$put,$parameter,ForceV=$vin_test,$lo_limit,$hi_limit,$pin_i uA,$Irng,$R_value1 kohm\n");
   }
    elsif (abs($pin_i) > 10 && abs($pin_i) <= 100 && $Rng_ReMes_enable == 0) 
	{   $Irng = "IRB";        $Rng_ReMes_enable = 1;        print "\nIRB_enable...\n";    
		# print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		# print fh_pupd ("$put,$parameter,ForceV=$vin_test,$lo_limit,$hi_limit,$pin_i uA,$Irng,$R_value1 kohm\n");
   }   
    elsif (abs($pin_i) > 100 && abs($pin_i) <= 1000 && $Rng_ReMes_enable == 0) 
	{   $Irng = "IRC";        $Rng_ReMes_enable = 1;        print "\nIRC_enable...\n";    
		# print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		# print fh_pupd ("$put,$parameter,ForceV=$vin_test,$lo_limit,$hi_limit,$pin_i uA,$Irng,$R_value1 kohm\n");
   }
	elsif ($Rng_ReMes_enable == 1)
	{	# Once the IRB/IRC is activated, it must be disabled to prevent it from being executed twice.   
        $Rng_ReMes_enable = 0;        print "\nIRB/IRC_disable...\n"; 
	}
}
while ($Rng_ReMes_enable == 1);


	


	   		###################################
	   		# TEST 7.1
	   		###################################
			
    # if($parameter eq "Rpd") {                   #measure Rpd at 6uA
		   	# ###################################
	   		# # TEST 7.1
	   		# ###################################
	        # #measure Rpd at 6uA
	         # $i_force = 6;
	    # `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	    # `hpti 'MSET 1,DC,1,WAIT,,20,(@)'`;
	    # `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
     	# `hpti 'MSET 1,DC,1,SEL,0,VOLT,($put)'`;
	    # `hpti 'MSET 1,DC,1,IRNG,1,IRA,($put)'`;
	    # `hpti 'MSET 1,DC,1,IFOR,2,$i_force,($put)'`; # force xx uA
	    # `hpti 'MSET 1,DC,1,PMUL,3,-5,($put)'`;
	    # `hpti 'MSET 1,DC,1,PMUH,4,1000,($put)'`;
	    # `hpti 'MSET 1,DC,1,ACTI,5,,($put)'`; 

	    # `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	    # `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	    # `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	    # `hpti 'MSET 1,DC,2,PPMU,0,ON,($put)'`;
	    # `hpti 'MSET 1,DC,2,ACTI,1,,($put)'`;

	    # `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	    # `hpti 'MSET 1,DC,3,WAIT,,3,(@)'`;
	    # `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
    	# `hpti 'MSET 1,DC,3,PMUM,0,I,($put)'`;

	    # `hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	    # `hpti 'MEAR VAL,10,($put)'`;

     	# $ret_val_2 = `hpti 'PMUR? VAL,($put)'`;
	    # #print "$ret_val_2\n";
	    # @ret_array_2 = split ",", $ret_val_2;
	    # $pin_v = $ret_array_2[1];
   
        # $R_value2 = abs($pin_v/$i_force );  
     	# print "$put voltage $pin_v mV is measured, Rpd = $R_value2 kohm.\n\n\n";

	# }  
		print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_pupd ("$put,$parameter,ForceV=$vin_test,$lo_limit,$hi_limit,$pin_i uA,$Irng,$R_value1 kohm\n");
 
    # if($parameter eq "Rpd") {                   #measure Rpd at 6uA
		# print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		# print fh_pupd ("$put,$parameter,ForceI=6uA,$lo_limit,$hi_limit,$pin_v mV,$R_value2 kohm\n");
	# }
}
sub vilh_sweep_binary {

	my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# initialize pass/fail boundary flag
	$pf_bnd_fnd = 0;
	# define current_vdd that will be used to start the binary search
	$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
	# define limit (mV) to exit the binary search
	$max_spread = 1;
	
	#`hpti 'SREC x,(@)'`;
	#`hpti 'SREC act,(tdo,$put)'`;	
	
	while ($pf_bnd_fnd == 0) {
		$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
		# set pin under test to new V
		if ($vil eq "tst") {
			# input low being tested
			`hpti 'DRLV $lvl,$current_put_mv,$vih,($put)'`;
		}
		else {
			# input high being tested
			`hpti 'DRLV $lvl,$vil,$current_put_mv,($put)'`;
		}
		`hpti 'WAIT 50'`;		
	
		$ret_val = `hpti 'FTST?'`;
		@retval_array = split " ",$ret_val;
	
    	#$ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		#print "errorcount: $ec_val\n ";
	    #@ec_array = split ",",$ec_val;
	
		#print "ec: $ec_array[2] ";

        #if ($ec_array[2] ne "0") {

		#print ("test reported $retval_array[1] @ vilh=$current_put_mv for $put; current test limits = $limit_1 mV and $limit_2 mV with Spread $spread mV\n");
		
		if ($retval_array[1] eq "F") {
		#print ("test reported $retval_array[1] @ vilh=$current_put_mv for $put; current test limits = $limit_1 mV and $limit_2 mV with Spread $spread mV\n");
			$limit_2 = $current_put_mv;
		}
		else {
			$limit_1 = $current_put_mv;
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


	return $limit_1;
	
}
sub vilh_sweep_linear {

	my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# define current_vdd that will be used to start the linear search
    $current_put_mv = $limit_1 ;     #initial vil/vih value		
	# define limit (mV) to exit the binary search
	$pf_flag = 0;	

  
  if ($vil eq "tst") {	     # input low being tested	VIL

		     `hpti 'FTST?'`;
	
	    while (($current_put_mv <= $limit_2) && ($pf_flag == 0)) {
		     $current_put_mv = $current_put_mv + 30 ; #30mv per step 
			 
             `hpti 'DRLV $lvl,$current_put_mv,$vih,($put)'`; #set vil = current_put_mv
             #`hpti 'SQSL "$vilh_pattern"'`;
			 #`hpti 'WAIT 10'`;		
	         #`hpti 'FTSM SET,4547,,'`;
		     $ret_val = `hpti 'FTST?'`;
			 print "FTST = $ret_val\n";
		     @retval_array = split " ",$ret_val;
			 if ($retval_array[1] eq "F") {
			    $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		        #print "errorcount: $ec_val\n ";
	            @ec_array = split ",",$ec_val;
		        print ("errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4]");
                print ("current VIL = $current_put_mv mV\n");
				if ($ec_array[2] eq "5") {$pf_flag = 1;}
                #if ($ec_array[2] ne "0") {$pf_flag = 1;}
				#if ($ec_array[2] > 20 ) {$pf_flag = 1;}
			 }	
			 #print ("current VIL = $current_put_mv mV\n");
			 
		}
	}
    else {            			# input high being tested  VIH

	         `hpti 'FTST?'`;
	
	    while (($current_put_mv >= $limit_2) && ($pf_flag == 0)) {
		     $current_put_mv = $current_put_mv - 30 ; #30mv per step 
             `hpti 'DRLV $lvl,$vil,$current_put_mv,($put)'`; #set vih = current_put_mv
			 #`hpti 'SQSL "$vilh_pattern"'`;
			 #`hpti 'WAIT 10'`;		
	         #`hpti 'FTSM SET,3189,,'`;

		     $ret_val = `hpti 'FTST?'`;
			 print "FTST = $ret_val\n";
		     @retval_array = split " ",$ret_val;
             if ($retval_array[1] eq "F") {
			    $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		        #print "errorcount: $ec_val\n ";
	            @ec_array = split ",",$ec_val;
		        print ("errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4]");
                print ("current VIH = $current_put_mv mV\n");
                if ($ec_array[2] eq "4") {$pf_flag = 1;}
                #if ($ec_array[2] ne "0") {$pf_flag = 1;}
				#if ($ec_array[2] > 20 ) {$pf_flag = 1;}
			
			 }	
				 
		     #print ("current VIH = $current_put_mv mV\n");
		
		}
	}		
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  	
	return $current_put_mv;
	#`hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  
}



sub vilh_sweep_linear_vhyst {

	my($put, $limit_1, $limit_2, $vil, $vih,$pat_cfg,$mode) = @_;
	
	# define current_vdd that will be used to start the linear search
    $current_put_mv = $limit_1 ;     #initial vil/vih value		
	# define limit (mV) to exit the binary search
	$pf_flag_coarse = 0;	
    $pf_flag_fine = 0;	
	$back_coarse_volt = 0;	# pass over vhyst 
 	$coarse_volt = 0;	    # coarse voltage 


	
  if ($vil eq "tst") {	     # input low being tested	 VIL
  
			print "tst --VIL\n";
			print " mode= $mode \n";

			 `hpti '$i3c_transparency_vilh_dataset'`;	
			 print "$i3c_transparency_vilh_dataset\n";
			 `hpti 'SQSL "i3c_DC_cfg_$pat_cfg"'`; `hpti 'FTST?'`;
			 print "-- i3c_DC_cfg_$pat_cfg\n";		
			 $pattern = `hpti 'SQSL?'`;
	         print "cfg setting: $pattern";
            `hpti 'SQSL "$vih_pattern"'`;	
	
	    while (($current_put_mv <= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv + 100 ; }#100mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {print "***** start pf_flag_coarse search *****\n";$current_put_mv = $current_put_mv + 20 ;} #20mv per step for fine search
			 
 		 
			 
			 `hpti 'DRLV $lvl,0,$current_put_mv,($put)'`; #set vih = current_put_mv		
             print "VIL DRLV $lvl,0,$current_put_mv,$put\n"; `hpti 'WAIT 500'`;
		     $ret_val = `hpti 'FTST?'`;
			 print "cfg$pat_cfg FTST of $current_put_mv mv = $ret_val";

			 
			 if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_mv = $coarse_volt - 100 ; $back_coarse_volt = 1;} #back the voltage of coarse search
		 
			 @retval_array = split " ",$ret_val;

			 if ($retval_array[1] eq "P") {

                if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search
                if($pf_flag_coarse == 0)                         {$pf_flag_coarse = 1 ; $coarse_volt = $current_put_mv; $current_put_mv = $limit_1 ;} # start fine search

             }
		}
	}
    else {            			# input high being tested VIH

        print "no tst-- VIH\n";	
			 print " mode= $mode \n";

			 `hpti '$i3c_transparency_vilh_dataset'`;	
			 print "$i3c_transparency_vilh_dataset\n";
			 `hpti 'SQSL "i3c_DC_cfg_$pat_cfg"'`; `hpti 'FTST?'`;
			 print "-- i3c_DC_cfg_$pat_cfg\n";		
			 $pattern = `hpti 'SQSL?'`;
	         print "cfg setting: $pattern";
			 
             `hpti 'SQSL "$vih_pattern"'`;			
		
	    while (($current_put_mv >= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv - 100 ; }#100mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {print "***** start pf_flag_coarse search *****\n";$current_put_mv = $current_put_mv - 20 ;} #20mv per step for fine search
			 
		 

			 `hpti 'DRLV $lvl,0,$current_put_mv,($put)'`; #set vil = current_put_mv		
             print "VIH DRLV $lvl,0,$current_put_mv,$put\n";`hpti 'WAIT 500'`;	 
		     $ret_val = `hpti 'FTST?'`;
			 print "cfg$pat_cfg FTST of $current_put_mv mv = $ret_val";
# exit;	
			if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_mv = $coarse_volt + 100 ; $back_coarse_volt = 1;} #back the voltage of coarse search
		    
		     @retval_array = split " ",$ret_val;
		      # print "retval_array[1]=$retval_array[1]\n";

             if ($retval_array[1] eq "F") {

                 if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search         
   			     if($pf_flag_coarse == 0)                         {$pf_flag_coarse = 1 ; $coarse_volt = $current_put_mv; $current_put_mv = $limit_1 ;} # start fine search
                 

                 #print ("vih_ercy_pf_flag_info: $pf_flag,$pf_count,$ercy_log\n");

			 }	
				 
		     # print ("current VIH = $current_put_mv mV\n");
			 
	# # return the last drive level tested that resulted in a Pass
	# `hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  	
	# return $current_put_mv;
		 
		
		}
	}		
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  	
	return $current_put_mv;
	#`hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  
}

sub vilh_sweep_linear_vilh {

	my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# define current_vdd that will be used to start the linear search
    $current_put_mv = $limit_1 ;     #initial vil/vih value		
	# define limit (mV) to exit the binary search
	$pf_flag_coarse = 0;	
    $pf_flag_fine = 0;	

  
  if ($vil eq "tst") {	     # input low being tested	 VIL
		     `hpti 'FTST?'`;

	        %vilh_L= (
				"i3c_clk0_p"  => [4379,	6923,	8295,	10839,	13383],
				"i3c_data0_p" => [3105,	5649,	8293,	10837,	13381],
				"i3c_data1_p" => [4375,	6919,	8291,	10835,	13379],
				"i3c_clk1_p"  => [3101,	5645,	8289,	10833,	13377]
   			);

   			@comp=();

   			$comp[0] = $vilh_L{$put}[0];
   			$comp[1] = $vilh_L{$put}[1];
   			$comp[2] = $vilh_L{$put}[2];
   			$comp[3] = $vilh_L{$put}[3];
   			$comp[4] = $vilh_L{$put}[4];
	
	    while (($current_put_mv <= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv + 30 ; }#30mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {$current_put_mv = $current_put_mv + 5 ;} #5mv per step for fine search
	
			 
             `hpti 'DRLV $lvl,$current_put_mv,$vih,($put)'`; #set vil = current_put_mv
								 
             $pattern = `hpti 'SQSL?'`;
	         print "cfg pattern setting:  SQSL $pattern ,$sprm_val\n";
		     
			 $ret_val = `hpti 'FTST?'`;
			 print "FTST of $current_put_mv mv\n";
 		     @retval_array = split " ",$ret_val;
			 # print @retval_array;
			 
			 if ($retval_array[1] eq "F") {
			    #########################
				# Fist Fail Cycle logging
				#########################
		        $cmd = sprintf("SQGB acqf,0;");
		        `hpti '$cmd'`;
				$cmd = sprintf ("ercy? ALL,0,,%d,(%s);", $gCapSize,$gScan_port);
				$ercy = `hpti -9000000 '$cmd'`;

				@ercy_array=();
				#print "ercy_array = @ercy_array \n";
				@ercy_array=split("\n",$ercy);

				$pf_count=0;
				$ercy_log = "";
				@e=();
				foreach $e (@ercy_array){
				   # print "$e\n";
				   @e=split(",",$e);
				   #print "$e[1]\n";
				   if($e =~ /^\S+/ ){
    			   		$ercy_log = $ercy_log.",".$e[1];
   				    }

				   # print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
				   foreach $comp(@comp){
					   if ($e[1] eq $comp) {
						$pf_count++;
						print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
						print "match $comp pf_count=$pf_count\n";						
					   }
				   }

                }
				print "match $pf_count\n";

                if(($pf_count==5)&&($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search
                if(($pf_count==5)&&($pf_flag_coarse == 0))                       {$pf_flag_coarse = 1 ; $current_put_mv = $current_put_mv - 30 ;} # start fine search
 				
                #print ("vil_ercy_pf_flag_info: $pf_flag,$pf_count,$ercy_log\n");
             }
		}
	}
    else {            			# input high being tested VIH

	         `hpti 'FTST?'`;
			 %vilh_H= (
				"i3c_clk0_p"  => [3107,	5651,	9567,	12111],
				"i3c_data0_p" => [4377,	6921,	9565,	12109],
				"i3c_data1_p" => [3103,	5647,	9563,	12107],
				"i3c_clk1_p"  => [4373,	6917,	9561,	12105]
		    );


	        @comp=();

   			$comp[0] = $vilh_H{$put}[0];
   			$comp[1] = $vilh_H{$put}[1];
   			$comp[2] = $vilh_H{$put}[2];
   			$comp[3] = $vilh_H{$put}[3];
            $comp[4] = $vilh_H{$put}[4];

	
	    while (($current_put_mv >= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv - 30 ; }#30mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {$current_put_mv = $current_put_mv - 5 ;} #5mv per step for fine search

             `hpti 'DRLV $lvl,$vil,$current_put_mv,($put)'`; #set vih = current_put_mv
			 #`hpti 'SQSL "$vilh_pattern"'`;
			 #`hpti 'WAIT 10'`;		
	         #`hpti 'FTSM SET,3189,,'`;
			 
	         $pattern = `hpti 'SQSL?'`;
	         print "cfg pattern setting:  SQSL $pattern ,$sprm_val\n";
	
		     $ret_val = `hpti 'FTST?'`;
		     print "FTST of $current_put_mv mv\n";
   
																																						  
		    
		     @retval_array = split " ",$ret_val;
			 # print @retval_array;

             if ($retval_array[1] eq "F") {
	             #########################
				 # Fist Fail Cycle logging
				 #########################
		         $cmd = sprintf("SQGB acqf,0;");
		         `hpti '$cmd'`;
				 $cmd = sprintf ("ercy? ALL,0,,%d,(%s);", $gCapSize,$gScan_port);
				 $ercy = `hpti -9000000 '$cmd'`;
				 # print "ercy=$ercy \n";
			 

				 @ercy_array=();
				 # print "ercy_array = @ercy_array \n";
				 @ercy_array=split("\n",$ercy);

				 $pf_count=0;
				 $ercy_log = "";
				 @e=();
				 foreach $e (@ercy_array){
				    #print "$e\n";
				    @e=split(",",$e);
				    #Sprint "$e[1]\n";
				    if($e =~ /^\S+/ ){
    			   		$ercy_log = $ercy_log.",".$e[1];
   				    }

				    # print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
					foreach $comp(@comp){	
						# print "e[1]=$e[1],comp= $comp\n";
						if ($e[1] eq $comp) {
							$pf_count++;
							print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
							print "match $comp pf_count=$pf_count\n";
							
						}
					}
                }
				print "match $pf_count\n";
                 if(($pf_count==4)&&($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search         
   			     if(($pf_count==4)&&($pf_flag_coarse == 0))                       {$pf_flag_coarse = 1 ; $current_put_mv = $current_put_mv + 30 ;} # start fine search
                 

                 #print ("vih_ercy_pf_flag_info: $pf_flag,$pf_count,$ercy_log\n");

			 }	
				 
		     #print ("current VIH = $current_put_mv mV\n");
		
		}
	}		
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  	
	return $current_put_mv;

}




sub pin_forceV_measI {
	
	my($pin, $force_v, $pass_min, $pass_max, $curr_range) = @_;
	
	$force_mv = $force_v*1000;
	
	#`hpti 'DFCM 1,$force_mv,,,$pass_min,$pass_max,$curr_range,I,5,PPNP,($pin); MEAS 1,1;MEAS 1,2;MEAS 1,3;MEAS 1,4; RLYC PPMU,PMU,($pin); WAIT 1000'`;
	`hpti 'RLYC PPMU,PMU,($pin); DFCM 1,$force_mv,,,$pass_min,$pass_max,$curr_range,I,5,PPNP,($pin); MEAS 1,1;MEAS 1,2;  WAIT 3000'`;
	$ret_val = `hpti 'PMUR? VAL,FORCE_MEASURE,($pin)'`;

	print "DFCM 1,$force_mv,,,$pass_min,$pass_max,$curr_range,I,5,PPNP,($pin); MEAS 1,1;MEAS 1,2;MEAS 1,3;MEAS 1,4; RLYC PPMU,PMU,($pin); WAIT 1000\n";
	#print "$ret_val\n";
	
	@ret_array = split ",", $ret_val;
	$pin_i = $ret_array[2];
	print "$ret_array[0] + $ret_array[1]+$ret_array[2]+$ret_array[3].\n";
	print "When $pin is forced to $force_mv mV, current $pin_i uA is measured.\n";

	return $pin_i;
	

}
sub volh_sweep_binary {

	my($put, $limit_1, $limit_2, $vol, $voh) = @_;
	
	# initialize pass/fail boundary flag
	$pf_bnd_fnd = 0;
	# define current_vdd that will be used to start the binary search
	$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
	# define limit (mV) to exit the binary search
	$max_spread = 1;

	`hpti 'SREC x,(@)'`;
	`hpti 'SREC act,(tdo,$put)'`;	
		
	#print "volh: $limit_1, $limit_2, $vol, $voh\n";
	while ($pf_bnd_fnd == 0) {
		$current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
		# set pin under test to new V
		if ($vol eq "tst") {
			# input low being tested
			`hpti 'RCLV $lvl,$current_put_mv,$voh,($put)'`;
		}
		else {
			# input high being tested
			`hpti 'RCLV $lvl,$vol,$current_put_mv,($put)'`;
		}
		`hpti 'WAIT 50'`;		
		
		$ret_val = `hpti 'FTST?'`;
		@retval_array = split " ",$ret_val;

		#print ("test reported $retval_array[1] @ volh=$current_put_mv for $put; current test limits = $limit_1 mV and $limit_2 mV with Spread $spread mV\n");
		
		if ($retval_array[1] eq "F") {
			$limit_2 = $current_put_mv;
		}
		else {
			$limit_1 = $current_put_mv;
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

	`hpti 'UPTD VEC,1'`;
	
	# return the last drive level tested that resulted in a Pass
	return $limit_1;
	
}
sub iolh_volt_sweep_binary {
   
    my($vddo_v,$Vin_set,$put_i,$pat_cfg,$vdd_i3c,$ilimit,$meas) = @_;

	$pf_bnd_fnd = 0;	
	
	# SREC x,(@);
	# SREC act,(tdo, $put);
	`hpti 'SREC x,(@)'`;
	`hpti 'SREC act,($put_i)'`;	
	#print "iolh: $limit_1, $limit_2, $iol, $ioh\n";
	$Vt= $vdd_i3c*0.5*1000;	
	$loadCurrent = $ilimit*1000 ;
	if ($meas eq "IOH") {
		$Vsearch1 = $Vin_set*0.2 ; $Vsearch2 = $Vin_set*1.2 ;
		# output high being tested
	     `hpti 'TERM $lvl,A,$Vt,100,$loadCurrent,auto,auto,($put_i)'`;	
		 print ("set termination \n");
	}
	elsif ($meas eq "IOL") {
		$Vsearch2 = $Vin_set*0.8 ; $Vsearch1 = $Vin_set*1.8 ;
		# output low being tested
	     `hpti 'TERM $lvl,A,$Vt,$loadCurrent,100,auto,auto,($put_i)'`;		
	}
	
	
	while ($pf_bnd_fnd == 0) {
		
 	    if ($meas eq "IOH") { $current_put_mv = $Vsearch2 - (($Vsearch2 - $Vsearch1)/2); `hpti 'RCLV $lvl,100,$current_put_mv,($put_i)'`; print ("set RCLV \n");} # set pin under test to new mV to search IOH
        elsif($meas eq "IOL") { $current_put_mv = $Vsearch2 + (($Vsearch1 - $Vsearch2)/2); `hpti 'RCLV $lvl,$current_put_mv ,800,($put_i)'`;} # set pin under test to new mV to search IOL

	 	
		#`hpti 'RCLV $lvl,-1300,-750,($put_i)'`;
		
	    `hpti 'SQSL "i3c_transparency_D0_to_D1_$meas"'`;
		`hpti 'WAIT 500'`;		
		
		$ret_val = `hpti 'FTST?'`;
		@retval_array = split " ",$ret_val;

		print ("pat i3c_transparency_D0_to_D1_$meas, test reported $retval_array[1], @ Vsearch=$current_put_mv ; current test limits = $ilimit mA  with Spread $spread mV\n");

        if(@retval_array[1] eq "P"){ $Vsearch1 = $current_put_mv ;}
	    elsif (@retval_array[1] eq "F") {$Vsearch2 = $current_put_mv ;} 
		
		# ensure spread is always a positive number
		$spread = $Vsearch2 - $Vsearch1;
		# define limit (mV) to exit the binary search
	    $max_spread = $Vin_set * 0.005 ;
		if ($spread < 0) {$spread = -1 * $spread;}
		
		if ($spread <= $max_spread) {
			$pf_bnd_fnd = 1;
			#print ("final spread = $spread V\n");
		}
	}
	
	#UPTD VEC,1;
	#`hpti 'UPTD VEC,1'`;
	
	print "Search voltage = $current_put_mv \n";

	print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$vddo_v,vdd_i3c=$vdd_i3c,");
	print fh_iolh ("$put_i,SearchV=$current_put_mv mv,\n");
		
	
}
sub iolh {
	
	my($vddo_v,$Vin_set,$put_i,$pat_cfg,$mode,$vdd_i3c,$vddc,$parameter,$meas,$first_run) = @_;
	
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
     #if($debug > 0.5) { print "-- MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)\n"; }
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)'`;	
     #if($debug > 0.5) { print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n"; }
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put_i)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put_i)'`;
	`hpti 'MSET 1,DC,1,ACTI,3,,($put_i)'`; 
    if($first_run == 0){
	   `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	   `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	   `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	   `hpti 'MSET 1,DC,2,PPMU,0,ON,($put_i)'`;
	   `hpti 'MSET 1,DC,2,ACTI,1,,($put_i)'`;        
	}
	
	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	#`hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;
    if($first_run == 0){`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`; print "whole PMU measurement\n";}
	else { `hpti 'MEAS 1,1; MEAS 1,3'`; }
	
	`hpti 'MEAR VAL,5,($put_i)'`;
	#`hpti 'MEAR VMUM,10,($put_i)'`;

	$ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;
	#$ret_val_1 = `hpti 'PMUR? VMUM,($put_i)'`;
	if($debug > 0.5) { print "$ret_val_1 \n"; }
	
	@ret_array_1 = split ",", $ret_val_1;
	$meas_i =  @ret_array_1[2]/1000;
	#`hpti 'RLYC AC,OFF,($put_i)'`;		
	
	$meas_i = abs($meas_i);
	#$first_run=1;
	print "IOLH value for $put_i = $meas_i mA \n";

	print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
	print fh_iolh ("$put_i,$parameter,ForceV=$Vin_set mv,$meas_i mA\n");


}

sub vil {

	my($vddo_v,$put,$mode,$vdd_i3c,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg) = @_;

	print " -- vil: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";

	if (($pat_cfg eq "43")||($pat_cfg eq "44")||($pat_cfg eq "45")||($pat_cfg eq "46")) { $vil_val = &vilh_sweep_linear_vilh($put,500,1400,"tst",$init_vih_mv);}
    else {$vil_val = &vilh_sweep_linear_vilh($put,330,1400,"tst",$init_vih_mv);}

	print "VIL value for $put = $vil_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
	print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vil_val\n");
	
}
sub vih {

	my($vddo_v,$put,$mode,$vdd_i3c,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg) = @_;
	
	print " -- vih: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";
	
	
	if (($pat_cfg eq "43")||($pat_cfg eq "44")||($pat_cfg eq "45")||($pat_cfg eq "46")) { $vih_val = &vilh_sweep_linear_vilh($put,1260,400,$init_vil_mv,"tst");}
	else { $vih_val = &vilh_sweep_linear_vilh($put,900,200,$init_vil_mv,"tst");}
	
	
	print "VIH value for $put = $vih_val mV\n";
	
	print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
	print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vih_val\n");
	
}
sub sch_vil {

	my($vddo_v,$put,$mode,$vdd_i3c,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg,$mode,$vih_val) = @_;

	print " -- sch_vil: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";

	if (($pat_cfg eq "55")||($pat_cfg eq "56")||($pat_cfg eq "57")||($pat_cfg eq "58")) 
		{ 	$vil_val = &vilh_sweep_linear_vhyst($put,300,1200,"tst",$init_vih_mv,$pat_cfg,$mode);}
    else{	$vil_val = &vilh_sweep_linear_vhyst($put,300,1200,"tst",$init_vih_mv,$pat_cfg,$mode);}

	print "***** sch_VIL value for $put = $vil_val mV *****\n\n\n";
	$Vhyst=abs($vih_val-$vil_val);

	$cfg_number = int($pat_cfg);
	if ($cfg_number >53)
	{
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_sch_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vil_val\n");		
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_sch_vilh ("$put,Vhyst,$lo_limit,$hi_limit,$Vhyst\n");		
	}
	else
	{
		print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vil_val\n");		
	}	
}
sub sch_vih {

	my($vddo_v,$put,$mode,$vdd_i3c,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg,$mode) = @_;
	
	print " -- sch_vih: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";
	
	$vih_val = &vilh_sweep_linear_vhyst($put,1200,400,$init_vil_mv,"tst",$pat_cfg,$mode);
	
	print "***** sch_VIH value for $put = $vih_val mV *****\n\n\n";

	$cfg_number = int($pat_cfg);
	if ($cfg_number >53)
	{
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_sch_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vih_val\n");
	}
		else
	{
		print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
		print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vih_val\n");		
	}	
	return $vih_val;
}
sub i3c_leak {
    
	
    my($vddo_v,$Vin_set,$put_i,$mode,$vdd_i3c,$vddc,$parameter,$pat_cfg) = @_;
						
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,IRB,($put_i)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put_i)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put_i)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put_i)'`; 

	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($put_i)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($put_i)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,10,($put_i)'`;

	$ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;

	if($debug > 0.5) { print "$ret_val_1\n"; }
	
	@ret_array_1 = split ",", $ret_val_1;
	$meas_i = abs($ret_array_1[2]);

	print "measures value with $Vin_set mv for $put_i = $meas_i uA\n";

	`hpti 'RLYC AC,OFF,($put_i)'`;		
	
	
	print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_i3c,$vddc,");
	print fh_leak ("$put_i,$parameter,ForceV= $Vin_set mv,$meas_i uA\n");

}
sub calibrate_temp {
	
	my($cal_temp, $soak, $cal_location) = @_;
	print ("\n");
	print ("Setting temperature to $cal_temp C using a $si_therm silicon thermal...\n");
	chomp($cal_temp);
	$case_temp = `../set_si_temp.prl $cal_temp $soak $si_therm`;
	chomp($case_temp);
	print ("Case temperature set to $case_temp C...\n");
	chdir($PATH);
	$junction_temp = `../tdiode/pm8609_tdiode_93k.prl ext_meas b 10 0`;
	chomp($junction_temp);
	print ("Junction temperature is $junction_temp C...\n");
	
	if ($cal_location eq "case") {
		print ("Calibration location is set to Case -> Case temp = $case_temp C and Setpoint was $cal_temp C\n");
	}
	elsif ($cal_location eq "junction") {
		print ("Calibration location is set to Junction...Calibration is in progress...\n");
		$temp_delta = 0;
		$temp_delta = $cal_temp - $junction_temp;
		print ("Current delta is: $temp_delta\n");
		while (abs($temp_delta) > 1) {
			$temp_adjust = $case_temp + $temp_delta;
			print ("Temperature forcer needs to be adjusted to $temp_adjust C...\n");
			$case_temp = `../set_si_temp.prl $temp_adjust $soak $si_therm`;
			chomp($case_temp);
			print ("Case temperature set to $case_temp C...\n");
			chdir($PATH);
			$junction_temp = `../tdiode/pm8609_tdiode_93k.prl ext_meas b 10 0`;
			chomp($junction_temp);
			print ("Junction temperature is $junction_temp C...\n");
			$temp_delta = $cal_temp - $junction_temp;
			print ("Current delta is: $temp_delta\n");
		}
	}
	else {
		die "Incorrect calibration location selected -> (case/junction)\n";
	}
}
sub check_bsdl {
	$bsdl_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";

	`hpti '$bsdl_dataset'`;
	`hpti 'SQSL "$device_bsdl"'`;
		
	print "BSDL setting: SPRM $bsdl_wfs,$bsdl_tim,$bsdl_dps,$bsdl_lvl,\n -- SQSL $device_bsdl\n";

	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	print "BSDL $bsdl_val and result  $bsdlval_array[1]\n"; 
	if ($bsdlval_array[1] eq "P") {	print "BSDL ($device_bsdl) passes...\nBSDL ($device_bsdl) passes...\nBSDL ($device_bsdl) passes...\n";	}
	
	if ($bsdlval_array[1] eq "F") {
		
		#$errorcount = `hpti 'ERCT? EOLY,(@)'`;
		#print "errorcount: $errorcount\n ";
        $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		print "errorcount: $ec_val\n ";
	    @ec_array = split ",",$ec_val;
	
		#print "errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4],$ec_array[5]\n ";

        if ($ec_array[2] ne "0") {
		    `disconnect`;
		     die "BSDL vector fails at initial conditions - check socketing.\nBSDL vector fails at initial conditions - check socketing.\nBSDL vector fails at initial conditions - check socketing.\n";
   		}		
     	else {
		print "BSDL ($device_bsdl) passes...\nBSDL ($device_bsdl) passes...\nBSDL ($device_bsdl) passes...\n";
     	}
	}		
	
	`hpti 'SQSL "$device_vil"'`;
	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	print "BSDL $bsdl_val and result  $bsdlval_array[1]\n"; 	
	if ($bsdlval_array[1] eq "P") {	print "BSDL ($device_vil) passes...\nBSDL ($device_vil) passes...\nBSDL ($device_vil) passes...\n";	}
	
	
	if ($bsdlval_array[1] eq "F") {
		
		#$errorcount = `hpti 'ERCT? EOLY,(@)'`;
		#print "errorcount: $errorcount\n ";
        $ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		print "errorcount: $ec_val\n ";
	    @ec_array = split ",",$ec_val;
	
		#print "errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4],$ec_array[5]\n ";

        if ($ec_array[2] ne "0") {
		    `disconnect`;
		     die "BSDL HIZ vector fails at initial conditions - check socketing.\nBSDL HIZ vector fails at initial conditions - check socketing.\nBSDL HIZ vector fails at initial conditions - check socketing.\n";
   		}		
     	else {
		print "BSDL ($device_vil) passes...\nBSDL ($device_vil) passes...\nBSDL ($device_vil) passes...\n";
     	}
	}	
}
sub check_vil {
	$vil_dataset = "SPRM $bsdl_wfs,$tim,$lvl,$dps";

	`hpti '$vil_dataset'`;
	`hpti 'SQSL "$device_vil"'`; 
	
	print "VIL setting: SPRM $bsdl_wfs,$tim,$dps,$lvl\n -- SQSL $device_vil\n";

	$vil_val = `hpti 'FTST?'`;
	@vil_array = split " ",$vil_val;
	
	if ($vil_array[1] eq "F") {
		
		$ec_val = `hpti 'ERCT? EOLY,(jtag_tdo_p)'`;
		print "errorcount: $ec_val\n ";
	    @ec_array = split ",",$ec_val;
	
		print "errorcount: $ec_array[0],$ec_array[1],$ec_array[2],$ec_array[3],$ec_array[4],$ec_array[5]\n ";

        if ($ec_array[2] ne "0") {
		    `disconnect`;
		     die "VIL vector fails at initial conditions - check socketing.\n";
		}
	}
	else {
		print "VIL vector ($device_vil) passes...\n";
	}
}
sub create_time_file {
    my ($time_file_path, $subject) = @_;
    my $time = `date`;
    chomp($time);
	


    # Construct the content
    $content = $subject . "_" .$time;
	
	#print "content=$content";

    # Open file for writing
    open(my $fh, '>>', $time_file_path) or die "Cannot open file '$time_file_path' $!";

    # Write content to file
    print $fh $content ."\n";

    # Close file handle
    close($fh);

    print "Time File wrote successfully at $time_file_path.\n";
}

########################################################
# Main Section of Code

$rep = 1;
$current_count = 0;
$extended = 0;

# # test mode can be either typ/rep/pvt
$test_mode = $ARGV[0];

# # ensure all data inputs are present when script is called
$test_mode or die "input format -> pm35160_i3c_char.prl <test_mode={typ/rep/pvt}> \n";



print "Enter Temperature To Test: (0/25/85/105): \n";
$test_temp = <STDIN>;
chomp($test_temp);

# temperature forcer set to manual mode - no control via script
$si_therm = "NO";
@temp_C = ($test_temp);
$temp_soak = 0;

print "Enter Process Split: \n";
$split = <STDIN>;
chomp($split);
print "Enter Device Serial Number: \n";
$device = <STDIN>;
chomp($device);

print "Current test for: Split|$split / Device|$device / Test|$test_mode \n";

$subject="Start_I3C_Char" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;

create_time_file($time_file_path, $subject);


if (($test_mode eq "typ") || ($test_mode eq "rep")) {
	
	if ($test_mode eq "typ") {
		@vdd_pwr = ("typ_1v8","typ_1v2","typ_1v0");
#		@vdd_pwr = ("typ_1v8");		
		@vdd_leak_pwr = ("typ_1v8","typ_1v0");	

		
	}
	

	if ($test_mode eq "rep") {
	    @vdd_pwr = ("typ_1v8");	
		@vdd_leak_pwr = ("typ_1v8");			
	}
	
	@vilh_pwr_tst = (1.80);
	@volh_pwr_tst = (1.80);
	@iolh_pwr_tst = (1.80);
	
	if ($test_mode eq "rep") {
		print ("Enter number of iterations: \n");
		$rep = <STDIN>;
		chomp($rep);
	}
}
elsif ($test_mode eq "pvt") {
	
	@vdd_pwr = ("typ_1v8","typ_1v2","typ_1v0","min_1v8","min_1v2","min_1v0","max_1v8","max_1v2","max_1v0");		
	# @vdd_pwr = ("typ_1v0","min_1v0","max_1v0");		
	@vdd_leak_pwr = ("typ_1v8","typ_1v0","min_1v8","min_1v0","max_1v8","max_1v0");		
	# @vdd_leak_pwr = ("typ_1v0","min_1v0","max_1v0");	
	# @i3c_pwr_tst = (1.800,1.200,1.100);
	@iolh_pwr_tst = (1.800,1.200,1.000);
	@temp_C = ($test_temp);
	$temp_soak = 30;
}
else {
	die "Incorrect test mode selected -> typ/rep/pvt\n";
}

print ("Enter test to perform ( leak / vilh / sch_vilh / iolh / pupd / vilh_all / all / Rpupd_iv_curve): ");
$test = <STDIN>;
# $test="sch_vilh";
chomp($test);




if ($test eq "all") {
	print "All tests selected - (IO leakage, VILH, PVT Comp OD, PVT Comp pupd)\n";
	
	$datalog_file_vilh = "i3c_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";

	$datalog_file_sch_vilh = "i3c_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "sch_VILH Data will be written to -> $datalog_file_sch_vilh\n";

	$datalog_file_iolh = "i3c_iolh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_iolh, ">>$datalog_file_iolh";
	print "IOLH Data will be written to -> $datalog_file_iolh\n";
	
	$datalog_file_leak = "i3c_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_leak\n";
	
	$datalog_file_pupd = "i3c_pupd_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_pupd, ">>$datalog_file_pupd";
	print "PVT compensation pupd Data will be written to -> $datalog_file_pupd\n";
}
elsif ($test eq "vilh_all") {
	print "All VILH tests selected - ( VILH, Schmitt_VILH, IO Leakage test)\n";
	$datalog_file_vilh = "i3c_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";

	$datalog_file_sch_vilh = "i3c_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "sch_VILH Data will be written to -> $datalog_file_sch_vilh\n";
	
    $datalog_file_leak = "i3c_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";

}	
elsif ($test eq "leak") {
	print "IO Leakage test selected\n";
	$datalog_file_leak = "i3c_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";
}
elsif ($test eq "vilh") {
	print "VILH test selected\n";
	$datalog_file_vilh = "i3c_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";
}
elsif ($test eq "sch_vilh") {
	print "sch_VILH test selected\n";
	$datalog_file_sch_vilh = "i3c_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "VILH Data will be written to -> $datalog_file_sch_vilh\n";
}
elsif ($test eq "iolh") {
	print "IOLH test selected\n";
	$datalog_file_iolh = "i3c_iolh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_iolh, ">>$datalog_file_iolh";
	print "IOLH Data will be written to -> $datalog_file_iolh\n";
}
elsif (($test eq "pupd") || ($test eq  "Rpupd_iv_curve")) {
	print "PVT Compensated pupd test selected\n";
	$datalog_file_pupd = "i3c_pupd_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_pupd, ">>$datalog_file_pupd";
	print "PVT compensation pupd Data will be written to -> $datalog_file_pupd\n";
} 
else {
	die "Incorrect test selected ($test) -> (leak/vilh/sch_vilh/iolh/pupd/vilh_all/all/Rpupd_iv_curve))"
}

#ensure that the test starts at powerdown
`disconnect`;

print ("Initializing power supplies to Nominal setting.\n");
#ensure pwr supplies have been set to nominal values
foreach $supply_name (@supply_name_array) {
	print ("power: $dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n");
	`hpti 'PSLV $dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

# connect DPS to device
`connect`;

foreach $temp (@temp_C) {
	
	$current_count = 0;
	
	while ($current_count < $rep) {	

		if ($rep > 1) {print "\n**Current repeat count: $current_count\n";}
	

        if (($test eq "all") || ($test eq "sch_vilh") || ($test eq "vilh") || ($test eq "vilh_all")) {
			&check_bsdl;
			print "\n\nPerforming schmitt_VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";
# @vdd_pwr = ("typ_1v0");
		    foreach $vdd_v (@vdd_pwr) {
				if ($test eq "sch_vilh")
				{
					if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (55,57);&set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
					elsif (($vdd_v eq "typ_1v2")||($vdd_v eq "min_1v2")||($vdd_v eq "max_1v2")) { @pat_label = (59,61);&set_device_power($vdd_v, 0.1);$force_vih = 1200;}
					elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (63,65);&set_device_power($vdd_v, 0.1);$force_vih = 1100;}
					elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (63,65);&set_device_power($vdd_v, 0.1);$force_vih = 1000;}
				}
				elsif ($test eq "vilh")
				{
					if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (43,45);&set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
					elsif (($vdd_v eq "typ_1v2")||($vdd_v eq "min_1v2")||($vdd_v eq "max_1v2")) { @pat_label = (47,49);&set_device_power($vdd_v, 0.1);$force_vih = 1200;}
					elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (51,53);&set_device_power($vdd_v, 0.1);$force_vih = 1100;}
					elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (51,53);&set_device_power($vdd_v, 0.1);$force_vih = 1000;}
				}
				elsif (($test eq "all") || ($test eq "vilh_all"))
				{
					if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (43,45,55,57);&set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
					elsif (($vdd_v eq "typ_1v2")||($vdd_v eq "min_1v2")||($vdd_v eq "max_1v2")) { @pat_label = (47,49,59,61);&set_device_power($vdd_v, 0.1);$force_vih = 1200;}
					elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (51,53,63,65);&set_device_power($vdd_v, 0.1);$force_vih = 1100;}
					elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (51,53,63,65);&set_device_power($vdd_v, 0.1);$force_vih = 1000;}
				}
# @pat_label = (63);
				print "vdd_v setting:  $vdd_v\n"; 
            	foreach $pat_cfg (@pat_label) {		 

					`hpti '$sch_vilh_dataset'`;	
					print "$sch_vilh_dataset\n";
					`hpti 'SQSL "i3c_DC_cfg_$pat_cfg"'`; `hpti 'FTST?'`;
					print "-- i3c_DC_cfg_$pat_cfg\n";

				   
			    	$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
				
					$vdd_i3c = `hpti 'PSLV? ${dps},(vddo_i3c_0)'`;
                    @retval_array2 = split ",",$vdd_i3c;
					# print "vdd_core=$retval_array1[1],vdd_i3c=$retval_array2[1]\n";
					
				
			    	if (($pat_cfg eq "55")||($pat_cfg eq "56")) {$mode = GPIO18_mode;}
				    elsif (($pat_cfg eq "57")||($pat_cfg eq "58")) {$mode = I2C18_mode;}
				    elsif (($pat_cfg eq "59")||($pat_cfg eq "60")) {$mode = GPIO12_mode;}
				    elsif (($pat_cfg eq "61")||($pat_cfg eq "62")) {$mode = I2C12_mode;}
			    	elsif (($pat_cfg eq "63")||($pat_cfg eq "64")) {$mode = GPIO10_mode;}
				    elsif (($pat_cfg eq "65")||($pat_cfg eq "66")) {$mode = I2C10_mode;}

			    	if (($pat_cfg eq "43")||($pat_cfg eq "44"))    {$mode = GPIO18_mode;}
				    elsif (($pat_cfg eq "45")||($pat_cfg eq "46")) {$mode = I2C18_mode; }
				    elsif (($pat_cfg eq "47")||($pat_cfg eq "48")) {$mode = GPIO12_mode;}
				    elsif (($pat_cfg eq "49")||($pat_cfg eq "50")) {$mode = I2C12_mode; }
			    	elsif (($pat_cfg eq "51")||($pat_cfg eq "52")) {$mode = GPIO10_mode;}
				    elsif (($pat_cfg eq "53")||($pat_cfg eq "54")) {$mode = I2C10_mode; }
							
					my $cfg_number = int($pat_cfg);
					my $pat_cfg_execute=0;
					my $vih_val=0;
					my $vil_val=0;

					# Check if this cfg_number is odd
					if ($cfg_number % 2 != 0) {
						$pat_cfg_execute=1;
					} else {
						$pat_cfg_execute=0;
					}

			     	foreach $put (@i3c_put) {
						if ($pat_cfg_execute==1) {
							if ($cfg_number >53)
							{
								$vih_val=sch_vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VT+",0,$force_vih,$pat_cfg,$mode);
								&sch_vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VT-",0,$force_vih,$pat_cfg,$mode,$vih_val);

							}
							else
							{
								&sch_vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VIH",0,$force_vih,$pat_cfg,$mode);
								&sch_vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VIL",0,$force_vih,$pat_cfg,$mode,$vih_val);
							}
						}
				    }											
			    }
			}
		    `hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high
			$subject="Sch_VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}		

		
		if (($test eq "all") || ($test eq "iolh")) {
			print "\n\nPerforming IOLH testing on Split $split, Device $device @ Temperature $temp C ...\n";
			$first_run =0 ;	
			if ($test eq "all") {&check_vil;}
            foreach $vdd_v (@vdd_pwr) {
				if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (1,2,3,4,5,6,7,8,9,10,11,12,13,14);&set_device_power($vdd_v, 0.1);} 
				elsif (($vdd_v eq "typ_1v2")||($vdd_v eq "min_1v2")||($vdd_v eq "max_1v2")) { @pat_label = (15,16,17,18,19,20,21,22,23,24,25,26,27);&set_device_power($vdd_v, 0.1);}
				elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (28,29,30,31,32,33,34,35,36,37,38,39,40,41,42);&set_device_power($vdd_v, 0.1);}
				elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (28,29,30,31,32,33,34,35,36,37,38,39,40,41,42);&set_device_power($vdd_v, 0.1);}
				print "vdd_v setting:  $vdd_v\n";
            	foreach $pat_cfg (@pat_label) {		 

				   $cfg_dataset = "SPRM $atp_wfs,$atp_tim,$lvl,$dps";	   

				   `hpti '$cfg_dataset'`;	
				   `hpti 'SQSL "i3c_DC_cfg_$pat_cfg"'`;
				   

				   $FT_val = `hpti 'FTST?'`;
				   print "cfg pattern setting:  SQSL i3c_DC_cfg_$pat_cfg , $FT_val\n";
			 

 	               $vdd_core = `hpti 'PSLV? 6,(vdd_core)'`;
                   @retval_array1 = split ",",$vdd_core;
                   print ("vdd_core setting $retval_array1[1] \n");		
	
	
  	               $vdd_i3c = `hpti 'PSLV? 6,(vddo_i3c_0)'`;
                   @retval_array2 = split ",",$vdd_i3c;
                   print ("vdd_i3c setting $retval_array2[1] \n");		
				   
					   if (($pat_cfg eq "1")||($pat_cfg eq "3")||($pat_cfg eq "5")||($pat_cfg eq "7")){$force_vil = 1800;$force_vih = 1800; $pmu_vin = ($retval_array2[1]-0.4)*1000; $meas = IOH;}                                 #GPIO18_mode ioh
			    	   elsif (($pat_cfg eq "2")||($pat_cfg eq "4")||($pat_cfg eq "6")||($pat_cfg eq "8")){$force_vil = 0;$force_vih = 0; $pmu_vin = 400; $meas = IOL;}                                    #GPIO18_mode iol
					   elsif (($pat_cfg eq "9")){$force_vil = 1800;$force_vih =1800; $pmu_vin = ($retval_array2[1]-0.27)*1000; $meas = IOH;}                                                                                        #I3CPP18_mode ioh    
					   elsif (($pat_cfg eq "10")||($pat_cfg eq "11")){$force_vil = 0;$force_vih = 0; $pmu_vin = 270; $meas = IOL;}                                                                        #I3CPP18_mode,I3COD18_mode iol
					   elsif (($pat_cfg eq "12")||($pat_cfg eq "13")||($pat_cfg eq "14")){$force_vil = 0;$force_vih = 0; $pmu_vin = $retval_array2[1]*0.2*1000; $meas = IOL;}
					   elsif (($pat_cfg eq "15")||($pat_cfg eq "17")||($pat_cfg eq "19")||($pat_cfg eq "21")){$force_vil = 1200;$force_vih = 1200; $pmu_vin = $retval_array2[1]*0.8*1000; $meas = IOH;}    #GPIO12_mode ioh
				       elsif (($pat_cfg eq "16")||($pat_cfg eq "18")||($pat_cfg eq "20")||($pat_cfg eq "22")){$force_vil = 0;$force_vih = 0; $pmu_vin = $retval_array2[1]*0.2*1000; $meas = IOL;}          #GPIO12_mode iol
					   elsif (($pat_cfg eq "23")){$force_vil = 1200;$force_vih =1200; $pmu_vin = ($retval_array2[1]-0.18)*1000; $meas = IOH;}                                                                                       #I3CPP12_mode ioh   
					   elsif (($pat_cfg eq "24")||($pat_cfg eq "25")){$force_vil = 0;$force_vih = 0; $pmu_vin = 180; $meas = IOL;}                                                                        #I3CPP12_mode,I3COD12_mode iol
					   elsif (($pat_cfg eq "26")||($pat_cfg eq "27")){$force_vil = 0;$force_vih = 0; $pmu_vin = $retval_array2[1]*0.2*1000; $meas = IOL;}
					   elsif (($pat_cfg eq "28")||($pat_cfg eq "30")||($pat_cfg eq "32")||($pat_cfg eq "34")){$force_vil = 1000;$force_vih = 1000; $pmu_vin = $retval_array2[1]*0.8*1000; $meas = IOH;}    #GPIO10_mode ioh
				       elsif (($pat_cfg eq "29")||($pat_cfg eq "31")||($pat_cfg eq "33")||($pat_cfg eq "35")){$force_vil = 0;$force_vih = 0; $pmu_vin = $retval_array2[1]*0.2*1000; $meas = IOL;}          #GPIO10_mode iol
					   elsif (($pat_cfg eq "36")){$force_vil = 1000;$force_vih =1000; $pmu_vin = ($retval_array2[1]-0.18)*1000; $meas = IOH;}                                                                                       #I3CPP10_mode ioh 					   
					   elsif (($pat_cfg eq "37")||($pat_cfg eq "38")||($pat_cfg eq "39")){$force_vil = 0;$force_vih = 0; $pmu_vin = 180; $meas = IOL;}                                                    #I3CPP10_mode,I3COD10_mode,I3COD10HL_mode iol
					   elsif (($pat_cfg eq "40")||($pat_cfg eq "41")||($pat_cfg eq "42")){$force_vil = 0;$force_vih = 0; $pmu_vin = $retval_array2[1]*0.2*1000; $meas = IOL;}                                    
	

                       if (($pat_cfg eq "1")||($pat_cfg eq "2")||($pat_cfg eq "3")||($pat_cfg eq "4")||($pat_cfg eq "5")||($pat_cfg eq "6")||($pat_cfg eq "7")||($pat_cfg eq "8")){$mode = GPIO18_mode ;}                                
			    	   elsif (($pat_cfg eq "9")||($pat_cfg eq "10")){$mode = I3CPP18_mode;}                                    
			    	   elsif (($pat_cfg eq "11")){$mode = I3COD18_mode;}                                    
					   elsif (($pat_cfg eq "12")||($pat_cfg eq "13")){$mode = I2CFM18_mode;}      
			    	   elsif (($pat_cfg eq "14")){$mode = I2CFM18_mode;}                                    
					   elsif (($pat_cfg eq "15")||($pat_cfg eq "16")||($pat_cfg eq "17")||($pat_cfg eq "18")||($pat_cfg eq "19")||($pat_cfg eq "20")||($pat_cfg eq "21")||($pat_cfg eq "22")){$mode = GPIO12_mode ;}   
    		    	   elsif (($pat_cfg eq "23")||($pat_cfg eq "24")){$mode = I3CPP12_mode;}                                    
			    	   elsif (($pat_cfg eq "25")){$mode = I3COD12_mode;}                                    
					   elsif (($pat_cfg eq "26")||($pat_cfg eq "27")){$mode = I2CSM12_mode;}      
					   elsif (($pat_cfg eq "28")||($pat_cfg eq "29")||($pat_cfg eq "30")||($pat_cfg eq "31")||($pat_cfg eq "32")||($pat_cfg eq "33")||($pat_cfg eq "34")||($pat_cfg eq "35")){$mode = GPIO10_mode ;}   
    		    	   elsif (($pat_cfg eq "36")||($pat_cfg eq "37")){$mode = I3CPP10_mode;}                                    
			    	   elsif (($pat_cfg eq "38")){$mode = I3COD10_mode;}                                    
			    	   elsif (($pat_cfg eq "39")){$mode = I3COD10HL_mode;}                                    
					   elsif (($pat_cfg eq "40")||($pat_cfg eq "41")){$mode = I2CSM10_mode;}      
			    	   elsif (($pat_cfg eq "42")){$mode = I2CFM10_mode;}                                    
	 		    	   
	                   
					   `hpti 'DRLV $lvl,$force_vil,$force_vih,(i3c_data0_p)'`;
				       `hpti 'SQSL "$iolh_pattern"'`;
					   $FTST_val = `hpti 'FTST?'`;
		
					   print ("IOLH first_run $first_run \n");	
					   #print "IOLH setting: meas = $meas\n";					   
					   &iolh($vdd_v,$pmu_vin,"i3c_data1_p",$pat_cfg,$mode,$retval_array2[1],$retval_array1[1],$meas,$first_run);
					   $first_run = 1;
			   
	                   print ("IOLH_volt first_run $first_run \n");	
					   
				       &iolh_volt_meas($vdd_v,"i3c_data1_p",$pat_cfg,$mode,$retval_array2[1],$retval_array1[1],@iolh_MaxSpec_array[$pat_cfg],"$meas at max current",$first_run);   #max expected current		
				       &iolh_volt_meas($vdd_v,"i3c_data1_p",$pat_cfg,$mode,$retval_array2[1],$retval_array1[1],@iolh_MinSpec_array[$pat_cfg],"$meas at min current",$first_run);   #min expected current		
					  
				}
			}				
			`hpti 'RLYC AC,OFF,(i3c_data1_p)'`;	
			$subject="IOLH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
		create_time_file($time_file_path, $subject);
		}		

		if (($test eq "all") || ($test eq "pupd")|| ($test eq "Rpupd_iv_curve")) {
			if ($test eq "all") {&check_vil;}
			print "\n\nPerforming PVT Compensated pupd testing on Split $split, Device $device @ Temperature $temp C ...\n";
			$pupd_dataset = "SPRM $atp_wfs,$atp_tim,$lvl,$dps";
			`hpti '$pupd_dataset'`;	
			

				foreach $vdd_v (@vdd_leak_pwr) {
					if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (69,70,71,72,73,74,75,81,82);&set_device_power($vdd_v, 0.1);} 
					elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (76,77,78,79,80,83,84);&set_device_power($vdd_v, 0.1);}
					elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (76,77,78,79,80,83,84);&set_device_power($vdd_v, 0.1);}


					$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
					@retval_array1 = split ",",$vdd_core;
					print ("\nvdd_core setting $retval_array1[1] \n");
					$vdd_i3c = `hpti 'PSLV? ${dps},(vddo_i3c_0)'`;
					@retval_array2 = split ",",$vdd_i3c;
					print ("vdd_i3c setting $retval_array2[1] \n");

					
					
					if ($test eq "Rpupd_iv_curve")
					{			
						print "iv_curve enable..\n";
						@vdd_leak_pwr = ("typ_1v8","typ_1v0");
						

						for (my $i3c_scan_V = 0.05; $i3c_scan_V <= 1.82; $i3c_scan_V += 0.05) {
							
							@I3C_supply_name_array = ("vddo_i3c_1","vddo_i3c_0");
												
							foreach $supply_name (@I3C_supply_name_array) {
								# print ("power: $dps,$i3c_scan_V,$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n");
								`hpti 'PSLV $dps,$i3c_scan_V,$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
							}
							
							$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
							@retval_array1 = split ",",$vdd_core;
							print ("\nvdd_core setting $retval_array1[1] \n");
							$vdd_i3c = `hpti 'PSLV? ${dps},(vddo_i3c_0)'`;
							@retval_array2 = split ",",$vdd_i3c;
							print ("vdd_i3c setting $retval_array2[1] \n");
						
						
						
							foreach $pat_cfg (@pat_label) 
							{	
													

								`hpti 'SQSL "i3c_DC_cfg_${pat_cfg}"'`;

								$FTST_val = `hpti 'FTST?'`;
								
								print "cfg pattern setting:  SQSL i3c_DC_cfg_$pat_cfg \n";


								if (($pat_cfg eq "69")||($pat_cfg eq "70")) {$term_v=0;$mode = pullup18_mode;$parameter = Rpu;}
								elsif (($pat_cfg eq "71")) {$term_v=0;$mode = hk18_mode;$parameter = Rpu;}
								elsif (($pat_cfg eq "72")||($pat_cfg eq "73")||($pat_cfg eq "74")||($pat_cfg eq "75")){$term_v=0;$mode = i3crp18_mode;$parameter = Rpu;}
								elsif (($pat_cfg eq "76")||($pat_cfg eq "77")){$term_v=0;$mode = pullup10_mode;$parameter = Rpu;}
								elsif (($pat_cfg eq "78")){$term_v=0;$mode = hk10_mode;$parameter = Rpu;}
								elsif (($pat_cfg eq "79")||($pat_cfg eq "80")) {$term_v=0;$mode = i3crp10_mode;$parameter= Rpu;}
								elsif (($pat_cfg eq "81")||($pat_cfg eq "82")) {$term_v=1800;$mode = pulldown18_mode;$parameter= Rpd;}
								elsif (($pat_cfg eq "83")||($pat_cfg eq "84")) {$term_v=1000;$mode = pulldown10_mode;$parameter= Rpd;}
								$run_all_pat=1;
								if ($run_all_pat==0 ) 
								{
									if (($pat_cfg eq "70")||($pat_cfg eq "71")||($pat_cfg eq "77")||($pat_cfg eq "78")||($pat_cfg eq "84")) 
									{									
										foreach $put (@i3c_put) 
										{	&PUPD_I($vdd_v,$term_v,$put,"atb[0]",$mode,$retval_array2[1],$retval_array1[1],$parameter,"IRD",$pat_cfg);
										}
									}
								}
								else
								{
									foreach $put (@i3c_put) 
									{	&PUPD_I($vdd_v,$term_v,$put,"atb[0]",$mode,$retval_array2[1],$retval_array1[1],$parameter,"IRD",$pat_cfg);
									}
								}
							}
						}
						
						
				}
				else{
						$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
						@retval_array1 = split ",",$vdd_core;
						print ("\nvdd_core $retval_array1[1] \n");
						$vdd_i3c = `hpti 'PSLV? ${dps},(vddo_i3c_0)'`;
						@retval_array2 = split ",",$vdd_i3c;
						print ("vdd_i3c setting $retval_array2[1] \n");
					
						foreach $pat_cfg (@pat_label) {
							`hpti 'SQSL "i3c_DC_cfg_${pat_cfg}"'`;
							$FTST_val = `hpti 'FTST?'`;
							print "cfg pattern setting:  SQSL i3c_DC_cfg_$pat_cfg , $FTST_val\n";

							if (($pat_cfg eq "69")||($pat_cfg eq "70")) {$term_v=0;$mode = pullup18_mode;$parameter = Rpu;}
							elsif (($pat_cfg eq "71")) {$term_v=0;$mode = hk18_mode;$parameter = Rpu;}
							elsif (($pat_cfg eq "72")||($pat_cfg eq "73")||($pat_cfg eq "74")||($pat_cfg eq "75")){$term_v=0;$mode = i3crp18_mode;$parameter = Rpu;}
							elsif (($pat_cfg eq "76")||($pat_cfg eq "77")){$term_v=0;$mode = pullup10_mode;$parameter = Rpu;}
							elsif (($pat_cfg eq "78")){$term_v=0;$mode = hk10_mode;$parameter = Rpu;}
							elsif (($pat_cfg eq "79")||($pat_cfg eq "80")) {$term_v=0;$mode = i3crp10_mode;$parameter= Rpu;}
							elsif (($pat_cfg eq "81")||($pat_cfg eq "82")) {$term_v=1800;$mode = pulldown18_mode;$parameter= Rpd;}
							elsif (($pat_cfg eq "83")||($pat_cfg eq "84")) {$term_v=1000;$mode = pulldown10_mode;$parameter= Rpd;}
				 
							foreach $put (@i3c_put)
							{	&PUPD_I($vdd_v,$term_v,$put,"atb[0]",$mode,$retval_array2[1],$retval_array1[1],$parameter,"IRD",$pat_cfg);
								# &PUPD_I($vdd_v,$term_v,$put,"atb[0]",$mode,$retval_array2[1],$retval_array1[1],$parameter,"IRD",$pat_cfg);
							} 
						}
				}
			}

			
			
			
			`hpti 'RLYC AC,OFF,($put)'`;  			
			$subject="PUPD_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);	
		}
		
		if (($test eq "all") || ($test eq "leak")) {
			if ($test eq "all") {&check_vil;}
			
			$leak_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$lvl,$dps";
			`hpti '$leak_dataset'`;	
			
			print "\n\nPerforming IO leakage testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    foreach $vdd_v (@vdd_leak_pwr) {
				if		(($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (67);&set_device_power($vdd_v, 0.1);$mode = disable18_mode;} 
				elsif	(($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (68);&set_device_power($vdd_v, 0.1);$mode = disable10_mode;}
				elsif	(($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (68);&set_device_power($vdd_v, 0.1);$mode = disable10_mode;}
			
				
                foreach $pat_cfg (@pat_label) {	
			        
                    if ($pat_cfg eq "68") {
						`hpti 'SQSL "pm35160_bsdl_reva_cfg67_TAP_UDR_SAMPLE_HIZ_TAP_UDR_SAMPLE_HIZ"'`;	#cfg68
					}  #new cfg for disable10_mode					
 		            else { 
						`hpti 'SQSL "pm35160_bsdl_reva_cfg68_TAP_UDR_SAMPLE_HIZ_TAP_UDR_SAMPLE_HIZ"'`;	#cfg67
					}
				    $FT_val = `hpti 'FTST?'`;
					
    				$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
                    #print ("vdd_i3c setting $retval_array1[1] \n");
				
				$vdd_i3c = `hpti 'PSLV? ${dps},(vddo_i3c_0)'`;
                    @retval_array2 = split ",",$vdd_i3c;
					$force_leak_hi=@retval_array2[1]*1000; #set measured pins' voltage are same to vddo_i3c_0
					$force_leak_hi_3v63=3630;
 		            $force_leak_lo = 0;   
                    foreach $put (@i3c_all_put) {	
					   print "force volt setting:  leak_hi $force_leak_hi , leak_lo $force_leak_lo , $put\n";
					   &i3c_leak($vdd_v,$force_leak_hi,$put,$mode,@retval_array2[1],@retval_array1[1],IIH,$pat_cfg);
					   &i3c_leak($vdd_v,$force_leak_lo,$put,$mode,@retval_array2[1],@retval_array1[1],IIL,$pat_cfg);					   
					   if ($pat_cfg eq "68") { &i3c_leak($vdd_v,$force_leak_hi_3v63,$put,$mode,@retval_array2[1],@retval_array1[1],IIH_3p63,$pat_cfg);	}
				    }	
                } 					
			}
			$subject="Leakage_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}
	    $current_count++;

		
		if (($test eq "all_bypass") || ($test eq "vilh_bypass") || ($test eq "vilh_all_bypass")) {
			
			print "\n\nPerforming VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    foreach $vdd_v (@vdd_pwr) {
				if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (43,44,45,46);&set_device_power($vdd_v, 0.1); $force_vih = 1800;} 
				elsif (($vdd_v eq "typ_1v2")||($vdd_v eq "min_1v2")||($vdd_v eq "max_1v2")) { @pat_label = (47,48,49,50);&set_device_power($vdd_v, 0.1); $force_vih = 1200;}
				elsif (($vdd_v eq "typ_1v1")||($vdd_v eq "min_1v1")||($vdd_v eq "max_1v1")) { @pat_label = (51,52,53,54);&set_device_power($vdd_v, 0.1); $force_vih = 1100;}
				elsif (($vdd_v eq "typ_1v0")||($vdd_v eq "min_1v0")||($vdd_v eq "max_1v0")) { @pat_label = (51,52,53,54);&set_device_power($vdd_v, 0.1); $force_vih = 1000;}
			    #`hpti 'PSLV 6,1.8,1,LOZ,15,(vdd_i3c_1)'`; #set vddc_i3c_1 as 1.8 for RX test (VIL/H)
				print "vdd_v setting:  $vdd_v\n";
				
            	foreach $pat_cfg (@pat_label) {		 
								   

				   &check_bsdl;	

				   $bsdl_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";
			       `hpti '$bsdl_dataset'`;	
				   print "bsdl setting SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps\n";
				   # `hpti 'SQSL "pm35160_bsdl_revb_UDR_UDR"'`; `hpti 'FTST?'`;
				   # print "SQSL pm35160_bsdl_revb_UDR_UDR as pre-condition\n";


				
			    	$vdd_core = `hpti 'PSLV? 6,(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
                    print ("vdd_core setting $retval_array1[1] \n");
				
				    $vdd_i3c = `hpti 'PSLV? 6,(vddo_i3c_0)'`;
                    @retval_array2 = split ",",$vdd_i3c;
                    print ("vddo_i3c_0 setting $retval_array2[1] \n");
				
			    	if (($pat_cfg eq "43")||($pat_cfg eq "44")) 	{$mode = GPIO18_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg43_DC_DC"'`; `hpti 'FTST?'`;}
				    elsif (($pat_cfg eq "45")||($pat_cfg eq "46"))	{$mode = I2C18_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg45_DC_DC"'`; `hpti 'FTST?'`;}
				    elsif (($pat_cfg eq "47")||($pat_cfg eq "48"))	{$mode = GPIO12_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg47_cfg51_DC_DC"'`; `hpti 'FTST?'`;}
				    elsif (($pat_cfg eq "49")||($pat_cfg eq "50"))	{$mode = I2C12_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg49_cfg53_DC_DC"'`; `hpti 'FTST?'`;}
			    	elsif (($pat_cfg eq "51")||($pat_cfg eq "52"))	{$mode = GPIO10_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg47_cfg51_DC_DC"'`; `hpti 'FTST?'`;}
				    elsif (($pat_cfg eq "53")||($pat_cfg eq "54"))	{$mode = I2C10_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg49_cfg53_DC_DC"'`; `hpti 'FTST?'`;}
				

			        foreach $put (@i3c_all_put) {
					   if (($pat_cfg eq "43")||($pat_cfg eq "45")||($pat_cfg eq "47")||($pat_cfg eq "49")||($pat_cfg eq "51")||($pat_cfg eq "53"))		{	&vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],VIH,0,$force_vih,$pat_cfg);}
				       elsif (($pat_cfg eq "44")||($pat_cfg eq "46")||($pat_cfg eq "48")||($pat_cfg eq "50")||($pat_cfg eq "52")||($pat_cfg eq "54"))	{	&vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],VIL,0,$force_vih,$pat_cfg);}
			        }											
			    }
			}
		    `hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  

			$subject="VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}					
	}
}
	

# reinit the DPS supplies to nominal
foreach $supply_name (@supply_name_array) {
	`hpti 'PSLV $dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

#powerdown the device
`disconnect`;
			# $c_subject='"Current repeat count:"' . $current_count;
			$subject="*** All_tests_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);

if ($test eq "all") {
	close fh_leak;
	close fh_vilh;
	close fh_sch_vilh;
	close fh_iolh;
	close fh_pupd;
}
elsif ($test eq "vilh_all") {
	close fh_vilh;
	close fh_sch_vilh;
	close fh_leak;
}
elsif ($test eq "leak") {
	close fh_leak;
}
elsif ($test eq "vilh") {
	close fh_vilh;
}
elsif ($test eq "sch_vilh") {
	close fh_sch_vilh;
}
elsif ($test eq "iolh") {
	close fh_iolh;
}
elsif ($test eq "pupd") {
	close fh_pupd;
}
else {
}

print "***Test Completed Successfully!  Device powered down and can be removed.***\n";

if ($si_therm ne "NO") {
	print ("Setting temperature to 25 C using a $si_therm silicon thermal...\n");
	`../set_si_temp.prl 25 1 $si_therm`;
}
exit;

