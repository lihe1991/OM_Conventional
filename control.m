%function [wr_addr,rd_addr,refresh,enable,add_enable,res_enable,x1_value,x0_value,y1_value,y0_value] = control(n,u,x1,x0,y1,y0)
function [ite_input_r,u,wr_addr,rd_addr,enable,add_enable,res_enable,x1_value,x0_value,y1_value,y0_value] = control(x1,x0,y1,y0)
persistent ite_output_count;     %call function once, ite_output_count add one. FUNCTION as Counter
    if(isempty(ite_output_count))
        ite_output_count=1;
    else
        ite_output_count=ite_output_count+1;
    end

persistent ite_count;
persistent ite_input_count;  
    if(isempty(ite_count))
        ite_count=0;
    end
    if(isempty(ite_input_count))
        ite_input_count=0;
    end 
    if ite_output_count == (1 + (ite_count + 1)*ite_count / 2)  % 
		ite_count=ite_count+1;    % Diagonal Count, next one
        ite_input_count = 0;      % Iteration Count  
	else
		ite_input_count = ite_input_count + 1;
    end
	n=floor((ite_count-ite_input_count)/64);
	%u = 63 - (ite_count-N_depth*64) + ite_input_count;
    u = (ite_count- n * 64) - ite_input_count;        %begin from 1 to 64
    ite_input_r = ite_input_count;
%CA_register    

IDLE=0;
COMP=1;
REST=2;
enable_fifo = 1;
persistent state;
if(enable_fifo == 1)
    if(n==0 || (n==1 &&u==0))
        state = IDLE;
    else
        state = COMP;
    end
end
switch (state)
    case IDLE
        if(n==1 && u==0)
            state = COMP;
            %accum = 1;
            wr_addr = n;  
            enable_fifo = 0;
        else
            x1_value = x1;
            x0_value = x0;
            y1_value = y1;
            y0_value = y0;
            refresh = 0;
            wr_addr = n;    %initial wr_addr=0 in verilog
        end
        if (n==0 && u==64)
            refresh = 1;
        else
            refresh = 0;
        end
    case COMP
        state = REST;
        x1_value = x1;
        x0_value = x0;
        y1_value = y1;
        y0_value = y0;
        if(u==64)
            %accum = n;
            refresh = 1;
        else
            refresh = 0;
        end
        %wr_addr = wr_addr - 1;
        wr_addr = n;
    case REST
        if(wr_addr == 0) 
            enable_fifo = 1;
            %state = COMP;
            %wr_addr = accum;
        else
            wr_addr = wr_addr - 1;
        end
%%%%%wr_addr is valid in "CA_gen", invalid in "V_frac"
end
switch (state)
    case IDLE
        add_enable = 0;
        enable = 1;
        if(refresh == 1)
            rd_addr = 1;
        else
            rd_addr = 0;
        end
        res_enable = 1;
    case COMP
        add_enable = 1;
        enable = 1;
        rd_addr = n;
        res_enable = 1;
    case REST
        enable = 0;
        rd_addr = n-1;
        res_enable = 1;
        if(wr_addr == 0)
            add_enable = 0; 
            %add_enable = 1;
        else
            add_enable = 1;
        end 
end


