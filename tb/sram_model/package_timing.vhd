--************************************************************************
--**    MODEL   :       package_timing.vhd                              **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 (Created new timing package model)          ** 
--************************************************************************


library IEEE,std;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_textio.all ;
use std.textio.all ;

--****************************************************************

package package_timing is

------------------------------------------------------------------------------------------------
-- Read Cycle timing
------------------------------------------------------------------------------------------------
constant    tRC    :   TIME    :=   45 ns;     --   Read Cycle Time	    
constant    tAA    :   TIME    :=   45 ns;    --   Address to Data Valid
constant    tOHA   :   TIME    :=   10 ns;     --   Data Hold from Address Change
constant    tACE   :   TIME    :=   45 ns;    --   Random access CEb Low to Data Valid
constant    tDOE   :   TIME    :=   22 ns;     --   OE Low to Data Valid
constant    tLZOE  :   TIME    :=   5 ns;     --   OE Low to LOW Z
constant    tHZOE  :   TIME    :=   18 ns;     --   OE High to HIGH Z
constant    tLZCE  :   TIME    :=   10 ns;     --   CEb LOW to LOW Z
constant    tHZCE  :   TIME    :=   18 ns;     --   CEb HIGH to HIGH Z

constant    tDBE   :   TIME	:=  45 ns;     --   BHE/BLE LOW to Data Valid
constant    tLZBE  :   TIME	:=  5 ns;     --   BHE/BLE LOW to LOW Z
constant    tHZBE  :   TIME	:=  18 ns;     --   BHE/BLE HIGH to HIGH Z

------------------------------------------------------------------------------------------------
-- Write Cycle timing
------------------------------------------------------------------------------------------------
constant    tWC    :   TIME    :=   45 ns;    --   Write Cycle Time
constant    tSCE   :   TIME    :=   35 ns;     --   CEb LOW to Write End

constant    tAW    :   TIME    :=   35 ns;     --   Address Setup to Write End
constant    tSA    :   TIME    :=   0 ns;     --   Address Setup to Write Start
constant    tHA    :   TIME    :=   0 ns;     --   Address Hold from Write End

constant    tPWE   :   TIME    :=   35 ns;     --   WEb pulse width

constant    tSD    :   TIME    :=   25 ns;     --   Data Setup to Write End 
constant    tHD    :   TIME    :=   0 ns;     --   Data Hold from Write End

constant    tBW    :   TIME    :=   35 ns;     --   BHE BLE Setup to Write End

constant    tLZWE  :   TIME    :=   10 ns;     --   WEb Low to High Z
constant    tHZWE  :   TIME    :=   18 ns;     --   WEb High to Low Z

end package_timing;


package body package_timing is

end package_timing;















