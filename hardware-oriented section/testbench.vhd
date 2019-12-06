library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is

COMPONENT TOP_LEVEL
	port(rst,clk: in std_logic;
		  V_s: in matrix(1 to No_Vk, 1 to 1) := (others=>(others=>(others=>'0')));
	     I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	     Vnodal: out matrix(1 to No_Nodes, 1 to 1);
	     Ibranch: out matrix(1 to No_Brn, 1 to 1));
END COMPONENT;

constant clk_period: time := 1 ns;
constant I_s: matrix(1 to No_Src-No_Vk, 1 to samples) :=init("I_s", No_Src-No_Vk, samples);
signal clk: std_logic := '1';
signal rst: std_logic := '1';
signal current_Vnodal: matrix(1 to No_Nodes, 1 to 1);
signal current_Ibranch: matrix(1 to No_Brn, 1 to 1);
signal current_Is: matrix(1 to No_Src-No_Vk, 1 to 1);
signal Vnodal: matrix(1 to No_Nodes, 1 to samples+1);
signal Ibranch: matrix(1 to No_Brn, 1 to samples+1);

procedure save_report(constant G: matrix;
                      constant name: in string;
		              constant dim1, dim2: in integer) is -- Initializing a matrix
file inp: text;
constant s: string(1 to name'high + 4) := (name & ".txt");
variable l: line;
begin

file_open(inp, s, write_mode);
-- Writing matrix values
matrices_data_cols: for j in 1 to dim2 loop
	matrices_data_rows: for i in 1 to dim1 loop
	    write(l, G(i,j));
		writeline(inp,l);
	end loop;
end loop;
file_close(inp);

end save_report;

begin

DUT: TOP_LEVEL port map(rst => rst,clk => clk, V_s => open, I_s => current_Is,Vnodal => current_Vnodal,Ibranch => current_Ibranch);

clk_process: process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;

stim_proc: process
   begin
		wait for 3*clk_period/2;
		rst<='0';
		for j in 2 to samples loop
		      for i in 1 to No_Src-No_Vk loop
		              current_Is(i,1) <= I_s(i,j);
		      end loop;
		      for i in 1 to No_Nodes loop
		              Vnodal(i,j-1) <= current_Vnodal(i,1);
		      end loop;
		      for i in 1 to No_Brn loop
		              Ibranch(i,j-1) <= current_Ibranch(i,1);
		      end loop;
		      wait for clk_period;
		end loop;
        for j in samples to samples+1 loop
		      for i in 1 to No_Nodes loop
		              Vnodal(i,j) <= current_Vnodal(i,1);
		      end loop;
		      for i in 1 to No_Brn loop
		              Ibranch(i,j) <= current_Ibranch(i,1);
		      end loop;
		      wait for clk_period;
		end loop;
		save_report(Vnodal,"Vnodal_report",No_Nodes,samples+1);
		save_report(Ibranch,"Ibranch_report",No_Brn,samples+1);
		wait;
   end process;

end Behavioral;
