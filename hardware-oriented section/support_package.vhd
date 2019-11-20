LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

PACKAGE SUPPORT_PACKAGE IS

impure function init_coef(constant index: in integer) return integer;

END SUPPORT_PACKAGE;

PACKAGE BODY SUPPORT_PACKAGE IS

impure function init_coef(constant index: in integer) return integer is -- Returns value of specified coefficient
file inp: text;
variable l: line;
variable v: std_logic_vector(14 downto 0);
variable i: integer :=0;
variable good: boolean;
begin

file_open(inp, "coeffs.txt",  read_mode);
-- Searching for desired coefficient
unused_data: while (i /= index) loop
	i := i + 1;
	readline(inp, l);
end loop;
read(l, v, good); -- Reading its value
assert good report "error in reading the specified coefficient";

file_close(inp);
return to_integer(unsigned(v));

end init_coef;

END SUPPORT_PACKAGE;