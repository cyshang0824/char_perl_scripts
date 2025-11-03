#!/usr/local/bin/perl

########################################################
# CY SHANG (Feb. 2025) - Titan lvds characterization
# Characterization tests supported - input Power On Leakage, input Current Balance, Differential DC Hysteresis


$date = `date`;
@date_array = split " ",$date;
$hostname = `hostname`;
@hostname_array = split ".",$hostname;
$hostname=$hostname_array[0];
chomp($hostname);
$si_therm_default="WIN";

my @pc_mes=();
my @pt_mes=();
use File::Basename; # Provides the 'dirname' function for path manipulation
use Cwd 'abs_path'; # Imports the 'abs_path' function from the Cwd module to get absolute paths
# Get the script's own name (may include a relative path)
my $script_name_with_path = $0;

# Get the directory where the script is located
# abs_path($script_name_with_path) converts the potentially relative path from $0 into an absolute path.
# dirname() then extracts the directory part from that absolute path.
my $script_directory = dirname(abs_path($script_name_with_path));
print "Directory of the current script: $script_directory\n";


$PATH = $script_directory . "/";
my $time_file_path = $PATH . "time_file_${date_array[1]}${date_array[2]}.txt";

# my $subject="$hostname\_test123";

# create_time_file($time_file_path, $subject);
# exit;


$gCapSize = 100000;
$gScan_port = "jtag_tdo_p";


$debug = 0 ;


$bsdl_wfs = 1;
$bsdl_tim = 1;
$bsdl_lvl = 3;
$bsdl_dps = 6;

# vectors to use for bsdl contact check
$bsdl_pattern = "pm35160_bsdl_reva_DC_DC";
$bsdl_HIZ_pattern = "pm35160_bsdl_reva_HIZ_HIZ";
$bsdl_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";





# vector to use for io leakage
# $device_io_leak = "lvds_PO_leakage";

# @iolh_MaxSpec_array = (3.541,7.03,13.46,25.26,30.37);					  
# @iolh_MinSpec_array = (1.967,3.849,7.514,14.49,17.71);	
	  

#class definition for all the possible pins that will be tested either in typ/rep/pvt modes
%lvds_pin_class = (
	"clk_pt"			=>	"lvds18_rx_noterm_ns_SP",
	"clk_pc"			=>	"lvds18_rx_noterm_ns_SP",
	"pe1_refclk_pt"		=>	"lvds18_rx_noterm_ns_SP",
	"pe1_refclk_pc"		=>	"lvds18_rx_noterm_ns_SP",
	"pe0_refclk_pt"		=>	"lvds18_rx_noterm_ns_SP",
	"pe0_refclk_pc"		=>	"lvds18_rx_noterm_ns_SP",
);


# power supply settings
%typ_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"vddo_gpio_s"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
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


%min_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"vddo_gpio_s"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.715,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.71,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.8,	
	"vddo_i3c_1"		=> 1.8,			
);

%max_1v8_supply = (
	"vddo_gpio_n"		=> 1.8,
	"vddo_gpio_s"		=> 1.8,
	"avdh_pcie_vph"	 	=> 1.2,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.753,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.89,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.8,	
	"vddo_i3c_1"		=> 1.8,		
);




