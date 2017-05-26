-------------------------------------------------------------------------------
-- Title      : "my_functions"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : my_functions.vhdl
-- Author     : Tom Scott www.missiontech.co.nz
-- Company    : Mission Technologies        
-- Created    : 2007-02-05
-- Last update: 2007-03-30
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Creates a add and truncate function
-- Based on "Circuit Design with VHDL" by Volnei A. Pedroni
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-02-05  1.0      toms    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

package my_functions is
  function add_truncate (signal a, b : signed; size : integer) return signed;
end my_functions;

package body my_functions is

 
  function add_truncate ( signal a, b : signed; size : integer) return signed is
    variable result : signed(7 downto 0);
  begin
    result := a + b;
    if(a(a'left)=b(b'left))and
      (result(result'left)/=a(a'left))then
      result := (result'left => a(a'left), others =>  not a(a'left));
    end if;
    return result;
  end add_truncate;

end my_functions;
