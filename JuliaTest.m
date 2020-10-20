tic
global n c R

n=2;
preset = 2; %1 is super cool with n = 2 and n = 6
R=2;

xvec = [-0.8 -0.123 0 -0.4];
yvec = [0.156 0.745 0 0.6];

cx=xvec(preset);
cy=yvec(preset);

c=cx + 1i*cy;


raw1=juliaraw(20);
raw2=juliaraw(200);
raw3=juliaraw(400);
toc
z = cat(3, raw1'/max(max(raw1)), raw2'/max(max(raw2)), raw3'/max(max(raw3)));

figure()
rawcombined=image(z);
axis equal
cd JuliaPics
saveas(gcf,['Julia_' 'n' num2str(n) '_R' num2str(R) '_cx' num2str(cx) '_cy' num2str(cy) '.png'])
cd ..

axis equal

function [rawimg]=juliaraw(Niter)

global n c R


Nx=2560;
Ny=1440;

xlim_lo=-2;
xlim_hi=2;

ylim_lo=-1;
ylim_hi=1;

rawimg=zeros(Nx,Ny);

xcoord=linspace(xlim_lo,xlim_hi,Nx);
ycoord=linspace(ylim_lo,ylim_hi,Ny);

[X,Y]=meshgrid(xcoord,ycoord);
X=X';
Y=Y';
for i = 1:Nx
    for j = 1:Ny
        z=X(i,j) + 1i*Y(i,j);
        iter=0;
        while iter < Niter && abs(z) < R
            z=z^n + c + 0.1*z^4;
            %z=(1-(z^3 / 6))/(z-0.5*z^2)^2+c; %woah
            iter = iter+1;
        
        end
        if iter < Niter
            %plot(x0,y0,'kx')
            %hold on
            rawimg(i,j)=iter;
        end
    end
end
end