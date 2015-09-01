The distribution of Graph Agglomerative Clustering (GAC) toolbox is a summary of our work in the topic of agglomerative clustering on a graph.

Both graph-based clustering and agglomerative clustering have been studied extensively, while developing agglomerative clustering on a graph is a rarely investigated problem.

We proposed a simple and effective algorithm called graph degree linkage. It has better performance than normalized cuts and spectral clustering, and is much faster. In addition, the implementation of our algorithm is pretty simple. You don't need to have any matrix library (eigen-vector solver).

%%%%%%%%%%%%%%%%%%%%%%%

This toolbox is written and maintained by Wei Zhang (wzhang009 at gmail.com).
Please drop me an email if you find any bugs or have any suggestions.

Please cite the following paper, if you find the code is helpful.

W. Zhang, X. Wang, D. Zhao, and X. Tang. 
Graph Degree Linkage: Agglomerative Clustering on a Directed Graph.
in Proceedings of European Conference on Computer Vision (ECCV), 2012.

%%%%%%%%%%%%%%%%%%%%%%%

How to compile mex files?
I include mexw64 files. If you use a system other than win64, you can find a file called gdlCompileMex.m to help you build the mex files.

%%%%%%%%%%%%%%%%%%%%%%%

GDL-U and AGDL have similar performance.
GDL-U is for small datasets and AGDL is for large datasets. 
AGDL has an additional parameter Kc in gdlMergingKNN_c.m. The larger Kc is, the closer performance AGDL has to GDL-U and slower the algorithm is. Default Kc = 10 is a good trade-off for most datasets.

%%%%%%%%%%%%%%%%%%%%%%%

Examples:

K = 20;
a = 1;
% GDL-U algorithm
clusteredLabels = graphAgglomerativeClustering(distance_matrix, groupNumber, 'gdl', K, 1, a, false);
% AGDL algorithm
clusteredLabels = graphAgglomerativeClustering(distance_matrix, groupNumber, 'gdl', K, 1, a, true);

