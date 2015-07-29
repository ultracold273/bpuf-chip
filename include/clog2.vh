///---------------------------------------------
///
///---------------------------------------------
function integer clog2
input [31:0] value
for (clog2 = 0; value > 0;clog2 = clog2 + 1) begin
    value = value >> 1;
end
endfunction
