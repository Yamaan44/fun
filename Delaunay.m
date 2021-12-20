clear;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INPUTS

rng(40);
color1 = 'Purple';
color2 = 'Amethyst';
edgecolor = 'Navy'; %set to a color, 'None', or 'Gradient' which follows color1:color2
orientation = 1; %1 for horizontal gradient, 2 for vertical
x_length = 2;
y_length = 1;
N_points = 90;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xrange = x_length;
yrange = y_length;
x = xrange*rand([N_points,1]);
y = yrange*rand([N_points,1]);
x = [x; 0; 0; xrange; xrange];
y = [y; 0; yrange; 0; yrange];

dt = DelaunayTri(x,y);
T = dt.Triangulation;
hold on

%order T from leftmost to rightmost
ic = incenters(dt);
ic = [ic, (1:length(ic))'];
sortedic = sortrows(ic,orientation); %1 for horizontal, 2 for vertical

%colormap
len = length(T);
color1 = rgb(color1);
color2 = rgb(color2);

colors_p = [linspace(color1(1),color2(1),len)', linspace(color1(2),color2(2),len)', linspace(color1(3),color2(3),len)'];

%if ones(len,3).*rgb(edgecolor)
%    edgecolor=ones(len,3).*rgb(edgecolor);
%end
if strcmp(edgecolor, 'Gradient') %if we want a gradient edge, follow the color palette
    edgecolor = colors_p;
elseif ~strcmp(edgecolor, 'None') %if we want a set color, set edge color to be the one color
    edgecolor=ones(len,3).*rgb(edgecolor);
end
for j = 1:length(T)
    i=sortedic(j,3);
    trIdx = T(i,:);
    triTemp = [x(trIdx(1)),y(trIdx(1));
                    x(trIdx(2)),y(trIdx(2));
                    x(trIdx(3)),y(trIdx(3))]; %matrix 3x2 of 3 x coordinates and 3 y coordinates defining triangle
    if strcmp(edgecolor, 'None') %if we want no edge
        patch(triTemp(:,1)',triTemp(:,2)',colors_p(j,:),'EdgeColor','None');
    else
        patch(triTemp(:,1)',triTemp(:,2)',colors_p(j,:),'EdgeColor',edgecolor(j,:));
    end
end


axis equal
xlim([0 xrange])
ylim([0 yrange])
set(gca,'visible','off')
exportgraphics(gca,'Pic1.png','BackgroundColor','none')