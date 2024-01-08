nS           = N-concatOrder;
nNIn         = nN;

yVal = zeros( nS * nN, 1 );
yCol = zeros( nS * nN, 1 );

logfile  = [ './dataY', ...
	     '_nN'  ,   int2str( nN ), ...
	     '_sym.log' ];
logID = fopen( logfile, 'w' );

clk = clock;
fprintf( logID, 'scriptDistanceMatrixSymmetrization starting on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );

nBatch = nS / nB;
for iBatch = 1 : nBatch
    indStart = 1 + ( iBatch - 1 ) * nB * nN;
    indEnd   = iBatch * nB * nN;
    jStart   = 1 + ( iBatch - 1 ) * nB;
    jEnd     = iBatch * nB;
    disp( [ 'Batch ', int2str( iBatch ) ] )
    disp( [ 'Diffraction pattern  indices ', int2str( jStart ), ...
            ' -- ',               int2str( jEnd ) ] )
    disp( [ 'Linear indices in the non-symmetric dist. matrix ', ...
            int2str( indStart ), ' -- ', int2str( indEnd ) ] )

    tic
    fileName = [ 'dataY', '_nS', int2str( nS ), ...
                          '_nN',  int2str( nNIn ), ...
                          '_iB', int2str( iBatch ), '.mat' ];		  
    DataBatch = load( fileName, 'yVal' );
    t = toc;
    fprintf( logID, 'READ (%i) %i %i %2.4f \n', iBatch, jStart, jEnd, t );

    tic
    DataBatch.yVal = reshape( DataBatch.yVal, [ nNIn, nB ] );
    DataBatch.yVal = DataBatch.yVal( 1 : nN, : );
    DataBatch.yVal( 1, : ) = 0;
    yVal( indStart : indEnd ) = reshape( ...
                                DataBatch.yVal, [ nN * nB, 1 ] );
    DataBatch = load( fileName, 'yInd' );
    DataBatch.yInd = reshape( DataBatch.yInd, [ nNIn, nB ] );
    DataBatch.yInd = DataBatch.yInd( 1 : nN, : );
    yCol( indStart : indEnd ) = double( reshape( ...
                                DataBatch.yInd, [ nN * nB, 1 ] ) );
    t = toc;
    fprintf( logID, 'TRIM (%i) %i %i %2.4f \n', iBatch, nNIn, nN, t );

end
clear DataBatch

disp( 'Symmetrizing the distance matrix...' )
disp( [ 'The total number of entries is ', int2str( nS * nN ) ] )

tic
yRow = ones( nN, 1 ) * ( 1 : nS );
yRow = reshape( yRow, nS * nN, 1 );
ifZero = yVal < 1E-6;
yRowNZ = yRow( ~ifZero );
yColNZ = yCol( ~ifZero ); 
yValNZ = sqrt( yVal( ~ifZero ) );
nNZ    = length( yRowNZ );
disp( [ 'The number of nonzero elements in the non-sym matrix is ', ...
        int2str( nNZ ) ] )
clear yVal 

yRow = yRow( ifZero );
yCol = yCol( ifZero );
nZ   = length( yRow );
disp( [ 'The number of zero elements in the non-sym matrix is ', ...
       int2str( nZ ) ] ) 
clear ifZero
t = toc;
fprintf( logID, 'ZEROSCAN (non-symmetric) %i %i %i %2.4f \n', ...
         nS * nN, nNZ, nZ, t );

tic
y = sparse( yRowNZ, yColNZ, yValNZ, nS, nS, nNZ );
clear yRowNZ yColNZ yValNZ
y2 = y .* y.'; % y2 contains the squares of the distances
y = y .^ 2;
y = y + y' - y2;
clear y2 % preserve memory
t = toc;
fprintf( logID, 'SYMNZ %2.4f \n', t );

tic
[ yRowNZ, yColNZ, yValNZ ] = find( y ); % Get the nonzero elements of y in
                                        % column vector format. This will 
                                        % probably not be needed in the future
                                        % but is presently done to ensure 
                                        % compatibility w/ the current version
                                        % of slaplacian 
nNZ = nnz( y );
disp( [ 'The number of nonzero elements in the sym matrix is ', ...
       int2str( nNZ ) ] )
t = toc;
fprintf( logID, 'COLVECNZ %i %2.4f \n', nNZ, t );

tic
y    = sparse( yRow, yCol, ones( nZ, 1 ), nS, nS, nZ );
y2   = y .* y.'; 
y    = y + y' - y2;
clear y2 % preserve memory
t = toc;
fprintf( logID, 'SYMZ %2.4f \n', t );

tic
%y    = sparse( yRow, yCol, ones( nZ, 1 ), nS, nS, nZ );
[ yRow, yCol, yVal ] = find( y );
yVal( 1 : end ) = 0;
nZ = nnz( y );
disp( [ 'The number of zero elements in the sym matrix is ', ...
        int2str( nZ ) ] )
t = toc;
fprintf( logID, 'COLVECZ %i %2.4f \n', nZ, t );

tic
yRow = int32( [ yRow; yRowNZ ] ); % preserve disk space
clear yRowNZ
yCol = int32( [ yCol; yColNZ ] ); 
clear yColNZ 
yVal = [ yVal; yValNZ ];
clear yValNZ
t = toc;
fprintf( logID, 'MERGE %2.4f \n', t );

tic
fileName = [ 'dataY', ... 
             '_nS',    int2str( nS ), ...
             '_nN',    int2str( nN ),  ...
             '_sym.mat' ];    
save( fileName, 'yRow', 'yCol', 'yVal', '-v7.3' ) % support large files
t = toc;
fprintf( logID, 'WRITE %i %2.4f \n', length( yVal ), t );

clk = clock; % Exit gracefully
fprintf( logID, 'scriptSymmetrizeDistanceMatrix finished on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
fclose( logID );
