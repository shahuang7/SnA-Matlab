function [ cFit, resNorm, residual ] = so3fit( psi, varargin )

nE = size( psi, 1 ); % number of eigenfuncs in reconstruction(=iEigsR = 18)
nD = size( psi, 2 ); % number of data points    (=nR = 1000)

% Parse optional arguments
Options.x0 =  reshape( eye( 9, nE ), [ 9 * nE, 1 ] ); % Initial iterate 
Options.lb = -1.5 * ones( 81, 1 );            % Lower bound 
Options.ub =  1.5 * ones( 81, 1 );            % Upper bound

Options.Display = 'iter';
Options = parseargs( Options, varargin{ : } );
Options.PlotFcns = []; 


% Constants to be used below
id3 = eye( 3 );                 % 3x3 identity matrix
iLowTri = [ 1, 2, 3, 5, 6, 9 ]; % linear indices of the lower triangular
                                % part of a matrix

OptiOptions = optimset( 'Display', Options.Display, 'MaxFunEvals', 1E4 );

[ cFit, resNorm, residual ] = ...
    lsqnonlin( @f, Options.x0, Options.lb, Options.ub, OptiOptions );
cFit = reshape( cFit, [ 9, nE ] );   % size(cFit) = 9  18

% Objective function

function v = f( x )
    
    c = reshape( x, [ 9, nE ] );
        
    v = zeros( 7 * nD, 1 ); % do not contrain ref. rotation axis
       
    for iD = 1 : nD
    
        % Make a rotation matrix at the current datapoint;
        r = c * psi( :, iD );
%         sr = size(r)
%         sc = size(c)
%         sp = size(psi(:,iD))
%         pause
        r = reshape( r, [ 3, 3 ] );
        rTr = r' * r - id3;
        
        v( ( 1 : 6 ) + ( iD - 1 ) * 7 ) = ...
            rTr( iLowTri )';                    % orthogonality contraint   
        v( 7 + ( iD - 1 ) * 7 ) = det( r ) - 1; % handedness constraint

    end
    
end

end
