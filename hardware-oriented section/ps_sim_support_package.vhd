LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE WORK.SUPPORT_PACKAGE.ALL;

PACKAGE PS_SIM_SUPPORT_PACKAGE IS

constant n: integer :=init_coef(1);
type matrix is array (natural range <>,natural range <>) of std_logic_vector(n-1 downto 0);
type intmtrx is array (natural range <>,natural range <>) of integer;

impure function init(constant name: string;
		     constant dim1, dim2: integer) return matrix;
impure function init_info(constant name: string;
		     	  constant dim1: integer) return intmtrx;

END PS_SIM_SUPPORT_PACKAGE;

PACKAGE BODY PS_SIM_SUPPORT_PACKAGE IS

impure function init(constant name: string;
		     constant dim1, dim2: integer) return matrix is -- Initializing a matrix
file inp: text;
constant s: string(1 to name'high + 4) := (name & ".txt");
variable G: matrix(1 to dim1, 1 to dim2);
variable l: line;
variable v: std_logic_vector(n-1 downto 0);
variable good: boolean;
begin

file_open(inp, s, read_mode);
-- Reading matrix values
matrices_data_rows: for i in 1 to dim1 loop
	matrices_data_cols: for j in 1 to dim2 loop
		readline(inp, l);
		read(l, v, good);
		assert good report "error in reading a matrix coefficient";
		G(i,j) := v;
	end loop;
end loop;

file_close(inp);
return G;

end init;

impure function init_info(constant name: string;
		     	  constant dim1: integer) return intmtrx is -- Returns BrnInfo matrix
file inp: text;
constant s: string(1 to name'high + 4) := (name & ".txt");
variable Info: intmtrx(1 to dim1, 1 to 2);
variable v: std_logic_vector(9 downto 0);
variable l: line;
variable good: boolean;
begin

file_open(inp, s, read_mode);

-- Reading matrix
Info_rows: for i in 1 to dim1 loop
	Info_cols: for j in 1 to 2 loop
		readline(inp, l);
		read(l, v, good);
		assert good report "error in reading a matrix coefficient";
		Info(i,j) := to_integer(unsigned(v));
	end loop;
end loop;

file_close(inp);
return Info;

end init_info;

END PS_SIM_SUPPORT_PACKAGE;
