function [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr]...
= commlteSISO_Rx(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl)

% get txsig from Redis
r=Redis();
ret=r.get('TxSig',txSig)
r.delete;

%% Channel
% SISO Fading channel
[rxFade, chPathG] = MIMOFadingChan(txSig, prmLTEPDSCH, prmMdl);
idealhD = lteIdChEst(prmLTEPDSCH, prmMdl, chPathG, nS);
% Add AWG noise
nVar = 10.^(0.1.*(-snrdB));
rxSig = AWGNChannel(rxFade, nVar);
%% RX
% OFDM Rx
rxGrid = OFDMRx(rxSig, prmLTEPDSCH);
% updated for numLayers -> numTx
[dataRx, csrRx, idx_data] = REdemapper_1Tx(rxGrid, nS, prmLTEPDSCH);
% MIMO channel estimation
if prmMdl.chEstOn
chEst = ChanEstimate_1Tx(prmLTEPDSCH, csrRx, csr_ref, 'interpolate');
hD=chEst(idx_data).';
else
hD = idealhD;
end
% Frequency-domain equalizer
yRec = Equalizer(dataRx, hD, nVar, prmLTEPDSCH.Eqmode);
% Demodulate
demodOut = DemodulatorSoft(yRec, prmLTEPDSCH.modType, nVar);
% Descramble both received codewords
rxCW = lteDescramble(demodOut, nS, 0, prmLTEPDSCH.maxG);
% Channel decoding includes - CB segmentation, turbo decoding, rate dematching
[decTbData1, ̃,̃] = lteTbChannelDecoding(nS, rxCW, Kplus1, C1, prmLTEDLSCH, prmLTEPDSCH);
% Transport block CRC detection
[dataOut, ̃] = CRCdetector(decTbData1);
end
