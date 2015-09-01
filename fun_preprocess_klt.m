function trks_new = fun_preprocess_klt(trks, delete_th1, delete_th2, delete_th3)

trks_new = trks;
tr_num = 1; tr_num2 = 1;

%% Delete
while tr_num <= length(trks_new)
    if ~isempty(delete_th1)
        if length(trks_new(tr_num).x) <= delete_th1 || (trks_new(tr_num).x(1) == trks_new(tr_num).x(end) && ...
                trks_new(tr_num).y(1) == trks_new(tr_num).y(end)) || ...
                (sqrt((trks_new(tr_num).x(end)- trks_new(tr_num).x(1))^2 + ...
                (trks_new(tr_num).y(end)-trks_new(tr_num).y(1))^2) < delete_th2)
            % 
            trks_short(tr_num2) = trks_new(tr_num);
            tr_num2 = tr_num2 + 1;
            % delete the data of x&y both unchange
            trks_new(tr_num) = [];
            tr_num = tr_num - 1;
        elseif length(trks_new(tr_num).t) ~= (trks_new(tr_num).t(end)-trks_new(tr_num).t(1)+1)
            % 
            trks_short(tr_num2) = trks_new(tr_num);
            tr_num2 = tr_num2 + 1;
            %
            trks_new(tr_num) = [];
            tr_num = tr_num - 1;
        else
            % delete the data of small change
            count = 0;
            for  t = 1 :length(trks_new(tr_num).y)-1
                if trks_new(tr_num).y(t+1) == trks_new(tr_num).y(t) && ...
                        trks_new(tr_num).x(t+1) == trks_new(tr_num).x(t)
                    continue;
                end
                count = count + 1;
            end
            
            if count < length(trks_new(tr_num).y)/3
                %
                trks_short(tr_num2) = trks_new(tr_num);
                tr_num2 = tr_num2 + 1;
                %
                trks_new(tr_num) = [];
                tr_num = tr_num - 1;
            else
                % new1: delete repeat
                for t = 1 : length(trks_new(tr_num).y)-3
                    same_n = t;
                    while same_n+1 < length(trks_new(tr_num).y) && ...
                            abs(trks_new(tr_num).y(same_n+2)-trks_new(tr_num).y(same_n)) < 1 && ...
                            abs(trks_new(tr_num).x(same_n+2)-trks_new(tr_num).x(same_n)) < 1
                        %                 while same_n+3 < length(trks_new(tr_num).y) && ...
                        %                         abs(trks_new(tr_num).y(same_n+2)-trks_new(tr_num).y(same_n)) < 2 && ...
                        %                         abs(trks_new(tr_num).x(same_n+2)-trks_new(tr_num).x(same_n)) < 2
                        same_n = same_n + 1;
                    end
                    if same_n-t > delete_th3
                        %
                        trks_short(tr_num2) = trks_new(tr_num);
                        tr_num2 = tr_num2 + 1;
                        %
                        trks_new(tr_num) = [];
                        tr_num = tr_num - 1;
                        break;
                    end
                end
            end
        end
    else
        if (trks_new(tr_num).x(1) == trks_new(tr_num).x(end) && ...
                trks_new(tr_num).y(1) == trks_new(tr_num).y(end)) || ...
                (sqrt((trks_new(tr_num).x(end)- trks_new(tr_num).x(1))^2 + ...
                (trks_new(tr_num).y(end)-trks_new(tr_num).y(1))^2) < delete_th2)
            %
            trks_short(tr_num2) = trks_new(tr_num);
            tr_num2 = tr_num2 + 1;
            % delete the data of x&y both unchange
            trks_new(tr_num) = [];
            tr_num = tr_num - 1;
        elseif length(trks_new(tr_num).t) ~= (trks_new(tr_num).t(end)-trks_new(tr_num).t(1)+1)
            % 
            trks_short(tr_num2) = trks_new(tr_num);
            tr_num2 = tr_num2 + 1;
            %
            trks_new(tr_num) = [];
            tr_num = tr_num - 1;
        else
            % delete the data of small change
            count = 0;
            for  t = 1 :length(trks_new(tr_num).y)-1
                if trks_new(tr_num).y(t+1) == trks_new(tr_num).y(t) && ...
                        trks_new(tr_num).x(t+1) == trks_new(tr_num).x(t)
                    continue;
                end
                count = count + 1;
            end
            
            if count < length(trks_new(tr_num).y)/3
                %
                trks_short(tr_num2) = trks_new(tr_num);
                tr_num2 = tr_num2 + 1;
                %
                trks_new(tr_num) = [];
                tr_num = tr_num - 1;
            else
                % new1: delete repeat
                for t = 1 : length(trks_new(tr_num).y)-3
                    same_n = t;
                    while same_n+1 < length(trks_new(tr_num).y) && ...
                            abs(trks_new(tr_num).y(same_n+2)-trks_new(tr_num).y(same_n)) < 1 && ...
                            abs(trks_new(tr_num).x(same_n+2)-trks_new(tr_num).x(same_n)) < 1
                        %                 while same_n+3 < length(trks_new(tr_num).y) && ...
                        %                         abs(trks_new(tr_num).y(same_n+2)-trks_new(tr_num).y(same_n)) < 2 && ...
                        %                         abs(trks_new(tr_num).x(same_n+2)-trks_new(tr_num).x(same_n)) < 2
                        same_n = same_n + 1;
                    end
                    if same_n-t > delete_th3
                        %
                        trks_short(tr_num2) = trks_new(tr_num);
                        tr_num2 = tr_num2 + 1;
                        %
                        trks_new(tr_num) = [];
                        tr_num = tr_num - 1;
                        break;
                    end
                end
            end
        end
    end
    tr_num = tr_num + 1;
end