%max_0v_supply = (
	"vddo_gpio_n"		=> 0,
	"vddo_gpio_s"		=> 0,
	"avdh_pcie_vph"	 	=> 1.2,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.753,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.8,	
	"vddo_i3c_1"		=> 1.8,		
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


@lvds_put_N = ("clk_pc",	"pe1_refclk_pc");
@lvds_put_P = ("clk_pt",	"pe1_refclk_pt");
# @lvds_put_N = (	"pe1_refclk_pc","clk_pc");
# @lvds_put_P = (	"pe1_refclk_pt","clk_pt");

########################################################
sub set_device_power {
	

	my($vdd_0, $wait_time) = @_;
    
	print ("\n\nPower supplies setting: $vdd_0 ...\n");
	
	if ($vdd_0 eq "off") {  
		$vdd = 0.0; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("off power ($vdd): $bsdl_dps,$off_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$off_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v8") {  
		$vdd = 1.8; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v8. power ($vdd): $bsdl_dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	
	elsif ($vdd_0 eq "min_1v8") {  
		$vdd = 1.71;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v8. power ($vdd): $bsdl_dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v8") {  
		$vdd = 1.89;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v8. power ($vdd): $bsdl_dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v2") {  
		$vdd = 1.2; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v2. power ($vdd): $bsdl_dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	
	elsif ($vdd_0 eq "min_1v2") {  
		$vdd = 1.14;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v2. power ($vdd): $bsdl_dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v2") {  
		$vdd = 1.26;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v2. power ($vdd): $bsdl_dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v0") {  
		$vdd = 1.0; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v0. power ($vdd): $bsdl_dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "min_1v0") {  
		$vdd = 0.95;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v0. power ($vdd): $bsdl_dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v0") {  
		$vdd = 1.1;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v0. power ($vdd): $bsdl_dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_0v") {  
		$vdd = 0.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_0v. power ($vdd): $bsdl_dps,$max_0v_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $bsdl_dps,$max_0v_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}		
	# wait for device to stablize
	if($debug > 0.5) { print ("Power supplies connected to device, waiting $wait_time seconds before starting test...\n"); }
	sleep ($wait_time);

return $vdd;
}

sub power_reset {

# connect DPS to device
`disconnect`;
	
print ("Initializing power supplies to Nominal setting.\n");
#ensure pwr supplies have been set to nominal values
foreach $supply_name (@supply_name_array) {

print ("power: $bsdl_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n");

	`hpti 'PSLV $bsdl_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

# connect DPS to device
`connect`;

# wait for device to stablize
$stable_time = 5;
print ("Power supplies connected to device, waiting $stable_time seconds before starting test...\n");
sleep ($stable_time);

}

sub lvds_vhyst_sweep_linear {

	my($put_P,$put_N, $limit_H, $limit_L, $mode) = @_;
	
	# define current_vdd that will be used to start the linear search
	print "\$limit_H=$limit_H, \$limit_L=$limit_L\n";

	# define limit (mV) to exit the binary search
	$pf_flag_coarse = 0;	
    $pf_flag_fine = 0;	
	$back_coarse_volt = 0;	# pass over vhyst 
 	$coarse_P_volt = 0;	    # coarse P voltage 
	$coarse_N_volt = 0;	    # coarse N voltage 
	$coarse_step=5;
	$fine_step=1;
	$offline_trial=0;
	$ercy_string="";
	print "\$mode=$mode\n";

  if ($mode eq "P_vil") {	     # input low being tested	 VIL
			print "-- P_vil\n";	
			$current_put_n_mv = $limit_H ;     #initial vil/vih value		
			$current_put_p_mv = $limit_L;     #initial vil/vih value	
			print "\$current_put_p_mv=$current_put_p_mv, \$current_put_n_mv=$current_put_n_mv\n";		
			
			`hpti 'SQSL "$bsdl_pattern"'`;			
			print "--- bsdl_DC_pattern is loaded! ---\n";
	
	    while (($current_put_p_mv <= $limit_H) && ($pf_flag_fine == 0))    #when completing fine search then stop
		{ 
			 if (($pf_flag_coarse == 0)) {$current_put_p_mv = $current_put_p_mv + $coarse_step;	$current_put_n_mv = $current_put_n_mv - $coarse_step;}#5mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {print "***** start pf_flag_fine search *****\n";$current_put_p_mv = $current_put_p_mv + $fine_step; $current_put_n_mv = $current_put_n_mv - $fine_step;} #1mv per step for fine search

			if ($current_put_p_mv > $limit_H || $current_put_n_mv < $limit_L) {
				last; # Exit the while loop
			}

			`hpti 'DRLV $bsdl_lvl,$current_put_p_mv,$limit_H,($put_P)'`;
			`hpti 'DRLV $bsdl_lvl,$limit_L,$current_put_n_mv,($put_N)'`;

			print "P_VIL DRLV $bsdl_lvl,$current_put_p_mv,$limit_H,(\$put_P=$put_P)\n";
			print "P_VIL DRLV $bsdl_lvl,$limit_L,$current_put_n_mv,(\$put_N=$put_N)\n";
			$ercy_string="";
			`hpti 'WAIT 200'`;	 
			$ret_val = `hpti 'FTST?'`;
			$ercy_string=`hpti 'ERCY? ALL,0,,1,(jtag_tdo_p)'`;
			if (($offline_trial==1) && ( (($current_put_p_mv >= 70)&& ($current_put_p_mv < 73)) || (($current_put_p_mv >= 975)&& ($current_put_p_mv < 978)) || (($current_put_p_mv >= 2370)&& ($current_put_p_mv < 2374)) )) { $ret_val="FTST F";	} #trial in offline03.
			if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_p_mv = $coarse_P_volt - $coarse_step ; $current_put_n_mv = $coarse_N_volt + $coarse_step ;$back_coarse_volt = 1;} #back the voltage of coarse search

			@retval_array = split " ",$ret_val;
			print "FTST=$retval_array[1]..$retval_array[1]..$retval_array[1]\n\n";
			if ($ercy_string =~/jtag_tdo_p/)  {
				print "failed $ercy_string\n";
                if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search
                if($pf_flag_coarse == 0)                         {$pf_flag_coarse = 1 ; $coarse_P_volt = $current_put_p_mv; $coarse_N_volt = $current_put_n_mv; $current_put_p_mv = $limit_L ;$current_put_n_mv = $limit_H ; } # start fine search

             }
		}
	}
    else {            			# input high being tested VIH

        print "-- P_vih\n";
		$current_put_p_mv = $limit_H ;     #initial vil/vih value		
		$current_put_n_mv = $limit_L;     #initial vil/vih value	
		print "\$current_put_p_mv=$current_put_p_mv, \$current_put_n_mv=$current_put_n_mv\n";		
			 
			`hpti 'SQSL "$bsdl_pattern"'`;			
			print "--- bsdl_DC_pattern is loaded! ---\n";

	    while (($current_put_p_mv >= $limit_L) && ($pf_flag_fine == 0)) #when completing fine search then stop
		{
			if (($pf_flag_coarse == 0)) {$current_put_p_mv  = $current_put_p_mv  - $coarse_step; $current_put_n_mv  = $current_put_n_mv  + $coarse_step;}#5mv per step for coarse search
			if (($pf_flag_coarse == 1)) {print "***** start pf_flag_fine search *****\n";$current_put_p_mv  = $current_put_p_mv  - $fine_step ; $current_put_n_mv  = $current_put_n_mv + $fine_step;	} #1mv per step for fine search
			
			if ($current_put_p_mv < $limit_L || $current_put_n_mv > $limit_H) {
				last; # Exit the while loop
			}
	
			`hpti 'DRLV $bsdl_lvl,$limit_L,$current_put_p_mv,($put_P)'`;
			`hpti 'DRLV $bsdl_lvl,$current_put_n_mv,$limit_H,($put_N)'`;

			print "P_VIH DRLV $bsdl_lvl,$limit_L,$current_put_p_mv,(\$put_P=$put_P)\n";
			print "P_VIH DRLV $bsdl_lvl,$current_put_n_mv,$limit_H,(\$put_N=$put_N)\n";
			$ercy_string="";
			`hpti 'WAIT 200'`;	 
			$ret_val = `hpti 'FTST?'`;
			$ercy_string=`hpti 'ERCY? ALL,0,,1,(jtag_tdo_p)'`;
			chomp($ret_val);
			if (($offline_trial==1) && ( (($current_put_p_mv < 43)&& ($current_put_p_mv >= 40)) || (($current_put_p_mv < 942) && ($current_put_p_mv >= 940)) || (($current_put_p_mv < 2353) && ($current_put_p_mv >= 2350)) )) { $ret_val="FTST F";	} #trial in offline03.
			if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_p_mv = $coarse_P_volt + $coarse_step ; $current_put_n_mv = $coarse_N_volt - $coarse_step ; $back_coarse_volt = 1;} #back the voltage of coarse search
			@retval_array = split " ",$ret_val;
			print "FTST=$retval_array[1]..$retval_array[1]..$retval_array[1]\n\n";
			if ($ercy_string =~/jtag_tdo_p/) 
			{
				print "failed $ercy_string\n";
				if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search         
				if($pf_flag_coarse == 0)                         {$pf_flag_coarse = 1 ; $coarse_P_volt = $current_put_p_mv; $coarse_N_volt = $current_put_n_mv; $current_put_p_mv = $limit_H; $current_put_n_mv = $limit_L;	} # start fine search $current_put_p_mv = $limit_H ;
			}	
	
		}
	}		
	# return the last drive level tested that resulted in a Pass
	`hpti 'DRLV $bsdl_lvl,0,1890,($put_P)'`; #restore initial drive low/high  	
	`hpti 'DRLV $bsdl_lvl,0,1890,($put_N)'`; #restore initial drive low/high 	
	return $current_put_p_mv,$current_put_n_mv;

}


sub lvds_P_vil {

	my($vddo_v,$put_P,$put_N,$vddc,$parameter,$init_vil_mv,$init_vih_mv) = @_;
	
	print " -- lvds_P_vil: $vddo_v,$put_P sweep from $init_vil_mv to $init_vih_mv\n";
	print " -- lvds_P_vil: $vddo_v,$put_N sweep from $init_vih_mv to $init_vil_mv\n";


	($P_vil_val,$N_vih_val) = &lvds_vhyst_sweep_linear($put_P,$put_N,$init_vih_mv,$init_vil_mv,"P_vil");
	
	print "***** P_vil value for $put_P = $P_vil_val mV *****\n";
	print "***** N_vih value for $put_N = $N_vih_val mV *****\n";
	$Vhyst=abs($P_vil_val-$N_vih_val);
	print "\n\n\$Vhyst=$Vhyst\n\n";
	print fh_lvds_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$vddc,");
	print fh_lvds_vilh ("$put_P,$put_N,$parameter,$P_vil_val,$N_vih_val,$Vhyst\n");	

}
sub lvds_P_vih {

	my($vddo_v,$put_P,$put_N,$vddc,$parameter,$init_vil_mv,$init_vih_mv) = @_;
	
	print " -- lvds_P_vih: $vddo_v,$put_P sweep from $init_vih_mv to $init_vil_mv\n";
	print " -- lvds_P_vih: $vddo_v,$put_N sweep from $init_vil_mv to $init_vih_mv\n";

	($P_vih_val,$N_vil_val) = &lvds_vhyst_sweep_linear($put_P,$put_N,$init_vih_mv,$init_vil_mv,"P_vih");

	print "***** P_vih value for $put_P = $P_vih_val mV *****\n";
	print "***** N_vil value for $put_N = $N_vil_val mV *****\n";
	$Vhyst=abs($P_vih_val-$N_vil_val);
	print "\n\n\$Vhyst=$Vhyst\n\n";

	print fh_lvds_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$vddc,");
	print fh_lvds_vilh ("$put_P,$put_N,$parameter,$P_vih_val,$N_vil_val,$Vhyst\n");

}

sub lvds_PO_leak {
    #debug IIL,,,IIH pass
	
	
    ($vddo_v,$Vin_set,$put,$put_all_fixed,$mode,$vddc,$parameter,$leak_cfg,$Irang) = @_;

print "put_all_fixed=$put_all_fixed\n";

	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$Irang,($put)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put)'`; 

	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_all_fixed)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$Irang,($put_all_fixed)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,1200,($put_all_fixed)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put_all_fixed)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put_all_fixed)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put_all_fixed)'`;	
	
	
	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($put,$put_all_fixed)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($put,$put_all_fixed)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,I,($put,$put_all_fixed)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,10,($put)'`;
	
	
	$ret_val_string = `hpti 'PMUR? VAL,($put)'`;
	&leak_return_val_datalog($ret_val_string,$Vin_set,$vddc);
	
}




sub leak_return_val_datalog{
	($ret_val_string,$Vin_set,$vddc) = @_;
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

				foreach $put (@temp_array) 
				{
					$meas_i=$measure_value_string;
					$meas_i=abs($meas_i);
					print "$put  -> $Vin_set mv for $meas_i uA\n";
					print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$temp,$leak_cfg,$mode,$vddc,");
					print fh_leak ("$put,$parameter,$Vin_set,$meas_i\n");
				}
			}
			else
			{			# major run here
				$put=$pin_name_string;
				$meas_i=$measure_value_string;
				$meas_i=abs($meas_i);
				print "$put  -> $Vin_set mv for $meas_i uA\n";
				print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$temp,$leak_cfg,$mode,$vddc,");
				print fh_leak ("$put,$parameter,$Vin_set,$meas_i\n");
			}
		}

	}	
}



