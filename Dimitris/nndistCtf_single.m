function [ yVal, yInd, Batch ] = nndistCtf_single( Batch, nD, nN, varargin )
%NNDIST Nearest-neighbor distances with single-precision input data
%   
%   [ yVal, yInd ] = nndistCtf_single( Batch, nD, nN ) reads a total of nY data 
%   vectors of dimension nD from the source files specified in Batch, and
%   for each data vector returns the l2 (Euclidean) distances to its nN 
%   nearest neighbors, as well as the corresponding indices of the nearest
%   neighbors.  
%   
%   The input data sources are specified in the structure array Batch with
%   the following fields:
%
%   Batch( i ).filename  -- a .mat file containing the i-th data batch 
%   Batch( i ).batchSize -- the number of datapoints in the batch
%   Batch( i ).dataname  -- the array in Batch( i ).filename containing the
%                           data, which must be of size 
%                           [ nD, Bach( i ).dataName ] 
%
%   The total number of data points is nY = sum_{ i } Batch( i ).batchSize.
%
%   yVal( ( i - 1 ) * nN + ( 1 : nN ) ) contains the distances to the
%   nN nearest neighbors of data point i sorted in ascending order.
%
%   yInd( ( i - 1 ) * nN + ( 1 : nN ) ) contains the indices of the nearest
%   neighbors.
%
%   [ ... ] = nndistCtf_single( Batch, nD, nN, 'batchOut', [ iBatch1, iBatch2 ] )
%   only computes the nearest neighbor distances for the query points in 
%   Batch( iBatch1 : iBatch2 ). This feature is useful when nndist is
%   executed as part of a parallel job. iBatch and iBatch2 are respectively
%   set to 1 and numel( Batch ) by default (i.e. all data points are 
%   processed).
%   
%   [ ... ] = nndist_single( Batch, nD, nN, 'logFile', logFile ) dumps log
%   information in the file logFile. By default, log information is written
%   on screen.
%
%   [ yVal, yInd, Batch ] = nndist_single( ... ) adds the field Batch( i ).gInd to 
%   the data strucure Batch, such that Batch( i ).gInd( 1 ) and 
%   Batch( i ).gInd( 2 ) respectively correspond to the upper and lower 
%   global indices originating from the i-th Batch. This feature is useful
%   when yVal and yInd from parallel processes are to be composed into
%   single vectors.
%
%   nndist_single requires the MinMaxSelection MEXC routines for partial sorting
%   to be available in the path.
%
%   See also DMAT.
%
%   Modified 02/15/2010

nBatch = numel( Batch );          % total number of batches
Options.logfile  = [];            % default logfile (screen)
Options.logfilePermission = 'w';  % overwrite existing logfile
Options.batchOut = [ 1, nBatch ]; % default output range
Options = parseargs( Options, varargin{ : } ); % process optional arguments
if ~isempty( Options.logfile )
    logID = fopen( Options.logfile, Options.logfilePermission );
else
    logID = 1;
end
    
nY  = 0; % global number of distance vectors 
nYL = 0; % number of distance vectors in the current process
nMaxBatchSize = 0;
iBatchL = 1;
for iBatch = 1 : nBatch;
    nMaxBatchSize = max( nMaxBatchSize, Batch( iBatch ).batchSize );
    nYAdd = Batch( iBatch ).batchSize;
    nY = nY + nYAdd;
    if iBatch == 1
        Batch( iBatch ).gInd = [ 1, nYAdd ];
    else
        Batch( iBatch ).gInd = Batch( iBatch - 1 ).gInd( 2 ) ...
            + [ 1, nYAdd ];
    end
    if iBatch >= Options.batchOut( 1 ) && iBatch <= Options.batchOut( 2 )
        nYL = nYL + nYAdd;
        if iBatchL == 1
            Batch( iBatch ).lInd = [ 1, nYAdd ];
        else
            Batch( iBatch ).lInd = Batch( iBatch - 1 ).lInd( 2 ) ...
            + [ 1, nYAdd ];
        end
        iBatchL = iBatchL + 1;
    end
end


