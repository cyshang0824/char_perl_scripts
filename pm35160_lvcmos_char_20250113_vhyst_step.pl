#!/usr/local/bin/perl

########################################################
# CY SHANG (July 2024) - Titan LVCMOS characterization
# Characterization tests supported - input sensitivity, IO leakage, PVT Compensated OD - ROCD, PVT Compensated ODT - Rtt/Vm


$date = `date`;
@date_array = split " ",$date;
$hostname = `hostname`;
@hostname_array = split ".eng.",$hostname;
$hostname=$hostname_array[0];
# print $hostname;


$PATH = "/proj/me_proj/cyshang/Titan/lvcmos_char/";
my $time_file_path = $PATH . "time_file_${date_array[1]}${date_array[2]}.txt";

# my $subject="$hostname\_test123";

# create_time_file($time_file_path, $subject);
# exit;


$gCapSize = 100000;
$gScan_port = "jtag_tdo_p";


$debug = 0 ;

$atp_wfs = 16;
$atp_tim = 1;
$lvl = 11;  #level 11 new added for change gpio9~18 1.89V
$dps = 6;


$bsdl_wfs = 1;
$bsdl_tim = 1;
$bsdl_lvl = 3;
$bsdl_dps = 6;

# vectors to use for bsdl contact check
$device_bsdl = "pm35160_bsdl_reva_DC_DC";
$device_HIZ = "pm35160_bsdl_reva_HIZ_HIZ";


#$cfg_dataset = "SPRM $lvcmos_wfs,$tim,$lvl,$dps";
$sch_vilh_dataset = "SPRM $atp_wfs,$atp_tim,$lvl,$dps";


# vectors to use for vil vih char
$gpio_read_pattern = "lvcmos_od_gpio_read";


# vector to use for io leakage
# $device_io_leak = "lvcmos_leakage";

@iolh_MaxSpec_array = (3.541,7.03,13.46,25.26,30.37);					  
@iolh_MinSpec_array = (1.967,3.849,7.514,14.49,17.71);	
	  

#class definition for all the possible pins that will be tested either in typ/rep/pvt modes
%lvcmos_pin_class = (
	"gpio18_p"		=>	"lvcmos18_od_ns_SP",
	"gpio17_p"		=>	"lvcmos18_od_ns_SP",
	"gpio16_p"		=>	"lvcmos18_od_ns_SP",
	"gpio15_p"		=>	"lvcmos18_od_ns_SP",
	"gpio14_p"		=>	"lvcmos18_od_ns_SP",
	"gpio13_p"		=>	"lvcmos18_od_ns_SP",
	"gpio12_p"		=>	"lvcmos18_od_ns_SP",
	"gpio11_p"		=>	"lvcmos18_od_ns_SP",
	"gpio10_p"		=>	"lvcmos18_od_ns_SP",
	"gpio09_p"		=>	"lvcmos18_od_ns_SP",
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
	"vddo_gpio_n"		=> 1.71,
	"vddo_gpio_s"		=> 1.71,
	"avdh_pcie_vph"	 	=> 1.2,
	"avd_serdes"		=> 0.90,
	"vddo_fc"		=> 1.20,
	"vddo_ddr_pll"		=> 1.80,
	"avd_pll_pcie_refclk"	=> 0.734,
	"avdh_dcsu_pll"		=> 1.80,
	"vdd_core"		=> 0.715,
	"avdh_pcie_refclk"	=> 1.8,
	"vddo_ddr_io"		=> 1.1,	
	"vddo_i3c_0"		=> 1.8,	
	"vddo_i3c_1"		=> 1.8,			
);

