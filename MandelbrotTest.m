tic
raw1=mandelbrotraw(20);
raw2=mandelbrotraw(200);
raw3=mandelbrotraw(2000);
toc
z = cat(3, raw1'/max(max(raw1)), raw2'/max(max(raw2)), raw3'/max(max(raw3)));

figure()
rawcombined=image(z);
saveas(gcf,['Mandelbrot.png'])


function [rawimg]=mandelbrotraw(Niter)

Nx=2560;
Ny=1440;

xlim_lo=-2.5;
xlim_hi=1;

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
        x0=X(i,j);
        y0=Y(i,j);
        c=x0 + 1i*y0;
        z=0;
        iter=0;
        while iter < Niter && abs(z) < 2
            z = z^2 + c;
            iter = iter+1;
        end
        if iter < Niter
            rawimg(i,j)=iter;
        end
    end
end
end