sub lvds_Curr_Bal {
    ($vddo_v,$Vin_set,$put_P,$put_N,$mode,$vddc,$parameter,$leak_cfg,$Irang) = @_;


	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put_P,$put_N)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$Irang,($put_P,$put_N)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put_P,$put_N)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put_P,$put_N)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put_P,$put_N)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put_P,$put_N)'`; 



	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($put_P,$put_N)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($put_P,$put_N)'`;


	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,I,($put_P,$put_N)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,10,($put_P,$put_N)'`;
	

	$ret_val_string = `hpti 'PMUR? VAL,($put_P,$put_N)'`;
# exit;	
	$put_pt_index=0;
	$put_pc_index=0;
	@pc_mes=();
	@pt_mes=();
	@pc_pin_name=();
	@pt_pin_name=();
	&lvds_Curr_Bal_val_datalog($ret_val_string,$Vin_set,$vddc);

}



sub lvds_Curr_Bal_val_datalog{
	($ret_val_string,$Vin_set,$vddc) = @_;

	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line)
	{
		if ($line_string ne "") {
			# print "line_string=$line_string\n";

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
			if ($pin_name_string =~/,/) # offline 
			{	@temp_array=();
				@temp_array=split (/\,/,$pin_name_string);

				foreach $put (@temp_array) 
				{
					$meas_i=$measure_value_string;
					$meas_i=abs($meas_i);
					print "$put  -> $Vin_set mv for $meas_i uA\n";
									#Pin_P go first then Pin_N ---> pt go first then pc
					if ($put=~/pt/) { @pt_mes[$put_pt_index]=$meas_i;	$put_pt_index++;}
					if ($put=~/pc/) { @pc_mes[$put_pc_index]=$meas_i;	$put_pc_index++;}
					

					if ($put=~/pc/) { 
						$Now_put_pc_index=$put_pc_index-1;
						$Current_diff= int(abs(@pc_mes[$Now_put_pc_index]-@pt_mes[$Now_put_pc_index])*1000)/1000;
						print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg,$mode,$vddc,");
						print fh_Curr_Bal ("@pt_pin_name[$Now_put_pc_index],$parameter,$Vin_set,@pt_mes[$Now_put_pc_index]\n");								
						print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg_cfg,$mode,$vddc,");
						print fh_Curr_Bal ("$put,$parameter,$Vin_set,$meas_i\n");							
						print "pt_mes[$Now_put_pc_index]=@pt_mes[$Now_put_pc_index]\npc_mes[$Now_put_pc_index]=@pc_mes[$Now_put_pc_index]\nCurrent_diff= $Current_diff \n";
						print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg,Current_diff,$vddc,");
						print fh_Curr_Bal ("$put,$parameter,$Vin_set,$Current_diff\n");
					}
				}
			}
			else
			{			# on line major run here
				$put=$pin_name_string;
				$meas_i=$measure_value_string;
				$meas_i=abs($meas_i);
				print "$put  -> $Vin_set mv for $meas_i uA\n";
				#Pin_P go first then Pin_N ---> pt go first then pc
				if ($put=~/pt/) { @pt_mes[$put_pt_index]=$meas_i;	@pt_pin_name[$put_pt_index]=$put;	$put_pt_index++;}
				if ($put=~/pc/) { @pc_mes[$put_pc_index]=$meas_i;	@pc_pin_name[$put_pc_index]=$put;	$put_pc_index++;}
			

				if ($put=~/pc/) { 
					$Now_put_pc_index=$put_pc_index-1;
					$Current_diff= int(abs(@pc_mes[$Now_put_pc_index]-@pt_mes[$Now_put_pc_index])*1000)/1000;
					print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg,$mode,$vddc,");
					print fh_Curr_Bal ("@pt_pin_name[$Now_put_pc_index],$parameter,$Vin_set,@pt_mes[$Now_put_pc_index]\n");					
					print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg,$mode,$vddc,");
					print fh_Curr_Bal ("$put,$parameter,$Vin_set,$meas_i\n");

					print "pt_mes[$Now_put_pc_index]=@pt_mes[$Now_put_pc_index]\npc_mes[$Now_put_pc_index]=@pc_mes[$Now_put_pc_index]\nCurrent_diff= $Current_diff \n";
					print fh_Curr_Bal ("$current_count,$rep,$split,$device,$test_mode,$temp,$Curr_Bal_cfg,Current_diff,$vddc,");
					print fh_Curr_Bal ("$put,$parameter,$Vin_set,$Current_diff\n");
				}
			}
		}
	}	
}