%max_1v8_supply = (
	"vddo_gpio_n"		=> 1.89,
	"vddo_gpio_s"		=> 1.89,
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
@lvcmos_put = ("gpio18_p",	"gpio17_p",	"gpio16_p",	"gpio15_p",	"gpio14_p",	"gpio13_p",	"gpio12_p",	"gpio11_p",	"gpio10_p",	"gpio09_p");
@lvcmos_all_put = ("gpio18_p",	"gpio17_p",	"gpio16_p",	"gpio15_p",	"gpio14_p",	"gpio13_p",	"gpio12_p",	"gpio11_p",	"gpio10_p",	"gpio09_p");			
# @lvcmos_output = ("i3c_data1_p");



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
	elsif ($vdd_0 eq "min_1v8") {  
		$vdd = 1.71;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v8. power ($vdd): $dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v8") {  
		$vdd = 1.89;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v8. power ($vdd): $dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v8_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v2") {  
		$vdd = 1.2; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v2. power ($vdd): $dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}	
	elsif ($vdd_0 eq "min_1v2") {  
		$vdd = 1.14;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v2. power ($vdd): $dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v2") {  
		$vdd = 1.26;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v2. power ($vdd): $dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v2_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "typ_1v0") {  
		$vdd = 1.0; 	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("typ_1v0. power ($vdd): $dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$typ_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "min_1v0") {  
		$vdd = 0.95;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("min_1v0. power ($vdd): $dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$min_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_1v0") {  
		$vdd = 1.1;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_1v0. power ($vdd): $dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_1v0_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
		} 
	}
	elsif ($vdd_0 eq "max_0v") {  
		$vdd = 0.0;	
		foreach $supply_name (@supply_name_array) {
			if($debug > 0.5) { print ("max_0v. power ($vdd): $dps,$max_0v_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)\n"); }
			`hpti 'PSLV $dps,$max_0v_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
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

my($vddo_v,$vin_test,$put,$mode,$vdd_gpio,$vddc,$parameter,$Irng,$Rpd_cfg,$Irange_Fixed) = @_;


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
	
	if ($pin_i != 0) {			$R_value1 = abs($vdd_gpio/$pin_i *1000);	}
	else { $R_value1 ="offline";}
	print "$put current $pin_i uA is measured, Rpu/pd = $R_value1 kohm, $Irng\n";	
	if ($Irange_Fixed ne "Yes")
    {
		if (abs($pin_i) <= 10 && $Rng_ReMes_enable == 0) 
		{   $Irng = "IRA";        $Rng_ReMes_enable = 1;        print "\nIRA_enable...\n";	}
		elsif (abs($pin_i) > 10 && abs($pin_i) <= 100 && $Rng_ReMes_enable == 0) 
		{   $Irng = "IRB";        $Rng_ReMes_enable = 1;        print "\nIRB_enable...\n";	}   
		elsif (abs($pin_i) > 100 && abs($pin_i) <= 1000 && $Rng_ReMes_enable == 0) 
		{   $Irng = "IRC";        $Rng_ReMes_enable = 1;        print "\nIRC_enable...\n";	}
		elsif ($Rng_ReMes_enable == 1)
		{	# Once the IRA/IRB/IRC is activated, it must be disabled and Change to IRD to prevent it from being executed twice.   
			$Rng_ReMes_enable = 0;        print "\nIRA/IRB/IRC_disable...\n"; 
		}
	}
	if ($R_value1 eq "offline") {	$Rng_ReMes_enable = 0;	}
}
while ($Rng_ReMes_enable == 1);

		print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$temp,$Rpd_cfg,$mode,$vdd_gpio,$vddc,");
		print fh_pupd ("$put,$parameter,$vin_test,$pin_i,$Irng,$R_value1\n");
 

}

sub PUPD_I_in_parallel{

my($vddo_v,$vin_test,$put,$mode,$vdd_gpio,$vddc,$parameter,$Irng,$Rpd_cfg,$Irange_Fixed) = @_;


my $Rng_ReMes_enable = 0;
my $pin_i=0;
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

	my $ret_val_string = `hpti 'PMUR? VAL,($put)'`;
	# print $ret_val_string;
	&pupd_return_val_datalog($ret_val_string,$vin_test,$vdd_gpio,$vddc,$Irng);


}

sub pupd_return_val_datalog
{
	($ret_val_string,$vin_test,$vdd_gpio,$vddc,$Irng) = @_;
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) 
	{
		if ($line_string ne "")
		{
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
					$pin_i=$measure_value_string;
					$pin_i_ma = abs($pin_i/1000);	
					if ($pin_i != 0) {	$R_value1 = abs($vdd_gpio/$pin_i *1000);	}
					else { $R_value1 ="offline";}
					print "$put current $pin_i uA is measured, Rpu/pd = $R_value1 kohm, $Irng\n";				
					print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$temp,$Rpd_cfg,$mode,$vdd_gpio,$vddc,");
					print fh_pupd ("$put,$parameter,$vin_test,$pin_i,$R_value1,$Irng\n");
 				}
			}
			else
			{			#major run here
				$put=$pin_name_string;
				$pin_i=$measure_value_string;
				$pin_i_ma = abs($pin_i/1000);	

				if ($pin_i != 0) {	$R_value1 = abs($vdd_gpio/$pin_i *1000);	}
				else { $R_value1 ="offline";}
				print "$put current $pin_i uA is measured, Rpu/pd = $R_value1 kohm, $Irng\n";				
				print fh_pupd ("$current_count,$rep,$split,$device,$test_mode,$temp,$Rpd_cfg,$mode,$vdd_gpio,$vddc,");
				print fh_pupd ("$put,$parameter,$vin_test,$pin_i,$R_value1,$Irng\n");
			}
		}

	}	
}







sub vilh_sweep_linear_vhyst {

	my($put, $limit_1, $limit_2, $vil, $vih,$mode) = @_;
	
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


             `hpti 'SQSL "$gpio_read_pattern"'`;			
			 print "--- gpio_read_pattern is loaded! ---\n";
	
	    while (($current_put_mv <= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv + 100 ; }#100mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {print "***** start pf_flag_fine search *****\n";$current_put_mv = $current_put_mv + 5 ;} #5mv per step for fine search
			 
 		 
			 
			 `hpti 'DRLV $lvl,$current_put_mv,1890,($put)'`; #set vih = current_put_mv		
             print "VIL DRLV $lvl,$current_put_mv,1890,$put\n"; `hpti 'WAIT 200'`;
		     $ret_val = `hpti 'FTST?'`;
			 print "$test FTST of $current_put_mv mv = $ret_val";

			 
			 if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_mv = $coarse_volt - 100 ; $back_coarse_volt = 1;} #back the voltage of coarse search
		 
			 @retval_array = split " ",$ret_val;

			 if ($retval_array[1] eq "F") {

                if(($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search
                if($pf_flag_coarse == 0)                         {$pf_flag_coarse = 1 ; $coarse_volt = $current_put_mv; $current_put_mv = $limit_1 ;} # start fine search

             }
		}
	}
    else {            			# input high being tested VIH

        print "no tst-- VIH\n";	
			 print " mode= $mode \n";

			 
             `hpti 'SQSL "$gpio_read_pattern"'`;			
			 print "--- gpio_read_pattern is loaded! ---\n";
		
	    while (($current_put_mv >= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv - 100 ; }#100mv per step for coarse search
		     if (($pf_flag_coarse == 1)) {print "***** start pf_flag_fine search *****\n";$current_put_mv = $current_put_mv - 5 ;} #5mv per step for fine search
			 
		 

			 `hpti 'DRLV $lvl,$current_put_mv,1890,($put)'`; #set vil = current_put_mv		
             print "VIH DRLV $lvl,$current_put_mv,1890,$put\n";`hpti 'WAIT 200'`;	 
			 $ret_val = `hpti 'FTST?'`;
			 print "$test FTST of $current_put_mv mv = $ret_val";

			if (($pf_flag_coarse == 1)&&($back_coarse_volt == 0)) {$current_put_mv = $coarse_volt + 100 ; $back_coarse_volt = 1;} #back the voltage of coarse search
		    
		     @retval_array = split " ",$ret_val;
		      # print "retval_array[1]=$retval_array[1]\n";
# exit;	
             if ($retval_array[1] eq "P") {

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

# sub vilh_sweep_linear_vilh {

	# my($put, $limit_1, $limit_2, $vil, $vih) = @_;
	
	# # define current_vdd that will be used to start the linear search
    # $current_put_mv = $limit_1 ;     #initial vil/vih value		
	# # define limit (mV) to exit the binary search
	# $pf_flag_coarse = 0;	
    # $pf_flag_fine = 0;	

  
  # if ($vil eq "tst") {	     # input low being tested	 VIL
		     # `hpti 'FTST?'`;

	        # %vilh_L= (
				# "i3c_clk0_p"  => [4379,	6923,	8295,	10839,	13383],
				# "i3c_data0_p" => [3105,	5649,	8293,	10837,	13381],
				# "i3c_data1_p" => [4375,	6919,	8291,	10835,	13379],
				# "i3c_clk1_p"  => [3101,	5645,	8289,	10833,	13377]
   			# );

   			# @comp=();

   			# $comp[0] = $vilh_L{$put}[0];
   			# $comp[1] = $vilh_L{$put}[1];
   			# $comp[2] = $vilh_L{$put}[2];
   			# $comp[3] = $vilh_L{$put}[3];
   			# $comp[4] = $vilh_L{$put}[4];
	
	    # while (($current_put_mv <= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 # if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv + 30 ; }#30mv per step for coarse search
		     # if (($pf_flag_coarse == 1)) {$current_put_mv = $current_put_mv + 5 ;} #5mv per step for fine search
	
			 
             # `hpti 'DRLV $lvl,$current_put_mv,$vih,($put)'`; #set vil = current_put_mv
								 
             # $pattern = `hpti 'SQSL?'`;
	         # print "cfg pattern setting:  SQSL $pattern ,$sprm_val\n";
		     
			 # $ret_val = `hpti 'FTST?'`;
			 # print "FTST of $current_put_mv mv\n";
 		     # @retval_array = split " ",$ret_val;
			 # # print @retval_array;
			 
			 # if ($retval_array[1] eq "F") {
			    # #########################
				# # Fist Fail Cycle logging
				# #########################
		        # $cmd = sprintf("SQGB acqf,0;");
		        # `hpti '$cmd'`;
				# $cmd = sprintf ("ercy? ALL,0,,%d,(%s);", $gCapSize,$gScan_port);
				# $ercy = `hpti -9000000 '$cmd'`;

				# @ercy_array=();
				# #print "ercy_array = @ercy_array \n";
				# @ercy_array=split("\n",$ercy);

				# $pf_count=0;
				# $ercy_log = "";
				# @e=();
				# foreach $e (@ercy_array){
				   # # print "$e\n";
				   # @e=split(",",$e);
				   # #print "$e[1]\n";
				   # if($e =~ /^\S+/ ){
    			   		# $ercy_log = $ercy_log.",".$e[1];
   				    # }

				   # # print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
				   # foreach $comp(@comp){
					   # if ($e[1] eq $comp) {
						# $pf_count++;
						# print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
						# print "match $comp pf_count=$pf_count\n";						
					   # }
				   # }

                # }
				# print "match $pf_count\n";

                # if(($pf_count==5)&&($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search
                # if(($pf_count==5)&&($pf_flag_coarse == 0))                       {$pf_flag_coarse = 1 ; $current_put_mv = $current_put_mv - 30 ;} # start fine search
 				
                # #print ("vil_ercy_pf_flag_info: $pf_flag,$pf_count,$ercy_log\n");
             # }
		# }
	# }
    # else {            			# input high being tested VIH

	         # `hpti 'FTST?'`;
			 # %vilh_H= (
				# "i3c_clk0_p"  => [3107,	5651,	9567,	12111],
				# "i3c_data0_p" => [4377,	6921,	9565,	12109],
				# "i3c_data1_p" => [3103,	5647,	9563,	12107],
				# "i3c_clk1_p"  => [4373,	6917,	9561,	12105]
		    # );


	        # @comp=();

   			# $comp[0] = $vilh_H{$put}[0];
   			# $comp[1] = $vilh_H{$put}[1];
   			# $comp[2] = $vilh_H{$put}[2];
   			# $comp[3] = $vilh_H{$put}[3];
            # $comp[4] = $vilh_H{$put}[4];

	
	    # while (($current_put_mv >= $limit_2) && ($pf_flag_fine == 0)) {             #when completing fine search then stop
			 # if (($pf_flag_coarse == 0)) {$current_put_mv = $current_put_mv - 30 ; }#30mv per step for coarse search
		     # if (($pf_flag_coarse == 1)) {$current_put_mv = $current_put_mv - 5 ;} #5mv per step for fine search

             # `hpti 'DRLV $lvl,$vil,$current_put_mv,($put)'`; #set vih = current_put_mv
			 # #`hpti 'SQSL "$vilh_pattern"'`;
			 # #`hpti 'WAIT 10'`;		
	         # #`hpti 'FTSM SET,3189,,'`;
			 
	         # $pattern = `hpti 'SQSL?'`;
	         # print "cfg pattern setting:  SQSL $pattern ,$sprm_val\n";
	
		     # $ret_val = `hpti 'FTST?'`;
		     # print "FTST of $current_put_mv mv\n";
   
																																						  
		    
		     # @retval_array = split " ",$ret_val;
			 # # print @retval_array;

             # if ($retval_array[1] eq "F") {
	             # #########################
				 # # Fist Fail Cycle logging
				 # #########################
		         # $cmd = sprintf("SQGB acqf,0;");
		         # `hpti '$cmd'`;
				 # $cmd = sprintf ("ercy? ALL,0,,%d,(%s);", $gCapSize,$gScan_port);
				 # $ercy = `hpti -9000000 '$cmd'`;
				 # # print "ercy=$ercy \n";
			 

				 # @ercy_array=();
				 # # print "ercy_array = @ercy_array \n";
				 # @ercy_array=split("\n",$ercy);

				 # $pf_count=0;
				 # $ercy_log = "";
				 # @e=();
				 # foreach $e (@ercy_array){
				    # #print "$e\n";
				    # @e=split(",",$e);
				    # #Sprint "$e[1]\n";
				    # if($e =~ /^\S+/ ){
    			   		# $ercy_log = $ercy_log.",".$e[1];
   				    # }

				    # # print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
					# foreach $comp(@comp){	
						# # print "e[1]=$e[1],comp= $comp\n";
						# if ($e[1] eq $comp) {
							# $pf_count++;
							# print ("errorcycle: $e[0],$e[1],$e[2],$e[3],$e[4],$e[5],$e[6]\n");
							# print "match $comp pf_count=$pf_count\n";
							
						# }
					# }
                # }
				# print "match $pf_count\n";
                 # if(($pf_count==4)&&($pf_flag_coarse == 1)&&($pf_flag_fine == 0)) {$pf_flag_fine = 1 ; } # stop fine search         
   			     # if(($pf_count==4)&&($pf_flag_coarse == 0))                       {$pf_flag_coarse = 1 ; $current_put_mv = $current_put_mv + 30 ;} # start fine search
                 

                 # #print ("vih_ercy_pf_flag_info: $pf_flag,$pf_count,$ercy_log\n");

			 # }	
				 
		     # #print ("current VIH = $current_put_mv mV\n");
		
		# }
	# }		
	# # return the last drive level tested that resulted in a Pass
	# `hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  	
	# return $current_put_mv;

# }




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
# sub volh_sweep_binary {

	# my($put, $limit_1, $limit_2, $vol, $voh) = @_;
	
	# # initialize pass/fail boundary flag
	# $pf_bnd_fnd = 0;
	# # define current_vdd that will be used to start the binary search
	# $current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
	# # define limit (mV) to exit the binary search
	# $max_spread = 1;

	# `hpti 'SREC x,(@)'`;
	# `hpti 'SREC act,(tdo,$put)'`;	
		
	# #print "volh: $limit_1, $limit_2, $vol, $voh\n";
	# while ($pf_bnd_fnd == 0) {
		# $current_put_mv = $limit_2 - (($limit_2 - $limit_1)/2);
		# # set pin under test to new V
		# if ($vol eq "tst") {
			# # input low being tested
			# `hpti 'RCLV $lvl,$current_put_mv,$voh,($put)'`;
		# }
		# else {
			# # input high being tested
			# `hpti 'RCLV $lvl,$vol,$current_put_mv,($put)'`;
		# }
		# `hpti 'WAIT 50'`;		
		
		# $ret_val = `hpti 'FTST?'`;
		# @retval_array = split " ",$ret_val;

		# #print ("test reported $retval_array[1] @ volh=$current_put_mv for $put; current test limits = $limit_1 mV and $limit_2 mV with Spread $spread mV\n");
		
		# if ($retval_array[1] eq "F") {
			# $limit_2 = $current_put_mv;
		# }
		# else {
			# $limit_1 = $current_put_mv;
		# }
		
		# # ensure spread is always a positive number
		# $spread = $limit_2 - $limit_1;
		# if ($spread < 0) {
			# $spread = -1 * $spread;
		# }
		
		# if ($spread <= $max_spread) {
			# $pf_bnd_fnd = 1;
			# #print ("final spread = $spread V\n");
		# }
	# }

	# `hpti 'UPTD VEC,1'`;
	
	# # return the last drive level tested that resulted in a Pass
	# return $limit_1;
	
# }
# sub iolh_volt_sweep_binary {
   
    # my($vddo_v,$Vin_set,$put_i,$pat_cfg,$vdd_gpio,$ilimit,$meas) = @_;

	# $pf_bnd_fnd = 0;	
	
	# # SREC x,(@);
	# # SREC act,(tdo, $put);
	# `hpti 'SREC x,(@)'`;
	# `hpti 'SREC act,($put_i)'`;	
	# #print "iolh: $limit_1, $limit_2, $iol, $ioh\n";
	# $Vt= $vdd_gpio*0.5*1000;	
	# $loadCurrent = $ilimit*1000 ;
	# if ($meas eq "IOH") {
		# $Vsearch1 = $Vin_set*0.2 ; $Vsearch2 = $Vin_set*1.2 ;
		# # output high being tested
	     # `hpti 'TERM $lvl,A,$Vt,100,$loadCurrent,auto,auto,($put_i)'`;	
		 # print ("set termination \n");
	# }
	# elsif ($meas eq "IOL") {
		# $Vsearch2 = $Vin_set*0.8 ; $Vsearch1 = $Vin_set*1.8 ;
		# # output low being tested
	     # `hpti 'TERM $lvl,A,$Vt,$loadCurrent,100,auto,auto,($put_i)'`;		
	# }
	
	
	# while ($pf_bnd_fnd == 0) {
		
 	    # if ($meas eq "IOH") { $current_put_mv = $Vsearch2 - (($Vsearch2 - $Vsearch1)/2); `hpti 'RCLV $lvl,100,$current_put_mv,($put_i)'`; print ("set RCLV \n");} # set pin under test to new mV to search IOH
        # elsif($meas eq "IOL") { $current_put_mv = $Vsearch2 + (($Vsearch1 - $Vsearch2)/2); `hpti 'RCLV $lvl,$current_put_mv ,800,($put_i)'`;} # set pin under test to new mV to search IOL

	 	
		# #`hpti 'RCLV $lvl,-1300,-750,($put_i)'`;
		
	    # `hpti 'SQSL "i3c_transparency_D0_to_D1_$meas"'`;
		# `hpti 'WAIT 500'`;		
		
		# $ret_val = `hpti 'FTST?'`;
		# @retval_array = split " ",$ret_val;

		# print ("pat i3c_transparency_D0_to_D1_$meas, test reported $retval_array[1], @ Vsearch=$current_put_mv ; current test limits = $ilimit mA  with Spread $spread mV\n");

        # if(@retval_array[1] eq "P"){ $Vsearch1 = $current_put_mv ;}
	    # elsif (@retval_array[1] eq "F") {$Vsearch2 = $current_put_mv ;} 
		
		# # ensure spread is always a positive number
		# $spread = $Vsearch2 - $Vsearch1;
		# # define limit (mV) to exit the binary search
	    # $max_spread = $Vin_set * 0.005 ;
		# if ($spread < 0) {$spread = -1 * $spread;}
		
		# if ($spread <= $max_spread) {
			# $pf_bnd_fnd = 1;
			# #print ("final spread = $spread V\n");
		# }
	# }
	
	# #UPTD VEC,1;
	# #`hpti 'UPTD VEC,1'`;
	
	# print "Search voltage = $current_put_mv \n";

	# print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$vddo_v,vdd_gpio=$vdd_gpio,");
	# print fh_iolh ("$put_i,SearchV=$current_put_mv mv,\n");
		
	
# }
sub iolh {
	
	my($vddo_v,$Vin_set,$put,$iolh_cfg,$mode,$vdd_gpio,$vddc,$parameter,$meas,$first_run) = @_;
	
	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,IRD,($put)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,6000,($put)'`;
	`hpti 'MSET 1,DC,1,ACTI,3,,($put)'`; 

   `hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
   `hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
   `hpti 'MSET 1,DC,2,ACT,,,(@)'`;
   `hpti 'MSET 1,DC,2,PPMU,0,ON,($put)'`;
   `hpti 'MSET 1,DC,2,ACTI,1,,($put)'`;        

	
	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	
	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`; print "using PMU measurement\n";


	`hpti 'MEAR VAL,5,($put)'`;
	$ret_val_string = `hpti 'PMUR? VAL,($put)'`;
# print "\$ret_val_string=$ret_val_string\n";	
	
	# print "Mea_Val $ret_val_string\n";
	&lolh_return_val_datalog($ret_val_string,$Vin_set,$vdd_gpio,$vddc);
	



}

sub lolh_return_val_datalog{
my($ret_val_string,$Vin_set,$vdd_gpio,$vddc) = @_;
	@ret_line=();
	@ret_line=split (/PMUR/,$ret_val_string);
	chomp(@ret_line);
	foreach $line_string (@ret_line) {
		if ($line_string ne "") 
		{
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
					$iolh_current=$measure_value_string;
					print "$put -> $iolh_current mA\@$Vin_set mV\n";
					$meas_i = abs($iolh_current);
					$meas_i=$meas_i/1000; #mA
					# print "IOLH value for $put = $meas_i mA \@$Vin_set mV\n";
					print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vdd_gpio,$vddc,");
					print fh_iolh ("$put,IOL,$Vin_set,$meas_i\n");
		
				}
			}
			else
			{			# major run here
				$put=$pin_name_string;
				$iolh_current=$measure_value_string;
				print "$put  -> $iolh_current mA \@$Vin_set mV\n";
				$meas_i = abs($iolh_current);
				$meas_i=$meas_i/1000; #mA
				# print "IOLH value for $put = $meas_i mA \@$Vin_set mV\n";

				print fh_iolh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vdd_gpio,$vddc,");
				print fh_iolh ("$put,IOL,$Vin_set,$meas_i\n");

			}
		}

	}	
}




# sub vil {

	# my($vddo_v,$put,$mode,$vdd_gpio,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg) = @_;

	# print " -- vil: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";

	# if (($pat_cfg eq "43")||($pat_cfg eq "44")||($pat_cfg eq "45")||($pat_cfg eq "46")) { $vil_val = &vilh_sweep_linear_vilh($put,500,1400,"tst",$init_vih_mv);}
    # else {$vil_val = &vilh_sweep_linear_vilh($put,330,1400,"tst",$init_vih_mv);}

	# print "VIL value for $put = $vil_val mV\n";
	
	# print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_gpio,$vddc,");
	# print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vil_val\n");
	
# }
# sub vih {

	# my($vddo_v,$put,$mode,$vdd_gpio,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$pat_cfg) = @_;
	
	# print " -- vih: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";
	
	
	# if (($pat_cfg eq "43")||($pat_cfg eq "44")||($pat_cfg eq "45")||($pat_cfg eq "46")) { $vih_val = &vilh_sweep_linear_vilh($put,1260,400,$init_vil_mv,"tst");}
	# else { $vih_val = &vilh_sweep_linear_vilh($put,900,200,$init_vil_mv,"tst");}
	
	
	# print "VIH value for $put = $vih_val mV\n";
	
	# print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,i3c_DC_test_config_$pat_cfg,$mode,$vdd_gpio,$vddc,");
	# print fh_vilh ("$put,$parameter,$lo_limit,$hi_limit,$vih_val\n");
	
# }
sub sch_vil {

	my($vddo_v,$put,$mode,$vdd_gpio,$vddc,$parameter,$init_vil_mv,$init_vih_mv,$vih_val) = @_;
	
	if ($mode eq "sch_vilh")
	{	print " -- sch_vil: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";}
	else
	{	print " -- non_sch_vil: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";}


	
	if ($mode eq "sch_vilh")
	{	
		$vil_val = &vilh_sweep_linear_vhyst($put,500,1200,"tst",$init_vih_mv,$mode);
		print "***** sch_vil value for $put = $vil_val mV *****\n\n\n";
	}
	else
	{	
		$vil_val = &vilh_sweep_linear_vhyst($put,500,1200,"tst",$init_vih_mv,$mode);
		print "***** non_sch_vil value for $put = $vil_val mV *****\n\n\n";
	}
	$Vhyst=abs($vih_val-$vil_val);


	if ($mode eq "sch_vilh")
	{
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$mode,$vdd_gpio,$vddc,");
		print fh_sch_vilh ("$put,$parameter,$vil_val\n");		
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$mode,$vdd_gpio,$vddc,");
		print fh_sch_vilh ("$put,Vhyst,$Vhyst\n");		
	}
	else
	{
		print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$mode,$vdd_gpio,$vddc,");
		print fh_vilh ("$put,$parameter,$vil_val\n");		
	}	
}
sub sch_vih {

	my($vddo_v,$put,$mode,$vdd_gpio,$vddc,$parameter,$init_vil_mv,$init_vih_mv) = @_;
	
	if ($mode eq "sch_vilh")
	{	print " -- sch_vih: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";	}
	else
	{	print " -- non_sch_vih: $vddo_v,$put,$init_vil_mv,$init_vih_mv\n";	}
	
	
	
	if ($mode eq "sch_vilh")
	{	
		$vih_val = &vilh_sweep_linear_vhyst($put,1200,500,$init_vil_mv,"tst",$mode);
		print "***** sch_vih value for $put = $vih_val mV *****\n\n\n";	
	}
	else
	{	
		$vih_val = &vilh_sweep_linear_vhyst($put,1200,500,$init_vil_mv,"tst",$mode);
		print "***** non_sch_vih value for $put = $vih_val mV *****\n\n\n";	
	}

	if ($mode eq "sch_vilh")
	{
		print fh_sch_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$mode,$vdd_gpio,$vddc,");
		print fh_sch_vilh ("$put,$parameter,$vih_val\n");
	}
		else
	{
		print fh_vilh ("$current_count,$rep,$split,$device,$test_mode,$temp,$mode,$vdd_gpio,$vddc,");
		print fh_vilh ("$put,$parameter,$vih_val\n");		
	}	
	return $vih_val;
}
sub lvcmos_leak {
    #debug IIL,,,IIH pass
	
	
    ($vddo_v,$Vin_set,$put,$mode,$vdd_gpio,$vddc,$parameter,$leak_cfg,$Irang) = @_;

	`hpti 'MSET 1,DC,1,LEN,6,,(@)'`;
	`hpti 'MSET 1,DC,1,WAIT,,0,(@)'`;
	`hpti 'MSET 1,DC,1,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,1,SEL,0,CURR,($put)'`;
	`hpti 'MSET 1,DC,1,IRNG,1,$Irang,($put)'`;
	`hpti 'MSET 1,DC,1,UFOR,2,$Vin_set,($put)'`;	
	`hpti 'MSET 1,DC,1,PMUL,3,-100,($put)'`;
	`hpti 'MSET 1,DC,1,PMUH,4,100,($put)'`;
	`hpti 'MSET 1,DC,1,ACTI,5,,($put)'`; 
	print "\nVin(Vpad gpio pins)=$Vin_set\n";
	`hpti 'MSET 1,DC,2,LEN,2,,(@)'`;
	`hpti 'MSET 1,DC,2,WAIT,,3,(@)'`;
	`hpti 'MSET 1,DC,2,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,2,PPMU,0,ON,($put)'`;
	`hpti 'MSET 1,DC,2,ACTI,1,,($put)'`;

	`hpti 'MSET 1,DC,3,LEN,1,,(@)'`;
	`hpti 'MSET 1,DC,3,WAIT,,2,(@)'`;
	`hpti 'MSET 1,DC,3,ACT,,,(@)'`;
	`hpti 'MSET 1,DC,3,PMUM,0,I,($put)'`;

	`hpti 'MEAS 1,1; MEAS 1,2; MEAS 1,3'`;
	
	`hpti 'MEAR VAL,10,($put)'`;
	
	$ret_val_string = `hpti 'PMUR? VAL,($put)'`;
	&leak_return_val_datalog($ret_val_string,$Vin_set,$vdd_gpio,$vddc);
	
}

sub leak_return_val_datalog{
	($ret_val_string,$Vin_set,$vdd_gpio,$vddc) = @_;
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
					print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$temp,$leak_cfg,$mode,$vdd_gpio,$vddc,");
					print fh_leak ("$put,$parameter,$Vin_set,$meas_i\n");
				}
			}
			else
			{			# major run here
				$put=$pin_name_string;
				$meas_i=$measure_value_string;
				$meas_i=abs($meas_i);
				print "$put  -> $Vin_set mv for $meas_i uA\n";
				print fh_leak ("$current_count,$rep,$split,$device,$test_mode,$temp,$leak_cfg,$mode,$vdd_gpio,$vddc,");
				print fh_leak ("$put,$parameter,$Vin_set,$meas_i\n");
			}
		}

	}	
}
sub start_from_current_temp{
	$atc_port=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/read_$tester_name\_p0.prl  $si_therm`;
	@atc_array=();
	@atc_array=split("pl2303 converter now attached to ttyUSB",$atc_port);
	$atc_port=$atc_array[1];
	@atc_array=();
	@atc_array=split("\n",$atc_port);
	$atc_port=$atc_array[0];

	if (($atc_port !=0) && ($atc_port !=1)) {	$atc_port=0;	}
	$current_temp=$atc_array[1];


	if (abs($current_temp-20)<5) 		
	{	@temp_C=(-3,108); 
#		@temp_C=(25,-3,108); #start from 25C
	} 
	elsif (abs($current_temp-108)<30)	{	@temp_C=(108,-3);	}
	elsif (abs($current_temp+3)<30)		{	@temp_C=(-3,108);	}

}	



sub calibrate_temp {
	
	my($cal_temp, $soak) = @_;
	print ("\n");
	print ("Setting temperature to $cal_temp C using a $si_therm silicon thermal...\n");
	chomp($cal_temp);
	print "cal_temp $cal_temp C\n";
	$atc_port=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/read_$tester_name\_p0.prl  $si_therm`;
	@atc_array=();
	@atc_array=split("pl2303 converter now attached to ttyUSB",$atc_port);
	$atc_port=$atc_array[1];
	@atc_array=();
	@atc_array=split("\n",$atc_port);
	$atc_port=$atc_array[0];
	print "\nGet ATC port = $atc_port\n";	
	if (($atc_port !=0) && ($atc_port !=1)) {	$atc_port=0;	}
	$current_temp=$atc_array[1];

	print "now temp=$atc_array[1]\n";
	$temp_diff=abs($cal_temp-$current_temp);
    print "temp diff =$temp_diff C\n";

	if ($temp_diff > 20)
	{
		# print "/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_$tester_name\_p$atc_port.prl $cal_temp $soak $si_therm\n";
		$current_temp=`/proj/me_proj/cyshang/ATC_control/atc_ps1600/set_$tester_name\_p$atc_port.prl $cal_temp $soak $si_therm`;
		chomp($current_temp);
		print " \n -- temp ready at $current_temp C \n";
		print " \n -- temp ready at $current_temp C \n";
		print " \n -- temp ready at $current_temp C \n";
	}	
	else
	{ print "temperature very close .... no need set temp again...\n";	}

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
	
	`hpti 'SQSL "$device_HIZ"'`;
	$bsdl_val = `hpti 'FTST?'`;
	@bsdlval_array = split " ",$bsdl_val;
	print "BSDL $bsdl_val and result  $bsdlval_array[1]\n"; 	
	if ($bsdlval_array[1] eq "P") {	print "BSDL ($device_HIZ) passes...\nBSDL ($device_HIZ) passes...\nBSDL ($device_HIZ) passes...\n";	}
	
	
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
		print "BSDL ($device_HIZ) passes...\nBSDL ($device_HIZ) passes...\nBSDL ($device_HIZ) passes...\n";
     	}
	}	
}
sub check_contact_HIZ {
	$vil_dataset = "SPRM $bsdl_wfs,$tim,$lvl,$dps";

	`hpti '$vil_dataset'`;
	`hpti 'SQSL "$device_HIZ"'`; 
	
	print "VIL setting: SPRM $bsdl_wfs,$tim,$dps,$lvl\n -- SQSL $device_HIZ\n";

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
		print "VIL vector ($device_HIZ) passes...\n";
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
$test_mode or die "input format -> pm35160_lvcmos_char.prl <test_mode={typ/rep/pvt}> \n";




# use ATC control
print "Enter Temperature Forcer Type: (WIN/ST/NO): \n";
$si_therm = <STDIN>;
chomp($si_therm);
$si_therm=uc($si_therm);
if ($si_therm ne "NO")
{
	print "Enter tester: (v3/v4/v5): \n";
	$tester_name = <STDIN>;
	chomp($tester_name);
}
else
{
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

$subject="$hostname\_Start_lvcmos_Char" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;

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
#		@vdd_pwr = ("typ_1v8");		
		@vdd_leak_pwr = ("max_1v8","max_0v");	
		
	}
	

	if ($test_mode eq "rep") {
	    @vdd_pwr = ("typ_1v8");	
		@vdd_leak_pwr = ("max_1v8","max_0v");			
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
	@vdd_leak_pwr = ("max_1v8","max_0v");		
	@iolh_pwr_tst = (1.800);
}
else {
	die "Incorrect test mode selected -> typ/rep/pvt\n";
}

print ("Enter test to perform ( leak / vilh / sch_vilh / iolh / pupd / vilh_all / all ): ");
$test = <STDIN>;
# $test="sch_vilh";
chomp($test);




if ($test eq "all") {
	print "All tests selected - (IO leakage, VILH, PVT Comp OD, PVT Comp pupd)\n";
	
	$datalog_file_vilh = "lvcmos_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";

	$datalog_file_sch_vilh = "lvcmos_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "sch_VILH Data will be written to -> $datalog_file_sch_vilh\n";

	$datalog_file_iolh = "lvcmos_iolh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_iolh, ">>$datalog_file_iolh";
	print "IOLH Data will be written to -> $datalog_file_iolh\n";
	
	$datalog_file_volh = "lvcmos_volh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_volh, ">>$datalog_file_volh";
	print "VOLH Data will be written to -> $datalog_file_volh\n";	
	
	$datalog_file_leak = "lvcmos_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "PVT compensation Output Drive Data will be written to -> $datalog_file_leak\n";
	
	$datalog_file_pupd = "lvcmos_pupd_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_pupd, ">>$datalog_file_pupd";
	print "PVT compensation pupd Data will be written to -> $datalog_file_pupd\n";
}
elsif ($test eq "vilh_all") {
	print "All VILH tests selected - ( VILH, Schmitt_VILH, IO Leakage test)\n";
	$datalog_file_vilh = "lvcmos_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";

	$datalog_file_sch_vilh = "lvcmos_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "sch_VILH Data will be written to -> $datalog_file_sch_vilh\n";
	
    $datalog_file_leak = "lvcmos_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";

}	
elsif ($test eq "leak") {
	print "IO Leakage test selected\n";
	$datalog_file_leak = "lvcmos_leak_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_leak, ">>$datalog_file_leak";
	print "IO Leak Data will be written to -> $datalog_file_leak\n";
}
elsif ($test eq "vilh") {
	print "VILH test selected\n";
	$datalog_file_vilh = "lvcmos_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_vilh, ">>$datalog_file_vilh";
	print "VILH Data will be written to -> $datalog_file_vilh\n";
}
elsif ($test eq "sch_vilh") {
	print "sch_VILH test selected\n";
	$datalog_file_sch_vilh = "lvcmos_sch_vilh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_sch_vilh, ">>$datalog_file_sch_vilh";
	print "VILH Data will be written to -> $datalog_file_sch_vilh\n";
}
elsif ($test eq "iolh") {
	print "IOLH test selected\n";
	$datalog_file_iolh = "lvcmos_iolh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_iolh, ">>$datalog_file_iolh";
	print "IOLH Data will be written to -> $datalog_file_iolh\n";
	
	$datalog_file_volh = "lvcmos_volh_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_volh, ">>$datalog_file_volh";
	print "VOLH Data will be written to -> $datalog_file_volh\n";
}
elsif ($test eq "pupd") {
	print "PVT Compensated pupd test selected\n";
	$datalog_file_pupd = "lvcmos_pupd_datalog_${split}_${test_mode}_${date_array[1]}${date_array[2]}.csv";
	open fh_pupd, ">>$datalog_file_pupd";
	print "PVT compensation pupd Data will be written to -> $datalog_file_pupd\n";
} 
else {
	die "Incorrect test selected ($test) -> (leak/vilh/sch_vilh/iolh/pupd/vilh_all/all))"
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

foreach $temp (@temp_C)
{
	print "Now start from $temp\n";

	$current_count = 0;
	# Set and Calibrate Temperature of case if temperature forcer available
	if ($si_therm ne "NO") {
		&calibrate_temp($temp,$temp_soak);
	}

	
	
	while ($current_count < $rep) {	

		if ($rep > 1) {print "\n**Current repeat count: $current_count\n";}
	
		$test_run_count=0; 
        if (($test eq "all") || ($test eq "sch_vilh") || ($test eq "vilh") || ($test eq "vilh_all")) {
			if (($test eq "all") || ($test eq "vilh_all")){ $test_run_count_max=2;	}
			else { 	$test_run_count_max=1;	}
			
			do
			{
				# &check_contact_HIZ;
				if (($test_run_count==1) || ($test eq "sch_vilh"))
				{	print "\n\nPerforming schmitt_VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";				}
				if (($test_run_count==2) || ($test eq "vilh"))
				{	print "\n\nPerforming non-schmitt_VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";			}
				
				foreach $vdd_v (@vdd_pwr) {
					if ($test eq "sch_vilh")
					{
						if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { &set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
						$test_run="sch_vilh";
					}
					elsif ($test eq "vilh")
					{
						if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { &set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
						$test_run="vilh";
					}
					elsif (($test eq "all") || ($test eq "vilh_all"))
					{
						if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { &set_device_power($vdd_v, 0.1);$force_vih = 1800;} 
						if ($test_run_count==0){$test_run="sch_vilh";}
						if ($test_run_count==1){$test_run="vilh";}
					}
					print "-- current $test_run is executing --\n";
					print "vdd_v setting:  $vdd_v\n"; 

					`hpti '$sch_vilh_dataset'`;	
					print "$sch_vilh_dataset\n";
					if ($test_run eq "sch_vilh")
					{
						`hpti 'SQSL "lvcmos_sch_vilh_compare_setup"'`;
						`hpti 'FTST?'`;
						print "-- lvcmos_sch_vilh_compare_setup --\n";
					}
					elsif ($test_run eq "vilh")
					{
						`hpti 'SQSL "lvcmos_vilh_compare_setup"'`;
						`hpti 'FTST?'`;
						print "-- lvcmos_vilh_compare_setup --\n";
					}
				   
					$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
					@retval_array1 = split ",",$vdd_core;
				
					$vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
					@retval_array2 = split ",",$vdd_gpio;
					# print "vdd_core=$retval_array1[1],vdd_gpio=$retval_array2[1]\n";
					$mode=$test_run;
					foreach $put (@lvcmos_all_put)
					{

						if ($test_run eq "sch_vilh")
						{
							$vih_val=sch_vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VT+",0,$force_vih);
							&sch_vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VT-",0,$force_vih,$vih_val);

						}
						else
						{
							&sch_vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VIH",0,$force_vih);
							&sch_vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],"VIL",0,$force_vih,$vih_val);
						}

					}											
				}
				`hpti 'DRLV $lvl,0,1890,($put)'`; #restore initial drive low/high
				if (($test_run_count==1) || ($test_run eq "sch_vilh"))
				{	$subject="$hostname\_Sch_VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;}
				if (($test_run_count==2) || ($test_run eq "vilh"))
				{	$subject="$hostname\_VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;}
				create_time_file($time_file_path, $subject);
				$test_run_count++;
			} until ($test_run_count == $test_run_count_max)
		}		

		if (($test eq "all") || ($test eq "iolh")) {
			print "\n\nPerforming IOLH testing on Split $split, Device $device @ Temperature $temp C ...\n";
			$first_run =0 ;	
			# if ($test eq "all") {&check_contact_HIZ;}
            foreach $vdd_v (@vdd_pwr) {
				if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) {@iolh_pat_label=(0,1,2,3,4); &set_device_power($vdd_v, 0.1);} 
				
				print "vdd_v setting:  $vdd_v\n";
				foreach $iolh_cfg (@iolh_pat_label) {		 

					$cfg_dataset = "SPRM $atp_wfs,$atp_tim,$lvl,$dps";	   
					if ($iolh_cfg eq "0")	{	$iolh_cfg_pattern="lvcmos_od_drive_strength_3ma_drive0";	$mode = IOL_3ma_200mV;	$pmu_vin = 200; $meas = IOL;}
					if ($iolh_cfg eq "1")	{	$iolh_cfg_pattern="lvcmos_od_drive_strength_3ma_drive0";	$mode = IOL_3ma_400mV;	$pmu_vin = 400; $meas = IOL;}
					if ($iolh_cfg eq "2")	{	$iolh_cfg_pattern="lvcmos_od_drive_strength_6ma_drive0";	$mode = IOL_6ma_400mV;	$pmu_vin = 400; $meas = IOL;}
					if ($iolh_cfg eq "3")	{	$iolh_cfg_pattern="lvcmos_od_drive_strength_12ma_drive0";	$mode = IOL_12ma_400mV;	$pmu_vin = 400; $meas = IOL;}
					if ($iolh_cfg eq "4")	{	$iolh_cfg_pattern="lvcmos_od_drive_strength_15ma_drive0";	$mode = IOL_15ma_400mV;	$pmu_vin = 400; $meas = IOL;}
					`hpti '$cfg_dataset'`;	
					`hpti 'SQSL "$iolh_cfg_pattern"'`;
					`hpti 'FTST?'`;`hpti 'WAIT 50'`;
					print "\ncfg pattern setting:  $iolh_cfg_pattern\n";


					$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
					@retval_array1 = split ",",$vdd_core;
					print ("vdd_core setting $retval_array1[1] \n");		


					$vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
					@retval_array2 = split ",",$vdd_gpio;
					print ("vdd_gpio setting $retval_array2[1] \n");		
				   
					$put_all=join(",",@lvcmos_all_put);	
					&iolh($vdd_v,$pmu_vin,$put_all,$iolh_cfg,$mode,$retval_array2[1],$retval_array1[1],$meas);
					`hpti 'RLYC AC,OFF,($put_all)'`;
					&iolh_volt_meas($vdd_v,$put_all,$iolh_cfg,$mode,$retval_array2[1],$retval_array1[1],@iolh_MaxSpec_array[$iolh_cfg],"$meas at max current");   #max expected current		
					&iolh_volt_meas($vdd_v,$put_all,$iolh_cfg,$mode,$retval_array2[1],$retval_array1[1],@iolh_MinSpec_array[$iolh_cfg],"$meas at min current");   #min expected current						
					`hpti 'RLYC AC,OFF,($put_all)'`;					   
				}
			}				

			$subject="$hostname\_IOLH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
		create_time_file($time_file_path, $subject);
		}		

		if (($test eq "all") || ($test eq "pupd")) {
			# if ($test eq "all") {&check_contact_HIZ;}
			print "\n\nPerforming PVT Compensated pupd testing on Split $split, Device $device @ Temperature $temp C ...\n";
			$pupd_dataset = "SPRM $atp_wfs,$atp_tim,$lvl,$dps";
			`hpti '$pupd_dataset'`;	
			

				foreach $vdd_v (@vdd_pwr)
				{
					if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8"))	{ @Rpd_label = ("10k_pd_1v8","40k_pd_1v8");&set_device_power($vdd_v, 0.1);} 


					$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
					@retval_array1 = split ",",$vdd_core;
					print ("\nvdd_core setting $retval_array1[1] \n");
					$vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
					@retval_array2 = split ",",$vdd_gpio;
					print ("vdd_gpio setting $retval_array2[1] \n");		
			

					$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
					@retval_array1 = split ",",$vdd_core;
					print ("\nvdd_core $retval_array1[1] \n");
					$vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
					@retval_array2 = split ",",$vdd_gpio;
					print ("vdd_gpio setting $retval_array2[1] \n");
				# `disconnect`;`hpti 'WAIT 500'`; `connect`;
				
					foreach $Rpd_cfg (@Rpd_label) 
					{
						if ($Rpd_cfg eq "10k_pd_1v8")	{$Rpd_cfg_pattern ="lvcmos_pd_10k";$parameter= Rpd;	$mode = Rpd10k_1v8_mode;	$term_v=1800;}
						if ($Rpd_cfg eq "40k_pd_1v8")	{$Rpd_cfg_pattern ="lvcmos_pd_40k";$parameter= Rpd;	$mode = Rpd40k_1v8_mode;	$term_v=1800;}

						`hpti 'SQSL "$Rpd_cfg_pattern"'`;
						$FTST_val = `hpti 'FTST?'`; `hpti 'WAIT 100'`;
						print "cfg pattern setting:  SQSL $Rpd_cfg_pattern\n";
						$put_all=join(",", @lvcmos_all_put);
						$Irange_Fixed="Yes";
						&PUPD_I_in_parallel($vdd_v,$term_v,$put_all,$mode,$retval_array2[1],$retval_array1[1],$parameter,"IRB",$Rpd_cfg,$Irange_Fixed);
						`hpti 'RLYC AC,OFF,($put_all)'`;  	
					}

			}			
			$subject="$hostname\_PUPD_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);	
		}
		
		if (($test eq "all") || ($test eq "leak")) {
			# if ($test eq "all") {&check_contact_HIZ;}
			
			$leak_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$lvl,$dps";
			`hpti '$leak_dataset'`;	
			
			print "\n\nPerforming IO leakage testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    foreach $vdd_v (@vdd_leak_pwr) {
		
				if		(($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @leak_label = ("1v8");&set_device_power($vdd_v, 0.1);$mode = disable18_mode;} 
				elsif	($vdd_v eq "max_0v") { @leak_label = ("0v");&set_device_power($vdd_v, 0.1);$mode = "Fail-safe_mode";}
				
                foreach $leak_cfg (@leak_label) {	
			        
                    if ($leak_cfg eq "1v8") 
					{
						`hpti 'SQSL "pm35160_bsdl_reva_HIZ_HIZ"'`;
						# `hpti 'SQSL "pm35160_bsdl_reva_cfg67_TAP_UDR_SAMPLE_HIZ_TAP_UDR_SAMPLE_HIZ"'`;	#cfg67
					} 				
				    
					$FT_val = `hpti 'FTST?'`;`hpti 'WAIT 500'`;
					
    				$vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
                    @retval_array1 = split ",",$vdd_core;
                    print ("vdd_core setting $retval_array1[1]\n");
				
					$vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
                    @retval_array2 = split ",",$vdd_gpio;
					$force_leak_hi=@retval_array2[1]*1000; #set measured pins' voltage are same to vddo_gpio_n
					print "vddo_gpio_n=@retval_array2[1]\n";
					
					$force_leak_hi_3v63=3630; # @vddo_gpio 0v and 1.89V
					$force_leak_lo = 0;   

					$put_all=join(",",@lvcmos_all_put);
					if ($leak_cfg eq "1v8") 
					{
						&lvcmos_leak($vdd_v,$force_leak_hi,$put_all,$mode,@retval_array2[1],@retval_array1[1],IIH,$leak_cfg,"IRB");
						&lvcmos_leak($vdd_v,$force_leak_lo,$put_all,$mode,@retval_array2[1],@retval_array1[1],IIL,$leak_cfg,"IRB");					   
					}
					# 1)Keep VDDO = 0, VPAD = 3.63V
					# 2)Measure Pad current ( Max current at 125C, VPAD=3.63 is 10uA)
					# 3)Measure Pad current ( Max current at 105C, VPAD=3.5475 is 6uA)					
					&lvcmos_leak($vdd_v,$force_leak_hi_3v63,$put_all,$mode,@retval_array2[1],@retval_array1[1],IIH_3p63,$leak_cfg,"IRB");
					`hpti 'RLYC AC,OFF,($put_all)'`; 
                } 					
			}
			$subject="$hostname\_Leakage_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			create_time_file($time_file_path, $subject);
		}
	    $current_count++;

		
		# if (($test eq "all_bypass") || ($test eq "vilh_bypass") || ($test eq "vilh_all_bypass"))
		# {
			
			# print "\n\nPerforming VILH testing on Split $split, Device $device @ Temperature $temp C ...\n";
		    # foreach $vdd_v (@vdd_pwr) {
				# if (($vdd_v eq "typ_1v8")||($vdd_v eq "min_1v8")||($vdd_v eq "max_1v8")) { @pat_label = (43,44,45,46);&set_device_power($vdd_v, 0.1); $force_vih = 1800;} 
				# #`hpti 'PSLV 6,1.8,1,LOZ,15,(vdd_gpio_1)'`; #set vddc_i3c_1 as 1.8 for RX test (VIL/H)
				# print "vdd_v setting:  $vdd_v\n";
				
            	# foreach $pat_cfg (@pat_label) {		 
								   

				   # &check_bsdl;	

				   # $bsdl_dataset = "SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps";
			       # `hpti '$bsdl_dataset'`;	
				   # print "bsdl setting SPRM $bsdl_wfs,$bsdl_tim,$bsdl_lvl,$bsdl_dps\n";
				   # # `hpti 'SQSL "pm35160_bsdl_revb_UDR_UDR"'`; `hpti 'FTST?'`;
				   # # print "SQSL pm35160_bsdl_revb_UDR_UDR as pre-condition\n";


				
			    	# $vdd_core = `hpti 'PSLV? ${dps},(vdd_core)'`;
                    # @retval_array1 = split ",",$vdd_core;
                    # print ("vdd_core setting $retval_array1[1] \n");
				
				    # $vdd_gpio = `hpti 'PSLV? ${dps},(vddo_gpio_n)'`;
                    # @retval_array2 = split ",",$vdd_gpio;
                    # print ("vddo_i3c_0 setting $retval_array2[1] \n");
				
			    	# if (($pat_cfg eq "43")||($pat_cfg eq "44")) 	{$mode = GPIO18_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg43_DC_DC"'`; `hpti 'FTST?'`;}
				    # elsif (($pat_cfg eq "45")||($pat_cfg eq "46"))	{$mode = I2C18_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg45_DC_DC"'`; `hpti 'FTST?'`;}
				    # elsif (($pat_cfg eq "47")||($pat_cfg eq "48"))	{$mode = GPIO12_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg47_cfg51_DC_DC"'`; `hpti 'FTST?'`;}
				    # elsif (($pat_cfg eq "49")||($pat_cfg eq "50"))	{$mode = I2C12_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg49_cfg53_DC_DC"'`; `hpti 'FTST?'`;}
			    	# elsif (($pat_cfg eq "51")||($pat_cfg eq "52"))	{$mode = GPIO10_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg47_cfg51_DC_DC"'`; `hpti 'FTST?'`;}
				    # elsif (($pat_cfg eq "53")||($pat_cfg eq "54"))	{$mode = I2C10_mode;	`hpti 'SQSL "pm35160_bsdl_reva_cfg49_cfg53_DC_DC"'`; `hpti 'FTST?'`;}
				

			        # foreach $put (@i3c_all_put) {
					   # if (($pat_cfg eq "43")||($pat_cfg eq "45")||($pat_cfg eq "47")||($pat_cfg eq "49")||($pat_cfg eq "51")||($pat_cfg eq "53"))		{	&vih($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],VIH,0,$force_vih,$pat_cfg);}
				       # elsif (($pat_cfg eq "44")||($pat_cfg eq "46")||($pat_cfg eq "48")||($pat_cfg eq "50")||($pat_cfg eq "52")||($pat_cfg eq "54"))	{	&vil($vdd_v,$put,$mode,$retval_array2[1],$retval_array1[1],VIL,0,$force_vih,$pat_cfg);}
			        # }											
			    # }
			# }
		    # `hpti 'DRLV $lvl,0,1800,($put)'`; #restore initial drive low/high  

			# $subject="$hostname\_VILH_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
			# create_time_file($time_file_path, $subject);
		# }					
	}
}
	

# reinit the DPS supplies to nominal
foreach $supply_name (@supply_name_array) {
	`hpti 'PSLV $dps,$typ_supply{$supply_name},$pwr_loads{$supply_name},LOZ,$pwr_seq{$supply_name},($supply_name)'`;
}

#powerdown the device
`disconnect`;
			# $c_subject='"Current repeat count:"' . $current_count;


if ($test eq "all") {
	close fh_leak;
	close fh_vilh;
	close fh_sch_vilh;
	close fh_iolh;
	close fh_volh;
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

$subject="$hostname\_*** All_tests_DONE" . "_" . $split . "_" . $device . "_" . $test_temp . "_" . $test_mode;
create_time_file($time_file_path, $subject);

exit;

# sub iolh_sweep_binary {
    
	# my($vddo_v,$Vin_set,$put_i,$pat_cfg,$vdd_gpio,$ilimit,$meas) = @_;
	
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
    
	my($vddo_v,$put_set,$iolh_cfg,$mode,$vdd_gpio,$vddc,$ilimit,$parameter) = @_;
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
		&volh_return_val_datalog($ret_val_string,$iforce,$vdd_gpio,$vddc,$parameter);		

	
	
	
	
}

sub volh_return_val_datalog{
my($ret_val_string,$iforce,$vdd_gpio,$vddc,$parameter) = @_;
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

						print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vdd_gpio,$vddc,");
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
				print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$temp,iolh_cfg_$iolh_cfg,$mode,$vdd_gpio,$vddc,");
				print fh_volh ("$put,$parameter,$meas_volt,$iforce\n");	
			}
		}

	}	
}

# sub lvcmos_volh {

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

	# print fh_volh ("$current_count,$rep,$split,$device,$test_mode,$junction_temp,$case_temp,$temp,$cal_reference,$device_HIZ,$vdd_lvdsrx_level,");
	# print fh_volh ("$put_v,$Iin_set,$lo_limit,$hi_limit,$meas_mV\n");
	
# }

