function F = features(ecg, varargin)

    % Create a parser.
    parameter = inputParser;
    
    % Create the ECGs parser.
    checkECG = @(x) isa(x, 'Signal');
    addRequired(parameter, 'ecg', checkECG);
    
    % Create the Q argument.
    checkQ = @(x) isvector(x) && isnumeric(x);
    addOptional(parameter, 'Q', ecg.Filter('Peak', 'Q'), checkQ);
    
    % Create the R argument.
    checkR = @(x) isvector(x) && isnumeric(x);
    addOptional(parameter, 'R', ecg.Filter('Peak', 'R'), checkR);
    
    % Create the S argument.
    checkS = @(x) isvector(x) && isnumeric(x);
    addOptional(parameter, 'S', ecg.Filter('Peak', 'S'), checkS);
    
    % Parse the input data.
    parse(parameter, ecg, varargin{:});

    % Initialize the F output array.
    F = Features.empty();
    
    % Get the list of the Q-peaks.
    q = [parameter.Results.Q.X];
    
    % Get the list of the R-peaks.
    r = [parameter.Results.R.X];
    
     % Get the list of the S-peaks.
    s = [parameter.Results.S.X];
    
    % Compute the RR' distance (s).
    RR = abs(diff(r));
    
    % Compute the mean of the RR' distances.
    RR_ave = mean(RR);
    
    % Compute the mena of the QR distances.
    RQ_ave = mean(abs(q - r));
    
    % Comput the mean of the RS distances.
    SR_ave = mean(abs(r - s));
    
    % Comput the moving mean of the RR' distances.
    MMRR = movmean(RR, 1500, 'SamplePoints', r(2:end));
    
    for i = 1:numel(RR)-1
       
        % The name of the record (using only the number found in the real
        % record name).
        % FN = Feature('Name', sscanf(regexprep(ecg.Name, '[^\d+]', ''), '%d'));
        FN = Feature('Name', ecg.Name);
        
        % Feature 1: previous interbeat interval.
        F1 = Feature('pRR', RR(i));
        
        % Feature 2: next interbeat interval.
        F2 = Feature('nRR', RR(i + 1));
        
        % Feature 3: average interbeat interval.
        F3 = Feature('aRR', RR_ave);
        
        % Feature 4: moving mean interbeat interval.
        F4 = Feature('mmRR', MMRR(i));
        
        % Feature 5: the distance (from the start) to the S-peaks.
        try
            F5 = Feature('SR', abs(r(i) - s(find(s > r(i), 1, 'first'))));
        catch
            F5 = Feature('SR', SR_ave);
        end
        
        % Feature 6: the distance (from the end) to the Q-peaks.
        try
            F6 = Feature('QR', abs(r(i + 1) - q(find(q < r(i + 1), 1, 'first'))));
        catch
            F6 = Feature('QR', RQ_ave);
        end
        
        % Feature 2: 
        % [*] Heart rate dynamics distinguish among atrial fibrillation, normal
        % sinus rhythm and sinis rhythm with frequent ectopy
        
        % The class of the signal.
        FT = Feature('Target', ecg.Target);
        

        % Save every feature in the features array.
        F(i) = Features(FN, F1, F2, F3, F4, F5, F6, FT);
        
    end

    
end