sub start_from_current_temp{
	$current_temp=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/read_temp_auto\.prl  $si_therm`;
	if (abs($current_temp-20)<5) 		
	{	@temp_C=(-3,108); 
#		@temp_C=(25,-1,108); #start from 25C
	} 
	elsif (abs($current_temp-108)<30)	{	@temp_C=(108,-3);	}
	elsif (abs($current_temp+3)<30)		{	@temp_C=(-3,108);	}

}	



sub set_temp {
	
	my($cal_temp, $soak) = @_;
	print ("\n");
	print ("Setting temperature to $cal_temp C using a $si_therm silicon thermal...\n");
	chomp($cal_temp);
	print "cal_temp $cal_temp C\n";

	$current_temp=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/read_temp_auto\.prl  $si_therm`;
	chomp($current_temp);
	
	print "current temp=$current_temp\n";
	$temp_diff=abs($cal_temp-$current_temp);
    print "temp diff =$temp_diff C\n";

	if ($temp_diff > 20)
	{
		print "start to set temp to $cal_temp C\n";
		$set_temp=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_temp_auto\.prl $cal_temp $soak $si_therm`;
		chomp($set_temp);
		print " \n -- temp ready at $set_temp C \n";
		print " \n -- temp ready at $set_temp C \n";
		print " \n -- temp ready at $set_temp C \n";
	}	
	else
	{ print "temperature very close .... no need set temp again...\n";	}

}


sub check_bsdl {
	`hpti '$bsdl_dataset'`;
	print "BSDL setting: SPRM $bsdl_dataset\n";

	`hpti 'SQSL "$bsdl_HIZ_pattern"'`; 
	print "SQSL $bsdl_HIZ_pattern\n";

	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	print "BSDL $bsdl_val and result  $bsdlval_array[1]\n"; 
	if ($bsdlval_array[1] eq "P") {	print "BSDL ($bsdl_pattern) passes...\nBSDL ($bsdl_pattern) passes...\nBSDL ($bsdl_pattern) passes...\n";	}
	
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
		print "BSDL ($bsdl_pattern) passes...\nBSDL ($bsdl_pattern) passes...\nBSDL ($bsdl_pattern) passes...\n";
     	}
	}		
	
	`hpti 'SQSL "$bsdl_HIZ_pattern"'`;
	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	print "BSDL $bsdl_val and result  $bsdlval_array[1]\n"; 	
	if ($bsdlval_array[1] eq "P") {	print "BSDL ($bsdl_HIZ_pattern) passes...\nBSDL ($bsdl_HIZ_pattern) passes...\nBSDL ($bsdl_HIZ_pattern) passes...\n";	}
	
	
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
		print "BSDL ($bsdl_HIZ_pattern) passes...\nBSDL ($bsdl_HIZ_pattern) passes...\nBSDL ($bsdl_HIZ_pattern) passes...\n";
     	}
	}	
}
sub check_contact_HIZ {

	`hpti '$bsdl_dataset'`;
	print "BSDL setting: SPRM $bsdl_dataset\n";

	`hpti 'SQSL "$bsdl_HIZ_pattern"'`; 
	print "SQSL $bsdl_HIZ_pattern\n";
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
		print "VIL vector ($bsdl_HIZ_pattern) passes...\n";
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

    print "Time File wrote successfully at $time_file_path\n";
}

########################################################
# Main Section of Code

$rep = 1;
$current_count = 0;
$extended = 0;

# # test mode can be either typ/rep/pvt
$test_mode = $ARGV[0];

# # ensure all data inputs are present when script is called
$test_mode or die "input format -> pm35160_lvds_char.prl <test_mode={typ/rep/pvt}> \n";




# use ATC control
print "Enter Temperature Forcer Type: (WIN/ST/NO): \n";
$si_therm = <STDIN>;
chomp($si_therm);
$si_therm=uc($si_therm);
if ($si_therm eq "") { $si_therm = $si_therm_default;	print "default ATC controller set to $si_therm\n";}
if ($si_therm ne "NO") 
{
    # Automatically get hostname
    my $hostname = `hostname`;
    chomp($hostname);

    #print "Hostname: $hostname\n";

    # Determine tester_name based on hostname
    if ($hostname =~ /^v3\.microsemi\.net$/i) {
        $tester_name = "v3";
    } elsif ($hostname =~ /^v4\.eng\.microchip\.com$/i) {
        $tester_name = "v4";		
    } elsif ($hostname =~ /^v5\.eng\.microchip\.com$/i) {
        $tester_name = "v5";
    } else {
        # If hostname does not match, prompt user to enter manually
        print "Hostname does not match v3, v4, or v5. Please enter tester (v3/v4/v5):\n";
        $tester_name = <STDIN>;
        chomp($tester_name);
    }

    print "Tester Name: $tester_name\n"; # Output the obtained tester_name
} 
else 
{
    # If si_therm is "NO", skip any operation
    print "si_therm is Manual, skipping tester name detection.\n";
	#temperature no control
	print "Enter Temperature To Test: (0/25/85/105): \n";
	$test_temp = <STDIN>;
	chomp($test_temp);
	#temperature forcer set to manual mode - no control via script
	$si_therm = "NO";
	@temp_C = ($test_temp);
	$temp_soak = 0;
}

print "Enter Process Split: \n";
$split = <STDIN>;
chomp($split);
print "Enter Device Serial Number: \n";
$device = <STDIN>;
chomp($device);

print "Current test for: Split|$split / Device|$device / Test|$test_mode \n";

$subject="$hostname\_Start_lvds_Char" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;

create_time_file($time_file_path, $subject);

if ($si_therm ne "NO") {
	@temp_C = (-3,108); #remove 25C
	&start_from_current_temp;
	# print "\n temp will run 0C,105C\n";
}
$temp_soak = 10;

if (($test_mode eq "typ") || ($test_mode eq "rep")) {
	
	if ($test_mode eq "typ") {
		@vdd_pwr = ("typ_1v8");	
	}
	

	if ($test_mode eq "rep") {
	    @vdd_pwr = ("typ_1v8");	
		
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
	
	@vdd_pwr = ("typ_1v8","min_1v8","max_1v8");		
	
	@iolh_pwr_tst = (1.800);
}
else {
	die "Incorrect test mode selected -> typ/rep/pvt\n";
}

print ("Enter test to perform ( 1. all / 2. leak / 3. Curr_Bal / 4. lvds_vilh): ");
$test = <STDIN>;
# $test="lvds_vilh";
chomp($test);
if ($test eq "1") { $test="all";}
if ($test eq "2") { $test="leak";}
if ($test eq "3") { $test="Curr_Bal";}
if ($test eq "4") { $test="lvds_vilh";}

print '$test='. "$test\n";



if ($test eq "all") {
	print "All tests selected!!\n";
		
	$datalog_file_lvds_vilh = "lvds_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_lvds_vilh, ">>$datalog_file_lvds_vilh";
	print "LVDS VILH Data will be written to -> $datalog_file_lvds_vilh\n";
	
	$datalog_file_leak = "lvds_PO_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_leak\n";
	
	$datalog_file_Curr_Bal = "lvds_Curr_Bal_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_Curr_Bal, ">>$datalog_file_Curr_Bal";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_Curr_Bal\n";	
}

elsif ($test eq "leak") {
	print "IO Leakage test selected\n";
	$datalog_file_leak = "lvds_PO_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";
}
elsif ($test eq "Curr_Bal") {
	print "Current Balance test selected\n";
	$datalog_file_Curr_Bal = "lvds_Curr_Bal_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_Curr_Bal, ">>$datalog_file_Curr_Bal";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_Curr_Bal\n";	
}
elsif ($test eq "lvds_vilh") {
	print "lvds_VILH test selected\n";
	$datalog_file_lvds_vilh = "lvds_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_lvds_vilh, ">>$datalog_file_lvds_vilh";
	print "LVDS VILH Data will be written to -> $datalog_file_lvds_vilh\n";
}
else {
	die "Incorrect test selected ($test) -> (leak / Curr_Bal / lvds_vilh / all))"
}

#ensure that the test starts at powerdown
`disconnect`;

print ("Initializing power supplies to Nominal setting.\n");
#ensure pwr supplies have been set to nominal values
foreach $supply_name (@supply_name_array) {
	print ("power: $bsdl_dps,$typ_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n");
	`hpti 'PSLV $bsdl_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

# connect DPS to device
`connect`;

foreach $temp (@temp_C)
{
	print "Now start from $temp\n";

	$current_count = 0;
	# Set and Calibrate Temperature of case if temperature forcer available
	if ($si_therm ne "NO") {
		&set_temp($temp,$temp_soak);
	}

	
	
	while ($current_count < $rep)
	{	

		if ($rep > 1) {print "\n**Current repeat count: $current_count\n";}

        if (($test eq "all") || ($test eq "lvds_vilh") )
		{
			
			&power_reset;
			print "\n\nPerforming lvds_VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";

			foreach $vdd_v (@vdd_pwr) 
			{

				if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { &set_device_power($vdd_v, 0.1);} 

				print "vdd_v setting:  $vdd_v\n"; 

				`hpti '$bsdl_dataset'`;	
				print "BSDL setting: SPRM $bsdl_dataset\n";
				`hpti 'SQSL "$bsdl_pattern"'`; 
				print "SQSL $bsdl_pattern\n";
				
				$vdd_core = `hpti 'PSLV? ${bsdl_dps},(vdd_core)'`;
				@retval_array1 = split ",",$vdd_core;

				$put_P="pe1_refclk_pt";$put_N="pe1_refclk_pc";
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",0,100);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",0,100);
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",900,1000);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",900,1000);
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",2300,2400);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",2300,2400);



				$put_P="clk_pt";$put_N="clk_pc";
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",0,100);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",0,100);
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",900,1000);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",900,1000);
				$P_vih_vhyst=lvds_P_vih($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIH_N_VIL",2300,2400);				
				$P_vil_vhyst=lvds_P_vil($vdd_v,$put_P,$put_N,$retval_array1[1],"P_VIL_N_VIH",2300,2400);
				
				
			}
			
			`hpti 'DRLV $bsdl_lvl,0,1890,($put_P)'`; #restore initial drive low/high
			`hpti 'DRLV $bsdl_lvl,0,1890,($put_N)'`; #restore initial drive low/high

			$subject="$hostname\_lvds_VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}		
		$current_count++;
		

		if (($test eq "all") || ($test eq "leak"))
		{
			# if ($test eq "all") {&check_contact_HIZ;}

			`hpti '$bsdl_dataset'`;	
			print "BSDL setting: SPRM $bsdl_dataset\n";	
			
			print "\n\nPerforming IO leakage testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    foreach $vdd_v (@vdd_pwr) {
		
				if		(($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @leak_label = ("1v8");&set_device_power($vdd_v, 0.1);} 
				# elsif	($vdd_v eq "max_0v") { @leak_label = ("0v");&set_device_power($vdd_v, 0.1);$mode = "Fail-safe_mode";}
				
                foreach $leak_cfg (@leak_label) {	

					

					`hpti 'SQSL "$bsdl_HIZ_pattern"'`;
					print "SQSL $bsdl_HIZ_pattern\n";
				
				    
					$FT_val = `hpti 'FTST?'`;`hpti 'WAIT 500'`;
					
    				$vdd_core = `hpti 'PSLV? ${bsdl_dps},(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
                    print ("vdd_core setting $retval_array1[1]\n");
				

					$put_all=join(",",@lvds_put_P);
					$put_all_fixed=join(",",@lvds_put_N);
					$force_leak_hi=0;		$mode="Fixed1V2_Mea0V";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],0,$leak_cfg,"IRB");
					$force_leak_hi=1200;	$mode="Fixed1V2_Mea1V2";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],1200,$leak_cfg,"IRB");
					$force_leak_hi=2400;	$mode="Fixed1V2_Mea2V4";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],2400,$leak_cfg,"IRB");

					$put_all=join(",",@lvds_put_N);
					$put_all_fixed=join(",",@lvds_put_P);

					$force_leak_hi=0;		$mode="Fixed1V2_Mea0V";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],0,$leak_cfg,"IRB");
					$force_leak_hi=1200;	$mode="Fixed1V2_Mea1V2";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],1200,$leak_cfg,"IRB");
					$force_leak_hi=2400;	$mode="Fixed1V2_Mea2V4";
					&lvds_PO_leak($vdd_v,$force_leak_hi,$put_all,$put_all_fixed,$mode,@retval_array1[1],2400,$leak_cfg,"IRB");
		
				
					# &lvds_PO_leak($vdd_v,$force_leak_hi_3v63,$put_all,$mode,@retval_array2[1],@retval_array1[1],IIH_3p63,$leak_cfg,"IRB");
					`hpti 'RLYC AC,OFF,($put_all)'`; 
                } 					
			}
			$subject="$hostname\_Leakage_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}
	    $current_count++;

		
		if (($test eq "all") || ($test eq "Curr_Bal"))
		{

			`hpti '$bsdl_dataset'`;
			print "BSDL setting: SPRM $bsdl_dataset\n";

			
			print "\n\nPerforming IO Current Balance testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    foreach $vdd_v (@vdd_pwr) {
		
				if		(($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @Curr_Bal_label = ("1v8");&set_device_power($vdd_v, 0.1);} 
				# elsif	($vdd_v eq "max_0v") { @Curr_Bal_label = ("0v");&set_device_power($vdd_v, 0.1);$mode = "Fail-safe_mode";}
				
                foreach $Curr_Bal_cfg (@Curr_Bal_label) {	

					
                    if ($Curr_Bal_cfg eq "1v8") 
					{
						`hpti 'SQSL "$bsdl_HIZ_pattern"'`;
					} 				
				    
					$FT_val = `hpti 'FTST?'`;`hpti 'WAIT 500'`;
					
    				$vdd_core = `hpti 'PSLV? ${bsdl_dps},(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
                    print ("vdd_core setting $retval_array1[1]\n");
				

					$put_P=join(",",@lvds_put_P);
					$put_N=join(",",@lvds_put_N);
					$force_Curr_Bal_hi=0;		$mode="PN_0V";
					&lvds_Curr_Bal($vdd_v,$force_Curr_Bal_hi,$put_P,$put_N,$mode,@retval_array1[1],0,$Curr_Bal_cfg,"IRB");
					$force_Curr_Bal_hi=1200;	$mode="PN_1V2";
					&lvds_Curr_Bal($vdd_v,$force_Curr_Bal_hi,$put_P,$put_N,$mode,@retval_array1[1],1200,$Curr_Bal_cfg,"IRB");
					$force_Curr_Bal_hi=2400;	$mode="PN_2V4";
					&lvds_Curr_Bal($vdd_v,$force_Curr_Bal_hi,$put_P,$put_N,$mode,@retval_array1[1],2400,$Curr_Bal_cfg,"IRB");

					`hpti 'RLYC AC,OFF,($put_all)'`; 
                } 					
			}
			$subject="$hostname\_Curr_Bal_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}
	    $current_count++;		

	



				
	}
}
	

