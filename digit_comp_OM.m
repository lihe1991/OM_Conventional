% 1. x(ite=0), y(ite=0) is the original input data with 8 bits.
% 2. Computation Algorithm
% For k = 0,1,2,3
% P(ite = k+1) = P(ite=k) /* y(ite=0), where P(ite=0) = x(ite=0);
% End
% 3. Computation Results
% x(ite=0)^+ = [1,1,0,0,1,0,0,1]; x(ite=0)^- = [0,0,0,1,0,0,1,0]
% x(ite=0) = [1,1,0,-1,1,0,-1,1] = 0.7109(signed)/0.7148(bin)
% y(ite=0)^+ = [1,0,1,0,0,1,1,0]; y(ite=0)^- = [0,0,0,1,1,0,0,0];
% y(ite=0) = [1,0,1,-1,-1,1,1,0] = 0.5547; 
% p(ite=1)^+ = [1,0,0,0,1,0,1,0]; p(ite=0)^- = [0,0,1,0,0,1,0,0]
% p(ite=1)^+ = [1,0,0,0,1,0,1,0,0]; p(ite=1)^- = [0,0,1,0,0,1,0,0,1];
% p(ite=1)= [1,0,-1,0,1,-1,1,0] = 0.3984 // [1,0,-1,0,1,-1,1,0,-1] = 0.3964
% p(ite=2)^+ = [0,1,0,0,0,0,0,0,1,0]; p(ite=2)^- = [0,0,0,0,1,0,0,0,1];
% p(ite=2)^+ = [0,1,0,0,0,0,0,0,1,0,0,1]; p(ite=2)^- = [0,0,0,0,1,0,0,0,1,0,0];
% p(ite=2) = [0,1,0,0,-1,0,0,1,-1] = 0.2207 // [0,1,0,0,-1,0,0,1,-1,0,1] = 0.2212
% p(ite=3)^+ = [0,0,1,0,0,0,0,0,1,0,0,1,0,0,0]; p(ite=3)^- = [0,0,0,0,0,0,0,1,0,0,1,0,1,0,0]
% p(ite=3) = [0,0,1,0,0,0,0,-1,1,0,-1,1,-1,0,0] = 0.1277


function [call,v_int1, v_int0,v_frac1, v_frac0,wt1,wt0,wc1,wc0,w_int1,w_int0,w_frac1, w_frac0, shift_o1, shift_o0, cout_one1, cout_one0, cout_two1, cout_two0,compare_frac,CAx1_sel, CAx0_sel,CAy1_sel, CAy0_sel,CAx1,CAx0,CAy1,CAy0,u_r,wr_addr,rd_addr,enable,add_enable,res_enable,x1_value,x0_value,y1_value,y0_value,p_value1,p_value0]=digit_comp_OM(xin1,xin0,y1,y0,n,u,ite_input_r)
%function [p_value1,p_value0]=MUL_0104(xin1,xin0,y1,y0,n,u,ite_input_r)   %,cin_one1,cin_one0,cin_two1,cin_two0)
%function [v_int1, v_int0,w_int1,w_int0,w_frac1, w_frac0, shift_o1, shift_o0,v_frac1, v_frac0, cout_one1, cout_one0, cout_two1, cout_two0,compare_frac,CAx1_sel, CAx0_sel,CAy1_sel, CAy0_sel,CAx1,CAx0,CAy1,CAy0,ite_input_r,u_r,wr_addr,rd_addr,enable,add_enable,res_enable,x1_value,x0_value,y1_value,y0_value,p_value1,p_value0]=MUL_1227(operand1,operand0,y1,y0)   %,cin_one1,cin_one0,cin_two1,cin_two0)
%function [a1,w_frac1,p_value1,p_value0]=MUL_1227(operand1,operand0,y1,y0)   %,cin_one1,cin_one0,cin_two1,cin_two0)
% if(isempty(p1)&&isempty(p0))
 persistent flag;
 % BRAM_frac
persistent w1_wr_frac;
persistent w0_wr_frac;
    if(isempty(w1_wr_frac)&& isempty(w0_wr_frac))
        w1_wr_frac=zeros(256,16);  % 64*4
        w0_wr_frac=zeros(256,16);
    end
 % BRAM_int
persistent w1_wr_int;
persistent w0_wr_int;
    if(isempty(w1_wr_int)&& isempty(w0_wr_int))
        w1_wr_int=zeros(256,5);  
        w0_wr_int=zeros(256,5);
    end
    
% persistent p1;
% persistent p0;
%  if isempty(flag)
%       p1=0;p0=0;
%  end
% 
% 
% [Arx1,Arx0,~,~,~,xin1,xin0]=digitreuse(operand1,operand0,p1,p0);   %yes

    %y1y0 == '10'; 
%different BRAM from digitreuse coz "x_ori" is only read in digitreuse but both "write" and "read" in control and CA_gen 
[u_r,wr_addr,rd_addr,enable,add_enable,res_enable,x1_value,x0_value,y1_value,y0_value] = control_v2(xin1,xin0,y1,y0,n,u);

[CAx1,CAx0,CAy1,CAy0] = CA_gen(x1_value,x0_value,y1_value,y0_value,wr_addr,rd_addr,u_r,ite_input_r,enable);%,refresh);

[CAx1_sel, CAx0_sel]=SDVM(y1_value,y0_value,CAx1,CAx0);
[CAy1_sel, CAy0_sel]=SDVM(x1_value,x0_value,CAy1,CAy0);

% if(isempty(cin_one1)&&isempty(cin_one0)&&isempty(cin_two1)&&isempty(cin_two0))
persistent cin_one1; persistent cin_one0; persistent cin_two1; persistent cin_two0;
persistent CAw_frac1; persistent CAw_frac0;
if isempty(flag)
     cin_one1 = 0; cin_one0 = 0; cin_two1 = 0; cin_two0 = 0;CAw_frac1=zeros(1,16);CAw_frac0=zeros(1,16);
else
    % BRAM_frac read
CAw_frac1=w1_wr_frac(pairing(rd_addr,ite_input_r),:);
CAw_frac0=w0_wr_frac(pairing(rd_addr,ite_input_r),:);
end
wc1=CAw_frac1;
wc0=CAw_frac0;
% end
%cin_one1 = 0; cin_one0 = 0; cin_two1 = 0; cin_two0 = 0; assign 0 at the start
%16-bit adder;

[v_frac1, v_frac0, cout_one1, cout_one0, cout_two1, cout_two0,compare_frac] = paralleladder(CAx1_sel,CAx0_sel,CAy1_sel,CAy0_sel,CAw_frac1,CAw_frac0,cin_one1,cin_one0,cin_two1,cin_two0);

% adder_control only valid when n>1; so cin_one & cin_two also need BRAM
%adder_control
if add_enable==1
    cin_one1 = cout_one1;  
    cin_one0 = cout_one0;
    cin_two1 = cout_two1;
    cin_two0 = cout_two0;
else
    cin_one1 = 0;
    cin_one0 = 0;
    cin_two1 = 0;
    cin_two0 = 0;
end

persistent CAw1_int; persistent CAw0_int;
a=zeros(1,5);

if isempty(flag)
    CAw1_int=zeros(1,5); CAw0_int=zeros(1,5); 
else
    CAw1_int=w1_wr_int(pairing(rd_addr,ite_input_r),:);
    CAw0_int=w0_wr_int(pairing(rd_addr,ite_input_r),:);
end
    wt1 = CAw1_int;
    wt0 = CAw0_int;

%5-bit adder
% BRAM_int read
[v_int1, v_int0, ~, ~, ~, ~,~] = paralleladder_int(a,a,a,a,CAw1_int,CAw0_int,cout_one1,cout_one0, cout_two1, cout_two0);

[w_frac1, w_frac0, shift_o1, shift_o0] = V_frac(v_frac1,v_frac0,rd_addr,wr_addr,ite_input_r,res_enable);     %V_frac1, V_frac2;
%CAw_frac1=w_frac1; CAw_frac0 = w_frac0;
% BRAM_frac write
w1_wr_frac(pairing(wr_addr,ite_input_r),:)=w_frac1;
w0_wr_frac(pairing(wr_addr,ite_input_r),:)=w_frac0;

[p_value1,p_value0,w_int1,w_int0] = V_upper(compare_frac,v_int1,v_int0,shift_o1,shift_o0,wr_addr,rd_addr, ite_input_r);
%CAw1_int = w_int1; CAw0_int = w_int0;
% BRAM_int write
w1_wr_int(pairing(wr_addr,ite_input_r),:)=w_int1;
w0_wr_int(pairing(wr_addr,ite_input_r),:)=w_int0;
p1=p_value1; p0=p_value0;
persistent count_call
if isempty(count_call)
    count_call=1; 
else
count_call = count_call+1;
end
call=count_call;
flag =1;
end

