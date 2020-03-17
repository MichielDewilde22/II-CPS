function [dataMics] = appReadSonar(serSONAR, numDataSamples, newArch)

    if ~newArch
        fprintf(serSONAR, '!F,0,0,0.0\n');
        rawData = fread( serSONAR, numDataSamples, 'uint16' );


        % Process
        numSamplesPort = numDataSamples / 2;

        % Parse
        dataPort1 = de2bi(rawData(1:numSamplesPort), 16) ;
        dataPort2 = de2bi(rawData(numSamplesPort+1:end), 16);


        % Filter
        [b,a] = butter(6, 100e3/(4.5e6/2));
        dataFiltered1 = filtfilt( b, a, dataPort1 );
        dataFiltered2 = filtfilt( b, a, dataPort2 );

        dataMics =  [ dataFiltered1( 1:10:end, : ) dataFiltered2( 1:10:end, : ) ];
        dataMics = dataMics - mean( dataMics );
    else
        fprintf(serSONAR, '!F,0,0,0.0\n');
        rawData = fread( serSONAR, numDataSamples/2, 'uint32' );

        data =  de2bi(rawData, 32);

        % Filter
        [b,a] = butter(6, 100e3/(4.5e6/2));
        dataFiltered = (filter( b, a, data ));

        dataMics = dataFiltered(1:10:end, 1:30);
        dataMics = dataMics - mean(dataMics);
    end
end