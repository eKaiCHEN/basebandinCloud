function hD = ChanEstimate_1Tx(prmLTE, Rx, Ref, Mode) 
%#codegen
Nrb = prmLTE.Nrb; % Number of resource blocks Nrb_sc = prmLTE.Nrb_sc; % 12 for normal mode Ndl_symb = prmLTE.Ndl_symb; % 7 for normal mode % Assume same number of Tx and Rx antennas = 1
% Initialize output buffer
hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2));
% Estimate channel based on CSR - per antenna port
csrRx = reshape(Rx, numel(Rx)/4, 4); % Align received pilots with reference pilots hp = csrRx./Ref; % Just divide received pilot by reference pilot
% to obtain channel response at pilot locations
% Now use some form of averaging/interpolation/repeating to
% compute channel response for the whole grid
% Choose one of 3 estimation methods "average" or "interpolate" or "hybrid" switch Mode
case 'average'
hD=gridResponse_averageSubframe(hp, Nrb, Nrb_sc, Ndl_symb);
case 'interpolate'
hD=gridResponse_interpolate(hp, Nrb, Nrb_sc, Ndl_symb);
otherwise
error('Choose the right mode for function ChanEstimate.'); end
end

function hD=gridResponse_interpolate(hp, Nrb, Nrb_sc, Ndl_symb) % Interpolate among subcarriers in each OFDM symbol
% containing CSR (Symbols 1,5,8,12)
% The interpolation assumes NCellID = 0.
% Then interpolate between OFDM symbols
hD = complex(zeros(Nrb*Nrb_sc, Ndl_symb*2)); N=size(hp,2);
Separation=6;
Edges=[0,5;3,2;0,5;3,2];
Symbol=[1,5,8,12];
% First: Compute channel response over all resource elements of OFDM symbols 0,4,7,11
for n=1:N
Edge=Edges(n,:);
y = InterpolateCsr(hp(:,n), Separation, Edge); hD(:,Symbol(n))=y;
end
% Second: Interpolate between OFDM symbols {0,4} {4,7}, {7, 11}, {11, 13}
for m=[2, 3, 4, 6, 7]
alpha=0.25*(m-1);
beta=1-alpha;
hD(:,m) = beta*hD(:,1) + alpha*hD(:, 5); hD(:,m+7) =beta*hD(:,8) + alpha*hD(:,12);
end

function hD=gridResponse_averageSubframe(hp, Nrb, Nrb_sc, Ndl_symb)
% Average over the two same Freq subcarriers, and then interpolate between % them - get all estimates and then repeat over all columns (symbols).
% The interpolation assumes NCellID = 0.
% Time average two pilots over the slots, then interpolate (F)
% between the 4 averaged values, repeat for all symbols in subframe
h1_a1 = mean([hp(:, 1), hp(:, 3)],2);
h1_a2 = mean([hp(:, 2), hp(:, 4)],2);
h1_a_mat = [h1_a1 h1_a2].';
h1_a = h1_a_mat(:);
h1_all = complex(zeros(length(h1_a)*3,1));
for i = 1:length(h1_a)-1
delta = (h1_a(i+1)-h1_a(i))/3; h1_all((i-1)*3+1) = h1_a(i); h1_all((i-1)*3+2) = h1_a(i)+delta; h1_all((i-1)*3+3) = h1_a(i)+2*delta;
end
% fill the last three - use the last delta
h1_all(end-2) = h1_a(end);
h1_all(end-1) = h1_a(end)+delta;
h1_all(end) = h1_a(end)+2*delta;
% Compute the channel response over the whole grid by repeating hD = h1_all(1:Nrb*Nrb_sc, ones(1, Ndl_symb*2));
end
