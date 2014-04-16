% MATnet alpha version
% A class for managing networks, consisting of nodes and edges with many
% attributes.
%
% Ioannis Psorakis, Pattern Analysis and Machine Learning Research Group
% University of Oxford
% yannis@robots.ox.ac.uk
% 2012

classdef matnet
    
    properties
        nodes
        edges
        
        graph_attributes
        comments
        
        is_directed
        
        A
    end
    
    properties(Hidden)
        changed
    end
    
    methods
        %% CONSTRUCTORS
        function obj = matnet(is_directed)
            obj.nodes = containers.Map();
            obj.edges = containers.Map();
            
            
            obj.graph_attributes = struct;
            
            obj.is_directed = is_directed;
            
            obj.comments = '';
            
            obj.A;
        end
        
        %% POPULATE GRAPH
        function add_node(obj,name,varargin)
            if nargin<1
                error('need more arguments')
            end
            
            if nargin<2
                error('first field must be the node name')
            end
            
            if obj.node_exists(name)
                %disp('node already exists, returning. Try edit_node() instead')
                return
            end
            
            aNode = struct;
            aNode.name = name;
            if length(varargin)>1
                if mod(length(varargin),2)==0
                    for i=1:2:length(varargin)-1
                        field_name = varargin{i};
                        aNode.(field_name) = varargin{i+1};
                    end
                else
                    error('please enter node attributes as ''attributeName'',attributeValue pairs')
                end
            end
            
            aNode.MATRIX_INDEX = obj.nodes.Count + 1;
            %
            obj.nodes(name) = aNode;
        end
        
        function add_edge(obj,from_node_name,to_node_name,edge_type,varargin)
            if nargin<3
                error('need at least from->to arguments')
            end
            
            if nargin<4
                edge_type = 'default';
            end
            
            if ~(obj.node_exists(from_node_name) && obj.node_exists(to_node_name))
                error('both nodes must exist in the network')
            end
            
            % check if link already exists
            if obj.edge_exists(from_node_name,to_node_name,edge_type)
                %disp('edge already exists, returning. Try edit_node() instead')
                return
            end
            
            % main fields
            anEdge = struct;
            anEdge.('from') = from_node_name;
            anEdge.('to') = to_node_name;
            anEdge.('type') = edge_type;
            
            % other fields
            if length(varargin)>1
                if mod(length(varargin),2)==0
                    for i=1:2:length(varargin)-1
                        field_name = varargin{i};
                        anEdge.(field_name) = varargin{i+1};
                    end
                else
                    error('please enter edge attributes as ''attributeName'',attributeValue pairs')
                end
            end
            
            %
            edge_name = [from_node_name,'->',to_node_name,':',edge_type];
            anEdge.('name') = edge_name;
            %anEdge.MATRIX_INDEX = obj.edges.Count+1;
            
            obj.edges(edge_name) = anEdge;
        end
        
        % FAST IMPLEMENTATIONS - no checks performed
        function fast_add_node(obj,name)
            aNode = struct;
            aNode.name = name;
            aNode.MATRIX_INDEX = obj.nodes.Count + 1;
            %
            obj.nodes(name) = aNode;
        end            
        
        function fast_add_edge(obj,from_node_name,to_node_name,edge_type,varargin)
            anEdge = struct;
            anEdge.('from') = from_node_name;
            anEdge.('to') = to_node_name;
            anEdge.('type') = edge_type;
            edge_name = [from_node_name,'->',to_node_name,':',edge_type];
            anEdge.('name') = edge_name;  
            obj.edges(edge_name) = anEdge;
        end
        
        function add_graph_attributes(obj,varargin)
            if nargin<2
                return
            end
            
            if length(varargin)>1
                if mod(length(varargin),2)==0
                    for i=1:2:length(varargin)-1
                        field_name = varargin{i};
                        obj.graph_attributes.(field_name) = varargin{i+1};
                    end
                else
                    error('please enter graph attributes as ''attributeName'',attributeValue pairs')
                end
            end
        end
        
        %% EDIT PROPERTIES
        function edit_node(obj,node_name,varargin)
            if ~obj.nodes.isKey(node_name)
                error(['Node ' + node_name + ' does not exist.'])
            end
            
            if length(varargin)>1
                if mod(length(varargin),2)==0
                    aNode = obj.nodes(node_name);
                    for i=1:2:length(varargin)-1
                        field_name = varargin{i};
                        aNode.(field_name) = varargin{i+1};
                    end
                    
                    obj.nodes(node_name) = aNode;
                else
                    error('please enter node attributes as ''attributeName'',attributeValue pairs')
                end
            end
        end
        
        function edit_edge(obj,from_node_name,to_node_name,edge_type,varargin)
            edge_name = [from_node_name,'->',to_node_name,':',edge_type];
            if ~obj.edges.isKey(edge_name)
                error(['Edge ' + node_name + ' does not exist.'])
            end
            
            if length(varargin)>1
                if mod(length(varargin),2)==0
                    anEdge = obj.edges(edge_name);
                    for i=1:2:length(varargin)-1
                        field_name = varargin{i};
                        anEdge.(field_name) = varargin{i+1};
                    end
                    
                    obj.edges(anEdge.name) = anEdge;
                else
                    error('please enter node attributes as ''attributeName'',attributeValue pairs')
                end
            end
        end
        
        %% EXIST CHECKERS
        function exists = node_exists(obj,node_name)
            exists =  obj.nodes.isKey(node_name);
        end
        
        function exists = edge_exists(obj,from_node_name,to_node_name,edge_type)
            if nargin<4
                edge_type = 'default';
            end
            
            if obj.is_directed
                edge_key = [from_node_name,'->',to_node_name,':',edge_type];
                exists = obj.edges.isKey(edge_key);
            else
                edge_key_1 = [from_node_name,'->',to_node_name,':',edge_type];
                edge_key_2 = [to_node_name,'->',from_node_name,':',edge_type];
                
                exists = obj.edges.isKey(edge_key_1) || obj.edges.isKey(edge_key_2);
            end
        end
        
        %% GETTERS
        function aNode = get_node(obj,node_name)
            if obj.node_exists(node_name)
                aNode = obj.nodes(node_name);
            else
                error('no such node name exists.')
            end
        end
        
        function anEdge = get_edge(obj,from_node_name,to_node_name,edge_type)
            if nargin<4
                edge_type = 'default';
            end
            
            if obj.edge_exists(from_node_name,to_node_name,edge_type)
                if obj.is_directed
                    edge_key = [from_node_name,'->',to_node_name,':',edge_type];
                    anEdge = obj.edges(edge_key);
                else
                    edge_key_1 = [from_node_name,'->',to_node_name,':',edge_type];
                    edge_key_2 = [to_node_name,'->',from_node_name,':',edge_type];
                    
                    if obj.edges.isKey(edge_key_1)
                        anEdge = obj.edges(edge_key_1);
                    elseif obj.edges.isKey(edge_key_2)
                        anEdge = obj.edges(edge_key_2);
                    end
                end
            else
                error('no such edge exists')
            end
        end
        
        function [N K] = total_nodes(obj,mode_class_1,mode_class_2)
            if nargin<=1
                N = length(obj.nodes.keys);
                K = nan;
            else
                N = 0;
                K = 0;
                
                node_keys = obj.nodes.keys;
                for n=1:length(node_keys)
                    aNode = obj.nodes(node_keys{n});
                    if strcmp(aNode.mode_class,mode_class_1)
                        N = N + 1;
                    elseif strcmp(aNode.mode_class,mode_class_2)
                        K = K + 1;
                    end
                end
            end
        end
        
        function M = total_edges(obj,edge_type)
            if nargin<=1
                M = length(obj.edges.keys);
            elseif nargin==2
                M=0;
                edge_keys = obj.edges.keys;
                for m=1:length(edge_keys)
                    anEdge = obj.edges(edge_keys{m});
                    if strcmp(anEdge.type,edge_type)
                        M = M+1;
                    end
                end
            end
        end
        
        function nL = get_node_name_list(obj)
            nL = obj.nodes.keys;
        end
        
        function eL = get_all_edge_names_list(obj)
            eL = obj.edges.keys;
        end
        
        function E = get_edge_index_list(obj,edge_type)
            if nargin<2
                edge_type = 'default';
            end
            
            eL = obj.get_all_edge_names_list();
            M = obj.total_edges(edge_type);
            E = zeros(M,2);
            
            for m=1:M
                edge_name = eL{m};
                edge_name_tokens = strsplit_re(edge_name,'(->)|:');
                current_edge_type = edge_name_tokens{3};
                if ~strcmp(edge_type,current_edge_type)
                    continue
                end
                
                from_node = obj.nodes(edge_name_tokens{1});
                to_node = obj.nodes(edge_name_tokens{2});
                
                
                E(m,1) = from_node.MATRIX_INDEX;
                E(m,2) = to_node.MATRIX_INDEX;
            end
        end
        %% MATRIX IMPORT/EXPORT, UPDATE/OVERWRITE
        function import_adjacency_matrix_one_mode_network(obj,A,node_names,edge_type)
            if nargin<4
                edge_type = 'default';
            end
            
            N = size(A,1);
            if nargin<3
                node_names = cell(N,1);
                for n=1:N
                    node_names{n} = num2str(n);
                    obj.add_node(node_names{n});
                end
            else
                for n=1:N
                    obj.fast_add_node(node_names{n});
                end
            end
            
            
            [x, y] = find(A);
            for m=1:length(x)
                i = x(m);
                j = y(m);
                
                node_i = node_names{i};
                node_j = node_names{j};
                
                obj.fast_add_edge(node_i,node_j,edge_type,'weight',A(i,j));
            end
            
        end
        
        function [A node_indicesN node_indicesK] = get_adjacency_matrix(obj,edge_type,mode_classes)
            %%%%%%%%%%%%%%% UNIPARTITE GRAPH %%%%%%%%%%%%%%%
            if nargin<3
                
                N = obj.total_nodes();
                A = zeros(N);
                node_indicesN = cell(N,1);
                
                if nargin<2
                    edge_type = 'default';
                end
                
                edge_keys = obj.edges.keys;
                for m=1:length(edge_keys)
                    current_edge = obj.edges(edge_keys{m});
                    
                    if ~strcmp(current_edge.type,edge_type), continue, end;
                    
                    from_node = obj.nodes(current_edge.from);
                    to_node = obj.nodes(current_edge.to);
                    
                    from_node_index = from_node.MATRIX_INDEX;
                    to_node_index = to_node.MATRIX_INDEX;
                    
                    if isempty(node_indicesN{from_node_index})
                        node_indicesN{from_node_index} = from_node.name;
                    end
                    
                    if isempty(node_indicesN{to_node_index})
                        node_indicesN{to_node_index} = to_node.name;
                    end
                    
                    if isfield(current_edge,'weight')
                        A(from_node_index,to_node_index) = current_edge.weight;
                        if ~obj.is_directed
                            A(to_node_index,from_node_index) = current_edge.weight;
                        end
                    else
                        A(from_node_index,to_node_index) = 1;
                        if ~obj.is_directed
                            A(to_node_index,from_node_index) = 1;
                        end
                    end
                end
                
                node_indicesK = {};
            else %%%%%%%%%%% BIPARTITE GRAPH %%%%%%%%%%%
                % mode_classes{1}, mode_classes{2}
                nodes_from_mode_class1 = containers.Map();
                nodes_from_mode_class2 = containers.Map();
                
                nodes_from_mode_class1_count = 0;
                nodes_from_mode_class2_count = 0;
                
                node_keys = obj.nodes.keys;
                for n=1:length(node_keys)
                    aNode = obj.nodes(node_keys{n});
                    if strcmp(aNode.mode_class,mode_classes{1})
                        nodes_from_mode_class1_count = nodes_from_mode_class1_count + 1;
                        nodes_from_mode_class1(aNode.name) = nodes_from_mode_class1_count;
                    else
                        nodes_from_mode_class2_count = nodes_from_mode_class2_count + 1;
                        nodes_from_mode_class2(aNode.name) = nodes_from_mode_class2_count;
                    end
                end
                
                N = nodes_from_mode_class1.Count;
                K = nodes_from_mode_class2.Count;
                
                A = zeros(N,K);
                
                node_indicesN = cell(N,1);
                node_indicesK = cell(K,1);
                
                if nargin<2
                    edge_type = 'default';
                end
                
                edge_keys = obj.edges.keys;
                for m=1:length(edge_keys)
                    current_edge = obj.edges(edge_keys{m});
                    
                    if ~strcmp(current_edge.type,edge_type), continue, end;
                    
                    from_node = obj.nodes(current_edge.from);
                    to_node = obj.nodes(current_edge.to);
                    
                    from_node_index = nodes_from_mode_class1(from_node.name);
                    to_node_index = nodes_from_mode_class2(to_node.name);
                    
                    if isempty(node_indicesN{from_node_index})
                        node_indicesN{from_node_index} = from_node.name;
                    end
                    if isempty(node_indicesK{to_node_index})
                        node_indicesK{to_node_index} = to_node.name;
                    end
                    
                    if obj.is_directed
                        if ~(nodes_from_mode_class1.isKey(from_node.name) && nodes_from_mode_class2.isKey(to_node.name))
                            continue
                        end
                        %
                        if isfield(current_edge,'weight')
                            A(nodes_from_mode_class1(from_node.name),nodes_from_mode_class2(to_node.name)) = current_edge.weight;
                        else
                            A(nodes_from_mode_class1(from_node.name),nodes_from_mode_class2(to_node.name)) = 1;
                        end
                    else
                        if nodes_from_mode_class1.isKey(from_node.name) && nodes_from_mode_class2.isKey(to_node.name)
                            if isfield(current_edge,'weight')
                                A(nodes_from_mode_class1(from_node.name),nodes_from_mode_class2(to_node.name)) = current_edge.weight;
                            else
                                A(nodes_from_mode_class1(from_node.name),nodes_from_mode_class2(to_node.name)) = 1;
                            end
                        elseif obj.nodes_from_mode_class1.isKey(to_node.name) && obj.nodes_from_mode_class2.isKey(from_node.name)
                            if isfield(current_edge,'weight')
                                A(nodes_from_mode_class1(to_node.name),nodes_from_mode_class2(from_node.name)) = current_edge.weight;
                            else
                                A(nodes_from_mode_class1(to_node.name),nodes_from_mode_class2(from_node.name)) = 1;
                            end
                        end
                    end
                end
            end
        end
        
        %% FILE IMPORT/EXPORT
        function export_to_GML(obj,output_filename)
            if ~strcmp(output_filename(end-3:end),'.gml')
                output_filename = [filename,'.gml'];
            end
            
            fid = fopen(output_filename,'w');
            fprintf(fid,'graph\r\n');
            fprintf(fid,'[\r\n');
            
            fprintf(fid,'\tdirected %d\r\n',obj.is_directed);
            fprintf(fid,'\tcomment "%s"\r\n',obj.comments);
            
            graph_attribute_names = fieldnames(obj.graph_attributes);
            for i=1:length(graph_attribute_names)
                att_name = graph_attribute_names{i};
                att_value = obj.graph_attributes.(graph_attribute_names{i});
                smart_print(fid,'\t',att_name,att_value,'\r\n');
            end
            
            % NODES
            node_names = obj.nodes.keys;
            N = length(node_names);
            for n=1:N
                current_node_name = node_names{n};
                current_node = obj.nodes(current_node_name);
                
                %open leaf
                fprintf(fid,'\tnode\r\n\t[\r\n');
                %fprintf(fid,'\t\tid %d\r\n',i);
                smart_print(fid,'\t\t','id',current_node_name,'\r\n');
                
                % iterate through attributes
                node_attributes = fieldnames(current_node);
                for k=1:length(node_attributes)
                    att_name = node_attributes{k};
                    if strcmp(att_name,'name'),continue,end;
                    att_value = current_node.(node_attributes{k});
                    
                    smart_print(fid,'\t\t',att_name,att_value,'\r\n');
                end
                %close leaf
                fprintf(fid,'\t]\r\n');
            end
            
            % EDGES
            edge_names = obj.edges.keys;
            M = length(edge_names);
            for m=1:M
                current_edge_name = edge_names{m};
                current_edge = obj.edges(current_edge_name);
                
                % open leaf
                fprintf(fid,'\tedge\r\n\t[\r\n');
                
                % source/target
                smart_print(fid,'\t\t','source',current_edge.from,'\r\n');
                smart_print(fid,'\t\t','target',current_edge.to,'\r\n');
                
                % iterate through attributes
                edge_attributes = fieldnames(current_edge);
                for k=1:length(edge_attributes)
                    att_name = edge_attributes{k};
                    if strcmp(att_name,'from')||strcmp(att_name,'to'),continue,end;
                    if strcmp(att_name,'weight'),att_name = 'value';end;
                    att_value = current_edge.(edge_attributes{k});
                    
                    smart_print(fid,'\t\t',att_name,att_value,'\r\n');
                end
                
                % close cleaf
                fprintf(fid,'\t]\r\n');
            end
            
            fprintf(fid,']');
            fclose(fid);
            
            function smart_print(fid,head,att_name,att_value,tail)
                if ~ischar(att_value) && length(att_value)>1
                    return
                end
                
                if ischar(att_value)
                    mask = '"%s"';
                elseif (att_value - round(att_value))==0%isinteger(att_value)
                    mask = '%d';
                elseif isreal(att_value)
                    mask = '%.2f';
                else
                    error('oops');
                end
                
                content = [head,att_name,' ',mask,tail];
                %fprintf(content,att_value);
                fprintf(fid,content,att_value);
            end
        end
        
        %% BASIC SNA - DEGREES
        function k = get_degree(obj,node_name)
            if ~obj.node_exists(node_name)
                error('no such node name exists.')
            end
            
            k=0;
            edge_list = obj.nodes.keys;
            for m=1:length(edge_list)
                k = k + ~isemtpy(regexp(edge_list{m},node_name));
            end
        end
        
        function kin = get_in_degree(obj,node_name)
            if ~obj.node_exists(node_name)
                error('no such node name exists.')
            end
            
            kin=0;
            edge_list = obj.nodes.keys;
            for m=1:length(edge_list)
                kin = kin + ~isemtpy(regexp(edge_list{m},['->',node_name]));
            end
        end
        
        function kout = get_out_degree(obj,node_name)
            if ~obj.node_exists(node_name)
                error('no such node name exists.')
            end
            
            kout=0;
            edge_list = obj.nodes.keys;
            for m=1:length(edge_list)
                kout = kout + ~isemtpy(regexp(edge_list{m},[node_name,'->']));
            end
        end
        
        %% BASIC SNA - PATHS
        function [path] = find_path_breadth_first_search(obj,from_node_name,to_node_name,edge_type)
            if nargin<4
                edge_type = 'default';
            end
            
            [A, node_indicesN] = get_adjacency_matrix(obj,edge_type);
            
            startnode = node_indicesN(from_node_name);
            endnode = node_indicesN(to_node_name);
            
            path = matnet.broad_search(A,startnode,endnode);
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Static)
        %% NETWORK OPERATIONS
        function path = broad_search(A,startnode,endnode)
            N = size(A,1);
            visited = boolean(0)*ones(1,N);
            path = zeros(1,N);
            nodes = queue(N);
            found=false;
            
            nodes.add(startnode);
            visited(startnode) = true;
            if startnode==endnode
                found = true;
            else
                search();
            end
            
            %disp('Path found:')
            % path(find(path==0,1,'first'))=startnode
            % path = path(path~=0)
            path = path(length(path):-1:1);
            
            function search()
                currentnode = nodes.remove();
                adjacency_set = find(A(currentnode,:)>0);
                
                for i=1:length(adjacency_set)
                    if ~visited(adjacency_set(i))
                        visited(adjacency_set(i))=true;
                        nodes.add(adjacency_set(i))
                        if adjacency_set(i) == endnode
                            path(find(path==0,1,'first'))=adjacency_set(i);
                            found = true;
                            break;
                        end
                    end
                end
                
                if found==false
                    search();
                else
                    path(find(path==0,1,'first')) = currentnode;
                end
            end
        end
        
        %% I/O
        function net = import_from_GML(filename)
            
            fid = fopen(filename);
            
            % entering_node = false;
            % entering_edge = false;
            
            in_header = false;
            
            while 1
                if in_header
                    in_header = false;
                else
                    rawline = fgetl(fid);
                    if ~ischar(rawline), break, end;
                    
                    rawline = strtrim(rawline);
                end
                % PROCESS HEADER
                if strcmp(rawline,'graph')
                    in_header = true;
                    while isempty(regexp(rawline,'node', 'once')) && isempty(regexp(rawline,'edge', 'once'))
                        rawline = strtrim(fgetl(fid));
                        
                        linecontents = strsplit(rawline,' ');
                        if length(linecontents)~=2,continue,end
                        
                        if strcmp(linecontents{1},'comment')
                            comment = rawline(8:end);
                        elseif strcmp(linecontents{1},'directed')
                            is_directed = logical(str2double(remove_quotes(linecontents{2})));
                        elseif strcmp(linecontents{1},'id')
                            id = remove_quotes(linecontents{2});
                        elseif strcmp(linecontents{1},'label')
                            label = remove_quotes(linecontents{2});
                        end
                    end
                    
                    if ~exist('is_directed','var')
                        is_directed = true;
                    end
                    net = matnet(is_directed);
                    
                    if exist('comment','var')
                        net.comments = comment;
                    end
                    
                    if exist('id','var')
                        net.add_graph_attributes('id',id);
                    end
                    
                    if exist('label','var')
                        net.add_graph_attributes('label',label);
                    end
                    
                    % PROCESS EDGE
                elseif strcmp(rawline,'edge')
                    while ~strcmp(rawline,']')
                        rawline = strtrim(fgetl(fid));
                        
                        linecontents = strsplit(rawline,' ');
                        if length(linecontents)~=2,continue,end
                        
                        if strcmp(linecontents{1},'source')
                            source = remove_quotes(linecontents{2});
                        elseif strcmp(linecontents{1},'target')
                            target = remove_quotes(linecontents{2});
                        elseif strcmp(linecontents{1},'value')
                            value = str2double(remove_quotes(linecontents{2}));
                        elseif strcmp(linecontents{1},'type')
                            edge_type = remove_quotes(linecontents{2});
                        end
                    end
                    
                    if ~exist('edge_type','var')
                        edge_type = 'default';
                    end
                    
                    net.add_edge(source,target,edge_type);
                    
                    if exist('value','var')
                        net.edit_edge(source,target,edge_type,'weight',value);
                    end
                    % PROCESS NODE
                elseif strcmp(rawline,'node')
                    while ~strcmp(rawline,']')
                        rawline = strtrim(fgetl(fid));
                        
                        linecontents = strsplit(rawline,' ');
                        
                        if length(linecontents)~=2,continue,end
                        
                        attributes = containers.Map();
                        
                        if strcmp(linecontents{1},'id')
                            id = linecontents{2};
                        elseif strcmp(linecontents{1},'label')
                            label = remove_quotes(linecontents{2});
                        else
                            attributes(linecontents{1}) = remove_quotes(linecontents{2});
                        end
                    end
                    
                    net.add_node(id);
                    if exist('label','var')
                        net.edit_node(id,'label',label);
                    end
                    attribute_names = attributes.keys;
                    for a=1:length(attribute_names)
                        net.edit_node(id,attribute_names{a},attributes(attribute_names{a}));
                    end
                end
            end
            
            fclose(fid);
            
            function s = remove_quotes(s)
                if isnumeric(s)
                    return
                end
                if (strcmp(s(1),'"') && strcmp(s(end),'"')) || (strcmp(s(1),'''') && strcmp(s(end),''''))
                    s = s(2:end-1);
                end
            end
        end
        
        %% RANDOM GRAPHS
        function A = get_ER_random_graph_adjacency_matrix(N,p)
            A = binornd(1,p,N,N);
            A = triu(A);
            A = A + A';
        end
        function [ER A] = get_ER_random_graph(N,p)
            A = matnet.get_ER_random_graph_adjacency_matrix(N,p);
            ER = matnet(0);
            ER.import_adjacency_matrix_one_mode_network(A);
        end
        
        %% AUX
        function S = sum_arithmetic_progression(N,a0,d)
            
            S = (N/2) * ( 2*a0 + (N-1)*d);
            
        end
        %
        function n = get_triu_number_of_elements(X)
            
            if ~isscalar(X)
                N = size(X,1);
            else
                N = X;
            end
            
            n = sum_arithmetic_progression(N-1,1,1);
            
        end
        function n = get_triu_elem_index(i,j,N)
            
            if i==1
                n = j-1;
            else
                n = get_triu_elem_index(i-1,N,N) + j - i;
            end
            
        end
        function [i, j] = get_triu_elem_i_j(e,N)
            
            if e<N
                i = 1;
                j = e+1;
            else
                max_elem_index_per_row = zeros(N-1,1);
                for n=1:N-1
                    max_elem_index_per_row(n) = get_triu_elem_index(n,N,N);
                end
                
                i = find(e<=max_elem_index_per_row,1);
                j = e-max_elem_index_per_row(i-1)+i;
                
            end
        end
    end
end