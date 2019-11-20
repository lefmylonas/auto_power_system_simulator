LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY HISTORY_CURRENTS IS
    port(V_branch, I_br: in matrix(1 to No_Brn, 1 to 1);
	 I_hs: out matrix(1 to No_Brn, 1 to 1));
END HISTORY_CURRENTS;

ARCHITECTURE arch OF HISTORY_CURRENTS IS

begin

Ihs_loop: for i in 1 to No_Brn generate
	Normal_brn: if signed(Transf(i,1)) = 0 generate -- Normal Branch
	   I_hs(i,1) <= calc_hist_currents(i,signed(V_branch(i,1)),signed(I_br(i,1)));
	end generate;
	
	Transf_brn: if signed(Transf(i,1)) /= 0 generate -- Transformer Secondary Branch
	   I_hs(i,1) <= calc_hist_currents(i,signed(V_branch(i,1)),signed(I_br(i,1)),signed(V_branch(i+1,1)));
	end generate;
	
end generate;

END arch;