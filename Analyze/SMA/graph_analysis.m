function [G] = graph_analysis(csig)
% At the moment consider unweighted graphs so convert to 0s and 1s will
% implement directionality later

N = length(csig);
B = zeros(N, N);

for i=1:N
    for j=i+1:N
        if (abs(csig(j,i)) > 0)
            B(j,i) = 1;
        end
    end
end

B = sparse(B);

fac = N/(N-1);

G.k = fac*num_edges(B)/num_vertices(B);
G.L = fac*mean(mean(all_shortest_paths(B)));
G.C = fac*mean(mean(clustering_coefficients(B)));
G.N = num_edges(B);
%C = fac*mean(mean(curvature(B)));
D = floyd_warshall_all_sp(B);
G.HL = HarmonicLength(D);