# reinit the DPS supplies to nominal
foreach $supply_name (@supply_name_array) {
	`hpti 'PSLV $bsdl_dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

#powerdown the device
`disconnect`;
			# $c_subject='"Current repeat count:"' . $current_count;


if ($test eq "all") {
	close fh_leak;
	close fh_Curr_Bal;
	close fh_vilh;
	close fh_lvds_vilh;
	close fh_iolh;
	close fh_volh;
	close fh_pupd;
}
elsif ($test eq "vilh_all") {
	close fh_vilh;
	close fh_lvds_vilh;
}
elsif ($test eq "leak") {
	close fh_leak;
}
elsif ($test eq "Curr_Bal") {
	close fh_Curr_Bal;
}
elsif ($test eq "vilh") {
	close fh_vilh;
}
elsif ($test eq "lvds_vilh") {
	close fh_lvds_vilh;
}
elsif ($test eq "iolh") {
	close fh_iolh;
	close fh_volh;
}
elsif ($test eq "pupd") {
	close fh_pupd;
}
else {
}
#return to first temp_C
# if (($test_mode eq "pvt") && ($si_therm ne "NO"))
# {
	# print "\nReturn temp to $temp_C[0]C\n";
	# print "/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_$tester_name\_p0.prl $temp_C[0] 10 $si_therm\n";
	# `/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_$tester_name\_p0.prl $temp_C[0] 10 $si_therm`;
# }
print "***Test Completed Successfully!  Device powered down and can be removed.***\n";

$subject="$hostname\_*** All_tests_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode . "\n";
create_time_file($time_file_path, $subject);

exit;

# sub iolh_sweep_binary {
    
	# my($vddo_v,$Vin_set,$put_i,$pat_cfg,$ilimit,$meas) = @_;
	
	# # initialize pass/fail boundary flag
	# $pf_bnd_fnd = 0;

	# # define loop count 10 times to exit the binary search
	# $loop = 0;
	
  	# if ($meas eq "IOH") { $Vsearch1 = $Vin_set*0.5 ; $Vsearch2 = $Vin_set ; $iL = -$ilimit*1000; $iH = -100; print "iL= $iL\n";} # set pin under test to new mV to search IOH
	# elsif($meas eq "IOL") { $Vsearch2 = $Vin_set ; $Vsearch1 = $Vin_set*1.5 ;  $iL = 100; $iH = $ilimit*1000; print "iH= $iH\n";} # set pin under test to new mV to search IOL
	
	# while ($pf_bnd_fnd == 0) {
		
	   # if ($meas eq "IOH") { $current_put_mv = $Vsearch2 - (($Vsearch2 - $Vsearch1)/2); } # set pin under test to new mV to search IOH
       # elsif($meas eq "IOL") { $current_put_mv = $Vsearch2 + (($Vsearch1 - $Vsearch2)/2);} # set pin under test to new mV to search IOL
	
	
	   # `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	   # `hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	   # `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	   # `hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
       # `hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
       # #if($debug > 0.5) { print "-- MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)\n"; }
	   # `hpti 'MSET 1,DC,1,UFOR,2,$current_put_mv,($put_i)'`;	
       # #if($debug > 0.5) { print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n"; }
	   # `hpti 'MSET 1,DC,1,PMUL,3,$iL,($put_i)'`;
	   # `hpti 'MSET 1,DC,1,PMUH,4,$iH,($put_i)'`;
	   # `hpti 'MSET 1,DC,1,ACTI,5,,($put_i)'`; 

	   # `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	   # `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	   # `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	   # `hpti 'MSET 1,DC,2,PPMU,0,ON,($put_i)'`;
	   # `hpti 'MSET 1,DC,2,ACTI,1,,($put_i)'`;

	   # `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	   # `hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	   # `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	   # `hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;

	   # `hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	   # #`hpti 'MEAR VAL,10,($put_i)'`;
	   # #`hpti 'MEAR VMUM,10,($put_i)'`;

	   # $ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;
	   	 
	   # if($debug > 0.5) { print "$ret_val_1\n"; }
	
	   # @ret_array_1 = split " ", $ret_val_1;
	   
	   # @ret_array_2 = split ",", @ret_array_1[1];

	
       # if(@ret_array_2[0] eq "P"){ $Vsearch2 = $current_put_mv ;}
	   # elsif (@ret_array_2[0] eq "F") {$Vsearch1 = $current_put_mv ;} 
	
       # #if($loop>=20) { print ("fail to search the voltage\n"); $pf_bnd_fnd = 1; }
	   # $loop = ++$loop;
	   # $spread = $Vsearch2 - $Vsearch1;
	   # $max_spread = $Vin_set * 0.005 ;
	   # if ($spread < 0) { $spread = -1 * $spread;}		
	   # if (($spread <= $max_spread)&&(@ret_array_2[0] eq "F")||($loop>20)) {$meas_i =  @ret_array_2[2]/1000; $pf_bnd_fnd = 1;}
	   
    # }

  	# `hpti 'RLYC AC,OFF,($put_i)'`;		
	
	# print "Search voltage = $current_put_mv IOLH value for $put_i = $meas_i mA \n";

	# print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$vddo_v,vdd_gpio=$vdd_gpio,");
	# print fh_iolh ("$put_i,SearchV=$current_put_mv mv,$meas=$meas_i mA\n");
			
# }
sub iolh_volt_meas {
    
	my($vddo_v,$put_set,$iolh_cfg,$mode,$vddc,$ilimit,$parameter) = @_;
		# print "\$parameter=$parameter\n";
		$iforce = $ilimit*1000; #uA
		# print "iforce = $iforce,($put_set)\n";
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

		`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
		`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
		`hpti 'MSET 1,DC,2,ACT,,,(@)'`;	  
		`hpti 'MSET 1,DC,2,PPMU,0,ON,($put_set)'`;
		`hpti 'MSET 1,DC,2,ACTI,1,,($put_set)'`;

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


		`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3; MEAS 1,4'`;

	   
		`hpti 'MEAR VAL,5,($put_set)'`;
		#`hpti 'MEAR VMUM,10,($put_i)'`;

		$ret_val_string = `hpti 'PMUR? VAL,($put_set)'`;
		# print "\$ret_val_string,$ret_val_string\n";

		 
		if($debug > 0.5) { print "$ret_val_string"; }

		# @ret_array_1 = split ",", $ret_val_string;
		# print "\$ret_val_string=$ret_val_string\n";
		&volh_return_val_datalog($ret_val_string,$iforce,$vddc,$parameter);		

	
	
	
	
}

sub volh_return_val_datalog{
my($ret_val_string,$iforce,$vddc,$parameter) = @_;
$pin_name_string="";
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) {
		if ($line_string ne "") 
		{
			# print "\$line_string=$line_string";
			@temp_array=();
			@temp_array=split (/\,/,$line_string);
			$measure_value_string=@temp_array[1];
			# print "\@temp_array[3]=@temp_array[3]\n";
			# print "\@temp_array[4]=@temp_array[4]\n";
			# print "\@temp_array[5]=@temp_array[5]\n";
			# print "\@temp_array=". join("\,\n",@temp_array) . "\n";
			# print "\$measure_value_string=$measure_value_string\n";
			@temp_array2=();
			@temp_array2=split (/\)/,$temp_array[3]);
			# print "\@temp_array2=". join("\,\n",@temp_array2) . "\n";
			$pin_name_string="";
			$pin_name_string=$temp_array2[0];			
			@temp_array3=();
			@temp_array3=split (/\(/,$pin_name_string);
			# print "\@temp_array3=". join("\,\n",@temp_array3) . "\n";
			$pin_name_string="";
			$pin_name_string=@temp_array3[1];
			# print "\$pin_name_string=$pin_name_string\n";

			
			if ((@temp_array[3] ne "") && (@temp_array[4] ne "") ) 
			{	
				# print "\nrun non-major or offline\n";
				@temp_array=();
				@temp_array=split (/\,\,/,$line_string);
				# print "\@temp_array[1]=@temp_array[1]\n";
				@temp_array2=();
				@temp_array2=split (/\(/,@temp_array[1]);
				# print "\@temp_array2[1]=@temp_array2[1]\n";
				@temp_array3=();
				@temp_array3=split (/\)/,@temp_array2[1]);
				# print "\@temp_array3[0]=@temp_array3[0]\n";				
				@pin_name_array=();
				@pin_name_array=split (/\,/,@temp_array3[0]);
				# print join("\t",@pin_name_array);

				foreach $put (@pin_name_array) {
					$volh_volt=$measure_value_string;
					# print "\n\$volh_volt=$volh_volt\n";
					if ($parameter =~/max/)
					{	print "$put  -> $volh_volt mV \@$iforce mA \@max current\n";	}
					elsif ($parameter =~/min/)
					{	print "$put  -> $volh_volt mV \@$iforce mA \@min current\n";	}
						$meas_volt = abs($volh_volt);

						print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vddc,");
						print fh_volh ("$put,$parameter,$meas_volt,$iforce\n");
					}
			}
			else
			{			# major run here
				# print "\nrun major\n";
				$put=$pin_name_string;
				# print "\$pin_name_string=$pin_name_string\n";
				$volh_volt=$measure_value_string;
				if ($parameter =~/max/)
				{	print "$put  -> $volh_volt mV \@$iforce mA \@max current\n";	}
				elsif ($parameter =~/min/)
				{	print "$put  -> $volh_volt mV \@$iforce mA \@min current\n";	}
				$meas_volt = abs($volh_volt);
				#`hpti 'RLYC AC,OFF,($put_set)'`;	
				print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vddc,");
				print fh_volh ("$put,$parameter,$meas_volt,$iforce\n");	
			}
		}

	}	
}