clk = clock;
fprintf( logID, 'NNDISTCTF_SINGLE starting on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
   
fprintf( logID, 'Global batch number         = %i \n', nBatch );
fprintf( logID, 'Local batch range           = %i %i \n', ...
    Options.batchOut );
fprintf( logID, 'Global max batch size       = %i \n', nMaxBatchSize );
fprintf( logID, 'Global distance matrix size = %i \n', nY  );
fprintf( logID, 'Local distance matrix rows  = %i \n', nYL );
fprintf( logID, 'Ambient space dimension     = %i \n', nD  );
fprintf( logID, 'Nearest neighbor number     = %i \n', nN  );

yVal = zeros( nN * nYL, 1 );          % Local nearest neighbor distances
yInd = zeros( nN * nYL, 1, 'int32' ); % Local nearest neighbor indices


fprintf( logID, 'Entering distance matrix calculation loop... \n' );
lIndStart = 1;
for iBatch = Options.batchOut( 1 ) : Options.batchOut( 2 )
    
    tic
    nQ  = Batch( iBatch ).batchSize;                % number of query points
    xQ = load( Batch( iBatch ).fileName, ...      % load query points
               Batch( iBatch ).dataName, ...      % from source data file
               Batch( iBatch ).ctfName );
    xQStr1 = [ 'xQ.', Batch( iBatch ).dataName ];  % string representing xQ, data
    xQStr2 = [ 'xQ.', Batch( iBatch ).ctfName ];   % string representing xQ, ctf
    eval( [ xQStr1, ' = double( ', xQStr1, ' );' ] ); % convert to double
    eval( [ xQStr2, ' = double( ', xQStr2, ' );' ] ); % convert to double 
    t = toc;
    fprintf( logID, 'READ (%i,%i) %i %2.4f \n', iBatch, iBatch, nQ, t );   
    
    tic
    evalStr = [ 'yNew = dmatCtf( ', xQStr1, ',', xQStr2,' );' ];
    eval( evalStr ); % Distance matrix for xQ
    t = toc;
    fprintf( logID, 'DMATCTF (%i,%i) %i %i %2.4f \n', ...
        iBatch, iBatch, nQ, nQ, t );

    tic
    [ yNN, jNN ] = mink( yNew, nN, 2 ); % operate along dimension 2 (cols).
    jNN          = jNN ...              % jNN is the local column index.       
                 + Batch( iBatch ).gInd( 1 ) - 1; 
    t = toc;
    fprintf( logID, 'MINK (%i,%i) %i %i %2.4f \n', ...
        iBatch, iBatch, nQ, nQ, t );

    jRead = 1 : nBatch;               % Determine which column batches
    jRead = jRead( jRead ~= iBatch ); % to read
    
    for jBatch = jRead % Loop over the columns 
            
        tic
        nT = Batch( jBatch ).batchSize;          % number of test points
        xT = load( Batch( jBatch ).fileName, ... % load test points
                   Batch( jBatch ).dataName, ...
                   Batch( iBatch ).ctfName );
        xTStr1 = [ 'xT.', Batch( jBatch ).dataName ]; % string for xT, data
        xTStr2 = [ 'xT.', Batch( jBatch ).ctfName ];  % string for xT, ctf
        eval( [ xTStr1, ' = double( ', xTStr1, ' );' ] ); % convert to double
        eval( [ xTStr2, ' = double( ', xTStr2, ' );' ] ); % convert to double 
        t = toc;
        fprintf( logID, 'READ (%i,%i) %i %2.4f \n', ...
            iBatch, jBatch, nT, t );
            
        tic
        evalStr = [ 'yNew = dmatCtf( ', xQStr1, ',',xQStr2, ',', xTStr1, ',',xTStr2, ' );' ];
        eval( evalStr ); % Distance matrix for xQ, xT
        t = toc;
        fprintf( logID, 'DMATCTF (%i,%i) %i %i %2.4f \n', ...
        iBatch, jBatch, nQ, nT, t );

        tic
        [ yNN, jNN2 ]  = mink( [ yNN, yNew ], nN, 2 );
        ifOld = jNN2 <= nN;
        for iQ = 1 : nQ
            jNN2( iQ, ifOld( iQ, : ) ) = ...
                jNN( iQ, jNN2( iQ, ifOld( iQ , : ) ) );
        end
        jNN2( ~ifOld ) = jNN2( ~ifOld ) - nN ...
                       + Batch( jBatch ).gInd( 1 ) - 1;
        jNN = jNN2;
        t = toc;
        fprintf( logID, 'MINK (%i,%i) %i %i %2.4f \n', ...
           iBatch, jBatch, nQ, nN, t );
        
    end

    tic
    [ yNN, jNN2 ] = sort( yNN, 2, 'ascend' ); % Sort in ascending
    for iQ = 1 : nQ                           % distance order
        jNN( iQ, : ) = jNN( iQ, jNN2( iQ, : ) );
    end
    t = toc;
    fprintf( logID, 'SORT (%i,%i) %i %i %2.4f \n', ...
           iBatch, jBatch, nQ, nN, t );

    nTot    = nN * nQ;
    lIndEnd = lIndStart + nTot - 1; 
    yVal( lIndStart : lIndEnd ) = reshape( yNN', nTot, 1 );
    yInd( lIndStart : lIndEnd ) = reshape( int32( jNN' ), nTot, 1 );
    fprintf( logID, 'LIND (%i) %i %i %2.4f \n', ...
        iBatch, lIndStart, lIndEnd, t );
    lIndStart = lIndEnd + 1;
end

clk = clock; % Exit gracefully
fprintf( logID, 'NNDISTCTF_SINGLE finished on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
fclose( logID );
