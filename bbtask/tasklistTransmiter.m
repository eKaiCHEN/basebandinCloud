function [dataIn, dataOut, txSig, rxSig, dataRx, yRec, csr]...
= commlteSISO_Tx(nS, snrdB, prmLTEDLSCH, prmLTEPDSCH, prmMdl)
%% TX
% Generate payload
dataIn = genPayload(nS, prmLTEDLSCH.TBLenVec);
% Transport block CRC generation
tbCrcOut1 =CRCgenerator(dataIn);
% Channel coding includes - CB segmentation, turbo coding, rate matching,
% bit selection, CB concatenation - per codeword
[data, Kplus1, C1] = lteTbChannelCoding(tbCrcOut1, nS, prmLTEDLSCH, prmLTEPDSCH); %Scramble codeword
scramOut = lteScramble(data, nS, 0, prmLTEPDSCH.maxG);
% Modulate
modOut = Modulator(scramOut, prmLTEPDSCH.modType);
% Generate Cell-Specific Reference (CSR) signals
csr = CSRgenerator(nS, prmLTEPDSCH.numTx);
% Resource grid filling
E=8*prmLTEPDSCH.Nrb;
csr_ref=reshape(csr(1:E),2*prmLTEPDSCH.Nrb,4);
txGrid = REmapper_1Tx(modOut, csr_ref, nS, prmLTEPDSCH);
% OFDM transmitter
txSig = OFDMTx(txGrid, prmLTEPDSCH);
% Send txsig to Redis
r=Redis();
ret=r.set('TxSig',txSig)
r.delete;
end