# sub lvds_volh {

	# my($Vin_set,$put_i,$Iin_set,$put_v) = @_;
				
	# `hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	# `hpti 'MSET 1,DC,1,WAIT,,20,(@)'`;
	# `hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	# `hpti 'MSET 1,DC,1,SEL,0,CURR,($put_i)'`;
	# `hpti 'MSET 1,DC,1,SEL,0,VOLT,($put_v)'`;
	# `hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_i)'`;
	# `hpti 'MSET 1,DC,1,IRNG,1,IRD,($put_v)'`;
	# `hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put_i)'`;	
# print "-- MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)\n";
	# `hpti 'MSET 1,DC,1,IFOR,2,$Iin_set,($put_v)'`;
	# `hpti 'MSET 1,DC,1,PMUL,3,-50,($put_i)'`;
	# `hpti 'MSET 1,DC,1,PMUL,3,500,($put_v)'`;
	# `hpti 'MSET 1,DC,1,PMUH,4,50,($put_i)'`;
	# `hpti 'MSET 1,DC,1,PMUH,4,2500,($put_v)'`;
	# `hpti 'MSET 1,DC,1,ACTI,5,,($put_i,$put_v)'`; 

	# `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	# `hpti 'MSET 1,DC,2,WAIT,,100,(@)'`;
	# `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	# `hpti 'MSET 1,DC,2,ACPM,0,ON,($put_i)'`;
	# `hpti 'MSET 1,DC,2,ACPM,0,ON,($put_v)'`;
	# `hpti 'MSET 1,DC,2,ACTI,1,,($put_i,$put_v)'`;

	# `hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	# `hpti 'MSET 1,DC,3,WAIT,,500,(@)'`;
	# `hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	# `hpti 'MSET 1,DC,3,PMUM,0,I,($put_i)'`;
	# `hpti 'MSET 1,DC,3,PMUM,0,L,($put_v)'`;

	# `hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	# ##`hpti 'MEAR VAL,10,($put_i)'`;

	# #$ret_val_1 = `hpti 'PMUR? VAL,($put_i)'`;
	# #print "$ret_val_1\n";
	
	# #@ret_array_1 = split ",", $ret_val_1;
	# #$meas_i = $ret_array_1[2];

	# $ret_val_2 = `hpti 'PMUR? VAL,($put_v)'`;
	# print "$ret_val_2\n";
	
	# @ret_array_2 = split ",", $ret_val_2;
	# $meas_mV = $ret_array_2[1];
	
	# print "measures value for $put_v = $meas_mV mV\n";

# #print ("Enter yes/no to check (yes/no): ");
# #$check_1 = <STDIN>;
# #chomp($check_1);

	# `hpti 'RLYC IDLE,OFF,($put_i,$put_v)'`;				

	# print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$bsdl_HIZ_pattern,$vdd_lvdsrx_level,");
	# print fh_volh ("$put_v,$Iin_set,$lo_limit,$hi_limit,$meas_mV\n");
	
# }

